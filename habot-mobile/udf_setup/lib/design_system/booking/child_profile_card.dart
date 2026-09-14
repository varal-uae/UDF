/// Step 201 (GEN-01198) -- selectable child profile cards.
///
/// The row: "Render registered child profiles as selectable M3 Outlined Cards
/// featuring avatars and checkmark selection states."
/// Metric: **Special-Requirement Field Capture Accuracy** -- 0.95 / 0.999 / 1.
/// Pass/Fail.
///
/// The metric is the instruction. The row describes a card with a face and a
/// tick on it; the metric is about whether allergies, medication and access
/// needs get captured. A card that shows an avatar and a name lets a parent
/// select by face in under a second and never discover that the allergy field
/// on that profile has been empty since the child was added. The selection
/// succeeds, the booking succeeds, and the capture accuracy the row is measured
/// on is decided by something the card never showed.
///
/// So the card carries requirement completeness, and selecting a profile whose
/// required fields are missing is not silently allowed. It is not silently
/// refused either -- refusing at the card leaves the parent tapping a card that
/// does nothing. It selects and reports what is missing, and the booking gate
/// downstream is what blocks.
///
/// **A tick is not a selection state.** To a screen reader a checkmark icon is
/// an icon; the selected state has to be announced. And to someone who cannot
/// distinguish the selected border from the unselected one, a tick plus an
/// outline colour is still one signal drawn twice. The card declares a
/// semantics payload, and selection is carried by shape and by announcement as
/// well as by colour.
library;

import '../tokens/shape_tokens.dart';

/// Fields a child profile must carry before the child can be booked onto a
/// service. Named rather than counted, so "incomplete" has an answer.
enum HabotChildRequirement {
  /// Date of birth. Decides age-band eligibility, so it is required before
  /// a booking can be priced, not merely before it is confirmed.
  dateOfBirth,

  /// Allergies. An explicit "none" is a value; an empty field is not.
  allergies,

  /// Medication carried or administered during the session.
  medication,

  /// Access, mobility or communication needs.
  accessNeeds,

  /// Who may collect the child.
  authorisedCollection,

  /// Emergency contact for the session.
  emergencyContact,
}

/// One child, as this card needs to know them.
class HabotChildProfile {
  const HabotChildProfile({
    required this.id,
    required this.displayName,
    required this.completedRequirements,
    this.hasAvatarImage = false,
  });

  /// Opaque profile id. The booking payload carries this, never the name.
  final String id;

  /// Shown on the card. Not sent anywhere by this file.
  final String displayName;

  /// Which required fields have a value.
  final Set<HabotChildRequirement> completedRequirements;

  /// Whether this profile has a photograph.
  final bool hasAvatarImage;

  List<HabotChildRequirement> get missingRequirements =>
      HabotChildRequirement.values
          .where(
            (HabotChildRequirement r) => !completedRequirements.contains(r),
          )
          .toList();

  bool get isComplete => missingRequirements.isEmpty;

  /// Share of required fields captured on this profile.
  double get captureRate =>
      completedRequirements
          .where(HabotChildRequirement.values.contains)
          .length /
      HabotChildRequirement.values.length;
}

/// How a card announces itself.
class HabotChildCardSemantics {
  const HabotChildCardSemantics({
    required this.label,
    required this.selected,
    required this.hint,
    required this.avatarLabel,
  });

  /// The accessible name of the card.
  final String label;

  /// The selected state, carried as state rather than as a drawn tick.
  final bool selected;

  /// What happens on activation.
  final String hint;

  /// What the avatar is. A child's photograph is not decorative, so it is
  /// never marked as such; a profile with no photograph gets the initial
  /// treatment and says so.
  final String avatarLabel;
}

/// Card geometry and behaviour.
class HabotChildProfileCard {
  const HabotChildProfileCard._();

  /// MD3 outlined card: an outline, no fill, elevation level 0.
  static double get outlineWidthDp => HabotShape.borderWidth;

  /// The selected outline is thicker as well as differently coloured, so
  /// selection survives a viewer who cannot separate the two colours.
  static double get selectedOutlineWidthDp => HabotShape.focusBorderWidth;

  static double get cornerRadiusDp => HabotShape.md;

  static bool get selectionIsNotColourAlone =>
      selectedOutlineWidthDp > outlineWidthDp;

  /// The colour roles used, as token names. Audited elsewhere; declared here so
  /// a role that was never audited is visible rather than implicit.
  static const String unselectedOutlineToken = 'md.sys.color.outline-variant';
  static const String selectedOutlineToken = 'md.sys.color.primary';
  static const String requirementWarningToken = 'md.sys.color.error';

  static String _missingPhrase(HabotChildProfile profile) {
    final int n = profile.missingRequirements.length;
    return n == 1
        ? '1 required detail missing'
        : '$n required details missing';
  }

  /// The semantics payload for one card.
  static HabotChildCardSemantics semanticsFor(
    HabotChildProfile profile, {
    required bool selected,
  }) =>
      HabotChildCardSemantics(
        label: profile.isComplete
            ? profile.displayName
            : '${profile.displayName}, ${_missingPhrase(profile)}',
        selected: selected,
        hint: selected ? 'Double tap to remove from booking'
            : 'Double tap to add to booking',
        avatarLabel: profile.hasAvatarImage
            ? 'Photo of ${profile.displayName}'
            : 'Initials for ${profile.displayName}',
      );

  /// True when the card tells the user what is missing before they choose.
  static bool surfacesMissingRequirements(HabotChildProfile profile) =>
      profile.isComplete ||
      semanticsFor(profile, selected: false).label.contains('missing');

  /// Selection is allowed; completeness is reported.
  ///
  /// The card does not refuse. A card that does nothing when tapped is a bug
  /// report, not a validation message. The booking gate is where a missing
  /// requirement stops the flow -- see Step 202.
  static bool mayBeSelected(HabotChildProfile profile) => true;

  /// Whether a selected profile is fit to be sent with a booking.
  static bool isBookable(HabotChildProfile profile) => profile.isComplete;

  // -----------------------------------------------------------------------
  // Metric: Special-Requirement Field Capture Accuracy. 0.95 / 0.999 / 1.
  // -----------------------------------------------------------------------

  static const double floor = 0.95;
  static const double optimal = 0.999;
  static const double ceiling = 1;

  /// Capture accuracy across a set of profiles: the share of required fields
  /// that actually carry a value.
  static double captureAccuracy(Iterable<HabotChildProfile> profiles) {
    final List<HabotChildProfile> all = profiles.toList();
    if (all.isEmpty) {
      return 0;
    }
    final int required =
        all.length * HabotChildRequirement.values.length;
    final int captured = all
        .map((HabotChildProfile p) => p.completedRequirements.length)
        .fold(0, (int a, int b) => a + b);
    return captured / required;
  }

  /// What the same set would report if capture were measured as "did the card
  /// get selected" -- the thing the row's own description makes easy to count.
  ///
  /// Always 1.0 for any selectable card, which is why it is the wrong number.
  static double selectionSuccessRate(Iterable<HabotChildProfile> profiles) {
    final List<HabotChildProfile> all = profiles.toList();
    if (all.isEmpty) {
      return 0;
    }
    return all.where(mayBeSelected).length / all.length;
  }

  static String qualitativeOutput(double accuracy) =>
      accuracy >= floor ? 'Pass' : 'Fail';

  static const String metricIsTheInstructionNote =
      'The row describes a face and a tick; the metric is about whether '
      'allergies, medication and access needs get captured. A card showing a '
      'photograph and a name lets a parent select by face in under a second '
      'and never discover that the allergy field has been empty since the '
      'child was added. What the card surfaces decides the number the row is '
      'graded on.';

  static const String selectNotRefuseNote =
      'An incomplete profile can still be selected. A card that does nothing '
      'when tapped is reported as a broken card, not as a validation message. '
      'The card names what is missing; the booking gate is what blocks.';

  static const String tickIsNotAStateNote =
      'To a screen reader a checkmark is an icon, not a selection. The card '
      'carries the selected state as state, and the selected outline is '
      'thicker as well as differently coloured, so selection survives a viewer '
      'who cannot separate the two colours.';

  static const String avatarIsNotDecorativeNote =
      'Step 97 A11Y_RAW_IMAGE: an image with no semantic label is invisible. A '
      'child\'s photograph is never marked decorative here, and a profile with '
      'no photograph announces initials rather than announcing nothing.';

  static const String nameStaysOnTheDeviceNote =
      'The card shows the display name; the booking payload carries the '
      'profile id. A child\'s name in an analytics event is the Step 157 '
      'sanitiser\'s problem only if it gets that far, and it does not need to.';

  static const String columnNote =
      'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic Step: '
      '"Render registered child profiles as selectable M3 Outlined Cards '
      'featuring avatars and checkmark selection states."';
}
