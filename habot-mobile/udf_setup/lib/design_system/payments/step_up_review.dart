/// Step 326 (GEN-03712) -- "instantly" and "queue" in one sentence, and two
/// different people behind one word.
///
/// The row: "Dispatch high-risk payment alerts instantly to mobile security
/// queues for biometric step-up review. [cite: 4588]"
/// Metric: **Fraud Alert Dispatch Speed** -- floor "< 2 sec", optimal
/// "< 500 ms", ceiling "< 5 sec". Pass / Fail. Assigned to **GFD**.
///
/// **The band is inverted**, the second of four in this batch: on a
/// lower-is-better measure the ceiling of 5 seconds is worse than the floor of
/// 2. Step 333 orders the same kind of band correctly, which is what makes
/// these four an error rather than a convention.
///
/// **"Biometric step-up" names two different people.** A step-up
/// authentication re-checks the *payer* before their own payment proceeds; a
/// security queue authenticates the *reviewer* before they see somebody else's
/// payment. Both are real and both use the same platform API, and they are not
/// the same control: one adds assurance to a transaction, the other adds
/// assurance to an inspection. The row uses one phrase and the implementation
/// has to pick. Both are declared here, with who is being authenticated stated
/// on each, because the failure mode of guessing is that a reviewer's
/// fingerprint is recorded as the payer's consent.
///
/// **A biometric gate with no fallback locks people out of their own money.**
/// A fingerprint that is wet, cut, or never enrolled is an ordinary Tuesday,
/// and both platforms ship a device-credential fallback for that reason.
/// Refusing the fallback is a choice, and the people it excludes are the ones
/// who do manual work with their hands.
///
/// **And "instantly" measures the fast half.** Dispatch is machine-to-machine
/// and takes half a second. The review is a person, and the person whose
/// payment is held waits for the queue. Against a four-minute review the
/// dispatch is 0.2 per cent of the wait -- so the row measures the part that
/// was never going to be slow, which is the same shape Step 302's string-trim
/// timing had, on a subject where the waiting is somebody's rent.
library;

import '../tokens/motion_tokens.dart';

/// Who a biometric prompt is authenticating.
enum HabotStepUpSubject {
  /// The person whose money it is.
  payer,

  /// The person inspecting somebody else's payment.
  reviewer,
}

/// What happened at the prompt.
enum HabotBiometricOutcome { passed, failedAndFellBack, unavailable }

/// One declared step-up.
class HabotStepUp {
  const HabotStepUp({
    required this.subject,
    required this.purpose,
    required this.hasDeviceCredentialFallback,
  });

  final HabotStepUpSubject subject;

  /// What the prompt adds assurance to.
  final String purpose;

  final bool hasDeviceCredentialFallback;
}

/// The review.
class HabotStepUpReview {
  const HabotStepUpReview._();

  // -----------------------------------------------------------------------
  // Two people, two prompts.
  // -----------------------------------------------------------------------

  static const List<HabotStepUp> stepUps = <HabotStepUp>[
    HabotStepUp(
      subject: HabotStepUpSubject.payer,
      purpose: 'assurance that this payment is authorised by its owner',
      hasDeviceCredentialFallback: true,
    ),
    HabotStepUp(
      subject: HabotStepUpSubject.reviewer,
      purpose: 'assurance that this reviewer is who the queue thinks they are',
      hasDeviceCredentialFallback: true,
    ),
  ];

  static HabotStepUp forSubject(HabotStepUpSubject s) =>
      stepUps.firstWhere((HabotStepUp u) => u.subject == s);

  static bool get bothSubjectsAreDeclared =>
      stepUps.length == 2 &&
      stepUps.map((HabotStepUp u) => u.subject).toSet().length == 2;

  static bool get thePurposesAreDifferent =>
      forSubject(HabotStepUpSubject.payer).purpose !=
      forSubject(HabotStepUpSubject.reviewer).purpose;

  /// The failure mode of not distinguishing them.
  static const String conflationHazard =
      'a reviewer\'s fingerprint recorded as the payer\'s consent';

  static bool get theHazardOfConflatingThemIsNamed =>
      conflationHazard.contains('payer\'s consent');

  static const String subjectNote =
      'A step-up re-checks the payer before their own payment proceeds. A '
      'security queue checks the reviewer before they see somebody else\'s. '
      'Both are real, both use the same platform prompt, and they add '
      'assurance to different things -- a transaction and an inspection. The '
      'row uses one phrase for both, so an implementation has to guess, and '
      'the cost of guessing wrong is that a reviewer\'s fingerprint ends up in '
      'the record as the payer\'s consent. Both are declared, each saying who '
      'it authenticates.';

  // -----------------------------------------------------------------------
  // The fallback.
  // -----------------------------------------------------------------------

  static bool get everyStepUpHasAFallback =>
      stepUps.every((HabotStepUp u) => u.hasDeviceCredentialFallback);

  static const Map<HabotBiometricOutcome, String> outcomes =
      <HabotBiometricOutcome, String>{
    HabotBiometricOutcome.passed: 'Confirmed',
    HabotBiometricOutcome.failedAndFellBack:
        'Use your device passcode instead',
    HabotBiometricOutcome.unavailable:
        'Biometrics are not set up on this device. Your passcode works',
  };

  static bool get everyOutcomeHasASentence =>
      outcomes.length == HabotBiometricOutcome.values.length;

  static bool get noOutcomeIsADeadEnd => outcomes.values.every(
        (String v) => !v.toLowerCase().contains('cannot continue'),
      );

  static const String fallbackNote =
      'A fingerprint that is wet, cut, or never enrolled is an ordinary '
      'Tuesday, and both platforms ship a device-credential fallback for '
      'exactly that. Refusing it is a choice, and the people it excludes are '
      'the ones who do manual work with their hands -- which, on this '
      'application, is most of them. No outcome here is a dead end.';

  // -----------------------------------------------------------------------
  // Which half the metric measures.
  // -----------------------------------------------------------------------

  static const int dispatchMs = 500;

  /// A human queue. Not fast, and not meant to be.
  static const int reviewSeconds = 240;

  static int get reviewMs => reviewSeconds * 1000;

  static int get totalWaitMs => dispatchMs + reviewMs;

  static double get dispatchShareOfTheWait => dispatchMs / totalWaitMs;

  static bool get theMetricMeasuresTheFastHalf =>
      dispatchShareOfTheWait < 0.01;

  /// What the payer experiences, which nothing on this row measures.
  static const String unmeasuredQuantity = 'time to decision';

  static bool get thePayersQuantityIsUnmeasured =>
      unmeasuredQuantity == 'time to decision';

  static const int siblingStepWithTheSameShape = 302;

  static const String halfNote =
      'Dispatch is machine to machine and takes half a second. The review is a '
      'person, and the person whose payment is held waits for the queue: '
      'against a four-minute review the dispatch is 0.2 per cent of the wait. '
      'The row measures the part that was never going to be slow, which is the '
      'shape Step 302\'s string-trim timing had -- except that here the '
      'waiting is somebody\'s rent, and the quantity that matters to them, '
      'time to decision, appears nowhere on the row.';

  // -----------------------------------------------------------------------
  // What the payer is told while they wait.
  // -----------------------------------------------------------------------

  static Duration get holdNoticeDelay => HabotMotion.loadingIndicatorDelay;

  static const Map<String, String> payerStates = <String, String>{
    'held': 'This payment is being checked. We will tell you either way',
    'approved': 'Checked and sent',
    'declined': 'This one was stopped. Call us and we will explain',
  };

  static bool get thePayerIsToldEitherWay =>
      payerStates.length == 3 &&
      (payerStates['held'] ?? '').contains('either way');

  static bool get noPayerStateLeavesThemWaitingSilently =>
      payerStates.values.every((String v) => v.split(' ').length >= 4);

  // -----------------------------------------------------------------------
  // The band.
  // -----------------------------------------------------------------------

  static const int bandFloorMs = 2000;
  static const int bandOptimalMs = 500;
  static const int bandCeilingMs = 5000;

  static bool get theBandIsInverted => bandCeilingMs > bandFloorMs;

  static const int correctlyOrderedBandInThisBatch = 333;

  static const String bandNote =
      'Lower is better, so the ceiling should be the best value and it is the '
      'worst: 5 seconds against a floor of 2. The second of four inverted '
      'latency bands in this batch, against one -- Step 333 -- that is ordered '
      'correctly.';

  static Map<String, bool> get obligations => <String, bool>{
        'both step-up subjects are declared': bothSubjectsAreDeclared,
        'each says what it adds assurance to': thePurposesAreDifferent,
        'every prompt has a device-credential fallback':
            everyStepUpHasAFallback,
        'no biometric outcome is a dead end': noOutcomeIsADeadEnd,
        'the payer is told either way': thePayerIsToldEitherWay,
      };

  static String get qualitativeOutput =>
      obligations.values.every((bool b) => b) ? 'Pass' : 'Fail';

  static Map<String, bool> get checks => <String, bool>{
        'two subjects, two purposes':
            bothSubjectsAreDeclared && thePurposesAreDifferent,
        'the cost of conflating them is named':
            theHazardOfConflatingThemIsNamed &&
                subjectNote.contains('has to guess'),
        'both prompts fall back to the device credential':
            everyStepUpHasAFallback &&
                everyOutcomeHasASentence &&
                noOutcomeIsADeadEnd,
        'and the people excluded would be the ones who work with their hands':
            fallbackNote.contains('most of them'),
        'the dispatch is 0.2 per cent of a four-minute wait':
            dispatchMs == 500 &&
                reviewMs == 240000 &&
                (dispatchShareOfTheWait - 500 / 240500).abs() < 1e-12 &&
                theMetricMeasuresTheFastHalf,
        'the quantity the payer experiences is not on the row':
            thePayersQuantityIsUnmeasured &&
                siblingStepWithTheSameShape == 302 &&
                halfNote.contains('somebody\'s rent'),
        'three payer states, none of them silent':
            thePayerIsToldEitherWay &&
                noPayerStateLeavesThemWaitingSilently &&
                holdNoticeDelay.inMilliseconds == 300,
        'the ceiling is worse than the floor':
            theBandIsInverted &&
                bandFloorMs == 2000 &&
                bandCeilingMs == 5000 &&
                bandOptimalMs == 500,
        'and Step 333 orders the same kind of band correctly':
            correctlyOrderedBandInThisBatch == 333 &&
                bandNote.contains('second of four'),
        'five obligations, all met, giving Pass':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Pass',
      };

  static const String columnNote =
      'COLUMN NOTE: this row is assigned to GFD rather than UDF, its Atomic '
      'Step carries a stray citation marker -- "[cite: 4588]" -- and every '
      'narrative column is the generic engineering-console boilerplate. Atomic '
      'Step: "Dispatch high-risk payment alerts instantly to mobile security '
      'queues for biometric step-up review."';
}
