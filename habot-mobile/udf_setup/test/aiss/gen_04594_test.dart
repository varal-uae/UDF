/// AISS GATE -- Step 267 of 275
/// Global Reference ID:       GEN-04594
/// Atomic Steps Reference ID: GEN-04594
/// Setup Step (Action): (EMPTY on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Implement secure field components masking displayed
///               sensitive values (e.g. account numbers)."
/// Metric: PII Leakage Incident Rate -- Floor "0 incidents (hard gate)",
///         Optimal "0 incidents", Ceiling 1. Pass/Fail.
///
/// MASKING FOR DISPLAY IS NOT MASKING. THE VALUE IS STILL IN FOUR OTHER
/// PLACES, AND THREE OF THEM ARE WHERE IT ACTUALLY LEAKS.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/forms/secure_field_display.dart';

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

  group('GEN-04594 :: what is drawn', () {
    gate(
      'GEN-04594-G1',
      'Atomic Step: "masking displayed sensitive values".',
      'Only the last four characters are drawn, the rest are bullets built '
          'from a code point rather than pasted, and the masked string keeps '
          'the original length so nothing about it reads as shorter',
      () =>
          HabotSecureFieldDisplay.theTailIsTheOnlyThingVisible &&
          HabotSecureFieldDisplay.visibleTailLength == 4 &&
          HabotSecureFieldDisplay.maskCharacter.length == 1,
    );

    gate(
      'GEN-04594-G2',
      'A four-digit code masked to four visible characters is not masked.',
      'A value no longer than the visible tail is hidden entirely and '
          'announced as hidden, rather than shown in full by arithmetic',
      () => HabotSecureFieldDisplay.aShortValueIsNotAccidentallyRevealed,
    );

    gate(
      'GEN-04594-G3',
      'A screen reader reads what is there.',
      'The announcement is the meaning rather than the glyphs -- "Account '
          'ending 3456" -- so a person using a reader is not given the last '
          'four digits preceded by nineteen bullets',
      () =>
          HabotSecureFieldDisplay.theAnnouncementIsNotTheGlyphs &&
          HabotSecureFieldDisplay.screenReaderNote.contains('slower way of '
              'saying'),
    );
  });

  group('GEN-04594 :: the four other places the value is', () {
    gate(
      'GEN-04594-G4',
      'Masking for display leaves memory, the snapshot and the clipboard.',
      'Five surfaces are ruled on with a reason each, three of them see '
          'nothing at all, and exactly one sees the whole value -- the one '
          'that has to',
      () =>
          HabotSecureFieldDisplay.everySurfaceIsRuledOn &&
          HabotSecureFieldDisplay.policies.length == 5 &&
          HabotSecureFieldDisplay.surfacesThatSeeNothing.length == 3 &&
          HabotSecureFieldDisplay.onlyMemorySeesTheWholeValue &&
          HabotSecureFieldDisplay.maskingIsNotMaskingNote.contains('out of '
              'sight and nowhere else'),
    );

    gate(
      'GEN-04594-G5',
      'The OS photographs the screen when the app is backgrounded.',
      'A revealed value cannot stay revealed into the background, and the '
          'app-switcher snapshot and the clipboard are both ruled to see '
          'nothing',
      () =>
          HabotSecureFieldDisplay.aBackgroundedFieldCannotBeRevealed &&
          HabotSecureFieldDisplay.policyFor(
                HabotExposureSurface.appSwitcherSnapshot,
              ).rule ==
              HabotExposureRule.none &&
          HabotSecureFieldDisplay.policyFor(
                HabotExposureSurface.clipboard,
              ).rule ==
              HabotExposureRule.none,
    );

    gate(
      'GEN-04594-G6',
      'Revealing has to be deliberate, and it has to be recorded.',
      'A reveal requires an explicit request, times out on a declared token, '
          'and emits an event carrying the field and the fact and no value',
      () =>
          HabotSecureFieldDisplay.mayReveal(
            personRequestedIt: true,
            isBackgrounded: false,
          ) &&
          !HabotSecureFieldDisplay.mayReveal(
            personRequestedIt: false,
            isBackgrounded: false,
          ) &&
          HabotSecureFieldDisplay.theRevealEventCarriesNoValue &&
          HabotSecureFieldDisplay.revealTimeout.inSeconds > 0 &&
          HabotSecureFieldDisplay.revealNote.contains('second copy'),
    );

    gate(
      'GEN-04594-G7',
      'Metric: floor and optimal "0 incidents", ceiling 1.',
      'The band is inverted -- one leakage incident would be its best case '
          'read the way the other bands in this sheet are read -- and that is '
          'recorded so nobody builds toward the ceiling',
      () =>
          HabotSecureFieldDisplay.floorIncidents == 0 &&
          HabotSecureFieldDisplay.optimalIncidents == 0 &&
          HabotSecureFieldDisplay.ceilingIncidents == 1 &&
          HabotSecureFieldDisplay.theBandIsInverted &&
          HabotSecureFieldDisplay.bandNote.contains('worst case'),
    );

    gate(
      'GEN-04594-G8',
      'Output: Pass/Fail.',
      'All nine declared checks hold and the step reports Pass on the five '
          'ruled surfaces rather than on the one the row mentions',
      () =>
          HabotSecureFieldDisplay.checks.length == 9 &&
          HabotSecureFieldDisplay.checks.values.every((bool b) => b) &&
          HabotSecureFieldDisplay.qualitativeOutput == 'Pass' &&
          HabotSecureFieldDisplay.columnNote.contains('EMPTY'),
    );
  });

  tearDownAll(() {
    final String surfaces = '${HabotSecureFieldDisplay.policies.length}';
    final String blind =
        '${HabotSecureFieldDisplay.surfacesThatSeeNothing.length}';
    final String tail = '${HabotSecureFieldDisplay.visibleTailLength}';
    final String timeout =
        '${HabotSecureFieldDisplay.revealTimeout.inSeconds}s';
    final String example = HabotSecureFieldDisplay.announcementFor(
      label: 'Account',
      value: 'AE070331234567890123456',
    );

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-04594',
        atomicStepReferenceId: 'GEN-04594',
        setupStepAction:
            'COLUMN NOTE: Setup Step (Action) is EMPTY on this row, and the '
            'band reads floor "0 incidents (hard gate)", optimal "0 '
            'incidents", ceiling "1". Atomic Step: "Implement secure field '
            'components masking displayed sensitive values (e.g. account '
            'numbers)."',
        implementationOrder: 267,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name':
              'HabotSecureFieldDisplay / HabotExposureSurface / '
                  'HabotExposurePolicy',
          'Component Properties':
              '$surfaces exposure surfaces, $blind of them ruled to see '
              'nothing and exactly one to see the whole value; $tail '
              'characters of tail drawn; announcement "$example"; reveal is '
              'explicit, times out after $timeout, re-masks on backgrounding '
              'and emits no value',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'FINDING: ${HabotSecureFieldDisplay.maskingIsNotMaskingNote} '
              'READER: ${HabotSecureFieldDisplay.screenReaderNote} '
              'BAND: ${HabotSecureFieldDisplay.bandNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'PII Leakage Incident Rate',
            observed:
                'NOT A RATE MEASURABLE HERE -- an incident is an event in the '
                'world. Substituted: of $surfaces surfaces an unmasked value '
                'can reach, $blind are ruled to see nothing and one sees the '
                'whole value because something has to hold it to send it. '
                'The ceiling of 1 is recorded as the worst case rather than '
                'as a target.',
            floor: '0 incidents (hard gate)',
            optimal: '0 incidents',
            ceiling: '1',
            higherIsBetter: false,
          ),
          AissMeasurement(
            metricName: 'Characters of the value the display shows',
            observed:
                '$tail, the last four, which is enough for a person to '
                'recognise their own account and not enough for anybody else '
                'to use it. A value shorter than that is hidden entirely.',
            floor: '4',
            optimal: '4',
            ceiling: '4',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/forms/secure_field_display.dart',
        ],
      ),
    );
  });
}
