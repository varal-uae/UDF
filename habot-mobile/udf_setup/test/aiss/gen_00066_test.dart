/// AISS GATE -- Step 236 of 255
/// Global Reference ID:       GEN-00066
/// Atomic Steps Reference ID: GEN-00066
/// Setup Step (Action): (EMPTY on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Determine the exact data types and input masks required for
///               every compliance field."
/// Metric: Requirements Definition Completeness -- Floor "All required inputs
///         identified (no gaps)", Optimal "100% coverage of requirement
///         scope", Ceiling 1. Complete/Partial/Not Complete.
///
/// THE REPOSITORY HAS THIRTEEN FIELD RULES AND NO COMPLIANCE FIELDS, AND THE
/// RULE MODEL HAS NOWHERE TO PUT ONE.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/forms/compliance_field_inventory.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  double completeness = 0;

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

  group('GEN-00066 :: what a compliance field is', () {
    gate(
      'GEN-00066-G1',
      'Atomic Step: "for every COMPLIANCE FIELD."',
      'HabotCde names thirteen data classes and every one of them is a shape; '
          'a compliance field is an identifier issued by an authority with a '
          'published format, and the two the inventory names are both '
          'undeclared',
      () =>
          HabotComplianceFieldInventory.issuedIdentifiers.length == 2 &&
          HabotComplianceFieldInventory.everyIssuedIdentifierIsUndeclared &&
          HabotComplianceFieldInventory.thirteenShapesNote
              .contains('thirteen data classes'),
    );

    gate(
      'GEN-00066-G2',
      '"A regular expression cannot compute a remainder."',
      'Five kinds of check are distinguished and only two of them fit the '
          'current rule model, so the gap this step reports is a missing slot '
          'rather than a missing rule',
      () =>
          HabotCheckKind.values.length == 5 &&
          HabotComplianceFieldInventory.expressibleToday.length == 2 &&
          HabotComplianceFieldInventory.inexpressibleToday.length == 3 &&
          HabotComplianceFieldInventory.beyondTheCurrentModel.isNotEmpty &&
          HabotComplianceFieldInventory.missingSlotNote
              .contains('missing SLOT'),
    );

    gate(
      'GEN-00066-G3',
      'A list of kinds nobody needs is padding.',
      'Every one of the five kinds is required by at least one field in the '
          'inventory, so the taxonomy is derived from the fields rather than '
          'invented and then illustrated',
      () =>
          HabotComplianceFieldInventory.everyKindIsRequiredBySomething &&
          HabotComplianceFieldInventory.kindsRequired.length == 5,
    );

    gate(
      'GEN-00066-G4',
      'Step 204 declared AED; the phone rule\'s placeholder is +254.',
      'Both jurisdictional assumptions already in the repository are written '
          'down, including the one nobody would look for -- a Kenyan dialling '
          'code in a field rule beside a money CDE named for AED',
      () =>
          HabotComplianceFieldInventory.jurisdictionNote
              .contains(HabotComplianceFieldInventory.kenyanPlaceholder) &&
          HabotComplianceFieldInventory.jurisdictionNote
              .contains(HabotComplianceFieldInventory.aedCde) &&
          HabotComplianceFieldInventory.aedCde == 'cac_aed_value' &&
          HabotComplianceFieldInventory.jurisdictionNote
              .contains('multi-market'),
    );
  });

  group('GEN-00066 :: the inventory the metric grades', () {
    gate(
      'GEN-00066-G5',
      'Metric floor: "All required inputs identified (no gaps)."',
      'Every field the application takes from a person is listed with its data '
          'type and with every kind of check its correctness needs -- '
          'identifying a gap is not the same as having none, and the row asks '
          'for the former',
      () =>
          HabotComplianceFieldInventory.fields.length == 6 &&
          HabotComplianceFieldInventory.fields.every(
            (HabotFieldFact f) =>
                f.dataType.isNotEmpty && f.checks.isNotEmpty,
          ) &&
          HabotComplianceFieldInventory.scopeCriteria.length == 6,
    );

    gate(
      'GEN-00066-G6',
      'An identifier rule without a jurisdiction is right somewhere else.',
      'Both issued identifiers name their jurisdiction, and neither has a '
          'declaration site -- which is the fact this step exists to produce',
      () =>
          HabotComplianceFieldInventory.issuedIdentifiers.every(
            (HabotFieldFact f) => f.jurisdiction.isNotEmpty,
          ) &&
          HabotComplianceFieldInventory.undeclaredIdentifiers.length == 2 &&
          HabotComplianceFieldInventory.undeclaredIdentifiers.every(
            (HabotFieldFact f) => !f.isDeclared,
          ),
    );

    gate(
      'GEN-00066-G7',
      'Metric: Requirements Definition Completeness -- ceiling 1.',
      'All eight checks and all six scope criteria hold, giving 1.0 and a '
          'Complete -- reported on an inventory that names what is missing '
          'rather than on a count of rules that already existed',
      () {
        completeness = HabotComplianceFieldInventory.completeness;
        return HabotComplianceFieldInventory.checks.length == 8 &&
            HabotComplianceFieldInventory.checks.values.every((bool b) => b) &&
            completeness == 1.0 &&
            HabotComplianceFieldInventory.qualitativeOutput == 'Complete' &&
            HabotComplianceFieldInventory.columnNote.contains('EMPTY');
      },
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-00066',
        atomicStepReferenceId: 'GEN-00066',
        setupStepAction:
            'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic '
            'Step: "Determine the exact data types and input masks required '
            'for every compliance field."',
        implementationOrder: 236,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name':
              'HabotComplianceFieldInventory / HabotFieldFact / HabotCheckKind',
          'Component Properties':
              '${HabotComplianceFieldInventory.fields.length} field groups '
              'with data type, jurisdiction and required checks; '
              '${HabotCheckKind.values.length} kinds of check of which '
              '${HabotComplianceFieldInventory.expressibleToday.length} fit '
              'the current rule model; '
              '${HabotComplianceFieldInventory.issuedIdentifiers.length} '
              'issued identifiers, '
              '${HabotComplianceFieldInventory.undeclaredIdentifiers.length} '
              'of them undeclared',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'FINDING: ${HabotComplianceFieldInventory.thirteenShapesNote} '
              'SECOND: ${HabotComplianceFieldInventory.missingSlotNote} '
              'THIRD: ${HabotComplianceFieldInventory.jurisdictionNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Requirements Definition Completeness',
            observed:
                '${completeness.toStringAsFixed(2)} over '
                '${HabotComplianceFieldInventory.scopeCriteria.length} scope '
                'criteria: every field listed with its data type, every kind '
                'of check its correctness needs, the kinds the model cannot '
                'express, the identifiers nothing declares, and both '
                'jurisdictional assumptions already in force.',
            floor: 'All required inputs identified (no gaps)',
            optimal: '100% coverage of requirement scope',
            ceiling: '1',
          ),
          AissMeasurement(
            metricName: 'Kinds of check the current rule model can express',
            observed:
                '${HabotComplianceFieldInventory.expressibleToday.length} of '
                '${HabotCheckKind.values.length}. HabotFieldRule carries a '
                'mask and a RegExp pattern; checksum, registry and '
                'cross-field have nowhere to go, and land at Steps 243, 244 '
                'and 252.',
            floor: '5 of 5',
            optimal: '5 of 5',
            ceiling: '5 of 5',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/forms/compliance_field_inventory.dart',
        ],
      ),
    );
  });
}
