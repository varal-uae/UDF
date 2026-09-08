/// AISS Step 97 -- GEN-04242
/// "Align the implementation with the platform architecture: Automated
///  accessibility linter integration in Cloud Build pipelines."
///
/// TRANSLATION RECORDED. The row names Cloud Build. This project has no Cloud
/// Build pipeline. It has a poka-yoke guard with six build-failing rules and
/// `tool/verify_aiss.sh`, which is the same mechanism under a different name.
/// Per the decision recorded in the Steps 96-110 build order, the
/// accessibility rules are added to THAT guard rather than to a second
/// pipeline, and per the same decision **they fail the build**.
///
/// WHY THE RULES LIVE IN `lib/` AND THE SCANNER LIVES IN `test/guards/`. A
/// rule that only exists inside a test file cannot be read by anything else --
/// not by the Step 96 audit, not by the Step 98 findings register, not by a
/// developer who wants to know what will fail before they run it. So the rules
/// are DATA here, and `test/guards/a11y_rules_test.dart` is the thing that
/// walks the source and applies them. That split is also what lets the rule
/// set be unit-tested against planted violations, which a guard embedded in
/// its own scanner cannot be.
///
/// EACH RULE ANSWERS ONE QUESTION: what did Steps 99-110 make possible that a
/// developer could still bypass by accident? A rule that forbids something no
/// one was going to write is noise; every rule below closes a route that is
/// currently open.
library;

/// One build-failing accessibility rule.
class HabotA11yRule {
  const HabotA11yRule({
    required this.id,
    required this.pattern,
    required this.message,
    required this.owner,
    this.exemptPaths = const <String>{},
    this.exemptionRationale,
  });

  /// e.g. 'A11Y_RAW_IMAGE'.
  final String id;

  /// Applied to source with comments and string literals already blanked out,
  /// exactly as the existing poka-yoke guard does it -- so documentation that
  /// MENTIONS a banned construct is never mistaken for code that uses one.
  final RegExp pattern;

  /// What a developer reads when the build stops. Says what to do instead,
  /// not merely what is wrong.
  final String message;

  /// The implementation step this rule protects.
  final String owner;

  /// Files allowed to contain the construct -- normally the one file that
  /// implements the sanctioned alternative.
  final Set<String> exemptPaths;

  /// Why those files are exempt. Required in practice: an exemption without a
  /// reason is how a rule dies.
  final String? exemptionRationale;

  bool appliesTo(String path) => !exemptPaths.contains(path);

  @override
  String toString() => '$id (${owner.split(' ').first})';
}

/// The rule set.
class HabotA11yRules {
  const HabotA11yRules._();

  /// SC 1.1.1. Step 100 gave this project two image widgets, one of which
  /// forces a decision about alt text. A bare `Image(` bypasses both.
  static final HabotA11yRule rawImage = HabotA11yRule(
    id: 'A11Y_RAW_IMAGE',
    pattern: RegExp(r'(?<!Habot)\bImage\s*(?:\.\s*(?:asset|network|file|memory)\s*)?\('),
    message:
        'A raw Image(...) has no alt text and no way to declare it has none. '
        'Use HabotImage(alt: ...) for an image that carries information, or '
        'HabotDecorativeImage(...) for one that does not.',
    owner: 'Step 100 GEN-02764',
    exemptPaths: <String>{'lib/design_system/a11y/image_semantics.dart'},
    exemptionRationale:
        'The two sanctioned widgets are built there; they are the only place '
        'a raw Image may be constructed.',
  );

  /// SC 4.1.2. An icon-only control whose icon carries nothing but an
  /// `IconData` announces as "button" and stops.
  ///
  /// THIS RULE EXISTS BECAUSE OF A REGRESSION THIS PROJECT INTRODUCED. Step 24
  /// (MUFCE-028) required every hover tooltip to be stripped, and the fix
  /// applied at the time was `tooltip: ''`. On an `IconButton` the tooltip is
  /// ALSO the accessible name, so removing the hover affordance removed the
  /// name with it -- correct for touch, silent for a screen reader. Two
  /// controls in Steps 1-95 are in that state and are fixed in this batch.
  ///
  /// SCOPE, NARROWED AFTER A FALSE POSITIVE. The first version of this rule
  /// matched ANY `icon: const Icon(Icons.x)`, and it fired on
  /// `TextButton.icon(icon: ..., label: Text('Filter'))` -- which is correct
  /// code. An icon beside a visible label needs no name of its own; Flutter
  /// adds no semantics node for an Icon without a semanticLabel, which is
  /// exactly right there. The defect is an icon that is the button's ONLY
  /// content, so the rule now requires the enclosing IconButton.
  static final HabotA11yRule bareIconButton = HabotA11yRule(
    id: 'A11Y_UNNAMED_ICON_BUTTON',
    pattern: RegExp(
      r'IconButton\s*\((?:[^()]|\([^()]*\))*icon\s*:\s*'
      r'(?:const\s+)?Icon\s*\(\s*Icons\.\w+\s*\)',
    ),
    message:
        'An IconButton whose Icon carries nothing but an IconData has no '
        'accessible name -- a screen reader announces "button" and stops. Add '
        'semanticLabel: to the Icon, or wrap the control in HabotHintedAction '
        'so it carries the Step 99 consequence hint too. Note that tooltip: '
        'is NOT the answer here: Step 24 banned hover affordances. An icon '
        'beside a visible label is fine and is not matched.',
    owner: 'Step 99 GEN-04572',
  );

  /// SC 1.4.4. Step 102 exists so that text scales. A hardcoded
  /// `TextScaler.noScaling` or a `textScaleFactor: 1.0` puts it back.
  static final HabotA11yRule suppressedTextScaling = HabotA11yRule(
    id: 'A11Y_TEXT_SCALING_SUPPRESSED',
    pattern: RegExp(
      r'TextScaler\.noScaling|textScaleFactor\s*:|textScaler\s*:\s*TextScaler\.linear\s*\(\s*1',
    ),
    message:
        'This pins text at one size, which is precisely what WCAG SC 1.4.4 '
        'forbids. Text scaling is applied once, by HabotTextScaleScope, and '
        'clamped to the audited range there.',
    owner: 'Step 102 GEN-04363',
    exemptPaths: <String>{'lib/design_system/a11y/text_scaling.dart'},
    exemptionRationale:
        'The clamp itself is declared there and is the sanctioned single '
        'point at which the OS scale is intercepted.',
  );

  /// SC 2.1.2. A `FocusScope` that traps without an exit is the failure mode
  /// Step 101 is built to prevent; `HabotFocusTrap` cannot be built without
  /// `onDismiss`.
  static final HabotA11yRule rawBlockSemantics = HabotA11yRule(
    id: 'A11Y_RAW_SEMANTIC_MODAL',
    pattern: RegExp(r'\bBlockSemantics\s*\('),
    message:
        'BlockSemantics removes everything behind it from the accessibility '
        'tree. On its own that is a focus trap with no documented way out, '
        'which fails SC 2.1.2. Use HabotFocusTrap, which requires onDismiss.',
    owner: 'Step 101 GEN-01826',
    exemptPaths: <String>{'lib/design_system/a11y/focus_trap.dart'},
    exemptionRationale:
        'HabotFocusTrap is the sanctioned wrapper and is the one place the '
        'barrier is constructed.',
  );

  /// SC 1.3.1 / 4.1.2. An `ExcludeSemantics` around a whole interactive
  /// subtree silently deletes it from the accessibility tree. Used correctly
  /// it hides a decorative child INSIDE a Semantics container; used carelessly
  /// it makes a control invisible to a screen reader while looking perfect.
  static final HabotA11yRule semanticsSuppression = HabotA11yRule(
    id: 'A11Y_SEMANTICS_EXCLUDED_AT_ROOT',
    pattern: RegExp(r'return\s+(?:const\s+)?ExcludeSemantics\s*\('),
    message:
        'Returning ExcludeSemantics as a widget root removes this whole '
        'subtree from the accessibility tree. If the content is decorative, '
        'say so with HabotDecorativeImage; if it is not, wrap it in Semantics '
        'and exclude only the visual child.',
    owner: 'Step 99 GEN-04572',
    exemptPaths: <String>{'lib/design_system/a11y/image_semantics.dart'},
    exemptionRationale:
        'HabotDecorativeImage IS the sanctioned way to declare empty alt, and '
        'excluding at its root is the mechanism.',
  );

  /// SC 2.5.8 / TTMAC-011. Step 10 declares the touch minimum; a literal
  /// `minimumSize` on a button is a second, unaudited declaration.
  static final HabotA11yRule literalTouchSize = HabotA11yRule(
    id: 'A11Y_LITERAL_TOUCH_SIZE',
    pattern: RegExp(r'minimumSize\s*:\s*(?:const\s+)?(?:WidgetStatePropertyAll\s*\(\s*)?Size\s*\(\s*\d'),
    message:
        'A literal minimum size bypasses the touch standard. Read '
        'HabotDensity.minTouchTarget, or size the control with '
        'HabotTapAccuracyAudit.sizeRequiredFor for its reach band.',
    owner: 'Step 108 GEN-00090',
  );

  static List<HabotA11yRule> get all => <HabotA11yRule>[
    rawImage,
    bareIconButton,
    suppressedTextScaling,
    rawBlockSemantics,
    semanticsSuppression,
    literalTouchSize,
  ];

  static HabotA11yRule byId(String id) =>
      all.firstWhere((HabotA11yRule r) => r.id == id);

  /// Every rule names the step it protects, and every exemption gives a
  /// reason. Checked rather than assumed -- this is the property that decays
  /// first as a rule set grows.
  static bool get isWellFormed => all.every(
    (HabotA11yRule r) =>
        r.id.startsWith('A11Y_') &&
        r.owner.isNotEmpty &&
        r.message.length > 40 &&
        (r.exemptPaths.isEmpty || r.exemptionRationale != null),
  );

  /// Rules that carry no exemption at all. Recorded because an absolute rule
  /// is a stronger claim than an exempted one, and worth being able to count.
  static List<HabotA11yRule> get absolute =>
      all.where((HabotA11yRule r) => r.exemptPaths.isEmpty).toList();
}
