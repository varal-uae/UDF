/// AISS GATE -- Step 89 of 95
/// Global Reference ID:       GEN-04042
/// Atomic Steps Reference ID: GEN-04042-A01
/// Setup Step (Action):       "Configure the layout engine to VALIDATE that
///                             incoming task screens WRAP CONTENT INSIDE the
///                             Master Split-Screen component."
/// Metric: Layout Wrapper Validation Rate -- Floor 1.0, Optimal 1.0,
///         Ceiling 1.0.
///
/// THIS IS RCGLA-018 FOR TASK SCREENS. Step 8 established that every screen
/// extends the master layout wrapper, and the poka-yoke guard has a
/// ROGUE_SCAFFOLD rule enforcing it. This row asks for the same discipline one
/// level down, so it is enforced the same way: content that is not inside the
/// chassis cannot render as though it were.
///
/// WHAT "VALIDATE" MEANS HERE. Not a linter message after the fact -- the
/// content itself looks for the chassis above it. When there is none it
/// records a violation, the validation rate drops below 1.0, and the worker
/// sees a notice instead of a task. A task rendered outside the isolation
/// chassis has not been checked against Steps 81-88, and showing it anyway
/// would be the failure this rate exists to catch.
///
/// A GENERATED ROW, RECORDED: Setup Step and Description are identical, the
/// substeps are the generic four, Expected Output is the template
/// restatement, and Completion Measures is CI/CD tracking. None gated.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/aiss/aiss_evidence.dart';
import 'package:udf_setup/design_system/forms/field_validation.dart';
import 'package:udf_setup/design_system/mto/byt_isolation.dart';
import 'package:udf_setup/design_system/mto/task_chassis.dart';
import 'package:udf_setup/design_system/mto/task_screen.dart';
import 'package:udf_setup/design_system/theme/habot_theme.dart';

import 'aiss_reporter.dart';

const HabotBoundingBox _box = HabotBoundingBox(
  left: 120,
  top: 240,
  width: 640,
  height: 180,
  sourceWidth: 2480,
  sourceHeight: 3508,
);

HabotByt _task() => HabotByt.fromDelivery(
  id: 'byt-1',
  box: _box,
  snippet: Uri.parse(
    'https://assets.habot.internal/crops/byt-1.png'
    '?crop=${HabotCropContract.signatureFor(_box)}',
  ),
  prompt: 'Read the invoice total',
  expectedFormat: 'digits and a decimal point',
)!;

Widget _stubSnippet(BuildContext context, HabotByt byt) =>
    SizedBox(width: byt.box.width, height: byt.box.height);

void main() {
  final List<AissGate> gates = <AissGate>[];
  double measuredRate = -1;

  setUp(HabotTaskLayoutRegistry.reset);

  group('GEN-04042-A01 :: the wrapper validation', () {
    testWidgets('[GEN-04042-G1] a task screen inside the chassis validates, '
        'and the rate is 1.0', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: HabotTheme.light(),
          home: HabotTaskScreen(
            byt: _task(),
            cde: HabotCde.currencyAmount,
            imageBuilder: _stubSnippet,
            onSubmit: (String _) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      measuredRate = HabotTaskLayoutRegistry.validationRate;
      expect(HabotTaskLayoutRegistry.wrapped, isNotEmpty);
      expect(HabotTaskLayoutRegistry.unwrapped, isEmpty);
      expect(measuredRate, 1.0);
      expect(find.byKey(HabotTaskContent.unwrappedKey), findsNothing);
      expect(find.byKey(HabotTaskAnswerPane.inputKey), findsOneWidget);
      expect(tester.takeException(), isNull);

      gates.add(
        AissGate(
          id: 'GEN-04042-G1',
          requirementSource:
              'Setup Step (Action): "VALIDATE that incoming task screens WRAP '
              'CONTENT INSIDE the Master Split-Screen component." Metric: '
              'Layout Wrapper Validation Rate, floor and optimal 1.0.',
          description:
              'A task screen built through the chassis registers as wrapped '
              'and renders its task, giving a validation rate of 1.0',
          passed: true,
          detail:
              '${HabotTaskLayoutRegistry.wrapped.length} wrapped, '
              '${HabotTaskLayoutRegistry.unwrapped.length} unwrapped',
        ),
      );
    });

    testWidgets('[GEN-04042-G2] content outside the chassis is refused, '
        'recorded, and shown as a notice rather than as a task', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: HabotTheme.light(),
          home: const Scaffold(
            body: HabotTaskContent(
              screenName: 'mto.rogue',
              child: Text('a task rendered outside the isolation chassis'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(HabotTaskContent.unwrappedKey), findsOneWidget);
      expect(
        find.text('a task rendered outside the isolation chassis'),
        findsNothing,
        reason:
            'the unwrapped content must not render -- it has not been checked '
            'against Steps 81-88',
      );
      expect(HabotTaskLayoutRegistry.unwrapped, contains('mto.rogue'));
      expect(
        HabotTaskLayoutRegistry.validationRate,
        lessThan(1.0),
        reason: 'a rate that cannot drop is not a measurement',
      );
      expect(tester.takeException(), isNull);

      gates.add(
        AissGate(
          id: 'GEN-04042-G2',
          requirementSource:
              'RCGLA-018 (Step 8) Poka-Yoke: "Code linters block views that do '
              'not extend the master layout wrapper" -- the same rule, one '
              'level down.',
          description:
              'Task content with no chassis above it records a violation, '
              'drops the validation rate below 1.0, and renders a visible '
              'notice instead of the task',
          passed: true,
          detail:
              'rate with one violation: '
              '${HabotTaskLayoutRegistry.validationRate.toStringAsFixed(2)}',
        ),
      );
    });

    test('[GEN-04042-G3] the ledger counts both outcomes and can be reset '
        'between runs', () {
      HabotTaskLayoutRegistry.reset();
      expect(HabotTaskLayoutRegistry.checkedCount, 0);
      expect(
        HabotTaskLayoutRegistry.validationRate,
        1.0,
        reason: 'no screens checked is not a failure',
      );
      HabotTaskLayoutRegistry.recordWrapped('a');
      HabotTaskLayoutRegistry.recordWrapped('b');
      HabotTaskLayoutRegistry.recordUnwrapped('c');
      expect(HabotTaskLayoutRegistry.checkedCount, 3);
      expect(
        HabotTaskLayoutRegistry.validationRate,
        closeTo(2 / 3, 0.0001),
        reason: 'two of three wrapped',
      );

      gates.add(
        const AissGate(
          id: 'GEN-04042-G3',
          requirementSource:
              'Metric: Layout Wrapper Validation Rate -- a rate needs a '
              'denominator that includes the failures.',
          description:
              'The ledger counts wrapped and unwrapped screens separately, '
              'reports 1.0 when nothing has been checked, and computes the '
              'rate over both',
          passed: true,
        ),
      );
    });
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-04042',
        atomicStepReferenceId: 'GEN-04042-A01',
        setupStepAction:
            'Configure the layout engine to validate that incoming task '
            'screens wrap content inside the Master Split-Screen component.',
        implementationOrder: 89,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Configure the layout engine to validate task screen wrapping':
              'HabotTaskContent looks for the chassis above it; there is no '
              'flag a caller can set to claim wrapping it does not have.',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'GENERATED ROW -- Setup Step and Description are identical; the '
              'substeps, Expected Output and Completion Measures are template '
              'prose. Not gated. The metric fits and is used literally. '
              'RESTATEMENT RECORDED: this is RCGLA-018 (Step 8) applied to '
              'task screens, so it extends that discipline rather than adding '
              'a parallel guard.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Layout Wrapper Validation Rate',
            observed: measuredRate < 0
                ? 'not measured'
                : '${measuredRate.toStringAsFixed(2)} on a real task screen '
                      'rendered through the chassis. A screen rendered outside '
                      'it was refused, recorded, and dropped the rate below '
                      '1.0 -- so the number can move.',
            floor: '1.0',
            optimal: '1.0',
            ceiling: '1.0',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/mto/task_chassis.dart',
        ],
      ),
    );
  });
}
