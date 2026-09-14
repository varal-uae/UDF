/// AISS GATE -- Step 242 of 255
/// Global Reference ID:       GEN-01947
/// Atomic Steps Reference ID: GEN-01947
/// Setup Step (Action): (EMPTY on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Store the validation engine execution logic in the Validation
///               Module."
/// Metric: Step Completion Rate (%) -- Floor 90, Optimal 99, Ceiling 100.
///         Complete/Partial/Not Complete.
///
/// THE LOGIC IS ALREADY STORED. STORING IT AGAIN IS THE DEFECT. The artefact
/// is a manifest the gates read, and a rule that a rule has one home.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/forms/compliance_field_inventory.dart';
import 'package:udf_setup/design_system/forms/validation_module.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  double completion = 0;

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

  group('GEN-01947 :: a manifest, not a second copy', () {
    gate(
      'GEN-01947-G1',
      'Step 179: two copies of a rule with one of them executed.',
      'Nine rule classes are listed with the single file each lives in, two of '
          'which predate this batch -- the row asks for the logic to be '
          'stored, and it was, so what is produced is the index rather than a '
          'duplicate',
      () =>
          HabotValidationModule.entries.length == 9 &&
          HabotValidationModule.predatedThisBatch.length == 2 &&
          HabotValidationModule.addedByThisBatch.length == 7 &&
          HabotValidationModule.alreadyStoredNote.contains('two copies of'),
    );

    gate(
      'GEN-01947-G2',
      'A rule class declared in two files is the thing the manifest exists to '
          'catch.',
      'No rule class has two homes, and every entry sits under the one '
          'declared module root -- both checked over the list rather than '
          'asserted about it',
      () =>
          HabotValidationModule.everyRuleHasOneHome &&
          HabotValidationModule.duplicatedRuleClasses.isEmpty &&
          HabotValidationModule.everyEntryIsInTheModule &&
          HabotValidationModule.moduleRoot == 'lib/design_system/forms',
    );

    gate(
      'GEN-01947-G3',
      'A manifest that grades itself against its own list grades nothing.',
      'Kind coverage is computed against Step 236\'s inventory of what this '
          'application actually needs, and all five kinds are covered with '
          'none missing',
      () =>
          HabotValidationModule.kindsRequired.containsAll(
            HabotComplianceFieldInventory.kindsRequired,
          ) &&
          HabotValidationModule.kindsRequired.length ==
              HabotComplianceFieldInventory.kindsRequired.length &&
          HabotValidationModule.kindsCovered.length ==
              HabotCheckKind.values.length &&
          HabotValidationModule.kindsMissing.isEmpty &&
          HabotValidationModule.kindCoverage == 1.0,
    );

    gate(
      'GEN-01947-G4',
      'Step 240 bound five rules and said where each runs.',
      'Every kind of rule Step 240 bound has a home in this manifest, so the '
          'two steps agree about the same rule set rather than each keeping '
          'its own',
      () =>
          HabotValidationModule.coversEveryRuleStep240Bound &&
          HabotValidationModule.manifestIsExecutableNote
              .contains('list the gates read'),
    );
  });

  group('GEN-01947 :: two names for one place', () {
    gate(
      'GEN-01947-G5',
      'This row names "@habot/shared-library"; GEN-02117 names "Validation '
          'Module."',
      'Both names the sheet gives the module are recorded, so the second '
          'resolves to the first rather than to a new folder -- two names for '
          'one place is how two places get built',
      () =>
          HabotValidationModule.sheetNameA == '@habot/shared-library' &&
          HabotValidationModule.sheetNameB == 'Validation Module.' &&
          HabotValidationModule.twoNamesNote
              .contains(HabotValidationModule.sheetNameA) &&
          HabotValidationModule.twoNamesNote
              .contains(HabotValidationModule.sheetNameB),
    );

    gate(
      'GEN-01947-G6',
      'Every entry names the step that put it there.',
      'The seven entries this batch adds carry their step number and the two '
          'that predate it carry none, so the manifest records provenance '
          'rather than only location',
      () =>
          HabotValidationModule.addedByThisBatch.every(
            (HabotModuleEntry e) => e.addedBy.startsWith('Step '),
          ) &&
          HabotValidationModule.predatedThisBatch.every(
            (HabotModuleEntry e) => e.addedBy.isEmpty,
          ),
    );

    gate(
      'GEN-01947-G7',
      'Metric: Step Completion Rate (%) -- floor 90, optimal 99.',
      'All seven module criteria and all seven checks hold, giving 100 and a '
          'Complete -- reported on a manifest with a duplicate check rather '
          'than on a copy of the logic somewhere new',
      () {
        completion = HabotValidationModule.completionRate;
        return HabotValidationModule.completionChecks.length == 7 &&
            HabotValidationModule.completionChecks.values
                .every((bool b) => b) &&
            HabotValidationModule.checks.length == 7 &&
            HabotValidationModule.checks.values.every((bool b) => b) &&
            completion == 100 &&
            HabotValidationModule.qualitativeOutput == 'Complete' &&
            HabotValidationModule.columnNote.contains('EMPTY');
      },
    );
  });

  tearDownAll(() {
    final String moduleRoot = HabotValidationModule.moduleRoot;
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-01947',
        atomicStepReferenceId: 'GEN-01947',
        setupStepAction:
            'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic '
            'Step: "Store the validation engine execution logic in the '
            'Validation Module."',
        implementationOrder: 242,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotValidationModule / HabotModuleEntry',
          'Component Properties':
              '${HabotValidationModule.entries.length} rule classes, each '
              'with one declaring file under $moduleRoot; '
              '${HabotValidationModule.kindsCovered.length} kinds of check '
              'covered against Step 236\'s required set; '
              '${HabotValidationModule.duplicatedRuleClasses.length} rule '
              'classes with more than one home',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'FINDING: ${HabotValidationModule.alreadyStoredNote} SHEET: '
              '${HabotValidationModule.twoNamesNote} METHOD: '
              '${HabotValidationModule.manifestIsExecutableNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Step Completion Rate (%)',
            observed:
                '${completion.toStringAsFixed(0)} over '
                '${HabotValidationModule.completionChecks.length} criteria: '
                'one declared root, every entry under it, no rule class with '
                'two homes, every required kind of check covered, every rule '
                'Step 240 bound accounted for, the manifest readable by the '
                'gates, and the sheet\'s two names reconciled.',
            floor: '90',
            optimal: '99',
            ceiling: '100',
          ),
          AissMeasurement(
            metricName: 'Rule classes declared in more than one file',
            observed:
                '${HabotValidationModule.duplicatedRuleClasses.length}. The '
                'check runs over the manifest rather than being asserted '
                'about it, so a future duplicate fails this gate instead of '
                'passing a comment.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/forms/validation_module.dart',
        ],
      ),
    );
  });
}
