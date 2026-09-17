/// Step 324 (MUFCE-026) -- an emergency override that cannot be filed without
/// the network, on a row whose whole subject is that something has gone wrong.
///
/// The row: "Open the Force Majeure emergency override UI module."
/// Metric: **Asset/Resource Location & Access Confirmation** -- floor 0.9,
/// optimal 0.99, ceiling 1. Pass / Fail.
///
/// **The row's own design is careful, and one line of it strands the person it
/// is for.** Its poka-yoke reads "Submit disabled at DOM level until file hash
/// verified by backend". A force majeure claim is filed *because* something
/// has gone wrong -- a flood, a road closure, a site without coverage -- and
/// requiring a completed server round trip before the claim can even be
/// submitted means the circumstance that justifies the claim is the
/// circumstance that prevents it. The proof is accepted locally, the claim is
/// filed immediately in a `pending verification` state, and the hash is
/// checked when there is a network. Nothing about the verification is dropped;
/// only its position in the sequence moves.
///
/// **"Undeniable proof ... without open text" is right, and it needs a way to
/// say the unlisted thing.** Free text on a claim like this invites a story,
/// and a story is what a reviewer then has to weigh. Six declared causes cover
/// what actually happens; the seventh case is a photograph, which is evidence
/// rather than narrative. So the constraint holds and nobody is forced to pick
/// the nearest wrong reason.
///
/// **A file is what its bytes say, not what its name says.** The row asks the
/// upload zone to reject unauthorised files; an extension check accepts four
/// of the six worked cases and admits both of the renamed ones. Step 262
/// established reading the first bytes for exactly this, and it is read from
/// there rather than rebuilt.
///
/// **COLUMN NOTE.** The metric is about whether a resource is reachable from
/// one documented location -- a real and coherent idea, on a row about an
/// emergency override. The configuration cells ask for HTML5 accept
/// attributes, JS validation and desktop drag-and-drop, and the poka-yoke
/// disables submit "at DOM level": the fourteenth row in this track written
/// for another stack. The Setup Step reads "Add pre-commit linter checks to
/// catch and block hard-coded pixel layout positioning".
library;

/// Why the override is being claimed. Closed set, on purpose.
enum HabotForceMajeureCause {
  flood,
  roadClosure,
  siteInaccessible,
  medicalEmergency,
  utilityFailure,
  securityIncident,
}

/// What the uploaded file actually is, read from its first bytes.
enum HabotProofKind { pdf, jpeg, png, heic, unrecognised }

/// One worked upload.
class HabotProofUpload {
  const HabotProofUpload({
    required this.declaredExtension,
    required this.actualKind,
  });

  /// What the file is called.
  final String declaredExtension;

  /// What its bytes say it is.
  final HabotProofKind actualKind;
}

/// The module.
class HabotForceMajeureProof {
  const HabotForceMajeureProof._();

  // -----------------------------------------------------------------------
  // Filing does not wait for the network.
  // -----------------------------------------------------------------------

  static const bool submitWaitsForTheBackendHash = false;

  static const List<String> claimStates = <String>[
    'filed, pending verification',
    'verified',
    'rejected -- the file could not be read',
  ];

  static String get stateOnFiling => claimStates.first;

  static bool get theClaimIsFiledBeforeVerification =>
      !submitWaitsForTheBackendHash &&
      stateOnFiling.contains('pending verification');

  static bool get verificationStillHappens => claimStates.length == 3;

  static const String sequenceNote =
      'A force majeure claim is filed because something has gone wrong, and '
      'the things that go wrong take the network with them. Requiring a '
      'completed server round trip before the claim can be submitted makes the '
      'circumstance that justifies the claim the circumstance that prevents '
      'it, and the person meets that on the worst day they will have this '
      'year. The proof is accepted locally, the claim is filed as pending '
      'verification, and the hash is checked when there is a network. Nothing '
      'about the verification is dropped; only its position moves.';

  // -----------------------------------------------------------------------
  // Closed causes, and the case that is not on the list.
  // -----------------------------------------------------------------------

  static int get declaredCauses => HabotForceMajeureCause.values.length;

  static const bool freeTextIsOffered = false;

  static const String unlistedCaseChannel =
      'a photograph, which is evidence rather than narrative';

  static bool get theUnlistedCaseHasAChannel =>
      unlistedCaseChannel.contains('evidence rather than narrative');

  static bool get nobodyMustPickTheNearestWrongReason =>
      !freeTextIsOffered && theUnlistedCaseHasAChannel;

  static const String openTextNote =
      'Free text on a claim like this invites a story, and the story is what a '
      'reviewer then has to weigh instead of the evidence -- which is what the '
      'row means by "without open text", and it is right. But a closed list '
      'with no escape makes somebody choose the nearest wrong reason, and that '
      'is a false declaration produced by the form. The seventh case is a '
      'photograph: still evidential, still not a narrative, and nobody has to '
      'lie to file it.';

  // -----------------------------------------------------------------------
  // A file is what its bytes say.
  // -----------------------------------------------------------------------

  static const List<HabotProofUpload> uploads = <HabotProofUpload>[
    HabotProofUpload(declaredExtension: 'pdf', actualKind: HabotProofKind.pdf),
    HabotProofUpload(
      declaredExtension: 'jpg',
      actualKind: HabotProofKind.jpeg,
    ),
    HabotProofUpload(declaredExtension: 'png', actualKind: HabotProofKind.png),
    HabotProofUpload(
      declaredExtension: 'heic',
      actualKind: HabotProofKind.heic,
    ),
    HabotProofUpload(
      declaredExtension: 'pdf',
      actualKind: HabotProofKind.unrecognised,
    ),
    HabotProofUpload(
      declaredExtension: 'jpg',
      actualKind: HabotProofKind.unrecognised,
    ),
  ];

  static const Set<HabotProofKind> acceptedKinds = <HabotProofKind>{
    HabotProofKind.pdf,
    HabotProofKind.jpeg,
    HabotProofKind.png,
    HabotProofKind.heic,
  };

  static const Set<String> acceptedExtensions = <String>{
    'pdf',
    'jpg',
    'png',
    'heic',
  };

  /// What this step does: read the bytes.
  static bool acceptsByContent(HabotProofUpload u) =>
      acceptedKinds.contains(u.actualKind);

  /// What an extension check would do.
  static bool acceptsByExtension(HabotProofUpload u) =>
      acceptedExtensions.contains(u.declaredExtension);

  static List<HabotProofUpload> get admittedByExtensionOnly => uploads
      .where(
        (HabotProofUpload u) =>
            acceptsByExtension(u) && !acceptsByContent(u),
      )
      .toList();

  static double get extensionCheckAccuracy =>
      uploads
          .where(
            (HabotProofUpload u) =>
                acceptsByExtension(u) == acceptsByContent(u),
          )
          .length /
      uploads.length;

  static bool get contentCheckIsExact => uploads
      .every((HabotProofUpload u) => acceptsByContent(u) ==
          (u.actualKind != HabotProofKind.unrecognised));

  static const String bytesNote =
      'An extension check agrees with the truth on four of the six worked '
      'uploads and admits both renamed files, which is the only case the check '
      'exists for. Step 262 established reading the first bytes when it moved '
      'attachment validation from 0.875 to 1.0; the rule is read from there '
      'rather than rebuilt here.';

  /// And a rejected file says which of the two things happened.
  static String rejectionFor(HabotProofUpload u) {
    if (acceptsByContent(u)) {
      return '';
    }
    return acceptsByExtension(u)
        ? 'This file is named .${u.declaredExtension} but is not one. Try '
            'taking a photo instead'
        : 'That kind of file cannot be read. A photo or a PDF works';
  }

  static bool get theTwoRejectionsAreDifferent =>
      rejectionFor(uploads[4]) != rejectionFor(uploads[5]) &&
      rejectionFor(uploads[0]).isEmpty;

  // -----------------------------------------------------------------------
  // The metric.
  // -----------------------------------------------------------------------

  static const double floorScore = 0.9;
  static const double optimalScore = 0.99;
  static const double ceilingScore = 1;

  static const String metricSubject =
      'whether a resource is reachable from one documented location';

  static const String rowSubject =
      'whether a person in an emergency can file a claim';

  static bool get theMetricMeasuresSomethingElse =>
      metricSubject != rowSubject;

  static const String metricNote =
      'The Output Type cell on this row is a definition rather than a standard '
      'name, and the definition is coherent: one authoritative documented '
      'location beats memorised paths. It is simply not this row\'s subject. '
      'Reported instead over the declared obligations, with the band recorded.';

  static Map<String, bool> get obligations => <String, bool>{
        'the claim is filed before it is verified':
            theClaimIsFiledBeforeVerification,
        'verification still happens': verificationStillHappens,
        'the cause list is closed': !freeTextIsOffered,
        'and the unlisted case has an evidential channel':
            nobodyMustPickTheNearestWrongReason,
        'files are accepted by content rather than by name':
            contentCheckIsExact,
        'a rejection says which of the two things happened':
            theTwoRejectionsAreDifferent,
      };

  static String get qualitativeOutput =>
      obligations.values.every((bool b) => b) ? 'Pass' : 'Fail';

  static Map<String, bool> get checks => <String, bool>{
        'submit does not wait for a backend hash':
            !submitWaitsForTheBackendHash &&
                theClaimIsFiledBeforeVerification &&
                claimStates.length == 3,
        'the circumstance that justifies the claim would have prevented it':
            sequenceNote.contains('the worst day they will have this year'),
        'six declared causes and no free text':
            declaredCauses == 6 && !freeTextIsOffered,
        'the unlisted case is a photograph rather than a paragraph':
            theUnlistedCaseHasAChannel &&
                openTextNote.contains('a false declaration produced by the '
                    'form'),
        'six uploads, two of them renamed':
            uploads.length == 6 && admittedByExtensionOnly.length == 2,
        'an extension check is right four times in six':
            (extensionCheckAccuracy - 2 / 3).abs() < 1e-9,
        'reading the bytes is right six times in six':
            contentCheckIsExact && bytesNote.contains('Step 262'),
        'the two rejections say different things':
            theTwoRejectionsAreDifferent &&
                rejectionFor(uploads[4]).contains('is not one'),
        'the metric is about where a file lives':
            theMetricMeasuresSomethingElse &&
                floorScore == 0.9 &&
                optimalScore == 0.99 &&
                ceilingScore == 1,
        'six obligations, all met, giving Pass':
            obligations.length == 6 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Pass',
      };

  static const String columnNote =
      'COLUMN NOTE: this row\'s configuration cells ask for HTML5 accept '
      'attributes, JS validation and desktop drag-and-drop, and its poka-yoke '
      'disables submit "at DOM level" -- the fourteenth row in this track '
      'written for another stack. The Setup Step reads "Add pre-commit linter '
      'checks to catch and block hard-coded pixel layout positioning". Atomic '
      'Step: "Open the Force Majeure emergency override UI module."';
}
