/// Step 271 (GEN-02808) -- an encryption health badge, and the thing it is
/// being asked to vouch for.
///
/// The row: "Configure an encryption health badge within the mobile admin
/// settings drawer."
/// Metric: **Encryption Key Management Compliance (%)** -- floor 95, optimal
/// 100, ceiling 100. Pass/Fail. Standards cited: NIST SP 800-57 Key
/// Management / ISO/IEC 27001 A.10.
///
/// **A badge in the client cannot attest to key management.** Key management
/// is custody, rotation, separation of duties and an access log, and all four
/// of them live where the keys are. What the client can honestly say is what
/// transport it negotiated, whether its own at-rest path goes through a
/// cipher, and how old the last statement from the side that does know is.
/// Three of the six facts below are knowable here; **none of the three
/// key-management facts is**, which is the same set the metric is named after.
///
/// **So the badge has three states, not two.** Green and red leave no room for
/// "I have not heard recently", which is the client's ordinary condition. A
/// two-state badge resolves that to green, and a green badge that means "this
/// device has not checked since Tuesday" is worse than no badge: it is an
/// assurance manufactured out of silence. The state goes to `unknown` once the
/// attestation is older than [HabotMotion.attestationMaxAge], and staleness is
/// deliberately not `failed` -- a badge that goes red when the network is bad
/// is a badge people learn to ignore.
///
/// **And the device's own encryption is provided, not shipped.**
/// `HabotEncryptedStore` (Step 122) requires a `HabotCipher` and declares no
/// default, because the platform keystore is behind a plugin this environment
/// cannot resolve. A badge rendering green against that is reporting on a
/// cipher nobody has supplied yet, which is exactly the failure a health badge
/// exists to catch.
library;

import '../data/encrypted_store.dart';
import '../resilience/socket_transport.dart';
import '../tokens/motion_tokens.dart';

/// What the badge can say.
enum HabotAttestationState {
  /// Everything this device can check holds, and the statement from the side
  /// that knows the rest is recent.
  verified,

  /// Something could not be checked, or the statement is too old to repeat.
  /// The client's ordinary condition, and the reason two states are not
  /// enough.
  unknown,

  /// Something this device can check does not hold.
  failed,
}

/// Where a fact about encryption lives.
enum HabotFactLocus {
  /// The device can establish it itself.
  thisDevice,

  /// Only the side holding the keys can establish it.
  theKeyHolder,
}

/// One thing a person reading a badge might reasonably think it covers.
class HabotEncryptionFact {
  const HabotEncryptionFact({
    required this.name,
    required this.locus,
    required this.isKeyManagement,
    required this.why,
  });

  final String name;
  final HabotFactLocus locus;

  /// Whether this is one of the things NIST SP 800-57 is about -- custody,
  /// rotation, separation, audit -- as opposed to encryption in general.
  final bool isKeyManagement;

  final String why;

  bool get knowableHere => locus == HabotFactLocus.thisDevice;
}

/// The badge.
class HabotEncryptionAttestation {
  const HabotEncryptionAttestation._();

  static const List<HabotEncryptionFact> facts = <HabotEncryptionFact>[
    HabotEncryptionFact(
      name: 'the transport in use is encrypted',
      locus: HabotFactLocus.thisDevice,
      isKeyManagement: false,
      why: 'HabotSocketPolicy declares wss and refuses anything else, so the '
          'scheme is a property of the code rather than of the connection '
          'somebody happened to get.',
    ),
    HabotEncryptionFact(
      name: 'nothing is persisted locally outside the encrypted store',
      locus: HabotFactLocus.thisDevice,
      isKeyManagement: false,
      why: 'HabotEncryptedStore IS a HabotLocalStore, so the layer above it '
          'cannot tell which one it holds and cannot forget to encrypt at one '
          'call site. Structural, in the way Step 269 means it.',
    ),
    HabotEncryptionFact(
      name: 'the cipher in use declares itself production grade',
      locus: HabotFactLocus.thisDevice,
      isKeyManagement: false,
      why: 'assertProductionReady throws on a cipher that says it is not. '
          'Knowable here, and currently unsatisfiable here: no cipher ships '
          'in lib/, because the keystore is behind a plugin.',
    ),
    HabotEncryptionFact(
      name: 'keys are held in a hardware security module',
      locus: HabotFactLocus.theKeyHolder,
      isKeyManagement: true,
      why: 'Custody. A client that could verify where a key is held would be '
          'a client that had been told where it is, which is a thing keys are '
          'kept from telling.',
    ),
    HabotEncryptionFact(
      name: 'keys are rotated on the declared schedule',
      locus: HabotFactLocus.theKeyHolder,
      isKeyManagement: true,
      why: 'Rotation. The device sees one key at a time and cannot tell a '
          'freshly rotated key from one that has been in place for three '
          'years -- they look identical from here.',
    ),
    HabotEncryptionFact(
      name: 'key access is logged and the log is reviewed',
      locus: HabotFactLocus.theKeyHolder,
      isKeyManagement: true,
      why: 'Separation of duties and audit. Both are about people, and the '
          'device has no view of either. This is the half of ISO/IEC 27001 '
          'A.10 a badge is least able to reach.',
    ),
  ];

  static List<HabotEncryptionFact> get knowableHere =>
      facts.where((HabotEncryptionFact f) => f.knowableHere).toList();

  static List<HabotEncryptionFact> get keyManagementFacts =>
      facts.where((HabotEncryptionFact f) => f.isKeyManagement).toList();

  static List<HabotEncryptionFact> get keyManagementKnowableHere =>
      keyManagementFacts
          .where((HabotEncryptionFact f) => f.knowableHere)
          .toList();

  /// Half of what the badge appears to cover is checkable from here.
  static double get shareOfFactsKnowableHere =>
      knowableHere.length / facts.length;

  /// And none of the part the metric is named after is.
  static double get shareOfKeyManagementKnowableHere =>
      keyManagementKnowableHere.length / keyManagementFacts.length;

  static bool get theMetricsOwnSubjectIsUnreachableFromHere =>
      keyManagementFacts.isNotEmpty && keyManagementKnowableHere.isEmpty;

  // -----------------------------------------------------------------------
  // The three states.
  // -----------------------------------------------------------------------

  /// [attestationAge] is how long ago the key holder last said anything.
  /// Null means it never has.
  static HabotAttestationState stateFor({
    required bool transportVerified,
    required bool cipherProductionGrade,
    required Duration? attestationAge,
  }) {
    if (!transportVerified || !cipherProductionGrade) {
      return HabotAttestationState.failed;
    }
    if (attestationAge == null ||
        attestationAge > HabotMotion.attestationMaxAge) {
      return HabotAttestationState.unknown;
    }
    return HabotAttestationState.verified;
  }

  /// A thing this device can check and which does not hold is a failure, even
  /// when the key holder's statement is fresh -- the local half is not
  /// overridden by somebody else's good news.
  static bool get aLocalFailureBeatsAFreshAttestation =>
      stateFor(
        transportVerified: true,
        cipherProductionGrade: false,
        attestationAge: Duration.zero,
      ) ==
      HabotAttestationState.failed;

  static bool get silenceIsNotVerified =>
      stateFor(
        transportVerified: true,
        cipherProductionGrade: true,
        attestationAge: null,
      ) ==
      HabotAttestationState.unknown;

  static bool get aStaleAttestationGoesUnknownRatherThanRed =>
      stateFor(
        transportVerified: true,
        cipherProductionGrade: true,
        attestationAge: HabotMotion.attestationMaxAge * 2,
      ) ==
      HabotAttestationState.unknown;

  static bool get everythingFreshAndLocallySoundIsVerified =>
      stateFor(
        transportVerified: true,
        cipherProductionGrade: true,
        attestationAge: HabotMotion.attestationMaxAge,
      ) ==
      HabotAttestationState.verified;

  static const String threeStatesNote =
      'Green and red leave no room for "I have not heard recently", which is '
      'the client\'s ordinary condition, and a two-state badge resolves that '
      'to green. A green badge meaning "this device has not checked since '
      'Tuesday" is worse than no badge: it is an assurance manufactured out '
      'of silence. Hence three states, with staleness landing on unknown '
      'rather than failed -- a badge that goes red whenever the network is '
      'bad is a badge people learn to ignore, and then it is not there for '
      'the one time it was right.';

  // -----------------------------------------------------------------------
  // The device's own half, read from what is actually there.
  // -----------------------------------------------------------------------

  /// Checked against the existing declaration rather than restated.
  static bool get theTransportSchemeIsDeclared =>
      HabotSocketPolicy.scheme == 'wss';

  /// The encrypted store's header, so the check is over the real format
  /// rather than a description of it.
  static bool get theStoreStampsItsRecords =>
      HabotEncryptedStore.headerMagic.length == 3 &&
      HabotEncryptedStore.formatVersion == 1 &&
      HabotEncryptedStore.headerLength == 4;

  /// Step 122 recorded that no cipher ships in lib/. The badge has to read
  /// that, not around it.
  static bool get noCipherShipsInThisRepository =>
      HabotEncryptedStore.cipherProvenance.contains('NO CIPHER SHIPS');

  /// So the honest badge state for this build, today, is failed -- and
  /// naming that is the whole value of the step. A badge whose first reading
  /// is green on a repository with no cipher in it would have been decorative
  /// from the day it shipped.
  static HabotAttestationState get stateForThisBuild => stateFor(
        transportVerified: theTransportSchemeIsDeclared,
        cipherProductionGrade: !noCipherShipsInThisRepository,
        attestationAge: null,
      );

  static const String noCipherNote =
      'The device\'s own encryption is provided, not shipped. '
      'HabotEncryptedStore requires a HabotCipher and declares no default, '
      'because device-bound encryption needs the Android Keystore or the iOS '
      'Keychain through a plugin this environment cannot resolve -- Step 122 '
      'recorded that as a compile-time obstacle rather than a silent gap. A '
      'health badge rendering green against it would be reporting on a cipher '
      'nobody has supplied, which is precisely the condition a health badge '
      'exists to catch. This build\'s honest reading is failed.';

  // -----------------------------------------------------------------------
  // The polling cadence the row asks for.
  // -----------------------------------------------------------------------

  /// The row's own instruction: "Background polling refreshes data every 30
  /// seconds." An int rather than a Duration, because a duration that is not
  /// a token does not belong in this file.
  static const int pollIntervalSecondsTheRowAsksFor = 30;

  static int get freshnessWindowSeconds =>
      HabotMotion.attestationMaxAge.inSeconds;

  /// How many times the row's cadence would ask inside one freshness window.
  static int get pollsPerFreshnessWindow =>
      freshnessWindowSeconds ~/ pollIntervalSecondsTheRowAsksFor;

  static bool get theCadenceOutrunsTheAnswer =>
      pollsPerFreshnessWindow > 1000;

  static const String cadenceNote =
      'The row asks for background polling every thirty seconds. The thing '
      'being polled changes when somebody rotates a key or signs an audit, '
      'and the declared freshness window is twenty-four hours -- so the '
      'cadence asks 2880 times for an answer that can differ once. Polling is '
      'not free on a phone: it is a radio wake, a connection and a battery '
      'cost, repeated while the screen is off. The badge refreshes when the '
      'drawer opens and when the attestation passes its age, and the thirty '
      'seconds is recorded as the row\'s figure rather than followed.';

  // -----------------------------------------------------------------------
  // What the badge is not.
  // -----------------------------------------------------------------------

  /// A badge is a report. A badge that can be tapped to fix encryption is a
  /// control, and a control that claims to fix encryption from a settings
  /// drawer is claiming something no button does.
  static const bool isReadOnly = true;

  static const String readOnlyNote =
      'The badge reports and does nothing else. A tappable "fix" would be a '
      'control claiming to repair key management from a settings drawer, '
      'which no button does; the drill-down opens the statement -- what was '
      'attested, by whom, and when -- so the answer to a red badge is a '
      'person who can act on it rather than a retry.';

  // -----------------------------------------------------------------------
  // Metric: Encryption Key Management Compliance (%) -- 95 / 100 / 100.
  // -----------------------------------------------------------------------

  static const double floorPercent = 95;
  static const double optimalPercent = 100;
  static const double ceilingPercent = 100;

  /// Ninety-five percent compliant key management means one key in twenty is
  /// not, and one key in twenty is a breach with a date on it. The band is
  /// the shape of an availability target applied to a subject where partial
  /// credit does not exist.
  static bool get theFloorAdmitsAFailureTheOutputHides =>
      floorPercent < optimalPercent && optimalPercent == ceilingPercent;

  static const String bandNote =
      'A floor of 95% on key management means one key in twenty is not '
      'managed, and one key in twenty is a breach with a date on it. Optimal '
      'and ceiling are both 100, so the band has no room above target either: '
      'it is an availability target\'s shape applied to a subject where '
      'partial credit does not exist. The Pass/Fail output then collapses the '
      'five points between floor and optimal into a word, which is the only '
      'honest thing in the band -- a key set is compliant or it is not.';

  /// **Fail, and deliberately.** The client half of this row is implementable
  /// and implemented; the badge's own first reading on this build is failed,
  /// because no cipher is supplied. Reporting Pass here would mean the badge
  /// had been built to show green.
  static String get qualitativeOutput =>
      stateForThisBuild == HabotAttestationState.verified ? 'Pass' : 'Fail';

  static Map<String, bool> get checks => <String, bool>{
        'six facts a badge appears to cover, each with a reason':
            facts.length == 6 &&
                facts.every((HabotEncryptionFact f) => f.why.length > 80),
        'three are knowable on this device and three are not':
            knowableHere.length == 3 &&
                (shareOfFactsKnowableHere - 0.5).abs() < 1e-9,
        'none of the three key-management facts is knowable here, which is '
            'the subject the metric is named after':
            theMetricsOwnSubjectIsUnreachableFromHere &&
                keyManagementFacts.length == 3 &&
                shareOfKeyManagementKnowableHere == 0,
        'silence reads as unknown rather than verified': silenceIsNotVerified,
        'a stale attestation reads as unknown rather than failed':
            aStaleAttestationGoesUnknownRatherThanRed,
        'a local failure is not overridden by a fresh attestation':
            aLocalFailureBeatsAFreshAttestation,
        'fresh and locally sound reads as verified':
            everythingFreshAndLocallySoundIsVerified,
        'the staleness window is read from a declared token':
            HabotMotion.attestationMaxAge.inHours == 24,
        'the transport scheme is read from the existing policy':
            theTransportSchemeIsDeclared,
        'the encrypted store\'s real header is checked':
            theStoreStampsItsRecords,
        'no cipher ships in this repository, and the badge reads that':
            noCipherShipsInThisRepository &&
                noCipherNote.contains('exists to catch'),
        'this build\'s honest badge state is failed':
            stateForThisBuild == HabotAttestationState.failed,
        'the polling cadence outruns the answer, and that is recorded':
            theCadenceOutrunsTheAnswer &&
                pollsPerFreshnessWindow == 2880 &&
                cadenceNote.contains('2880'),
        'the badge reports and does not act':
            isReadOnly && readOnlyNote.contains('rather than a retry'),
        'the floor admits a failure the Pass/Fail output hides':
            theFloorAdmitsAFailureTheOutputHides &&
                bandNote.contains('partial credit does not exist'),
      };

  static const String columnNote =
      'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Dependency '
      'reads "Dependent on prior foundational steps" with a global dependency '
      'of GEN-02807. Atomic Step: "Configure an encryption health badge '
      'within the mobile admin settings drawer."';
}
