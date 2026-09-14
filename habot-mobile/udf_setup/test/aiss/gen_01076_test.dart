/// AISS GATE -- Step 163 of 175
/// Global Reference ID:       GEN-01076
/// Atomic Steps Reference ID: GEN-01076
/// Setup Step (Action) / Atomic Step: "Monitor form abandonment rates
///   associated with input validation errors via the dashboard."
/// Metric: Dashboard Data Refresh Latency -- Floor "<1 hour",
///         Optimal "<5 minutes", Ceiling "<24 hours". Good / Average / Poor.
///
/// TWO DIFFERENT THINGS SHARE THIS ROW: what is measured (abandonment
/// associated with validation errors) and how stale the panel showing it may
/// be. Both are gated, separately. "Associated with" is the whole requirement
/// and it is a join.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/telemetry/abandonment_monitor.dart';
import 'package:udf_setup/design_system/telemetry/event_schema.dart';
import 'package:udf_setup/design_system/tokens/motion_tokens.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  double? abandonmentRate;
  double? errorShare;

  void gate(String id, String source, String description, bool Function() run) {
    test('[$id] $description', () {
      bool passed = false;
      try {
        passed = run();
        expect(passed, isTrue, reason: '$id failed: $description');
      } finally {
        gates.add(
          AissGate(
            id: id,
            requirementSource: source,
            description: description,
            passed: passed,
          ),
        );
      }
    });
  }

  int ordinal = 0;

  HabotEvent rejected(String trace, String cde, {int attempt = 1}) =>
      HabotEvent(
        kind: HabotEventKind.validationRejected,
        view: 'referral_form',
        traceId: trace,
        occurredAt: DateTime.utc(2026, 8, 24, 10),
        sessionOrdinal: ordinal++,
        payload: <String, Object?>{'cde': cde, 'attempt_index': attempt},
      );

  HabotEvent completed(String trace, int index) => HabotEvent(
        kind: HabotEventKind.stepCompleted,
        view: 'referral_form',
        traceId: trace,
        occurredAt: DateTime.utc(2026, 8, 24, 10),
        sessionOrdinal: ordinal++,
        payload: <String, Object?>{
          'flow_id': 'f-$trace',
          'step_index': index,
          'step_count': 5,
          'time_on_step_ms': 3000,
        },
      );

  HabotEvent abandoned(
    String trace, {
    required bool withError,
    int index = 2,
  }) =>
      HabotEvent(
        kind: HabotEventKind.flowAbandoned,
        view: 'referral_form',
        traceId: trace,
        occurredAt: DateTime.utc(2026, 8, 24, 10),
        sessionOrdinal: ordinal++,
        payload: <String, Object?>{
          'flow_id': 'f-$trace',
          'step_index': index,
          'had_visible_error': withError,
        },
      );

  setUp(() => ordinal = 0);

  group('GEN-01076 :: "associated with", which is a join', () {
    gate(
      'GEN-01076-G1',
      'Atomic Step: "...form abandonment rates ASSOCIATED WITH input '
          'validation errors." "An abandonment count is not useful; an '
          'abandonment attributable to a named field is a bug report."',
      'An abandonment is joined to the validation rejections that preceded it '
          'on the same trace id, and is attributed to the LAST field that '
          'rejected the user -- someone who failed the postcode, fixed it, '
          'then failed the phone number and gave up was defeated by the phone '
          'number',
      () {
        final List<HabotEvent> events = <HabotEvent>[
          rejected('t1', 'postcode'),
          rejected('t1', 'phoneNumber', attempt: 2),
          abandoned('t1', withError: true),
        ];
        final List<HabotAbandonment> out =
            HabotAbandonmentMonitor.attribute(events);
        return events.every(HabotEventSchema.matches) &&
            out.length == 1 &&
            out.single.attributedCde == 'phoneNumber' &&
            out.single.hadVisibleError &&
            out.single.isAttributable &&
            out.single.stepIndex == 2 &&
            out.single.flowId == 'f-t1' &&
            HabotAbandonmentMonitor.lastRejectionNote
                .contains('double-counts') &&
            HabotAbandonmentMonitor.joinNote.contains('trace id');
      },
    );

    gate(
      'GEN-01076-G2',
      '"A completed step means whatever was wrong got fixed."',
      'A rejection followed by a completed step on the same trace does not '
          'attribute a later abandonment, so a field people routinely correct '
          'is not blamed for the one they eventually gave up on',
      () {
        final List<HabotEvent> events = <HabotEvent>[
          rejected('t2', 'postcode'),
          completed('t2', 0),
          abandoned('t2', withError: false),
        ];
        final HabotAbandonment a =
            HabotAbandonmentMonitor.attribute(events).single;
        return a.attributedCde == null &&
            !a.hadVisibleError &&
            !a.isAttributable;
      },
    );

    gate(
      'GEN-01076-G3',
      '"Works from the EVENTS rather than from live objects, so the figures '
          'are the ones the warehouse would produce from the same rows."',
      'Attribution depends only on the emitted event stream and its ordering, '
          'and the events it consumes are the ones Step 156 declares -- so a '
          'monitor cannot quietly disagree with the dashboard it is meant to '
          'explain',
      () {
        final List<HabotEvent> shuffled = <HabotEvent>[
          rejected('t3', 'phoneNumber'),
          abandoned('t3', withError: true),
        ].reversed.toList();
        final List<HabotAbandonment> out =
            HabotAbandonmentMonitor.attribute(shuffled);
        return out.single.attributedCde == 'phoneNumber' &&
            shuffled.every(HabotEventSchema.matches);
      },
    );
  });

  group('GEN-01076 :: the rate, and the denominator it needs', () {
    gate(
      'GEN-01076-G4',
      '"A monitor that only sees the ones who left reports 100% abandonment '
          'forever."',
      'The rate is abandonments over STARTS, counted from the same event '
          'stream, so four flows with one abandonment between them report 0.25 '
          'rather than 1.0',
      () {
        final List<HabotEvent> events = <HabotEvent>[
          completed('a', 0),
          completed('b', 0),
          abandoned('b', withError: true),
          completed('c', 0),
          completed('d', 0),
        ];
        abandonmentRate = HabotAbandonmentMonitor.abandonmentRate(events);
        return HabotAbandonmentMonitor.startsIn(events) == 4 &&
            abandonmentRate == 0.25 &&
            HabotAbandonmentMonitor.denominatorNote.contains('STARTS');
      },
    );

    gate(
      'GEN-01076-G5',
      '"A rate over a denominator of zero is the most misleading number a '
          'dashboard can show, and \'no data yet\' is a truthful panel state."',
      'With nothing started the rate is null rather than zero or one, and the '
          'error-associated share is null rather than an arbitrary figure',
      () =>
          HabotAbandonmentMonitor.abandonmentRate(const <HabotEvent>[]) ==
              null &&
          HabotAbandonmentMonitor.errorAssociatedShare(const <HabotEvent>[]) ==
              null &&
          HabotAbandonmentMonitor.worstField(const <HabotEvent>[]) == null &&
          HabotAbandonmentMonitor.startsIn(const <HabotEvent>[]) == 0,
    );

    gate(
      'GEN-01076-G6',
      '"The field to fix first." An abandonment count nobody can attribute is '
          'not actionable.',
      'Abandonments are broken down by the Critical Data Element that caused '
          'them, the worst field is named, and abandonments with no rejection '
          'behind them are excluded from that breakdown while still counting '
          'towards the rate',
      () {
        final List<HabotEvent> events = <HabotEvent>[
          rejected('p1', 'phoneNumber'),
          abandoned('p1', withError: true),
          rejected('p2', 'phoneNumber'),
          abandoned('p2', withError: true),
          rejected('p3', 'postcode'),
          abandoned('p3', withError: true),
          abandoned('p4', withError: false),
        ];
        final Map<String, int> byCde =
            HabotAbandonmentMonitor.abandonmentByCde(events);
        errorShare = HabotAbandonmentMonitor.errorAssociatedShare(events);
        return HabotAbandonmentMonitor.attribute(events).length == 4 &&
            byCde['phoneNumber'] == 2 &&
            byCde['postcode'] == 1 &&
            byCde.length == 2 &&
            HabotAbandonmentMonitor.worstField(events) == 'phoneNumber' &&
            errorShare == 0.75 &&
            HabotAbandonmentMonitor.abandonmentRate(events) == 1.0;
      },
    );
  });

  group('GEN-01076 :: the metric the row actually carries', () {
    gate(
      'GEN-01076-G7',
      'Metric: Dashboard Data Refresh Latency -- floor "<1 hour", optimal '
          '"<5 minutes", ceiling "<24 hours".',
      'The row\'s bands are implemented against the declared tokens and reach '
          'every state including Poor, and beyond the ceiling the panel is '
          'reported as stale rather than shown as a number',
      () =>
          HabotAbandonmentMonitor.optimal ==
              HabotMotion.dashboardRefreshOptimal &&
          HabotAbandonmentMonitor.floor == HabotMotion.dashboardRefreshFloor &&
          HabotAbandonmentMonitor.ceiling ==
              HabotMotion.dashboardRefreshCeiling &&
          HabotAbandonmentMonitor.optimal == const Duration(minutes: 5) &&
          HabotAbandonmentMonitor.floor == const Duration(hours: 1) &&
          HabotAbandonmentMonitor.ceiling == const Duration(hours: 24) &&
          HabotAbandonmentMonitor.bandFor(const Duration(minutes: 2)) ==
              'Good' &&
          HabotAbandonmentMonitor.bandFor(const Duration(minutes: 40)) ==
              'Average' &&
          HabotAbandonmentMonitor.bandFor(const Duration(hours: 6)) ==
              'Average' &&
          HabotAbandonmentMonitor.bandFor(const Duration(hours: 30)) ==
              'Poor' &&
          HabotAbandonmentMonitor.isStale(const Duration(hours: 30)) &&
          !HabotAbandonmentMonitor.isStale(const Duration(hours: 24)),
    );

    gate(
      'GEN-01076-G8',
      'COLUMN NOTE: the row carries a dashboard-freshness metric on an '
          'abandonment-monitoring step.',
      'The mismatch is recorded rather than resolved by ignoring one half: '
          'conflating them produces a dashboard that is either fresh and empty '
          'or full and wrong, and both halves are built',
      () =>
          HabotAbandonmentMonitor.twoThingsNote
              .contains('fresh and empty or full and wrong') &&
          HabotAbandonmentMonitor.twoThingsNote.contains('separately'),
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-01076',
        atomicStepReferenceId: 'GEN-01076',
        setupStepAction:
            'Monitor form abandonment rates associated with input validation '
            'errors via the dashboard.',
        implementationOrder: 163,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotAbandonmentMonitor / HabotAbandonment',
          'Component Properties':
              'Joins Step 156 validationRejected events to Step 160 '
              'flowAbandoned events on trace id, last rejection wins, cleared '
              'by a completed step; rate over flow starts; breakdown by '
              'Critical Data Element; freshness banded against the Step 129 '
              'dashboard tokens',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'COLUMN NOTE RECORDED: the metric on this row measures the '
              'dashboard\'s freshness, not abandonment. Both are implemented '
              'separately. CHOICE RECORDED: an abandonment is attributed to '
              'the LAST field that rejected the user; attributing to every '
              'field they hit double-counts and makes a field people routinely '
              'fix look as bad as one nobody can satisfy. The other reading is '
              'defensible and produces different numbers.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Dashboard Data Refresh Latency',
            observed:
                'Bands implemented against HabotMotion.dashboardRefresh* -- '
                'Good under 5 minutes, Average to 24 hours, Poor beyond, with '
                'the panel reported as stale rather than shown as a number '
                'past the ceiling. The observed age is supplied by whatever '
                'renders the panel; this step owns the vocabulary and the '
                'staleness rule.',
            floor: '<1 hour',
            optimal: '<5 minutes',
            ceiling: '<24 hours',
            higherIsBetter: false,
          ),
          AissMeasurement(
            metricName: 'Form abandonment rate associated with validation',
            observed:
                'Over the fixture stream: abandonment rate '
                '${abandonmentRate?.toStringAsFixed(2) ?? "null"} over flow '
                'STARTS (not over abandonments, which would read 1.0 forever), '
                'with ${errorShare == null ? "n/a" : (errorShare! * 100).toStringAsFixed(0)}% '
                'of abandonments attributable to a named field and '
                '"phoneNumber" reported as the field to fix first. Over an '
                'empty stream every figure is null and the panel says "no data '
                'yet" rather than showing a rate over a denominator of zero.',
            floor: 'attributable to a named CDE',
            optimal: 'attributable to a named CDE',
            ceiling: 'attributable to a named CDE',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/telemetry/abandonment_monitor.dart',
        ],
      ),
    );
  });
}
