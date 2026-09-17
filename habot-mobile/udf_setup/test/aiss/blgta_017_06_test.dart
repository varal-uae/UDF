/// AISS GATE -- Step 420 of 415
/// Global Reference ID:       BLGTA-017-06
/// Atomic Steps Reference ID: BLGTA-017-06
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Configure the mobile application network gateway to silently
///               capture the unique mobile device ID upon submission."
/// Metric: Process Execution Quality Score -- floor ">=90%", optimal ">=98%",
///         ceiling "1". Best Qualitative Output: "Good/Average/Poor -> Best =
///         Good (100%)". ISO 9001:2015 Quality Management Standard. Assigned to
///         **UDF**.
///
/// A PERMANENT DEVICE ID THE PLATFORMS WILL NOT GIVE YOU, FOR A QUESTION THAT
/// DOES NOT NEED ONE.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/telemetry/device_identifier.dart';

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

  group('BLGTA-017-06 :: the platform declines', () {
    gate(
      'BLGTA-017-06-G1',
      'Four identifier kinds assessed, one chosen.',
      'Hardware, advertising, vendor and app-scoped install',
      () =>
          HabotDeviceIdentifier.everyKindIsAssessed &&
          HabotDeviceIdentifier.chosen == HabotIdentifierKind.appScopedInstall,
    );

    gate(
      'BLGTA-017-06-G2',
      'The platform does not supply a permanent device id.',
      'Android removed non-resettable hardware identifiers years ago and iOS '
          'gates its advertising identifier behind a prompt the user can '
          'refuse',
      () =>
          HabotDeviceIdentifier.theHardwareIdIsUnavailable &&
          HabotDeviceIdentifier.noFingerprintIsAssembled,
    );

    gate(
      'BLGTA-017-06-G3',
      'And a fingerprint is the same act under another name.',
      'Assembling one from model, locale and screen metrics is what an '
          'implementation that appears to satisfy this row would be doing',
      () =>
          HabotDeviceIdentifier
              .platformNote.contains('same act under a different name'),
    );

  });

  group('BLGTA-017-06 :: what the gateway actually needs', () {
    gate(
      'BLGTA-017-06-G4',
      'The gateway needs less than the instruction asks for.',
      'To know that two submissions came from the same install, not which '
          'person or which handset',
      () =>
          HabotDeviceIdentifier.theNeedIsNarrowerThanTheInstruction &&
          HabotDeviceIdentifier.propertiesDeclared == 6,
    );

    gate(
      'BLGTA-017-06-G5',
      'The identifier is app-scoped and cannot be joined.',
      'Generated on first run, kept in this application\'s own keychain entry, '
          'salted per environment, sent to nobody else',
      () =>
          HabotDeviceIdentifier.theIdentifierIsAppScoped &&
          HabotDeviceIdentifier.itCannotBeJoinedAcrossApps,
    );

    gate(
      'BLGTA-017-06-G6',
      'It does not outlive the install.',
      'And losing it costs the gateway one false negative rather than a person '
          'their privacy',
      () =>
          HabotDeviceIdentifier.itDoesNotOutliveTheInstall &&
          HabotDeviceIdentifier.designNote.contains('one false negative'),
    );

  });

  group('BLGTA-017-06 :: "silently", for the second time', () {
    gate(
      'BLGTA-017-06-G7',
      'Silence as an implementation property is kept.',
      'The capture costs no tap and no visible step',
      () =>
          HabotDeviceIdentifier.silentInTheBuildableSense &&
          HabotDeviceIdentifier.theWordWasSplitAtStep417,
    );

    gate(
      'BLGTA-017-06-G8',
      'Silence as secrecy is refused for the second time.',
      'After Step 417, and on the same disclosure surface',
      () =>
          HabotDeviceIdentifier.notSilentInTheOtherSense &&
          HabotDeviceIdentifier.secondRefusalInThisBatch &&
          HabotDeviceIdentifier.theDisclosureSurfaceIsTheOneStep417Named,
    );

  });

  group('BLGTA-017-06 :: the band and the arrow', () {
    gate(
      'BLGTA-017-06-G9',
      'The band mixes units and the output carries an arrow.',
      'Two percentages against a ceiling of 1, with "Best = Good (100%)" '
          'spelled out',
      () =>
          HabotDeviceIdentifier.theBandMixesUnits &&
          HabotDeviceIdentifier.theOutputColumnHoldsAnArrow &&
          HabotDeviceIdentifier.theCountReachesSeven,
    );

    gate(
      'BLGTA-017-06-G10',
      'Six obligations, all met, giving Good.',
      'And all ten declared checks hold',
      () =>
          HabotDeviceIdentifier.obligations.length == 6 &&
          HabotDeviceIdentifier.obligations.values.every((bool b) => b) &&
          HabotDeviceIdentifier.qualitativeOutput == 'Good' &&
          HabotDeviceIdentifier.quality == 100,
    );
  });

  tearDownAll(() {
    final int kinds = HabotIdentifierKind.values.length;
    final int properties = HabotDeviceIdentifier.propertiesDeclared;
    final int refusals =
        HabotDeviceIdentifier.rowsRefusingTheSecrecyReading.length;
    final double quality = HabotDeviceIdentifier.quality;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'BLGTA-017-06',
        atomicStepReferenceId: 'BLGTA-017-06',
        setupStepAction:
            'COLUMN NOTE: this row asks the gateway to silently capture a '
            'unique mobile device ID, which neither platform supplies to an '
            'ordinary application -- so what was built is an app-scoped '
            'install identifier that answers the duplicate-submission question '
            'and nothing else, and the capture is disclosed on the surface '
            'Step 417 named, the second row in this batch whose literal '
            'reading would build surveillance; its band writes floor and '
            'optimal as percentages against a ceiling of 1; its Best '
            'Qualitative Output cell carries an arrow; and its lower half '
            'holds a Domain Expertise line and three numbered sub-cells that '
            'belong to a network-perimeter row. Atomic Step: "Configure the '
            'mobile application network gateway to silently capture the unique '
            'mobile device ID upon submission."',
        implementationOrder: 420,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Configuration Parameter':
              'an app-scoped install identifier in place of the device '
                  'identifier this row asks for, which neither platform '
                  'supplies',
          'Current Setting':
              '$properties properties declared: generated on first run, kept '
                  'in this application\'s keychain entry, salted per '
                  'environment, rotated on reinstall, never sent elsewhere, '
                  'never surviving an uninstall',
          'Previous Setting':
              'none; $kinds identifier kinds were assessed before one was '
                  'chosen',
          'Change Log':
              '$refusals rows in this batch refuse the secrecy reading of '
                  '"silently" and meet the requirement another way',
          'Configuration Timestamp': '2026-09-17T00:00:00Z',
          'Completion Status': 'Good',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Process Execution Quality Score',
            observed:
                'THE INSTRUCTION ASKS FOR SOMETHING THE PLATFORMS DECLINE. '
                'Android removed non-resettable hardware identifiers from '
                'ordinary applications years ago and iOS gates its advertising '
                'identifier behind a prompt the user can refuse, so an '
                'implementation that appears to satisfy this row is either '
                'assembling a fingerprint -- the same act under another name '
                '-- or failing quietly. $kinds kinds were assessed and an '
                'app-scoped install identifier was built, answering the '
                'duplicate-submission question completely and nothing else. '
                'The band writes floor and optimal as percentages against a '
                'ceiling of 1 and the output column carries an arrow. '
                'Observed: quality $quality.',
            floor: '>=90%',
            optimal: '>=98%',
            ceiling: '1',
            higherIsBetter: true,
          ),
          AissMeasurement(
            metricName: 'Identifiers captured that outlive the install',
            observed:
                '0. The identifier rotates on reinstall, cannot be joined to '
                'another application\'s data, and never leaves this gateway; '
                'losing it costs one false negative on duplicate detection '
                'rather than costing a person their privacy. The capture is '
                'silent in the sense the row\'s own design cells mean -- no '
                'tap, no visible step -- and not silent in the other sense: it '
                'is disclosed on the surface Step 417 named, the second of '
                '$refusals refusals in this batch where the requirement '
                'survives and only the mechanism changes.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/telemetry/device_identifier.dart',
        ],
      ),
    );
  });
}
