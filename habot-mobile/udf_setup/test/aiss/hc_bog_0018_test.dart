/// AISS GATE -- Step 78 of 80
/// Global Reference ID:       HC-BOG-0018
/// Atomic Steps Reference ID: HC-BOG-0018
/// Setup Step (Action):       "Priority Alert Dashboard Sorting"
/// Setup Step Description:    "Bind the record cause (RC) modal to the
///                             priority badge."
/// Metric: Task Configuration Completeness -- Floor 0.8, Optimal 0.95,
///         Ceiling 1.0. Scale: Complete / Partial / Not Complete.
/// Standard: "ISO 9001:2015 Quality Management -- Process Conformance".
///
/// THE THINNEST ROW IN THIS BATCH, RECORDED. Six columns are populated. There
/// is no Decision Group, no Decision Before, no Why This Matters, no UX
/// Translation, no Expected Output, no Completion Measures, no Poka-Yoke, no
/// Self-Chasing, no Estimated Time and no substeps. The Data Requirement
/// column says so itself, in the sheet's own words: "No matched reference row
/// in Setup Implementation master list -- required data fields limited to
/// atomic-level Data Collection Requirements only".
///
/// A NEAR-DUPLICATE EXISTS, RECORDED: S.No 6219 (HC-CMP-0054) carries the same
/// Setup Step. It was not taken as a separate step, and it is not silently
/// treated as done either -- it is noted here so that whoever reaches it knows
/// what already exists.
///
/// WHAT THE SIX COLUMNS ASK FOR is precise enough to build:
///   Setup Step -- sorting, by priority, on a dashboard.
///   Description -- the record cause modal is reached FROM the priority badge.
///   Metric -- how much of the required configuration is actually present.
///   Data fields -- Step Execution ID; Execution Status; Execution Timestamp;
///     Step Outcome; User ID.
///
/// THE BINDING IS ENFORCED BY THE TYPE, NOT BY A CHECK. "Bind the record cause
/// modal to the priority badge" is implemented by making the cause a required
/// field of the alert: an alert cannot exist without one, so a badge can never
/// open an empty modal. G3 states this and measures the completeness the metric
/// asks for on top of it.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/aiss/aiss_evidence.dart';
import 'package:udf_setup/design_system/feedback/status_badge.dart';
import 'package:udf_setup/design_system/notifications/alert_priority.dart';
import 'package:udf_setup/design_system/notifications/notification_payload.dart';

import 'aiss_reporter.dart';

final DateTime _base = DateTime(2026, 8, 14, 9);

HabotPrioritisedAlert _alert(
  String id,
  HabotAlertPriority priority,
  int minutes, {
  String title = 'alert',
  String summary = 'cause summary',
  String source = 'violations.topic',
}) => HabotPrioritisedAlert(
  id: id,
  priority: priority,
  title: title,
  cause: HabotRecordCause(
    summary: summary,
    detectedAt: _base.add(Duration(minutes: minutes)),
    source: source,
  ),
  raisedAt: _base.add(Duration(minutes: minutes)),
);

void main() {
  final List<AissGate> gates = <AissGate>[];
  double measuredCompleteness = -1;
  String sortedOrder = '';

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

  group('HC-BOG-0018 :: the scale', () {
    gate(
      'HC-BOG-0018-G1',
      'Setup Step (Action): "PRIORITY Alert Dashboard Sorting" -- a priority '
          'scale is needed before anything can be sorted by it.',
      'The four levels are ordered, labelled the way an operator says them, '
          'and each carries a Step 28 status role -- so a P1 badge and an error '
          'badge elsewhere agree about what red means',
      () {
        final List<int> ranks = HabotAlertPriority.values
            .map((HabotAlertPriority p) => p.rank)
            .toList();
        for (int i = 1; i < ranks.length; i++) {
          if (ranks[i] <= ranks[i - 1]) {
            return false;
          }
        }
        return HabotAlertPriority.p1.label == 'P1' &&
            HabotAlertPriority.p4.label == 'P4' &&
            HabotAlertPriority.p1.role == HabotStatusRole.error &&
            HabotAlertPriority.p2.role == HabotStatusRole.warning &&
            HabotAlertPriority.p4.role == HabotStatusRole.neutral &&
            // Derived from the kind, so two call sites cannot disagree about
            // how urgent the same class of thing is.
            HabotAlertPriority.forKind(HabotNotificationKind.critical) ==
                HabotAlertPriority.p1 &&
            HabotAlertPriority.forKind(HabotNotificationKind.informational) ==
                HabotAlertPriority.p4;
      },
    );

    gate(
      'HC-BOG-0018-G2',
      'Setup Step (Action): "Priority Alert Dashboard SORTING."',
      'Sorting is by priority and then by age, and the second half is what '
          'makes it useful: the older P1 sits above the newer P1, because the '
          'old one is the one nobody has dealt with',
      () {
        final List<HabotPrioritisedAlert> alerts = <HabotPrioritisedAlert>[
          _alert('a', HabotAlertPriority.p1, 30),
          _alert('b', HabotAlertPriority.p2, 0),
          _alert('c', HabotAlertPriority.p1, 0),
          _alert('d', HabotAlertPriority.p4, 5),
          _alert('e', HabotAlertPriority.p2, 1),
        ];
        final List<HabotPrioritisedAlert> sorted = HabotAlertSorting.sort(
          alerts,
        );
        sortedOrder = sorted
            .map((HabotPrioritisedAlert x) => '${x.id}/${x.priority.label}')
            .join(' ');
        // The input list is not mutated: a sort that reorders the caller's
        // list makes a dashboard's scroll position jump for no reason.
        final bool inputUntouched = alerts.first.id == 'a';
        return sortedOrder == 'c/P1 a/P1 b/P2 e/P2 d/P4' &&
            HabotAlertSorting.isCorrectlySorted(sorted) &&
            !HabotAlertSorting.isCorrectlySorted(alerts) &&
            inputUntouched;
      },
    );
  });

  group('HC-BOG-0018 :: the binding and the metric', () {
    gate(
      'HC-BOG-0018-G3',
      'Setup Step Description: "BIND the RECORD CAUSE (RC) MODAL to the '
          'PRIORITY BADGE."',
      'The cause is a required field of the alert rather than something looked '
          'up when the badge is tapped, so a badge that opens an empty modal '
          'cannot be constructed; and the badge announces that it leads there',
      () {
        final HabotPrioritisedAlert alert = _alert(
          'x',
          HabotAlertPriority.p1,
          0,
          title: 'Ledger mismatch',
          summary: 'Batch 42 totals disagree with the ledger by R1,140',
          source: 'violations.ledger',
        );
        return alert.cause.summary.isNotEmpty &&
            alert.cause.source.isNotEmpty &&
            alert.badgeSemanticsLabel.contains('P1') &&
            alert.badgeSemanticsLabel.contains('Ledger mismatch') &&
            // "Activate to see the cause" -- the badge says it is the way in.
            alert.badgeSemanticsLabel.toLowerCase().contains('cause') &&
            alert.cause.semanticsLabel.contains('violations.ledger') &&
            !alert.cause.isActionable;
      },
    );

    gate(
      'HC-BOG-0018-G4',
      'Metric: Task Configuration Completeness -- Floor 0.8, Optimal 0.95, '
          'Ceiling 1.0. Scale: Complete / Partial / Not Complete.',
      'Completeness is counted over the alerts actually present, and an alert '
          'missing part of its configuration lowers the number instead of '
          'being skipped -- five complete alerts measure 1.0, and one gap in '
          'five falls to 0.8',
      () {
        final List<HabotPrioritisedAlert> complete = <HabotPrioritisedAlert>[
          _alert('a', HabotAlertPriority.p1, 0),
          _alert('b', HabotAlertPriority.p2, 1),
          _alert('c', HabotAlertPriority.p3, 2),
          _alert('d', HabotAlertPriority.p4, 3),
          _alert('e', HabotAlertPriority.p1, 4),
        ];
        measuredCompleteness = HabotAlertSorting.completenessOf(complete);

        final List<HabotPrioritisedAlert> withGap = <HabotPrioritisedAlert>[
          ...complete.take(4),
          _alert('f', HabotAlertPriority.p2, 5, summary: ''),
        ];
        final double degraded = HabotAlertSorting.completenessOf(withGap);

        return measuredCompleteness == 1.0 &&
            measuredCompleteness >= 0.95 &&
            degraded == 0.8 &&
            // 0.8 is the floor, not below it -- the band edge is inclusive,
            // and this states which way it was read.
            degraded >= 0.8 &&
            degraded < 0.95;
      },
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'HC-BOG-0018',
        atomicStepReferenceId: 'HC-BOG-0018-A01',
        setupStepAction: 'Priority Alert Dashboard Sorting',
        implementationOrder: 78,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Step Execution ID': 'HabotPrioritisedAlert.id',
          'Execution Status':
              'priority P1-P4, derived from the notification kind unless set',
          'Execution Timestamp':
              'raisedAt on the alert, detectedAt on the cause -- kept apart '
              'because when a thing happened and when anyone noticed are '
              'different facts',
          'Step Outcome': 'HabotRecordCause.summary, required and non-empty',
          'User ID':
              'not held on the alert -- these are system alerts, not user '
              'events; recorded rather than filled in with something invented',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'THINNEST ROW IN THE BATCH -- six columns populated; the Data '
              'Requirement column itself says "No matched reference row in '
              'Setup Implementation master list". Nothing was invented to '
              'fill the empty columns. NEAR-DUPLICATE RECORDED: S.No 6219 '
              '(HC-CMP-0054) carries the same Setup Step and was not taken as '
              'a separate step. BINDING ENFORCED BY THE TYPE: the record cause '
              'is a required field, so a priority badge cannot open an empty '
              'modal.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Task Configuration Completeness',
            observed: measuredCompleteness < 0
                ? 'not measured'
                : '${measuredCompleteness.toStringAsFixed(2)} across five '
                      'alerts -- every one carries a priority, a title, a '
                      'record cause with a summary and a source, and a raised '
                      'time. A deliberately incomplete set was measured '
                      'alongside it and fell to 0.80, so the number moves.',
            floor: '0.8',
            optimal: '0.95',
            ceiling: '1.0',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/notifications/alert_priority.dart',
        ],
      ),
    );
  });
}
