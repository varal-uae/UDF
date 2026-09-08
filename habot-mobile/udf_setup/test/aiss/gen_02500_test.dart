/// AISS GATE -- Step 148 of 155
/// Global Reference ID:       GEN-02500
/// Atomic Steps Reference ID: GEN-02500
/// Setup Step (Action) / Atomic Step: "Display only the specific Byt and one
///   input field on the screen."
/// Metric: Data Validation Pass Rate (%) -- Floor 0.95, Optimal 0.999,
///         Ceiling 1.0. Pass / Fail.
///
/// A UI RULE CARRYING A VALIDATION METRIC, because showing one question at a
/// time changes WHEN an error can be caught.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/forms/field_validation.dart';
import 'package:udf_setup/design_system/forms/form_gate.dart';
import 'package:udf_setup/design_system/wizard/form_splitter.dart';
import 'package:udf_setup/design_system/wizard/single_field_step.dart';
import 'package:udf_setup/design_system/wizard/step_machine.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  double passRate = 0;
  double caughtRate = 0;

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

  List<HabotFormField> form() => const <HabotFormField>[
        HabotFormField(
          name: 'childName',
          label: 'Name',
          cde: HabotCde.personName,
        ),
        HabotFormField(
          name: 'dateOfBirth',
          label: 'Date of birth',
          cde: HabotCde.dateIso,
        ),
        HabotFormField(
          name: 'contactPhone',
          label: 'Phone',
          cde: HabotCde.phoneNumber,
        ),
      ];

  ({WizardStepMachine machine, HabotFormGate gate}) wizard() {
    final HabotFormGate g = HabotFormGate();
    return (
      machine: WizardStepMachine(
        steps: HabotFormSplitter.split(form()).steps,
        gate: g,
      ),
      gate: g,
    );
  }

  Map<String, HabotCde> cdes() => <String, HabotCde>{
        for (final HabotFormField f in form()) f.name: f.cde,
      };

  group('GEN-02500 :: one Byt, one field', () {
    gate(
      'GEN-02500-G1',
      'Atomic Step: "Display ONLY the specific Byt and ONE input field on the '
          'screen."',
      'Every step produced from a form is a single decision, and the rule is '
          'checkable rather than a convention -- a step holding two unrelated '
          'fields is reported by name',
      () {
        final List<WizardStep> steps =
            HabotFormSplitter.split(form()).steps;
        const WizardStep rogue = WizardStep(
          id: 'step.two',
          title: 'Two',
          fieldNames: <String>['a', 'b'],
        );
        return steps.every(HabotSingleFieldStep.isSingleDecision) &&
            HabotSingleFieldStep.violations(steps).isEmpty &&
            !HabotSingleFieldStep.isSingleDecision(rogue) &&
            HabotSingleFieldStep.violations(<WizardStep>[rogue]).single
                .contains('step.two') &&
            HabotSingleFieldStep.visibleFields ==
                HabotFormSplitter.fieldsPerSingleStep;
      },
    );

    gate(
      'GEN-02500-G2',
      '"Only one input field" is a rule about what is ABSENT, and a rule about '
          'absence needs a list or it cannot be checked.',
      'The step surface contract states what may appear and what may not, the '
          'two lists do not overlap, and a floating action button is on the '
          'forbidden side -- which is what Step 154 then enforces',
      () {
        final Set<String> permitted =
            HabotStepSurfaceContract.permittedElements.toSet();
        final Set<String> forbidden =
            HabotStepSurfaceContract.forbiddenElements.toSet();
        return permitted.intersection(forbidden).isEmpty &&
            permitted.length >= 6 &&
            forbidden.length >= 5 &&
            HabotStepSurfaceContract.permits(
              'the Byt this question belongs to',
            ) &&
            HabotStepSurfaceContract.forbids('a floating action button') &&
            HabotStepSurfaceContract.forbids(
              'a second unrelated input field',
            ) &&
            HabotSingleFieldStep.bytIsNotDecorationNote.contains('Step 88');
      },
    );
  });

  group('GEN-02500 :: where an error gets caught', () {
    gate(
      'GEN-02500-G3',
      'Metric: Data Validation Pass Rate. Floor 0.95, optimal 0.999, '
          'ceiling 1.0.',
      'A form filled correctly reaches submission with every entry valid, and '
          'the pass rate is defined over what REACHES submission rather than '
          'over every keystroke -- which would report ordinary typing mistakes '
          'as a system failure',
      () {
        final ({WizardStepMachine machine, HabotFormGate gate}) w = wizard();
        final List<HabotEntryOutcome> outcomes = HabotSingleFieldStep.walk(
          machine: w.machine,
          gate: w.gate,
          entries: <String, String>{
            'childName': 'Amara Okafor',
            'dateOfBirth': '2018-04-11',
            'contactPhone': '07700 900123',
          },
          cdes: cdes(),
        );
        passRate = HabotSingleFieldStep.validationPassRate(outcomes);
        return outcomes.length == 3 &&
            outcomes.every((HabotEntryOutcome o) => o.isValid) &&
            passRate == 1.0 &&
            passRate >= HabotSingleFieldStep.optimal &&
            passRate >= HabotSingleFieldStep.floor;
      },
    );

    gate(
      'GEN-02500-G4',
      'On a long page a user answers twenty questions and then meets twenty '
          'errors at once, having lost the context for nineteen of them. The '
          'interesting number is WHERE an invalid entry is caught.',
      'An invalid entry is refused on the step it was made on rather than '
          'travelling to the end of the form, and the wizard does not advance '
          'past it',
      () {
        final ({WizardStepMachine machine, HabotFormGate gate}) w = wizard();
        final List<HabotEntryOutcome> outcomes = HabotSingleFieldStep.walk(
          machine: w.machine,
          gate: w.gate,
          entries: <String, String>{
            'childName': 'Amara Okafor',
            'dateOfBirth': 'not a date',
            'contactPhone': '07700 900123',
          },
          cdes: cdes(),
        );
        caughtRate = HabotSingleFieldStep.caughtAtSourceRate(outcomes);
        final HabotEntryOutcome bad = outcomes.firstWhere(
          (HabotEntryOutcome o) => o.fieldName == 'dateOfBirth',
        );
        return !bad.isValid &&
            bad.caughtAtStep &&
            bad.stepId == 'step.dateOfBirth' &&
            caughtRate == 1.0 &&
            HabotSingleFieldStep.errorsDeferredToEnd(outcomes) == 1 &&
            w.machine.index == 1 &&
            w.machine.lastBlock == StepBlockReason.validationFailed;
      },
    );

    gate(
      'GEN-02500-G5',
      'A rate that cannot fall is not a measurement. The pass rate has to drop '
          'when something slips past its step.',
      'An outcome recorded as invalid AND not caught at its step lowers both '
          'rates -- constructed directly, because the wizard itself will not '
          'produce that state and a check that can only ever pass proves '
          'nothing',
      () {
        const List<HabotEntryOutcome> slipped = <HabotEntryOutcome>[
          HabotEntryOutcome(
            stepId: 'step.a',
            fieldName: 'a',
            isValid: true,
            caughtAtStep: true,
          ),
          HabotEntryOutcome(
            stepId: 'step.b',
            fieldName: 'b',
            isValid: false,
            caughtAtStep: false,
          ),
        ];
        return HabotSingleFieldStep.validationPassRate(slipped) == 0.5 &&
            HabotSingleFieldStep.validationPassRate(slipped) <
                HabotSingleFieldStep.floor &&
            HabotSingleFieldStep.caughtAtSourceRate(slipped) == 0.0;
      },
    );

    gate(
      'GEN-02500-G6',
      'A metric read as "how many submissions pass" would be 1.0 by '
          'construction and prove nothing, and reporting it as evidence would '
          'be the dishonest reading of this row.',
      'The reading taken is recorded in the code, naming which number carries '
          'the weight and why',
      () =>
          HabotSingleFieldStep.metricReadingNote.contains(
            'changes WHEN an error can be caught',
          ) &&
          HabotSingleFieldStep.metricReadingNote.contains(
            'a number that cannot fall is not evidence',
          ) &&
          HabotSingleFieldStep.ceiling == 1.0 &&
          HabotSingleFieldStep.optimal == 0.999,
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-02500',
        atomicStepReferenceId: 'GEN-02500',
        setupStepAction:
            'Display only the specific Byt and one input field on the screen.',
        implementationOrder: 148,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name':
              'HabotSingleFieldStep / HabotStepSurfaceContract',
          'Component Properties':
              '${HabotStepSurfaceContract.permittedElements.length} permitted '
              'surface elements, '
              '${HabotStepSurfaceContract.forbiddenElements.length} forbidden; '
              'one field per step unless the fields are a declared Step 44 '
              'compound block',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'Zero-dependency row. The submission pass rate is 1.0 by '
              'construction of the Step 20 gate, so the measurement that '
              'carries the weight is caughtAtSourceRate.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Data Validation Pass Rate (%)',
            observed:
                '${passRate.toStringAsFixed(3)} over the entries that reach '
                'submission. Defined as valid entries over what reaches '
                'submission -- everything valid plus anything invalid that '
                'slipped past its own step -- so it falls the moment a step '
                'advances without its fields having been judged, and is '
                'demonstrated falling to 0.5 on a constructed case.',
            floor: '0.95',
            optimal: '0.999',
            ceiling: '1.0',
          ),
          AissMeasurement(
            metricName: 'Invalid entries caught on the step that made them',
            observed:
                '${(caughtRate * 100).toStringAsFixed(0)}%. On a long page the '
                'same form would have shown its errors at the end, when the '
                'user has lost the context for all but the last question. This '
                'is what the decomposition buys, and it is the number worth '
                'reporting.',
            floor: '0.95',
            optimal: '1.0',
            ceiling: '1.0',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/wizard/single_field_step.dart',
        ],
      ),
    );
  });
}
