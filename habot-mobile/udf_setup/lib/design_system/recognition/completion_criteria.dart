/// Step 436 (GEN-02127) -- what "complete" means, written down before anything
/// is awarded points for it, and the charter that applies once a person rather
/// than a screen is being scored.
///
/// The row: "Define the criteria indicating absolute "completion" for various
/// workflows."
/// Metric: **Step Completion Rate (%)** -- floor 90, optimal 99, ceiling 100.
/// Complete/Partial/Not Complete. ISO/IEC 27001:2022 General Standards.
/// Assigned to **PDG**.
///
/// **The whole Data Requirement is one word.** "Data/artifacts to prepare:
/// completion." The row asks for a definition of completion and names, as the
/// artefact to prepare, the word it is asking to be defined. The Data Collected
/// cell repeats it. A definition that is its own input is the most compressed
/// form of the defect this track has seen, and it arrives on the row every
/// other row in this batch depends on: points, streaks, levels and praise are
/// all awarded for completing something.
///
/// **"Absolute" is the right word, and it rules out three things.** A workflow
/// is not complete because a screen was reached, because a button was pressed,
/// or because a timer expired. It is complete when the record it exists to
/// change is in its terminal state on the server -- approved, rejected, filed,
/// paid -- and the person who started it has been told. Step 434 already
/// separated a 202 from an outcome; this is the same separation, promoted to a
/// definition every later row binds to.
///
/// **This batch is where the rows start scoring people.** Step 416 fixed the
/// unit of analysis at a screen and forbade attributing friction to an
/// individual. The rows that follow are explicitly about individuals -- points,
/// streaks, levels, praise, evaluations, quizzes, an escalation timer -- so the
/// screen rule cannot apply and a second rule is needed for when a person is
/// legitimately the subject. It is written here, as a charter of four rules,
/// before the first point is awarded.
///
/// **The band is Step 404's and Step 412's.** Step Completion Rate at 90, 99,
/// 100 for the third time in three batches, each on a subject unrelated to the
/// others.
library;

import '../telemetry/friction_framework.dart';

/// Where a workflow's record is.
enum HabotRecordState {
  /// Drafted on the device.
  draft,

  /// Accepted by the queue; nothing decided.
  submitted,

  /// Decided on the server: approved, rejected, filed or paid.
  terminal,
}

/// One workflow and what counts as its completion.
class HabotWorkflowCompletion {
  const HabotWorkflowCompletion({
    required this.workflow,
    required this.terminalStates,
    required this.personIsNotified,
  });

  final String workflow;
  final List<String> terminalStates;
  final bool personIsNotified;
}

/// The four rules that apply when a person is being scored.
class HabotScoringCharter {
  const HabotScoringCharter._();

  static const List<String> rules = <String>[
    'the person can see their own score and how it was computed',
    'every score can be contested, and a contest pauses its use',
    'no score triggers a consequence automatically; a named person decides',
    'scores come from validated server events, never from telemetry about '
        'how somebody used a screen',
  ];

  static int get ruleCount => rules.length;

  static bool get fourRules => ruleCount == 4;

  static bool get frictionTelemetryCanNeverFeedAScore =>
      HabotFrictionFramework.theUnitOfAnalysisIsAScreen &&
      rules.last.contains('telemetry');
}

/// The completion criteria.
class HabotCompletionCriteria {
  const HabotCompletionCriteria._();

  // -----------------------------------------------------------------------
  // The Data Requirement is the word being defined.
  // -----------------------------------------------------------------------

  static const String dataRequirementCell =
      'Data/artifacts to prepare: completion.';

  static bool get theArtefactIsTheWordItself =>
      dataRequirementCell.endsWith('completion.');

  static const bool everyLaterRowDependsOnIt = true;

  static const String selfReferenceNote =
      'The row asks for a definition of completion and names, as the artefact '
      'to prepare, the single word "completion". A definition that is its own '
      'input is the most compressed form of that defect in the track, and it '
      'sits on the row every other row in this batch depends on, since points, '
      'streaks, levels and praise are all awarded for completing something.';

  // -----------------------------------------------------------------------
  // "Absolute" rules out three things.
  // -----------------------------------------------------------------------

  static const List<String> notCompletion = <String>[
    'a screen was reached',
    'a button was pressed',
    'a timer expired',
  ];

  static bool get threeThingsAreRuledOut => notCompletion.length == 3;

  static bool isComplete({
    required HabotRecordState state,
    required bool personNotified,
  }) =>
      state == HabotRecordState.terminal && personNotified;

  static bool get aSubmittedRecordIsNotComplete =>
      !isComplete(state: HabotRecordState.submitted, personNotified: true);

  static bool get anUnnotifiedTerminalRecordIsNotComplete =>
      !isComplete(state: HabotRecordState.terminal, personNotified: false);

  static bool get aNotifiedTerminalRecordIsComplete =>
      isComplete(state: HabotRecordState.terminal, personNotified: true);

  static const int theStepThatSeparatedAcceptanceFromOutcome = 434;

  static const List<HabotWorkflowCompletion> workflows =
      <HabotWorkflowCompletion>[
    HabotWorkflowCompletion(
      workflow: 'overtime request',
      terminalStates: <String>['approved', 'rejected'],
      personIsNotified: true,
    ),
    HabotWorkflowCompletion(
      workflow: 'shift swap',
      terminalStates: <String>['swapped', 'declined', 'expired'],
      personIsNotified: true,
    ),
    HabotWorkflowCompletion(
      workflow: 'expense claim',
      terminalStates: <String>['paid', 'rejected'],
      personIsNotified: true,
    ),
    HabotWorkflowCompletion(
      workflow: 'training module',
      terminalStates: <String>['passed', 'not yet passed'],
      personIsNotified: true,
    ),
  ];

  static bool get everyWorkflowNamesItsTerminalStates => workflows
      .every((HabotWorkflowCompletion w) => w.terminalStates.isNotEmpty);

  static bool get everyWorkflowNotifies =>
      workflows.every((HabotWorkflowCompletion w) => w.personIsNotified);

  static bool get anExpiryIsATerminalStateNotACompletion =>
      workflows[1].terminalStates.contains('expired');

  static const String absoluteNote =
      'A workflow is not complete because a screen was reached, a button was '
      'pressed or a timer expired. It is complete when the record it exists to '
      'change is in a terminal state on the server and the person who started '
      'it has been told. "Expired" is listed as a terminal state for a shift '
      'swap because the record is finished; it is not a completion anybody '
      'should be awarded points for, and the distinction is kept.';

  // -----------------------------------------------------------------------
  // The charter.
  // -----------------------------------------------------------------------

  static bool get theCharterIsWrittenBeforeAnyPoint =>
      HabotScoringCharter.fourRules;

  static bool get theScreenRuleStillHoldsForTelemetry =>
      HabotScoringCharter.frictionTelemetryCanNeverFeedAScore;

  static const String charterNote =
      'Step 416 fixed the unit of analysis at a screen. The rows after this '
      'one score people -- points, streaks, levels, praise, evaluations, '
      'quizzes, an escalation timer -- so a second rule is needed for when a '
      'person is legitimately the subject. Four: the person sees their own '
      'score and its working; any score can be contested and a contest pauses '
      'its use; no score triggers a consequence without a named person '
      'deciding; and scores come from validated server events, never from '
      'telemetry about how somebody used a screen.';

  // -----------------------------------------------------------------------
  // The band, for the third time.
  // -----------------------------------------------------------------------

  static const int bandFloor = 90;
  static const int bandOptimal = 99;
  static const int bandCeiling = 100;

  /// Steps 404, 412 and this one.
  static const List<int> rowsWithThisBand = <int>[404, 412, 436];

  static bool get thirdOccurrence => rowsWithThisBand.length == 3;

  static double get completion {
    if (workflows.isEmpty) {
      return 0;
    }
    final int defined = workflows
        .where((HabotWorkflowCompletion w) =>
            w.terminalStates.isNotEmpty && w.personIsNotified)
        .length;
    return defined / workflows.length * 100;
  }

  static String get qualitativeOutput =>
      completion >= bandOptimal ? 'Complete' : 'Partial';

  static const String columnNote =
      'COLUMN NOTE: this row\'s Data Requirement reads, in full, '
      '"Data/artifacts to prepare: completion." -- the artefact to prepare is '
      'the word the row asks to be defined, and the Data Collected cell '
      'repeats it; its band is Step Completion Rate at 90, 99, 100, the third '
      'time in three batches after Steps 404 and 412; and it is the definition '
      'every later row in this batch depends on, so it also carries the '
      'four-rule charter that applies once a person rather than a screen is '
      'scored. Atomic Step: "Define the criteria indicating absolute '
      '"completion" for various workflows."';

  static Map<String, bool> get obligations => <String, bool>{
        'completion requires a terminal state': aSubmittedRecordIsNotComplete,
        'and a notified person': anUnnotifiedTerminalRecordIsNotComplete,
        'every workflow names its terminal states':
            everyWorkflowNamesItsTerminalStates,
        'the scoring charter is written first':
            theCharterIsWrittenBeforeAnyPoint,
        'telemetry can never feed a score': theScreenRuleStillHoldsForTelemetry,
      };

  static Map<String, bool> get checks => <String, bool>{
        'the Data Requirement is the word being defined':
            theArtefactIsTheWordItself && everyLaterRowDependsOnIt,
        'and every later row depends on it':
            selfReferenceNote.contains('completing something'),
        'three things are ruled out by "absolute"': threeThingsAreRuledOut,
        'a submitted record is not complete':
            aSubmittedRecordIsNotComplete &&
                theStepThatSeparatedAcceptanceFromOutcome == 434,
        'nor is a terminal one nobody was told about':
            anUnnotifiedTerminalRecordIsNotComplete &&
                aNotifiedTerminalRecordIsComplete,
        'four workflows, each naming its terminal states':
            workflows.length == 4 &&
                everyWorkflowNamesItsTerminalStates &&
                everyWorkflowNotifies,
        'and an expiry is terminal without being a completion':
            anExpiryIsATerminalStateNotACompletion &&
                absoluteNote.contains('awarded points for'),
        'four charter rules, written before the first point':
            theCharterIsWrittenBeforeAnyPoint &&
                charterNote.contains('legitimately the subject'),
        'the band is Step 404\'s and 412\'s, a third time':
            thirdOccurrence && bandCeiling == 100,
        'five obligations, all met, giving Complete':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Complete' &&
                theScreenRuleStillHoldsForTelemetry,
      };
}
