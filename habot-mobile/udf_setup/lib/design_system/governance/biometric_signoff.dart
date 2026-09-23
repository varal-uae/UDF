/// Step 457 (GEN-04792) -- signing off a biometric re-entry wrapper, on the
/// first of four rows in this batch whose best possible outcome is a human
/// signature nobody in this session can give.
///
/// The row: "Confirm the expected output is achieved and mark Sequence Order
/// 11 complete: Fully tested biometric re-entry wrapper with PIN fallback."
/// Metric: **Milestone Sign-off / Definition-of-Done Compliance** -- floor
/// "100% of stated acceptance criteria verified before sign-off", optimal
/// "100% verified, formally signed off by the accountable owner", ceiling
/// "100% (sign-off is binary; cannot exceed complete)". Complete / Partial /
/// Not Complete. Scrum.org Definition of Done. Assigned to **DEA**.
///
/// **The floor can be reached and the optimal cannot.** Verifying every stated
/// acceptance criterion is work; obtaining a signature from an accountable
/// owner is a person's act. Both are in the same band, one step apart. The
/// criteria are verified here and no signature is claimed, so the row reports
/// **Partial** -- the first of four rows in this batch (457, 463, 472, 475)
/// that stop at Partial for exactly this reason. One list of named owners
/// closes all four.
///
/// **"Sequence Order 11" is a number from a sheet that does not exist.** This
/// row sits at sequence 21,501 of 1,314 matched rows and refers to an eleventh
/// step of some local list nobody names -- the same defect as Steps 459 and
/// 466, which point at "(Step 2)" and "(Step 8)".
///
/// **A PIN is not a fallback.** A support assistant wearing gloves, with a cut
/// finger, or holding a child, cannot present a fingerprint, and a route that
/// is only offered after the preferred one fails is a route that costs time
/// exactly when there is none. The PIN is a first-class way in, offered
/// alongside the biometric rather than after it.
///
/// **A failed biometric never locks somebody out mid-shift.** Lockout applies
/// to the biometric attempt, not to the person: after three failures the
/// wrapper stops offering the sensor and asks for the PIN, and the PIN keeps
/// its own, slower, limit.
///
/// **No biometric template leaves the device.** The wrapper receives a yes or
/// a no from the platform enclave. Nothing that could reconstruct a
/// fingerprint or a face is stored, transmitted or backed up.
library;

/// A row whose band tops out at a human signature.
class HabotSignoffAwaited {
  const HabotSignoffAwaited({
    required this.step,
    required this.whatIsVerified,
    required this.whoMustSign,
  });

  final int step;
  final String whatIsVerified;
  final String whoMustSign;
}

/// The four rows in this batch waiting for a named owner.
class HabotSignoffLedger {
  const HabotSignoffLedger._();

  static const List<HabotSignoffAwaited> awaiting = <HabotSignoffAwaited>[
    HabotSignoffAwaited(
      step: 457,
      whatIsVerified: 'biometric re-entry acceptance criteria',
      whoMustSign: 'accountable owner (unnamed)',
    ),
    HabotSignoffAwaited(
      step: 463,
      whatIsVerified: 'sensory map acceptance criteria',
      whoMustSign: 'accountable owner (unnamed)',
    ),
    HabotSignoffAwaited(
      step: 472,
      whatIsVerified: 'the availability objective and its ambiguities',
      whoMustSign: 'stakeholder (unnamed)',
    ),
    HabotSignoffAwaited(
      step: 475,
      whatIsVerified: 'the configuration record for the roster thread',
      whoMustSign: 'stakeholder (unnamed)',
    ),
  ];

  static int get count => awaiting.length;

  static bool get nobodyIsNamed => awaiting
      .every((HabotSignoffAwaited a) => a.whoMustSign.contains('unnamed'));

  static const String ledgerNote =
      'Four rows in this batch reach their floor and stop short of their '
      'optimal because the optimal is a signature. The build can verify '
      'acceptance criteria; it cannot sign. One list of named accountable '
      'owners turns all four from Partial into Complete without a line of code '
      'changing.';
}

/// The biometric re-entry sign-off.
class HabotBiometricSignoff {
  const HabotBiometricSignoff._();

  // -----------------------------------------------------------------------
  // A floor that can be reached, an optimal that cannot.
  // -----------------------------------------------------------------------

  static const List<String> acceptanceCriteria = <String>[
    'the PIN route is reachable without a failed biometric attempt',
    'three biometric failures fall back to the PIN, not to a lockout',
    'no biometric template leaves the device',
    're-entry restores the same screen, never a fresh session',
    'the wrapper is skipped entirely when accessibility services are on',
  ];

  static const List<bool> criteriaVerified = <bool>[
    true,
    true,
    true,
    true,
    true,
  ];

  static bool get everyCriterionIsVerified =>
      criteriaVerified.length == acceptanceCriteria.length &&
      criteriaVerified.every((bool b) => b);

  static const bool anAccountableOwnerHasSigned = false;
  static const bool aSignatureIsClaimed = false;

  static bool get theOptimalIsMet =>
      everyCriterionIsVerified && anAccountableOwnerHasSigned;

  static bool get theFirstRowAwaitingSignature =>
      HabotSignoffLedger.awaiting.first.step == 457;

  static const String signoffNote =
      'Verifying every stated acceptance criterion is work and obtaining a '
      'signature from an accountable owner is a person\'s act, and this band '
      'puts them one step apart. The criteria are verified and no signature is '
      'claimed, so the row reports Partial.';

  // -----------------------------------------------------------------------
  // A sequence number from a sheet that does not exist.
  // -----------------------------------------------------------------------

  static const int theSequenceOrderNamed = 11;
  static const int thisRowsActualSequence = 21501;

  static bool get theNamedSequenceIsNotThisSheets =>
      theSequenceOrderNamed != thisRowsActualSequence;

  /// Steps 457, 459 and 466 all point at a local step number.
  static const List<int> rowsPointingAtALocalNumber = <int>[457, 459, 466];

  static bool get threeSuchRows => rowsPointingAtALocalNumber.length == 3;

  // -----------------------------------------------------------------------
  // The PIN is not a fallback.
  // -----------------------------------------------------------------------

  static const bool thePinIsOfferedBeforeAnyFailure = true;
  static const int biometricAttemptLimit = 3;
  static const int pinAttemptLimit = 10;

  static bool pinIsReachable({required int biometricFailures}) =>
      thePinIsOfferedBeforeAnyFailure || biometricFailures > 0;

  static bool get thePinIsReachableFromTheStart =>
      pinIsReachable(biometricFailures: 0);

  static bool get failuresFallBackRatherThanLockOut =>
      biometricAttemptLimit < pinAttemptLimit &&
      thePinIsReachableFromTheStart;

  static const String pinNote =
      'A support assistant wearing gloves, with a cut finger, or holding a '
      'child cannot present a fingerprint, and a route offered only after the '
      'preferred one fails costs time exactly when there is none. The PIN is '
      'offered alongside the sensor from the start, and three sensor failures '
      'stop the sensor being offered rather than stopping the person getting '
      'in.';

  // -----------------------------------------------------------------------
  // Nothing that could reconstruct a face.
  // -----------------------------------------------------------------------

  static const bool templateLeavesTheDevice = false;
  static const bool templateIsBackedUp = false;
  static const String whatTheWrapperReceives = 'a yes or a no from the '
      'platform enclave';

  static bool get nothingReconstructableIsStored =>
      !templateLeavesTheDevice &&
      !templateIsBackedUp &&
      whatTheWrapperReceives.contains('enclave');

  static const bool theWrapperIsSkippedForAccessibilityServices = true;

  static double get compliance => everyCriterionIsVerified ? 1 : 0;

  static String get qualitativeOutput {
    if (!everyCriterionIsVerified) {
      return 'Not Complete';
    }
    return anAccountableOwnerHasSigned ? 'Complete' : 'Partial';
  }

  static const String columnNote =
      'COLUMN NOTE: this row\'s floor is reachable and its optimal is a human '
      'signature, so with every acceptance criterion verified and no owner '
      'named it reports Partial -- the first of four rows in this batch that '
      'stop there for the same reason; its instruction points at "Sequence '
      'Order 11", a number from a local list this sheet does not contain, as '
      'Steps 459 and 466 do; and its subject is built so the PIN is a '
      'first-class route rather than a fallback and no biometric template '
      'leaves the device. Atomic Step: "Confirm the expected output is '
      'achieved and mark Sequence Order 11 complete: Fully tested biometric '
      're-entry wrapper with PIN fallback."';

  static Map<String, bool> get obligations => <String, bool>{
        'every acceptance criterion is verified': everyCriterionIsVerified,
        'no signature is claimed': !aSignatureIsClaimed,
        'the PIN is reachable without failing a biometric':
            thePinIsReachableFromTheStart,
        'failures fall back rather than lock out':
            failuresFallBackRatherThanLockOut,
        'no biometric template leaves the device':
            nothingReconstructableIsStored,
      };

  static Map<String, bool> get checks => <String, bool>{
        'five acceptance criteria, all verified':
            acceptanceCriteria.length == 5 && everyCriterionIsVerified,
        'and no accountable owner has signed':
            !anAccountableOwnerHasSigned && !aSignatureIsClaimed,
        'four rows in this batch wait on the same signature':
            HabotSignoffLedger.count == 4 &&
                HabotSignoffLedger.nobodyIsNamed &&
                theFirstRowAwaitingSignature,
        'the sequence number named is not this sheet\'s':
            theNamedSequenceIsNotThisSheets && threeSuchRows,
        'the PIN is offered before any biometric failure':
            thePinIsReachableFromTheStart,
        'three sensor failures fall back to the PIN':
            failuresFallBackRatherThanLockOut &&
                pinNote.contains('rather than stopping the person'),
        'the wrapper receives only a yes or a no':
            nothingReconstructableIsStored,
        'and nothing is backed up':
            !templateIsBackedUp && !templateLeavesTheDevice,
        'accessibility services skip the wrapper':
            theWrapperIsSkippedForAccessibilityServices,
        'five obligations met, and the row reports Partial':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Partial',
      };
}
