/// AISS GATE -- Step 269 of 275
/// Global Reference ID:       GEN-00820
/// Atomic Steps Reference ID: GEN-00820
/// Setup Step (Action): (EMPTY on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Execute Cloud DLP scans against analytical datasets to
///               confirm 0 raw unhashed PII findings."
/// Metric: Raw Unhashed PII Finding Count -- Floor 0, Optimal 0, Ceiling 0.
///         Pass / Fail. Standard cited: ISO/IEC 27701.
///
/// A CLIENT CANNOT SCAN THE WAREHOUSE AND SHOULD NOT BE ABLE TO. ITS HALF IS
/// UPSTREAM, AND IT IS THE HALF THAT DECIDES THE ANSWER.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/telemetry/emission_purity.dart';

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

  group('GEN-00820 :: who can do what', () {
    gate(
      'GEN-00820-G1',
      'Atomic Step: "Execute Cloud DLP scans against analytical datasets".',
      'The scan is named as a server obligation rather than attempted: a '
          'client with credentials to scan the warehouse would be a client '
          'with credentials to read it',
      () =>
          HabotEmissionPurity.cannotRunTheScanNote.contains('could also read '
              'it') &&
          HabotEmissionPurity.serverObligations.length == 2,
    );

    gate(
      'GEN-00820-G2',
      'Nothing on the other side of the wire may be claimed here.',
      'Five obligations are split three to the client and two to the server, '
          'and neither server obligation is marked satisfied by this step',
      () =>
          HabotEmissionPurity.obligations.length == 5 &&
          HabotEmissionPurity.clientObligations.length == 3 &&
          HabotEmissionPurity.nothingOnTheServerSideIsClaimed &&
          (HabotEmissionPurity.shareShownHere - 0.4).abs() < 1e-9,
    );

    gate(
      'GEN-00820-G3',
      'The client half is upstream of the scan.',
      'If nothing unhashed leaves the device the dataset cannot contain it, '
          'so the scan becomes a confirmation rather than a discovery -- and '
          'that is where the work was done',
      () => HabotEmissionPurity.upstreamNote.contains('at the declaration'),
    );
  });

  group('GEN-00820 :: the structural guarantee', () {
    gate(
      'GEN-00820-G4',
      'An event carrying a name cannot be declared.',
      'Five field types are declared and none of them is free text, checked '
          'over the enum\'s own names so a sixth type called text or note '
          'would break this gate rather than pass it',
      () =>
          HabotEmissionPurity.declaredTypes.length == 5 &&
          HabotEmissionPurity.noFieldTypeIsFreeText &&
          HabotEmissionPurity.freeTextTypeNames.length == 5,
    );

    gate(
      'GEN-00820-G5',
      'A zero over an empty population is not evidence.',
      'The schema has events and fields to check, every declared field is one '
          'of the five types, and the schema covers every declared kind of '
          'event',
      () =>
          HabotEmissionPurity.declaredEventKinds > 0 &&
          HabotEmissionPurity.declaredFields > 0 &&
          HabotEmissionPurity.everyDeclaredFieldIsATypedField &&
          HabotEmissionPurity.declaredFieldsThatCouldCarryRawPii == 0,
    );

    gate(
      'GEN-00820-G6',
      'The strongest guarantee is the weakest evidence.',
      'The zero is recorded as structural rather than measured: a test over '
          'it can never fail while the enum stands, and what can fail is the '
          'check on the enum\'s names',
      () => HabotEmissionPurity.structuralNotMeasuredNote.contains('can never '
          'fail'),
    );
  });

  group('GEN-00820 :: what a salted hash is not', () {
    gate(
      'GEN-00820-G7',
      'A hash is not anonymisation when the input space is small.',
      'A phone number has about a billion possible values, so an opaque id '
          'derived from one is recovered by a loop rather than by an attack, '
          'and that is written down rather than left implied',
      () =>
          HabotEmissionPurity.phoneNumberSearchSpace == 1000000000 &&
          HabotEmissionPurity.aSaltedHashIsNotAnonymisation &&
          HabotEmissionPurity.hashIsNotAnonymousNote.contains('it is a loop'),
    );

    gate(
      'GEN-00820-G8',
      'What the salt does buy is checked against the implementation.',
      'The same input on two installs gives two identifiers, exercised '
          'against the existing sanitiser rather than described, and at least '
          'one declared field is an opaque id so the salt matters',
      () =>
          HabotEmissionPurity.theSaltSeparatesInstalls &&
          HabotEmissionPurity.opaqueIdFields > 0,
    );

    gate(
      'GEN-00820-G9',
      'Metric: Raw Unhashed PII Finding Count -- 0 / 0 / 0. Pass / Fail.',
      'All twelve declared checks hold and the step reports Pass on the '
          'population it can see, with the population it cannot see named '
          'rather than claimed',
      () =>
          HabotEmissionPurity.checks.length == 12 &&
          HabotEmissionPurity.checks.values.every((bool b) => b) &&
          HabotEmissionPurity.qualitativeOutput == 'Pass' &&
          HabotEmissionPurity.columnNote.contains('EMPTY'),
    );
  });

  tearDownAll(() {
    final String kinds = '${HabotEmissionPurity.declaredEventKinds}';
    final String fields = '${HabotEmissionPurity.declaredFields}';
    final String opaque = '${HabotEmissionPurity.opaqueIdFields}';
    final String shown = '${HabotEmissionPurity.shownHere.length}';
    final String total = '${HabotEmissionPurity.obligations.length}';

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-00820',
        atomicStepReferenceId: 'GEN-00820',
        setupStepAction:
            'COLUMN NOTE: Setup Step (Action) is EMPTY on this row, and the '
            'band is written with LaTeX escapes for floor, optimal and '
            'ceiling. Atomic Step: "Execute Cloud DLP scans against '
            'analytical datasets to confirm 0 raw unhashed PII findings."',
        implementationOrder: 269,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name':
              'HabotEmissionPurity / HabotPurityObligation / '
                  'HabotObligationSide',
          'Component Properties':
              '$total obligations, $shown of them shown to hold here and the '
              'server\'s two named rather than claimed; '
              '${HabotEmissionPurity.declaredTypes.length} field types none '
              'of which is free text; $kinds declared event kinds with '
              '$fields fields, $opaque of them opaque identifiers salted per '
              'install',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'FINDING: ${HabotEmissionPurity.hashIsNotAnonymousNote} '
              'SERVER: ${HabotEmissionPurity.cannotRunTheScanNote} '
              'STRUCTURAL: ${HabotEmissionPurity.structuralNotMeasuredNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Raw Unhashed PII Finding Count',
            observed:
                '0 declared fields could carry a raw personal value, and the '
                'zero is structural: there is no field type such a value '
                'could be declared as. Checked over $kinds event kinds and '
                '$fields fields. The warehouse-side scan the row names is a '
                'server obligation and is not claimed here.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
          AissMeasurement(
            metricName: 'Obligations demonstrable on this side of the wire',
            observed:
                '$shown of $total. The other three are the log scrubber -- '
                'measured at three of eleven by Step 268 -- and the two '
                'server obligations, both named as unproven here.',
            floor: '5 of 5',
            optimal: '5 of 5',
            ceiling: '5 of 5',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/telemetry/emission_purity.dart',
        ],
      ),
    );
  });
}
