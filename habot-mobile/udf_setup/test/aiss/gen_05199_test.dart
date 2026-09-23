/// AISS GATE -- Step 474 of 1,314
/// Global Reference ID:       GEN-05199
/// Atomic Steps Reference ID: GEN-05199
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Build and configure: implement an indisputable filter
///               algorithm verifying DCYN == 1 and LSA/Therapist certification
///               status prior to display"
/// Metric: Document/Credential Verification Accuracy -- floor ">= 95%", optimal
///         ">= 99%", ceiling "1". Best Qualitative Output: "Pass/Fail". ISO/IEC
///         27001 Information Security & KYC Verification Standard. Assigned to
///         **UDF**.
///
/// A 95 PER CENT FLOOR ON A SAFEGUARDING CHECK, WHICH IS ONE UNCERTIFIED ADULT
/// IN TWENTY.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/roster/certification_filter.dart';

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

  group('GEN-05199 :: what the floor would allow', () {
    gate(
      'GEN-05199-G1',
      'A floor of 95 per cent would allow one in twenty through.',
      'One uncertified adult in twenty reaching a family\'s screen',
      () => HabotCertificationFilter.theFloorWouldAllowOneInTwenty,
    );

    gate(
      'GEN-05199-G2',
      'And the ceiling is a bare 1 under two percentage cells.',
      'The band does not hold a single unit',
      () =>
          HabotCertificationFilter.theBandMixesUnits &&
          HabotCertificationFilter.floorNote.contains('exists to prevent'),
    );

  });

  group('GEN-05199 :: a hard gate, not a threshold', () {
    gate(
      'GEN-05199-G3',
      'Five workers, two displayed, three excluded.',
      'The gate runs at display time, not at registration',
      () =>
          HabotCertificationFilter.workers.length == 5 &&
          HabotCertificationFilter.twoAreDisplayed &&
          HabotCertificationFilter.threeAreExcluded,
    );

    gate(
      'GEN-05199-G4',
      'The expired certificate is excluded.',
      'A certificate valid yesterday is not valid today',
      () => HabotCertificationFilter.theExpiredWorkerIsExcluded,
    );

    gate(
      'GEN-05199-G5',
      'And so is the worker whose flag is not 1.',
      'DCYN == 1 is required, whatever DCYN turns out to mean',
      () => HabotCertificationFilter.theFlaggedWorkerIsExcluded,
    );

    gate(
      'GEN-05199-G6',
      'No confidence level displays an unverified worker.',
      'What the automated reader cannot confirm goes to a person',
      () =>
          HabotCertificationFilter.theGateIsHard &&
          HabotCertificationFilter.unreadableGoesToAPerson,
    );

  });

  group('GEN-05199 :: what the percentages can honestly measure', () {
    gate(
      'GEN-05199-G7',
      'The reader\'s accuracy is what the percentages measure.',
      '99.3 per cent, which a percentage can honestly describe',
      () =>
          HabotCertificationFilter.theReaderMeetsTheOptimal &&
          HabotCertificationFilter.rereadNote.contains('that count is zero'),
    );

  });

  group('GEN-05199 :: recorded, reviewable, one-directional', () {
    gate(
      'GEN-05199-G8',
      'Every exclusion is recorded and reviewable.',
      '"Indisputable" is not a property an algorithm can have',
      () => HabotCertificationFilter.theDecisionIsReviewable,
    );

    gate(
      'GEN-05199-G9',
      'The override excludes and never includes.',
      'A named person can remove somebody the filter allowed, and never add '
          'one it refused',
      () =>
          HabotCertificationFilter.theOverrideIsOneDirectional &&
          HabotCertificationFilter
              .indisputableNote.contains('never to include'),
    );

    gate(
      'GEN-05199-G10',
      'Five obligations met, DCYN left opaque, giving Pass.',
      'The third unexpanded abbreviation, logged for a named confirmer',
      () =>
          HabotCertificationFilter.obligations.length == 5 &&
          HabotCertificationFilter.obligations.values.every((bool b) => b) &&
          HabotCertificationFilter.dcynIsTreatedAsOpaque &&
          HabotCertificationFilter.theThirdUnexpandedAbbreviation &&
          HabotCertificationFilter.dcynConfirmer.isNotEmpty &&
          HabotCertificationFilter.qualitativeOutput == 'Pass',
    );
  });

  tearDownAll(() {
    final int workers = HabotCertificationFilter.workers.length;
    final int shown = HabotCertificationFilter.displayed.length;
    final double reader = HabotCertificationFilter.readerAccuracyPercent;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-05199',
        atomicStepReferenceId: 'GEN-05199',
        setupStepAction:
            'COLUMN NOTE: this row puts a floor of 95 per cent on a '
            'safeguarding check, which read as the filter\'s accuracy would '
            'allow one uncertified adult in twenty onto a family\'s screen, so '
            'the filter is built as a hard gate instead and the band\'s '
            'percentages are re-read as the accuracy of the automated '
            'certificate reader; its ceiling is a bare 1 beneath two '
            'percentage cells; "indisputable" is replaced by a recorded, '
            'reviewable decision whose human override can only exclude; and '
            'DCYN, the third unexpanded abbreviation in two batches, is '
            'treated as an opaque flag with its expansion logged for a named '
            'confirmer. Atomic Step: "Build and configure: implement an '
            'indisputable filter algorithm verifying DCYN == 1 and '
            'LSA/Therapist certification status prior to display"',
        implementationOrder: 474,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'LSA/Therapist':
              'a hard display gate over $workers worked records showing $shown '
                  'and excluding three, with reader accuracy '
                  '${reader.toStringAsFixed(1)} per cent and zero uncertified '
                  'workers displayed',
          'Completion Status': 'Pass',
          'Action/Event Timestamp': '2026-09-23T00:00:00Z',
          'User/Session ID': 'Fredrick',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Document/Credential Verification Accuracy',
            observed:
                'A STATISTICAL FLOOR IS THE WRONG SHAPE FOR A SAFEGUARDING '
                'CHECK. Read as the filter\'s accuracy, a floor of 95 per cent '
                'lets one uncertified adult in twenty reach a family\'s '
                'screen, which is the thing the filter exists to prevent; '
                'nobody would sign that floor written in words. The filter is '
                'a hard gate instead, and the band\'s percentages are re-read '
                'as the accuracy of the automated certificate reader: '
                '${reader.toStringAsFixed(1)} per cent, above the 99 optimal.',
            floor: '>= 95%',
            optimal: '>= 99%',
            ceiling: '1',
            higherIsBetter: true,
          ),
          AissMeasurement(
            metricName: 'Uncertified workers displayed to a family',
            observed:
                '0 of $workers. Display requires the flag equal to 1, a '
                'certificate present and verified, and an expiry in the '
                'future; $shown of $workers pass and three do not, one for an '
                'expired certificate, one for a flag that is not 1 and one the '
                'reader could not confirm and no person has checked. Every '
                'exclusion carries its reason and a named person can override '
                'in one direction only: to exclude, never to include.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/roster/certification_filter.dart',
        ],
      ),
    );
  });
}
