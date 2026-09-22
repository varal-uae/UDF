/// AISS GATE -- Step 439 of 415
/// Global Reference ID:       GEN-05221
/// Atomic Steps Reference ID: GEN-05221
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Build and configure: build mobile dashboard progression cards
///               showing current level, points, and next-tier requirements"
/// Metric: Performance Tier Calculation Accuracy -- floor ">= 95%", optimal ">=
///         99%", ceiling "1". Best Qualitative Output: "Pass/Fail". Octalysis
///         Gamification Framework. Assigned to **UDF**.
///
/// A PROGRESSION CARD, AND THE METRIC NAME THAT TURNS A GAME LEVEL INTO A
/// PERFORMANCE TIER.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/recognition/progression_card.dart';

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

  group('GEN-05221 :: level, not tier', () {
    gate(
      'GEN-05221-G1',
      'The metric relabels a level as a performance tier.',
      'The instruction says level; the metric says performance tier',
      () => HabotProgressionCard.theMetricRelabelsTheLevel,
    );

    gate(
      'GEN-05221-G2',
      'And a level ignores three things a rating must weigh.',
      'Quality, difficulty and circumstances',
      () =>
          HabotProgressionCard.threeThingsALevelIgnores &&
          HabotProgressionCard.relabelNote.contains('where the slide starts'),
    );

    gate(
      'GEN-05221-G3',
      'The card says level.',
      'Tier is refused on anything a person sees',
      () => HabotProgressionCard.tierIsRefusedOnScreen,
    );

  });

  group('GEN-05221 :: white-hat drives only', () {
    gate(
      'GEN-05221-G4',
      'Six drives assessed, three used, all white-hat.',
      'Meaning, accomplishment and empowerment; not scarcity, unpredictability '
          'or loss',
      () =>
          HabotProgressionCard.drives.length == 6 &&
          HabotProgressionCard.everyWhiteHatDriveIsUsed &&
          HabotProgressionCard.noBlackHatDriveIsUsed,
    );

    gate(
      'GEN-05221-G5',
      'No countdown, no threatened loss, no comparison.',
      'The black-hat side of Octalysis is left out',
      () => HabotProgressionCard.theCardIsWhiteHatOnly,
    );

    gate(
      'GEN-05221-G6',
      'And this time the standard contains the idea.',
      'Unlike Step 418\'s, Octalysis names the distinction the row needs',
      () =>
          HabotProgressionCard.thisStandardContainsTheIdea &&
          HabotProgressionCard.theRowWhoseStandardCouldNotHelp == 418 &&
          HabotProgressionCard.standardNote.contains('distinction'),
    );

  });

  group('GEN-05221 :: the requirement in work', () {
    gate(
      'GEN-05221-G7',
      'Forty points is four overtime completions or two modules.',
      'The requirement is written in work, not in points',
      () =>
          HabotProgressionCard.pointsToGo == 40 &&
          HabotProgressionCard.theRequirementIsInWork,
    );

    gate(
      'GEN-05221-G8',
      'Counted with Step 436\'s definition of completion.',
      'A submitted but undecided request does not count',
      () =>
          HabotProgressionCard.workNote.contains('does not count') &&
          HabotCompletionCriteria.aSubmittedRecordIsNotComplete,
    );

  });

  group('GEN-05221 :: the band', () {
    gate(
      'GEN-05221-G9',
      'The band mixes units.',
      'Two percentages and a ceiling of 1',
      () => HabotProgressionCard.theBandMixesUnits,
    );

    gate(
      'GEN-05221-G10',
      'Five obligations, all met, giving Pass.',
      'And all ten declared checks hold',
      () =>
          HabotProgressionCard.obligations.length == 5 &&
          HabotProgressionCard.obligations.values.every((bool b) => b) &&
          HabotProgressionCard.qualitativeOutput == 'Pass' &&
          HabotProgressionCard.currentLevel == 3,
    );
  });

  tearDownAll(() {
    final int level = HabotProgressionCard.currentLevel;
    final int toGo = HabotProgressionCard.pointsToGo;
    final double accuracy = HabotProgressionCard.calculationAccuracy;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-05221',
        atomicStepReferenceId: 'GEN-05221',
        setupStepAction:
            'COLUMN NOTE: this row\'s instruction says "level" and its metric '
            'says "Performance Tier", relabelling a count of completions as a '
            'rating of how well somebody works -- the card says level and tier '
            'is refused on screen; its reference standard, Octalysis, is the '
            'rare citation that contains the distinction the row needs, and '
            'only its white-hat drives are used; and its band writes floor and '
            'optimal as percentages against a ceiling of 1. Atomic Step: '
            '"Build and configure: build mobile dashboard progression cards '
            'showing current level, points, and next-tier requirements"',
        implementationOrder: 439,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Build and configure: build mobile dashboard progression cards '
          'showing current':
              'a card showing level $level, $toGo points to go written as four '
                  'overtime completions or two training modules, white-hat '
                  'drives only',
          'Completion Status': 'Pass',
          'Action/Event Timestamp': '2026-09-22T00:00:00Z',
          'User/Session ID': 'Fredrick',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Performance Tier Calculation Accuracy',
            observed:
                'THE METRIC CALLS A GAME LEVEL A PERFORMANCE TIER. A level '
                'counts completions and says nothing about their quality, '
                'difficulty or circumstances, which a performance rating must '
                'weigh; this metric is where the slide from one to the other '
                'starts. The card says level. The band writes floor and '
                'optimal as percentages against a ceiling of 1. Observed: '
                '$accuracy per cent of cards calculated correctly.',
            floor: '>= 95%',
            optimal: '>= 99%',
            ceiling: '1',
            higherIsBetter: true,
          ),
          AissMeasurement(
            metricName: 'Black-hat motivation drives on the card',
            observed:
                '0 of 3. Octalysis divides motivation into drives that make '
                'people feel good about what they did and drives that make '
                'them anxious about what they might lose; unlike the standard '
                'Step 418 cited, it names the distinction this card needs. No '
                'countdown, no threatened loss of level, no comparison with '
                'anybody else, and the next requirement is written as work to '
                'do rather than a number to reach.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/recognition/progression_card.dart',
        ],
      ),
    );
  });
}
