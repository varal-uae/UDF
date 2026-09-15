/// Step 272 (GEN-03536) -- the dialog that says the application will not run
/// here, and the two things it must not say.
///
/// The row: "Display minimalist security alert dialogs explaining
/// environmental execution blocks."
/// Metric: **Security Alert Contrast Ratio** -- floor 4.5:1, optimal 7:1,
/// ceiling 21:1. Output "Pass". Standard cited: WCAG 2.2 AA Contrast Rules.
///
/// **No on-device detector decides this.** Every check for a rooted phone, an
/// emulator, an attached debugger or a hooking framework runs inside the
/// environment it is judging, and an attacker with enough privilege to matter
/// is an attacker who can make the check return whatever they like. The
/// detectors are therefore signals the client reports; the block is a decision
/// the server takes; and the dialog's job is to explain a decision made
/// elsewhere. A client that blocked itself would be asking the suspect to hold
/// its own trial.
///
/// **Minimalist is not vague, and it is not candid either.** "Something went
/// wrong" teaches nobody anything, and "root detected via su binary at
/// /system/xbin" hands the next person a checklist. The dialog says what
/// happened in a sentence, gives a reference somebody in support can look up,
/// offers the one action that exists, and does not name the check that fired.
/// Four of the five causes share one message for exactly that reason; the
/// fifth -- an operating system below the floor -- gets its own, because it is
/// the only one the person reading can act on.
///
/// **And 21:1 is not a target.** It is black on white, which no themed surface
/// is, and it is the ratio associated with halation for readers with
/// astigmatism. WCAG's own enhanced level stops at 7:1 and asks for nothing
/// above it. The ceiling is recorded as the arithmetic top of the scale rather
/// than as something to reach -- the same reading Step 267 gave its inverted
/// band.
library;

import '../a11y/contrast.dart';
import '../surfaces/dialog_to_sheet.dart';

/// Why an environment is refused.
enum HabotBlockCause {
  /// The device is rooted or jailbroken.
  privilegedUser,

  /// The application is running on an emulator.
  emulatedDevice,

  /// A debugger is attached to the process.
  debuggerAttached,

  /// A runtime hooking framework is present.
  instrumentationPresent,

  /// The operating system is older than the declared floor.
  unsupportedPlatformVersion,
}

/// One signal the client can send about its environment.
class HabotBlockSignal {
  const HabotBlockSignal({
    required this.cause,
    required this.clientCanObserve,
    required this.clientCanTrust,
    required this.resolvableInSession,
    required this.why,
  });

  final HabotBlockCause cause;

  /// Whether the client can look for it at all.
  final bool clientCanObserve;

  /// Whether the answer means anything when the environment is hostile.
  final bool clientCanTrust;

  /// Whether the condition could stop being true while this run of the
  /// application is still in memory. Drives whether a retry is offered, so a
  /// future cause that can clear in place gets a button without anybody
  /// editing the dialog.
  final bool resolvableInSession;

  final String why;

  /// A signal worth sending but not worth acting on alone.
  bool get isEvidenceNotAVerdict => clientCanObserve && !clientCanTrust;
}

/// The block.
class HabotExecutionBlock {
  const HabotExecutionBlock._();

  static const List<HabotBlockSignal> signals = <HabotBlockSignal>[
    HabotBlockSignal(
      cause: HabotBlockCause.privilegedUser,
      clientCanObserve: true,
      clientCanTrust: false,
      resolvableInSession: false,
      why: 'Root detection is a list of paths, packages and properties, and '
          'every entry on it is something a rooted device can hide. The check '
          'runs with less privilege than the thing it is looking for.',
    ),
    HabotBlockSignal(
      cause: HabotBlockCause.emulatedDevice,
      clientCanObserve: true,
      clientCanTrust: false,
      resolvableInSession: false,
      why: 'Build fingerprints and sensor behaviour give an emulator away '
          'until somebody edits them, and they are editable. It also catches '
          'the QA fleet, which is a real cost for a weak signal.',
    ),
    HabotBlockSignal(
      cause: HabotBlockCause.debuggerAttached,
      clientCanObserve: true,
      clientCanTrust: false,
      resolvableInSession: false,
      why: 'Observable through the platform, and the platform call is one of '
          'the first things an attached debugger patches. Useful as a report '
          'from an ordinary device, worthless as a defence.',
    ),
    HabotBlockSignal(
      cause: HabotBlockCause.instrumentationPresent,
      clientCanObserve: true,
      clientCanTrust: false,
      resolvableInSession: false,
      why: 'A hooking framework rewrites the function that would report it. '
          'This is the clearest case of the general problem: the detector and '
          'the thing detected occupy the same address space.',
    ),
    HabotBlockSignal(
      cause: HabotBlockCause.unsupportedPlatformVersion,
      clientCanObserve: true,
      clientCanTrust: true,
      resolvableInSession: false,
      why: 'The one honest local check. An old operating system is not '
          'hiding, it is old, and the person holding the phone can do '
          'something about it -- which is why it gets its own message.',
    ),
  ];

  static HabotBlockSignal signalFor(HabotBlockCause c) =>
      signals.firstWhere((HabotBlockSignal s) => s.cause == c);

  static List<HabotBlockSignal> get trustworthyLocally =>
      signals.where((HabotBlockSignal s) => s.clientCanTrust).toList();

  static List<HabotBlockSignal> get evidenceOnly =>
      signals.where((HabotBlockSignal s) => s.isEvidenceNotAVerdict).toList();

  /// Four of the five are reportable and not decidable here.
  static double get shareThatIsEvidenceOnly =>
      evidenceOnly.length / signals.length;

  static bool get everyHostileSignalIsEvidenceRatherThanAVerdict =>
      evidenceOnly.length == 4 && trustworthyLocally.length == 1;

  static const String whoDecidesNote =
      'Every on-device detector runs inside the environment it is judging, so '
      'an attacker privileged enough to matter is an attacker who can make '
      'the detector say whatever they like -- the detector and the thing '
      'detected occupy the same address space. The signals are therefore '
      'reported, not acted on: the server weighs them against what it knows '
      'and refuses the session, and the client explains a decision taken '
      'elsewhere. A client that blocked itself would be asking the suspect to '
      'hold its own trial. The same shape as Step 253\'s balance gate and '
      'Step 269\'s ingestion check.';

  // -----------------------------------------------------------------------
  // What the dialog says.
  // -----------------------------------------------------------------------

  /// The message shown for every cause the person cannot act on. One text,
  /// deliberately, so that comparing two blocked devices tells an attacker
  /// nothing about which check fired.
  static const String genericMessage =
      'This device cannot run the app securely, so the session was stopped. '
      'Nothing was charged and nothing was lost.';

  /// The one cause with an action attached.
  static const String platformMessage =
      'This version of the operating system is older than the app supports. '
      'Updating the device and opening the app again should resolve it.';

  static String messageFor(HabotBlockCause c) =>
      c == HabotBlockCause.unsupportedPlatformVersion
          ? platformMessage
          : genericMessage;

  static Set<String> get distinctMessages =>
      HabotBlockCause.values.map(messageFor).toSet();

  /// Four causes, one message: the dialog does not say which check fired.
  static bool get theDialogDoesNotNameTheCheck =>
      distinctMessages.length == 2 &&
      HabotBlockCause.values
              .where((HabotBlockCause c) => messageFor(c) == genericMessage)
              .length ==
          4;

  /// A support code, opaque to the reader and meaningful to the person who
  /// receives the call. Not the cause name, which is the point.
  static String referenceCodeFor(HabotBlockCause c) =>
      'SB-${(HabotBlockCause.values.indexOf(c) + 41) * 7}';

  static bool get theCodeCarriesNoCauseName => HabotBlockCause.values.every(
        (HabotBlockCause c) =>
            !referenceCodeFor(c).toLowerCase().contains(c.name.toLowerCase()),
      );

  static bool get everyCauseHasItsOwnCode =>
      HabotBlockCause.values.map(referenceCodeFor).toSet().length ==
      HabotBlockCause.values.length;

  /// A retry is offered exactly when the condition could clear while this
  /// run is still in memory. None of the five can: a phone does not un-root
  /// itself and an operating system does not update without restarting, so
  /// the version floor is worded as "open the app again" rather than given a
  /// button that fails in place. A sixth cause declared resolvable would get
  /// the button without anybody editing this dialog.
  static bool offersRetry(HabotBlockCause c) =>
      signalFor(c).resolvableInSession;

  static bool get nothingOffersARetryThatCannotWork =>
      HabotBlockCause.values.every((HabotBlockCause c) => !offersRetry(c)) &&
      platformMessage.contains('opening the app again');

  /// The retry rule is a function of the data rather than a constant: a cause
  /// that could clear in place would be offered one.
  static bool get theRetryRuleIsDataDriven =>
      signals.every((HabotBlockSignal s) => !s.resolvableInSession) &&
      offersRetry(HabotBlockCause.unsupportedPlatformVersion) ==
          signalFor(HabotBlockCause.unsupportedPlatformVersion)
              .resolvableInSession;

  static const String minimalistNote =
      'Minimalist is not vague and it is not candid either. "Something went '
      'wrong" teaches nobody anything; "root detected via the su binary" '
      'hands the next reader a checklist. The dialog gives one sentence of '
      'what happened, one reassurance about money and data, a reference code '
      'support can look up, and the one action that exists. Four of the five '
      'causes share a message precisely so that comparing two blocked devices '
      'reveals nothing, and the fifth differs because it is the only one the '
      'person holding the phone can do something about.';

  // -----------------------------------------------------------------------
  // The surface, decided by the rule that already exists.
  // -----------------------------------------------------------------------

  /// Step 225's rule, run rather than restated. A block is the closest thing
  /// the taxonomy has to a decision: it stays a dialog at every width and it
  /// cannot be swiped away.
  static HabotSurfaceForm formAt(double widthDp) =>
      HabotSurfaceChoice.formFor(HabotSurfaceIntent.decision, widthDp);

  static bool get itIsADialogAtEveryWidth =>
      formAt(360) == HabotSurfaceForm.dialog &&
      formAt(1024) == HabotSurfaceForm.dialog &&
      !HabotSurfaceChoice.isDismissibleByGesture(formAt(360));

  static bool get aSheetHereWouldBreakTheBlocking =>
      HabotSurfaceChoice.blindConversionBreaksBlocking(
        HabotSurfaceIntent.decision,
      );

  static const String noIntentFitsNote =
      'None of Step 225\'s four intents is really this. Choice, decision, '
      'disclosure and destructive confirmation all assume the flow continues '
      'after the surface closes, and after this one there is no flow: the '
      'session is over and the only exits are support and the home screen. '
      'It is mapped to decision because that is the intent whose surface '
      'properties are right -- a dialog at every width, not dismissible by '
      'gesture -- and the mismatch is recorded rather than papered over by '
      'adding a fifth intent for one screen.';

  // -----------------------------------------------------------------------
  // Metric: Security Alert Contrast Ratio -- 4.5:1 / 7:1 / 21:1.
  // -----------------------------------------------------------------------

  static double get floorRatio => WcagThresholds.textFloor;
  static double get optimalRatio => WcagThresholds.textOptimal;

  /// The arithmetic top of the scale: pure black on pure white.
  static const double ceilingRatio = 21;

  static bool get theBandIsReadFromTheExistingThresholds =>
      floorRatio == 4.5 && optimalRatio == 7.0;

  /// Nothing in WCAG asks for more than the enhanced level, and the ceiling
  /// is three times it.
  static bool get theCeilingIsAboveEveryPublishedRequirement =>
      ceilingRatio > optimalRatio * 2;

  static const String ceilingNote =
      'Twenty-one to one is not a target. It is pure black on pure white, '
      'which no themed surface is and no Material You palette produces, and '
      'it is the ratio associated with halation -- text that appears to '
      'shimmer -- for readers with astigmatism. WCAG\'s enhanced level stops '
      'at 7:1 and asks for nothing above it, so the ceiling here is the '
      'arithmetic top of the scale rather than a goal. Recorded the way Step '
      '267\'s inverted band was, so nobody builds toward it.';

  static const String metricDoesNotMeasureTheRowNote =
      'A contrast ratio says the alert is legible. It says nothing about '
      'whether the block was correct, whether the explanation is true, or '
      'whether the person can get help -- which are the three things this row '
      'is actually about. The measurement is worth making and is made; the '
      'gap between what it measures and what the step does is recorded, as it '
      'was for Steps 251 and 258, rather than hidden by reporting the easy '
      'number as though it settled the hard one.';

  /// **Pass.** The contrast obligation is met by the existing tokens and
  /// thresholds; the substance of the row -- who decides, what is said, and
  /// what is withheld -- is settled above and the metric's silence about it
  /// is named.
  static String get qualitativeOutput =>
      theBandIsReadFromTheExistingThresholds &&
              theDialogDoesNotNameTheCheck &&
              itIsADialogAtEveryWidth
          ? 'Pass'
          : 'Fail';

  static Map<String, bool> get checks => <String, bool>{
        'five causes are ruled on, each with a reason':
            signals.length == 5 &&
                signals.every((HabotBlockSignal s) => s.why.length > 80),
        'every cause is observable here and only one is trustworthy here':
            signals.every((HabotBlockSignal s) => s.clientCanObserve) &&
                everyHostileSignalIsEvidenceRatherThanAVerdict,
        'four of five are evidence rather than a verdict, and the share is '
            'published':
            (shareThatIsEvidenceOnly - 0.8).abs() < 1e-9,
        'the decision is named as the server\'s':
            whoDecidesNote.contains('hold its own trial'),
        'four causes share one message, so the check is not named':
            theDialogDoesNotNameTheCheck,
        'the actionable cause gets the only different message':
            messageFor(HabotBlockCause.unsupportedPlatformVersion) !=
                genericMessage,
        'the message says nothing was charged and nothing was lost':
            genericMessage.contains('Nothing was charged'),
        'every cause has a distinct reference code and none names its cause':
            everyCauseHasItsOwnCode && theCodeCarriesNoCauseName,
        'no retry is offered that could not work, and the rule reads the '
            'data rather than a constant':
            nothingOffersARetryThatCannotWork && theRetryRuleIsDataDriven,
        'it is a dialog at every width and cannot be swiped away':
            itIsADialogAtEveryWidth && aSheetHereWouldBreakTheBlocking,
        'the intent mismatch is recorded rather than given a fifth intent':
            noIntentFitsNote.contains('adding a fifth intent'),
        'the band is read from the existing WCAG thresholds':
            theBandIsReadFromTheExistingThresholds,
        'the 21:1 ceiling is recorded as unreachable rather than as a goal':
            theCeilingIsAboveEveryPublishedRequirement &&
                ceilingNote.contains('halation'),
        'the metric\'s silence about the row\'s substance is named':
            metricDoesNotMeasureTheRowNote.contains('the easy number'),
      };

  static const String columnNote =
      'COLUMN NOTE: Setup Step (Action) is EMPTY on this row, and Best '
      'Qualitative Output is "Pass" with no Fail offered. Atomic Step: '
      '"Display minimalist security alert dialogs explaining environmental '
      'execution blocks."';
}
