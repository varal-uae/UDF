/// AISS GATE -- Step 240 of 255
/// Global Reference ID:       GEN-04009
/// Atomic Steps Reference ID: GEN-04009
/// Setup Step (Action): (EMPTY on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Attach the Regex validation engine directly to the frontend
///               mobile input field controllers."
/// Metric: Edge Regex Binding Rate -- Floor 1, Optimal 1, Ceiling 1.
///         Pass/Fail. Standard cited: Client-Side Poka-Yoke Validation.
///
/// EVERY DECLARED FIELD IS BOUND. NOT EVERY DECLARED RULE IS A REGEX. Both
/// figures are published, the same shape as Steps 233 and 234.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/forms/compliance_field_inventory.dart';
import 'package:udf_setup/design_system/forms/edge_binding.dart';
import 'package:udf_setup/design_system/forms/field_validation.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  double binding = 0;

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

  group('GEN-04009 :: the binding', () {
    gate(
      'GEN-04009-G1',
      'Atomic Step: "Attach the Regex validation engine to the field '
          'controllers."',
      'Every one of the thirteen declared CDEs carries a pattern and the field '
          'widget wires it in, so the row\'s own rate is 1.0 -- read from the '
          'declaration rather than counted by hand',
      () {
        binding = HabotEdgeBinding.edgeRegexBindingRate;
        return HabotEdgeBinding.everyFieldCarriesAPattern &&
            HabotEdgeBinding.declaredFields == HabotCde.values.length &&
            binding == 1.0 &&
            binding >= HabotEdgeBinding.floor;
      },
    );

    gate(
      'GEN-04009-G2',
      '"A regular expression recognises a regular language."',
      'Five rules across five kinds of check are listed and three of them '
          'cannot be expressed as a pattern at all -- a checksum is '
          'arithmetic, a registry is a lookup, and a cross-field rule belongs '
          'to no field',
      () =>
          HabotEdgeBinding.rules.length == 5 &&
          HabotEdgeBinding.rules
                  .map((HabotBoundRule r) => r.kind)
                  .toSet()
                  .length ==
              HabotCheckKind.values.length &&
          HabotEdgeBinding.theThreeHardKindsAreNamed &&
          HabotEdgeBinding.regexCannotNote.contains('computes a remainder'),
    );

    gate(
      'GEN-04009-G3',
      '"Directly to the controller" is an attachment point, and it is the '
          'wrong one for the rule that matters.',
      'The three rules a pattern cannot carry are also the three that cannot '
          'be attached to a single controller, because a controller sees one '
          'field -- so the row\'s instruction is structurally unable to reach '
          'them',
      () =>
          HabotEdgeBinding.unattachableToAController.length == 3 &&
          HabotEdgeBinding.unattachableToAController
              .map((HabotBoundRule r) => r.kind)
              .toSet()
              .length ==
              3 &&
          HabotEdgeBinding.attachmentPointNote.contains('does not add up'),
    );

    gate(
      'GEN-04009-G4',
      'A rule with nowhere to run is a rule nobody enforces.',
      'Every one of the five is bound somewhere -- two to the field, one each '
          'to Steps 243 and 252 -- and each says why it runs where it runs',
      () =>
          HabotEdgeBinding.everyRuleIsBoundSomewhere &&
          HabotEdgeBinding.ruleCoverageRate == 1.0 &&
          HabotEdgeBinding.rules.every(
            (HabotBoundRule r) => r.why.length > 60 && r.attachedTo.isNotEmpty,
          ),
    );
  });

  group('GEN-04009 :: two figures', () {
    gate(
      'GEN-04009-G5',
      'Steps 233 and 234: publish the exclusion rather than the denominator.',
      'Two of the five kinds fit in a pattern, which is 0.4 of the rule set, '
          'and that figure is published beside the row\'s 1.0 rather than the '
          'denominator being chosen to make one number come out right',
      () =>
          (HabotEdgeBinding.regexShareOfRules - 0.4).abs() < 1e-9 &&
          HabotEdgeBinding.regexExpressibleRules.length == 2 &&
          HabotEdgeBinding.beyondARegex.length == 3 &&
          HabotEdgeBinding.twoFiguresNote.contains('come out at one'),
    );

    gate(
      'GEN-04009-G6',
      'Step 236 found the model has no slot for three kinds of check.',
      'The three kinds this step cannot bind to a controller are the same '
          'three Step 236 found the rule model cannot express, reached from a '
          'different direction and agreeing',
      () =>
          HabotComplianceFieldInventory.inexpressibleToday.length == 3 &&
          HabotEdgeBinding.beyondARegex.every(
            (HabotBoundRule r) => HabotComplianceFieldInventory
                .inexpressibleToday
                .contains(r.kind),
          ),
    );

    gate(
      'GEN-04009-G7',
      'Edge Regex Binding Rate -- floor, optimal and ceiling all 1.',
      'All nine checks hold and the step reports Pass: the rate the row asks '
          'for is 1.0 and every rule the application actually needs has a '
          'declared home, regex or not',
      () =>
          HabotEdgeBinding.checks.length == 9 &&
          HabotEdgeBinding.checks.values.every((bool b) => b) &&
          HabotEdgeBinding.qualitativeOutput == 'Pass' &&
          HabotEdgeBinding.columnNote.contains('EMPTY'),
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-04009',
        atomicStepReferenceId: 'GEN-04009',
        setupStepAction:
            'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic '
            'Step: "Attach the Regex validation engine directly to the '
            'frontend mobile input field controllers."',
        implementationOrder: 240,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotEdgeBinding / HabotBoundRule',
          'Component Properties':
              '${HabotEdgeBinding.declaredFields} declared fields, all '
              'carrying a pattern; ${HabotEdgeBinding.rules.length} rules '
              'across ${HabotCheckKind.values.length} kinds of check, of '
              'which ${HabotEdgeBinding.regexExpressibleRules.length} are '
              'regex-expressible and '
              '${HabotEdgeBinding.beyondARegex.length} are not; every rule '
              'bound somewhere with a reason',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'FINDING: ${HabotEdgeBinding.regexCannotNote} SECOND: '
              '${HabotEdgeBinding.attachmentPointNote} REPORTING: '
              '${HabotEdgeBinding.twoFiguresNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Edge Regex Binding Rate',
            observed:
                '${binding.toStringAsFixed(1)} over the '
                '${HabotEdgeBinding.declaredFields} declared fields. Every '
                'one carries a pattern and the field widget wires it in.',
            floor: '1',
            optimal: '1',
            ceiling: '1',
          ),
          AissMeasurement(
            metricName: 'Share of the rule set a regular expression can carry',
            observed:
                '${HabotEdgeBinding.regexShareOfRules.toStringAsFixed(1)} -- '
                '${HabotEdgeBinding.regexExpressibleRules.length} of '
                '${HabotEdgeBinding.rules.length}. The other three are a '
                'checksum, a registry lookup and a cross-field relation, and '
                'none of them can be attached to a controller that sees one '
                'field.',
            floor: 'n/a -- descriptive',
            optimal: 'n/a -- descriptive',
            ceiling: 'n/a -- descriptive',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/forms/edge_binding.dart',
        ],
      ),
    );
  });
}
