/// AISS GATE -- Step 147 of 155
/// Global Reference ID:       GEN-02533
/// Atomic Steps Reference ID: GEN-02533
/// Setup Step (Action): "Step 33: 'Rule of And' Automated Task Splitter"
/// Atomic Step: "Break down mobile forms into single-question steps rather
///               than long scrolling pages."
/// Metric: API Response Latency (ms) -- Floor 0.0, Optimal 100-300,
///         Ceiling 500.0. Good / Average / Poor.
///
/// A MISMATCHED METRIC, READ RATHER THAN IGNORED: splitting a form turns one
/// write into N, and the metric is the budget for one of them.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/forms/compound_field.dart';
import 'package:udf_setup/design_system/forms/field_validation.dart';
import 'package:udf_setup/design_system/forms/form_gate.dart';
import 'package:udf_setup/design_system/tokens/motion_tokens.dart';
import 'package:udf_setup/design_system/wizard/form_splitter.dart';
import 'package:udf_setup/design_system/wizard/step_machine.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  int stepsProduced = 0;

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

  /// A referral form: two standalone questions, then a declared compound
  /// address block, then one more standalone question.
  List<HabotFormField> referralForm() => <HabotFormField>[
        const HabotFormField(
          name: 'childName',
          label: 'Child\'s name',
          cde: HabotCde.personName,
        ),
        const HabotFormField(
          name: 'dateOfBirth',
          label: 'Date of birth',
          cde: HabotCde.dateIso,
        ),
        for (final CompoundPart p in HabotCompoundFields.addressBlock)
          HabotFormField(
            name: p.name,
            label: p.label,
            cde: p.cde,
            compoundGroup: 'address',
          ),
        const HabotFormField(
          name: 'contactPhone',
          label: 'Contact phone',
          cde: HabotCde.phoneNumber,
        ),
      ];

  group('GEN-02533 :: the split', () {
    gate(
      'GEN-02533-G1',
      'Atomic Step: "Break down mobile forms into SINGLE-QUESTION STEPS rather '
          'than long scrolling pages."',
      'A form becomes a sequence of steps, most holding exactly one field, and '
          'no field is lost or duplicated -- which is what makes it a split '
          'rather than a rearrangement',
      () {
        final HabotSplitPlan plan =
            HabotFormSplitter.split(referralForm());
        stepsProduced = plan.stepCount;
        return plan.isLossless &&
            plan.fieldCount == referralForm().length &&
            plan.stepCount == 4 &&
            plan.groupings.length == plan.stepCount &&
            plan.groupings
                    .where((HabotStepGrouping g) =>
                        g == HabotStepGrouping.single)
                    .length ==
                3;
      },
    );

    gate(
      'GEN-02533-G2',
      'Step 146 finding F-3: an address is four fields and one decision. '
          'Splitting it four ways turns a three-line answer into a four-screen '
          'journey, which is worse than the long form it replaces.',
      'A declared Step 44 compound block stays on one step, and the splitter '
          'reads that declaration rather than forming a second opinion about '
          'which fields belong together',
      () {
        final HabotSplitPlan plan =
            HabotFormSplitter.split(referralForm());
        final WizardStep address = plan.steps.firstWhere(
          (WizardStep s) => s.id == 'step.address',
        );
        return address.fieldNames.length ==
                HabotCompoundFields.addressBlock.length &&
            address.fieldNames.length > 1 &&
            HabotFormSplitter.compoundGroups.containsKey('address') &&
            HabotFormSplitter.compoundGroups['address']!
                .toSet()
                .containsAll(address.fieldNames) &&
            HabotFormSplitter.undeclaredMultiFieldSteps(plan).isEmpty;
      },
    );

    gate(
      'GEN-02533-G3',
      'A splitter that quietly leaves two unrelated questions together has not '
          'split the form, and the failure is invisible in a step count.',
      'A multi-field step that is NOT a declared compound group is reported -- '
          'checked by constructing that plan rather than by trusting the '
          'splitter',
      () {
        final HabotSplitPlan rogue = HabotSplitPlan(
          steps: <WizardStep>[
            const WizardStep(
              id: 'step.twoUnrelatedThings',
              title: 'Two things',
              fieldNames: <String>['a', 'b'],
            ),
          ],
          groupings: <HabotStepGrouping>[HabotStepGrouping.compound],
          fieldCount: 2,
        );
        return HabotFormSplitter.undeclaredMultiFieldSteps(rogue).length == 1 &&
            HabotFormSplitter.undeclaredMultiFieldSteps(rogue).single ==
                'step.twoUnrelatedThings';
      },
    );

    gate(
      'GEN-02533-G4',
      'A form order is usually the order the information exists in on the '
          'paper it came from, and reordering it makes a familiar form '
          'unfamiliar.',
      'Field order is preserved across the split, and the steps feed the Step '
          '20 machine rather than a parallel wizard model',
      () {
        final List<HabotFormField> form = referralForm();
        final HabotSplitPlan plan = HabotFormSplitter.split(form);
        final List<String> flattened = <String>[
          for (final WizardStep s in plan.steps) ...s.fieldNames,
        ];
        final WizardStepMachine machine = WizardStepMachine(
          steps: plan.steps,
          gate: HabotFormGateProbe.instance,
        );
        return flattened.join(',') ==
                form.map((HabotFormField f) => f.name).join(',') &&
            machine.stepCount == plan.stepCount &&
            machine.current.id == plan.steps.first.id;
      },
    );
  });

  group('GEN-02533 :: the metric, read', () {
    gate(
      'GEN-02533-G5',
      'The Atomic Step is a UI decomposition and the metric is an API latency. '
          'Ignoring the metric, or inventing an API call for it to measure, '
          'are both worse than reading it.',
      'The reading is recorded in the code -- splitting turns one write into N '
          'and the metric budgets one of them -- and the number of commits the '
          'split produces is reported rather than assumed',
      () {
        final HabotSplitPlan plan =
            HabotFormSplitter.split(referralForm());
        return HabotFormSplitter.commitsFor(plan) == plan.stepCount &&
            HabotFormSplitter.commitsFor(plan) > 1 &&
            HabotFormSplitter.metricReadingNote.contains(
              'one write into N writes',
            ) &&
            HabotFormSplitter.metricReadingNote.contains('are both worse');
      },
    );

    gate(
      'GEN-02533-G6',
      'Metric: Floor 0.0, Optimal 100-300ms, Ceiling 500ms. Good/Average/Poor.',
      'The bands come from tokens rather than literals, a commit inside the '
          'optimal window reads as Good, one between the window and the '
          'ceiling as Average, and one past the ceiling as Poor',
      () =>
          HabotFormSplitter.optimalMin ==
              HabotMotion.formStepCommitOptimalMin &&
          HabotFormSplitter.optimalMax ==
              HabotMotion.formStepCommitOptimalMax &&
          HabotFormSplitter.ceiling == HabotMotion.formStepCommitCeiling &&
          HabotFormSplitter.bandFor(const Duration(milliseconds: 200)) ==
              'Good' &&
          HabotFormSplitter.bandFor(const Duration(milliseconds: 50)) ==
              'Good' &&
          HabotFormSplitter.bandFor(const Duration(milliseconds: 420)) ==
              'Average' &&
          HabotFormSplitter.bandFor(const Duration(milliseconds: 900)) ==
              'Poor' &&
          HabotFormSplitter.withinCeiling(const Duration(milliseconds: 500)) &&
          !HabotFormSplitter.withinCeiling(const Duration(milliseconds: 501)),
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-02533',
        atomicStepReferenceId: 'GEN-02533',
        setupStepAction: 'Step 33: "Rule of And" Automated Task Splitter',
        implementationOrder: 147,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotFormSplitter / HabotSplitPlan',
          'Component Properties':
              '${HabotFormSplitter.compoundGroups.length} declared compound '
              'groups read from Step 44; the sample referral form splits into '
              '$stepsProduced steps; output is WizardStep for the Step 20 '
              'machine',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'Zero-dependency row. The metric is an API latency on a UI '
              'decomposition step; the reading taken is recorded in '
              'HabotFormSplitter.metricReadingNote.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'API Response Latency (ms), per step commit',
            observed:
                'Budgeted, not yet measured against a server. The split turns '
                'one form write into $stepsProduced, and each is budgeted at '
                '${HabotMotion.formStepCommitOptimalMin.inMilliseconds}-'
                '${HabotMotion.formStepCommitOptimalMax.inMilliseconds}ms '
                'with a hard ceiling of '
                '${HabotMotion.formStepCommitCeiling.inMilliseconds}ms. Step '
                '153 measures actual saves against these bands.',
            floor: '0.0',
            optimal: '100-300',
            ceiling: '500.0',
            higherIsBetter: false,
          ),
          const AissMeasurement(
            metricName: 'Fields lost or duplicated by the split',
            observed:
                '0. Every field appears exactly once across the produced '
                'steps, which is what makes a split a split rather than a '
                'rearrangement, and a declared compound block stays whole.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/wizard/form_splitter.dart',
        ],
      ),
    );
  });
}

/// A form gate for the machine constructed in G4. The split itself does not
/// validate anything, so the gate only has to exist.
class HabotFormGateProbe {
  const HabotFormGateProbe._();

  static final HabotFormGate instance = HabotFormGate();
}
