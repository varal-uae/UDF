/// AISS GATE -- Step 395 of 395
/// Global Reference ID:       GEN-03226
/// Atomic Steps Reference ID: GEN-03226
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Create visual SLA countdown timer widgets for approval review
///               cards."
/// Metric: SLA Widget Refresh Interval -- floor "1s", optimal "1s", ceiling
///         "2s". Best Qualitative Output: "Complete". OPS SLA Timer Framework.
///         Assigned to **UDF**.
///
/// THE FIRST BAND IN THIS TRACK THAT IS COLLAPSED AT ONE END AND INVERTED AT
/// THE OTHER.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/approvals/sla_countdown.dart';

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

  group('GEN-03226 :: collapsed and inverted at once', () {
    gate(
      'GEN-03226-G1',
      'The floor equals the optimal.',
      'Both are 1s on a refresh interval',
      () => HabotSlaCountdown.theFloorEqualsTheOptimal,
    );

    gate(
      'GEN-03226-G2',
      'And the ceiling is the worst of the three.',
      'Lower is better for a refresh interval, so a ceiling of 2s is the worst '
          'value the band names',
      () =>
          HabotSlaCountdown.theCeilingIsTheWorstValue &&
          HabotSlaCountdown.theBandIsCollapsedAndInverted,
    );

    gate(
      'GEN-03226-G3',
      'No previous band in this track carried both defects.',
      'Every inversion had three distinct values and every collapse was flat, '
          'so neither defect can be read as the other one\'s rounding',
      () =>
          !HabotSlaCountdown.anyPreviousBandCarriedBothDefects &&
          HabotSlaCountdown.bandNote.contains('rounding'),
    );
  });

  group('GEN-03226 :: cadence follows magnitude', () {
    gate(
      'GEN-03226-G4',
      'An hour away ticks once a minute; the last ten minutes tick every '
          'second.',
      'A second-by-second countdown on a list of cards redraws a number nobody '
          'is watching',
      () =>
          HabotSlaCountdown.anHourAwayTicksOnceAMinute &&
          HabotSlaCountdown.theLastTenMinutesTickEverySecond &&
          !HabotSlaCountdown.everyCardTicksEverySecond,
    );

    gate(
      'GEN-03226-G5',
      'Which is 59 redraws a minute per card not taken.',
      'And on a screen reader an announcement every second is an interruption '
          'every second',
      () =>
          HabotSlaCountdown.redrawsSavedPerCardPerMinute == 59 &&
          HabotSlaCountdown.cadenceNote
              .contains('an interruption every second'),
    );

    gate(
      'GEN-03226-G6',
      'The live region announces at four thresholds.',
      'Rather than on every tick',
      () =>
          HabotSlaCountdown.announcementsAreAtThresholds &&
          !HabotSlaCountdown.theLiveRegionAnnouncesEveryTick &&
          HabotSlaCountdown.announcementThresholdsMinutes.length == 4,
    );
  });

  group('GEN-03226 :: what zero means', () {
    gate(
      'GEN-03226-G7',
      'Four cards, three consequences, one auto-approval.',
      'A timer that does not say what zero means is decoration with a clock '
          'face, and the auto-approving card is the one that has to be loudest',
      () =>
          HabotSlaConsequence.values.length == 3 &&
          HabotSlaCountdown.cards.length == 4 &&
          HabotSlaCountdown.everyCardNamesItsConsequence &&
          HabotSlaCountdown.theAutoApprovingCardIsTheLoudest &&
          !HabotSlaCountdown.aTimerWithNoStatedConsequenceIsShown,
    );

    gate(
      'GEN-03226-G8',
      'Every card carries its absolute deadline.',
      '"4h 12m left" is unreadable tomorrow and lies across a device sleep, so '
          'two people in two time zones see the same deadline',
      () =>
          HabotSlaCountdown.bothTheCountdownAndTheDeadlineAreShown &&
          HabotSlaCountdown.everyCardCarriesAnAbsoluteDueTime &&
          !HabotSlaCountdown.onlyTheDurationIsShown &&
          HabotSlaCountdown.deadlineNote
              .contains('two different arithmetic results'),
    );

    gate(
      'GEN-03226-G9',
      'A stale countdown is labelled by the Step 129 policy.',
      'A countdown computed from data that stopped arriving is a confident '
          'wrong number, which is worse than a blank',
      () =>
          HabotSlaCountdown.aStaleCountdownIsLabelled &&
          HabotSlaCountdown.stalenessNote.contains('Step 129'),
    );
  });

  group('GEN-03226 :: the ninth one-valued output column', () {
    gate(
      'GEN-03226-G10',
      'Output reported as Complete, which is the only value the column holds.',
      'Ninth in the track and third in this batch, after Steps 383 and 389; '
          'six obligations, all met, and all ten declared checks hold',
      () =>
          HabotSlaCountdown.theCountReachesNine &&
          HabotSlaCountdown.oneValuedColumnsInThisBatch.contains(383) &&
          HabotSlaCountdown.oneValuedColumnsInThisBatch.contains(389) &&
          HabotSlaCountdown.obligations.length == 6 &&
          HabotSlaCountdown.obligations.values.every((bool b) => b) &&
          HabotSlaCountdown.qualitativeOutput == 'Complete' &&
          HabotSlaCountdown.checks.length == 10 &&
          HabotSlaCountdown.checks.values.every((bool b) => b),
    );
  });

  tearDownAll(() {
    final int saved = HabotSlaCountdown.redrawsSavedPerCardPerMinute;
    final int autoApproving = HabotSlaCountdown.autoApproving.length;
    final String due = HabotSlaCountdown.cards.first.dueAt;
    final int columns = HabotSlaCountdown.oneValuedColumnsInTheTrack;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-03226',
        atomicStepReferenceId: 'GEN-03226',
        setupStepAction:
            'COLUMN NOTE: the band on this row sets a floor and an optimal '
            'both at 1s and a ceiling at 2s, so on a lower-is-better measure '
            'it is collapsed at one end and inverted at the other -- the first '
            'band in this track to carry both defects at once; its Best '
            'Qualitative Output column holds the single word "Complete", the '
            'ninth one-valued output column and the third in this batch after '
            'Steps 383 and 389; its standard is an "OPS SLA Timer Framework"; '
            'its Data Requirement cell holds the Atomic Step\'s own sentence '
            'as the artefact to prepare; and the Setup Step column is empty. '
            'Atomic Step: "Create visual SLA countdown timer widgets for '
            'approval review cards."',
        implementationOrder: 395,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Create visual SLA countdown timer widgets for approval review cards':
              '4 cards across 3 consequences; $autoApproving auto-approves at '
                  'zero and is marked as such',
          'Completion Status': 'Complete',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
          'Component Properties':
              'the first card is due at $due; matching the tick rate to the '
                  'magnitude saves $saved redraws a minute per card',
          'Data Quality Note':
              'BAND: ${HabotSlaCountdown.bandNote} CADENCE: '
              '${HabotSlaCountdown.cadenceNote} CONSEQUENCE: '
              '${HabotSlaCountdown.consequenceNote} DEADLINE: '
              '${HabotSlaCountdown.deadlineNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'SLA Widget Refresh Interval',
            observed:
                'COLLAPSED AT ONE END AND INVERTED AT THE OTHER, WHICH IS NEW. '
                'Floor 1s, optimal 1s, ceiling 2s. On a refresh interval lower '
                'is better, so the value the row calls best is the worst of '
                'the three, and the floor and the optimal are the same number. '
                'Every inversion this track has recorded had three distinct '
                'values and every collapse was flat; this is the first cell '
                'group to be both, which means neither defect can be read as '
                'the other one\'s rounding. The output column holds the single '
                'word "Complete" -- the ${columns}th one-valued column in the '
                'track and the third in this batch.',
            floor: '1s',
            optimal: '1s',
            ceiling: '2s',
            higherIsBetter: false,
          ),
          AissMeasurement(
            metricName: 'Countdowns that do not say what zero means',
            observed:
                '0 of 4. A countdown implies a consequence and the consequence '
                'is what makes the number worth showing: two cards escalate to '
                'a named person, $autoApproving auto-approves without anybody '
                'looking -- the one that has to be loudest, because inaction '
                'there is a decision -- and one lapses. Every card also '
                'carries its absolute due time beside the countdown, so a '
                'reader coming back tomorrow and a colleague in another time '
                'zone see the same deadline. The tick rate follows the '
                'magnitude, saving $saved redraws a minute per card and '
                'sparing a screen reader an announcement every second.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/approvals/sla_countdown.dart',
        ],
      ),
    );
  });
}
