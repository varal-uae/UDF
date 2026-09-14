/// Step 202 (GEN-01507) -- assigning children to a booking payload.
///
/// The row: "Add a single-tap card interaction allowing parents to assign one
/// or more children to the booking payload."
/// Metric: Special-Requirement Field Capture Accuracy -- 0.95 / 0.999 / 1.
///
/// Single tap is the right interaction and it has one property worth designing
/// around: it is symmetric. The gesture that adds a child is the gesture that
/// removes one, so a mis-tap while scrolling a list of four siblings silently
/// drops a child from the booking, and nothing about the screen has changed
/// except one outline. The count is therefore always visible and the payload is
/// derived from the selection set rather than accumulated alongside it -- a
/// selection set and a payload list that are updated separately will disagree,
/// and the one that gets sent is the one nobody is looking at.
///
/// "One or more" is the other half. A booking with zero children is refusable
/// here rather than at the payment step, and a booking past the session's
/// capacity fails at the tap that exceeds it, with the reason, rather than at
/// submit where the parent has to work out which child to drop.
///
/// The link to the metric is Step 201's: a child with missing required fields
/// can be selected but cannot be sent. This file is where "cannot be sent"
/// actually happens.
library;

import 'child_profile_card.dart';

/// Why a tap did not change the selection.
enum HabotAssignmentRefusal {
  /// The session is full.
  capacityReached,

  /// The child is not eligible for this service's age band.
  ageBand,

  /// The child is already assigned to an overlapping session.
  alreadyBookedElsewhere,
}

/// The outcome of one tap.
class HabotAssignmentResult {
  const HabotAssignmentResult({
    required this.accepted,
    required this.selectedCount,
    this.refusal,
    this.reason = '',
  });

  final bool accepted;
  final int selectedCount;
  final HabotAssignmentRefusal? refusal;

  /// Shown to the parent. Empty when the tap was accepted.
  final String reason;
}

/// What gets sent when the booking is submitted.
class HabotBookingPayload {
  const HabotBookingPayload({
    required this.serviceId,
    required this.childIds,
  });

  final String serviceId;

  /// Profile ids, in a stable order. Names are not carried.
  final List<String> childIds;

  bool get isValid => childIds.isNotEmpty;

  Map<String, Object?> toJson() => <String, Object?>{
        'serviceId': serviceId,
        'childIds': childIds,
      };
}

/// The selection, and the payload derived from it.
class HabotChildAssignment {
  HabotChildAssignment({
    required this.serviceId,
    required this.capacity,
    this.eligibleIds = const <String>{},
    this.conflictingIds = const <String>{},
  });

  final String serviceId;

  /// Maximum children this session can take.
  final int capacity;

  /// Ids the service's age band admits. Empty means "not restricted".
  final Set<String> eligibleIds;

  /// Ids already booked into an overlapping session.
  final Set<String> conflictingIds;

  /// Insertion-ordered so the payload is stable across rebuilds.
  final Set<String> _selected = <String>{};

  Set<String> get selectedIds => Set<String>.unmodifiable(_selected);

  int get selectedCount => _selected.length;

  bool isSelected(String id) => _selected.contains(id);

  /// Always visible on the screen. The count is the only thing that changes
  /// legibly when a mis-tap removes a child.
  String get countLabel => selectedCount == 1
      ? '1 child selected'
      : '$selectedCount children selected';

  int get remainingCapacity => capacity - selectedCount;

  /// One tap. Adds if absent, removes if present.
  HabotAssignmentResult toggle(HabotChildProfile profile) {
    if (_selected.contains(profile.id)) {
      _selected.remove(profile.id);
      return HabotAssignmentResult(
        accepted: true,
        selectedCount: selectedCount,
      );
    }
    if (eligibleIds.isNotEmpty && !eligibleIds.contains(profile.id)) {
      return HabotAssignmentResult(
        accepted: false,
        selectedCount: selectedCount,
        refusal: HabotAssignmentRefusal.ageBand,
        reason: '${profile.displayName} is outside this service\'s age range.',
      );
    }
    if (conflictingIds.contains(profile.id)) {
      return HabotAssignmentResult(
        accepted: false,
        selectedCount: selectedCount,
        refusal: HabotAssignmentRefusal.alreadyBookedElsewhere,
        reason: '${profile.displayName} is already booked at this time.',
      );
    }
    if (selectedCount >= capacity) {
      return HabotAssignmentResult(
        accepted: false,
        selectedCount: selectedCount,
        refusal: HabotAssignmentRefusal.capacityReached,
        reason: 'This session takes $capacity children. '
            'Remove one to add ${profile.displayName}.',
      );
    }
    _selected.add(profile.id);
    return HabotAssignmentResult(accepted: true, selectedCount: selectedCount);
  }

  /// The payload, derived rather than accumulated.
  HabotBookingPayload payload() => HabotBookingPayload(
        serviceId: serviceId,
        childIds: List<String>.unmodifiable(_selected),
      );

  /// Selected profiles that cannot be sent because required fields are missing.
  List<HabotChildProfile> blockingProfiles(
    Iterable<HabotChildProfile> profiles,
  ) =>
      profiles
          .where(
            (HabotChildProfile p) =>
                _selected.contains(p.id) &&
                !HabotChildProfileCard.isBookable(p),
          )
          .toList();

  /// The submit gate: at least one child, and every selected child complete.
  bool canSubmit(Iterable<HabotChildProfile> profiles) =>
      selectedCount > 0 && blockingProfiles(profiles).isEmpty;

  /// Why submit is blocked, for the parent rather than for a log.
  String submitBlockReason(Iterable<HabotChildProfile> profiles) {
    if (selectedCount == 0) {
      return 'Choose at least one child for this booking.';
    }
    final List<HabotChildProfile> blocking = blockingProfiles(profiles);
    if (blocking.isEmpty) {
      return '';
    }
    final HabotChildProfile first = blocking.first;
    return '${first.displayName} is missing '
        '${first.missingRequirements.length} required details.';
  }

  // -----------------------------------------------------------------------
  // Metric: Special-Requirement Field Capture Accuracy.
  // -----------------------------------------------------------------------

  static const double floor = 0.95;
  static const double optimal = 0.999;
  static const double ceiling = 1;

  /// Capture accuracy over the children actually being sent -- which is the
  /// population the metric is about, and a smaller one than every registered
  /// profile.
  double captureAccuracyForSelection(Iterable<HabotChildProfile> profiles) =>
      HabotChildProfileCard.captureAccuracy(
        profiles.where((HabotChildProfile p) => _selected.contains(p.id)),
      );

  static String qualitativeOutput(double accuracy) =>
      accuracy >= floor ? 'Pass' : 'Fail';

  static const String symmetricGestureNote =
      'The gesture that adds a child is the gesture that removes one. A '
      'mis-tap while scrolling past four siblings drops a child from the '
      'booking and changes one outline. The selected count is always on '
      'screen because it is the only part of the change that is legible at a '
      'glance.';

  static const String payloadIsDerivedNote =
      'The payload is computed from the selection set rather than maintained '
      'beside it. Two structures updated separately will disagree, and the one '
      'that gets sent is the one nobody is looking at.';

  static const String failAtTheTapNote =
      'Capacity, age band and clashes are checked at the tap that would break '
      'them, with a reason. Checked at submit instead, the parent is told the '
      'booking is invalid and left to work out which child to drop.';

  static const String zeroIsRefusableNote =
      '"One or more" means zero is a state the screen can be in and submit '
      'must refuse. Refused here rather than at payment, where the refusal '
      'arrives after a card has been entered.';

  static const String idsNotNamesNote =
      'The payload carries profile ids. A child\'s name is rendered on the '
      'card and never leaves the device through this path.';

  static const String columnNote =
      'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic Step: '
      '"Add a single-tap card interaction allowing parents to assign one or '
      'more children to the booking payload."';
}
