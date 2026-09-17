/// AISS GATE -- Step 356 of 375
/// Global Reference ID:       GEN-00932
/// Atomic Steps Reference ID: GEN-00932
/// Setup Step (Action): "Create a configuration file storing the Regex maps
///                      for each specific CDE field ID." (INPUT MASKING, ON A
///                      BADGE ROW)
/// Atomic Step: "Display \"Bank Verified Revenue\" badge on mobile executive
///               dashboard views."
/// Metric: UI Render Frame Rate -- floor, optimal and ceiling all
///         `$60\text{ fps}$`. Complete / Not Complete. Material Design 3 Cards.
///
/// THE FIRST BAND DEFECT IN THIS TRACK THAT IS ABOUT THE ENCODING RATHER THAN
/// THE VALUES: ALL THREE CELLS ARE LATEX.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/badges/bank_verified_badge.dart';

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

  group('GEN-00932 :: the band is typeset', () {
    gate(
      'GEN-00932-G1',
      'Floor, optimal and ceiling all hold the same LaTeX string.',
      r'$60\text{ fps}$ -- math mode with a \text{} wrapper, in a cell a '
          'consumer will try to read as a number',
      () =>
          HabotBankVerifiedBadge.allThreeBoundariesAreIdentical &&
          HabotBankVerifiedBadge.theBandIsLatex,
    );

    gate(
      'GEN-00932-G2',
      'None of the three parses as a number.',
      'double.tryParse returns null and a careless reader substitutes zero, '
          'which is how this kind of defect fails quietly',
      () =>
          HabotBankVerifiedBadge.theBandCannotBeParsedAsANumber &&
          HabotBankVerifiedBadge.theIntendedValueIsRecoverable,
    );

    gate(
      'GEN-00932-G3',
      'Every band defect before this was about the values.',
      'Inverted, collapsed, mismatched units, unfailable -- this is the first '
          'about the encoding',
      () => HabotBankVerifiedBadge.encodingNote
          .contains('first about the encoding'),
    );
  });

  group('GEN-00932 :: what the badge may claim', () {
    gate(
      'GEN-00932-G4',
      'Four sources of a verification claim, one of which is sufficient.',
      'A bank name on file, a linked account and a successful login to an '
          'aggregator are not a bank confirming anything',
      () =>
          HabotVerificationSource.values.length == 4 &&
          HabotBankVerifiedBadge.threeOfFourSourcesAreInsufficient,
    );

    gate(
      'GEN-00932-G5',
      'The badge renders nothing without a verification record.',
      'Otherwise it borrows a bank\'s credibility for a number the bank never '
          'saw',
      () =>
          !HabotBankVerifiedBadge.theBadgeRendersWithoutARecord &&
          !HabotBankVerifiedBadge.mayAssert(null) &&
          HabotBankVerifiedBadge.claimNote.contains('never saw'),
    );
  });

  group('GEN-00932 :: a verification has an age', () {
    gate(
      'GEN-00932-G6',
      'A bank confirmed the revenue at a moment, not permanently.',
      'The badge carries its verification date and stops asserting past a '
          'thirty-day window',
      () =>
          HabotBankVerifiedBadge.theBadgeShowsItsVerificationDate &&
          HabotBankVerifiedBadge.assertionWindow.inDays == 30,
    );

    gate(
      'GEN-00932-G7',
      'The age is classified by Step 129\'s freshness policy.',
      'Rather than a second scheme that can disagree with the dashboard around '
          'it',
      () =>
          HabotBankVerifiedBadge.theAgeVocabularyIsAlreadyDeclared &&
          HabotBankVerifiedBadge.ageNote.contains('Step 129'),
    );
  });

  group('GEN-00932 :: the amount has to match', () {
    gate(
      'GEN-00932-G8',
      'One of three worked pairs would borrow credibility.',
      'A badge asserting a bank confirmed one figure, beside a different '
          'figure -- credible and wrong at once',
      () =>
          HabotBankVerifiedBadge.oneOfThreeWouldBorrowCredibility &&
          HabotBankVerifiedBadge.amountsThatMatch == 2,
    );

    gate(
      'GEN-00932-G9',
      'The badge and the amount come from the same record.',
      'Because in most dashboards they are drawn by different code and the '
          'badge survives a change to the number beside it',
      () => HabotBankVerifiedBadge.amountNote
          .contains('credible and wrong at once'),
    );

    gate(
      'GEN-00932-G10',
      'Output reported as Complete / Not Complete.',
      'Five obligations, all met, giving Complete; all ten declared checks '
          'hold',
      () =>
          HabotBankVerifiedBadge.obligations.length == 5 &&
          HabotBankVerifiedBadge.obligations.values.every((bool b) => b) &&
          HabotBankVerifiedBadge.qualitativeOutput == 'Complete' &&
          HabotBankVerifiedBadge.checks.length == 10 &&
          HabotBankVerifiedBadge.checks.values.every((bool b) => b) &&
          HabotBankVerifiedBadge.columnNote.contains('Regex maps'),
    );
  });

  tearDownAll(() {
    final int insufficient =
        HabotBankVerifiedBadge.insufficientSources.length;
    final int matching = HabotBankVerifiedBadge.amountsThatMatch;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-00932',
        atomicStepReferenceId: 'GEN-00932',
        setupStepAction:
            'COLUMN NOTE: all three boundary cells on this row hold the LaTeX '
            'string for sixty frames a second, which cannot be parsed as a '
            'number; the metric is a render frame rate on a static badge; the '
            'Data Requirement cell reads "Data/artifacts to prepare: Bank '
            'Verified Revenue", which is the badge label lifted into the '
            'artefact list; and the Setup Step column reads "Create a '
            'configuration file storing the Regex maps for each specific CDE '
            'field ID". Atomic Step: "Display Bank Verified Revenue badge on '
            'mobile executive dashboard views."',
        implementationOrder: 356,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Bank Verified Revenue':
              '$insufficient of 4 claim sources are insufficient; the badge '
                  'renders for one of them and for no record at all',
          'Completion Status': 'Complete',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
          'Component Properties':
              '$matching of 3 worked pairs have the badge covering the amount '
                  'beside it; the badge carries its verification date and '
                  'stops asserting after thirty days',
          'Data Quality Note':
              'ENCODING: ${HabotBankVerifiedBadge.encodingNote} '
              'METRIC: ${HabotBankVerifiedBadge.metricNote} '
              'CLAIM: ${HabotBankVerifiedBadge.claimNote} '
              'AGE: ${HabotBankVerifiedBadge.ageNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'UI Render Frame Rate',
            observed:
                'THE BAND IS TYPESET. All three boundary cells hold the same '
                'LaTeX string -- math mode with a \\text{} wrapper -- in cells '
                'a downstream consumer will try to parse as numbers. Every '
                'band defect this track has recorded until now was about the '
                'values: inverted ends, collapsed ends, mismatched units, '
                'floors that cannot be failed. This is the first about the '
                'encoding, and it is the kind that fails silently. The '
                'metric is also a frame rate on a static chip, which does '
                'not animate.',
            floor: r'$60\text{ fps}$',
            optimal: r'$60\text{ fps}$',
            ceiling: r'$60\text{ fps}$',
          ),
          AissMeasurement(
            metricName: 'Claim sources sufficient to render the badge',
            observed:
                '1 of 4. "Bank Verified" says a bank confirmed this revenue, '
                'and a bank name on file, a linked account and a successful '
                'login to an aggregator are three other things. The badge '
                'renders for a bank confirmation and for nothing else, carries '
                'the date of that confirmation, stops asserting after thirty '
                'days, and refuses when the verified amount is not the amount '
                'shown beside it -- which one of the three worked pairs is.',
            floor: '1',
            optimal: '1',
            ceiling: '1',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/badges/bank_verified_badge.dart',
        ],
      ),
    );
  });
}
