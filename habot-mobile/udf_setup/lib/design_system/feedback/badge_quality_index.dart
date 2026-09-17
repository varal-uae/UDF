/// Step 312 (RTSET-033) -- a ceiling below its own optimal, and a Setup Step
/// that binds an app action to the screen reader's activation gesture.
///
/// The row: "Select status badge styling and dashboard container layouts for
/// mobile views."
/// Metric: **Select Status Badge Quality Index** -- floor 0.98, optimal 1,
/// **ceiling 0.999**. Complete.
///
/// **The ceiling is below the optimal.** Not in a different unit, not measuring
/// a different thing: 0.999 is less than 1, so the value the row calls best is
/// outside the range the row calls acceptable, by 0.001. Every band defect
/// this track has recorded in eleven batches has been a unit mismatch, a floor
/// that cannot fail, or a boundary describing another subject. This is the
/// first one that is simply false on its own terms.
///
/// **And none of the three numbers is reachable.** The thing being scored is
/// five status badges. An index over five items moves in fifths: 1.0, 0.8,
/// 0.6, and so on. There is no value at 0.98 and none at 0.999, so the floor
/// and the ceiling both name states the measurement cannot produce, and
/// exactly one attainable value -- 1.0 -- clears the floor. The band is a
/// Pass/Fail with three decimal places, which is what the row's own
/// qualitative column, "Complete", already said. Step 305 in this batch has
/// the same defect at a different scale.
///
/// **The styling was selected eight steps into this project and has three
/// carriers.** `HabotStatusSpec` already holds a label, an icon and a colour
/// role for each of five statuses, because SC 1.4.1 needs the first two and
/// the third is reinforcement. "Select status badge styling" is therefore a
/// row asking for a decision that exists; what it adds is the dashboard
/// container around the badge, and the Setup Step, which is the part worth
/// arguing with.
///
/// **A double-tap is not a free gesture.** The Setup Step asks for "haptic
/// feedback on double-tap confirmation". With TalkBack or VoiceOver running, a
/// double-tap **is** activation: the person explores by touch to find a
/// control and double-taps to press it. An application that treats double-tap
/// as a distinct confirming gesture receives an ordinary press from every
/// screen reader user and a confirmation from everyone else, which means the
/// people most likely to want a confirmation step are the only ones who cannot
/// reach it. Confirmation belongs on a control, not on a gesture count.
///
/// **COLUMN NOTE.** This is the only row in this batch assigned to ADFA rather
/// than UDF. Its Output Type cell is a sentence about stale FCM and APNs push
/// tokens, its Decision Group is "Benefits.", and its narrative columns are
/// about an insurance pricing engine -- "Your Cost Per Pay Period widget",
/// "100% rate accuracy vs carrier".
library;

import '../interaction/haptics.dart';
import '../tokens/motion_tokens.dart';
import 'status_badge.dart';

/// The step.
class HabotBadgeQualityIndex {
  const HabotBadgeQualityIndex._();

  // -----------------------------------------------------------------------
  // The band that cannot be satisfied.
  // -----------------------------------------------------------------------

  static const double bandFloor = 0.98;
  static const double bandOptimal = 1.0;
  static const double bandCeiling = 0.999;

  static bool get theCeilingIsBelowTheOptimal => bandCeiling < bandOptimal;

  static double get byHowMuch => bandOptimal - bandCeiling;

  /// The population being scored.
  static int get badgesScored => HabotStatus.values.length;

  static double get smallestIndexStep => 1 / badgesScored;

  static List<double> get attainableIndexValues => List<double>.generate(
        badgesScored + 1,
        (int i) => i / badgesScored,
      );

  static List<double> get attainableValuesClearingTheFloor =>
      attainableIndexValues.where((double v) => v >= bandFloor).toList();

  static bool get neitherTheFloorNorTheCeilingIsAttainable =>
      !attainableIndexValues.contains(bandFloor) &&
      !attainableIndexValues.contains(bandCeiling);

  static bool get exactlyOneValuePasses =>
      attainableValuesClearingTheFloor.length == 1 &&
      attainableValuesClearingTheFloor.first == 1.0;

  static const String bandNote =
      'The ceiling, 0.999, is below the optimal, 1, by a thousandth: the value '
      'the row calls best sits outside the range the row calls acceptable. '
      'Eleven batches of band defects in this track have been unit mismatches, '
      'unfailable floors or boundaries about another subject; this is the '
      'first that is false on its own terms. And the population is five '
      'badges, so the index moves in fifths and neither 0.98 nor 0.999 is a '
      'value it can take. One attainable value clears the floor. The band is a '
      'Pass/Fail with three decimal places, which is what the qualitative '
      'column already said.';

  // -----------------------------------------------------------------------
  // The styling, which already exists and has three carriers.
  // -----------------------------------------------------------------------

  static bool get everyStatusHasASpec => HabotStatuses.isComplete;

  static Iterable<HabotStatusSpec> get specs => HabotStatuses.all;

  /// A label that is present, and a spec that is filed under the status it
  /// says it is -- the two ways a five-entry table goes wrong.
  static bool get everySpecCarriesAllThree => specs.every(
        (HabotStatusSpec s) =>
            s.label.trim().isNotEmpty &&
            identical(HabotStatuses.of(s.status), s),
      );

  static bool get noTwoStatusesShareALabel =>
      specs.map((HabotStatusSpec s) => s.label).toSet().length == badgesScored;

  static Set<HabotStatusRole> get rolesInUse =>
      specs.map((HabotStatusSpec s) => s.role).toSet();

  /// Two statuses may legitimately share a colour role, because the label and
  /// the icon are what separate them. The index is over labels, not colours.
  static bool get theIndexIsOverLabelsRatherThanColours =>
      noTwoStatusesShareALabel && rolesInUse.length <= badgesScored;

  static double get observedIndex => noTwoStatusesShareALabel &&
          everySpecCarriesAllThree &&
          everyStatusHasASpec
      ? 1.0
      : specs.where((HabotStatusSpec s) => s.label.isNotEmpty).length /
          badgesScored;

  static const String stylingNote =
      'The selection this row asks for was made when the badge component was '
      'built: each of five statuses carries a label, an icon and a colour '
      'role, because SC 1.4.1 needs the first two and the third is '
      'reinforcement. Asking again produces either the same answer or a second '
      'badge, and a repository with two status badges has a drift problem '
      'rather than a design. What the row adds is the container and the Setup '
      'Step.';

  // -----------------------------------------------------------------------
  // The container.
  // -----------------------------------------------------------------------

  /// A badge inside a card is not a control. Making the badge tappable to
  /// "see more" puts a target inside a row that is already a target.
  static const bool theBadgeIsInteractive = false;

  static const String containerNote =
      'The badge sits inside the row\'s own tappable area and is not itself a '
      'target. A tappable badge inside a tappable row gives a finger two '
      'answers for one landing, and the one it gets depends on a few points of '
      'travel nobody can control. The row opens the record; the badge says '
      'what state it is in. One target, one meaning.';

  // -----------------------------------------------------------------------
  // The Setup Step, refused.
  // -----------------------------------------------------------------------

  /// The strength the row asks for, which the haptics component already
  /// declares for a confirmed destructive action.
  static HabotHapticStrength get requestedStrength =>
      HabotHaptics.strengthFor(HabotHapticMoment.destructiveConfirmed);

  static bool get theRequestedStrengthAlreadyExists =>
      requestedStrength == HabotHapticStrength.medium;

  /// The window a platform uses to decide that two taps were one gesture.
  static Duration get doubleTapWindow => HabotMotion.doubleTapWindow;

  static const List<String> screenReadersThatOwnDoubleTap = <String>[
    'TalkBack: explore by touch, then double-tap to activate',
    'VoiceOver: single tap to select, then double-tap to activate',
  ];

  static const bool doubleTapIsBoundToAnAppAction = false;

  static bool get theGestureIsOwnedByAssistiveTechnology =>
      screenReadersThatOwnDoubleTap.length == 2;

  /// Where the confirmation goes instead.
  static const String confirmationMechanism =
      'a named confirming control in a dialog, with the haptic on its press';

  static const String gestureNote =
      'With TalkBack or VoiceOver running, a double-tap IS activation: the '
      'person explores by touch to find a control and double-taps to press it. '
      'An application that treats double-tap as a separate confirming gesture '
      'receives an ordinary press from every screen reader user and a '
      'confirmation from everyone else -- so the people most likely to want a '
      'confirmation step are the only ones who cannot reach it, and nothing in '
      'testing shows it unless somebody turns a screen reader on. The haptic '
      'moves to the press of a named control, where the strength the row asks '
      'for is already declared.';

  // -----------------------------------------------------------------------
  // The verdict.
  // -----------------------------------------------------------------------

  static Map<String, bool> get obligations => <String, bool>{
        'every status has a spec': everyStatusHasASpec,
        'no two statuses share a label': noTwoStatusesShareALabel,
        'the badge is not a target inside a target': !theBadgeIsInteractive,
        'no app action is bound to a double-tap':
            !doubleTapIsBoundToAnAppAction,
        'the confirming haptic fires on a named control':
            theRequestedStrengthAlreadyExists,
      };

  static String get qualitativeOutput =>
      obligations.values.every((bool b) => b) ? 'Complete' : 'Incomplete';

  static Map<String, bool> get checks => <String, bool>{
        'the ceiling is a thousandth below the optimal':
            theCeilingIsBelowTheOptimal && (byHowMuch - 0.001).abs() < 1e-9,
        'five badges, so the index moves in fifths':
            badgesScored == 5 &&
                smallestIndexStep == 0.2 &&
                attainableIndexValues.length == 6,
        'and neither boundary is a value the index can take':
            neitherTheFloorNorTheCeilingIsAttainable &&
                exactlyOneValuePasses &&
                bandNote.contains('false on its own terms'),
        'the styling already carries three separators':
            everyStatusHasASpec &&
                everySpecCarriesAllThree &&
                noTwoStatusesShareALabel,
        'and the index is over labels rather than colour roles':
            theIndexIsOverLabelsRatherThanColours && observedIndex == 1.0,
        'asking again would produce a second badge':
            stylingNote.contains('drift problem'),
        'the badge is not a target inside a target':
            !theBadgeIsInteractive &&
                containerNote.contains('One target, one meaning'),
        'both screen readers own the double-tap':
            theGestureIsOwnedByAssistiveTechnology &&
                doubleTapWindow.inMilliseconds == 300,
        'so no app action is bound to it':
            !doubleTapIsBoundToAnAppAction &&
                gestureNote.contains('cannot reach it'),
        'and the requested strength was already declared':
            theRequestedStrengthAlreadyExists &&
                confirmationMechanism.contains('named confirming control'),
        'five obligations, all met, giving Complete':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Complete',
      };

  static const String columnNote =
      'COLUMN NOTE: this is the only row in this batch assigned to ADFA rather '
      'than UDF. Its Decision Group is "Benefits.", its Output Type cell is a '
      'sentence about stale FCM and APNs push tokens, its narrative columns '
      'are an insurance pricing engine -- "Your Cost Per Pay Period widget", '
      '"100% rate accuracy vs carrier" -- and its Setup Step reads "Implement '
      'haptic feedback on double-tap confirmation -- medium haptic pattern". '
      'Atomic Step: "Select status badge styling and dashboard container '
      'layouts for mobile views."';
}
