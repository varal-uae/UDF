/// AISS Step 135 -- GEN-02544
/// Atomic Step: "Set up variation mapping within the frontend state
///               management."
/// Metric: WCAG 2.2 AA Compliance Rate (%) -- Floor 0.8, Optimal 1, Ceiling 1.
///
/// COLUMN NOTE, RECORDED: Setup Step (Action) is EMPTY on this row.
///
/// A ROW DELIBERATELY NOT TAKEN AT STEPS 96-110, AND WHY IT IS TAKEN NOW. The
/// Steps 96-110 build order excluded this row with a specific reason: it
/// "carries this batch metric verbatim -- WCAG 2.2 AA Compliance Rate -- but
/// its Setup Step is 'Set up variation mapping within the frontend state
/// management'... an A/B experiment row wearing an accessibility metric.
/// Building it as accessibility work would be building the wrong thing;
/// building it as experiment infrastructure is a different batch." This is
/// that batch: Steps 133 and 134 built the dispatcher, and this is the state
/// management it maps into.
///
/// THE MISMATCHED METRIC TURNS OUT TO BE USEFUL, WHICH WAS NOT EXPECTED. A
/// WCAG compliance rate is the wrong metric for wiring variants into state --
/// but it names a real and commonly-missed hazard, so rather than discard it,
/// it is used for the thing it accidentally describes:
///
/// **Every variant must be independently accessible.** An experiment that
/// ships an inaccessible treatment arm has not run an experiment; it has
/// degraded the product for a randomly selected half of its users, invisibly,
/// and the metrics will read as a preference result. This is a real failure
/// mode and almost nobody checks for it.
///
/// So [HabotVariationMapping] refuses to register a variant that has not
/// declared an accessibility audit, and the compliance rate reported is the
/// share of REGISTERED VARIANTS that pass -- not the share of screens. That is
/// an honest use of the row's number, and the reinterpretation is recorded
/// rather than presented as what the row asked for.
///
/// THE STATE-MANAGEMENT HALF. A variant selects a value, not a code path
/// scattered through the tree. `if (flags.isEnabled(...))` sprinkled across
/// twenty widgets is untestable and undeletable; a mapping from variant name
/// to value is neither.
library;

import '../a11y/wcag_audit.dart';
import 'feature_flags.dart';

/// What is known about one variant's accessibility.
class HabotVariantAccessibility {
  const HabotVariantAccessibility({
    required this.variant,
    required this.auditedCriteria,
    required this.failingCriteria,
  });

  final String variant;

  /// Criterion ids this variant was audited against, e.g. '1.4.3'.
  final List<String> auditedCriteria;

  /// Those it failed.
  final List<String> failingCriteria;

  bool get isAudited => auditedCriteria.isNotEmpty;
  bool get passes => isAudited && failingCriteria.isEmpty;

  double get complianceRate => auditedCriteria.isEmpty
      ? 0
      : (auditedCriteria.length - failingCriteria.length) /
            auditedCriteria.length;

  Map<String, Object?> toJson() => <String, Object?>{
    'variant': variant,
    'audited': auditedCriteria,
    'failing': failingCriteria,
    'compliance_rate': complianceRate,
  };
}

/// Thrown when a variant is registered without an accessibility audit.
class HabotUnauditedVariantError extends StateError {
  HabotUnauditedVariantError(String flagKey, String variant)
    : super(
        'Variant "$variant" of "$flagKey" has no declared accessibility '
        'audit. An experiment that ships an inaccessible arm has not run an '
        'experiment -- it has degraded the product for a randomly selected '
        'share of users, invisibly, and the result will read as a preference. '
        'Declare the criteria this variant was audited against, even if the '
        'answer is that it is identical to control.',
      );
}

/// Maps a variant name to the value the UI actually uses.
///
/// One mapping per decision, held in one place. See the header for why this is
/// not a scattering of `if (isEnabled)`.
class HabotVariationMapping<T> {
  HabotVariationMapping({
    required this.flagKey,
    required this.flags,
    required Map<String, T> values,
    required Map<String, HabotVariantAccessibility> accessibility,
    required this.controlVariant,
  }) : _values = Map<String, T>.from(values),
       _accessibility = Map<String, HabotVariantAccessibility>.from(
         accessibility,
       ) {
    for (final String variant in _values.keys) {
      final HabotVariantAccessibility? a = _accessibility[variant];
      if (a == null || !a.isAudited) {
        throw HabotUnauditedVariantError(flagKey, variant);
      }
    }
    if (!_values.containsKey(controlVariant)) {
      throw StateError(
        'The mapping for "$flagKey" has no value for its control variant '
        '"$controlVariant". Every unit outside the experiment gets control, '
        'so a mapping without it has no answer for most of its users.',
      );
    }
  }

  final String flagKey;
  final HabotFeatureFlags flags;
  final String controlVariant;

  final Map<String, T> _values;
  final Map<String, HabotVariantAccessibility> _accessibility;

  Map<String, T> get values => Map<String, T>.unmodifiable(_values);

  Map<String, HabotVariantAccessibility> get accessibility =>
      Map<String, HabotVariantAccessibility>.unmodifiable(_accessibility);

  int _resolutions = 0;
  int get resolutions => _resolutions;

  /// The value for this unit. Synchronous, from the Step 134 dispatcher.
  ///
  /// [forRender] passes straight through: this is where an evaluation becomes
  /// an exposure, because this is the value that reaches the screen.
  T resolve({bool forRender = true}) {
    _resolutions++;
    final HabotVariantAssignment assignment = flags.variantOf(
      flagKey,
      forRender: forRender,
    );
    return _values[assignment.variant] ?? _values[controlVariant] as T;
  }

  /// Which variant this unit is in, without resolving a value or counting an
  /// exposure. For diagnostics and for the evidence record.
  String get currentVariant =>
      flags.variantOf(flagKey).variant;

  // ---- the reinterpreted metric ------------------------------------------

  /// The share of this mapping's variants that pass their declared audit.
  ///
  /// This is the row's metric applied to the hazard it accidentally names --
  /// see the header. It is NOT a claim about the app's overall WCAG
  /// conformance, which is Step 96's figure and is reported there.
  double get variantComplianceRate {
    if (_accessibility.isEmpty) {
      return 0;
    }
    final int passing = _accessibility.values
        .where((HabotVariantAccessibility a) => a.passes)
        .length;
    return passing / _accessibility.length;
  }

  /// Variants that would degrade the product for whoever is bucketed into
  /// them. Empty is the requirement.
  List<String> get inaccessibleVariants => _accessibility.values
      .where((HabotVariantAccessibility a) => !a.passes)
      .map(
        (HabotVariantAccessibility a) =>
            '${a.variant}: fails ${a.failingCriteria.join(", ")}',
      )
      .toList();

  static const double floor = 0.8;
  static const double optimal = 1.0;

  /// Criteria a variant must at minimum be audited against before it may
  /// ship. Not the full Step 96 set -- these are the ones a UI variation
  /// realistically changes.
  static List<String> get minimumCriteria => <String>[
    WcagCriteria.textContrast.id,
    WcagCriteria.nonTextContrast.id,
    WcagCriteria.targetSize.id,
    WcagCriteria.nameRoleValue.id,
  ];

  /// True when [a] covers everything [minimumCriteria] requires.
  static bool auditIsSufficient(HabotVariantAccessibility a) =>
      minimumCriteria.every(a.auditedCriteria.contains);

  static const String metricReinterpretation =
      'The row carries "WCAG 2.2 AA Compliance Rate" on a step about wiring '
      'variants into state management. The Steps 96-110 build order flagged '
      'the mismatch and deliberately excluded the row. Rather than discard the '
      'metric, it is used for the hazard it accidentally names: every variant '
      'must be independently accessible, or the experiment has degraded the '
      'product for a random share of users and the result will read as a '
      'preference. The rate reported is over registered VARIANTS, not screens, '
      'and it is not a claim about overall conformance -- that is Step 96.';

  static const String notTakenEarlierNote =
      'This row was deliberately not taken at Steps 96-110, recorded there as '
      '"an A/B experiment row wearing an accessibility metric... building it '
      'as experiment infrastructure is a different batch". This is that batch: '
      'Steps 133 and 134 built the dispatcher this maps into.';
}
