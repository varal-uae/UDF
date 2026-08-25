/// AISS GATE -- Step 92 of 95
/// Global Reference ID:       GEN-02896
/// Atomic Steps Reference ID: GEN-02896-A01
/// Setup Step (Action):       "Build the mobile worker interface using
///                             MATERIAL 3 ELEVATED CARD component."
/// Metric: Mobile Usability Task Success Rate (%) -- Floor 80.0,
///         Optimal 95.0, Ceiling 100.0.
///
/// METRIC NOT PRODUCED, RECORDED. A task success rate is obtained by giving a
/// task to a sample of people and counting who completes it. No suite produces
/// it. The same metric was already recorded as not produced on GEN-03017
/// (Step 77), and no number is invented here either.
///
/// WHAT IS GATED is what the step names -- the M3 elevated card -- plus the
/// properties this design system already requires of any card. The worker card
/// is a VARIANT of the Step 29 chassis, exactly as the Step 52 KPI card is, so
/// it inherits the shadow-or-border rule and the corner radius rather than
/// drawing its own.
///
/// AND THE PRIORITY BADGE IS STEP 78's. `HabotAlertPriority` already maps
/// P1-P4 to the Step 28 status roles, so a P1 task and a P1 alert are the same
/// red, and the label is text as well as colour because colour alone fails
/// WCAG SC 1.4.1.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/aiss/aiss_evidence.dart';
import 'package:udf_setup/design_system/feedback/status_badge.dart';
import 'package:udf_setup/design_system/mto/byt_isolation.dart';
import 'package:udf_setup/design_system/mto/interaction_timer.dart';
import 'package:udf_setup/design_system/mto/task_queue.dart';
import 'package:udf_setup/design_system/mto/worker_task_card.dart';
import 'package:udf_setup/design_system/notifications/alert_priority.dart';
import 'package:udf_setup/design_system/surfaces/card_chassis.dart';
import 'package:udf_setup/design_system/theme/habot_theme.dart';
import 'package:udf_setup/design_system/tokens/spacing_tokens.dart';
import 'package:udf_setup/design_system/tokens/surface_tokens.dart';

import 'aiss_reporter.dart';

const HabotBoundingBox _box = HabotBoundingBox(
  left: 120,
  top: 240,
  width: 640,
  height: 180,
  sourceWidth: 2480,
  sourceHeight: 3508,
);

HabotMtoTask _task({
  HabotAlertPriority priority = HabotAlertPriority.p1,
  String? worker,
}) => HabotMtoTask(
  byt: HabotByt.fromDelivery(
    id: 'byt-1',
    box: _box,
    snippet: Uri.parse(
      'https://assets.habot.internal/crops/byt-1.png'
      '?crop=${HabotCropContract.signatureFor(_box)}',
    ),
    prompt: 'Read the invoice total',
    expectedFormat: 'digits and a decimal point',
  )!,
  priority: priority,
  queuedAt: DateTime(2026, 8, 18, 9),
  allocatedTo: worker,
  allocatedAt: worker == null ? null : DateTime(2026, 8, 18, 9, 2),
);

Future<void> _pumpCard(
  WidgetTester tester,
  HabotMtoTask task, {
  HabotInteractionTimer? timer,
  VoidCallback? onOpen,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: HabotTheme.light(),
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(HabotSpacing.md),
          child: HabotWorkerTaskCard(
            task: task,
            timer: timer,
            onOpen: onOpen ?? () {},
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  final List<AissGate> gates = <AissGate>[];

  group('GEN-02896-A01 :: the card', () {
    testWidgets('[GEN-02896-G1] the worker card is the Step 29 chassis in its '
        'elevated variant, not a fourth card', (WidgetTester tester) async {
      await _pumpCard(tester, _task());

      expect(find.byType(HabotCard), findsOneWidget);
      final HabotCard card = tester.widget<HabotCard>(find.byType(HabotCard));
      expect(card.variant, HabotCardVariant.elevated);
      expect(HabotWorkerTaskCard.variant, HabotCardVariant.elevated);
      expect(
        card.hasBorder,
        isFalse,
        reason:
            'GEN-01452 (Step 29): a card may have a shadow or a border, never '
            'both -- and this one is elevated',
      );
      expect(card.onPressed, isNotNull, reason: 'the whole card is the target');
      expect(tester.takeException(), isNull);

      gates.add(
        AissGate(
          id: 'GEN-02896-G1',
          requirementSource:
              'Setup Step (Action): "Build the mobile worker interface using '
              'MATERIAL 3 ELEVATED CARD component."',
          description:
              'The card is HabotCard in the elevated variant, so it inherits '
              'the Step 29 elevation ladder, corner radius and the rule that a '
              'surface never carries both a shadow and a border',
          passed: true,
          detail: 'elevation level ${card.elevation.name}',
        ),
      );
    });

    testWidgets('[GEN-02896-G2] priority is shown as colour AND text, in the '
        'Step 78 vocabulary', (WidgetTester tester) async {
      await _pumpCard(tester, _task());

      expect(find.text('P1'), findsOneWidget);
      final HabotWorkerTaskCard card = tester.widget<HabotWorkerTaskCard>(
        find.byType(HabotWorkerTaskCard),
      );
      expect(card.priorityRole, HabotStatusRole.error);
      expect(
        card.priorityRole,
        HabotAlertPriority.p1.role,
        reason: 'one priority vocabulary, shared with the alert panel',
      );
      expect(card.semanticLabel, contains('P1 priority task'));
      expect(card.semanticLabel, contains('Waiting'));
      expect(tester.takeException(), isNull);

      gates.add(
        const AissGate(
          id: 'GEN-02896-G2',
          requirementSource:
              'HC-BOG-0018 (Step 78) built the P1-P4 scale and bound it to the '
              'GEN-01275 (Step 28) status roles. WCAG SC 1.4.1: colour is '
              'never the only carrier.',
          description:
              'The card renders the priority label as text in the status role '
              'Step 78 assigns it, and announces both the priority and the '
              'state to a screen reader',
          passed: true,
        ),
      );
    });

    testWidgets('[GEN-02896-G3] elapsed time appears only when a task has '
        'actually been started', (WidgetTester tester) async {
      await _pumpCard(tester, _task());
      expect(
        find.byKey(HabotWorkerTaskCard.elapsedKey),
        findsNothing,
        reason: 'a task nobody has opened has no elapsed time to show',
      );

      final HabotInteractionTimer timer = HabotInteractionTimer(
        taskId: 'byt-1',
        clock: () => DateTime(2026, 8, 18, 9, 3),
      );
      addTearDown(timer.dispose);
      timer.start();
      await _pumpCard(
        tester,
        _task(worker: 'me'),
        timer: timer,
      );
      expect(find.byKey(HabotWorkerTaskCard.elapsedKey), findsOneWidget);
      expect(find.text('In progress'), findsOneWidget);
      expect(tester.takeException(), isNull);

      gates.add(
        const AissGate(
          id: 'GEN-02896-G3',
          requirementSource:
              'GEN-03866 (Step 93) measures worker execution duration; the '
              'card is where an operator sees it.',
          description:
              'The elapsed readout is present exactly when a timer exists for '
              'the task, and the card states whether the task is waiting or in '
              'progress rather than leaving it to be inferred',
          passed: true,
        ),
      );
    });
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-02896',
        atomicStepReferenceId: 'GEN-02896-A01',
        setupStepAction:
            'Build the mobile worker interface using Material 3 Elevated Card '
            'component.',
        implementationOrder: 92,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Build the mobile worker interface using Material 3 Elevated Card':
              'HabotWorkerTaskCard = HabotCard(variant: elevated) with the '
              'Step 78 priority badge and the Step 93 elapsed readout',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'METRIC NOT PRODUCED -- "Mobile Usability Task Success Rate" is '
              'a measure of people, obtained by watching them attempt tasks. '
              'The same metric was recorded as not produced on Step 77. No '
              'number invented. GENERATED ROW -- Setup Step and Description '
              'are identical; Expected Output and Completion Measures are '
              'template prose. Not gated.',
        },
        measurements: const <AissMeasurement>[
          AissMeasurement(
            metricName: 'Mobile Usability Task Success Rate (%)',
            observed:
                'NOT PRODUCED -- a usability-study measure obtained by giving '
                'a task to a sample of people and counting completions. What '
                'was measured instead: the card is the Step 29 chassis in its '
                'elevated variant, it carries the Step 78 priority as colour '
                'and text, and the elapsed readout appears only for a task '
                'that has been started.',
            floor: '80.0',
            optimal: '95.0',
            ceiling: '100.0',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/mto/worker_task_card.dart',
        ],
      ),
    );
  });
}
