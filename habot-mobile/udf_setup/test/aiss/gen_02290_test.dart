/// AISS GATE -- Step 238 of 255
/// Global Reference ID:       GEN-02290
/// Atomic Steps Reference ID: GEN-02290
/// Setup Step (Action): (EMPTY on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Apply the defined Regex masks to the mobile text input
///               components."
/// Metric: Data Validation Pass Rate (%) -- Floor 0.95, Optimal 0.999,
///         Ceiling 1. Pass/Fail. Standard cited: ISO/IEC 27001, OWASP Input
///         Validation.
///
/// THREE OF THIRTEEN DECLARED FIELDS CANNOT BE TYPED INTO A STATE THEIR OWN
/// VALIDATOR ACCEPTS. Applying the declared masks -- which is exactly what
/// this row asks for -- is the thing that breaks them. REPORTS FAIL.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/forms/field_validation.dart';
import 'package:udf_setup/design_system/forms/mask_binding.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  double declared = 0;
  double corrected = 0;

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

  group('GEN-02290 :: the defect', () {
    gate(
      'GEN-02290-G1',
      'Atomic Step: "APPLY the defined Regex masks to the input components."',
      'ValidatedInputField wires rule.formatters, which is '
          'HabotMask.formattersFor(rule.mask), so the mask is a character '
          'filter over what may be typed while the pattern is a whole-value '
          'test -- and three fields have a mask that filters out a character '
          'their own pattern requires',
      () =>
          HabotMaskBinding.unfillableFields.length == 3 &&
          HabotMaskBinding.maskIsNotAValidatorNote.contains('rule.formatters'),
    );

    gate(
      'GEN-02290-G2',
      'A date field that eats the separator cannot ever validate.',
      'dateIso needs a hyphen and is masked decimal, dateUs needs a slash and '
          'is masked numeric, timeOfDay needs a colon and is masked numeric -- '
          'one blocked character each, named rather than counted',
      () {
        final HabotMaskAgreement iso =
            HabotMaskBinding.agreementFor(HabotCde.dateIso);
        final HabotMaskAgreement us =
            HabotMaskBinding.agreementFor(HabotCde.dateUs);
        final HabotMaskAgreement time =
            HabotMaskBinding.agreementFor(HabotCde.timeOfDay);
        return iso.blockedSeparators.single == '-' &&
            us.blockedSeparators.single == '/' &&
            time.blockedSeparators.single == ':' &&
            !iso.isReachableByTyping &&
            !us.isReachableByTyping &&
            !time.isReachableByTyping;
      },
    );

    gate(
      'GEN-02290-G3',
      'The separator scan must not fire on quantifiers or character classes.',
      'Ten of the thirteen fields agree, including the four whose patterns '
          'contain a hyphen or a dot inside a character class and the two '
          'whose literal separators their mask already allows -- so the scan '
          'finds three, not eight',
      () =>
          HabotMaskBinding.agreements.length == 13 &&
          HabotMaskBinding.agreements
                  .where((HabotMaskAgreement a) => a.agrees)
                  .length ==
              10 &&
          HabotMaskBinding.agreementFor(HabotCde.emailAddress)
              .requiredSeparators
              .contains('@') &&
          HabotMaskBinding.agreementFor(HabotCde.emailAddress).agrees &&
          HabotMaskBinding.agreementFor(HabotCde.personName)
              .requiredSeparators
              .isEmpty,
    );

    gate(
      'GEN-02290-G4',
      'The mask and the pattern disagree in both directions.',
      'accountNumber is masked to allow a space and patterned to reject one, '
          'so an IBAN written the way every bank prints it types cleanly and '
          'fails validation -- which is the half Step 243 normalises rather '
          'than widens',
      () =>
          HabotMaskBinding.theMaskAndPatternDisagreeBothWays &&
          HabotMaskBinding.groupedAccountNumberTypesCleanly &&
          HabotMaskBinding.groupedAccountNumberFailsItsPattern,
    );
  });

  group('GEN-02290 :: the correction, and the metric', () {
    gate(
      'GEN-02290-G5',
      'Step 179: two copies of a rule with one of them executed.',
      'The correction is derived from each field\'s own declared pattern '
          'rather than from a hand-written table, so this file holds no second '
          'copy of any rule -- and it widens nothing that was not required',
      () =>
          HabotMaskBinding.correctionMakesEveryFieldReachable &&
          HabotMaskBinding.correctionIsMinimal &&
          HabotMaskBinding.derivedNotRestatedNote.contains('no second copy'),
    );

    gate(
      'GEN-02290-G6',
      'Metric: Data Validation Pass Rate -- floor 0.95.',
      'The declared binding measures 0.769, below the row\'s own floor, and '
          'the corrected binding measures 1.0; both are published rather than '
          'the corpus chosen to make one of them true',
      () {
        declared = HabotMaskBinding.maskPatternAgreementRate;
        corrected = HabotMaskBinding.correctedAgreementRate;
        return (declared - 10 / 13).abs() < 1e-9 &&
            declared < HabotMaskBinding.floor &&
            corrected == 1.0;
      },
    );

    gate(
      'GEN-02290-G7',
      'Data Validation Pass Rate -- Pass/Fail.',
      'All nine checks hold and the step reports FAIL on the binding as it '
          'stands, because reporting Pass would mean reporting on code that is '
          'not wired in -- the correction is built, tested and named as a '
          'one-line adoption in another step\'s file',
      () =>
          HabotMaskBinding.checks.length == 9 &&
          HabotMaskBinding.checks.values.every((bool b) => b) &&
          HabotMaskBinding.qualitativeOutput == 'Fail' &&
          HabotMaskBinding.qualitativeOutputAfterCorrection == 'Pass' &&
          HabotMaskBinding.adoptionNote.contains('one-line change') &&
          HabotMaskBinding.columnNote.contains('EMPTY'),
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-02290',
        atomicStepReferenceId: 'GEN-02290',
        setupStepAction:
            'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic '
            'Step: "Apply the defined Regex masks to the mobile text input '
            'components."',
        implementationOrder: 238,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotMaskBinding / HabotMaskAgreement',
          'Component Properties':
              '${HabotMaskBinding.agreements.length} declared fields '
              'analysed, ${HabotMaskBinding.unfillableFields.length} of them '
              'unfillable; a corrected formatter stack derived from each '
              'field\'s own pattern; '
              '${HabotMaskBinding.recognisedSeparators.length} separator '
              'characters recognised by a scan that ignores character classes '
              'and quantifiers',
          'Completion Status': 'FAIL on the declared binding -- see note',
          'Data Quality Note':
              'FINDING: ${HabotMaskBinding.unfillableNote} CONTEXT: '
              '${HabotMaskBinding.maskIsNotAValidatorNote} SECOND DIRECTION: '
              'accountNumber is masked alphanumeric, which allows a space, '
              'and patterned to reject one -- so an IBAN written the way '
              'every bank prints it types cleanly and fails validation. Step '
              '243 normalises before validating rather than widening the '
              'pattern, because the groups are presentation. METHOD: '
              '${HabotMaskBinding.derivedNotRestatedNote} ADOPTION: '
              '${HabotMaskBinding.adoptionNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Data Validation Pass Rate (%)',
            observed:
                '${declared.toStringAsFixed(3)} over the '
                '${HabotMaskBinding.agreements.length} declared fields -- ten '
                'agree and three cannot be typed into a state their own '
                'validator accepts. Below the row\'s floor of '
                '${HabotMaskBinding.floor}. With the derived correction '
                'adopted the same measurement is '
                '${corrected.toStringAsFixed(1)}.',
            floor: '0.95',
            optimal: '0.999',
            ceiling: '1',
          ),
          AissMeasurement(
            metricName: 'Fields whose error message cannot be acted on',
            observed:
                '${HabotMaskBinding.unfillableFields.length} of '
                '${HabotMaskBinding.agreements.length}. The dateUs message '
                'says to enter a date as MM/DD/YYYY and the field deletes the '
                'slash. Step 250 measures the same defect from the '
                'error-recovery side and reports Low.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/forms/mask_binding.dart',
        ],
      ),
    );
  });
}
