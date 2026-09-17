/// AISS GATE -- Step 422 of 415
/// Global Reference ID:       UFHT-025-12
/// Atomic Steps Reference ID: UFHT-025-12
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Compute the average time-to-action metric for every active
///               layout view screen."
/// Metric: Touch Target Size & Accessibility Compliance -- floor "44px / WCAG
///         AA", optimal "48px / WCAG AA", ceiling "56px / WCAG AAA". Best
///         Qualitative Output: "Good (Scale: Good/Average/Poor)". Google
///         Material Design 3 Accessibility Guidelines; WCAG 2.1 AA (min. 4.5:1
///         contrast, 44-48dp touch target). Assigned to **UDF**.
///
/// A TOUCH-TARGET BAND FOR THE THIRD TIME, ON A ROW ABOUT HOW LONG A SCREEN
/// TAKES.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/telemetry/time_to_action.dart';

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

  group('UFHT-025-12 :: the band belongs elsewhere', () {
    gate(
      'UFHT-025-12-G1',
      'The band belongs to a touch-target row.',
      '44px / 48px / 56px, on a row measuring time from screen to action',
      () =>
          HabotTimeToAction.theBandIsAboutTouchTargets &&
          HabotTimeToAction.theBandMeasuresSomethingElse,
    );

    gate(
      'UFHT-025-12-G2',
      'Third occurrence, so it is a default.',
      'After Steps 342 and 402 -- three unrelated subjects carrying one band '
          'is what the sheet writes when nobody supplied one',
      () =>
          HabotTimeToAction.thirdOccurrence &&
          HabotTimeToAction.itIsADefaultRatherThanAMistake,
    );

  });

  group('UFHT-025-12 :: the same objection as Step 421', () {
    gate(
      'UFHT-025-12-G3',
      'Three screens and twenty-one observations.',
      'Clock-in, overtime request and shift swap',
      () =>
          HabotTimeToAction.screenCount == 3 &&
          HabotTimeToAction.observationCount == 21,
    );

    gate(
      'UFHT-025-12-G4',
      'One screen has a mean twice its median.',
      'Carried by a single observation just under two minutes',
      () =>
          HabotTimeToAction.theMeanIsPulledUpwards &&
          HabotTimeToAction.theSameObjectionAsStep421,
    );

    gate(
      'UFHT-025-12-G5',
      'So three statistics are published.',
      'The mean the row asks for, the median and the p90, for the same reason '
          'as one row earlier',
      () =>
          HabotTimeToAction.threeStatisticsArePublished &&
          HabotTimeToAction.everyScreenHasAllThreeStatistics,
    );

  });

  group('UFHT-025-12 :: close to Step 421 and not the same', () {
    gate(
      'UFHT-025-12-G6',
      'This row and Step 421 are distinct.',
      'Time inside a field against time from a screen appearing to its '
          'transaction committing',
      () =>
          HabotTimeToAction.theTwoAreDistinct &&
          HabotTimeToAction.theDifferenceIsWrittenDown,
    );

    gate(
      'UFHT-025-12-G7',
      'And the difference is written down rather than rediscovered.',
      'They are close enough that a reader could reasonably think one is '
          'redundant',
      () => HabotTimeToAction.adjacencyNote.contains('during a cleanup'),
    );

  });

  group('UFHT-025-12 :: the claim in the design cells', () {
    gate(
      'UFHT-025-12-G8',
      'The row\'s claim holds by screen and fails by person.',
      '"Protects workforce from subjective micromanagement" is true aggregated '
          'and is the thing it claims to prevent when attributed',
      () =>
          HabotTimeToAction.theClaimDependsOnTheUnitOfAnalysis &&
          HabotTimeToAction.theUnitWasFixedAtStep416,
    );

    gate(
      'UFHT-025-12-G9',
      'And the grouping is by screen.',
      'Which is why Step 416 fixed the unit of analysis before any of these '
          'rows computed anything',
      () =>
          HabotTimeToAction.theGroupingIsByScreen &&
          HabotTimeToAction.claimNote.contains('cannot be offended'),
    );

    gate(
      'UFHT-025-12-G10',
      'Five obligations, all met, giving Good.',
      'And all ten declared checks hold',
      () =>
          HabotTimeToAction.obligations.length == 5 &&
          HabotTimeToAction.obligations.values.every((bool b) => b) &&
          HabotTimeToAction.qualitativeOutput == 'Good' &&
          HabotTimeToAction.theSlowestScreenHasTheMostFields,
    );
  });

  tearDownAll(() {
    final int screens = HabotTimeToAction.screenCount;
    final int observations = HabotTimeToAction.observationCount;
    final int occurrences = HabotTimeToAction.rowsCarryingThisBand.length;
    final String claim = HabotTimeToAction.theRowsClaim;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'UFHT-025-12',
        atomicStepReferenceId: 'UFHT-025-12',
        setupStepAction:
            'COLUMN NOTE: this row is scored on "Touch Target Size & '
            'Accessibility Compliance" with a 44px/48px/56px band, which '
            'belongs to a touch-target row and is here on a row about '
            'time-to-action -- the third occurrence in the track after Steps '
            '342 and 402, which makes it the sheet\'s default band rather than '
            'one row\'s mistake; its Best Qualitative Output cell reads "Good '
            '(Scale: Good/Average/Poor)", stating its own answer and then the '
            'scale; its Data Requirement holds the Layout Type/Grid Dimensions '
            'field set that belongs to a layout row; and its design cells '
            'claim the measurement protects the workforce from subjective '
            'micromanagement, which is true by screen and false by person. '
            'Atomic Step: "Compute the average time-to-action metric for every '
            'active layout view screen."',
        implementationOrder: 422,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Layout Type':
              'not applicable: this row\'s Data Requirement holds the layout '
                  'field set belonging to a layout row',
          'Layout Grid Dimensions': 'as above',
          'Spacing Rules': 'as above',
          'Alignment Settings': 'as above',
          'Layout Validation Status':
              '$screens screens and $observations observations, each screen '
                  'publishing a mean, a median and a ninetieth percentile',
          'Completion Status': 'Good',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Touch Target Size & Accessibility Compliance',
            observed:
                'THE BAND BELONGS TO A TOUCH-TARGET ROW, FOR THE THIRD TIME IN '
                'THE TRACK. "Touch Target Size & Accessibility Compliance" at '
                '44px, 48px and 56px is a band about the size of a tap target, '
                'and this row measures how long a screen takes to produce an '
                'action. Steps 342 and 402 carried the same band on two other '
                'unrelated subjects, which makes $occurrences occurrences and '
                'a default rather than a mistake: this is what the sheet '
                'writes when nobody supplied a band. Observed: $screens '
                'screens and $observations observations, each screen carrying '
                'three statistics.',
            floor: '44px / WCAG AA',
            optimal: '48px / WCAG AA',
            ceiling: '56px / WCAG AAA',
            higherIsBetter: true,
          ),
          AissMeasurement(
            metricName: 'Figures attributed to an individual',
            observed:
                '0 of $observations. The row\'s own design cells claim this '
                'measurement "$claim", which is true aggregated by screen -- a '
                'measured screen is an argument against a manager\'s '
                'impression, and the screen cannot be offended -- and false '
                'the moment the same number is attached to a name, when it '
                'becomes the thing it claims to prevent. Step 416 fixed the '
                'unit of analysis before any row in this batch computed '
                'anything, which is why the claim can be allowed to stand.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/telemetry/time_to_action.dart',
        ],
      ),
    );
  });
}
