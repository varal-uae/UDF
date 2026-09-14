/// AISS Step 191 -- GEN-05111
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Implement the mobile UI styling requirement: M3 Surface
///               Container color tokens for background navigation shell."
/// Metric: UI Styling / Transition Compliance -- Floor "<=100ms transition
///         duration; visual QA pass on target devices", Optimal "<=100ms
///         transition, 100% visual QA pass", Ceiling ">100ms transitions read
///         as sluggish; >0 visual QA defects". Pass / Fail.
///
/// **"SURFACE CONTAINER" IS A LADDER, NOT A COLOUR.** MD3 specifies five
/// rungs — lowest, low, base, high, highest — and they encode depth. Assigning
/// the navigation shell "a surface container token" without saying which rung
/// is the same as not assigning one: put the shell on `surfaceContainerHigh`
/// and it floats above the content it frames; put it on
/// `surfaceContainerLowest` and the content appears to sit on top of the
/// navigation. Neither looks broken on its own screen, which is why this gets
/// decided differently on each one.
///
/// **THE RUNG IS A CONSEQUENCE OF WHAT SITS ON WHAT.** So the assignment is
/// declared for every shell surface at once, from the MD3 specification, and
/// the ordering between them is checked rather than assumed.
///
/// **IN DARK MODE THE LADDER IS THE ELEVATION SYSTEM.** MD3 expresses depth in
/// dark schemes as surface tint rather than as shadow, which is what
/// `HabotElevation.darkSurfaceLadder` already encodes. A shell whose rung and
/// whose declared elevation level disagree renders at one depth and casts the
/// shadow of another.
///
/// **AND HERE IS THE GAP THIS STEP FOUND.** The Step 4 contrast audit gates
/// `onSurface` against every container rung — but `onSurfaceVariant` only
/// against plain `surface`. Navigation labels are `onSurfaceVariant` and they
/// sit on `surfaceContainer`. **That exact pair is not audited anywhere in
/// this repository**, and it is the pair every navigation label in the product
/// uses. [HabotSurfaceContainerShell.missingAuditPairs] names it and
/// [HabotSurfaceContainerShell.auditShellPairs] measures it.
library;

import '../a11y/contrast.dart';
import '../a11y/contrast_audit.dart';
import '../tokens/color_tokens.dart';
import '../tokens/elevation_tokens.dart';
import '../tokens/m3_naming.dart';
import '../tokens/motion_tokens.dart';

/// A surface in the application shell.
class HabotShellSurface {
  const HabotShellSurface({
    required this.name,
    required this.rung,
    required this.elevation,
    required this.contentRole,
    required this.rationale,
  });

  final String name;

  /// Which rung of the MD3 surface-container ladder.
  final String rung;

  /// The elevation level it claims. Must agree with the rung -- see the
  /// header.
  final HabotElevationLevel elevation;

  /// The role the text and icons ON it take.
  final String contentRole;

  final String rationale;

  String get rungToken => 'md.sys.color.${HabotM3Naming.kebab(rung)}';
}

/// The shell's surface assignments, and the audit gap they exposed.
class HabotSurfaceContainerShell {
  const HabotSurfaceContainerShell._();

  /// The MD3 ladder, lowest depth first. Declared as an ordering because the
  /// ordering is the meaning.
  static const List<String> ladder = <String>[
    'surfaceContainerLowest',
    'surfaceContainerLow',
    'surfaceContainer',
    'surfaceContainerHigh',
    'surfaceContainerHighest',
  ];

  static int rungIndex(String rung) => ladder.indexOf(rung);

  static const List<HabotShellSurface> surfaces = <HabotShellSurface>[
    HabotShellSurface(
      name: 'navigationBar',
      rung: 'surfaceContainer',
      elevation: HabotElevationLevel.level2,
      contentRole: 'onSurfaceVariant',
      rationale: 'The row\'s subject. MD3 puts the navigation bar on the base '
          'container rung: it must read as a distinct plane from the page '
          'without appearing to hover over it.',
    ),
    HabotShellSurface(
      name: 'navigationRail',
      rung: 'surfaceContainer',
      elevation: HabotElevationLevel.level2,
      rationale: 'The same surface in a different orientation. Giving the rail '
          'a different rung from the bar is how a product ends up looking '
          'different on a tablet for no reason anyone chose.',
      contentRole: 'onSurfaceVariant',
    ),
    HabotShellSurface(
      name: 'appBarScrolledUnder',
      rung: 'surfaceContainer',
      elevation: HabotElevationLevel.level2,
      contentRole: 'onSurface',
      rationale: 'Flat at rest and on the container rung once content scrolls '
          'beneath it -- the rung IS the signal that something is underneath.',
    ),
    HabotShellSurface(
      name: 'bottomSheet',
      rung: 'surfaceContainerLow',
      elevation: HabotElevationLevel.level1,
      contentRole: 'onSurface',
      rationale: 'Enters from an edge and sits close to the page it came '
          'from.',
    ),
    HabotShellSurface(
      name: 'dialog',
      rung: 'surfaceContainerHigh',
      elevation: HabotElevationLevel.level3,
      contentRole: 'onSurface',
      rationale: 'The highest rung in ordinary use: a dialog interrupts, and '
          'the depth is what says so before the text does.',
    ),
  ];

  static HabotShellSurface byName(String name) =>
      surfaces.firstWhere((HabotShellSurface s) => s.name == name);

  /// The navigation shell the row is about.
  static HabotShellSurface get navigationShell => byName('navigationBar');

  /// Depth ordering: a dialog sits above the navigation shell, which sits
  /// above a sheet. Checked rather than assumed.
  static bool get ladderIsConsistent =>
      rungIndex(byName('bottomSheet').rung) <
          rungIndex(byName('navigationBar').rung) &&
      rungIndex(byName('navigationBar').rung) <
          rungIndex(byName('dialog').rung);

  /// The rung and the elevation level must move together -- see the header.
  static bool get elevationAgreesWithRung {
    final List<HabotShellSurface> sorted = List<HabotShellSurface>.from(surfaces)
      ..sort((HabotShellSurface a, HabotShellSurface b) =>
          rungIndex(a.rung).compareTo(rungIndex(b.rung)));
    for (int i = 1; i < sorted.length; i++) {
      final int prevRung = rungIndex(sorted[i - 1].rung);
      final int thisRung = rungIndex(sorted[i].rung);
      final int prevLevel = sorted[i - 1].elevation.index;
      final int thisLevel = sorted[i].elevation.index;
      if (thisRung > prevRung && thisLevel < prevLevel) {
        return false;
      }
    }
    return true;
  }

  // ---- the audit gap -------------------------------------------------------

  /// Pairs the shell actually renders.
  static List<AuditPair> get shellPairs => <AuditPair>[
        for (final HabotShellSurface s in surfaces)
          AuditPair(s.contentRole, s.rung),
      ];

  /// Shell pairs the Step 4 audit does NOT already cover.
  ///
  /// **The finding.** `onSurfaceVariant` on `surfaceContainer` is what every
  /// navigation label in the product renders as, and it is audited nowhere.
  static List<String> get missingAuditPairs {
    final Set<String> covered = <String>{
      for (final AuditPair p in <AuditPair>[
        ...ContrastAudit.textPairs,
        ...ContrastAudit.nonTextPairs,
      ])
        '${p.foreground}/${p.background}',
    };
    final Set<String> needed = <String>{
      for (final AuditPair p in shellPairs) '${p.foreground}/${p.background}',
    };
    return needed.where((String p) => !covered.contains(p)).toList()..sort();
  }

  /// Measure the shell's pairs, including the ones the existing audit misses.
  static List<ContrastResult> auditShellPairs(
    String schemeName,
    HabotColorScheme scheme,
  ) =>
      <ContrastResult>[
        for (final AuditPair p in shellPairs)
          Contrast.evaluate(
            foregroundName: '$schemeName.${p.foreground}',
            backgroundName: '$schemeName.${p.background}',
            foreground: scheme.roles[p.foreground]!,
            background: scheme.roles[p.background]!,
          ),
      ];

  static List<ContrastResult> shellFailures() => <ContrastResult>[
        ...auditShellPairs('light', HabotColors.light),
        ...auditShellPairs('dark', HabotColors.dark),
      ].where((ContrastResult r) => !r.passes).toList();

  // ---- timing --------------------------------------------------------------

  /// The shell's background changes when the scheme does. There is no reason
  /// for it to animate at all -- a theme change is not a transition the user
  /// is watching a single element through.
  static Duration get transition => HabotMotion.instant;

  static Duration get budget => HabotMotion.fast;

  static bool withinBudget(Duration d) => d <= budget;

  // ---- the row's metric ---------------------------------------------------

  static Map<String, bool> get complianceChecks => <String, bool>{
        'the navigation shell is assigned a specific rung rather than "a '
                'surface container"':
            ladder.contains(navigationShell.rung),
        'every shell surface declares its rung, its elevation level and the '
                'role its content takes':
            surfaces.every(
              (HabotShellSurface s) =>
                  ladder.contains(s.rung) && s.contentRole.isNotEmpty,
            ),
        'the depth ordering between shell surfaces is consistent':
            ladderIsConsistent,
        'each surface\'s elevation level agrees with its rung, so it does not '
                'render at one depth and cast the shadow of another':
            elevationAgreesWithRung,
        'the shell\'s own contrast pairs clear their floors in both schemes':
            shellFailures().isEmpty,
        'the transition is within the row\'s budget':
            withinBudget(transition),
        'every rung converts to a conformant MD3 token name':
            surfaces.every(
              (HabotShellSurface s) => HabotM3Naming.isConformant(s.rungToken),
            ),
      };

  static bool get isCompliant =>
      complianceChecks.values.every((bool b) => b);

  static String get qualitativeOutput => isCompliant ? 'Pass' : 'Fail';

  /// Raised rather than fixed here: adding a pair to the Step 4 audit set is a
  /// change to a gate that every earlier step's evidence rests on, and it
  /// belongs in that gate rather than smuggled in through a styling row.
  static List<String> get auditGapRaised => missingAuditPairs
      .map(
        (String p) =>
            '$p is rendered by the shell and is not in ContrastAudit. '
            'Measured here; belongs in the Step 4 pair set.',
      )
      .toList();

  static const String ladderNotColourNote =
      'Surface container is a ladder of five rungs and they encode depth. '
      'Assigning "a surface container token" without saying which rung is the '
      'same as not assigning one: on the high rung the shell floats above the '
      'content it frames, on the lowest the content appears to sit on top of '
      'the navigation. Neither looks broken on its own screen, which is why it '
      'gets decided differently on each one.';

  static const String darkElevationNote =
      'MD3 expresses depth in dark schemes as surface tint rather than as '
      'shadow, which is what HabotElevation.darkSurfaceLadder encodes. A shell '
      'whose rung and whose declared elevation level disagree renders at one '
      'depth and casts the shadow of another.';

  static const String auditGapNote =
      'The Step 4 contrast audit gates onSurface against every container rung '
      'but onSurfaceVariant only against plain surface. Navigation labels are '
      'onSurfaceVariant on surfaceContainer -- the pair every navigation label '
      'in the product uses, audited nowhere. Measured here and raised for the '
      'Step 4 pair set rather than quietly added to it, because that gate is '
      'what every earlier step\'s evidence rests on.';

  static const String columnNote =
      'Setup Step (Action) is EMPTY on this row. The Atomic Step is the unit '
      'of work.';
}
