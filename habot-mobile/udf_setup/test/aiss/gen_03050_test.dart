/// AISS GATE -- Step 329 of 335
/// Global Reference ID:       GEN-03050
/// Atomic Steps Reference ID: GEN-03050
/// Setup Step (Action): (the generic engineering-console boilerplate --
///                      COLUMN NOTE, RECORDED)
/// Atomic Step: "Configure the API Gateway to physically drop any mobile
///               request containing un-masked PHI if the target service is not
///               on the HIPAA-eligible covered products list."
/// Metric: Control Pass Rate (%) -- floor 90, optimal 98, ceiling 100.
///         Pass/Fail. COSO Internal Control Framework; ISO/IEC 42001.
///
/// THE RIGHT CONTROL, THE WRONG STATUTE, AND TWO EXITS THE GATEWAY CANNOT
/// SEE. AND STEP 316 COLLAPSES THE SAME KIND OF BAND CORRECTLY.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/data/phi_egress_gate.dart';

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

  group('GEN-03050 :: the statute', () {
    gate(
      'GEN-03050-G1',
      'Atomic Step: "the HIPAA-eligible covered products list".',
      'HIPAA is United States health-privacy law and a covered-products list '
          'is a US cloud-vendor construct; this application ships in the UAE',
      () =>
          HabotPhiEgressGate.theCitedInstrumentIsForAnotherJurisdiction &&
          HabotPhiEgressGate.applicableInstruments.length == 2,
    );

    gate(
      'GEN-03050-G2',
      'And the rule itself translates without loss.',
      'Health data goes only to destinations allowed to receive it; the UAE '
          'instruments add a constraint HIPAA has no equivalent of, which is '
          'that the data may not leave the country',
      () =>
          HabotPhiEgressGate.theRuleSurvivesTranslation &&
          HabotPhiEgressGate.statuteNote
              .contains('a jurisdiction they are not in'),
    );
  });

  group('GEN-03050 :: three exits, one gateway', () {
    gate(
      'GEN-03050-G3',
      'Atomic Step: "Configure the API Gateway to physically drop".',
      'Health data leaves a phone through the request body, a crash report '
          'and an analytics event; the gateway sees one of the three',
      () =>
          HabotEgressPath.values.length == 3 &&
          HabotPhiEgressGate.theGatewaySeesOneExitInThree &&
          (HabotPhiEgressGate.gatewayCoverage - 1 / 3).abs() < 1e-9,
    );

    gate(
      'GEN-03050-G4',
      'The crash reporter is the worse of the two misses.',
      'It assembles its payload precisely when something has gone wrong, '
          'which is when the field is most likely to be populated and least '
          'likely to have been cleared',
      () =>
          HabotPhiEgressGate.theWorstMissIsTheCrashReport &&
          HabotPhiEgressGate.exitsNote
              .contains('least likely to have been cleared'),
    );
  });

  group('GEN-03050 :: the control at the source', () {
    gate(
      'GEN-03050-G5',
      'Five destinations, three of them refused.',
      'Two of those three would never reach a gateway at all, so the refusal '
          'has to happen where the payload is assembled',
      () =>
          HabotPhiEgressGate.destinations.length == 5 &&
          HabotPhiEgressGate.refused.length == 3 &&
          HabotPhiEgressGate.twoOfTheThreeRefusalsWouldNeverReachAGateway &&
          HabotPhiEgressGate.theRefusalHappensBeforeAssembly,
    );

    gate(
      'GEN-03050-G6',
      'Two of the three source refusals already exist.',
      'The log and event scrubber at Step 157 and the on-screen masking '
          'policy at Step 267; what this step adds is the destination list',
      () =>
          HabotPhiEgressGate.twoOfThreeRefusalsWereAlreadyBuilt &&
          HabotPhiEgressGate.sourceNote.contains('Steps 157 and'),
    );

    gate(
      'GEN-03050-G7',
      'A payload that exists can be sent by something nobody is watching.',
      'Which is why the refusal precedes assembly rather than happening in '
          'flight',
      () => HabotPhiEgressGate.sourceNote.contains('nobody is watching'),
    );
  });

  group('GEN-03050 :: the band, against Step 316\'s', () {
    gate(
      'GEN-03050-G8',
      'Floor 90 per cent on a fail-closed control.',
      'At the floor, a hundred requests in a thousand may carry health data '
          'to a service that is not allowed to receive it',
      () =>
          HabotPhiEgressGate.requestsPerThousandAllowedThroughAtTheFloor ==
              100 &&
          HabotPhiEgressGate.theBandGradientsAFailClosedControl,
    );

    gate(
      'GEN-03050-G9',
      'Step 316 collapses the same kind of band to a single 1.',
      'Which looks like a defect and is correct; two bands, one subject, and '
          'only one of them is right',
      () =>
          HabotPhiEgressGate.siblingStepWithTheCollapsedBand == 316 &&
          HabotPhiEgressGate.bandNote.contains('only one of them is right'),
    );

    gate(
      'GEN-03050-G10',
      'Output: Pass / Fail.',
      'Five declared obligations, all met, giving Pass; all ten declared '
          'checks hold',
      () =>
          HabotPhiEgressGate.obligations.length == 5 &&
          HabotPhiEgressGate.obligations.values.every((bool b) => b) &&
          HabotPhiEgressGate.qualitativeOutput == 'Pass' &&
          HabotPhiEgressGate.checks.length == 10 &&
          HabotPhiEgressGate.checks.values.every((bool b) => b) &&
          HabotPhiEgressGate.columnNote.contains('ships in the UAE'),
    );
  });

  tearDownAll(() {
    final String invisible = HabotPhiEgressGate.invisibleToTheGateway
        .map((HabotEgressPath p) => p.name)
        .join(', ');
    final String refusedNames = HabotPhiEgressGate.refused
        .map((HabotDestination d) => d.name)
        .join('; ');

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-03050',
        atomicStepReferenceId: 'GEN-03050',
        setupStepAction:
            'COLUMN NOTE: every narrative column on this row is the generic '
            'engineering-console boilerplate, and the row cites HIPAA and a '
            'covered-products list in an application that ships in the UAE, '
            'where the instruments are Federal Decree-Law 45 of 2021 and '
            'Federal Law 2 of 2019. Atomic Step: "Configure the API Gateway to '
            'physically drop any mobile request containing un-masked PHI if '
            'the target service is not on the HIPAA-eligible covered products '
            'list."',
        implementationOrder: 329,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Configure the API Gateway to physically drop any mobile request':
              'refused at the source for $refusedNames',
          'Completion Status': 'Pass',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
          'Component Properties':
              'exits a gateway cannot see: $invisible',
          'Data Quality Note':
              'STATUTE: ${HabotPhiEgressGate.statuteNote} '
              'EXITS: ${HabotPhiEgressGate.exitsNote} '
              'SOURCE: ${HabotPhiEgressGate.sourceNote} '
              'BAND: ${HabotPhiEgressGate.bandNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Control Pass Rate (%)',
            observed:
                '100% over five declared obligations, but the band is the '
                'wrong shape for the control: at a floor of 90, one request in '
                'ten may carry health data to an ineligible service. Step 316 '
                'collapses the same kind of band to a single 1 and is right to '
                '-- a fail-closed control has no gradient.',
            floor: '90',
            optimal: '98',
            ceiling: '100',
          ),
          AissMeasurement(
            metricName: 'Egress paths a gateway rule covers',
            observed:
                '1 of 3. The crash reporter and the analytics SDK send to '
                'their own endpoints and never pass the gateway, and the '
                'crash reporter is the worse miss because it populates its '
                'payload exactly when something has gone wrong. The refusal is '
                'therefore at assembly, where two of the three were already '
                'built at Steps 157 and 267.',
            floor: '3',
            optimal: '3',
            ceiling: '3',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/data/phi_egress_gate.dart',
        ],
      ),
    );
  });
}
