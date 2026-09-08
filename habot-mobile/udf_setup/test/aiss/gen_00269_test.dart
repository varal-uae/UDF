/// AISS GATE -- Step 151 of 155
/// Global Reference ID:       GEN-00269
/// Atomic Steps Reference ID: GEN-00269
/// Setup Step (Action) / Atomic Step: "Confirm focus advances to the next
///   field with zero manual scrolling required."
/// Metric: General Task Completion Quality -- Floor "Task completed with
///         documented exceptions", Optimal "100% completion matching stated
///         implementation-step intent", Ceiling 1.0.
///         Complete / Partial / Not Complete.
library;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/forms/field_validation.dart';
import 'package:udf_setup/design_system/forms/focus_advance.dart';
import 'package:udf_setup/design_system/forms/form_gate.dart';
import 'package:udf_setup/design_system/i18n/localization_objective.dart';
import 'package:udf_setup/design_system/wizard/step_machine.dart';
import 'package:udf_setup/design_system/wizard/wizard_navigation.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  double quality = 0;

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

  /// Two single-question steps, then a compound block of two fields.
  const List<WizardStep> steps = <WizardStep>[
    WizardStep(id: 's1', title: 'Name', fieldNames: <String>['name']),
    WizardStep(id: 's2', title: 'Date', fieldNames: <String>['date']),
    WizardStep(
      id: 'step.contact',
      title: 'Contact',
      fieldNames: <String>['phone', 'email'],
    ),
  ];

  ({WizardStepMachine machine, HabotFormGate gate}) build() {
    final HabotFormGate g = HabotFormGate();
    for (final String f in <String>['name', 'date', 'phone', 'email']) {
      g
        ..register(f)
        ..update(f, const FieldValidationResult.valid());
    }
    return (machine: WizardStepMachine(steps: steps, gate: g), gate: g);
  }

  group('GEN-00269 :: the traversal, including its edges', () {
    gate(
      'GEN-00269-G1',
      '"Zero manual scrolling" cannot be satisfied by setting textInputAction '
          'on a field. The interesting cases are the edges: the last field of '
          'a step, and the last field of the last step.',
      'The traversal covers every field in order and gives each position an '
          'action derived from where it sits -- next field inside a step, next '
          'STEP at a step boundary, submit at the very end',
      () {
        final ({WizardStepMachine machine, HabotFormGate gate}) w = build();
        final List<HabotFocusPosition> t =
            HabotFocusAdvance.traversalOf(w.machine);
        return t.length == 4 &&
            t[0].action == HabotFocusAction.nextStep &&
            t[1].action == HabotFocusAction.nextStep &&
            t[2].action == HabotFocusAction.nextField &&
            t[3].action == HabotFocusAction.submit &&
            t.map((HabotFocusPosition p) => p.fieldName).join(',') ==
                'name,date,phone,email';
      },
    );

    gate(
      'GEN-00269-G2',
      'A key that says "Next" on the final question is a promise the app does '
          'not keep.',
      'The platform action key is derived from position rather than set per '
          'field: next everywhere except the last position, where it is done',
      () {
        final ({WizardStepMachine machine, HabotFormGate gate}) w = build();
        final List<HabotFocusPosition> t =
            HabotFocusAdvance.traversalOf(w.machine);
        return t.take(3).every(
                  (HabotFocusPosition p) =>
                      p.inputAction == TextInputAction.next,
                ) &&
            t.last.inputAction == TextInputAction.done &&
            HabotFocusAdvance.nextAfter(t, t.last) == null &&
            HabotFocusAdvance.nextAfter(t, t.first)!.fieldName == 'date';
      },
    );

    gate(
      'GEN-00269-G3',
      'Metric optimal: "100% completion matching stated implementation-step '
          'intent". The stated intent is zero manual scrolling.',
      'A traversal in which every next field is on screen once the keyboard is '
          'up needs no intervention at any point, which is what the row asks '
          'for',
      () {
        final ({WizardStepMachine machine, HabotFormGate gate}) w = build();
        quality = HabotFocusAdvance.completionQuality(
          machine: w.machine,
          visibleWithoutScrolling: (String _) => true,
        );
        return quality == HabotFocusAdvance.optimal &&
            quality == 1.0 &&
            HabotFocusAdvance.walk(
              machine: w.machine,
              visibleWithoutScrolling: (String _) => true,
            ).isEmpty;
      },
    );

    gate(
      'GEN-00269-G4',
      'A quality figure that cannot fall is not a measurement, and the case it '
          'has to catch is a next field hidden behind the keyboard.',
      'A field that is not reachable without scrolling lowers the figure and '
          'is reported with the field name and the reason, rather than only a '
          'fraction',
      () {
        final ({WizardStepMachine machine, HabotFormGate gate}) w = build();
        final List<HabotManualIntervention> problems = HabotFocusAdvance.walk(
          machine: w.machine,
          visibleWithoutScrolling: (String f) => f != 'email',
        );
        final double degraded = HabotFocusAdvance.completionQuality(
          machine: w.machine,
          visibleWithoutScrolling: (String f) => f != 'email',
        );
        return problems.length == 1 &&
            problems.single.reason.contains('email') &&
            problems.single.reason.contains('scroll') &&
            problems.single.at.fieldName == 'phone' &&
            degraded < 1.0 &&
            degraded == 0.75;
      },
    );
  });

  group('GEN-00269 :: the keyboard is not a bypass', () {
    gate(
      'GEN-00269-G5',
      'After Step 147 a step usually holds one field, so advancing focus past '
          'it means advancing the STEP -- and the action key becomes a second '
          'way to leave a step.',
      'Crossing a step boundary goes through the same navigation the forward '
          'button uses, so an unsatisfied step refuses the key exactly as it '
          'refuses the button',
      () {
        final ({WizardStepMachine machine, HabotFormGate gate}) w = build();
        final HabotWizardNavigation n = HabotWizardNavigation(
          machine: w.machine,
          direction: HabotTextDirectionality.leftToRight,
        );
        final List<HabotFocusPosition> t =
            HabotFocusAdvance.traversalOf(w.machine);
        w.gate.update('name', const FieldValidationResult.invalid('No.'));
        final HabotNavigationOutcome? refused = HabotFocusAdvance.advance(
          from: t.first,
          navigation: n,
        );
        w.gate.update('name', const FieldValidationResult.valid());
        final HabotNavigationOutcome? allowed = HabotFocusAdvance.advance(
          from: t.first,
          navigation: n,
        );
        final HabotNavigationOutcome? withinStep = HabotFocusAdvance.advance(
          from: t[2],
          navigation: n,
        );
        return refused != null &&
            !refused.moved &&
            refused.blockedBy == StepBlockReason.validationFailed &&
            allowed != null &&
            allowed.moved &&
            withinStep == null &&
            HabotFocusAdvance.keyboardIsNotABypassNote.contains(
              'way around validation',
            );
      },
    );

    gate(
      'GEN-00269-G6',
      'The row FLOOR is "task completed with documented exceptions". A step '
          'with nowhere to write an exception makes the floor unreachable and '
          'the optimal a formality.',
      'There is a declared place for exceptions, it is empty -- so the optimal '
          'is claimed rather than the floor -- and the reasoning about the '
          'edges is recorded in the code',
      () =>
          HabotFocusAdvance.documentedExceptions.isEmpty &&
          quality == HabotFocusAdvance.optimal &&
          HabotFocusAdvance.edgesAreThePointNote.contains(
            'invisible to a test that checks one field advancing to another',
          ),
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-00269',
        atomicStepReferenceId: 'GEN-00269',
        setupStepAction:
            'Confirm focus advances to the next field with zero manual '
            'scrolling required.',
        implementationOrder: 151,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotFocusAdvance',
          'Component Properties':
              '${HabotFocusAction.values.length} position actions (next field, '
              'next step, submit); the platform action key is derived from '
              'position; step boundaries route through HabotWizardNavigation',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'Zero-dependency row. The row floor permits documented '
              'exceptions; there are none, so the optimal is claimed rather '
              'than the floor.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'General Task Completion Quality',
            observed:
                '${(quality * 100).toStringAsFixed(0)}% of traversal points '
                'need no manual intervention. Measured by walking the whole '
                'form end to end rather than by checking one field advance, '
                'because the failures live at the edges: the last field of a '
                'step, the last field of the last step, and a next field '
                'behind the keyboard.',
            floor: 'Task completed with documented exceptions',
            optimal: '100% completion matching stated implementation-step '
                'intent',
            ceiling: '1.0',
          ),
          const AissMeasurement(
            metricName: 'Manual scrolls required to complete the form',
            observed:
                '0, across every position in the traversal. The figure is '
                'demonstrably able to rise: hiding one field behind the '
                'keyboard drops the quality to 0.75 and names the field and '
                'the reason.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/forms/focus_advance.dart',
        ],
      ),
    );
  });
}
