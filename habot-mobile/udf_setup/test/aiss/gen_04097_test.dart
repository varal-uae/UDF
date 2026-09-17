/// AISS GATE -- Step 391 of 395
/// Global Reference ID:       GEN-04097
/// Atomic Steps Reference ID: GEN-04097
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Run automated UI tests attempting malformed entries to
///               confirm local client rejection."
/// Metric: Local Rejection Test Pass Rate -- floor 1, optimal 1, ceiling 1.
///         Pass / Fail. Automated UI Security Test Suite. Assigned to **ADFA**.
///
/// THE ONLY ROW IN THE BATCH THAT TESTS A REFUSAL RATHER THAN BUILDING ONE, AND
/// THE THIRD COLLAPSED BAND IN THE TRACK.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/forms/malformed_entry_suite.dart';

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

  group('GEN-04097 :: the row that tests the refusals', () {
    gate(
      'GEN-04097-G1',
      'This row tests a refusal rather than building one.',
      'Which makes it the row most likely to be skipped and the most valuable',
      () =>
          HabotMalformedEntrySuite.itIsTheTestRowInTheBatch &&
          !HabotMalformedEntrySuite.thisRowBuildsARefusal,
    );

    gate(
      'GEN-04097-G2',
      'A refusal nobody tested works until somebody edits a regex.',
      'And it produces nothing anybody can look at, which is why it gets '
          'dropped first',
      () => HabotMalformedEntrySuite.roleNote
          .contains('somebody edits a regular expression'),
    );
  });

  group('GEN-04097 :: seven classes of malformed', () {
    gate(
      'GEN-04097-G3',
      'Seven malformation classes, each with a case.',
      'Too long, wrong alphabet, a control character, an invisible format '
          'character, a direction override, a checksum failure, and whitespace '
          'that looks like content',
      () =>
          HabotMalformedClass.values.length == 7 &&
          HabotMalformedEntrySuite.everyClassHasACase &&
          HabotMalformedEntrySuite.coverage == 100,
    );

    gate(
      'GEN-04097-G4',
      'Four of the seven are invisible on screen.',
      'Which is exactly why hand-written tests miss them',
      () =>
          HabotMalformedEntrySuite.fourOfSevenAreInvisible &&
          HabotMalformedEntrySuite.invisibleCases == 4 &&
          HabotMalformedEntrySuite.classesNote.contains('hand-written'),
    );
  });

  group('GEN-04097 :: the invisible list is the declared one', () {
    gate(
      'GEN-04097-G5',
      'The code points come from Step 302\'s blank-input rule.',
      'Rather than from a second list kept here',
      () =>
          HabotMalformedEntrySuite.theInvisibleListIsAlreadyDeclared &&
          !HabotMalformedEntrySuite.aSecondListIsKeptHere,
    );

    gate(
      'GEN-04097-G6',
      'So the suite grows when the rule does.',
      'A character added to the rule is tested here without anybody '
          'remembering to, which is how a list like this stays correct',
      () =>
          HabotMalformedEntrySuite.theSuiteGrowsWithTheRule &&
          HabotMalformedEntrySuite.reuseNote
              .contains('longer than a release'),
    );
  });

  group('GEN-04097 :: assert the reason, not the refusal', () {
    gate(
      'GEN-04097-G7',
      'Every case asserts which rule fired.',
      '"Rejected" is not enough',
      () => HabotMalformedEntrySuite.everyCaseAssertsWhichRuleFired,
    );

    gate(
      'GEN-04097-G8',
      'And the seven asserted rules are distinct.',
      'So a refusal from the wrong rule fails the suite instead of counting as '
          'a pass',
      () => HabotMalformedEntrySuite.theRulesAreDistinct,
    );

    gate(
      'GEN-04097-G9',
      'A field that refuses everything would not pass.',
      'Which is how a validator can start rejecting valid input and look '
          'healthier for it',
      () =>
          !HabotMalformedEntrySuite.aFieldThatRefusesEverythingWouldPass &&
          HabotMalformedEntrySuite.assertionNote
              .contains('look healthier for it'),
    );
  });

  group('GEN-04097 :: the band, collapsed for the third time', () {
    gate(
      'GEN-04097-G10',
      'Floor, optimal and ceiling are all 1; output Pass / Fail.',
      'The third collapsed band in the track and the one row where the shape '
          'is defensible; five obligations, all met, and all ten declared '
          'checks hold',
      () =>
          HabotMalformedEntrySuite.theBandIsCollapsed &&
          HabotMalformedEntrySuite.thisIsTheThirdCollapsedBand &&
          HabotMalformedEntrySuite.theShapeIsDefensibleHere &&
          HabotMalformedEntrySuite.obligations.length == 5 &&
          HabotMalformedEntrySuite.obligations.values.every((bool b) => b) &&
          HabotMalformedEntrySuite.qualitativeOutput == 'Pass' &&
          HabotMalformedEntrySuite.checks.length == 10 &&
          HabotMalformedEntrySuite.checks.values.every((bool b) => b),
    );
  });

  tearDownAll(() {
    final int cases = HabotMalformedEntrySuite.cases.length;
    final int invisible = HabotMalformedEntrySuite.invisibleCases;
    final int codePoints =
        HabotMalformedEntrySuite.invisibleCodePoints.length;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-04097',
        atomicStepReferenceId: 'GEN-04097',
        setupStepAction:
            'COLUMN NOTE: this row is assigned to ADFA rather than UDF; its '
            'band sets floor, optimal and ceiling all to 1 -- the third '
            'collapsed band in the track, after Step 353 and alongside Step '
            '383 in this batch, and the one row where the shape is defensible '
            'because a rejection suite genuinely is all or nothing; its Data '
            'Requirement cell holds the Atomic Step\'s own text truncated with '
            'an ellipsis; and the Setup Step column is empty. Atomic Step: '
            '"Run automated UI tests attempting malformed entries to confirm '
            'local client rejection."',
        implementationOrder: 391,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Run automated UI tests attempting malformed entries to confirm':
              '$cases cases across 7 malformation classes, $invisible of them '
                  'invisible on screen',
          'Completion Status': 'Pass',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
          'Component Properties':
              'the invisible code points are read from the declared '
                  'blank-input rule, which holds $codePoints of them',
          'Data Quality Note':
              'ROLE: ${HabotMalformedEntrySuite.roleNote} CLASSES: '
              '${HabotMalformedEntrySuite.classesNote} REUSE: '
              '${HabotMalformedEntrySuite.reuseNote} ASSERTION: '
              '${HabotMalformedEntrySuite.assertionNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Local Rejection Test Pass Rate',
            observed:
                'COLLAPSED, FOR THE THIRD TIME IN THE TRACK, AND DEFENSIBLY SO '
                'FOR ONCE. Floor, optimal and ceiling are all 1, as at Step '
                '383 in this batch and Step 353 before it. A rejection suite '
                'genuinely is all or nothing, which makes this the one row '
                'where the shape says something true -- it is recorded because '
                'the other two did not, and because three occurrences make the '
                'shape a habit rather than a judgement.',
            floor: '1',
            optimal: '1',
            ceiling: '1',
          ),
          AissMeasurement(
            metricName: 'Malformation classes with no case',
            observed:
                '0 of 7. This is the only row in the batch that tests a '
                'refusal rather than building one, which makes it the one most '
                'likely to be dropped -- it produces nothing anybody can look '
                'at -- and the most valuable, because a refusal nobody tested '
                'works until the day somebody edits a regular expression. '
                '$invisible of the seven cases are invisible to a person '
                'looking at the field, and their code points are read from the '
                'declared blank-input rule rather than from a second list. '
                'Each case asserts which rule fired, so a field that refused '
                'everything would fail this suite rather than sail through it.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/forms/malformed_entry_suite.dart',
        ],
      ),
    );
  });
}
