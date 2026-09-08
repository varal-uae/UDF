/// AISS GATE -- Step 149 of 155
/// Global Reference ID:       GEN-01087
/// Atomic Steps Reference ID: GEN-01087
/// Setup Step (Action) / Atomic Step: "Design a wizard layout interface
///   featuring clear back and next navigation affordances."
/// Metric: Entity Decomposition Structural Integrity -- Floor 0.95,
///         Optimal 1.0, Ceiling 1.0. Pass / Fail.
///
/// "CLEAR" IS THE REQUIREMENT, AND A DISABLED BUTTON IS NOT CLEAR.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/forms/field_validation.dart';
import 'package:udf_setup/design_system/forms/form_gate.dart';
import 'package:udf_setup/design_system/i18n/language_preference.dart';
import 'package:udf_setup/design_system/i18n/localization_objective.dart';
import 'package:udf_setup/design_system/wizard/step_machine.dart';
import 'package:udf_setup/design_system/wizard/wizard_navigation.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  double integrity = 0;

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

  const List<WizardStep> steps = <WizardStep>[
    WizardStep(id: 's1', title: 'Name', fieldNames: <String>['name']),
    WizardStep(id: 's2', title: 'Date', fieldNames: <String>['date']),
    WizardStep(id: 's3', title: 'Phone', fieldNames: <String>['phone']),
  ];

  ({WizardStepMachine machine, HabotFormGate gate}) build() {
    final HabotFormGate g = HabotFormGate();
    for (final String f in <String>['name', 'date', 'phone']) {
      g
        ..register(f)
        ..update(f, const FieldValidationResult.valid());
    }
    return (
      machine: WizardStepMachine(steps: steps, gate: g),
      gate: g,
    );
  }

  HabotWizardNavigation nav(
    WizardStepMachine m, {
    HabotTextDirectionality d = HabotTextDirectionality.leftToRight,
  }) =>
      HabotWizardNavigation(machine: m, direction: d);

  group('GEN-01087 :: clear affordances', () {
    gate(
      'GEN-01087-G1',
      'A greyed-out Next is unambiguous to the person who wrote it and silent '
          'to everyone else -- and it is skipped by some screen readers '
          'entirely, so a blind user gets no forward affordance and no '
          'explanation.',
      'The forward control stays enabled and, when the step cannot be left, '
          'refuses with a reason carried as a translatable key rather than an '
          'English string',
      () {
        final ({WizardStepMachine machine, HabotFormGate gate}) w = build();
        w.gate.update(
          'name',
          const FieldValidationResult.invalid('Enter a name.'),
        );
        final HabotWizardNavigation n = nav(w.machine);
        final HabotNavigationOutcome out = n.forward();
        return n.forwardIsEnabled &&
            !out.moved &&
            out.wasRefused &&
            out.blockedBy == StepBlockReason.validationFailed &&
            out.refusalMessageKey == 'wizard.blocked.validation' &&
            HabotMessageKeys.all.contains(out.refusalMessageKey) &&
            HabotWizardNavigation.enabledNextNote.contains(
              'skipped by some screen readers',
            );
      },
    );

    gate(
      'GEN-01087-G2',
      'Step 146 decision D-1: validation blocks progress, not retreat. A '
          'wizard that traps someone on a step they cannot satisfy has no exit '
          'but force-quitting, which loses the form.',
      'Back succeeds from a step whose own fields are invalid, and the back '
          'control is hidden on the first step rather than shown doing nothing',
      () {
        final ({WizardStepMachine machine, HabotFormGate gate}) w = build();
        final HabotWizardNavigation n = nav(w.machine);
        final bool hiddenAtStart = !n.backwardIsVisible;
        n.forward();
        w.gate.update(
          'date',
          const FieldValidationResult.invalid('Enter a date.'),
        );
        final HabotNavigationOutcome back = n.backward();
        return hiddenAtStart &&
            back.moved &&
            back.index == 0 &&
            back.refusalMessageKey == null &&
            HabotWizardNavigation.backAlwaysNote.contains(
              'blocks progress, not retreat',
            );
      },
    );

    gate(
      'GEN-01087-G3',
      'A "Next" that submits is a Next that surprises.',
      'The forward label becomes Done on the last step, both labels are keys '
          'the catalogue declares, and every block reason has a message rather '
          'than a silent null',
      () {
        final ({WizardStepMachine machine, HabotFormGate gate}) w = build();
        final HabotWizardNavigation n = nav(w.machine);
        final String first = n.forwardLabelKey;
        n.forward();
        n.forward();
        return first == 'action.next' &&
            n.forwardLabelKey == 'action.done' &&
            HabotMessageKeys.all.contains(n.forwardLabelKey) &&
            HabotMessageKeys.all.contains(n.backwardLabelKey) &&
            StepBlockReason.values
                .where((StepBlockReason r) => r != StepBlockReason.none)
                .every((StepBlockReason r) =>
                    HabotWizardNavigation.refusalKeyFor(r) != null) &&
            HabotWizardNavigation.refusalKeyFor(StepBlockReason.none) == null;
      },
    );

    gate(
      'GEN-01087-G4',
      'Step 138 F-1 and Step 146 F-1: "Back" and "Next" are semantic; leading '
          'and trailing are visual. In Urdu the forward control sits on the '
          'LEFT.',
      'The side each control sits on flips with the language, resolved in one '
          'place so no screen has to remember it, and the preference-driven '
          'constructor agrees with the explicit one',
      () {
        final ({WizardStepMachine machine, HabotFormGate gate}) w = build();
        final HabotWizardNavigation ltr = nav(w.machine);
        final HabotWizardNavigation rtl = nav(
          w.machine,
          d: HabotTextDirectionality.rightToLeft,
        );
        final HabotLanguagePreference p = HabotLanguagePreference(
          catalogues: <HabotStringCatalogue>[
            HabotEnglishStrings.catalogue,
            HabotStringCatalogue(
              localeCode: 'ur',
              strings: <String, String>{
                for (final String k in HabotMessageKeys.all) k: 'ur:$k',
              },
              source: 'gate fixture',
            ),
          ],
        )..activate('ur');
        final HabotWizardNavigation viaPreference =
            HabotWizardNavigation.forPreference(
          machine: w.machine,
          preference: p,
        );
        return ltr.forwardSide == HabotControlSide.trailing &&
            ltr.backwardSide == HabotControlSide.leading &&
            rtl.forwardSide == HabotControlSide.leading &&
            rtl.backwardSide == HabotControlSide.trailing &&
            rtl.isRightToLeft &&
            !ltr.isRightToLeft &&
            viaPreference.forwardSide == rtl.forwardSide;
      },
    );
  });

  group('GEN-01087 :: structural integrity', () {
    gate(
      'GEN-01087-G5',
      'Metric: Entity Decomposition Structural Integrity. Floor 0.95, optimal '
          '1.0.',
      'The properties that make a set of steps a wizard rather than a list of '
          'screens all hold, and they are checked against the machine actual '
          'behaviour rather than against its declaration',
      () {
        final ({WizardStepMachine machine, HabotFormGate gate}) w = build();
        integrity = HabotWizardNavigation.structuralIntegrity(w.machine);
        return integrity == 1.0 &&
            integrity >= HabotWizardNavigation.floor &&
            HabotWizardNavigation.integrityFailures(w.machine).isEmpty &&
            HabotWizardNavigation.integrityChecks(w.machine).length == 6;
      },
    );

    gate(
      'GEN-01087-G6',
      'An integrity score that cannot fall is not a measurement.',
      'A decomposition with a field on two steps scores below the floor and '
          'names the property it broke -- checked by constructing that '
          'machine, not by trusting the checker',
      () {
        final HabotFormGate g = HabotFormGate();
        final WizardStepMachine broken = WizardStepMachine(
          steps: const <WizardStep>[
            WizardStep(id: 'a', title: 'A', fieldNames: <String>['x']),
            WizardStep(id: 'a', title: 'A again', fieldNames: <String>['x']),
          ],
          gate: g,
        );
        final double score =
            HabotWizardNavigation.structuralIntegrity(broken);
        final List<String> failures =
            HabotWizardNavigation.integrityFailures(broken);
        return score < HabotWizardNavigation.floor &&
            failures.length == 2 &&
            failures.any((String f) => f.contains('unique')) &&
            failures.any((String f) => f.contains('two steps'));
      },
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-01087',
        atomicStepReferenceId: 'GEN-01087',
        setupStepAction:
            'Design a wizard layout interface featuring clear back and next '
            'navigation affordances.',
        implementationOrder: 149,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotWizardNavigation',
          'Component Properties':
              'forward always enabled and refusing with a reason; back never '
              'refused for validation; '
              '${StepBlockReason.values.length} block reasons each mapped to a '
              'message key; control sides resolved from the language',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'Zero-dependency row. Decorates the Step 20 WizardStepMachine '
              'rather than replacing it, so there is one answer to "which step '
              'am I on".',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Entity Decomposition Structural Integrity',
            observed:
                '${integrity.toStringAsFixed(2)} over six '
                'properties: unique step ids, every step owning at least one '
                'field, no field on two steps, first/last consistent with the '
                'index, and bounded progress. Demonstrated falling below the '
                'floor on a constructed decomposition with a duplicated step '
                'id and a shared field.',
            floor: '0.95',
            optimal: '1.0',
            ceiling: '1.0',
          ),
          const AissMeasurement(
            metricName: 'Forward controls that refuse without saying why',
            observed:
                '0. The control stays enabled and returns the reason as a '
                'translatable key. A greyed-out button would have scored the '
                'same on any structural check and told the user nothing -- and '
                'told a screen-reader user less than nothing, since some skip '
                'disabled controls entirely.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/wizard/wizard_navigation.dart',
        ],
      ),
    );
  });
}
