/// AISS Step 147 -- GEN-02533
/// Setup Step (Action): "Step 33: 'Rule of And' Automated Task Splitter"
/// Atomic Step: "Break down mobile forms into single-question steps rather
///               than long scrolling pages."
/// Metric: API Response Latency (ms) -- Floor 0.0, Optimal 100-300,
///         Ceiling 500.0. Good / Average / Poor.
///
/// **A MISMATCHED METRIC, AND THE HONEST READING OF IT.** The Atomic Step is a
/// UI decomposition; the metric is an API latency. They do not obviously
/// belong to each other, and the lazy move is either to ignore the metric or
/// to invent an API call so it has something to measure.
///
/// The real connection is a consequence of the decomposition itself. A long
/// scrolling page saves once, at the end. A form split into single-question
/// steps saves at every step -- that is what makes Step 153's per-field
/// autosave possible and Step 146's finding F-3 survivable -- so splitting a
/// form turns one write into N writes. The metric is the budget for one of
/// those writes: under 500ms or the wizard feels like it is fighting the user
/// at every step, and 100-300ms is the band where a step transition covers the
/// save entirely. That reading is recorded rather than assumed.
///
/// **THE "RULE OF AND" IS THE SPLITTING RULE, AND IT IS NOT "ONE FIELD".**
/// Step 146 finding F-3: an address is four fields and one decision. Splitting
/// it four ways turns a three-line answer into a four-screen journey, which is
/// worse than the long form it replaces. Step 44 already declares which field
/// groups are one decision (`HabotCompoundFields`), so this splitter reads
/// that declaration instead of inventing a second opinion about it.
///
/// **IT PRODUCES THE STEP 20 TYPE.** `WizardStep` and `WizardStepMachine`
/// already exist, with the validation gating, the draft and the progress
/// fraction. This step produces steps for that machine rather than a parallel
/// one -- a second wizard model would be exactly the drift these steps exist
/// to prevent.
library;

import '../forms/compound_field.dart';
import '../forms/field_validation.dart';
import '../tokens/motion_tokens.dart';
import 'step_machine.dart';

/// One field a form asks for, before it is assigned to a step.
class HabotFormField {
  const HabotFormField({
    required this.name,
    required this.label,
    required this.cde,
    this.required_ = true,
    this.compoundGroup,
  });

  final String name;
  final String label;
  final HabotCde cde;
  final bool required_;

  /// The Step 44 compound block this field belongs to, if any. Fields sharing
  /// a group are one decision and stay on one step.
  final String? compoundGroup;
}

/// Why a step holds more than one field.
enum HabotStepGrouping {
  /// One field, one decision. The default.
  single,

  /// A Step 44 compound block: several fields, one decision.
  compound,
}

/// The result of splitting one form.
class HabotSplitPlan {
  const HabotSplitPlan({
    required this.steps,
    required this.groupings,
    required this.fieldCount,
  });

  final List<WizardStep> steps;

  /// Why each step is shaped the way it is, parallel to [steps].
  final List<HabotStepGrouping> groupings;

  final int fieldCount;

  int get stepCount => steps.length;

  /// Fields per step, which is the number the objective is really about.
  double get averageFieldsPerStep =>
      steps.isEmpty ? 0 : fieldCount / steps.length;

  /// Every field appears exactly once across the steps. The property that
  /// makes a split a split rather than a rearrangement.
  bool get isLossless {
    final List<String> all = <String>[
      for (final WizardStep s in steps) ...s.fieldNames,
    ];
    return all.length == fieldCount && all.toSet().length == fieldCount;
  }
}

/// Splits a long form into wizard steps.
class HabotFormSplitter {
  const HabotFormSplitter._();

  /// Step 148's rule: a single-decision step shows one input field.
  static const int fieldsPerSingleStep = 1;

  /// The groups Step 44 declares as one decision. Read, not restated.
  static Map<String, List<String>> get compoundGroups => <String, List<String>>{
        for (final MapEntry<String, List<CompoundPart>> e
            in HabotCompoundFields.all.entries)
          e.key: e.value.map((CompoundPart p) => p.name).toList(),
      };

  /// Split a form, preserving field order.
  ///
  /// Consecutive fields in the same compound group become one step; every
  /// other field becomes its own. Order is preserved because a form's order is
  /// usually the order the information exists in on the paper it came from,
  /// and reordering it makes a familiar form unfamiliar.
  static HabotSplitPlan split(List<HabotFormField> fields) {
    final List<WizardStep> steps = <WizardStep>[];
    final List<HabotStepGrouping> groupings = <HabotStepGrouping>[];
    int i = 0;
    while (i < fields.length) {
      final HabotFormField field = fields[i];
      final String? group = field.compoundGroup;
      if (group == null) {
        steps.add(
          WizardStep(
            id: 'step.${field.name}',
            title: field.label,
            fieldNames: <String>[field.name],
          ),
        );
        groupings.add(HabotStepGrouping.single);
        i++;
        continue;
      }
      final List<String> names = <String>[];
      final int start = i;
      while (i < fields.length && fields[i].compoundGroup == group) {
        names.add(fields[i].name);
        i++;
      }
      steps.add(
        WizardStep(
          id: 'step.$group',
          title: fields[start].label,
          fieldNames: names,
        ),
      );
      groupings.add(
        names.length == 1
            ? HabotStepGrouping.single
            : HabotStepGrouping.compound,
      );
    }
    return HabotSplitPlan(
      steps: steps,
      groupings: groupings,
      fieldCount: fields.length,
    );
  }

  /// Steps holding more than one field that are NOT a declared compound
  /// group. Empty is the requirement: this is the check that stops the
  /// splitter quietly leaving two unrelated questions together.
  static List<String> undeclaredMultiFieldSteps(HabotSplitPlan plan) {
    final Set<String> declared = compoundGroups.keys
        .map((String g) => 'step.$g')
        .toSet();
    return plan.steps
        .where((WizardStep s) =>
            s.fieldNames.length > fieldsPerSingleStep &&
            !declared.contains(s.id))
        .map((WizardStep s) => s.id)
        .toList();
  }

  // ---- the row's metric, as read above ------------------------------------

  static Duration get optimalMin => HabotMotion.formStepCommitOptimalMin;
  static Duration get optimalMax => HabotMotion.formStepCommitOptimalMax;
  static Duration get ceiling => HabotMotion.formStepCommitCeiling;

  /// The row's qualitative vocabulary, applied to one step commit.
  static String bandFor(Duration observed) {
    if (observed >= optimalMin && observed <= optimalMax) {
      return 'Good';
    }
    if (observed < optimalMin) {
      // Faster than the optimal band is not a problem; the row's floor is 0.
      return 'Good';
    }
    return observed <= ceiling ? 'Average' : 'Poor';
  }

  static bool withinCeiling(Duration observed) => observed <= ceiling;

  /// How many commits a split produces, against the one a long page would.
  /// The number the metric is a budget for.
  static int commitsFor(HabotSplitPlan plan) => plan.stepCount;

  static const String metricReadingNote =
      'The Atomic Step is a UI decomposition and the metric is an API '
      'latency. The connection is a consequence of the decomposition: a long '
      'scrolling page saves once, at the end; a form split into single '
      'questions saves at every step -- which is what makes Step 153 possible '
      'and Step 146 finding F-3 survivable -- so splitting turns one write '
      'into N writes. The metric is the budget for one of those writes. That '
      'reading is recorded rather than assumed, and the alternative readings '
      '(ignore the metric, or invent an API call for it to measure) are both '
      'worse.';

  static const String ruleOfAndNote =
      'The splitting rule is not "one field". An address is four fields and '
      'one decision; splitting it four ways turns a three-line answer into a '
      'four-screen journey, which is worse than the long form it replaces. '
      'Step 44 already declares which groups are one decision, and this '
      'splitter reads that declaration rather than forming a second opinion '
      'about it.';

  static const String reusesStepMachineNote =
      'The splitter produces WizardStep values for the Step 20 '
      'WizardStepMachine, which already owns validation gating, the draft and '
      'the progress fraction. A parallel wizard model would be the drift these '
      'steps exist to prevent.';
}
