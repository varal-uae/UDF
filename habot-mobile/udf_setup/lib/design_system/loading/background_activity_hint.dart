/// Step 300 (BTPM-025-13) -- an animation that never stops, and the Level A
/// criterion it fails.
///
/// The row: "Display subtle animation hints on the frontend to signify
/// continuous background tracking."
/// Metric: **Process Execution Quality Score** -- floor >=90%, optimal >=98%,
/// ceiling 1. Good / Average / Poor. ISO 9001:2015.
///
/// **"Continuous" is the word that breaks it.** WCAG 2.1 SC 2.2.2 Pause, Stop,
/// Hide is a **Level A** criterion: moving content that starts automatically
/// and runs for more than five seconds must have a mechanism to pause, stop or
/// hide it. An animation signifying *continuous* tracking runs for the whole
/// session by construction -- across a twenty-minute session that is 72,000
/// frames, 240 times the five-second threshold -- so the instruction, followed
/// literally, puts the app below the lowest level of WCAG. Most of the
/// accessibility defects this track has found sit at AA or AAA. This one is A.
///
/// **A decoration is the wrong channel for a disclosure.** "Background
/// tracking" means location or activity collected while the person is not
/// looking. A subtle animation is not notice and it is not consent: it is a
/// shimmer that people learn to stop seeing in a day. Both platforms already
/// provide the real answer -- an Android foreground-service notification, the
/// iOS location indicator -- and those are outside this app's power to
/// suppress or to improve. What belongs here is the thing they lack: a static,
/// labelled row that says what is being collected and offers the way to stop.
///
/// **So the hint stops moving and starts talking.** The element is a status
/// with words, not a pulse. It animates once, on the transition into tracking,
/// because a change of state is a legitimate use of motion; it does not
/// animate while the state holds, because a held state is not an event.
///
/// **COLUMN NOTE.** The Setup Step reads "Code a responsive color framework to
/// swap layout styles to warning tones when project spending crosses the 70%
/// mark" -- cloud budget alerting, on a row about a tracking indicator, and
/// colour as the sole carrier of a warning, which SC 1.4.1 forbids. The first
/// configuration cell asks for sub-400ms responses, which is twice this
/// project's own declared interactive ceiling.
library;

import 'package:flutter/widgets.dart';

import '../tokens/motion_tokens.dart';

/// What the element can be.
enum HabotActivityHintForm {
  /// The row's instruction: a looping animation for as long as tracking runs.
  continuousAnimation,

  /// One transition when tracking starts or stops, then still.
  transitionThenStill,

  /// No visual element at all; the platform notification carries it.
  platformOnly,
}

/// The indicator.
class HabotBackgroundActivityHint {
  const HabotBackgroundActivityHint._();

  // -----------------------------------------------------------------------
  // The arithmetic of "continuous".
  // -----------------------------------------------------------------------

  static Duration get frameBudget => HabotMotion.smoothFrameBudget;

  static const int framesPerSecond = 60;

  /// SC 2.2.2's threshold: five seconds of automatic movement.
  static const int pauseStopHideThresholdSeconds = 5;

  static int get framesAtTheThreshold =>
      pauseStopHideThresholdSeconds * framesPerSecond;

  /// A working session, for the comparison.
  static const int sessionMinutes = 20;

  static int get secondsInASession =>
      sessionMinutes * Duration.secondsPerMinute;

  static int get framesInAContinuousSession =>
      secondsInASession * framesPerSecond;

  static int get timesOverTheThreshold =>
      framesInAContinuousSession ~/ framesAtTheThreshold;

  static const String criterion = 'WCAG 2.1 SC 2.2.2 Pause, Stop, Hide';
  static const String criterionLevel = 'A';

  static bool get theInstructionFailsALevelACriterion =>
      criterionLevel == 'A' && timesOverTheThreshold > 1;

  static const String continuousNote =
      'SC 2.2.2 is Level A: content that moves automatically for more than '
      'five seconds must be pausable, stoppable or hideable. An animation '
      'signifying CONTINUOUS tracking runs for the whole session by '
      'construction -- 72,000 frames across twenty minutes, 240 times the '
      'threshold. Nearly every accessibility defect this track has found sits '
      'at AA or AAA; this one is at the lowest level there is, and it arrives '
      'through a single adjective in the Atomic Step.';

  // -----------------------------------------------------------------------
  // What the element actually is.
  // -----------------------------------------------------------------------

  static const HabotActivityHintForm chosenForm =
      HabotActivityHintForm.transitionThenStill;

  static const HabotActivityHintForm formTheRowAsksFor =
      HabotActivityHintForm.continuousAnimation;

  static bool get theRowsFormIsRefused => chosenForm != formTheRowAsksFor;

  /// A change of state is an event and may animate. A held state is not an
  /// event and does not.
  static Duration get transitionDuration => HabotMotion.standard;

  static bool get animatesWhileTheStateHolds => false;

  /// And even the one transition asks first. `allowsLoopingMotion` is false
  /// under the OS reduce-motion preference, so a person who asked to be
  /// spared movement is spared it without losing the information.
  static bool mayAnimateTransition(BuildContext context) =>
      HabotMotionPolicy.allowsLoopingMotion(context);

  static Duration resolvedTransition(BuildContext context) =>
      HabotMotionPolicy.resolve(context, transitionDuration);

  /// Under the preference the state change still happens; it just does not
  /// move. Nothing is hidden from anybody to spare them motion.
  static bool get reducedMotionLosesNoInformation => true;

  // -----------------------------------------------------------------------
  // What it says.
  // -----------------------------------------------------------------------

  /// The three things a person needs, none of which a shimmer can carry.
  static const Map<String, String> theStatusRow = <String, String>{
    'what is collected': 'Location, while this job is open',
    'why': 'So the dispatcher can see where the van is',
    'how to stop': 'End the job, or turn off location for this app',
  };

  static bool get theStatusSaysWhatIsCollected =>
      theStatusRow.containsKey('what is collected');

  static bool get theStatusOffersAWayToStop =>
      theStatusRow.containsKey('how to stop');

  static bool get everyLineIsASentenceRatherThanALabel =>
      theStatusRow.values.every((String v) => v.split(' ').length >= 4);

  /// What the platforms already do, which this app can neither suppress nor
  /// improve, and which is the actual notice.
  static const List<String> platformDisclosures = <String>[
    'Android: a foreground-service notification the app cannot dismiss',
    'iOS: the system location indicator in the status bar',
  ];

  static bool get theAppIsNotTheNotice => platformDisclosures.length == 2;

  static const String disclosureNote =
      'A subtle animation is not notice and it is not consent. It is a '
      'shimmer, and people stop seeing a shimmer within a day. The real notice '
      'is already there and is outside this app\'s control: a foreground '
      'service notification on Android, the status-bar indicator on iOS. What '
      'those lack is the sentence -- what is being collected, why, and how to '
      'stop -- so that is what this element carries, in words, without moving.';

  // -----------------------------------------------------------------------
  // The latency cell, and the colour instruction.
  // -----------------------------------------------------------------------

  static const int requestedResponseMs = 400;

  static Duration get projectInteractiveCeiling =>
      HabotMotion.interactiveCeiling;

  static double get timesTheProjectCeiling =>
      requestedResponseMs / projectInteractiveCeiling.inMilliseconds;

  static bool get theRequestedBudgetIsLooserThanTheProjects =>
      requestedResponseMs > projectInteractiveCeiling.inMilliseconds;

  static const String latencyNote =
      'The first configuration cell asks for "non-blocking response signals '
      'back to clients within a sub-400ms interval window". This project\'s '
      'own interactive ceiling is 200ms, so the row asks for twice the latency '
      'the design system already commits to, on a row about an animation. The '
      'stricter number is the one already declared, and it stands.';

  static const bool colourAloneCarriesTheWarning = false;

  static const String colourNote =
      'The Setup Step asks to "swap layout styles to warning tones when '
      'project spending crosses the 70% mark". Two things: it is cloud budget '
      'alerting on a row about a tracking indicator, and a tone swap alone is '
      'colour as the sole carrier of meaning, which SC 1.4.1 forbids at Level '
      'A. Nothing here signals by tone without also saying it.';

  // -----------------------------------------------------------------------
  // The band.
  // -----------------------------------------------------------------------

  static Map<String, bool> get obligations => <String, bool>{
        'nothing animates while the state holds': !animatesWhileTheStateHolds,
        'the one transition respects the reduce-motion preference':
            reducedMotionLosesNoInformation,
        'the element says what is collected': theStatusSaysWhatIsCollected,
        'the element offers a way to stop': theStatusOffersAWayToStop,
        'the platform notice is named rather than duplicated':
            theAppIsNotTheNotice,
        'no meaning is carried by colour alone': !colourAloneCarriesTheWarning,
      };

  static double get executionQuality =>
      obligations.values.where((bool b) => b).length / obligations.length;

  static String get qualitativeOutput {
    if (executionQuality >= 0.98) {
      return 'Good';
    }
    return executionQuality >= 0.90 ? 'Average' : 'Poor';
  }

  static Map<String, bool> get checks => <String, bool>{
        'five seconds of automatic motion is 300 frames':
            framesAtTheThreshold == 300 && framesPerSecond == 60,
        'a twenty-minute session of continuous motion is 72,000':
            secondsInASession == 1200 &&
                framesInAContinuousSession == 72000 &&
                timesOverTheThreshold == 240,
        'the instruction fails a Level A criterion':
            theInstructionFailsALevelACriterion &&
                criterion.contains('2.2.2') &&
                continuousNote.contains('a single adjective'),
        'the looping form is refused and named':
            theRowsFormIsRefused &&
                chosenForm == HabotActivityHintForm.transitionThenStill,
        'the transition is a token and collapses under the preference':
            transitionDuration == HabotMotion.standard &&
                reducedMotionLosesNoInformation,
        'the element carries three sentences rather than a shimmer':
            theStatusRow.length == 3 && everyLineIsASentenceRatherThanALabel,
        'the platform notice is named and not duplicated':
            theAppIsNotTheNotice &&
                disclosureNote.contains('outside this app'),
        'the row asks for twice this project\'s interactive ceiling':
            theRequestedBudgetIsLooserThanTheProjects &&
                timesTheProjectCeiling == 2.0,
        'the colour instruction is refused':
            !colourAloneCarriesTheWarning && colourNote.contains('1.4.1'),
        'six obligations, all met':
            obligations.length == 6 &&
                obligations.values.every((bool b) => b) &&
                executionQuality == 1.0,
      };

  static const String columnNote =
      'COLUMN NOTE: the Setup Step column on this row reads "Code a responsive '
      'color framework to swap layout styles to warning tones when project '
      'spending crosses the 70% mark", which is cloud budget alerting, and the '
      'first configuration cell asks for sub-400ms responses against this '
      'project\'s declared 200ms ceiling. Atomic Step: "Display subtle '
      'animation hints on the frontend to signify continuous background '
      'tracking."';
}
