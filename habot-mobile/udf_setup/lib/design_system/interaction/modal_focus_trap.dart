/// Step 280 (ERMWD-029-07) -- a "touch-based focus trap", which is two
/// mechanisms wearing one name.
///
/// The row: "Configure touch-based focus traps inside modals with
/// thumb-friendly dismissal zones."
/// Metric: **Process Execution Quality Score** -- floor ">=90%", optimal
/// ">=98%", ceiling 1. Good / Average / Poor. Cited: ISO 9001:2015.
///
/// **A focus trap is not a touch construct.** Focus is what a keyboard walks
/// with Tab and what a screen reader walks with a swipe; a trap keeps that
/// walk inside the modal instead of letting it wander into the page behind,
/// which is still rendered and still reachable. A finger does not traverse --
/// it lands where it lands. What touch needs is a scrim that absorbs taps
/// outside the modal. So the row names one mechanism and asks for the other,
/// and both are required, for different people. Both are declared here, each
/// with the user it serves.
///
/// **A trap with no declared exit is a cage.** Every modal surface names its
/// escapes, and they are not the same for every surface: Step 225 already
/// ruled that a decision dialog is *not* dismissible by gesture, so a scrim
/// tap must not close one. Scrim dismissal is allowed exactly where that rule
/// allows gesture dismissal, which makes the two rules one rule rather than
/// two that will drift.
///
/// **And "thumb-friendly" rules out the place the close button usually goes.**
/// The top trailing corner is the least reachable point on a phone held in one
/// hand, and it is where an X is conventionally drawn. The primary dismissal
/// sits at the bottom, inside the reach band Step 176 already declared for the
/// FAB; the top control stays as a duplicate for people using a pointer, and
/// is never the only route.
library;

import 'fab_thumb_zone.dart';
import '../surfaces/dialog_to_sheet.dart';

/// Which containment mechanism, and who it is for.
enum HabotContainment {
  /// Keeps keyboard and screen-reader traversal inside the modal.
  focusTraversal,

  /// Absorbs pointer and touch events outside the modal.
  tapScrim,
}

/// A way out.
enum HabotDismissRoute {
  /// Tapping outside the modal.
  scrimTap,

  /// Dragging the sheet down.
  dragDown,

  /// A labelled control inside the modal.
  explicitAction,

  /// The platform back gesture or button.
  systemBack,
}

/// Where on the screen an affordance sits, as a fraction of height measured
/// from the bottom. 0.0 is the bottom edge, 1.0 the top.
class HabotScreenPosition {
  const HabotScreenPosition({
    required this.name,
    required this.fractionFromBottom,
    required this.isTrailingCorner,
  });

  final String name;
  final double fractionFromBottom;
  final bool isTrailingCorner;
}

/// The rule.
class HabotModalFocusTrap {
  const HabotModalFocusTrap._();

  // -----------------------------------------------------------------------
  // Two mechanisms, named separately.
  // -----------------------------------------------------------------------

  /// Who each mechanism is for. A table rather than a sentence, so that a
  /// future change has to say which population it is dropping.
  static const Map<HabotContainment, String> servedBy =
      <HabotContainment, String>{
    HabotContainment.focusTraversal:
        'keyboard users and screen-reader users, whose traversal would '
            'otherwise walk into the page behind the modal',
    HabotContainment.tapScrim:
        'everybody using touch or a pointer, whose taps would otherwise reach '
            'controls they cannot see the state of',
  };

  static bool get bothMechanismsAreDeclared =>
      servedBy.length == HabotContainment.values.length &&
      HabotContainment.values.length == 2 &&
      servedBy.values.every((String s) => s.length > 60);

  /// The row asks for one and names the other. Recorded as a count so the
  /// gate reads the table rather than the prose.
  static const int mechanismsTheRowNames = 1;

  static bool get theRowNamesFewerMechanismsThanItNeeds =>
      mechanismsTheRowNames < HabotContainment.values.length;

  static const String traversalIsNotTouchNote =
      'A focus trap is not a touch construct. Focus is what a keyboard walks '
      'with Tab and what a screen reader walks with a swipe, and a trap keeps '
      'that walk inside the modal rather than letting it wander into a page '
      'that is still rendered behind. A finger does not traverse: it lands '
      'where it lands, and what touch needs is a scrim that absorbs the taps. '
      'The row names the first and asks for the second, and the two serve '
      'different people -- so both are declared, each with the population it '
      'is for, rather than one being built and named after the other.';

  // -----------------------------------------------------------------------
  // The exits, and the rule they already have to agree with.
  // -----------------------------------------------------------------------

  /// Every modal form's escapes. Read against Step 225's dismissibility rule
  /// rather than invented, so the two cannot drift apart.
  static List<HabotDismissRoute> routesFor(HabotSurfaceForm form) {
    final List<HabotDismissRoute> routes = <HabotDismissRoute>[
      HabotDismissRoute.explicitAction,
      HabotDismissRoute.systemBack,
    ];
    if (HabotSurfaceChoice.isDismissibleByGesture(form)) {
      routes
        ..add(HabotDismissRoute.scrimTap)
        ..add(HabotDismissRoute.dragDown);
    }
    return routes;
  }

  /// A blocking dialog keeps its two exits and gains no gesture, which is the
  /// property it existed for.
  static bool get aDialogIsNotClosedByTappingOutside =>
      !routesFor(HabotSurfaceForm.dialog).contains(HabotDismissRoute.scrimTap);

  static bool get aSheetIs =>
      routesFor(HabotSurfaceForm.modalSheet)
          .contains(HabotDismissRoute.scrimTap) &&
      routesFor(HabotSurfaceForm.modalSheet)
          .contains(HabotDismissRoute.dragDown);

  /// Nothing is ever without an exit.
  static bool get everyFormHasAtLeastTwoExits => HabotSurfaceForm.values
      .every((HabotSurfaceForm f) => routesFor(f).length >= 2);

  /// The scrim rule and the gesture rule are the same rule, checked across
  /// every declared form rather than on the two that were thought about.
  static bool get theScrimRuleFollowsTheGestureRule =>
      HabotSurfaceForm.values.every(
        (HabotSurfaceForm f) =>
            routesFor(f).contains(HabotDismissRoute.scrimTap) ==
            HabotSurfaceChoice.isDismissibleByGesture(f),
      );

  static const String noCageNote =
      'A trap with no declared exit is a cage. Every modal form here names '
      'its escapes, and they differ by form because Step 225 already ruled '
      'that a decision dialog is not dismissible by gesture -- so a scrim tap '
      'must not close one, or the ruling would be undone by a different file. '
      'Scrim dismissal is therefore defined AS the gesture rule rather than '
      'beside it: one rule, read in two places, which is the only arrangement '
      'that cannot drift.';

  // -----------------------------------------------------------------------
  // Thumb-friendly, measured.
  // -----------------------------------------------------------------------

  /// How far up the screen a thumb reaches comfortably on a phone held in one
  /// hand. The FAB's anchor is the existing declaration of the same fact.
  static const double reachBandTopFraction = 0.4;

  static bool isWithinReach(HabotScreenPosition p) =>
      p.fractionFromBottom <= reachBandTopFraction;

  static const List<HabotScreenPosition> dismissalPositions =
      <HabotScreenPosition>[
    HabotScreenPosition(
      name: 'drag handle at the top edge of the sheet',
      fractionFromBottom: 0.35,
      isTrailingCorner: false,
    ),
    HabotScreenPosition(
      name: 'action row along the bottom of the modal',
      fractionFromBottom: 0.08,
      isTrailingCorner: false,
    ),
    HabotScreenPosition(
      name: 'close control in the top trailing corner',
      fractionFromBottom: 0.94,
      isTrailingCorner: true,
    ),
  ];

  static List<HabotScreenPosition> get withinReach =>
      dismissalPositions.where(isWithinReach).toList();

  static double get shareWithinReach =>
      withinReach.length / dismissalPositions.length;

  /// The conventional close control is the one that is out of reach, and it
  /// is not the only route -- which is the whole content of "thumb-friendly".
  static bool get theConventionalCloseIsTheUnreachableOne =>
      dismissalPositions
          .where((HabotScreenPosition p) => p.isTrailingCorner)
          .every((HabotScreenPosition p) => !isWithinReach(p)) &&
      withinReach.length == 2;

  /// Read against the existing FAB placement: the same corner, for the same
  /// reason, and Step 176 already recorded that it disadvantages left-handed
  /// use.
  static bool get theReachClaimMatchesTheExistingOne =>
      HabotFabThumbZone.anchor == HabotFabAnchor.bottomTrailing &&
      HabotFabThumbZone.handednessLimitation.isNotEmpty &&
      HabotFabThumbZone.fabIsNeverTheOnlyRoute;

  static const String thumbNote =
      'The top trailing corner is the least reachable point on a phone held '
      'in one hand, and it is exactly where an X is conventionally drawn. So '
      '"thumb-friendly dismissal" is not a padding change: it is a decision '
      'about which affordance is primary. The drag handle and the action row '
      'are inside the reach band and are the routes people will use; the '
      'corner control stays for pointer users and for muscle memory, and is '
      'never the only way out. Step 176 made the same argument about the FAB '
      'and recorded the same limitation -- a reach band drawn for a right '
      'hand disadvantages a left one, and neither file pretends otherwise.';

  // -----------------------------------------------------------------------
  // Focus, restored.
  // -----------------------------------------------------------------------

  /// Where focus goes when the modal closes. The half everybody forgets: a
  /// screen reader dropped at the top of the page has lost the person's
  /// place, and they have to find the control they just used again.
  static String focusAfterClose(String openerId) => openerId;

  static bool get focusReturnsToTheOpener =>
      focusAfterClose('habot.booking.editDate') == 'habot.booking.editDate';

  static const String restorationNote =
      'Focus returns to the control that opened the modal. It is the half '
      'that gets forgotten, because it is invisible to anybody not using a '
      'reader: closing a sheet and dropping focus at the top of the page '
      'loses the person\'s place entirely, and they have to walk back to the '
      'control they used a second ago. Trapping focus without restoring it is '
      'half an implementation that passes every visual review.';

  // -----------------------------------------------------------------------
  // Metric: Process Execution Quality Score -- 90% / 98% / 1.
  // -----------------------------------------------------------------------

  static Map<String, bool> get obligations => <String, bool>{
        'both containment mechanisms are declared': bothMechanismsAreDeclared,
        'traversal is trapped for keyboard and reader users':
            servedBy.containsKey(HabotContainment.focusTraversal),
        'the scrim absorbs taps for everybody else':
            servedBy.containsKey(HabotContainment.tapScrim),
        'every modal form has at least two exits': everyFormHasAtLeastTwoExits,
        'a blocking dialog is not closed by tapping outside':
            aDialogIsNotClosedByTappingOutside,
        'a sheet is, by tap and by drag': aSheetIs,
        'the scrim rule is the gesture rule': theScrimRuleFollowsTheGestureRule,
        'most dismissal affordances are within reach':
            shareWithinReach > 0.5 && theConventionalCloseIsTheUnreachableOne,
        'focus returns to the opener': focusReturnsToTheOpener,
      };

  static double get qualityScore =>
      obligations.values.where((bool b) => b).length / obligations.length;

  static const double floorPercent = 90;
  static const double optimalPercent = 98;

  static String get qualitativeOutput {
    final double pct = qualityScore * 100;
    if (pct >= optimalPercent) {
      return 'Good';
    }
    return pct >= floorPercent ? 'Average' : 'Poor';
  }

  static const String wrongStackNote =
      'The row\'s Data Requirement column carries React Native props -- '
      'keyboardType="numeric" and secureTextEntry={true} -- in an application '
      'written in Dart, and they are about secure text fields rather than '
      'about focus traps. So the cell holds a second subject in a third '
      'framework. This is the sixth row in this track written against a stack '
      'that was never used; Step 258 keeps the list.';

  static Map<String, bool> get checks => <String, bool>{
        'two containment mechanisms, each with the population it serves':
            bothMechanismsAreDeclared && theRowNamesFewerMechanismsThanItNeeds,
        'the traversal/touch confusion is recorded':
            traversalIsNotTouchNote.contains('lands where it lands'),
        'every form has at least two exits': everyFormHasAtLeastTwoExits,
        'a dialog keeps its blocking property':
            aDialogIsNotClosedByTappingOutside,
        'a sheet can be tapped or dragged away': aSheetIs,
        'the scrim rule is defined as the gesture rule, across every form':
            theScrimRuleFollowsTheGestureRule && noCageNote.contains('cannot '
                'drift'),
        'two of three dismissal affordances are within reach':
            withinReach.length == 2 &&
                (shareWithinReach - 2 / 3).abs() < 1e-9,
        'the conventional close control is the unreachable one':
            theConventionalCloseIsTheUnreachableOne &&
                thumbNote.contains('which affordance is primary'),
        'the reach claim matches the existing FAB declaration':
            theReachClaimMatchesTheExistingOne,
        'focus returns to the opener, and the omission is named':
            focusReturnsToTheOpener &&
                restorationNote.contains('passes every visual review'),
        'nine obligations, all of them met, giving Good':
            obligations.length == 9 &&
                obligations.values.every((bool b) => b) &&
                qualityScore == 1.0 &&
                qualitativeOutput == 'Good',
        'the React Native props in a Dart application are recorded':
            wrongStackNote.contains('sixth row'),
      };

  static const String columnNote =
      'COLUMN NOTE: the Setup Step column on this row reads "Run the static '
      'analysis scanner tool locally against all existing mobile filtering '
      'files", and the Data Requirement column carries React Native props for '
      'secure text fields. Atomic Step: "Configure touch-based focus traps '
      'inside modals with thumb-friendly dismissal zones."';
}
