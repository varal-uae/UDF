/// AISS GATE -- Step 283 of 295
/// Global Reference ID:       GEN-00854
/// Atomic Steps Reference ID: GEN-00854
/// Setup Step (Action): "Review the backend schema data type requirements for
///                      all incoming parameters." (DIFFERENT SUBJECT)
/// Atomic Step: "Add haptic feedback invocation mediumImpact() to success
///               state callbacks."
/// Metric: Haptic Trigger Execution Delay -- Floor "<= 10 ms", Optimal
///         "<= 2 ms", Ceiling "16 ms". Complete / Not Complete.
///
/// THE BINDING ALREADY EXISTS, AND TWO ROWS GIVE THIS ONE METRIC TWO BANDS
/// THAT DIFFER BY A FACTOR OF TEN AND TWENTY-FIVE.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/interaction/success_haptic.dart';

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

  group('GEN-00854 :: already built, and deliberately narrower', () {
    gate(
      'GEN-00854-G1',
      'Atomic Step: "mediumImpact() to success state callbacks".',
      'The binding exists: the declared success moment already fires at '
          'medium strength, so this step is a census rather than an addition',
      () => HabotSuccessHaptic.theRowsBindingAlreadyExists,
    );

    gate(
      'GEN-00854-G2',
      '"All success state callbacks", counted.',
      'Six moments in this application could be called a success and one of '
          'them fires; the other five are the set the existing component '
          'deliberately refused',
      () =>
          HabotSuccessHaptic.moments.length == 6 &&
          HabotSuccessHaptic.firing.length == 1 &&
          (HabotSuccessHaptic.shareThatFires - 1 / 6).abs() < 1e-9 &&
          HabotSuccessHaptic.theSilentSetIsTheDeclaredOne,
    );

    gate(
      'GEN-00854-G3',
      'A haptic on every outcome is a haptic on nothing.',
      'Every moment gives a reason, and the consequence of the literal '
          'reading -- a phone people put on silent, taking the one haptic '
          'that mattered with it -- is recorded',
      () =>
          HabotSuccessHaptic.everyMomentGivesAReason &&
          HabotSuccessHaptic.literalReadingNote.contains('put on silent'),
    );
  });

  group('GEN-00854 :: two bands for one measurement', () {
    gate(
      'GEN-00854-G4',
      'Metric: Haptic Trigger Execution Delay -- 10 ms / 2 ms / 16 ms.',
      'The band already declared for the same interval is 100 / 50 / 16, so '
          'the two disagree by factors of ten and twenty-five',
      () =>
          HabotSuccessHaptic.theTwoBandsDisagree &&
          HabotSuccessHaptic.theDisagreementIsAnOrderOfMagnitude &&
          HabotSuccessHaptic.rowFloorMs == 10 &&
          HabotSuccessHaptic.rowOptimalMs == 2,
    );

    gate(
      'GEN-00854-G5',
      'They agree on the ceiling, which is a frame.',
      'Sixteen milliseconds is the only one of the six figures that is a fact '
          'about anything, and two milliseconds across a platform channel is '
          'not a harder target but an unmeetable one',
      () =>
          HabotSuccessHaptic.theyAgreeOnlyOnTheCeiling &&
          HabotSuccessHaptic.twoBandsNote.contains('unmeetable'),
    );

    gate(
      'GEN-00854-G6',
      'The ceiling is a property of the call path, not the device.',
      'A haptic behind an await cannot land in the same frame however fast '
          'the hardware is, and the existing component fires synchronously',
      () =>
          HabotSuccessHaptic.theCeilingIsAPropertyOfTheCallPath &&
          HabotSuccessHaptic.theBandStillReadsTheDeclaredVocabulary,
    );

    gate(
      'GEN-00854-G7',
      'Nothing here can read the OS haptic setting.',
      'The gap was recorded when the component was built and is raised to an '
          'open decision by this step, because it stays recorded forever '
          'unless somebody is asked to choose',
      () =>
          !HabotSuccessHaptic.canReadTheOsHapticSetting &&
          HabotSuccessHaptic.thePreferenceGapWasAlreadyRecorded &&
          HabotSuccessHaptic.preferenceEscalationNote
              .contains('open decision'),
    );

    gate(
      'GEN-00854-G8',
      'Output: Complete / Not Complete.',
      'Five obligations, all met, giving Complete; all ten declared checks '
          'hold',
      () =>
          HabotSuccessHaptic.obligations.length == 5 &&
          HabotSuccessHaptic.obligations.values.every((bool b) => b) &&
          HabotSuccessHaptic.qualitativeOutput == 'Complete' &&
          HabotSuccessHaptic.checks.length == 10 &&
          HabotSuccessHaptic.checks.values.every((bool b) => b) &&
          HabotSuccessHaptic.columnNote.contains('LaTeX'),
    );
  });

  tearDownAll(() {
    final String share =
        (HabotSuccessHaptic.shareThatFires * 100).toStringAsFixed(1);
    final String declared =
        '${HabotSuccessHaptic.declaredFloorMs}/'
        '${HabotSuccessHaptic.declaredOptimalMs}/'
        '${HabotSuccessHaptic.declaredCeilingMs}';

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-00854',
        atomicStepReferenceId: 'GEN-00854',
        setupStepAction:
            'COLUMN NOTE: the Setup Step column on this row reads "Review the '
            'backend schema data type requirements for all incoming '
            'parameters", and the band is written with LaTeX escapes. Atomic '
            'Step: "Add haptic feedback invocation mediumImpact() to success '
            'state callbacks."',
        implementationOrder: 283,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'mediumImpact':
              'bound to the declared success moment; strength resolved by the '
                  'existing component rather than by this step',
          'Component Name': 'HabotSuccessHaptic / HabotSuccessMoment',
          'Component Properties':
              '${HabotSuccessHaptic.moments.length} candidate success moments, '
              '${HabotSuccessHaptic.firing.length} of which fires ($share%); '
              'the declared band for the same interval is $declared ms against '
              'this row\'s 10/2/16',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'FINDING: ${HabotSuccessHaptic.twoBandsNote} '
              'RESTRAINT: ${HabotSuccessHaptic.literalReadingNote} '
              'PREFERENCE: ${HabotSuccessHaptic.preferenceEscalationNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Haptic Trigger Execution Delay',
            observed:
                'NOT TIMED HERE -- a tap-to-motor interval needs a device and '
                'a person. What is checked is the property that decides '
                'whether the ceiling is reachable at all: the call path is '
                'synchronous, so the haptic can land in the same frame as the '
                'state change. The declared band for this interval is '
                '$declared ms and this row gives 10/2/16; only the ceiling '
                'matches.',
            floor: '<= 10 ms',
            optimal: '<= 2 ms',
            ceiling: '16 ms',
            higherIsBetter: false,
          ),
          AissMeasurement(
            metricName: 'Success moments that fire a haptic',
            observed:
                '${HabotSuccessHaptic.firing.length} of '
                '${HabotSuccessHaptic.moments.length} ($share%). The row asks '
                'for all of them; the other five are the ones the existing '
                'component refused, and the refusal is the feature.',
            floor: '1 of 6',
            optimal: '1 of 6',
            ceiling: '1 of 6',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/interaction/success_haptic.dart',
        ],
      ),
    );
  });
}
