/// AISS GATE -- Step 407 of 415
/// Global Reference ID:       ETMDI-008-10
/// Atomic Steps Reference ID: ETMDI-008-10
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Display intermediate calculated values on mobile screen for
///               transparency."
/// Metric: UI Design-System Adherence Rate -- floor ">=85%", optimal ">=95%",
///         ceiling "1". Best Qualitative Output: "Good/Average/Poor -> Best =
///         Good (100%)". Material Design 3 Guidelines / Nielsen Norman Group
///         Heuristic Evaluation. Assigned to **UDF**.
///
/// SHOW THE WORKING -- AND THE ROW ASKS FOR COLOUR ALONE TO CARRY IT, WHICH IS
/// REFUSED.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/disclosure/intermediate_values.dart';

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

  group('ETMDI-008-10 :: five steps that sum', () {
    gate(
      'ETMDI-008-10-G1',
      'Five steps, all checkable.',
      'A disclosure whose steps cannot be re-added is a longer version of the '
          'same unexplained number',
      () =>
          HabotIntermediateValues.steps.length == 5 &&
          HabotIntermediateValues.everyStepIsCheckable &&
          HabotIntermediateValues.checkableShare == 100,
    );

    gate(
      'ETMDI-008-10-G2',
      'Two of them are deductions.',
      'Deductions are the lines people dispute, so they are shown rather than '
          'netted off',
      () => HabotIntermediateValues.twoStepsAreDeductions,
    );

    gate(
      'ETMDI-008-10-G3',
      'The steps sum to the headline in fils.',
      'Computed in integer fils, because a disclosure that rounds each line '
          'separately stops summing',
      () =>
          HabotIntermediateValues.theStepsSumToTheHeadline &&
          HabotIntermediateValues.headlineFils == 174100,
    );

  });

  group('ETMDI-008-10 :: every line names its rule', () {
    gate(
      'ETMDI-008-10-G4',
      'And a disclosure that does not sum is worse than none.',
      'It converts a question about the total into a question about arithmetic',
      () => HabotIntermediateValues.sumNote.contains('about the wrong thing'),
    );

    gate(
      'ETMDI-008-10-G5',
      'Every line names its rule.',
      'The overtime multiplier, the deduction basis, the rounding rule',
      () =>
          HabotIntermediateValues.everyLineNamesItsRule &&
          HabotIntermediateValues.theBareNumberIsRefused,
    );

  });

  group('ETMDI-008-10 :: one tap away', () {
    gate(
      'ETMDI-008-10-G6',
      'Because the rule is what people dispute.',
      'Nobody argues with a number, they argue with the rule that produced it',
      () =>
          HabotIntermediateValues.ruleNote
              .contains('what the hours were worth'),
    );

    gate(
      'ETMDI-008-10-G7',
      'The working is one tap away, in Step 21\'s sheet.',
      'Rather than a second disclosure surface invented here',
      () =>
          HabotIntermediateValues.theDisclosureIsOneTapFromTheNumber &&
          HabotIntermediateValues.theStepThatBuiltTheSheet == 21 &&
          !HabotIntermediateValues.aNewPatternWasInvented,
    );

  });

  group('ETMDI-008-10 :: colour alone is refused', () {
    gate(
      'ETMDI-008-10-G8',
      'The row asks for colour alone and it is refused.',
      'Colour is not available to a colour-blind user, a monochrome display or '
          'a screen reader',
      () =>
          HabotIntermediateValues.theInstructionIsRefused &&
          HabotIntermediateValues.threeCarriers,
    );

    gate(
      'ETMDI-008-10-G9',
      'The carriers are Step 189\'s, restated at Step 369.',
      'Colour, icon and text together, which is the rule the track already '
          'carries',
      () =>
          HabotIntermediateValues.theStepThatDeclaredTheCarriers == 189 &&
          HabotIntermediateValues.theStepThatRestatedIt == 369 &&
          HabotIntermediateValues.colourNote.contains('one man in twelve'),
    );

    gate(
      'ETMDI-008-10-G10',
      'Five obligations, all met, giving Good.',
      'And all ten declared checks hold',
      () =>
          HabotIntermediateValues.obligations.length == 5 &&
          HabotIntermediateValues.obligations.values.every((bool b) => b) &&
          HabotIntermediateValues.qualitativeOutput == 'Good' &&
          HabotIntermediateValues.theMetricIsTheSharedOne &&
          HabotIntermediateValues.thisIsTheLastOfSix &&
          HabotIntermediateValues.rowsSharingIt == 6,
    );
  });

  tearDownAll(() {
    final int steps = HabotIntermediateValues.steps.length;
    final int deductions = HabotIntermediateValues.deductions;
    final int fils = HabotIntermediateValues.headlineFils;
    final int carriers = HabotIntermediateValues.carriers.length;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'ETMDI-008-10',
        atomicStepReferenceId: 'ETMDI-008-10',
        setupStepAction:
            'COLUMN NOTE: the Data Requirement column on this row asks for '
            '"Green colour coding if 0, Red if not", which is colour as the '
            'only carrier and red against green -- SC 1.4.1 twice; the row '
            'carries the same metric, band and arrow-annotated output cell as '
            'Steps 401, 403, 405 and 406 here and Step 389 before them, the '
            'sixth and last of the set; and its Setup Step column reads '
            '"Confirm high-confidence outputs permit frictionless one-click '
            'user approvals". Atomic Step: "Display intermediate calculated '
            'values on mobile screen for transparency."',
        implementationOrder: 407,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Mobile Platform': 'Android and iOS, one Flutter codebase',
          'OS Version': 'Android 13+ / iOS 16+',
          'Device Type':
              'handset; the working is one tap from the headline rather than '
                  'on a second screen',
          'Screen Dimensions':
              '$steps calculation lines always visible above the fold, summing '
                  'to $fils fils',
          'Mobile Configuration':
              '$carriers carriers on every state -- colour, icon and text -- '
                  'because the row asks for colour alone and colour alone '
                  'reaches neither a colour-blind user nor a screen reader',
          'Completion Status': 'Good',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'UI Design-System Adherence Rate',
            observed:
                'THE SIXTH AND LAST ROW CARRYING THE SHARED METRIC. The same '
                '"UI Design-System Adherence Rate" and the same mixed-unit '
                'band as Steps 389, 401, 403, 405 and 406 -- six subjects, one '
                'rate. Observed: $steps calculation steps, $deductions of them '
                'deductions, summing in integer fils to $fils, every line '
                'naming the rule that produced it.',
            floor: '>=85%',
            optimal: '>=95%',
            ceiling: '1',
            higherIsBetter: true,
          ),
          AissMeasurement(
            metricName: 'Steps a user cannot re-add',
            observed:
                '0 of $steps. The arithmetic is held in fils rather than in a '
                'decimal currency amount, so the lines sum exactly instead of '
                'nearly; a disclosure that does not add up converts a question '
                'about a payslip into a question about arithmetic and costs '
                'more support time than no disclosure at all. $deductions '
                'lines are deductions and are shown rather than netted off, '
                'because a deduction is the line people ring about, and each '
                'one names its rule.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/disclosure/intermediate_values.dart',
        ],
      ),
    );
  });
}
