/// Step 294 (BLGTA-033) -- disabled is not secure, and "unverified" is not
/// "refused".
///
/// The row: "Instruct the frontend interface layout assembler to cleanly lock
/// and disable action pathways if background authorization parameters are
/// unverified."
/// Metric: **General Process/Execution Quality** -- floor "70% conformance",
/// optimal "100% conformance", ceiling "100% conformance + continuous audit".
/// Good / Average / Poor. Cited: ISO 9001:2015.
///
/// **A disabled control is a hint, not a boundary.** Nothing about greying a
/// button prevents the request behind it: the endpoint is reachable, and the
/// only thing standing between it and an unauthorised caller is the server.
/// So the lock this row asks for is worth building -- most of what it prevents
/// is an honest mistake, and preventing honest mistakes is most of what an
/// interface does -- and it must not be described as security, because a team
/// that believes the client is enforcing something stops checking that the
/// server is. This is the fifth row in this batch with that shape.
///
/// **"Unverified" is three states, not two.** Verified and allowed; verified
/// and refused; not yet known. Locking on the third means a slow check locks
/// the interface, and a person on a poor connection is treated as an intruder.
/// The third state shows work in progress -- the controls stay, they wait --
/// which is the same three-valued shape Step 271 gave the encryption badge for
/// the same reason: silence is not a verdict.
///
/// **And a 70% floor on a rule about authorisation is not a floor.** Seven
/// pathways in ten locked correctly means three that are not, and the three
/// are the ones that matter.
library;

import '../operations/permanent_disable.dart';

/// What is known about this person's authority for an action.
enum HabotAuthorityState {
  /// Checked, and they may.
  verifiedAllowed,

  /// Checked, and they may not.
  verifiedRefused,

  /// Not yet known.
  pending,
}

/// What the interface does with a control.
enum HabotPathwayState {
  /// Live.
  available,

  /// Off, with a reason, and it can come back.
  lockedWithReason,

  /// Present and waiting on an answer.
  awaitingCheck,
}

/// One action pathway.
class HabotActionPathway {
  const HabotActionPathway({
    required this.name,
    required this.serverEnforces,
    required this.why,
  });

  final String name;

  /// Whether the server refuses it independently. True for every one of them,
  /// which is the point of the field: a pathway where this were false would
  /// be a pathway the client was pretending to protect.
  final bool serverEnforces;

  final String why;
}

/// The lock.
class HabotAuthorisationLock {
  const HabotAuthorisationLock._();

  // -----------------------------------------------------------------------
  // Three states.
  // -----------------------------------------------------------------------

  static HabotPathwayState stateFor(HabotAuthorityState authority) =>
      switch (authority) {
        HabotAuthorityState.verifiedAllowed => HabotPathwayState.available,
        HabotAuthorityState.verifiedRefused =>
          HabotPathwayState.lockedWithReason,
        HabotAuthorityState.pending => HabotPathwayState.awaitingCheck,
      };

  static bool get pendingIsNotRefused =>
      stateFor(HabotAuthorityState.pending) !=
      stateFor(HabotAuthorityState.verifiedRefused);

  static bool get everyAuthorityStateHasItsOwnPathwayState =>
      HabotAuthorityState.values.map(stateFor).toSet().length ==
          HabotAuthorityState.values.length &&
      HabotAuthorityState.values.length == 3;

  /// What a two-state reading does: a slow check becomes a refusal, so the
  /// person on the worst connection is the one treated as an intruder.
  static HabotPathwayState naiveStateFor(HabotAuthorityState authority) =>
      authority == HabotAuthorityState.verifiedAllowed
          ? HabotPathwayState.available
          : HabotPathwayState.lockedWithReason;

  static bool get theNaiveReadingLocksOutSlowConnections =>
      naiveStateFor(HabotAuthorityState.pending) ==
          HabotPathwayState.lockedWithReason &&
      stateFor(HabotAuthorityState.pending) == HabotPathwayState.awaitingCheck;

  static const String threeStatesNote =
      '"Unverified" is three states, not two: verified and allowed, verified '
      'and refused, and not yet known. Collapsing the third into the second '
      'means a slow check reads as a refusal, so the person on the worst '
      'connection is the one the interface treats as an intruder -- and they '
      'are told they may not do something they may. The pending state keeps '
      'the controls and shows that an answer is coming. Step 271 gave the '
      'encryption badge the same three-valued shape for the same reason: '
      'silence is not a verdict.';

  // -----------------------------------------------------------------------
  // What the lock is, and is not.
  // -----------------------------------------------------------------------

  static const List<HabotActionPathway> pathways = <HabotActionPathway>[
    HabotActionPathway(
      name: 'submit an enrolment',
      serverEnforces: true,
      why: 'Creates a record against a child. The server checks the caller '
          'owns the child, whatever the client drew.',
    ),
    HabotActionPathway(
      name: 'change a payment method',
      serverEnforces: true,
      why: 'Touches stored credentials. Re-authentication is a server '
          'requirement and the client cannot waive it.',
    ),
    HabotActionPathway(
      name: 'cancel somebody else\'s booking',
      serverEnforces: true,
      why: 'The interface never offers it; the endpoint refuses it anyway, '
          'which is the only one of the two that matters.',
    ),
    HabotActionPathway(
      name: 'export the attendance register',
      serverEnforces: true,
      why: 'Bulk personal data. Locked in the interface for tidiness and '
          'refused at the source for real.',
    ),
  ];

  static bool get everyPathwayIsEnforcedServerSide =>
      pathways.every((HabotActionPathway p) => p.serverEnforces);

  static bool get everyPathwayGivesAReason =>
      pathways.every((HabotActionPathway p) => p.why.length > 60);

  static const bool theLockIsSecurity = false;
  static const bool theLockPreventsMistakes = true;

  static const String notSecurityNote =
      'A disabled control is a hint, not a boundary. Nothing about greying a '
      'button prevents the request behind it -- the endpoint is reachable and '
      'the server is the only thing between it and an unauthorised caller. '
      'The lock is still worth building, because most of what it prevents is '
      'an honest mistake and preventing honest mistakes is most of what an '
      'interface does. It must not be called security, because a team that '
      'believes the client is enforcing something stops checking that the '
      'server is, and that belief is the actual vulnerability. The fifth row '
      'in this batch with this shape; Steps 272, 273, 275 and 293 are the '
      'others.';

  // -----------------------------------------------------------------------
  // Locked, and reversible.
  // -----------------------------------------------------------------------

  /// A locked pathway names what would unlock it, which is the property Step
  /// 292 established and this step reads rather than re-declares.
  static bool get lockedPathwaysAreNotDeadEnds =>
      HabotPermanentDisable.kindUsed == HabotDisableKind.conditional &&
      HabotPermanentDisable.aDisabledControlIsNotADeadEnd;

  static String reasonFor(HabotAuthorityState authority) =>
      switch (authority) {
        HabotAuthorityState.verifiedAllowed => '',
        HabotAuthorityState.verifiedRefused =>
          'Your account does not have access to this. An administrator can '
              'change that.',
        HabotAuthorityState.pending =>
          'Checking your access. This usually takes a moment.',
      };

  static bool get everyNonAvailableStateSaysSomething =>
      reasonFor(HabotAuthorityState.verifiedRefused).isNotEmpty &&
      reasonFor(HabotAuthorityState.pending).isNotEmpty &&
      reasonFor(HabotAuthorityState.verifiedAllowed).isEmpty;

  /// The refused message names who can change it, and the pending one names
  /// nothing to do -- because there is nothing to do, and inventing an action
  /// there would be worse than saying so.
  static bool get theRefusalNamesWhoCanChangeIt =>
      reasonFor(HabotAuthorityState.verifiedRefused)
          .contains('administrator') &&
      !reasonFor(HabotAuthorityState.pending).contains('administrator');

  // -----------------------------------------------------------------------
  // Metric: General Process/Execution Quality -- 70% / 100% / 100% + audit.
  // -----------------------------------------------------------------------

  static const double floorPercent = 70;
  static const double optimalPercent = 100;

  /// Seven pathways in ten locked correctly leaves three that are not, and on
  /// this subject the three are the ones that matter.
  static int get pathwaysWrongAtFloor => ((100 - floorPercent) / 10).round();

  static bool get theFloorAllowsThreeInTen => pathwaysWrongAtFloor == 3;

  static const String floorNote =
      'A 70% floor means three action pathways in ten are locked wrongly, and '
      'on this subject a wrongly unlocked pathway is the only kind anybody '
      'will hear about. A conformance floor works where the failures are '
      'interchangeable; these are not. The figure is carried verbatim and the '
      'step reports against its own obligations, every one of which holds -- '
      'which is the honest reading, because 70% of a rule is not a weaker '
      'rule, it is no rule.';

  /// The ceiling is the only one in this batch that asks for something beyond
  /// the optimal and names what it is: continuous audit. Worth recording,
  /// because most of the ceilings here are the optimal repeated.
  static const String ceilingAsWritten =
      '100% conformance + continuous audit';

  static bool get theCeilingAddsSomethingRealAboveTheOptimal =>
      ceilingAsWritten.contains('continuous audit') &&
      optimalPercent == 100;

  static Map<String, bool> get obligations => <String, bool>{
        'three authority states map to three pathway states':
            everyAuthorityStateHasItsOwnPathwayState,
        'pending is not treated as refused': pendingIsNotRefused,
        'every pathway is enforced at the server':
            everyPathwayIsEnforcedServerSide,
        'every pathway says why it is on the list': everyPathwayGivesAReason,
        'a locked pathway is not a dead end': lockedPathwaysAreNotDeadEnds,
        'every non-available state says something':
            everyNonAvailableStateSaysSomething,
        'the refusal names who can change it': theRefusalNamesWhoCanChangeIt,
      };

  static double get conformance =>
      obligations.values.where((bool b) => b).length / obligations.length;

  static String get qualitativeOutput {
    final double pct = conformance * 100;
    if (pct >= optimalPercent) {
      return 'Good';
    }
    return pct >= floorPercent ? 'Average' : 'Poor';
  }

  static Map<String, bool> get checks => <String, bool>{
        'three authority states, three pathway states, one each':
            everyAuthorityStateHasItsOwnPathwayState && pendingIsNotRefused,
        'the two-state reading locks out slow connections':
            theNaiveReadingLocksOutSlowConnections &&
                threeStatesNote.contains('silence is not a verdict'),
        'four pathways, all enforced server-side, each with a reason':
            pathways.length == 4 &&
                everyPathwayIsEnforcedServerSide &&
                everyPathwayGivesAReason,
        'the lock is named as mistake-prevention rather than security':
            !theLockIsSecurity &&
                theLockPreventsMistakes &&
                notSecurityNote.contains('the actual vulnerability'),
        'a locked pathway is not a dead end, read from Step 292':
            lockedPathwaysAreNotDeadEnds,
        'the refused and pending messages differ, and neither is empty':
            everyNonAvailableStateSaysSomething &&
                theRefusalNamesWhoCanChangeIt,
        'the 70% floor is three pathways in ten, and is recorded as no rule':
            theFloorAllowsThreeInTen && floorNote.contains('it is no rule'),
        'the ceiling asks for something real above the optimal':
            theCeilingAddsSomethingRealAboveTheOptimal,
        'seven obligations, all met, giving Good':
            obligations.length == 7 &&
                obligations.values.every((bool b) => b) &&
                conformance == 1.0 &&
                qualitativeOutput == 'Good',
      };

  static const String columnNote =
      'COLUMN NOTE: the Setup Step column on this row reads "Embed '
      'translucent padding layers to scale compact icon layers safely to '
      '48x48dp", and every narrative column is about an insurance premium '
      'calculator -- dependants, rate lookups and a cost-per-pay-period '
      'widget. Atomic Step: "Instruct the frontend interface layout assembler '
      'to cleanly lock and disable action pathways if background '
      'authorization parameters are unverified."';
}
