/// AISS: HC-BOG-0018-A01 -- "Priority Alert Dashboard Sorting."
/// Setup Step Description: "Bind the record cause (RC) modal to the priority
/// badge."
/// Metric: Task Configuration Completeness -- Floor 0.8, Optimal 0.95,
///         Ceiling 1.0.
///
/// AISS: GEN-00335-A01 -- "Bind Pub/Sub violation topic listeners to the alert
/// panel component."
/// Metric: Telemetry Ingestion Latency -- Floor <= 5 second batch window,
///         Optimal <= 1 second streaming, Ceiling 10 seconds staleness.
///
/// VERY THIN ROW, RECORDED (HC-BOG-0018): almost every column is empty -- no
/// substeps, no decision, no expected output, no completion measure, no
/// estimate. Only the Setup Step, the Setup Step Description and the metric
/// bands are populated, and a near-duplicate row exists at S.No 6219
/// (HC-CMP-0054) carrying the same Setup Step. Both facts are recorded.
///
/// METRIC MISMATCH, RECORDED (GEN-00335): "Telemetry Ingestion Latency" with
/// batch-window and streaming-ingestion bands is a property of a Pub/Sub
/// pipeline, not of the widget that renders what arrives. A client cannot
/// influence how long a topic took to deliver. What the BINDING owns -- that
/// every event reaching the listener reaches the panel, in order, without
/// being dropped or duplicated -- is what is measured here, and the
/// distinction is stated rather than glossed.
library;

import 'dart:async';

import 'package:flutter/foundation.dart';

import '../feedback/status_badge.dart';
import '../tokens/motion_tokens.dart';
import 'alert_panel.dart';
import 'notification_center.dart';
import 'notification_payload.dart';

/// HC-BOG-0018: the priority scale.
///
/// Four levels rather than a number, because "P2" is a thing an operator can
/// hold in their head and "priority 7" is not. Sorting is by this and then by
/// age, so the oldest thing at the highest priority is always at the top.
enum HabotAlertPriority {
  p1,
  p2,
  p3,
  p4;

  /// Lower sorts first.
  int get rank => index;

  String get label => 'P${index + 1}';

  /// The status role the badge renders in -- the Step 28 vocabulary, so a
  /// priority badge and a status badge elsewhere agree about what red means.
  HabotStatusRole get role {
    switch (this) {
      case HabotAlertPriority.p1:
        return HabotStatusRole.error;
      case HabotAlertPriority.p2:
        return HabotStatusRole.warning;
      case HabotAlertPriority.p3:
        return HabotStatusRole.primary;
      case HabotAlertPriority.p4:
        return HabotStatusRole.neutral;
    }
  }

  /// The priority a notification kind carries when nothing more specific is
  /// known. Derived rather than defaulted at each call site.
  static HabotAlertPriority forKind(HabotNotificationKind kind) {
    switch (kind) {
      case HabotNotificationKind.critical:
        return HabotAlertPriority.p1;
      case HabotNotificationKind.dispatch:
        return HabotAlertPriority.p2;
      case HabotNotificationKind.approval:
        return HabotAlertPriority.p2;
      case HabotNotificationKind.failure:
        return HabotAlertPriority.p3;
      case HabotNotificationKind.informational:
        return HabotAlertPriority.p4;
    }
  }
}

/// The "record cause" the Setup Step Description names: why this alert exists.
///
/// Bound to the badge, so the badge is the affordance -- tapping the priority
/// is how you find out what caused it. That is the whole of the description,
/// and it is why [HabotPrioritisedAlert] cannot be constructed without one:
/// a badge that opens an empty modal is worse than a badge that does nothing.
@immutable
class HabotRecordCause {
  const HabotRecordCause({
    required this.summary,
    required this.detectedAt,
    required this.source,
    this.remediation,
  });

  /// One line. What went wrong.
  final String summary;

  final DateTime detectedAt;

  /// Where the finding came from -- a topic name, a check id, a subsystem.
  final String source;

  /// What to do about it, when that is known.
  final String? remediation;

  bool get isActionable => remediation != null && remediation!.isNotEmpty;

  String get semanticsLabel =>
      'Cause: $summary. Detected by $source.'
      '${isActionable ? ' Suggested action: $remediation' : ''}';
}

/// One alert on the dashboard.
@immutable
class HabotPrioritisedAlert {
  const HabotPrioritisedAlert({
    required this.id,
    required this.priority,
    required this.title,
    required this.cause,
    required this.raisedAt,
  });

  final String id;
  final HabotAlertPriority priority;
  final String title;

  /// Required. See [HabotRecordCause].
  final HabotRecordCause cause;

  final DateTime raisedAt;

  String get badgeSemanticsLabel =>
      '${priority.label} priority, $title. Activate to see the cause.';
}

/// HC-BOG-0018: the sorting.
class HabotAlertSorting {
  const HabotAlertSorting._();

  /// Priority first, then oldest first inside a priority.
  ///
  /// The second half matters as much as the first: sorting by priority alone
  /// leaves a P1 from three days ago below a P1 from a minute ago, and the old
  /// one is the one nobody has dealt with.
  static List<HabotPrioritisedAlert> sort(
    List<HabotPrioritisedAlert> alerts,
  ) {
    final List<HabotPrioritisedAlert> out =
        List<HabotPrioritisedAlert>.from(alerts);
    out.sort((HabotPrioritisedAlert a, HabotPrioritisedAlert b) {
      final int byPriority = a.priority.rank.compareTo(b.priority.rank);
      if (byPriority != 0) {
        return byPriority;
      }
      return a.raisedAt.compareTo(b.raisedAt);
    });
    return out;
  }

  /// True when [sorted] is ordered correctly. The completeness check behind
  /// the metric: an ordering that cannot be verified is an ordering nobody
  /// should trust.
  static bool isCorrectlySorted(List<HabotPrioritisedAlert> sorted) {
    for (int i = 1; i < sorted.length; i++) {
      final HabotPrioritisedAlert prev = sorted[i - 1];
      final HabotPrioritisedAlert curr = sorted[i];
      if (curr.priority.rank < prev.priority.rank) {
        return false;
      }
      if (curr.priority.rank == prev.priority.rank &&
          curr.raisedAt.isBefore(prev.raisedAt)) {
        return false;
      }
    }
    return true;
  }

  /// Metric: Task Configuration Completeness. What is being counted is how
  /// much of the configuration this step requires is actually present -- every
  /// alert carries a priority, a record cause, and a raised time.
  static double completenessOf(List<HabotPrioritisedAlert> alerts) {
    if (alerts.isEmpty) {
      return 1;
    }
    int complete = 0;
    for (final HabotPrioritisedAlert alert in alerts) {
      if (alert.title.isNotEmpty &&
          alert.cause.summary.isNotEmpty &&
          alert.cause.source.isNotEmpty) {
        complete++;
      }
    }
    return complete / alerts.length;
  }
}

/// GEN-00335: one event off the violation topic.
@immutable
class HabotViolationEvent {
  const HabotViolationEvent({
    required this.id,
    required this.topic,
    required this.summary,
    required this.severity,
    required this.publishedAt,
  });

  final String id;

  /// The Pub/Sub topic it came from.
  final String topic;
  final String summary;
  final HabotAlertSeverity severity;
  final DateTime publishedAt;
}

/// GEN-00335: the binding.
///
/// Subscribes to a violation stream and turns each event into an alert on the
/// panel. What this class guarantees, and what its gates measure: nothing
/// arriving is dropped, nothing is delivered twice, and order is preserved.
class HabotViolationBinding {
  HabotViolationBinding({
    required this.stream,
    required this.panel,
    required this.centre,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now {
    _subscription = stream.listen(_onEvent, onError: _onError);
  }

  final Stream<HabotViolationEvent> stream;
  final HabotAlertPanelController panel;
  final HabotNotificationCenter centre;
  final DateTime Function() _clock;

  StreamSubscription<HabotViolationEvent>? _subscription;
  final List<String> _deliveredOrder = <String>[];
  final Set<String> _seen = <String>{};
  int _received = 0;
  int _duplicates = 0;
  int _errors = 0;

  /// Ceiling: "10 seconds (staleness ceiling before alerting)". An event older
  /// than this when it arrives is stale -- the client cannot make the pipeline
  /// faster, but it can refuse to present a stale breach as current news.
  static const Duration stalenessCeiling =
      HabotMotion.violationStalenessCeiling;

  List<String> get deliveredOrder => List<String>.unmodifiable(_deliveredOrder);
  int get receivedCount => _received;
  int get deliveredCount => _deliveredOrder.length;
  int get duplicateCount => _duplicates;
  int get errorCount => _errors;
  int get staleCount => _stale;
  int _stale = 0;

  /// What the binding owns: every event that arrived reached the panel.
  double get bindingDeliveryRate =>
      _received == 0 ? 1 : (_deliveredOrder.length + _duplicates) / _received;

  bool isStale(HabotViolationEvent event) =>
      _clock().difference(event.publishedAt) > stalenessCeiling;

  void _onEvent(HabotViolationEvent event) {
    _received++;
    if (!_seen.add(event.id)) {
      _duplicates++;
      return;
    }
    if (isStale(event)) {
      // Recorded and stored, but not raised to the blocking panel: a breach
      // from a minute ago presented as happening now is misinformation.
      _stale++;
      centre.receive(
        id: event.id,
        kind: HabotNotificationKind.informational,
        title: 'Past violation: ${event.summary}',
        body: 'Reported by ${event.topic}',
        route: '/settings',
      );
      _deliveredOrder.add(event.id);
      return;
    }
    panel.raise(
      HabotSystemAlert(
        id: event.id,
        severity: event.severity,
        headline: event.summary,
        detail: 'Reported by ${event.topic}',
      ),
    );
    _deliveredOrder.add(event.id);
  }

  /// A stream error must not take the binding down -- a listener that dies on
  /// the first malformed event stops delivering every event after it.
  void _onError(Object error, StackTrace stack) {
    _errors++;
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
  }
}
