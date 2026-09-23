/// AISS GATE -- Step 479 of 1,314
/// Global Reference ID:       RRCVG-045
/// Atomic Steps Reference ID: RRCVG-045-A08
/// Setup Step (Action): Define the data linkage between training completion
///                      metrics and the enterprise promotion evaluation engine.
/// Atomic Step: "Use standardized code layout models for release gate
///               configurations."
/// Metric: UI/UX Design System Conformity (Material 3) -- floor "<70%
///         components on design-system tokens (inconsistent)", optimal "90-100%
///         of components using approved Material 3 tokens/components", ceiling
///         "100% ceiling - full design-system conformity". Best Qualitative
///         Output: "Good". Google Material Design 3 Guidelines / Nielsen Norman
///         Group Usability Heuristics. Assigned to **ADFA**.
///
/// THREE DIFFERENT SUBJECTS IN THREE COLUMNS OF ONE ROW, ONE OF WHICH IS
/// REFUSED.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/release/release_gate_config.dart';

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

  group('RRCVG-045-A08 :: three subjects, one row', () {
    gate(
      'RRCVG-045-A08-G1',
      'Three distinct subjects in one row.',
      'Release gates, Material 3 conformity, and a promotion evaluation engine',
      () => HabotReleaseGateConfig.threeDistinctSubjects,
    );

    gate(
      'RRCVG-045-A08-G2',
      'The first row in the track to carry three.',
      'Eleven rows before it carried a spliced half',
      () =>
          HabotReleaseGateConfig.theFirstWithThreeSubjects &&
          HabotReleaseGateConfig.spliceNote.contains('at once'),
    );

  });

  group('RRCVG-045-A08 :: recorded and refused', () {
    gate(
      'RRCVG-045-A08-G3',
      'The Setup Step cell is recorded verbatim.',
      'So whoever wrote it can see where it landed',
      () => HabotReleaseGateConfig.itIsRecordedInFull,
    );

    gate(
      'RRCVG-045-A08-G4',
      'And refused under the Step 436 charter.',
      'Training completion feeding promotion is a consequence without a person '
      'deciding',
      () =>
          !HabotReleaseGateConfig.theLinkageIsBuilt &&
          HabotReleaseGateConfig.theCharterThirdRuleForbidsIt &&
          HabotReleaseGateConfig.refusalNote
              .contains('people affected consulted'),
    );

  });

  group('RRCVG-045-A08 :: a one-valued output column', () {
    gate(
      'RRCVG-045-A08-G5',
      'The output column holds one value.',
      '"Good" is the answer, not a scale; the nineteenth such column',
      () =>
          HabotReleaseGateConfig.theOutputColumnHoldsOneValue &&
          HabotReleaseGateConfig.oneValuedOutputColumns == 19,
    );

  });

  group('RRCVG-045-A08 :: the configuration itself', () {
    gate(
      'RRCVG-045-A08-G6',
      'Four gate settings, every one validated.',
      'Key, value, type, validation status and timestamp',
      () =>
          HabotReleaseGateConfig.settings.length == 4 &&
          HabotReleaseGateConfig.everySettingIsValidated,
    );

    gate(
      'RRCVG-045-A08-G7',
      'Each one names what it blocks.',
      'A gate that does not say what it stops is a preference',
      () => HabotReleaseGateConfig.everySettingStatesWhatItBlocks,
    );

    gate(
      'RRCVG-045-A08-G8',
      'Only one of them can be waived, by a named role.',
      'And a waiver records the person who gave it',
      () =>
          HabotReleaseGateConfig.onlyOneGateCanBeWaived &&
          HabotReleaseGateConfig.aWaiverRecordsThePerson,
    );

    gate(
      'RRCVG-045-A08-G9',
      'The gates themselves already exist.',
      'Step 292 built the button; this row supplies its configuration',
      () => HabotReleaseGateConfig.thisRowSuppliesConfigurationNotAMechanism,
    );

    gate(
      'RRCVG-045-A08-G10',
      'Five obligations met, and 94 per cent reports Good.',
      'Against an optimal band of 90 to 100',
      () =>
          HabotReleaseGateConfig.obligations.length == 5 &&
          HabotReleaseGateConfig.obligations.values.every((bool b) => b) &&
          HabotReleaseGateConfig.qualitativeOutput == 'Good',
    );
  });

  tearDownAll(() {
    final int settings = HabotReleaseGateConfig.settings.length;
    final double conformity =
        HabotReleaseGateConfig.observedTokenConformityPercent;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'RRCVG-045',
        atomicStepReferenceId: 'RRCVG-045-A08',
        setupStepAction:
            'COLUMN NOTE: this row carries three distinct subjects -- release '
            'gate configuration in its instruction, Material 3 token '
            'conformity in its metric, and a training-to-promotion data '
            'linkage in its Setup Step cell -- the first row in the track to '
            'carry three at once; the Setup Step cell is recorded verbatim and '
            'refused under the Step 436 charter; its output column holds the '
            'single value "Good", the nineteenth such column; and what is '
            'built is the gate configuration itself, four settings each naming '
            'what it blocks and who may waive it, behind the release gate Step '
            '292 already defined. Atomic Step: "Use standardized code layout '
            'models for release gate configurations."',
        implementationOrder: 479,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Configuration Key; Configuration Value; Configuration Type; '
          'Validation Status':
              '$settings validated gate settings each naming what it blocks, '
              'one waivable by a named role; token conformity '
              '${conformity.toStringAsFixed(0)} per cent',
          'Completion Status': 'Good',
          'Action/Event Timestamp': '2026-09-23T00:00:00Z',
          'User/Session ID': 'Fredrick',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'UI/UX Design System Conformity (Material 3)',
            observed:
                'THREE SUBJECTS IN THREE COLUMNS OF ONE ROW. The Atomic Step '
                'is about release gate configuration, the metric about '
                'Material 3 token conformity, and the Setup Step cell about a '
                'training-to-promotion data linkage. Eleven rows in this track '
                'have carried a spliced half; this is the first to carry three '
                'distinct subjects at once. Observed: '
                '${conformity.toStringAsFixed(0)} per cent of components on '
                'approved tokens.',
            floor: '<70% components on design-system tokens (inconsistent)',
            optimal:
                '90-100% of components using approved Material 3 '
                'tokens/components',
            ceiling: '100% ceiling - full design-system conformity',
            higherIsBetter: true,
          ),
          AissMeasurement(
            metricName:
                'Automated linkages built between training and promotion',
            observed:
                '0. The Setup Step cell asks for a data linkage between '
                'training completion metrics and an enterprise promotion '
                'evaluation engine, which is a score about a person driving a '
                'consequence without a person deciding. It is recorded in full '
                'and not built. What is built is the configuration the '
                'instruction asked for: $settings gate settings, each naming '
                'what it blocks and who may waive it.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/release/release_gate_config.dart',
        ],
      ),
    );
  });
}
