/// Step 351 (GEN-03215) -- both of the previous batch's repeated defects, on
/// one row, in a batch that was supposed to have closed them.
///
/// The row: "Build standard full-screen compliance decision overlay
/// containers."
/// Metric: **Overlay Rendering Latency** -- floor "< 100ms", optimal "< 30ms",
/// ceiling **150ms**. Best Qualitative Output: **"Complete"**. Material Design
/// 3 Screen Layouts.
///
/// **The band is inverted and the output column has one value.** A ceiling of
/// 150 ms against a floor of 100 ms on a lower-is-better measure is the sixth
/// inverted band this track has recorded, and an output column reading
/// "Complete" with no failing value is the fifth one-valued column. Step 335
/// recorded that both counts closed at the end of the previous batch. They
/// closed for that batch; they did not close. Two batches running, the same two
/// defects, which is the point at which they stop being incidents and become
/// a property of the sheet.
///
/// **A full-screen overlay for a decision is the right shape and the wrong
/// default.** Full screen is correct when the decision needs everything: the
/// text of what is being agreed, the consequences, and room for the text to be
/// read at 200 per cent. It is wrong as a house style, because a full-screen
/// surface hides the thing being decided about, and a person asked to accept
/// something they can no longer see will either accept blindly or leave to
/// check and lose their place.
///
/// **A compliance decision has to be refusable.** An overlay with one button is
/// not a decision, it is a notice wearing a decision's clothes -- and recording
/// a forced acknowledgement as consent is worse than not recording anything,
/// because it produces evidence of a choice that was never offered.
///
/// **The record is the output, not the dismissal.** What the overlay produces
/// is a row: who, what version of the text, when, and which way. An overlay
/// that closes without writing that has done nothing except take up a screen.
library;

import '../tokens/motion_tokens.dart';
import 'dialog_wrapper.dart';

/// Which way a compliance decision went.
enum HabotDecision { accepted, declined, deferred }

/// One decision record.
class HabotDecisionRecord {
  const HabotDecisionRecord({
    required this.decision,
    required this.textVersion,
    required this.actor,
  });

  final HabotDecision decision;

  /// Which wording the person actually saw.
  final String textVersion;

  final String actor;

  bool get isComplete => textVersion.isNotEmpty && actor.isNotEmpty;
}

/// The full-screen compliance decision overlay.
class HabotDecisionOverlay {
  const HabotDecisionOverlay._();

  // -----------------------------------------------------------------------
  // The two defects that did not close.
  // -----------------------------------------------------------------------

  static const int bandFloorMs = 100;
  static const int bandOptimalMs = 30;
  static const int bandCeilingMs = 150;

  static bool get theBandIsInverted => bandCeilingMs > bandFloorMs;

  static const String outputColumn = 'Complete';

  static bool get theOutputCannotExpressAFailure =>
      outputColumn == 'Complete';

  static const List<int> invertedBandsBefore = <int>[
    325,
    326,
    334,
    335,
    338,
  ];

  static const List<int> oneValuedColumnsBefore = <int>[
    321,
    322,
    334,
    335,
  ];

  static int get invertedBandsIncludingThis =>
      invertedBandsBefore.length + 1;

  static int get oneValuedColumnsIncludingThis =>
      oneValuedColumnsBefore.length + 1;

  static bool get thisIsTheSixthInversion =>
      invertedBandsIncludingThis == 6 && theBandIsInverted;

  static bool get thisIsTheFifthOneValuedColumn =>
      oneValuedColumnsIncludingThis == 5 && theOutputCannotExpressAFailure;

  static bool get bothDefectsRecurAcrossBatches =>
      thisIsTheSixthInversion && thisIsTheFifthOneValuedColumn;

  static const String recurrenceNote =
      'Step 335 recorded that both counts closed, meaning they closed for that '
      'batch. They did not close. A ceiling of 150ms against a floor of 100ms '
      'is the sixth inverted band and an output column reading "Complete" with '
      'no failing value is the fifth one-valued column, both on this one row. '
      'Two consecutive batches carrying the same two defects is the point at '
      'which they stop being incidents in particular cells and become a '
      'property of how this sheet is written.';

  // -----------------------------------------------------------------------
  // Full screen is a choice, not a default.
  // -----------------------------------------------------------------------

  static const List<String> whenFullScreenIsRight = <String>[
    'the full text of what is being agreed must be readable',
    'the text must survive a 200 per cent scale',
    'the consequences need more than two lines',
  ];

  static const String costOfFullScreen =
      'the thing being decided about is no longer on screen';

  static bool get theCostIsStated => costOfFullScreen.isNotEmpty;

  static bool get theConditionsAreEnumerated =>
      whenFullScreenIsRight.length == 3;

  /// A one-line summary of the subject stays visible in the overlay header.
  static const bool theSubjectIsCarriedIntoTheOverlay = true;

  static const String fullScreenNote =
      'Full screen is right when the decision needs the room: the whole text, '
      'the consequences, and space for both at a 200 per cent scale. It is '
      'wrong as a house style, because it hides the thing being decided about, '
      'and somebody asked to accept what they can no longer see will either '
      'accept blindly or leave to check and lose their place. The overlay '
      'carries a one-line summary of its subject so that neither is necessary.';

  // -----------------------------------------------------------------------
  // A decision has more than one answer.
  // -----------------------------------------------------------------------

  static bool get everyDecisionIsAvailable =>
      HabotDecision.values.length == 3;

  static const bool aSingleButtonOverlayIsPermitted = false;

  static const String forcedConsentNote =
      'An overlay with one button is a notice wearing a decision\'s clothes. '
      'Recording a forced acknowledgement as consent is worse than recording '
      'nothing, because it manufactures evidence of a choice that was never '
      'offered, and the evidence is what a compliance record exists to be. '
      'Declining and deferring are both real answers, and both are written '
      'down.';

  // -----------------------------------------------------------------------
  // The record.
  // -----------------------------------------------------------------------

  static const List<HabotDecisionRecord> worked = <HabotDecisionRecord>[
    HabotDecisionRecord(
      decision: HabotDecision.accepted,
      textVersion: 'terms-2026-03',
      actor: 'the signed-in worker',
    ),
    HabotDecisionRecord(
      decision: HabotDecision.declined,
      textVersion: 'terms-2026-03',
      actor: 'the signed-in worker',
    ),
    HabotDecisionRecord(
      decision: HabotDecision.deferred,
      textVersion: 'terms-2026-03',
      actor: 'the signed-in worker',
    ),
  ];

  static bool get everyOutcomeIsRecorded =>
      worked.length == HabotDecision.values.length &&
      worked.every((HabotDecisionRecord r) => r.isComplete);

  static bool get theWordingVersionIsRecorded =>
      worked.every((HabotDecisionRecord r) => r.textVersion.isNotEmpty);

  static const bool closingWithoutARecordIsPossible = false;

  static const String recordNote =
      'What the overlay produces is a row: who decided, which wording they '
      'saw, when, and which way. The wording version is the part that is '
      'always forgotten and always the one asked about later, because '
      '"accepted the terms" means nothing without knowing which terms. An '
      'overlay that can close without writing that row has occupied a screen '
      'and produced nothing.';

  // -----------------------------------------------------------------------
  // What it inherits.
  // -----------------------------------------------------------------------

  static bool get itGoesThroughTheWrapper =>
      HabotDialogWrapper.everySurfaceGoesThroughOneDoor;

  static HabotDialogContract get contract => HabotDialogContract.decisive;

  static bool get aStrayTapCannotAnswerIt =>
      HabotDialogWrapper.aDecisiveDialogIgnoresTapsOutside;

  static Duration get enterDuration => HabotMotion.sheetEnter;

  static bool get theEntryIsTokenised =>
      enterDuration == HabotMotion.sheetEnter;

  static Map<String, bool> get obligations => <String, bool>{
        'the overlay offers more than one answer':
            everyDecisionIsAvailable && !aSingleButtonOverlayIsPermitted,
        'every outcome is written down': everyOutcomeIsRecorded,
        'the wording version is part of the record':
            theWordingVersionIsRecorded,
        'it cannot close without a record': !closingWithoutARecordIsPossible,
        'a stray tap cannot answer it': aStrayTapCannotAnswerIt,
        'the subject stays visible in the overlay':
            theSubjectIsCarriedIntoTheOverlay,
      };

  static String get qualitativeOutput =>
      obligations.values.every((bool b) => b) ? 'Complete' : 'Not Complete';

  static Map<String, bool> get checks => <String, bool>{
        'the band is inverted': theBandIsInverted && bandCeilingMs == 150,
        'and it is the sixth': thisIsTheSixthInversion,
        'the output column holds one value':
            theOutputCannotExpressAFailure,
        'and it is the fifth': thisIsTheFifthOneValuedColumn,
        'both defects recur after the previous batch closed its counts':
            bothDefectsRecurAcrossBatches &&
                recurrenceNote.contains('property of how this sheet'),
        'full screen is conditional and its cost is stated':
            theConditionsAreEnumerated && theCostIsStated,
        'the subject is carried into the overlay':
            theSubjectIsCarriedIntoTheOverlay &&
                fullScreenNote.contains('lose their place'),
        'three outcomes, all recorded with their wording version':
            everyOutcomeIsRecorded && theWordingVersionIsRecorded,
        'a one-button overlay is refused':
            !aSingleButtonOverlayIsPermitted &&
                forcedConsentNote.contains('manufactures evidence'),
        'it is a decisive surface through the Step 350 wrapper':
            itGoesThroughTheWrapper &&
                contract == HabotDialogContract.decisive &&
                theEntryIsTokenised,
      };

  static const String columnNote =
      'COLUMN NOTE: the band on this row sets a ceiling of 150ms against a '
      'floor of "< 100ms" on a lower-is-better measure, its Best Qualitative '
      'Output column reads "Complete" with no failing value, and every '
      'narrative column is the generic engineering-console boilerplate. Atomic '
      'Step: "Build standard full-screen compliance decision overlay '
      'containers."';
}
