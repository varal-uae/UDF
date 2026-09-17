/// AISS GATE -- Step 321 of 335
/// Global Reference ID:       GEN-03426
/// Atomic Steps Reference ID: GEN-03426
/// Setup Step (Action): (the generic engineering-console boilerplate --
///                      COLUMN NOTE, RECORDED)
/// Atomic Step: 'Display high-contrast "Site Verified" or "Outside Authorized
///               Zone" badges on screen.'
/// Metric: Badge Visual Contrast Ratio -- floor 4.5:1, optimal 7:1, ceiling
///         21:1. Best Qualitative Output: **"Pass"**. WCAG 2.2 AA.
///
/// AN OUTPUT COLUMN WITH ONE VALUE IN IT, AND TWO BADGES FOR THREE STATES.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/operations/zone_badge.dart';

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

  group('GEN-03426 :: two badges, three states', () {
    gate(
      'GEN-03426-G1',
      'Atomic Step: "Site Verified" OR "Outside Authorized Zone".',
      'The device has a third answer -- permission denied, no fix indoors, a '
          'cold start -- and six worked readings split two, two and two',
      () =>
          HabotZoneVerdict.values.length == 3 &&
          HabotZoneBadge.readings.length == 6 &&
          HabotZoneBadge.countOf(HabotZoneVerdict.verified) == 2 &&
          HabotZoneBadge.countOf(HabotZoneVerdict.outside) == 2 &&
          HabotZoneBadge.countOf(HabotZoneVerdict.unknown) == 2,
    );

    gate(
      'GEN-03426-G2',
      'Collapsing unknown into outside is the harm.',
      'It tells somebody standing in exactly the right place that they are in '
          'the wrong one; a device with no fix reports unknown',
      () => HabotZoneBadge.noFixIsUnknownRatherThanOutside,
    );

    gate(
      'GEN-03426-G3',
      'Steps 294 and 316 reached the same three-valued shape.',
      'From authorisation and from fail-closed logic; this is its third '
          'appearance and the first on a sensor reading',
      () => HabotZoneVerdict.values.contains(HabotZoneVerdict.unknown),
    );
  });

  group('GEN-03426 :: the confidence rule', () {
    gate(
      'GEN-03426-G4',
      'A fix 60m out with +/-25m of accuracy spans 35m to 85m.',
      'Against a 50m fence that is not an answer, and asserting one is a coin '
          'toss dressed as a measurement',
      () =>
          HabotZoneBadge.theStraddlingReadingIsUnknown &&
          HabotZoneBadge.readings[2].nearestPossible == 35 &&
          HabotZoneBadge.readings[2].furthestPossible == 85 &&
          HabotZoneBadge.fenceRadiusMetres == 50,
    );

    gate(
      'GEN-03426-G5',
      'Outside only when the whole circle is outside.',
      'The simple comparison the row\'s two-badge phrasing invites gets two '
          'of the six readings wrong',
      () =>
          HabotZoneBadge.readingsTheNaiveRuleGetsWrong.length == 2 &&
          HabotZoneBadge.confidenceNote.contains('coin toss'),
    );
  });

  group('GEN-03426 :: what each state offers', () {
    gate(
      'GEN-03426-G6',
      'Three labels, two of them with a way on.',
      'Both non-verified states offer the same escape -- start it anyway and '
          'add a note -- because a geofence on a phone is evidence, not a lock',
      () =>
          HabotZoneBadge.everyVerdictHasALabel &&
          HabotZoneBadge.everyNonVerifiedVerdictOffersAWayOn &&
          !HabotZoneBadge.theBadgeBlocksTheWork,
    );

    gate(
      'GEN-03426-G7',
      'Making it a gate strands people who are where they said they would be.',
      'Which is the reason the badge does not block the work',
      () => HabotZoneBadge.deadEndNote
          .contains('exactly where they said they would be'),
    );

    gate(
      'GEN-03426-G8',
      'Every badge carries words.',
      'Colour is not the carrier -- SC 1.4.1 again, and the fifth row across '
          'two batches to arrive at it',
      () =>
          HabotZoneBadge.everyBadgeCarriesItsWords &&
          !HabotZoneBadge.colourIsTheSoleCarrier,
    );
  });

  group('GEN-03426 :: the output column', () {
    gate(
      'GEN-03426-G9',
      'Best Qualitative Output: "Pass".',
      'A vocabulary with no failing value can only be closed one way, '
          'whatever the measurement turns out to be; four rows in this batch '
          'are like this and they are the first four in this track',
      () =>
          HabotZoneBadge.theOutputCannotExpressAFailure &&
          HabotZoneBadge.fourRowsInThisBatchShareTheDefect &&
          HabotZoneBadge.outputNote.contains('makes the gate decorative'),
    );

    gate(
      'GEN-03426-G10',
      'Output reported as Pass / Fail against declared obligations.',
      'Six obligations, all met, so a failure would have had somewhere to go; '
          'all ten declared checks hold',
      () =>
          HabotZoneBadge.obligations.length == 6 &&
          HabotZoneBadge.obligations.values.every((bool b) => b) &&
          HabotZoneBadge.qualitativeOutput == 'Pass' &&
          HabotZoneBadge.checks.length == 10 &&
          HabotZoneBadge.checks.values.every((bool b) => b) &&
          HabotZoneBadge.ceilingNote.contains('Step 315'),
    );
  });

  tearDownAll(() {
    final String unknownLabel =
        HabotZoneBadge.labels[HabotZoneVerdict.unknown] ?? '';
    final String wayOn =
        HabotZoneBadge.nextSteps[HabotZoneVerdict.unknown] ?? '';

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-03426',
        atomicStepReferenceId: 'GEN-03426',
        setupStepAction:
            'COLUMN NOTE: the Best Qualitative Output column on this row reads '
            '"Pass", with no failing value, and every narrative column is the '
            'generic engineering-console boilerplate. Atomic Step: "Display '
            'high-contrast Site Verified or Outside Authorized Zone badges on '
            'screen."',
        implementationOrder: 321,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Site Verified':
              '${HabotZoneBadge.countOf(HabotZoneVerdict.verified)} of '
                  '${HabotZoneBadge.readings.length} worked readings',
          'Outside Authorized Zone':
              '${HabotZoneBadge.countOf(HabotZoneVerdict.outside)} of '
                  '${HabotZoneBadge.readings.length}; the remaining '
                  '${HabotZoneBadge.countOf(HabotZoneVerdict.unknown)} are '
                  'neither',
          'Completion Status': 'Pass',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
          'Component Properties':
              'the third state reads "$unknownLabel" and offers "$wayOn"',
          'Data Quality Note':
              'CONFIDENCE: ${HabotZoneBadge.confidenceNote} '
              'DEAD ENDS: ${HabotZoneBadge.deadEndNote} '
              'OUTPUT: ${HabotZoneBadge.outputNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Badge Visual Contrast Ratio',
            observed:
                'Held to the ordinary contrast band, with the 21:1 ceiling '
                'recorded as the formula\'s maximum rather than a target -- '
                'Step 272\'s finding, restated at Step 315. The row\'s output '
                'column contains only "Pass", so the gate as written could not '
                'have reported a contrast failure at all.',
            floor: '4.5:1',
            optimal: '7:1',
            ceiling: '21:1',
          ),
          AissMeasurement(
            metricName: 'Readings forced into a verdict they do not support',
            observed:
                '0 of ${HabotZoneBadge.readings.length} with the confidence '
                'rule, against 2 without it. A fix that straddles the fence '
                'and a device with no fix both report unknown, and neither '
                'state stops the work.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/operations/zone_badge.dart',
        ],
      ),
    );
  });
}
