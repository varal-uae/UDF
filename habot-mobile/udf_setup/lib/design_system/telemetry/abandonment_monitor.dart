/// AISS Step 163 -- GEN-01076
/// Setup Step (Action) / Atomic Step: "Monitor form abandonment rates
///   associated with input validation errors via the dashboard."
/// Metric: Dashboard Data Refresh Latency -- Floor "<1 hour",
///         Optimal "<5 minutes", Ceiling "<24 hours". Good / Average / Poor.
///
/// **THE METRIC IS ABOUT THE DASHBOARD'S FRESHNESS, NOT ABOUT ABANDONMENT.**
/// Two different things share this row: what is measured (abandonment
/// associated with validation errors) and how stale the panel showing it may
/// be. Both are handled, separately, because conflating them produces a
/// dashboard that is either fresh and empty or full and wrong.
///
/// **"ASSOCIATED WITH" IS THE WHOLE REQUIREMENT, AND IT IS A JOIN.**
/// An abandonment count is not useful; an abandonment count attributable to a
/// specific field is a bug report. The association needs two things the
/// previous steps produce: the `had_visible_error` flag on the Step 160
/// abandonment event, and the `validationRejected` events naming the Critical
/// Data Element. This step makes the join, on the trace id, and attributes an
/// abandonment to the LAST field that rejected the user before they left.
///
/// **WHY THE LAST REJECTION AND NOT ALL OF THEM.** A user who fails the
/// postcode, fixes it, then fails the phone number and gives up was defeated
/// by the phone number. Attributing the abandonment to both fields
/// double-counts and makes a field that people routinely fix look as bad as
/// one nobody can satisfy. The choice is stated because the other reading is
/// defensible and produces different numbers.
///
/// **A RATE NEEDS A DENOMINATOR THE CLIENT HAS.** Abandonments over STARTS,
/// not over abandonments — a monitor that only sees the ones who left reports
/// 100% abandonment forever. Starts come from the same tracker.
///
/// **THE FRESHNESS HALF REUSES STEP 129 RATHER THAN INVENTING A SECOND
/// VOCABULARY.** A panel's staleness is the same question the dashboard
/// already answers for KPI data, with different bounds.
library;

import '../tokens/motion_tokens.dart';
import 'event_schema.dart';

/// One abandonment, attributed.
class HabotAbandonment {
  const HabotAbandonment({
    required this.flowId,
    required this.stepIndex,
    required this.hadVisibleError,
    required this.attributedCde,
    required this.at,
  });

  final String flowId;
  final int stepIndex;
  final bool hadVisibleError;

  /// The Critical Data Element that last rejected this user, or null when
  /// they left without a rejection on screen.
  final String? attributedCde;

  final DateTime at;

  bool get isAttributable => hadVisibleError && attributedCde != null;
}

/// Joins abandonment events to the validation rejections that preceded them.
class HabotAbandonmentMonitor {
  const HabotAbandonmentMonitor._();

  /// Build the attributed set from a stream of Step 156 events.
  ///
  /// Works from the EVENTS rather than from live objects, so the figures this
  /// produces are the same ones the warehouse would produce from the same
  /// rows. A monitor computing from in-memory state can disagree with the
  /// dashboard it is meant to explain.
  static List<HabotAbandonment> attribute(Iterable<HabotEvent> events) {
    final Map<String, String> lastRejectionByTrace = <String, String>{};
    final List<HabotAbandonment> out = <HabotAbandonment>[];
    final List<HabotEvent> ordered = events.toList()
      ..sort((HabotEvent a, HabotEvent b) =>
          a.sessionOrdinal.compareTo(b.sessionOrdinal));
    for (final HabotEvent e in ordered) {
      switch (e.kind) {
        case HabotEventKind.validationRejected:
          final Object? cde = e.payload['cde'];
          if (cde is String) {
            // Last one wins -- see the header.
            lastRejectionByTrace[e.traceId] = cde;
          }
        case HabotEventKind.stepCompleted:
          // A completed step means whatever was wrong got fixed.
          lastRejectionByTrace.remove(e.traceId);
        case HabotEventKind.flowAbandoned:
          out.add(
            HabotAbandonment(
              flowId: e.payload['flow_id']! as String,
              stepIndex: e.payload['step_index']! as int,
              hadVisibleError: e.payload['had_visible_error'] == true,
              attributedCde: lastRejectionByTrace[e.traceId],
              at: e.occurredAt,
            ),
          );
        case HabotEventKind.viewOpened:
        case HabotEventKind.searchEmpty:
        case HabotEventKind.timingCaptured:
        case HabotEventKind.errorCaptured:
        case HabotEventKind.probeCompleted:
          break;
      }
    }
    return out;
  }

  /// Flow starts, counted from the events. The denominator.
  static int startsIn(Iterable<HabotEvent> events) {
    final Set<String> traces = <String>{};
    for (final HabotEvent e in events) {
      if (e.kind == HabotEventKind.stepCompleted ||
          e.kind == HabotEventKind.flowAbandoned) {
        traces.add(e.traceId);
      }
    }
    return traces.length;
  }

  /// The rate the row is about: abandonments over starts.
  ///
  /// Null when nothing started -- a rate over a denominator of zero is the
  /// most misleading number a dashboard can show, and "no data yet" is a
  /// truthful panel state.
  static double? abandonmentRate(Iterable<HabotEvent> events) {
    final int starts = startsIn(events);
    if (starts == 0) {
      return null;
    }
    return attribute(events).length / starts;
  }

  /// The subset the row actually asks for: abandonment ASSOCIATED WITH a
  /// validation error, broken down by the field that caused it.
  static Map<String, int> abandonmentByCde(Iterable<HabotEvent> events) {
    final Map<String, int> out = <String, int>{};
    for (final HabotAbandonment a in attribute(events)) {
      if (!a.isAttributable) {
        continue;
      }
      out[a.attributedCde!] = (out[a.attributedCde!] ?? 0) + 1;
    }
    return out;
  }

  /// Share of abandonments that had an error on screen. The number that says
  /// whether this is a validation problem at all, or people simply leaving.
  static double? errorAssociatedShare(Iterable<HabotEvent> events) {
    final List<HabotAbandonment> all = attribute(events);
    if (all.isEmpty) {
      return null;
    }
    return all.where((HabotAbandonment a) => a.isAttributable).length /
        all.length;
  }

  /// The field to fix first. Null when nothing is attributable, rather than
  /// an arbitrary pick.
  static String? worstField(Iterable<HabotEvent> events) {
    final Map<String, int> by = abandonmentByCde(events);
    if (by.isEmpty) {
      return null;
    }
    String worst = by.keys.first;
    for (final MapEntry<String, int> e in by.entries) {
      if (e.value > by[worst]!) {
        worst = e.key;
      }
    }
    return worst;
  }

  // ---- the row's metric: the dashboard's freshness ------------------------

  static Duration get optimal => HabotMotion.dashboardRefreshOptimal;
  static Duration get floor => HabotMotion.dashboardRefreshFloor;
  static Duration get ceiling => HabotMotion.dashboardRefreshCeiling;

  /// The row's vocabulary for an observed panel age.
  static String bandFor(Duration age) {
    if (age <= optimal) {
      return 'Good';
    }
    if (age <= floor) {
      return 'Average';
    }
    return age <= ceiling ? 'Average' : 'Poor';
  }

  /// Beyond the ceiling the panel is history rather than a dashboard, and
  /// should say so rather than showing a number.
  static bool isStale(Duration age) => age > ceiling;

  static const String joinNote =
      '"Associated with" is the whole requirement and it is a join. An '
      'abandonment count is not useful; an abandonment attributable to a '
      'named field is a bug report. The join needs the had_visible_error flag '
      'from Step 160 and the validationRejected events from Step 156, matched '
      'on trace id.';

  static const String lastRejectionNote =
      'An abandonment is attributed to the LAST field that rejected the user. '
      'Someone who failed the postcode, fixed it, then failed the phone number '
      'and gave up was defeated by the phone number. Attributing to both '
      'double-counts and makes a field people routinely fix look as bad as one '
      'nobody can satisfy. The other reading is defensible and produces '
      'different numbers, which is why the choice is stated.';

  static const String denominatorNote =
      'The rate is abandonments over STARTS. A monitor that only sees the '
      'people who left reports 100% abandonment forever, and a rate over a '
      'denominator of zero is the most misleading number a dashboard can show '
      '-- so it returns null and the panel says "no data yet".';

  static const String twoThingsNote =
      'The row carries a dashboard-freshness metric on an abandonment-'
      'monitoring step. They are different things and are handled separately: '
      'conflating them produces a dashboard that is either fresh and empty or '
      'full and wrong.';
}
