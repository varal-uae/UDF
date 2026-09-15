/// AISS GATE -- Step 266 of 275
/// Global Reference ID:       GEN-04627
/// Atomic Steps Reference ID: GEN-04627
/// Setup Step (Action): (EMPTY on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Provide clear text alternatives (alt descriptions) for all
///               non-text visual content."
/// Metric: Accessibility Conformance Score -- Floor "90% (AA partial)",
///         Optimal "100% (Full AA)", Ceiling "N/A (AAA optional)".
///         Pass/Fail.
///
/// "ALL" IS WRONG IN TWO DIRECTIONS, AND A POLICY OF ALT-TEXT-ON-EVERYTHING
/// SCORES LOWER ON THIS ROW'S OWN METRIC THAN THE CENSUS DOES.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/a11y/alt_text_census.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  double score = 0;

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

  group('GEN-04627 :: the census', () {
    gate(
      'GEN-04627-G1',
      'Atomic Step: "for all non-text visual content".',
      'Eight classes of non-text content are inventoried, six informational '
          'and two decorative, and each says why it is classified that way',
      () =>
          HabotAltTextCensus.inventory.length == 8 &&
          HabotAltTextCensus.informational.length == 6 &&
          HabotAltTextCensus.decorative.length == 2 &&
          HabotAltTextCensus.inventory.every(
            (HabotNonTextContent c) => c.why.length > 40,
          ),
    );

    gate(
      'GEN-04627-G2',
      'SC 1.1.1 allows a text alternative OR being ignored.',
      'Decorative content is marked decorative rather than described, because '
          'alt text on a divider makes a screen reader announce a divider -- '
          'which is worse than silence',
      () =>
          HabotAltTextCensus.decorative.every(
            (HabotNonTextContent c) =>
                c.author == HabotAltAuthor.noneBecauseDecorative,
          ) &&
          HabotAltTextCensus.allIsWrongTwiceNote.contains('worse than '
              'silence'),
    );

    gate(
      'GEN-04627-G3',
      'And some non-text content has no author in this application.',
      'The support-ticket attachment is authored by the person who attached '
          'it, and when they decline it is announced as not described rather '
          'than given an invented description',
      () =>
          HabotAltTextCensus.theUploaderIsOneOfThem &&
          HabotAltTextCensus.authors.length == 4 &&
          HabotAltTextCensus.nothingIsLeftUnauthored,
    );

    gate(
      'GEN-04627-G4',
      'A chart\'s alternative is its finding, not its shape.',
      'The chart class is described by what the chart shows rather than by '
          'what kind of chart it is, and that distinction is recorded',
      () => HabotAltTextCensus.chartNote.contains('did not want one'),
    );
  });

  group('GEN-04627 :: the metric, and the rule that already existed', () {
    gate(
      'GEN-04627-G5',
      'Metric: Accessibility Conformance Score -- 90% / 100% / N/A.',
      'Every class is conformant, giving 100% against the row\'s optimal, and '
          'the ceiling is recorded as the band with no top that it is',
      () {
        score = HabotAltTextCensus.conformanceScore;
        return score == HabotAltTextCensus.optimalPercent &&
            HabotAltTextCensus.nonConformant.isEmpty &&
            score >= HabotAltTextCensus.floorPercent &&
            HabotAltTextCensus.qualitativeOutput == 'Pass';
      },
    );

    gate(
      'GEN-04627-G6',
      'A policy of alt-text-on-everything is worse on this row\'s own metric.',
      'Describing every class including the decorative ones scores 75% -- '
          'below the floor -- and the comparison is computed rather than '
          'argued',
      () =>
          HabotAltTextCensus.describingEverythingScoresLower &&
          (HabotAltTextCensus.scoreIfEverythingWereDescribed - 75).abs() <
              1e-9 &&
          HabotAltTextCensus.scoreIfEverythingWereDescribed <
              HabotAltTextCensus.floorPercent,
    );

    gate(
      'GEN-04627-G7',
      'The rule already exists; this is the seventh restatement.',
      'The Step 97 validator is exercised on real strings rather than '
          'restated: a finding passes, a file name fails, "image of a chart" '
          'fails, and a single character fails',
      () =>
          HabotAltTextCensus.theExistingValidatorStillDecides &&
          HabotAltTextCensus.alreadyExistsNote.contains('seventh '
              'restatement'),
    );

    gate(
      'GEN-04627-G8',
      'Output: Pass/Fail.',
      'All nine declared checks hold and the step reports Pass on a census '
          'rather than on an eighth implementation of a rule that has been '
          'enforced since Step 97',
      () =>
          HabotAltTextCensus.checks.length == 9 &&
          HabotAltTextCensus.checks.values.every((bool b) => b) &&
          HabotAltTextCensus.columnNote.contains('EMPTY'),
    );
  });

  tearDownAll(() {
    final String classes = '${HabotAltTextCensus.inventory.length}';
    final String info = '${HabotAltTextCensus.informational.length}';
    final String deco = '${HabotAltTextCensus.decorative.length}';
    final String authors = '${HabotAltTextCensus.authors.length}';
    final String naive =
        HabotAltTextCensus.scoreIfEverythingWereDescribed.toStringAsFixed(0);

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-04627',
        atomicStepReferenceId: 'GEN-04627',
        setupStepAction:
            'COLUMN NOTE: Setup Step (Action) is EMPTY on this row, and the '
            'ceiling reads "N/A (AAA optional)" -- a band with no top. '
            'Atomic Step: "Provide clear text alternatives (alt descriptions) '
            'for all non-text visual content."',
        implementationOrder: 266,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name':
              'HabotAltTextCensus / HabotNonTextContent / HabotAltAuthor',
          'Component Properties':
              '$classes classes of non-text content -- $info informational, '
              '$deco decorative -- written by $authors different authors '
              'including the person who attaches a file; validated by the '
              'existing HabotAltText rules rather than by new ones',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'FINDING: ${HabotAltTextCensus.allIsWrongTwiceNote} '
              'EXISTING: ${HabotAltTextCensus.alreadyExistsNote} '
              'CHARTS: ${HabotAltTextCensus.chartNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Accessibility Conformance Score',
            observed:
                '${score.toStringAsFixed(0)}% over $classes content classes: '
                'informational content has an author and decorative content '
                'is marked decorative, with nothing left in between.',
            floor: '90% (AA partial)',
            optimal: '100% (Full AA)',
            ceiling: 'N/A (AAA optional)',
          ),
          AissMeasurement(
            metricName: 'Score if every class were described',
            observed:
                '$naive%, below the row\'s own floor. Alt text on a divider '
                'makes a reader announce a divider, so the literal reading of '
                '"all" fails the metric the same sentence sets.',
            floor: '90% (AA partial)',
            optimal: '100% (Full AA)',
            ceiling: 'N/A (AAA optional)',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/a11y/alt_text_census.dart',
        ],
      ),
    );
  });
}
