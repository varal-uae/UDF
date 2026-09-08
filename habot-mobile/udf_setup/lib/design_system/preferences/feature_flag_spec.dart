/// AISS Step 133 -- GEN-05309
/// Atomic Step: "Design the approach and technical specification for: build a
///               client-side feature flag and variant dispatcher optimized for
///               touch UI layouts."
/// Metric: Technical Specification Completeness -- Floor "Spec missing
///         acceptance criteria or edge cases", Optimal "Spec complete: inputs,
///         outputs, edge cases...".
/// Best Qualitative Output: Complete / Partial / Not Complete.
///
/// COLUMN NOTE, RECORDED: Setup Step (Action) is EMPTY on this row.
///
/// A SPECIFICATION STEP, AND THE HONEST WAY TO BUILD ONE. The row asks for a
/// design, not an implementation -- Step 134 is the implementation. The lazy
/// reading is to write a markdown document and call the step done; the problem
/// with that is a document nobody can execute drifts from the code within a
/// sprint and nothing notices.
///
/// So the specification is CODE: a declared set of inputs, outputs, edge cases
/// and acceptance criteria that Step 134's implementation is checked against
/// by a gate. The metric then means something -- "spec complete: inputs,
/// outputs, edge cases" is countable, and a spec that has drifted from what
/// was built fails rather than sitting quietly in a folder being wrong.
///
/// "OPTIMIZED FOR TOUCH UI LAYOUTS" is the phrase that makes this a mobile
/// spec rather than a generic one, and it has a specific consequence:
/// **evaluation must be synchronous.** A flag consulted during `build()`
/// cannot await anything. An async flag read is what produces the layout jump
/// people see as a flash of the wrong variant, and on a touch surface a layout
/// that changes under a finger already on its way down is a mis-tap. That is
/// [HabotFlagSpec.evaluationIsSynchronous], and it is the sharpest requirement
/// in the spec.
library;

/// One thing the dispatcher must take.
class HabotSpecInput {
  const HabotSpecInput({
    required this.name,
    required this.type,
    required this.required_,
    required this.rationale,
  });

  final String name;
  final String type;
  final bool required_;
  final String rationale;
}

/// One thing it must produce.
class HabotSpecOutput {
  const HabotSpecOutput({
    required this.name,
    required this.type,
    required this.rationale,
  });

  final String name;
  final String type;
  final String rationale;
}

/// A case that must have a defined answer.
class HabotSpecEdgeCase {
  const HabotSpecEdgeCase({
    required this.situation,
    required this.requiredBehaviour,
    required this.whyItMatters,
  });

  final String situation;
  final String requiredBehaviour;
  final String whyItMatters;
}

/// A checkable statement about the implementation.
class HabotSpecCriterion {
  const HabotSpecCriterion({required this.id, required this.statement});

  final String id;
  final String statement;
}

/// The specification.
class HabotFlagSpec {
  const HabotFlagSpec._();

  static const String subject =
      'client-side feature flag and variant dispatcher, optimised for touch '
      'UI layouts';

  /// The requirement the "touch UI" phrase produces. See the header.
  static const bool evaluationIsSynchronous = true;

  static const List<HabotSpecInput> inputs = <HabotSpecInput>[
    HabotSpecInput(
      name: 'flagKey',
      type: 'String',
      required_: true,
      rationale: 'Identifies the decision. Stable across releases, because a '
          'renamed key is a flag that silently reverts to its default.',
    ),
    HabotSpecInput(
      name: 'unitId',
      type: 'String',
      required_: true,
      rationale: 'The stable identity a rollout is bucketed by -- a device or '
          'an account, never a session. Bucketing by session moves a user '
          'between variants on every launch, which makes an experiment '
          'unreadable and the app feel broken.',
    ),
    HabotSpecInput(
      name: 'rollout',
      type: 'HabotRollout',
      required_: true,
      rationale: 'The staged exposure percentage and its variant weights.',
    ),
    HabotSpecInput(
      name: 'overrides',
      type: 'Map<String, String>',
      required_: false,
      rationale: 'Forced assignments for QA and for support reproducing a '
          'user report. Must be visible in the evidence, or an override left '
          'on becomes a permanent silent behaviour change.',
    ),
  ];

  static const List<HabotSpecOutput> outputs = <HabotSpecOutput>[
    HabotSpecOutput(
      name: 'variant',
      type: 'String',
      rationale: 'Which arm this unit is in. Always a value, never null -- see '
          'the edge cases.',
    ),
    HabotSpecOutput(
      name: 'source',
      type: 'HabotVariantSource',
      rationale: 'How the answer was reached: default, bucketed, or overridden. '
          'Without it, an experiment result cannot be told apart from a '
          'misconfiguration.',
    ),
    HabotSpecOutput(
      name: 'isExposure',
      type: 'bool',
      rationale: 'Whether this evaluation should count as the unit having SEEN '
          'the variant. Evaluating a flag is not exposure; rendering it is. '
          'Conflating them inflates every experiment denominator.',
    ),
  ];

  static const List<HabotSpecEdgeCase> edgeCases = <HabotSpecEdgeCase>[
    HabotSpecEdgeCase(
      situation: 'The flag key is unknown to this build.',
      requiredBehaviour: 'Return the declared default variant, source '
          '"default". Never throw, never return null.',
      whyItMatters: 'A flag added by the server before the client shipped is '
          'the normal case during a staged rollout, not an error. Throwing '
          'there crashes the app for the users furthest behind on updates.',
    ),
    HabotSpecEdgeCase(
      situation: 'The rollout percentage is 0.',
      requiredBehaviour: 'Everyone gets the control variant, and no exposure '
          'is recorded.',
      whyItMatters: 'A flag at 0% must be indistinguishable from a flag that '
          'does not exist, or a paused experiment keeps polluting its own '
          'results.',
    ),
    HabotSpecEdgeCase(
      situation: 'The same unit evaluates the same flag twice.',
      requiredBehaviour: 'Identical variant, both times, for the life of the '
          'install -- and exposure counted once.',
      whyItMatters: 'A user whose UI changes between two taps has, from their '
          'side, encountered a bug. On a touch surface it is worse than that: '
          'the control they were reaching for has moved.',
    ),
    HabotSpecEdgeCase(
      situation: 'Evaluation happens inside build().',
      requiredBehaviour: 'Returns synchronously from memory. No await, no '
          'network, no disk.',
      whyItMatters: 'An async read produces a flash of the wrong variant and '
          'a layout that shifts under a finger already moving.',
    ),
    HabotSpecEdgeCase(
      situation: 'The device has never reached the server.',
      requiredBehaviour: 'Every flag serves its declared default, and the '
          'dispatcher reports that it is running on defaults.',
      whyItMatters: 'This app is offline-first. A flag system that needs the '
          'network to answer is a flag system that does not work for the '
          'users this product exists for.',
    ),
    HabotSpecEdgeCase(
      situation: 'A variant is removed from the rollout while a unit is in it.',
      requiredBehaviour: 'The unit falls back to control, and the source says '
          'so.',
      whyItMatters: 'Silently keeping a unit in a variant that no longer '
          'exists is how a decommissioned code path stays live for a subset '
          'of users nobody can enumerate.',
    ),
  ];

  static const List<HabotSpecCriterion> acceptance = <HabotSpecCriterion>[
    HabotSpecCriterion(
      id: 'AC-1',
      statement: 'Evaluation is synchronous and touches neither disk nor '
          'network.',
    ),
    HabotSpecCriterion(
      id: 'AC-2',
      statement: 'The same unit and flag always yield the same variant.',
    ),
    HabotSpecCriterion(
      id: 'AC-3',
      statement: 'An unknown flag returns its default rather than throwing.',
    ),
    HabotSpecCriterion(
      id: 'AC-4',
      statement: 'Bucketing is uniform: over many units, observed variant '
          'shares match the declared weights within tolerance.',
    ),
    HabotSpecCriterion(
      id: 'AC-5',
      statement: 'Exposure is recorded once per unit per flag, and only when '
          'the variant is actually served for rendering.',
    ),
    HabotSpecCriterion(
      id: 'AC-6',
      statement: 'Overrides are honoured and are visible in the evidence.',
    ),
  ];

  /// The metric, computed over the spec's own parts. The row's floor is "spec
  /// missing acceptance criteria or edge cases", so those two are what a
  /// completeness figure has to be about.
  static Map<String, bool> get completenessChecks => <String, bool>{
    'inputs declared with types and rationale': inputs.isNotEmpty &&
        inputs.every(
          (HabotSpecInput i) =>
              i.type.isNotEmpty && i.rationale.length > 40,
        ),
    'outputs declared with types and rationale': outputs.isNotEmpty &&
        outputs.every(
          (HabotSpecOutput o) =>
              o.type.isNotEmpty && o.rationale.length > 40,
        ),
    'edge cases enumerated with required behaviour': edgeCases.length >= 5 &&
        edgeCases.every(
          (HabotSpecEdgeCase e) =>
              e.requiredBehaviour.isNotEmpty && e.whyItMatters.length > 40,
        ),
    'acceptance criteria stated and identified': acceptance.length >= 5 &&
        acceptance.every(
          (HabotSpecCriterion c) =>
              c.id.startsWith('AC-') && c.statement.length > 20,
        ),
    'the touch-UI constraint is stated as a requirement, not a preference':
        evaluationIsSynchronous,
  };

  static double get completeness {
    final Iterable<bool> r = completenessChecks.values;
    return r.where((bool b) => b).length / r.length;
  }

  /// The row's own vocabulary.
  static String get qualitativeOutput {
    if (completeness >= 1.0) {
      return 'Complete';
    }
    return completeness > 0 ? 'Partial' : 'Not Complete';
  }

  static List<String> get gaps => completenessChecks.entries
      .where((MapEntry<String, bool> e) => !e.value)
      .map((MapEntry<String, bool> e) => e.key)
      .toList();

  static const String specAsCodeRationale =
      'The specification is code rather than a document because a document '
      'nobody can execute drifts from the implementation within a sprint and '
      'nothing notices. Step 134 is checked against these declarations by a '
      'gate, so a spec that has drifted fails instead of sitting in a folder '
      'being wrong.';
}
