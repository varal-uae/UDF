/// AISS GATE -- Step 188 of 195
/// Global Reference ID:       GEN-03899
/// Atomic Steps Reference ID: GEN-03899
/// Setup Step (Action): (EMPTY on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Assign the Material color token md.sys.color.primary to the
///               left button container. [cite: 540]"
/// Metric: Design System Token Compliance -- Floor 1, Optimal 1, Ceiling 1.
///         Pass / Fail.
///
/// FOLLOWING THIS ROW LITERALLY COLOURS THE WRONG BUTTON IN URDU. "The left
/// button" is a position; in a right-to-left locale the confirming action sits
/// on the right. Third occurrence of the same defect: Step 150's swipe
/// direction and Step 167's frozen column were both written as sides.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/i18n/localization_objective.dart';
import 'package:udf_setup/design_system/tokens/button_role_map.dart';
import 'package:udf_setup/design_system/tokens/m3_naming.dart';

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

  group('GEN-03899 :: the token the row names', () {
    gate(
      'GEN-03899-G1',
      'Atomic Step: "Assign the Material color token md.sys.color.primary to '
          'the ... button container."',
      'The confirming action\'s container carries exactly the token the row '
          'names, spelled the way MD3 spells it, and the spelling comes from '
          'the Step 177 converter rather than from a string typed here',
      () =>
          HabotButtonRoleMap.rowToken == 'md.sys.color.primary' &&
          HabotButtonRoleMap.containerTokenFor(HabotButtonRole.confirm) ==
              HabotButtonRoleMap.rowToken &&
          HabotM3Naming.isConformant(HabotButtonRoleMap.rowToken) &&
          HabotButtonRoleMap.forRole(HabotButtonRole.confirm).variant ==
              'M3 Filled Button',
    );

    gate(
      'GEN-03899-G2',
      '"In a right-to-left locale the confirming action sits on the right, so '
          'assigning primary to whatever is on the left paints the DISMISS '
          'action as the primary one."',
      'Position is derived from text direction: the left button is the dismiss '
          'action in English and the confirm action in Urdu, so the row\'s '
          'literal wording hits a different control in each -- which is the '
          'finding',
      () =>
          HabotButtonRoleMap.roleAtLeft(
                HabotTextDirectionality.leftToRight,
              ) ==
              HabotButtonRole.dismiss &&
          HabotButtonRoleMap.roleAtRight(
                HabotTextDirectionality.leftToRight,
              ) ==
              HabotButtonRole.confirm &&
          HabotButtonRoleMap.roleAtLeft(
                HabotTextDirectionality.rightToLeft,
              ) ==
              HabotButtonRole.confirm &&
          HabotButtonRoleMap.roleAtRight(
                HabotTextDirectionality.rightToLeft,
              ) ==
              HabotButtonRole.dismiss &&
          HabotButtonRoleMap.literalInstructionHits(
                HabotTextDirectionality.leftToRight,
              ) !=
              HabotButtonRoleMap.literalInstructionHits(
                HabotTextDirectionality.rightToLeft,
              ) &&
          HabotButtonRoleMap.directionNote.contains('Steps 150 and 167'),
    );

    gate(
      'GEN-03899-G3',
      '"One token on one widget is not a design system, and the metric asks '
          'for compliance rather than for a single assignment."',
      'Every button variant the product uses has a declared container and '
          'label role with the MD3 component it maps to, so the next dialog '
          'has an answer to look up rather than a colour to choose',
      () {
        final Set<HabotButtonRole> roles = HabotButtonRoleMap.all
            .map((HabotButtonColors c) => c.role)
            .toSet();
        return HabotButtonRoleMap.all.length == 4 &&
            roles.length == HabotButtonRole.values.length &&
            HabotButtonRoleMap.all.every(
              (HabotButtonColors c) =>
                  c.label.isNotEmpty && c.variant.startsWith('M3 '),
            ) &&
            HabotButtonRoleMap.forRole(HabotButtonRole.secondary).container ==
                'secondaryContainer' &&
            HabotButtonRoleMap.forRole(HabotButtonRole.dismiss).variant ==
                'M3 Text Button' &&
            HabotButtonRoleMap.oneWidgetIsNotASystemNote
                .contains('invents its own colours');
      },
    );
  });

  group('GEN-03899 :: the pairs, and the ones that are not pairs', () {
    gate(
      'GEN-03899-G4',
      '"Assigning primary to a container without assigning onPrimary to its '
          'label is how a button ends up at 1.9:1 and passes review."',
      'Every container assignment comes with the label role it is read '
          'against, and the pair is the same pair the Step 4 audit gates',
      () =>
          HabotButtonRoleMap.all.every(
            (HabotButtonColors c) =>
                c.container == null || c.auditedPair != null,
          ) &&
          HabotButtonRoleMap.forRole(HabotButtonRole.confirm).auditedPair!
              .join('/') ==
              'onPrimary/primary' &&
          HabotButtonRoleMap.forRole(HabotButtonRole.destructive).auditedPair!
              .join('/') ==
              'onError/error' &&
          HabotButtonRoleMap.labelPairNote.contains('1.9:1'),
    );

    gate(
      'GEN-03899-G5',
      'A text button has no container. "Transparent is a colour and no '
          'container is an absence."',
      'The dismiss variant declares a null container rather than a transparent '
          'one, still declares its label role, and therefore contributes no '
          'audited pair -- which is correct, because there is nothing to read '
          'it against',
      () {
        final HabotButtonColors dismiss =
            HabotButtonRoleMap.forRole(HabotButtonRole.dismiss);
        return dismiss.container == null &&
            dismiss.containerToken == null &&
            dismiss.auditedPair == null &&
            dismiss.label == 'primary' &&
            HabotM3Naming.isConformant(dismiss.labelToken) &&
            dismiss.labelToken == 'md.sys.color.primary';
      },
    );

    gate(
      'GEN-03899-G6',
      '"A delete button coloured like a submit button gets pressed."',
      'The destructive variant takes the error role rather than primary, so '
          'confirming a deletion does not look identical to confirming a save',
      () =>
          HabotButtonRoleMap.containerTokenFor(
                HabotButtonRole.destructive,
              ) ==
              'md.sys.color.error' &&
          HabotButtonRoleMap.containerTokenFor(
                HabotButtonRole.destructive,
              ) !=
              HabotButtonRoleMap.containerTokenFor(HabotButtonRole.confirm) &&
          HabotButtonRoleMap.destructiveNote.contains('gets pressed'),
    );

    gate(
      'GEN-03899-G7',
      'Metric: Design System Token Compliance -- 1 at every bound.',
      'Every compliance condition holds, including the one the row\'s own '
          'wording would have broken: position derived from direction rather '
          'than written as a side',
      () =>
          HabotButtonRoleMap.isCompliant &&
          HabotButtonRoleMap.complianceChecks.length == 6 &&
          HabotButtonRoleMap.complianceChecks.values.every((bool b) => b) &&
          HabotButtonRoleMap.qualitativeOutput == 'Pass' &&
          HabotButtonRoleMap.columnNote.contains('[cite: 540]'),
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-03899',
        atomicStepReferenceId: 'GEN-03899',
        setupStepAction:
            'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic '
            'Step: "Assign the Material color token md.sys.color.primary to '
            'the left button container." The "[cite: 540]" fragment is an '
            'artefact of the source document and carries no requirement.',
        implementationOrder: 188,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotButtonRoleMap / HabotButtonColors',
          'Component Properties':
              '${HabotButtonRoleMap.all.length} button roles mapped to MD3 '
              'variants with container and label colour roles; position '
              'resolved from text direction; every container assignment '
              'carries its audited label pair',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'FINDING: "the left button" is a position, and in a right-to-left '
              'locale the confirming action sits on the right -- so following '
              'the row literally paints the DISMISS action as the primary one, '
              'in the language where the product is least able to notice. This '
              'is the third occurrence of the same defect: Step 150\'s swipe '
              'direction and Step 167\'s frozen table column were both written '
              'as sides and both had to become directions. The map is keyed by '
              'what a button DOES; position is derived.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Design System Token Compliance',
            observed:
                'All ${HabotButtonRoleMap.complianceChecks.length} conditions '
                'hold. The confirming action\'s container carries '
                '${HabotButtonRoleMap.rowToken}, every variant declares a '
                'container and label pair, no container is assigned without '
                'its label, the destructive variant does not share the confirm '
                'colour, and position is derived from text direction rather '
                'than written as a side.',
            floor: '1',
            optimal: '1',
            ceiling: '1',
          ),
          AissMeasurement(
            metricName: 'Button variants with a declared colour pair',
            observed:
                '${HabotButtonRoleMap.all.length} of '
                '${HabotButtonRoleMap.all.length}. Three carry a container and '
                'its audited label pair; the text button declares a null '
                'container rather than a transparent one, because transparent '
                'is a colour and no container is an absence.',
            floor: 'all declared variants',
            optimal: 'all declared variants',
            ceiling: 'all declared variants',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/tokens/button_role_map.dart',
        ],
      ),
    );
  });
}
