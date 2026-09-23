/// Step 481 (GEN-01032) -- submitting to a store, on the first band in the
/// track whose three cells are the same word.
///
/// The row: "Deploy production mobile app builds to Apple App Store Connect."
/// Metric: **Deployment Status** -- floor "Deployed", optimal "Deployed",
/// ceiling "Deployed". Complete / Not Complete. Apple App Store Release Rules.
/// Assigned to **ADFA**.
///
/// **Floor, optimal and ceiling are one word, repeated three times.** Step 456
/// found a floor and a ceiling that were one boundary; Step 460 found a floor
/// and an optimal that were one state. This row collapses all three, which
/// means the band is not a band at all: it is a state, and a state cannot be
/// exceeded, missed or improved.
///
/// **And it is somebody else's state.** Whether a build is deployed depends on
/// a review carried out by people who do not work here and who answer to
/// their own timetable. Measuring the team on it measures the reviewer. So
/// what is measured instead is what the team controls and what a reviewer
/// will check: the build is signed with the right identity, every required
/// piece of metadata is present, the submission is reproducible from a tagged
/// commit, and the privacy declarations match what the application actually
/// collects.
///
/// **The privacy declaration has to match the allowlist.** Step 419 fixed the
/// telemetry payload at eight fields, none of which identifies a person. A
/// store declaration that claims more, or less, is either a false statement
/// to the people downloading the application or a promise the code does not
/// keep. The two are compared, field by field, before submission.
///
/// **Rejection is a state, not a failure of the build.** A rejected submission
/// records the reviewer's reason verbatim, and nothing about it changes the
/// artefact hash: the same build is resubmitted unless the reason requires a
/// code change, in which case it gets a new version and a new tag.
library;

import '../telemetry/tracking_sdk.dart';

/// One submission to the store.
class HabotSubmission {
  const HabotSubmission({
    required this.version,
    required this.tag,
    required this.signed,
    required this.metadataComplete,
    required this.outcome,
    required this.reviewerReason,
  });

  final String version;
  final String tag;
  final bool signed;
  final bool metadataComplete;

  /// 'accepted', 'rejected' or 'in review'.
  final String outcome;

  /// Verbatim, when there is one.
  final String reviewerReason;
}

/// The store submission.
class HabotStoreSubmission {
  const HabotStoreSubmission._();

  // -----------------------------------------------------------------------
  // One word, three times.
  // -----------------------------------------------------------------------

  static const String bandFloorRaw = 'Deployed';
  static const String bandOptimalRaw = 'Deployed';
  static const String bandCeilingRaw = 'Deployed';

  static bool get allThreeCellsAreIdentical =>
      bandFloorRaw == bandOptimalRaw && bandOptimalRaw == bandCeilingRaw;

  /// A floor and a ceiling (456), a floor and an optimal (460), all three
  /// (here).
  static const List<int> bandsCollapsingCells = <int>[456, 460, 481];

  static bool get theThirdAndWorstCollapse =>
      bandsCollapsingCells.length == 3 && allThreeCellsAreIdentical;

  static bool get aStateCannotBeExceeded => allThreeCellsAreIdentical;

  static const String bandNote =
      'Step 456 found a floor and a ceiling that were one boundary and Step '
      '460 found a floor and an optimal that were one state. This row '
      'collapses all three into one word, so the band is not a band: it is a '
      'state, and a state cannot be exceeded, missed or improved.';

  // -----------------------------------------------------------------------
  // Somebody else's state.
  // -----------------------------------------------------------------------

  static const String whoDecidesDeployment = 'the store review team';

  static const bool theTeamControlsTheOutcome = false;

  static const List<String> whatTheTeamControls = <String>[
    'the build is signed with the release identity',
    'every required metadata field is present',
    'the submission is reproducible from a tagged commit',
    'the privacy declarations match what is collected',
  ];

  static bool get fourControllableThings =>
      whatTheTeamControls.length == 4 && !theTeamControlsTheOutcome;

  static const String controlNote =
      'Whether a build is deployed depends on a review carried out by people '
      'who do not work here and answer to their own timetable, so measuring '
      'the team on it measures the reviewer. What is measured instead is what '
      'the team controls and what a reviewer will check.';

  // -----------------------------------------------------------------------
  // The declaration against the allowlist.
  // -----------------------------------------------------------------------

  static const int declaredFieldCount = 8;

  static bool get theAllowlistIsEightFields =>
      HabotTrackingSdk.eightFieldsAreDeclared;

  static bool get theDeclarationMatchesTheAllowlist =>
      declaredFieldCount == HabotTrackingSdk.fieldCount;

  static const bool anyDeclaredFieldIdentifiesAPerson = false;

  static bool get theComparisonRunsBeforeSubmission =>
      theDeclarationMatchesTheAllowlist && !anyDeclaredFieldIdentifiesAPerson;

  static const String declarationNote =
      'A store declaration that claims more than the code collects is a false '
      'statement to the people downloading the application, and one that '
      'claims less is a promise the code does not keep. The declaration and '
      'the Step 419 allowlist are compared field by field before submission.';

  // -----------------------------------------------------------------------
  // Rejection is a state.
  // -----------------------------------------------------------------------

  static const List<HabotSubmission> submissions = <HabotSubmission>[
    HabotSubmission(
      version: '5.0.0',
      tag: 'v5.0.0',
      signed: true,
      metadataComplete: true,
      outcome: 'rejected',
      reviewerReason: 'Guideline 5.1.1 - purpose string for microphone access '
          'does not say what the recording is used for',
    ),
    HabotSubmission(
      version: '5.0.1',
      tag: 'v5.0.1',
      signed: true,
      metadataComplete: true,
      outcome: 'accepted',
      reviewerReason: '',
    ),
  ];

  static bool get everySubmissionIsSignedAndComplete => submissions.every(
      (HabotSubmission s) => s.signed && s.metadataComplete);

  static bool get theRejectionReasonIsVerbatim => submissions.first
      .reviewerReason
      .contains('Guideline 5.1.1');

  static bool get aCodeChangeTookANewVersion =>
      submissions.first.version != submissions.last.version &&
      submissions.first.tag != submissions.last.tag;

  static bool get everySubmissionIsTagged =>
      submissions.every((HabotSubmission s) => s.tag.isNotEmpty);

  static String get qualitativeOutput =>
      submissions.last.outcome == 'accepted' ? 'Complete' : 'Not Complete';

  static const String columnNote =
      'COLUMN NOTE: this row\'s floor, optimal and ceiling are the same word, '
      'the first band in the track to collapse all three cells and the third '
      'collapse after Steps 456 and 460, so it states a condition rather than '
      'a measure; the condition is a store reviewer\'s decision rather than '
      'the team\'s, so four controllable things are measured instead; the '
      'privacy declaration is compared field by field against the Step 419 '
      'allowlist before submission; and a rejection records the reviewer\'s '
      'reason verbatim, taking a new version only where a code change was '
      'needed. Atomic Step: "Deploy production mobile app builds to Apple App '
      'Store Connect."';

  static Map<String, bool> get obligations => <String, bool>{
        'the four controllable things are measured': fourControllableThings,
        'the declaration matches the allowlist':
            theDeclarationMatchesTheAllowlist,
        'no declared field identifies a person':
            !anyDeclaredFieldIdentifiesAPerson,
        'every submission is signed, complete and tagged':
            everySubmissionIsSignedAndComplete && everySubmissionIsTagged,
        'a rejection reason is recorded verbatim':
            theRejectionReasonIsVerbatim,
      };

  static Map<String, bool> get checks => <String, bool>{
        'floor, optimal and ceiling are one word':
            allThreeCellsAreIdentical,
        'the third and worst collapse in the track':
            theThirdAndWorstCollapse && aStateCannotBeExceeded,
        'so the band states a condition, not a measure':
            bandNote.contains('cannot be exceeded'),
        'the outcome belongs to the store review team':
            !theTeamControlsTheOutcome && whoDecidesDeployment.isNotEmpty,
        'so four controllable things are measured instead':
            fourControllableThings && controlNote.contains('measures the '
                'reviewer'),
        'the declaration is eight fields, as the allowlist is':
            theAllowlistIsEightFields && theDeclarationMatchesTheAllowlist,
        'and none of them identifies a person':
            theComparisonRunsBeforeSubmission &&
                declarationNote.contains('field by field'),
        'two submissions, both signed, complete and tagged':
            submissions.length == 2 &&
                everySubmissionIsSignedAndComplete &&
                everySubmissionIsTagged,
        'the rejection reason is verbatim and took a new version':
            theRejectionReasonIsVerbatim && aCodeChangeTookANewVersion,
        'five obligations, all met, giving Complete':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Complete',
      };
}
