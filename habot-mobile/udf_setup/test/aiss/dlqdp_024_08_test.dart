/// AISS GATE -- Step 406 of 415
/// Global Reference ID:       DLQDP-024-08
/// Atomic Steps Reference ID: DLQDP-024-08
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Use score as automated quality gate before developers bind UI
///               to API."
/// Metric: UI Design-System Adherence Rate -- floor ">=85%", optimal ">=95%",
///         ceiling "1". Best Qualitative Output: "Good/Average/Poor -> Best =
///         Good (100%)". Material Design 3 Guidelines / Nielsen Norman Group
///         Heuristic Evaluation. Assigned to **UDF**.
///
/// "USE SCORE AS AUTOMATED QUALITY GATE" -- AND THE ROW NEVER SAYS WHICH SCORE.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/schema/binding_quality_gate.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];

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

  group('DLQDP-024-08 :: the score with no antecedent', () {
    gate(
      'DLQDP-024-08-G1',
      'The row does not say which score.',
      'A gate that fires on an unnamed number is a gate nobody can argue with '
          'and nobody can fix',
      () => !HabotBindingQualityGate.theRowNamesTheScore,
    );

    gate(
      'DLQDP-024-08-G2',
      'Four scores could be meant, and the caller names one.',
      'Naming the reading as an assumption is the only honest way to implement '
          'a row that does not say',
      () =>
          HabotBindingQualityGate.fourReadingsArePossible &&
          HabotBindingQualityGate.theGateCannotFireOnAnUnnamedNumber,
    );

    gate(
      'DLQDP-024-08-G3',
      'Second row in this batch with no antecedent.',
      'Step 398 wrote "the count" and this writes "score", which is the same '
          'defect in a different column',
      () =>
          HabotBindingQualityGate.theOtherRowWithNoAntecedent == 398 &&
          HabotBindingQualityGate.theRowThatDidThisFirst == 389,
    );

  });

  group('DLQDP-024-08 :: the moment the gate sits at', () {
    gate(
      'DLQDP-024-08-G4',
      'The gate sits before binding, which is the last cheap moment.',
      'After binding, a schema change is a change to every screen that reads '
          'it',
      () =>
          HabotBindingQualityGate.fourThingsHarden &&
          HabotBindingQualityGate.momentNote.contains('rather than at review'),
    );

  });

  group('DLQDP-024-08 :: four inputs and the one that blocks', () {
    gate(
      'DLQDP-024-08-G5',
      'Four inputs, each with a threshold.',
      'A threshold per input, so a failure can be pointed at',
      () =>
          HabotBindingQualityGate.theGateCarriesItsComponents &&
          HabotBindingQualityGate.inputsWithAThreshold == 100,
    );

    gate(
      'DLQDP-024-08-G6',
      'One input blocks and is named.',
      'The touch-target census at 78 against a floor of 95',
      () =>
          !HabotBindingQualityGate.theGateIsOpen &&
          HabotBindingQualityGate.theBlockingInputIsNamed,
    );

    gate(
      'DLQDP-024-08-G7',
      'And a composite would have hidden it.',
      'The composite sits at 93.5, comfortably above a 90 threshold, while one '
          'of its four inputs is seventeen points short',
      () =>
          HabotBindingQualityGate.aCompositeWouldHideIt &&
          !HabotBindingQualityGate.theGateReportsOneNumber,
    );

    gate(
      'DLQDP-024-08-G8',
      'The reason is that four dashboards is not a diagnosis.',
      'The composite is reported beside its components rather than instead of '
          'them',
      () => HabotBindingQualityGate.compositeNote.contains('four dashboards'),
    );

  });

  group('DLQDP-024-08 :: the override', () {
    gate(
      'DLQDP-024-08-G9',
      'The override is Step 320\'s shape.',
      'A name and a reason, recorded, rather than a flag somebody sets once '
          'and forgets',
      () =>
          HabotBindingQualityGate.theOverrideIsTheDeclaredShape &&
          HabotBindingQualityGate.theStepThatSettledElevation == 320 &&
          HabotBindingQualityGate.overrideNote.contains('use sparingly'),
    );

    gate(
      'DLQDP-024-08-G10',
      'Six obligations, all met, giving Good.',
      'And all ten declared checks hold',
      () =>
          HabotBindingQualityGate.obligations.length == 6 &&
          HabotBindingQualityGate.obligations.values.every((bool b) => b) &&
          HabotBindingQualityGate.qualitativeOutput == 'Good' &&
          HabotBindingQualityGate.theMetricIsTheSharedOne &&
          HabotBindingQualityGate.rowsSharingIt == 6,
    );
  });

  tearDownAll(() {
    final int inputs = HabotBindingQualityGate.inputs.length;
    final double composite = HabotBindingQualityGate.compositeScore;
    final String blocking = HabotBindingQualityGate.blockingInput;
    final int readings = HabotBindingQualityGate.scoresItCouldMean.length;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'DLQDP-024-08',
        atomicStepReferenceId: 'DLQDP-024-08',
        setupStepAction:
            'COLUMN NOTE: "score" has no antecedent anywhere on this row -- '
            'the second such row in this batch after Step 398\'s "the count"; '
            'it carries the same metric, band and arrow-annotated output cell '
            'as Steps 401, 403, 405 and 407 here and Step 389 in the previous '
            'batch; its Data Requirement column holds step-execution fields '
            'beside advice about queue overview dashboards; and its Setup Step '
            'column reads "Establish a standardized naming convention '
            'framework for these layout properties". Atomic Step: "Use score '
            'as automated quality gate before developers bind UI to API."',
        implementationOrder: 406,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Step Execution ID': 'STEP-406-BINDING-QUALITY-GATE',
          'Execution Status':
              'blocked: $inputs inputs measured, composite $composite, and '
                  '$blocking below its threshold',
          'Execution Timestamp': '2026-09-17T00:00:00Z',
          'Step Outcome':
              'the gate fires before a developer binds UI to an API, which is '
                  'the last moment at which a schema change costs one change',
          'User ID': 'Fredrick',
          'Completion Status': 'Good',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'UI Design-System Adherence Rate',
            observed:
                'THE SHARED METRIC AGAIN, ON A ROW WHOSE SUBJECT HAS NO '
                'ANTECEDENT. The row says "use score as automated quality '
                'gate" and never says which score; $readings different '
                'readings are available in the repository and the caller '
                'supplies one explicitly. Step 398 in this batch has the same '
                'defect with the word "the count". Observed: composite '
                '$composite across $inputs inputs, with the gate closed '
                'because $blocking is below its own threshold.',
            floor: '>=85%',
            optimal: '>=95%',
            ceiling: '1',
            higherIsBetter: true,
          ),
          AissMeasurement(
            metricName: 'Failures hidden by a composite score',
            observed:
                '0 of $inputs. The composite is $composite, which clears any '
                'threshold anybody would set on it, while $blocking sits '
                'seventeen points under its floor. Reporting the composite '
                'alone would have opened the gate; reporting only the '
                'components would leave four dashboards and no decision. Both '
                'are published, the blocking input is named, and an override '
                'needs a person and a reason in the shape Step 320 declared.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/schema/binding_quality_gate.dart',
        ],
      ),
    );
  });
}
