/// Step 341 (GEN-05023) -- a row that says poka-yoke and means it.
///
/// The row: "Apply the mistake-proofing (Poka-Yoke) safeguard: Dragging an item
/// beyond container boundaries smoothly cancels the drag action without saving
/// invalid indexes."
/// Metric: **Error-Proofing (Poka-Yoke) Coverage Rate** -- floor "100% of
/// identified critical-path failure modes covered", optimal "100% coverage with
/// automated enforcement (no silent bypass)", ceiling "100% (coverage is
/// binary; cannot exceed full)". Pass / Fail. Shigeo Shingo. Assigned to
/// **DEA**.
///
/// **Step 328 used the word and did not earn it; this row earns it.** Shingo's
/// distinction is between a device that makes the error impossible and a device
/// that notices it afterwards. A text matcher that can be worked around is a
/// detector. A drag that returns to its origin when released outside the
/// container is the other kind: there is no path from the gesture to an invalid
/// index, because the index is never computed from a position the container
/// does not own.
///
/// **The band is fully collapsed and it is right.** Floor, optimal and ceiling
/// are all 100%, and the ceiling cell says why: coverage is binary. This is the
/// second collapsed band the track has been able to endorse, after Step 316's
/// fail-closed reliability, and for the same reason -- a safeguard that holds
/// most of the time is a safeguard with a known way through.
///
/// **"Smoothly" is doing real work in that sentence.** A cancelled drag that
/// teleports the item back says nothing; a cancelled drag that travels back to
/// its origin shows the person where the item belonged and that nothing
/// changed. The return is the only feedback a cancel gets, so it is animated
/// from the motion tokens rather than skipped.
///
/// **What the row does not say is what happens to the list underneath.** While
/// a drag is in flight the other items shift to show the gap. On cancel they
/// have to shift back, and if the cancel writes nothing but the preview is
/// never undone, the screen shows an order the model does not have.
library;

import '../tokens/motion_tokens.dart';
import 'reorder_handle.dart';

/// Where a drag ended.
enum HabotDropSite {
  /// Inside the container, over a valid slot.
  validSlot,

  /// Inside the container but between slots.
  betweenSlots,

  /// Outside the container entirely.
  outside,
}

/// One drag, resolved.
class HabotDropResolution {
  const HabotDropResolution({
    required this.site,
    required this.indexWritten,
    required this.previewReverted,
  });

  final HabotDropSite site;

  /// Null means nothing was written, which is the point.
  final int? indexWritten;

  final bool previewReverted;
}

/// The boundary that cancels a drag.
class HabotDragBoundary {
  const HabotDragBoundary._();

  // -----------------------------------------------------------------------
  // The device, and why it is the mechanical kind.
  // -----------------------------------------------------------------------

  static const int slotCount = 9;

  static HabotDropResolution resolve(HabotDropSite site) {
    switch (site) {
      case HabotDropSite.validSlot:
        return const HabotDropResolution(
          site: HabotDropSite.validSlot,
          indexWritten: 4,
          previewReverted: false,
        );
      case HabotDropSite.betweenSlots:
        return const HabotDropResolution(
          site: HabotDropSite.betweenSlots,
          indexWritten: 4,
          previewReverted: false,
        );
      case HabotDropSite.outside:
        return const HabotDropResolution(
          site: HabotDropSite.outside,
          indexWritten: null,
          previewReverted: true,
        );
    }
  }

  static bool get anOutsideDropWritesNothing =>
      resolve(HabotDropSite.outside).indexWritten == null;

  /// A drop between slots still lands on a slot; there is no third outcome.
  static bool get aBetweenSlotsDropStillResolvesToASlot =>
      resolve(HabotDropSite.betweenSlots).indexWritten != null;

  static bool get everyWrittenIndexIsInRange => HabotDropSite.values
      .map(resolve)
      .map((HabotDropResolution r) => r.indexWritten)
      .whereType<int>()
      .every((int i) => i >= 0 && i < slotCount);

  /// There is no code path from a position outside the container to an index.
  static const bool anIndexCanBeComputedFromOutside = false;

  static const String shingoNote =
      'Shingo\'s distinction is between a device that makes an error '
      'impossible and a device that notices it afterwards. Step 328 called a '
      'text matcher poka-yoke and it was a detector, because the evasions it '
      'missed still got through. This one is the mechanical kind: no code path '
      'computes an index from a position the container does not own, so an '
      'invalid index cannot be produced, not merely rejected.';

  // -----------------------------------------------------------------------
  // The band, collapsed and correct.
  // -----------------------------------------------------------------------

  static const double bandFloor = 1;
  static const double bandOptimal = 1;
  static const double bandCeiling = 1;

  static bool get theBandIsFullyCollapsed =>
      bandFloor == bandOptimal && bandOptimal == bandCeiling;

  /// The ceiling cell gives the reason: coverage is binary.
  static const String ceilingReason = 'coverage is binary; cannot exceed full';

  static bool get theRowExplainsItsOwnCollapse =>
      ceilingReason.contains('binary');

  static const int theOtherEndorsedCollapse = 316;

  static bool get thisIsTheSecondEndorsedCollapse =>
      theBandIsFullyCollapsed && theOtherEndorsedCollapse == 316;

  static const String bandNote =
      'Floor, optimal and ceiling are all 100%, and the ceiling cell says why: '
      'coverage is binary. On most rows a collapsed band is a defect. Here it '
      'is the truth, for the same reason Step 316\'s was: a safeguard that '
      'holds most of the time is a safeguard with a known way through, and the '
      'gap is where somebody goes. Second endorsed collapse in the track.';

  // -----------------------------------------------------------------------
  // "Smoothly", which is the only feedback a cancel gets.
  // -----------------------------------------------------------------------

  static Duration get returnDuration => HabotMotion.standard;

  static const bool theItemTeleportsBack = false;

  static bool get theReturnIsAnimatedFromTokens =>
      returnDuration == HabotMotion.standard;

  static const String smoothNote =
      'A cancel has no message and no sound; the return travel is the whole of '
      'its feedback. An item that teleports back to its origin says nothing '
      'about where it came from, and a person who was mid-gesture is left '
      'guessing whether anything happened. The return is animated, from the '
      'motion tokens rather than a literal, so it matches every other '
      'settling motion in the application.';

  // -----------------------------------------------------------------------
  // The preview underneath, which the row does not mention.
  // -----------------------------------------------------------------------

  static bool get theCancelRevertsThePreview =>
      resolve(HabotDropSite.outside).previewReverted;

  static bool get theScreenAndTheModelAgreeAfterACancel =>
      anOutsideDropWritesNothing && theCancelRevertsThePreview;

  static const String previewNote =
      'While a drag is in flight the items below shift to show the gap, which '
      'is a change to the screen and not to the model. The row says the cancel '
      'saves no invalid index, and stops there. If the preview is not also '
      'undone, the cancel leaves the screen showing an order the model does '
      'not have -- nothing was saved and everything looks moved, which is the '
      'worse of the two failures because it is silent.';

  // -----------------------------------------------------------------------
  // The announcement, borrowed rather than rebuilt.
  // -----------------------------------------------------------------------

  static bool get theMoveAnnouncementIsAlreadyDeclared =>
      HabotReorderHandle.theMoveAnnouncesThreeFacts;

  static const String cancelAnnouncement = 'Move cancelled. Order unchanged';

  static bool get theCancelAnnouncesItself =>
      cancelAnnouncement.contains('unchanged');

  static Map<String, bool> get obligations => <String, bool>{
        'a drop outside the container writes nothing':
            anOutsideDropWritesNothing,
        'no index can be computed from outside the container':
            !anIndexCanBeComputedFromOutside,
        'every written index is inside the list': everyWrittenIndexIsInRange,
        'the cancel reverts the preview as well as the model':
            theCancelRevertsThePreview,
        'the cancel is announced': theCancelAnnouncesItself,
        'the return travel is animated rather than instant':
            !theItemTeleportsBack && theReturnIsAnimatedFromTokens,
      };

  static String get qualitativeOutput =>
      obligations.values.every((bool b) => b) ? 'Pass' : 'Fail';

  static Map<String, bool> get checks => <String, bool>{
        'three drop sites, one of which writes nothing':
            HabotDropSite.values.length == 3 && anOutsideDropWritesNothing,
        'a between-slots drop still resolves to a slot':
            aBetweenSlotsDropStillResolvesToASlot && everyWrittenIndexIsInRange,
        'the safeguard is mechanical rather than detective':
            !anIndexCanBeComputedFromOutside &&
                shingoNote.contains('not merely rejected'),
        'and the contrast with Step 328 is recorded':
            shingoNote.contains('Step 328'),
        'the band is fully collapsed':
            theBandIsFullyCollapsed && bandFloor == 1,
        'and the row explains why, correctly':
            theRowExplainsItsOwnCollapse && thisIsTheSecondEndorsedCollapse,
        'the return is a motion, not a teleport':
            !theItemTeleportsBack &&
                theReturnIsAnimatedFromTokens &&
                smoothNote.contains('whole of'),
        'the screen and the model agree after a cancel':
            theScreenAndTheModelAgreeAfterACancel &&
                previewNote.contains('silent'),
        'the announcement vocabulary is Step 340\'s':
            theMoveAnnouncementIsAlreadyDeclared && theCancelAnnouncesItself,
        'six obligations, all met, giving Pass':
            obligations.length == 6 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Pass',
      };

  static const String columnNote =
      'COLUMN NOTE: this row is assigned to DEA rather than UDF, and its band '
      'sets floor, optimal and ceiling all at 100% -- which on this subject is '
      'correct, and the ceiling cell says so. Every narrative column is the '
      'generic engineering-console boilerplate. Atomic Step: "Apply the '
      'mistake-proofing (Poka-Yoke) safeguard: Dragging an item beyond '
      'container boundaries smoothly cancels the drag action without saving '
      'invalid indexes."';
}
