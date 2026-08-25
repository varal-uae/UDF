/// AISS GATE -- Step 91 of 95
/// Global Reference ID:       GEN-03580
/// Atomic Steps Reference ID: GEN-03580-A01
/// Setup Step (Action):       "Present the human worker with a SINGLE MASKED
///                             INPUT FIELD and CROPPED VISUAL EVIDENCE."
/// Metric: UI Screen Visual Focus Efficiency -- Floor 1.0, Optimal 1.0,
///         Ceiling 1.0.
///
/// The payoff of Steps 81-90: the Zero-Context UI constraint rendered as an
/// actual screen. The metric is a ratio -- task elements over all interactive
/// elements -- and a floor, optimal and ceiling all at 1.0 means the sheet is
/// asking for a screen where nothing is interactive except the task. That is
/// the same requirement GEN-00610 states as a peripheral count of zero, from
/// the other direction, and both are measured on the rendered tree.
///
/// "MASKED", INTERPRETED AND RECORDED. This app already has input masking:
/// CSIVW-001 (Step 15) built keystroke-level masks and IS12-CSIVW-011 (Step
/// 16) built the 13 Critical Data Element rules that carry them. So the masked
/// input is a `ValidatedInputField` bound to the CDE the task declares, using
/// the sheet's own vocabulary rather than inventing a second meaning for the
/// word. G4 gates that reading; if you want an obscured-character field
/// instead, that is a product decision and this is where it is recorded.
///
/// A GENERATED ROW OTHERWISE: Setup Step and Description are identical, the
/// substeps are the generic four, and Completion Measures is CI/CD tracking.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/aiss/aiss_evidence.dart';
import 'package:udf_setup/design_system/forms/field_validation.dart';
import 'package:udf_setup/design_system/forms/validated_input_field.dart';
import 'package:udf_setup/design_system/interaction/atomic_button.dart';
import 'package:udf_setup/design_system/mto/byt_isolation.dart';
import 'package:udf_setup/design_system/mto/isolated_viewport.dart';
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

Future<void> _pumpScreen(
  WidgetTester tester, {
  ValueChanged<String>? onSubmit,
}) async {
  tester.view.physicalSize = const Size(400, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: HabotTheme.light(),
      home: HabotTaskScreen(
        byt: _task(),
        cde: HabotCde.currencyAmount,
        imageBuilder: _stubSnippet,
        onSubmit: onSubmit ?? (String _) {},
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  final List<AissGate> gates = <AissGate>[];
  double measuredEfficiency = -1;

  setUp(HabotTaskLayoutRegistry.reset);

  group('GEN-03580-A01 :: the focused screen', () {
    testWidgets('[GEN-03580-G1] exactly one input and one submit, beside the '
        'cropped evidence', (WidgetTester tester) async {
      await _pumpScreen(tester);

      expect(
        find.byType(ValidatedInputField),
        findsNWidgets(HabotFocusAudit.expectedInputCount),
        reason: '"a SINGLE masked input field"',
      );
      expect(
        find.byType(AtomicButton),
        findsNWidgets(HabotFocusAudit.expectedSubmitCount),
      );
      expect(find.byType(HabotIsolatedViewport), findsOneWidget);
      expect(find.byKey(HabotTaskAnswerPane.promptKey), findsOneWidget);
      expect(tester.takeException(), isNull);

      gates.add(
        const AissGate(
          id: 'GEN-03580-G1',
          requirementSource:
              'Setup Step (Action): "Present the human worker with a SINGLE '
              'masked input field and CROPPED VISUAL EVIDENCE."',
          description:
              'The rendered screen carries exactly one input, exactly one '
              'submit and one isolated viewport -- the whole of the task and '
              'nothing beside it',
          passed: true,
        ),
      );
    });

    testWidgets('[GEN-03580-G2] focus efficiency measured on the rendered tree',
        (WidgetTester tester) async {
      await _pumpScreen(tester);

      int taskElements = 0;
      int distractions = 0;
      for (final Widget widget in tester.allWidgets) {
        final String name = widget.runtimeType.toString();
        if (HabotFocusAudit.isTaskElement(name)) {
          taskElements++;
        } else if (HabotFocusAudit.isDistraction(name)) {
          distractions++;
        }
      }
      measuredEfficiency = HabotFocusAudit.efficiency(
        taskElements: taskElements,
        distractions: distractions,
      );
      expect(taskElements, 3, reason: 'viewport, input, submit');
      expect(distractions, 0);
      expect(measuredEfficiency, HabotFocusAudit.efficiencyFloor);
      // And the ratio can fall: one distraction in the same denominator.
      expect(
        HabotFocusAudit.efficiency(taskElements: 3, distractions: 1),
        closeTo(0.75, 0.0001),
      );
      expect(tester.takeException(), isNull);

      gates.add(
        AissGate(
          id: 'GEN-03580-G2',
          requirementSource:
              'Metric: UI Screen Visual Focus Efficiency -- Floor, Optimal and '
              'Ceiling all 1.0.',
          description:
              'Task elements over all interactive elements, counted on the '
              'rendered tree: the screen scores 1.0, and a single added '
              'distraction would take it to 0.75',
          passed: true,
          detail:
              '$taskElements task elements, $distractions distractions -> '
              '${measuredEfficiency.toStringAsFixed(2)}',
        ),
      );
    });

    testWidgets('[GEN-03580-G3] the submit is closed until the answer '
        'validates, and it is the Step 18 gate that decides', (
      WidgetTester tester,
    ) async {
      final List<String> submitted = <String>[];
      await _pumpScreen(tester, onSubmit: submitted.add);

      AtomicButton button() =>
          tester.widget<AtomicButton>(find.byType(AtomicButton));
      expect(
        button().onPressed,
        isNull,
        reason: 'nothing typed yet -- an empty answer must not be sendable',
      );

      await tester.enterText(find.byType(TextField), '1240.50');
      await tester.pumpAndSettle();
      expect(button().onPressed, isNotNull);

      await tester.tap(find.byKey(HabotTaskAnswerPane.submitKey));
      await tester.pumpAndSettle();
      expect(submitted, <String>['1240.50']);
      expect(tester.takeException(), isNull);

      gates.add(
        const AissGate(
          id: 'GEN-03580-G3',
          requirementSource:
              'BPTR-0160 / IS12-CSIVW-011 (Steps 16-18): the form gate is the '
              'single authority on whether a value may be submitted.',
          description:
              'The submit control is disabled until the CDE rule passes and '
              'then sends exactly what was typed -- the task screen adds no '
              'second rule about when an answer is acceptable',
          passed: true,
        ),
      );
    });

    testWidgets('[GEN-03580-G4] the "masked" input is the Step 15-16 '
        'validated field bound to a CDE, not a new text field', (
      WidgetTester tester,
    ) async {
      await _pumpScreen(tester);

      final ValidatedInputField field = tester.widget<ValidatedInputField>(
        find.byType(ValidatedInputField),
      );
      expect(field.cde, HabotCde.currencyAmount);
      expect(field.fieldName, HabotTaskAnswerPane.fieldName);
      expect(field.gate, isNotNull);
      // The label tells the worker the shape of the answer, which is what the
      // mask enforces.
      expect(field.label, contains('digits'));
      expect(tester.takeException(), isNull);

      gates.add(
        const AissGate(
          id: 'GEN-03580-G4',
          requirementSource:
              'Setup Step (Action): "a single MASKED input field", read with '
              'CSIVW-001 (Step 15) and IS12-CSIVW-011 (Step 16), which built '
              'input masking and the 13 Critical Data Element rules.',
          description:
              'The input is a ValidatedInputField carrying the task\'s own '
              'CDE, so the mask, the keyboard and the validation message come '
              'from the existing rule set. INTERPRETATION RECORDED: "masked" '
              'is read as the sheet\'s own input masking, not as obscured '
              'characters',
          passed: true,
        ),
      );
    });
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-03580',
        atomicStepReferenceId: 'GEN-03580-A01',
        setupStepAction:
            'Present the human worker with a single masked input field and '
            'cropped visual evidence.',
        implementationOrder: 91,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Present the human worker with a single masked input field':
              'one ValidatedInputField bound to the task\'s CDE, one submit '
              'governed by the Step 18 form gate, one isolated viewport',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'GENERATED ROW -- Setup Step and Description are identical; the '
              'substeps, Expected Output and Completion Measures are template '
              'prose. Not gated. The metric fits and is measurable as a ratio. '
              'INTERPRETATION RECORDED: "masked" is read as the input masking '
              'this app already has (Steps 15-16), not as obscured characters; '
              'the alternative reading is a product decision and is stated in '
              'the gate file so it can be argued with.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'UI Screen Visual Focus Efficiency',
            observed: measuredEfficiency < 0
                ? 'not measured'
                : '${measuredEfficiency.toStringAsFixed(2)} -- 3 task elements '
                      '(viewport, input, submit) and 0 distractions on the '
                      'rendered tree at 400x900. One added distraction would '
                      'take the same ratio to 0.75, so the measure moves.',
            floor: '1.0',
            optimal: '1.0',
            ceiling: '1.0',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/mto/task_screen.dart',
        ],
      ),
    );
  });
}
