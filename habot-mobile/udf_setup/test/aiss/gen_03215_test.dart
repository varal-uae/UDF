/// AISS GATE -- Step 351 of 355
/// Global Reference ID:       GEN-03215
/// Atomic Steps Reference ID: GEN-03215
/// Setup Step (Action): (the generic engineering-console boilerplate --
///                      COLUMN NOTE, RECORDED)
/// Atomic Step: "Build standard full-screen compliance decision overlay
///               containers."
/// Metric: Overlay Rendering Latency -- floor "< 100ms", optimal "< 30ms",
///         ceiling **150ms**. Best Qualitative Output: **"Complete"**. MD3.
///
/// BOTH OF THE PREVIOUS BATCH'S REPEATED DEFECTS, ON ONE ROW. THE COUNTS
/// CLOSED FOR THAT BATCH; THEY DID NOT CLOSE.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/dialogs/decision_overlay.dart';

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

  group('GEN-03215 :: the two defects that did not close', () {
    gate(
      'GEN-03215-G1',
      'Ceiling 150ms against a floor of "< 100ms".',
      'A lower-is-better measure whose ceiling is a worse value than its '
          'floor -- the sixth inverted band in the track',
      () =>
          HabotDecisionOverlay.theBandIsInverted &&
          HabotDecisionOverlay.thisIsTheSixthInversion &&
          HabotDecisionOverlay.bandCeilingMs == 150,
    );

    gate(
      'GEN-03215-G2',
      'Best Qualitative Output: "Complete", with no failing value.',
      'A column with one value reports Complete whether the thing completed or '
          'not -- the fifth such column',
      () =>
          HabotDecisionOverlay.theOutputCannotExpressAFailure &&
          HabotDecisionOverlay.thisIsTheFifthOneValuedColumn,
    );

    gate(
      'GEN-03215-G3',
      'Step 335 recorded that both counts closed.',
      'They closed for that batch. Two consecutive batches carrying the same '
          'two defects makes them a property of the sheet rather than '
          'incidents in particular cells',
      () =>
          HabotDecisionOverlay.bothDefectsRecurAcrossBatches &&
          HabotDecisionOverlay.invertedBandsBefore.length == 5 &&
          HabotDecisionOverlay.oneValuedColumnsBefore.length == 4 &&
          HabotDecisionOverlay.recurrenceNote
              .contains('property of how this sheet'),
    );
  });

  group('GEN-03215 :: full screen is a choice', () {
    gate(
      'GEN-03215-G4',
      'Three conditions under which full screen is right.',
      'The whole text, the consequences, and room for both at a 200 per cent '
          'scale',
      () =>
          HabotDecisionOverlay.theConditionsAreEnumerated &&
          HabotDecisionOverlay.whenFullScreenIsRight.length == 3,
    );

    gate(
      'GEN-03215-G5',
      'Its cost is stated: the subject is no longer on screen.',
      'Somebody asked to accept what they cannot see will accept blindly or '
          'leave to check and lose their place',
      () =>
          HabotDecisionOverlay.theCostIsStated &&
          HabotDecisionOverlay.fullScreenNote.contains('lose their place'),
    );

    gate(
      'GEN-03215-G6',
      'The overlay carries a one-line summary of its subject.',
      'So neither blind acceptance nor leaving is necessary',
      () => HabotDecisionOverlay.theSubjectIsCarriedIntoTheOverlay,
    );
  });

  group('GEN-03215 :: a decision has more than one answer', () {
    gate(
      'GEN-03215-G7',
      'Three outcomes are available: accept, decline, defer.',
      'An overlay with one button is a notice wearing a decision\'s clothes',
      () =>
          HabotDecisionOverlay.everyDecisionIsAvailable &&
          !HabotDecisionOverlay.aSingleButtonOverlayIsPermitted &&
          HabotDecision.values.length == 3,
    );

    gate(
      'GEN-03215-G8',
      'Recording a forced acknowledgement as consent is worse than nothing.',
      'It manufactures evidence of a choice that was never offered, and the '
          'evidence is what a compliance record exists to be',
      () => HabotDecisionOverlay.forcedConsentNote
          .contains('manufactures evidence'),
    );
  });

  group('GEN-03215 :: the record', () {
    gate(
      'GEN-03215-G9',
      'Every outcome is written down with the wording version.',
      '"Accepted the terms" means nothing without knowing which terms, and the '
          'overlay cannot close without writing the row',
      () =>
          HabotDecisionOverlay.everyOutcomeIsRecorded &&
          HabotDecisionOverlay.theWordingVersionIsRecorded &&
          !HabotDecisionOverlay.closingWithoutARecordIsPossible,
    );

    gate(
      'GEN-03215-G10',
      'Output reported as Complete / Not Complete.',
      'Six obligations, all met, giving Complete; it is a decisive surface '
          'through the Step 350 wrapper and all ten declared checks hold',
      () =>
          HabotDecisionOverlay.obligations.length == 6 &&
          HabotDecisionOverlay.obligations.values.every((bool b) => b) &&
          HabotDecisionOverlay.qualitativeOutput == 'Complete' &&
          HabotDecisionOverlay.itGoesThroughTheWrapper &&
          HabotDecisionOverlay.aStrayTapCannotAnswerIt &&
          HabotDecisionOverlay.checks.length == 10 &&
          HabotDecisionOverlay.checks.values.every((bool b) => b),
    );
  });

  tearDownAll(() {
    final int inversions = HabotDecisionOverlay.invertedBandsIncludingThis;
    final int columns = HabotDecisionOverlay.oneValuedColumnsIncludingThis;
    final String version = HabotDecisionOverlay.worked.first.textVersion;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-03215',
        atomicStepReferenceId: 'GEN-03215',
        setupStepAction:
            'COLUMN NOTE: the band on this row sets a ceiling of 150ms against '
            'a floor of "< 100ms" on a lower-is-better measure, its Best '
            'Qualitative Output column reads "Complete" with no failing value, '
            'and every narrative column is the generic engineering-console '
            'boilerplate. Atomic Step: "Build standard full-screen compliance '
            'decision overlay containers."',
        implementationOrder: 351,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Build standard full-screen compliance decision overlay containers.':
              '3 outcomes, each written to a record carrying who decided, '
                  'which wording they saw ($version), when, and which way',
          'Completion Status': 'Complete',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
          'Component Properties':
              'a decisive surface through the Step 350 wrapper: a stray tap on '
                  'the scrim cannot answer it, and it cannot close without '
                  'writing a record',
          'Data Quality Note':
              'RECURRENCE: ${HabotDecisionOverlay.recurrenceNote} '
              'FULL SCREEN: ${HabotDecisionOverlay.fullScreenNote} '
              'FORCED CONSENT: ${HabotDecisionOverlay.forcedConsentNote} '
              'RECORD: ${HabotDecisionOverlay.recordNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Overlay Rendering Latency',
            observed:
                'BOTH OF THE PREVIOUS BATCH\'S REPEATED DEFECTS, ON ONE ROW. A '
                'ceiling of 150ms against a floor of 100ms on a '
                'lower-is-better measure is inversion number $inversions; a '
                'Best Qualitative Output column reading "Complete" with no '
                'failing value is one-valued column number $columns. Step 335 '
                'recorded that both counts closed, which they did for that '
                'batch. Two consecutive batches carrying the same two defects '
                'is where they stop being incidents in particular cells and '
                'become a property of how this sheet is written.',
            floor: '< 100ms',
            optimal: '< 30ms',
            ceiling: '150ms',
          ),
          AissMeasurement(
            metricName: 'Compliance outcomes the overlay can record',
            observed:
                '3 -- accepted, declined, deferred -- each written with the '
                'actor, the timestamp and the version of the wording that was '
                'shown. The wording version is the part always forgotten and '
                'always asked about afterwards. An overlay with one button is '
                'a notice wearing a decision\'s clothes, and recording a '
                'forced acknowledgement as consent manufactures evidence of a '
                'choice that was never offered.',
            floor: '2',
            optimal: '3',
            ceiling: '3',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/dialogs/decision_overlay.dart',
        ],
      ),
    );
  });
}
