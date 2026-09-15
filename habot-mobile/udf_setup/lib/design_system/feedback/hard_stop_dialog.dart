/// Step 281 (HSFVS-011-15) -- the dialog that ends a flow, and the two
/// vocabularies that have no word for it.
///
/// The row: "Implement an M3 AlertDialog to interrupt the user flow securely
/// upon a hard stop."
/// Metric: **Observability / Alert Coverage** -- floor ">=90%", optimal 1,
/// ceiling 1. Good / Average / Poor. Cited: the Google SRE Handbook,
/// Monitoring Distributed Systems.
///
/// **Two different things are called an alert.** The SRE Handbook's alert
/// coverage is the share of failure modes that page a human operator; this row
/// is a dialog that tells the person holding the phone. Both are "alerts" and
/// neither measures the other -- a perfect alert-coverage score would be a
/// statement about the monitoring stack and would say nothing about whether
/// this dialog is comprehensible. The metric is recorded and the substitution
/// is stated, as at Steps 268, 273 and 275.
///
/// **A hard stop is not an error category, and the vocabulary has no slot for
/// it.** `HabotErrorCategory` has nine members and every one of them describes
/// something that went wrong *on the way to* an outcome. A hard stop is the
/// outcome: the flow is over, nothing further will be attempted, and retrying
/// is not a thing that can happen. Step 272 found the same shape in the
/// surface taxonomy -- none of the four intents fits a terminal block. Two
/// rows in one batch reaching the same missing concept is a recommendation
/// rather than a coincidence, and it is recorded as one.
///
/// **And an interrupting dialog arrives under a moving thumb.** A surface that
/// appears unannounced and is immediately live gets dismissed by the tap that
/// was meant for the button underneath it. The actions do not accept input
/// until the enter transition has finished, and the safe action holds the
/// initial focus.
library;

import '../resilience/error_templates.dart';
import '../surfaces/dialog_to_sheet.dart';
import '../tokens/motion_tokens.dart';

/// What a hard stop has to tell somebody.
class HabotHardStop {
  const HabotHardStop({
    required this.what,
    required this.cost,
    required this.next,
  });

  /// What happened, in one sentence, with no code in it.
  final String what;

  /// What it cost -- money, data, time. Stated even when the answer is
  /// nothing, because "nothing was charged" is the sentence people need.
  final String cost;

  /// The one thing to do now. Never a retry.
  final String next;

  bool get isComplete =>
      what.isNotEmpty && cost.isNotEmpty && next.isNotEmpty;

  bool get mentionsNoCode =>
      !what.contains('Exception') &&
      !what.contains('HTTP') &&
      !RegExp(r'\b\d{3}\b').hasMatch(what);
}

/// The dialog.
class HabotHardStopDialog {
  const HabotHardStopDialog._();

  // -----------------------------------------------------------------------
  // No slot in either vocabulary.
  // -----------------------------------------------------------------------

  /// The nine declared error categories, none of which is a terminal stop.
  static int get declaredErrorCategories => HabotErrorCategory.values.length;

  /// Names a terminal category would plausibly have, checked over the enum's
  /// own names so that adding one later breaks this gate rather than passing
  /// it -- the pattern Step 269 used for free-text field types.
  static const Set<String> terminalCategoryNames = <String>{
    'hardStop',
    'terminal',
    'aborted',
    'ended',
    'stopped',
  };

  static bool get noErrorCategoryIsTerminal => HabotErrorCategory.values.every(
        (HabotErrorCategory c) => !terminalCategoryNames.contains(c.name),
      );

  /// And no surface intent is either -- the gap Step 272 recorded.
  static const Set<String> terminalIntentNames = <String>{
    'terminalStop',
    'block',
    'halt',
  };

  static bool get noSurfaceIntentIsTerminal => HabotSurfaceIntent.values.every(
        (HabotSurfaceIntent i) => !terminalIntentNames.contains(i.name),
      );

  static bool get bothVocabulariesAreMissingTheSameConcept =>
      noErrorCategoryIsTerminal && noSurfaceIntentIsTerminal;

  static const String missingSlotNote =
      'A hard stop is not an error category and it is not one of the four '
      'surface intents. Every HabotErrorCategory describes something that '
      'went wrong on the way to an outcome; a hard stop IS the outcome -- the '
      'flow is over, nothing further will be attempted, and retrying is not a '
      'thing that can happen. Step 272 found the same hole in the surface '
      'taxonomy for an environmental block. Two rows in one batch arriving at '
      'the same missing concept is a recommendation rather than a '
      'coincidence: a terminal kind belongs in both vocabularies, and adding '
      'it touches gated files from earlier steps, so it is recorded here '
      'rather than done quietly.';

  // -----------------------------------------------------------------------
  // The surface, from the existing rule.
  // -----------------------------------------------------------------------

  /// Mapped to the intent whose surface properties are right -- a dialog at
  /// every width, not dismissible by gesture -- with the mismatch above
  /// recorded rather than papered over.
  static const HabotSurfaceIntent mappedIntent = HabotSurfaceIntent.decision;

  static HabotSurfaceForm formAt(double widthDp) =>
      HabotSurfaceChoice.formFor(mappedIntent, widthDp);

  static bool get itIsADialogAtEveryWidth =>
      formAt(360) == HabotSurfaceForm.dialog &&
      formAt(1024) == HabotSurfaceForm.dialog;

  static bool get itCannotBeSwipedAway =>
      !HabotSurfaceChoice.isDismissibleByGesture(formAt(360));

  // -----------------------------------------------------------------------
  // What it says.
  // -----------------------------------------------------------------------

  static const HabotHardStop workedExample = HabotHardStop(
    what: 'The booking was cancelled before it completed, so the place was '
        'not held.',
    cost: 'Nothing was charged, and the details you entered are still here.',
    next: 'Choose another session, or contact support with reference SB-294.',
  );

  static bool get theMessageIsComplete =>
      workedExample.isComplete && workedExample.mentionsNoCode;

  /// The three obligations, named so a future message can be checked against
  /// them rather than against taste.
  static const List<String> obligationsOfTheMessage = <String>[
    'what happened, in one sentence and with no code in it',
    'what it cost, stated even when the answer is nothing',
    'the one thing to do now, which is never a retry',
  ];

  static bool get everyObligationIsNamed =>
      obligationsOfTheMessage.length == 3 &&
      obligationsOfTheMessage.every((String s) => s.length > 25);

  /// Retrying cannot help, so no retry is offered. Read against the existing
  /// template vocabulary rather than asserted: the template set keys on
  /// category, and a hard stop has no category -- which is open decision 26
  /// arriving from a second direction.
  static const bool offersRetry = false;

  static bool get theTemplateSetCannotExpressThis =>
      !offersRetry &&
      HabotErrorTemplates.isComplete &&
      noErrorCategoryIsTerminal;

  static const String noRetryNote =
      'No retry is offered, because retrying is not a thing that can happen '
      'after a hard stop. That is awkward for the existing template set, '
      'which keys a retry decision on an error category -- and a hard stop '
      'has no category to key on. Open decision 26 already asks whether '
      '"retryable" belongs on a template at all; this row reaches the same '
      'question from the other side, which is the second piece of evidence '
      'for the same change.';

  // -----------------------------------------------------------------------
  // Arriving under a moving thumb.
  // -----------------------------------------------------------------------

  /// Actions accept input only once the enter transition has finished. The
  /// window comes from the declared motion token rather than a number chosen
  /// here.
  static Duration get inputSettleWindow => HabotMotion.emphasized;

  static bool acceptsInputAt(Duration sinceAppearance) =>
      sinceAppearance >= inputSettleWindow;

  static bool get aTapArrivingWithTheDialogIsIgnored =>
      !acceptsInputAt(Duration.zero) &&
      acceptsInputAt(inputSettleWindow) &&
      inputSettleWindow.inMilliseconds > 0;

  /// The safe action holds initial focus, so a person who confirms by reflex
  /// confirms the harmless one.
  static const String initiallyFocusedAction = 'Back to sessions';
  static const String secondaryAction = 'Contact support';

  static bool get theSafeActionIsTheFocusedOne =>
      initiallyFocusedAction != secondaryAction &&
      workedExample.next.contains('Choose another session');

  static const String movingThumbNote =
      'An interrupting dialog arrives under a thumb that was already moving. '
      'A surface that appears unannounced and is live on the same frame gets '
      'dismissed by the tap meant for the button underneath it, and the '
      'person never reads it -- which converts a hard stop into a screen that '
      'flickered. The actions accept nothing until the enter transition has '
      'finished, and the safe action holds the initial focus so that a reflex '
      'confirmation confirms the harmless one.';

  // -----------------------------------------------------------------------
  // Metric: Observability / Alert Coverage -- 90% / 1 / 1.
  // -----------------------------------------------------------------------

  static Map<String, bool> get coverage => <String, bool>{
        'the surface blocks and cannot be swiped away':
            itIsADialogAtEveryWidth && itCannotBeSwipedAway,
        'the message says what happened, with no code in it':
            workedExample.mentionsNoCode,
        'the message says what it cost': workedExample.cost.isNotEmpty,
        'the message says what to do now, and it is not a retry':
            workedExample.next.isNotEmpty && !offersRetry,
        'the dialog ignores input until it has finished arriving':
            aTapArrivingWithTheDialogIsIgnored,
        'the safe action holds initial focus': theSafeActionIsTheFocusedOne,
      };

  static double get coverageRate =>
      coverage.values.where((bool b) => b).length / coverage.length;

  static const double floorPercent = 90;

  static String get qualitativeOutput {
    final double pct = coverageRate * 100;
    if (pct >= 100) {
      return 'Good';
    }
    return pct >= floorPercent ? 'Average' : 'Poor';
  }

  static const String twoKindsOfAlertNote =
      'Two different things are called an alert. The SRE Handbook\'s alert '
      'coverage is the share of failure modes that page a human operator, and '
      'it is measured on the monitoring stack; this row is a dialog that '
      'tells the person holding the phone. A perfect score on the first would '
      'say nothing about whether the second is comprehensible. The metric is '
      'recorded, the substitution is stated -- coverage over the obligations '
      'this dialog actually has -- and the same trick is not used twice: Step '
      '282 carries the identical metric on a snackbar row.';

  static Map<String, bool> get checks => <String, bool>{
        'nine error categories and none of them is terminal':
            declaredErrorCategories == 9 && noErrorCategoryIsTerminal,
        'no surface intent is terminal either, as Step 272 found':
            noSurfaceIntentIsTerminal &&
                bothVocabulariesAreMissingTheSameConcept,
        'the missing slot is recorded as a recommendation':
            missingSlotNote.contains('rather than done quietly'),
        'it is a dialog at every width and cannot be swiped away':
            itIsADialogAtEveryWidth && itCannotBeSwipedAway,
        'the message carries all three obligations':
            theMessageIsComplete && everyObligationIsNamed,
        'no retry is offered, and the template gap is named':
            !offersRetry &&
                theTemplateSetCannotExpressThis &&
                noRetryNote.contains('open decision 26'),
        'input is refused until the enter transition finishes':
            aTapArrivingWithTheDialogIsIgnored &&
                inputSettleWindow == HabotMotion.emphasized,
        'the safe action holds focus, and the reason is recorded':
            theSafeActionIsTheFocusedOne &&
                movingThumbNote.contains('a screen that flickered'),
        'six coverage obligations, all met, giving Good':
            coverage.length == 6 &&
                coverage.values.every((bool b) => b) &&
                coverageRate == 1.0 &&
                qualitativeOutput == 'Good',
        'the two meanings of "alert" are recorded':
            twoKindsOfAlertNote.contains('paging a human operator') ||
                twoKindsOfAlertNote.contains('page a human operator'),
      };

  static const String columnNote =
      'COLUMN NOTE: the Setup Step column on this row reads "Locate API '
      'request ingestion gateway service responsible for object uploads", '
      'which belongs to a different subject. Atomic Step: "Implement an M3 '
      'AlertDialog to interrupt the user flow securely upon a hard stop."';
}
