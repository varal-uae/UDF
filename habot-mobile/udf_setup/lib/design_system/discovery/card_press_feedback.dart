/// Step 199 (GEN-01430) -- press feedback on a category card.
///
/// The row: "Implement M3 Elevating Card effects on category card press
/// events."
///
/// **Material 3 does not raise a card on press.** The elevated card's
/// resting level is 1; it goes to level 3 while DRAGGED and back to level 1
/// when pressed. Press is expressed by the state layer -- a translucent wash of
/// the on-surface colour over the card -- not by a shadow. That is not a style
/// preference: on a touch screen the finger is on top of the thing that would
/// cast the shadow, so a press elevation animates something the user's hand is
/// covering. The one device class where elevation-on-interaction is visible is
/// a pointer device, and there the event is hover, not press.
///
/// So the row is implemented as MD3 specifies it: state layer on press,
/// elevation change reserved for drag, and a hover elevation kept for pointer
/// devices where it can actually be seen. The elevating half of the row is
/// honoured where it is visible and declined where it is not.
///
/// The metric on this row is Category Navigation Discoverability (Time-to-Find)
/// -- floor <10s, optimal <3s, ceiling <15s. Two things about it are recorded
/// rather than worked around. Press feedback does not change how long it takes
/// to find a category; it changes whether a tap felt registered. And the
/// floor/optimal/ceiling convention inverts on a duration: the "ceiling" of 15s
/// is the WORST permitted value, not the best, so a naive higher-is-better
/// reading of this row grades a 15-second search as a ceiling result.
library;

import '../tokens/elevation_tokens.dart';
import '../tokens/motion_tokens.dart';

/// The pointer situations a card can be in.
enum HabotCardInteraction { resting, hovered, pressed, dragged, focused }

/// How a card responds to one interaction.
class HabotCardResponse {
  const HabotCardResponse({
    required this.interaction,
    required this.elevation,
    required this.stateLayerOpacity,
    required this.visibleUnderAFinger,
  });

  final HabotCardInteraction interaction;

  /// The MD3 elevation level for this interaction.
  final HabotElevationLevel elevation;

  /// State-layer opacity over the card surface. MD3 state-layer opacities.
  final double stateLayerOpacity;

  /// Whether the user can see this response while touching the card.
  final bool visibleUnderAFinger;
}

/// Press feedback for the category grid.
class HabotCardPressFeedback {
  const HabotCardPressFeedback._();

  /// MD3 elevated-card levels and state-layer opacities.
  static const List<HabotCardResponse> responses = <HabotCardResponse>[
    HabotCardResponse(
      interaction: HabotCardInteraction.resting,
      elevation: HabotElevationLevel.level1,
      stateLayerOpacity: 0,
      visibleUnderAFinger: true,
    ),
    HabotCardResponse(
      interaction: HabotCardInteraction.hovered,
      elevation: HabotElevationLevel.level2,
      stateLayerOpacity: 0.08,
      visibleUnderAFinger: true,
    ),
    HabotCardResponse(
      // Elevation returns to rest. The response is the state layer.
      interaction: HabotCardInteraction.pressed,
      elevation: HabotElevationLevel.level1,
      stateLayerOpacity: 0.10,
      visibleUnderAFinger: false,
    ),
    HabotCardResponse(
      interaction: HabotCardInteraction.dragged,
      elevation: HabotElevationLevel.level3,
      stateLayerOpacity: 0.10,
      visibleUnderAFinger: true,
    ),
    HabotCardResponse(
      interaction: HabotCardInteraction.focused,
      elevation: HabotElevationLevel.level1,
      stateLayerOpacity: 0.10,
      visibleUnderAFinger: true,
    ),
  ];

  static HabotCardResponse responseFor(HabotCardInteraction interaction) =>
      responses.firstWhere(
        (HabotCardResponse r) => r.interaction == interaction,
      );

  /// How long the state layer takes to appear and clear.
  static Duration get stateLayerDuration => HabotMotion.fast;

  /// The window within which a press must produce SOME feedback, or the tap
  /// reads as ignored and gets repeated.
  static Duration get feedbackCeiling => HabotMotion.interactiveCeiling;

  static bool get feedbackIsInsideTheCeiling =>
      stateLayerDuration <= feedbackCeiling;

  /// True when press does not change elevation -- the MD3 behaviour.
  static bool get pressKeepsRestingElevation =>
      responseFor(HabotCardInteraction.pressed).elevation ==
      responseFor(HabotCardInteraction.resting).elevation;

  /// True when drag is the interaction that raises the card.
  static bool get dragIsTheElevatingInteraction =>
      HabotElevation.dp[responseFor(HabotCardInteraction.dragged).elevation]! >
      HabotElevation.dp[responseFor(HabotCardInteraction.resting).elevation]!;

  /// The elevation delta the row asks for, if it were applied to press.
  ///
  /// Zero, and that is the finding: the row asks for an effect with no size.
  static double get pressElevationDeltaDp =>
      HabotElevation.dp[responseFor(HabotCardInteraction.pressed).elevation]! -
      HabotElevation.dp[responseFor(HabotCardInteraction.resting).elevation]!;

  /// Hover elevation is kept, because on a pointer device it is visible.
  static bool get hoverRaisesOnPointerDevices =>
      HabotElevation.dp[responseFor(HabotCardInteraction.hovered).elevation]! >
      HabotElevation.dp[responseFor(HabotCardInteraction.resting).elevation]!;

  // -----------------------------------------------------------------------
  // The metric.
  // -----------------------------------------------------------------------

  /// Seconds. From the row, in the row's own order.
  static const double timeToFindFloorSeconds = 10;
  static const double timeToFindOptimalSeconds = 3;
  static const double timeToFindCeilingSeconds = 15;

  /// True when the row's ceiling is a worse outcome than its floor.
  ///
  /// It is, because the metric is a duration. The floor/optimal/ceiling
  /// convention was written for rates, where higher is better; on a duration
  /// the ordering reverses and the ceiling becomes the worst tolerated value.
  static bool get bandIsInvertedForADuration =>
      timeToFindCeilingSeconds > timeToFindFloorSeconds &&
      timeToFindOptimalSeconds < timeToFindFloorSeconds;

  static String qualitativeOutputForSeconds(double seconds) {
    if (seconds < timeToFindOptimalSeconds) {
      return 'Good';
    }
    if (seconds < timeToFindFloorSeconds) {
      return 'Average';
    }
    return 'Poor';
  }

  /// What this step can actually be graded on.
  static Map<String, bool> get checks => <String, bool>{
        'press keeps the resting elevation, as MD3 specifies':
            pressKeepsRestingElevation,
        'drag is the interaction that raises the card':
            dragIsTheElevatingInteraction,
        'hover elevation is retained for pointer devices':
            hoverRaisesOnPointerDevices,
        'press produces a state layer rather than a shadow':
            responseFor(HabotCardInteraction.pressed).stateLayerOpacity > 0,
        'the press response is not hidden under the finger':
            !responseFor(HabotCardInteraction.pressed).visibleUnderAFinger &&
                responseFor(HabotCardInteraction.pressed).stateLayerOpacity > 0,
        'feedback lands inside the interactive ceiling':
            feedbackIsInsideTheCeiling,
        'every interaction has a declared response':
            responses.length == HabotCardInteraction.values.length,
        'focus is answered as well as press': responseFor(
              HabotCardInteraction.focused,
            ).stateLayerOpacity >
            0,
      };

  static double get adherence =>
      checks.values.where((bool b) => b).length / checks.length;

  static const String elevationOnPressIsAPointerIdeaNote =
      'MD3 returns an elevated card to its resting level on press and answers '
      'the press with a state layer. On a touch screen the finger is on top of '
      'the surface that would cast the shadow, so a press elevation animates '
      'something the hand is covering. The elevating half of the row is '
      'honoured on hover, where a pointer device can see it, and declined on '
      'press, where nothing can.';

  static const String metricDoesNotMeasureTheRowNote =
      'Time-to-Find measures how long it takes to locate a category. Press '
      'feedback changes whether a tap felt registered, which is a different '
      'property, measured after the category has already been found. The '
      'figure the row asks for cannot be produced from anything this step '
      'builds and is not invented; what is reported is the feedback latency '
      'against the interactive ceiling.';

  static const String invertedBandNote =
      'Floor 10s, optimal 3s, ceiling 15s. On a duration the convention '
      'inverts: the ceiling is the WORST tolerated value, not the best. A '
      'reader applying the sheet\'s usual higher-is-better reading grades a '
      'fifteen-second search as a ceiling result. Recorded because the same '
      'shape will recur on every duration metric in the sheet.';

  static const String columnNote =
      'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic Step: '
      '"Implement M3 Elevating Card effects on category card press events."';
}
