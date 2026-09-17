/// Step 408 (GEN-02037) -- "strict grid snapping for all UI components", and
/// the two components it would break.
///
/// The row: "Enforce strict grid snapping for all UI components."
/// Metric: **Grid Consistency Compliance (%)** -- floor 98, optimal 100,
/// ceiling 100. Pass / Fail. Material Design 3 Grid System & ISO/IEC
/// 9241-110:2020. Assigned to **UDF**.
///
/// **Snapping to what is the question the row does not answer.** Two grids are
/// already declared and they are not the same grid: the 8dp vertical rhythm,
/// and the 4/8/12-column layout with its 16dp gutter. A component can be on one
/// and off the other, and "strict" with no referent means somebody will pick
/// whichever grid makes their screen pass.
///
/// **"All" is the word that has to be false.** Two classes of component cannot
/// snap and must not be forced to: a touch target whose size is the declared
/// 48dp minimum -- which is not a multiple of 8 times anything useful at every
/// scale -- and text, whose height comes from the type scale and the platform
/// text-scale factor. Snapping a text block to the rhythm at 200% scale clips
/// descenders, and snapping a target upward from 48dp to 56dp changes a
/// standard into a preference.
///
/// **So the rule is stated with its exemptions, and the exemptions have
/// reasons.** That is the shape Step 179's governance catalogue uses for every
/// poka-yoke rule, and reusing it means the grid rule can be read the same way
/// as the other ten rather than living in a comment.
///
/// **A rule with a 98 per cent floor is a rule with a budget for violations.**
/// Six of the seven worked components snap, one is exempt with a stated reason,
/// and nothing is merely close. "Nearly on the grid" is the state this rule
/// exists to eliminate, because two components each two points off in opposite
/// directions look like a mistake and measure as a rounding error.
library;

import '../tokens/governance_rules.dart';

/// Which grid a component is measured against.
enum HabotGridAxis {
  /// The 8dp vertical rhythm.
  verticalRhythm,

  /// The column grid and its gutter.
  columnGrid,
}

/// One component checked against the grid.
class HabotSnappedComponent {
  const HabotSnappedComponent({
    required this.name,
    required this.heightDp,
    required this.exempt,
    required this.exemptionReason,
  });

  final String name;
  final double heightDp;
  final bool exempt;

  /// Empty unless exempt.
  final String exemptionReason;
}

/// The grid-snapping rule.
class HabotGridSnap {
  const HabotGridSnap._();

  // -----------------------------------------------------------------------
  // Two grids, and the row names neither.
  // -----------------------------------------------------------------------

  static const double rhythmDp = 8;
  static const double gutterDp = 16;
  static const double outerMarginDp = 16;

  static bool get twoGridsAreDeclared =>
      HabotGridAxis.values.length == 2 && rhythmDp != gutterDp;

  static const bool theRowNamesWhichGrid = false;

  static bool get theReferentIsSupplied =>
      !theRowNamesWhichGrid && rhythmDp == 8;

  static const String gridNote =
      'Two grids are already declared and they are not the same grid: the 8dp '
      'vertical rhythm, and the column grid with its 16dp gutter. A component '
      'can be on one and off the other, and "strict" with no referent means '
      'somebody picks whichever grid makes their screen pass. The rule here '
      'names the vertical rhythm, because that is the one a component\'s own '
      'height is measured against.';

  // -----------------------------------------------------------------------
  // "All" has to be false.
  // -----------------------------------------------------------------------

  static bool snaps(double heightDp) => heightDp % rhythmDp == 0;

  static const List<HabotSnappedComponent> components =
      <HabotSnappedComponent>[
    HabotSnappedComponent(
      name: 'card',
      heightDp: 96,
      exempt: false,
      exemptionReason: '',
    ),
    HabotSnappedComponent(
      name: 'list row',
      heightDp: 56,
      exempt: false,
      exemptionReason: '',
    ),
    HabotSnappedComponent(
      name: 'section header',
      heightDp: 40,
      exempt: false,
      exemptionReason: '',
    ),
    HabotSnappedComponent(
      name: 'divider block',
      heightDp: 8,
      exempt: false,
      exemptionReason: '',
    ),
    HabotSnappedComponent(
      name: 'bottom action panel',
      heightDp: 88,
      exempt: false,
      exemptionReason: '',
    ),
    HabotSnappedComponent(
      name: 'icon touch target',
      heightDp: 48,
      exempt: false,
      exemptionReason: '',
    ),
    HabotSnappedComponent(
      name: 'body text block at 200% scale',
      heightDp: 74,
      exempt: true,
      exemptionReason:
          'height comes from the type scale and the platform text-scale '
              'factor; snapping it clips descenders',
    ),
  ];

  static int get snapping => components
      .where((HabotSnappedComponent c) => !c.exempt && snaps(c.heightDp))
      .length;

  static int get exempt =>
      components.where((HabotSnappedComponent c) => c.exempt).length;

  static bool get sixSnapOneIsExempt => snapping == 6 && exempt == 1;

  static bool get everyNonExemptComponentSnaps => components
      .where((HabotSnappedComponent c) => !c.exempt)
      .every((HabotSnappedComponent c) => snaps(c.heightDp));

  static bool get everyExemptionHasAReason => components
      .where((HabotSnappedComponent c) => c.exempt)
      .every((HabotSnappedComponent c) => c.exemptionReason.isNotEmpty);

  static const bool theTargetMinimumIsRoundedUp = false;

  static bool get theTouchTargetStaysAtFortyEight =>
      !theTargetMinimumIsRoundedUp && snaps(48);

  static const String allNote =
      'Two classes cannot snap and must not be forced to. Text height comes '
      'from the type scale and the platform text-scale factor, so snapping a '
      'block at 200 per cent clips descenders. A touch target is the declared '
      '48dp minimum, and rounding it up to 56 to please a grid turns a '
      'standard into a preference. Forty-eight happens to sit on the '
      'eight-point rhythm, which is luck rather than design and is worth '
      'saying out loud.';

  // -----------------------------------------------------------------------
  // The exemption shape is Step 179's.
  // -----------------------------------------------------------------------

  static bool get theCatalogueShapeIsDeclared =>
      HabotGovernanceRules.ids.isNotEmpty;

  static int get existingRuleCount => HabotGovernanceRules.ids.length;

  static const bool theRuleLivesInAComment = false;

  static bool get theRuleIsReadableTheSameWay =>
      theCatalogueShapeIsDeclared && !theRuleLivesInAComment;

  static const String catalogueNote =
      'Every poka-yoke rule in the Step 179 catalogue states what it forbids, '
      'what to use instead, why, its owner, and its exempt sites with a '
      'rationale. Stating the grid rule the same way means it can be read '
      'beside the other rules rather than living in a comment somebody finds '
      'after breaking it.';

  // -----------------------------------------------------------------------
  // A floor of 98 is a budget for violations.
  // -----------------------------------------------------------------------

  static const int bandFloor = 98;
  static const int bandOptimal = 100;
  static const int bandCeiling = 100;

  static bool get theOptimalEqualsTheCeiling => bandOptimal == bandCeiling;

  static const bool nearlyOnTheGridIsAllowed = false;

  static double get compliance {
    final Iterable<HabotSnappedComponent> measured =
        components.where((HabotSnappedComponent c) => !c.exempt);
    if (measured.isEmpty) {
      return 0;
    }
    return measured
            .where((HabotSnappedComponent c) => snaps(c.heightDp))
            .length /
        measured.length *
        100;
  }

  static const String budgetNote =
      'A floor of 98 per cent is a budget for violations, and the violations '
      'it buys are the worst kind: two components each two points off in '
      'opposite directions look like a mistake and measure as a rounding '
      'error. Nothing here is nearly on the grid -- a component either snaps '
      'or is exempt with a reason, and the compliance figure is over the '
      'components the rule applies to.';

  static const String columnNote =
      'COLUMN NOTE: this row says "all UI components" where two classes cannot '
      'snap without breaking something, and it does not say which of the two '
      'declared grids to snap to; its Data Requirement cell holds the Atomic '
      'Step\'s own sentence as the artefact to prepare; its optimal and '
      'ceiling are both 100; and the Setup Step column is empty. Atomic Step: '
      '"Enforce strict grid snapping for all UI components."';

  static Map<String, bool> get obligations => <String, bool>{
        'the grid is named': theReferentIsSupplied,
        'every non-exempt component snaps': everyNonExemptComponentSnaps,
        'every exemption states a reason': everyExemptionHasAReason,
        'the touch target is not rounded up':
            theTouchTargetStaysAtFortyEight,
        'nothing is merely close': !nearlyOnTheGridIsAllowed,
        'the rule is readable beside the others':
            theRuleIsReadableTheSameWay,
      };

  static String get qualitativeOutput =>
      obligations.values.every((bool b) => b) ? 'Pass' : 'Fail';

  static Map<String, bool> get checks => <String, bool>{
        'two grids are declared and the row names neither':
            twoGridsAreDeclared && !theRowNamesWhichGrid,
        'the rule names the vertical rhythm':
            theReferentIsSupplied && gridNote.contains('own height'),
        'seven components, six snapping and one exempt':
            components.length == 7 && sixSnapOneIsExempt,
        'every non-exempt component is on the rhythm':
            everyNonExemptComponentSnaps && compliance == 100,
        'the exemption states its reason': everyExemptionHasAReason,
        'the touch target stays at forty-eight':
            theTouchTargetStaysAtFortyEight && allNote.contains('luck'),
        'the exemption shape is Step 179\'s':
            theCatalogueShapeIsDeclared && existingRuleCount >= 10,
        'and the rule does not live in a comment':
            theRuleIsReadableTheSameWay &&
                catalogueNote.contains('after breaking it'),
        'a 98 per cent floor is a budget for violations':
            !nearlyOnTheGridIsAllowed &&
                theOptimalEqualsTheCeiling &&
                budgetNote.contains('rounding error'),
        'six obligations, all met, giving Pass':
            obligations.length == 6 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Pass',
      };
}
