/// AISS GATE -- Step 243 of 255
/// Global Reference ID:       GEN-03393
/// Atomic Steps Reference ID: GEN-03393
/// Setup Step (Action): (EMPTY on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Confirm 100% validation accuracy across typed IBAN input test
///               suites."
/// Metric: IBAN Input Validation Accuracy -- Floor 1, Optimal 1, Ceiling 1.
///         Pass. Standard cited: ISO 13616.
///
/// A REGULAR EXPRESSION CANNOT VALIDATE AN IBAN. Structure alone classifies
/// five of ten; adding the registry and length reaches eight; only mod-97
/// reaches ten, and the two it adds are the two errors people make.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/forms/iban_validator.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  double full = 0;
  double structural = 0;
  double registry = 0;

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

  group('GEN-03393 :: the arithmetic', () {
    gate(
      'GEN-03393-G1',
      'ISO 13616: move the first four characters to the end, map letters to '
          'numbers, take the whole thing mod 97.',
      'Every valid vector leaves a remainder of one and every invalid one does '
          'not -- computed a character at a time so no intermediate value '
          'exceeds a machine integer, which is what a twenty-nine digit IBAN '
          'would otherwise require',
      () =>
          HabotIbanValidator.mod97Of('AE070331234567890123456') == 1 &&
          HabotIbanValidator.mod97Of('GB82WEST12345698765432') == 1 &&
          HabotIbanValidator.mod97Of('DE89370400440532013000') == 1 &&
          HabotIbanValidator.mod97Of('AE070331235467890123456') != 1 &&
          HabotIbanValidator.mod97Of('AE070331334567890123456') != 1,
    );

    gate(
      'GEN-03393-G2',
      'Metric: floor, optimal and ceiling are all 1, so only a perfect '
          'classifier passes.',
      'Every one of the ten vectors reaches the verdict it was chosen to '
          'reach, and the five verdicts are all exercised -- valid, bad '
          'structure, unknown country, wrong length and a failed check digit',
      () =>
          HabotIbanValidator.suiteIsFullyClassified &&
          HabotIbanValidator.suite.length == 10 &&
          HabotIbanValidator.suite
                  .map((HabotIbanCase c) => c.expected)
                  .toSet()
                  .length ==
              HabotIbanVerdict.values.length,
    );

    gate(
      'GEN-03393-G3',
      '"The pattern says what an IBAN looks like; mod-97 says whether it is '
          'one."',
      'Structure alone classifies five of ten and adding the country registry '
          'and its length reaches eight -- both short of the row\'s floor, and '
          'both measured rather than asserted',
      () {
        structural = HabotIbanValidator.structureOnlyAccuracy;
        registry = HabotIbanValidator.structureAndRegistryAccuracy;
        return (structural - 0.5).abs() < 1e-9 &&
            (registry - 0.8).abs() < 1e-9 &&
            registry < HabotIbanValidator.floor;
      },
    );

    gate(
      'GEN-03393-G4',
      'Transposition is the commonest typing error there is.',
      'The two vectors only the checksum catches are a transposed pair of '
          'digits and a single mistyped digit -- both structurally perfect, '
          'both the right country and the right length',
      () =>
          HabotIbanValidator.caughtOnlyByTheChecksum.length == 2 &&
          HabotIbanValidator.theChecksumIsWhatMakesItOne &&
          HabotIbanValidator.validate('AE070331235467890123456') ==
              HabotIbanVerdict.checksumFailed &&
          HabotIbanValidator.validate('AE070331334567890123456') ==
              HabotIbanVerdict.checksumFailed,
    );
  });

  group('GEN-03393 :: grouping, case and the registry', () {
    gate(
      'GEN-03393-G5',
      'Step 238: accountNumber is masked to allow a space and patterned to '
          'reject one.',
      'The conventional grouped form validates, because normalisation strips '
          'the groups before anything is judged -- the fix is normalising '
          'rather than widening the pattern, since the groups are how an IBAN '
          'is written and not part of what it is',
      () =>
          HabotIbanValidator.groupedFormValidates &&
          HabotIbanValidator.groupingSurvivesNormalisation &&
          HabotIbanValidator.groupingNote.contains('in the wrong places'),
    );

    gate(
      'GEN-03393-G6',
      'A person typing on a phone gets a lower-case first letter.',
      'A lower-cased IBAN validates, and an unrecognised country is reported '
          'as unknown rather than invalid -- because a client registry that '
          'goes stale starts rejecting valid accounts and those are different '
          'facts',
      () =>
          HabotIbanValidator.lowerCaseSurvivesNormalisation &&
          HabotIbanValidator.validate('XX0700000000000000000000') ==
              HabotIbanVerdict.unknownCountry &&
          HabotIbanValidator.countries.length == 6 &&
          HabotIbanValidator.countryFor('AE')!.length == 23 &&
          HabotIbanValidator.registryNote.contains('goes stale'),
    );

    gate(
      'GEN-03393-G7',
      'IBAN Input Validation Accuracy -- Pass.',
      'All ten checks hold and the full stack classifies ten of ten, so the '
          'step reports Pass against a band whose floor, optimal and ceiling '
          'are all 1 -- a band nothing short of the arithmetic could have met',
      () {
        full = HabotIbanValidator.fullStackAccuracy;
        return HabotIbanValidator.checks.length == 10 &&
            HabotIbanValidator.checks.values.every((bool b) => b) &&
            full == 1.0 &&
            HabotIbanValidator.qualitativeOutput == 'Pass' &&
            HabotIbanValidator.columnNote.contains('EMPTY');
      },
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-03393',
        atomicStepReferenceId: 'GEN-03393',
        setupStepAction:
            'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic '
            'Step: "Confirm 100% validation accuracy across typed IBAN input '
            'test suites."',
        implementationOrder: 243,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotIbanValidator / HabotIbanCase',
          'Component Properties':
              '${HabotIbanValidator.suite.length} vectors across '
              '${HabotIbanVerdict.values.length} verdicts; '
              '${HabotIbanValidator.countries.length} countries with their '
              'registered lengths; streaming mod-97 over the rearranged '
              'value; normalisation strips grouping and upper-cases before '
              'anything is judged',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'FINDING: ${HabotIbanValidator.regexCannotNote} MEASURED: '
              '${HabotIbanValidator.layersNote} GROUPING: '
              '${HabotIbanValidator.groupingNote} REGISTRY: '
              '${HabotIbanValidator.registryNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'IBAN Input Validation Accuracy',
            observed:
                '${full.toStringAsFixed(2)} over '
                '${HabotIbanValidator.suite.length} vectors. Structure alone '
                'scores ${structural.toStringAsFixed(1)} and structure plus '
                'the country registry scores ${registry.toStringAsFixed(1)}; '
                'the two vectors that separate them are a transposed pair of '
                'digits and one mistyped digit.',
            floor: '1',
            optimal: '1',
            ceiling: '1',
          ),
          AissMeasurement(
            metricName: 'Wrong IBANs a pattern-only validator would accept',
            observed:
                '${HabotIbanValidator.caughtOnlyByTheChecksum.length} of the '
                'six invalid vectors are structurally perfect and reachable '
                'only by arithmetic. The other four are caught by structure, '
                'by length or by the country registry.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/forms/iban_validator.dart',
        ],
      ),
    );
  });
}
