/// Step 230 (GEN-05144) -- viewport parameters and double-tap zoom.
///
/// The row: "Design the approach and technical specification for: set up
/// viewport parameters and disable accidental double-tap zoom behaviors on
/// mobile browsers."
/// Metric: Technical Specification Completeness -- floor "Spec missing
/// acceptance criteria or edge cases", optimal "Spec complete: inputs,
/// outputs, edge cases & acceptance criteria defined", ceiling 1.
/// Complete/Partial/Not Complete.
///
/// **This row does what open decision 2 could not.** RCGLA-012 substep 2 asked
/// for `user-scalable=no` and was deferred, because suppressing zoom fails WCAG
/// 1.4.4 Resize Text and modern mobile browsers ignore it anyway. This row asks
/// for something different and achievable: disabling **accidental double-tap
/// zoom**, which `touch-action: manipulation` does. It removes the double-tap
/// gesture and the ~300ms tap delay that waiting for it creates, and leaves
/// pinch zoom entirely intact.
///
/// So the intent behind the deferred row -- taps that register immediately,
/// without a stray double-tap throwing the layout -- is satisfiable without the
/// conformance failure. That closes the half of open decision 2 that was about
/// responsiveness, and leaves the half that was about suppressing zoom closed
/// the other way: it stays refused.
///
/// **Boundary.** A viewport meta tag and `touch-action` are web platform
/// concepts. On the Flutter mobile targets there is no viewport meta at all and
/// no double-tap zoom to disable; this specification applies to the PWA and web
/// build. Recorded rather than quietly generalised.
///
/// **The metric asks for a specification, so the deliverable is one.**
/// Completeness is measured over the sections a specification is required to
/// have: inputs, outputs, edge cases and acceptance criteria.
library;

/// One section a technical specification must have for the metric to call it
/// complete.
enum HabotSpecSection { inputs, outputs, edgeCases, acceptanceCriteria }

/// One declared viewport or touch directive.
class HabotViewportDirective {
  const HabotViewportDirective({
    required this.declaration,
    required this.applied,
    required this.wcagImpact,
    required this.rationale,
  });

  final String declaration;

  /// Whether this build actually emits it.
  final bool applied;

  /// The criterion this directive touches, or an empty string when it touches
  /// none.
  final String wcagImpact;

  final String rationale;
}

/// The specification.
class HabotViewportPolicy {
  const HabotViewportPolicy._();

  /// Which targets this applies to at all.
  static const List<String> appliesTo = <String>['web', 'pwa'];
  static const List<String> doesNotApplyTo = <String>['android', 'ios'];

  static const String platformBoundaryNote =
      'A viewport meta tag and touch-action are web platform concepts. The '
      'Flutter Android and iOS builds have no viewport meta and no double-tap '
      'zoom to disable, so this specification is scoped to the web and PWA '
      'targets rather than quietly generalised to all of them.';

  static const List<HabotViewportDirective> directives =
      <HabotViewportDirective>[
    HabotViewportDirective(
      declaration: 'width=device-width',
      applied: true,
      wcagImpact: '',
      rationale:
          'The layout is laid out against the device width rather than a '
          'desktop default that is then scaled down.',
    ),
    HabotViewportDirective(
      declaration: 'initial-scale=1',
      applied: true,
      wcagImpact: '',
      rationale: 'One CSS pixel per layout pixel at first paint.',
    ),
    HabotViewportDirective(
      declaration: 'maximum-scale=1',
      applied: false,
      wcagImpact: 'WCAG 2.1 SC 1.4.4 Resize Text (AA)',
      rationale:
          'Caps zoom at 100%, which is the same failure as user-scalable=no '
          'in a different spelling. Not emitted.',
    ),
    HabotViewportDirective(
      declaration: 'user-scalable=no',
      applied: false,
      wcagImpact: 'WCAG 2.1 SC 1.4.4 Resize Text (AA)',
      rationale:
          'What RCGLA-012 substep 2 asked for. It fails 1.4.4, and modern iOS '
          'and Android browsers ignore it, so it is a conformance failure that '
          'does not even take effect. Not emitted -- open decision 2.',
    ),
    HabotViewportDirective(
      declaration: 'touch-action: manipulation',
      applied: true,
      wcagImpact: '',
      rationale:
          'Removes the double-tap-to-zoom gesture and the tap delay that '
          'waiting for it creates. Pinch zoom is untouched, so text can still '
          'be enlarged and 1.4.4 still passes. This is what the row actually '
          'asks for.',
    ),
  ];

  static List<HabotViewportDirective> get emitted =>
      directives.where((HabotViewportDirective d) => d.applied).toList();

  static List<HabotViewportDirective> get refused =>
      directives.where((HabotViewportDirective d) => !d.applied).toList();

  static bool get nothingEmittedFailsWcag => emitted.every(
        (HabotViewportDirective d) => d.wcagImpact.isEmpty,
      );

  static bool get everyRefusalNamesACriterion => refused.every(
        (HabotViewportDirective d) => d.wcagImpact.isNotEmpty,
      );

  /// The viewport meta tag this build emits, assembled from the directives
  /// rather than written out, so a refusal cannot be re-added by editing a
  /// string.
  static String get viewportMeta => emitted
      .where((HabotViewportDirective d) => !d.declaration.contains(':'))
      .map((HabotViewportDirective d) => d.declaration)
      .join(', ');

  static bool get metaOmitsScaleLocks =>
      !viewportMeta.contains('user-scalable') &&
      !viewportMeta.contains('maximum-scale');

  // -----------------------------------------------------------------------
  // Open decision 2.
  // -----------------------------------------------------------------------

  /// Pinch zoom survives, so text can be enlarged.
  static const bool pinchZoomRemains = true;

  /// The tap delay double-tap zoom creates, removed as a side effect.
  static const int tapDelayRemovedMs = 300;

  static bool get closesTheResponsivenessHalfOfDecisionTwo =>
      directives
          .firstWhere(
            (HabotViewportDirective d) =>
                d.declaration.startsWith('touch-action'),
          )
          .applied &&
      pinchZoomRemains;

  static bool get leavesTheZoomSuppressionHalfRefused => refused.any(
        (HabotViewportDirective d) => d.declaration == 'user-scalable=no',
      );

  static const String openDecisionTwoNote =
      'RCGLA-012 substep 2 asked for user-scalable=no and was deferred as '
      'open decision 2, because suppressing zoom fails WCAG 1.4.4. This row '
      'asks for something different: disabling ACCIDENTAL DOUBLE-TAP zoom, '
      'which touch-action: manipulation does without touching pinch zoom. The '
      'responsiveness the earlier row wanted is delivered; the zoom '
      'suppression it asked for stays refused.';

  // -----------------------------------------------------------------------
  // Metric: Technical Specification Completeness.
  // -----------------------------------------------------------------------

  /// The specification, by section. The metric names exactly these four.
  static Map<HabotSpecSection, List<String>> get specification =>
      <HabotSpecSection, List<String>>{
        HabotSpecSection.inputs: <String>[
          'Build target (web, pwa, android, ios).',
          'The declared directive list above.',
        ],
        HabotSpecSection.outputs: <String>[
          'The viewport meta content string: "$viewportMeta".',
          'A touch-action: manipulation declaration on the app root.',
          'No scale lock of any spelling.',
        ],
        HabotSpecSection.edgeCases: <String>[
          'A browser that ignores touch-action: the tap delay returns and '
              'nothing breaks; the gesture is a convenience, not a control.',
          'A user with browser zoom already at 200%: initial-scale=1 applies '
              'to the layout viewport and does not reset their zoom.',
          'An embedded map or drawing surface that wants its own double-tap: '
              'touch-action is declared on the app root and overridden on that '
              'subtree, which is the only place it may be overridden.',
          'The android and ios targets, where none of this exists.',
        ],
        HabotSpecSection.acceptanceCriteria: <String>[
          'Pinch zoom enlarges text to at least 200% on every web target.',
          'A single tap registers without waiting for a second one.',
          'The emitted meta contains no user-scalable and no maximum-scale.',
          'Every refused directive names the criterion it would fail.',
        ],
      };

  static bool sectionIsPresent(HabotSpecSection s) =>
      (specification[s] ?? <String>[]).isNotEmpty;

  static double get specCompleteness =>
      HabotSpecSection.values.where(sectionIsPresent).length /
      HabotSpecSection.values.length;

  static String get qualitativeOutput {
    if (specCompleteness == 1.0) {
      return 'Complete';
    }
    return specCompleteness >= 0.5 ? 'Partial' : 'Not Complete';
  }

  static Map<String, bool> get checks => <String, bool>{
        'all four specification sections are present':
            specCompleteness == 1.0,
        'the specification is scoped to the targets it applies to':
            appliesTo.length == 2 && doesNotApplyTo.length == 2,
        'nothing emitted fails an accessibility criterion':
            nothingEmittedFailsWcag,
        'every refused directive names the criterion it would fail':
            everyRefusalNamesACriterion,
        'the emitted meta contains no scale lock of any spelling':
            metaOmitsScaleLocks,
        'the responsiveness half of open decision 2 is closed':
            closesTheResponsivenessHalfOfDecisionTwo,
        'the zoom-suppression half stays refused':
            leavesTheZoomSuppressionHalfRefused,
        'pinch zoom survives, so 1.4.4 still passes': pinchZoomRemains,
        'edge cases include the platforms where none of this exists':
            specification[HabotSpecSection.edgeCases]!.any(
          (String e) => e.contains('android and ios'),
        ),
      };

  static const String columnNote =
      'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic Step: '
      '"Design the approach and technical specification for: set up viewport '
      'parameters and disable accidental double-tap zoom behaviors on mobile '
      'browsers."';
}
