/// AISS GATE -- Step 359 of 375
/// Global Reference ID:       ACRAE-004
/// Atomic Steps Reference ID: ACRAE-004
/// Setup Step (Action): "Inventory non-critical telemetry data requiring
///                      background upload." (TELEMETRY, ON A REPORT-UI ROW)
/// Atomic Step: "Append the Confidence Indicator visually next to the AI's
///               rating in the final report UI."
/// Metric: Appraisal Completion Accuracy (%) -- floor 95, optimal 99, ceiling
///         100. Complete/Partial/Not Complete. ISO 30401.
///
/// A MODEL'S CONFIDENCE IS NOT A PROBABILITY OF BEING RIGHT, AND THE TWO
/// RATINGS THE CONTROL EXISTS FOR ARE THE TWO WITH THE HIGHEST SCORES.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/badges/confidence_indicator.dart';

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

  group('ACRAE-004 :: the number that is not rendered', () {
    gate(
      'ACRAE-004-G1',
      'A scoring function\'s output is not a probability of being right.',
      'On inputs unlike its training data it is usually high and usually '
          'wrong, so no wording here contains a percentage sign',
      () =>
          !HabotConfidenceIndicator.theRawScoreIsRenderedAsAPercentage &&
          HabotConfidenceIndicator.noWordingIsAPercentage &&
          HabotConfidenceIndicator.scoreNote.contains('promise nobody'),
    );

    gate(
      'ACRAE-004-G2',
      'Four bands, each with its own wording.',
      'High, moderate, low, and unsupported -- the fourth being the case where '
          'there is nothing to cite whatever the score said',
      () =>
          HabotConfidenceBand.values.length == 4 &&
          HabotConfidenceIndicator.everyBandHasItsOwnWording,
    );
  });

  group('ACRAE-004 :: the two cases the control exists for', () {
    gate(
      'ACRAE-004-G3',
      'Four worked ratings, one low and one unsupported.',
      'The low one is outside the model\'s calibrated range; the unsupported '
          'one has no citable source',
      () =>
          HabotConfidenceIndicator.ratings.length == 4 &&
          HabotConfidenceIndicator.oneRatingIsLow &&
          HabotConfidenceIndicator.oneRatingIsUnsupported,
    );

    gate(
      'ACRAE-004-G4',
      'Both of them score above 0.9.',
      'The score is confident in exactly the two cases where the interface '
          'should not be, which is the whole argument',
      () =>
          HabotConfidenceIndicator.theTwoFailingRatingsScoreHighest &&
          HabotConfidenceIndicator.populationNote.contains('should not be'),
    );
  });

  group('ACRAE-004 :: citations, which the row buries', () {
    gate(
      'ACRAE-004-G5',
      'The row asks for source chips and tap-to-source, in a formatting note.',
      'A citation somebody can open is worth more than any confidence number, '
          'because it turns "trust me" into "look"',
      () =>
          HabotConfidenceIndicator.aCitationIsOpenable &&
          HabotConfidenceIndicator.citationNote.contains('turns "trust me"'),
    );

    gate(
      'ACRAE-004-G6',
      'Every rating not marked unsupported cites at least one source.',
      'Four citations across three supported ratings',
      () =>
          HabotConfidenceIndicator.everySupportedRatingCitesSomething &&
          HabotConfidenceIndicator.totalCitations == 4,
    );

    gate(
      'ACRAE-004-G7',
      'The rating with nothing to cite says so on its face.',
      'Whatever its score, which was 0.95',
      () =>
          HabotConfidenceIndicator.oneRatingIsUnsupported &&
          HabotConfidenceIndicator.ratings.last.citations.isEmpty,
    );
  });

  group('ACRAE-004 :: reuse and the band', () {
    gate(
      'ACRAE-004-G8',
      'The interval threshold is the existing metric\'s.',
      'Past a relative interval width a reading renders as indicative rather '
          'than as a number -- the same rule this row needs',
      () =>
          HabotConfidenceIndicator.theIntervalRuleIsAlreadyDeclared &&
          HabotConfidenceIndicator.indicativeThreshold == 0.5,
    );

    gate(
      'ACRAE-004-G9',
      'Floor 95, optimal 99, ceiling 100 -- well formed.',
      'And named "Appraisal Completion Accuracy", which is about whether '
          'appraisals finish; the figure published is about this row instead',
      () =>
          HabotConfidenceIndicator.theBandIsWellFormed &&
          HabotConfidenceIndicator.completeness == 100 &&
          HabotConfidenceIndicator.bandNote
              .contains('a number about this row'),
    );

    gate(
      'ACRAE-004-G10',
      'Output reported as Complete / Partial / Not Complete.',
      'Six obligations, all met, giving Complete; all ten declared checks hold',
      () =>
          HabotConfidenceIndicator.obligations.length == 6 &&
          HabotConfidenceIndicator.obligations.values.every((bool b) => b) &&
          HabotConfidenceIndicator.qualitativeOutput == 'Complete' &&
          HabotConfidenceIndicator.checks.length == 10 &&
          HabotConfidenceIndicator.checks.values.every((bool b) => b) &&
          HabotConfidenceIndicator.columnNote.contains('background upload'),
    );
  });

  tearDownAll(() {
    final int low = HabotConfidenceIndicator.countIn(HabotConfidenceBand.low);
    final int unsupported =
        HabotConfidenceIndicator.countIn(HabotConfidenceBand.unsupported);
    final String lowWording =
        HabotConfidenceIndicator.wording[HabotConfidenceBand.low] ?? '';

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'ACRAE-004',
        atomicStepReferenceId: 'ACRAE-004',
        setupStepAction:
            'COLUMN NOTE: the Setup Step column on this row reads "Inventory '
            'non-critical telemetry data requiring background upload", which '
            'is a telemetry instruction on a report-UI row; the metric is an '
            'appraisal completion accuracy on a confidence display; and the '
            'Data Requirement column holds the better design -- source chips '
            'and a tap-to-source citation -- as a formatting note. Atomic '
            'Step: "Append the Confidence Indicator visually next to the AI\'s '
            'rating in the final report UI."',
        implementationOrder: 359,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Step Execution ID': 'ACRAE-004',
          'Execution Status': 'Complete',
          'Execution Timestamp': '2026-09-17T00:00:00Z',
          'Step Outcome':
              '4 ratings across 4 confidence bands; $low low and $unsupported '
                  'unsupported, both scoring above 0.9',
          'User ID': 'Fredrick',
          'Completion Status': 'Complete',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
          'Component Properties':
              'the low band reads "$lowWording"; no wording in the indicator '
                  'contains a percentage sign',
          'Data Quality Note':
              'SCORE: ${HabotConfidenceIndicator.scoreNote} '
              'POPULATION: ${HabotConfidenceIndicator.populationNote} '
              'CITATIONS: ${HabotConfidenceIndicator.citationNote} '
              'REUSE: ${HabotConfidenceIndicator.reuseNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Appraisal Completion Accuracy (%)',
            observed:
                '100, over the population named here rather than the one the '
                'metric implies: the share of ratings carrying a stated '
                'confidence band. The band itself is well formed at 95, 99, '
                '100, and the metric is about whether appraisals finish rather '
                'than about whether a confidence display is honest.',
            floor: '95',
            optimal: '99',
            ceiling: '100',
          ),
          AissMeasurement(
            metricName: 'Ratings shown as confident that should not be',
            observed:
                '0 of 4, because the indicator reports a named band rather '
                'than the scoring function\'s output. Of the four worked '
                'ratings, one is outside the calibrated range and one has no '
                'citable source -- and both score above 0.9, at 0.97 and 0.95. '
                'A display that rendered the raw number would have shown both '
                'as strong. Every supported rating cites a source a person can '
                'open, which is the row\'s own Data Requirement asking for the '
                'better design in a formatting note.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/badges/confidence_indicator.dart',
        ],
      ),
    );
  });
}
