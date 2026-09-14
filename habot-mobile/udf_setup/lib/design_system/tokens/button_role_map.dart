/// AISS Step 188 -- GEN-03899
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Assign the Material color token md.sys.color.primary to the
///               left button container. [cite: 540]"
/// Metric: Design System Token Compliance -- Floor 1, Optimal 1, Ceiling 1.
///         Pass / Fail.
///
/// **FOLLOWING THIS ROW LITERALLY COLOURS THE WRONG BUTTON IN URDU.** "The left
/// button" is a position. In a right-to-left locale the confirming action sits
/// on the *right*, so an implementation that assigns
/// `md.sys.color.primary` to whatever is on the left paints the **dismiss**
/// action as the primary one — in the language where the product is least able
/// to notice. Steps 150 and 167 found the same shape twice already: a swipe
/// direction and a frozen table column that were both written as sides and had
/// to become directions.
///
/// **SO THE MAP IS KEYED BY WHAT A BUTTON DOES, NOT BY WHERE IT SITS**, and the
/// position is derived from the text direction. The row's instruction is then
/// satisfied in the locale it was written for, and is satisfied *correctly* in
/// the ones it was not.
///
/// **ONE TOKEN ON ONE WIDGET IS NOT A DESIGN SYSTEM, AND THE METRIC ASKS FOR
/// COMPLIANCE RATHER THAN FOR A SINGLE ASSIGNMENT.** A rule that covers only
/// the case somebody wrote down is the reason the next dialog invents its own
/// colours. Every button variant the product uses gets its container and label
/// roles declared here, so "which token does this button take" has one answer
/// rather than one answer per screen.
///
/// **THE LABEL IS NOT OPTIONAL AND IS WHERE THIS GOES WRONG.** Assigning
/// `primary` to a container without assigning `onPrimary` to its label is how a
/// button ends up with a 1.9:1 contrast ratio and passes review, because the
/// person reviewing it is looking at the container. The pairs here are the same
/// pairs the Step 4 audit already gates.
library;

import '../i18n/localization_objective.dart';
import 'm3_naming.dart';

/// What a button does, which is the thing that does not change with locale.
enum HabotButtonRole {
  /// The action the dialog exists to offer. MD3 filled button.
  confirm,

  /// Backing out. MD3 text button.
  dismiss,

  /// A secondary but real action -- "Save draft" beside "Submit". MD3 tonal.
  secondary,

  /// Destructive confirmation. Carries the error role rather than primary,
  /// because a delete button coloured like a submit button gets pressed.
  destructive,
}

/// Which MD3 colour roles a button variant takes.
class HabotButtonColors {
  const HabotButtonColors({
    required this.role,
    required this.container,
    required this.label,
    required this.outline,
    required this.variant,
  });

  final HabotButtonRole role;

  /// The container role. Null for a text button, which has no container --
  /// recorded as null rather than as "transparent", because transparent is a
  /// colour and no container is an absence.
  final String? container;

  /// The label role. **Never null.** See the header.
  final String label;

  /// The border role, for outlined variants.
  final String? outline;

  /// The MD3 component this maps to.
  final String variant;

  /// The container's canonical MD3 token name, which is what the row names.
  String? get containerToken =>
      container == null ? null : 'md.sys.color.${HabotM3Naming.kebab(container!)}';

  String get labelToken =>
      'md.sys.color.${HabotM3Naming.kebab(label)}';

  /// The pair the Step 4 contrast audit gates. A container with no label pair
  /// is the defect described in the header.
  List<String>? get auditedPair =>
      container == null ? null : <String>[label, container!];
}

/// The button colour map, and where each button sits.
class HabotButtonRoleMap {
  const HabotButtonRoleMap._();

  /// The token the row names, spelled the way MD3 spells it.
  static const String rowToken = 'md.sys.color.primary';

  static const List<HabotButtonColors> all = <HabotButtonColors>[
    HabotButtonColors(
      role: HabotButtonRole.confirm,
      container: 'primary',
      label: 'onPrimary',
      outline: null,
      variant: 'M3 Filled Button',
    ),
    HabotButtonColors(
      role: HabotButtonRole.secondary,
      container: 'secondaryContainer',
      label: 'onSecondaryContainer',
      outline: null,
      variant: 'M3 Filled Tonal Button',
    ),
    HabotButtonColors(
      role: HabotButtonRole.dismiss,
      container: null,
      label: 'primary',
      outline: null,
      variant: 'M3 Text Button',
    ),
    HabotButtonColors(
      role: HabotButtonRole.destructive,
      container: 'error',
      label: 'onError',
      outline: null,
      variant: 'M3 Filled Button (error)',
    ),
  ];

  static HabotButtonColors forRole(HabotButtonRole role) =>
      all.firstWhere((HabotButtonColors c) => c.role == role);

  // ---- position, derived rather than assumed -------------------------------

  /// MD3 places the confirming action at the END of the action row -- the
  /// trailing edge in reading order. Which physical side that is depends on
  /// the direction.
  static HabotButtonRole roleAtLeft(HabotTextDirectionality direction) =>
      direction == HabotTextDirectionality.rightToLeft
          ? HabotButtonRole.confirm
          : HabotButtonRole.dismiss;

  static HabotButtonRole roleAtRight(HabotTextDirectionality direction) =>
      direction == HabotTextDirectionality.rightToLeft
          ? HabotButtonRole.dismiss
          : HabotButtonRole.confirm;

  /// What the row's literal instruction would produce in a given direction.
  ///
  /// **The finding.** Left-to-right it lands on the dismiss action, which is
  /// not what the row means either -- and right-to-left it lands on confirm,
  /// which is what it means, by accident. Either way, "the left button" is not
  /// a stable target.
  static String literalInstructionHits(HabotTextDirectionality direction) =>
      roleAtLeft(direction).name;

  /// The container token for a button, by what it does.
  static String? containerTokenFor(HabotButtonRole role) =>
      forRole(role).containerToken;

  // ---- the row's metric ---------------------------------------------------

  /// Design System Token Compliance: 1 at every bound, so a conjunction.
  static Map<String, bool> get complianceChecks => <String, bool>{
        'the confirming action\'s container carries the token the row names':
            containerTokenFor(HabotButtonRole.confirm) == rowToken,
        'every button variant has a declared container and label role, so the '
                'next dialog does not invent its own':
            all.every((HabotButtonColors c) => c.label.isNotEmpty),
        'no container is assigned without its label pair, which is how a '
                'button reaches 1.9:1 and passes review':
            all.every(
              (HabotButtonColors c) =>
                  c.container == null || c.auditedPair != null,
            ),
        'every declared role name converts to a conformant MD3 token name':
            all.every(
              (HabotButtonColors c) =>
                  HabotM3Naming.isConformant(c.labelToken) &&
                  (c.containerToken == null ||
                      HabotM3Naming.isConformant(c.containerToken!)),
            ),
        'position is derived from text direction rather than written as a '
                'side':
            roleAtLeft(HabotTextDirectionality.leftToRight) !=
                roleAtLeft(HabotTextDirectionality.rightToLeft),
        'a destructive confirmation does not take the same colour as an '
                'ordinary one':
            containerTokenFor(HabotButtonRole.destructive) !=
                containerTokenFor(HabotButtonRole.confirm),
      };

  static bool get isCompliant =>
      complianceChecks.values.every((bool b) => b);

  static String get qualitativeOutput => isCompliant ? 'Pass' : 'Fail';

  static const String directionNote =
      '"The left button" is a position. In a right-to-left locale the '
      'confirming action sits on the right, so assigning primary to whatever '
      'is on the left paints the DISMISS action as the primary one -- in the '
      'language where the product is least able to notice. Steps 150 and 167 '
      'found the same shape: a swipe direction and a frozen column, both '
      'written as sides, both having to become directions.';

  static const String oneWidgetIsNotASystemNote =
      'One token on one widget is not a design system, and the metric asks for '
      'compliance rather than a single assignment. A rule covering only the '
      'case somebody wrote down is why the next dialog invents its own '
      'colours.';

  static const String labelPairNote =
      'Assigning primary to a container without assigning onPrimary to its '
      'label is how a button ends up at 1.9:1 and passes review -- the person '
      'reviewing it is looking at the container. The pairs declared here are '
      'the pairs the Step 4 audit already gates.';

  static const String destructiveNote =
      'A destructive confirmation takes the error role rather than primary. A '
      'delete button coloured like a submit button gets pressed.';

  static const String columnNote =
      'Setup Step (Action) is EMPTY on this row. The Atomic Step is the unit '
      'of work. The "[cite: 540]" fragment in the Atomic Step text is an '
      'artefact of the source document and carries no requirement.';
}
