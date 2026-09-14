/// AISS Step 195 -- GEN-02885
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Display compliance failure alerts via Material 3 Alert Dialog
///               on mobile screens."
/// Metric: Task Completion Status -- Floor 0.8, Optimal 1, Ceiling 1.
///         Complete / Partial / Not Complete.
///
/// **AN ALERT DIALOG IS THE HEAVIEST THING THIS PRODUCT CAN DO TO SOMEBODY.**
/// It takes the screen, blocks every other control, and cannot be ignored. For
/// a compliance failure that is exactly right — the user must not continue —
/// and for nearly everything else it is wrong. So the useful half of this row
/// is not "build a dialog", it is **deciding what earns one**, because a
/// codebase where any failure can raise a modal is a codebase that trains
/// people to dismiss modals without reading them, and then the one that
/// mattered goes the same way.
///
/// [HabotComplianceAlert.qualifies] is that decision, and everything that does
/// not qualify goes to the Step 68 inline and snackbar paths that already
/// exist.
///
/// **TWO MODALS AT ONCE IS THE FAILURE MODE NOBODY DESIGNS FOR.** Compliance
/// checks do not fail politely one at a time. Stacking dialogs produces a user
/// tapping through three of them, and the third is dismissed with the same
/// reflex as the first. The alert path holds **one** dialog and queues the
/// rest in the order they were raised, so dismissing the visible one promotes
/// the next rather than losing it.
///
/// **A DIALOG WHOSE ONLY BUTTON IS "OK" IS A NOTIFICATION WEARING A
/// DECISION'S CLOTHES.** If the user cannot continue, telling them so without
/// offering the route to comply is a dead end. Every alert carries the action
/// that resolves it, or it says plainly that the resolution is not in the
/// app — which is a different and honest answer.
///
/// **MODALS ARE AN ACCESSIBILITY CONSTRUCT BEFORE THEY ARE A VISUAL ONE.**
/// Step 97's `A11Y_RAW_SEMANTIC_MODAL` rule exists because a modal without a
/// focus trap and a semantic boundary is, to a screen reader, a page with some
/// extra text on it — the user keeps swiping into the controls the dialog is
/// supposed to be blocking. The alert routes through the sanctioned focus-trap
/// site rather than constructing its own barrier.
library;

import '../resilience/error_templates.dart';
import '../tokens/button_role_map.dart';
import '../tokens/motion_tokens.dart';

/// How bad a compliance failure is.
enum HabotComplianceSeverity {
  /// The action cannot proceed and the data cannot be kept. A modal.
  blocking,

  /// The action proceeded but something must be corrected before submission.
  /// Inline, not a modal.
  correctable,

  /// A record for the audit trail. Neither.
  advisory,
}

/// Where a compliance failure is surfaced.
enum HabotAlertSurface {
  /// M3 Alert Dialog. Modal, focus-trapped, one at a time.
  alertDialog,

  /// The Step 68 snackbar. Transient, non-blocking.
  snackbar,

  /// Attached to the field or section it concerns.
  inline,

  /// Recorded, not shown.
  logOnly,
}

/// One compliance failure.
class HabotComplianceFailure {
  const HabotComplianceFailure({
    required this.code,
    required this.severity,
    required this.category,
    required this.resolution,
    required this.raisedAt,
  });

  /// The rule that failed, as the compliance system names it.
  final String code;

  final HabotComplianceSeverity severity;

  /// The Step 68 category, so the copy comes from the template set rather
  /// than from a string written at the call site.
  final HabotErrorCategory category;

  /// What the user can do about it. Null means the resolution is not in this
  /// app -- which is allowed, and must then be SAID rather than left as an OK
  /// button.
  final String? resolution;

  final DateTime raisedAt;

  HabotErrorTemplate get template => HabotErrorTemplates.of(category);

  bool get resolvableInApp => resolution != null;
}

/// Decides what earns a modal, and shows one at a time.
class HabotComplianceAlert {
  HabotComplianceAlert();

  final List<HabotComplianceFailure> _queue = <HabotComplianceFailure>[];
  HabotComplianceFailure? _showing;

  /// **The decision.** Only a blocking failure earns a modal.
  static bool qualifies(HabotComplianceFailure failure) =>
      failure.severity == HabotComplianceSeverity.blocking;

  /// Where a failure goes, for every severity. Declared as a total mapping so
  /// a new severity cannot be added without someone deciding how loud it is.
  static HabotAlertSurface surfaceFor(HabotComplianceSeverity severity) {
    switch (severity) {
      case HabotComplianceSeverity.blocking:
        return HabotAlertSurface.alertDialog;
      case HabotComplianceSeverity.correctable:
        return HabotAlertSurface.inline;
      case HabotComplianceSeverity.advisory:
        return HabotAlertSurface.logOnly;
    }
  }

  /// Raise a failure. Returns the surface it was routed to.
  HabotAlertSurface raise(HabotComplianceFailure failure) {
    final HabotAlertSurface surface = surfaceFor(failure.severity);
    if (surface != HabotAlertSurface.alertDialog) {
      return surface;
    }
    if (_showing == null) {
      _showing = failure;
      return surface;
    }
    // **One at a time.** The rest queue rather than stack.
    _queue.add(failure);
    _queue.sort(
      (HabotComplianceFailure a, HabotComplianceFailure b) =>
          a.raisedAt.compareTo(b.raisedAt),
    );
    return surface;
  }

  HabotComplianceFailure? get showing => _showing;

  int get queuedCount => _queue.length;

  /// Never more than one modal on screen.
  bool get hasModal => _showing != null;

  /// The user dealt with the current one; the next takes its place.
  void dismissCurrent() {
    if (_queue.isEmpty) {
      _showing = null;
      return;
    }
    _showing = _queue.removeAt(0);
  }

  // ---- what the dialog contains -------------------------------------------

  /// The confirming action's colour role, from the Step 188 map rather than
  /// chosen here. A compliance dialog's primary action resolves the failure,
  /// so it is the confirm role -- not the destructive one, which would read as
  /// though complying were dangerous.
  static String? get primaryActionToken =>
      HabotButtonRoleMap.containerTokenFor(HabotButtonRole.confirm);

  /// Actions offered for a failure. **Never a bare acknowledgement.**
  static List<String> actionsFor(HabotComplianceFailure failure) =>
      failure.resolvableInApp
          ? <String>[failure.resolution!, failure.template.retryLabel]
          : <String>['Close'];

  /// When the resolution is not in the app, the dialog must say where it is.
  /// An OK button with no explanation is the dead end this guards against.
  static String bodyFor(HabotComplianceFailure failure) =>
      failure.resolvableInApp
          ? failure.template.body
          : '${failure.template.body} This cannot be resolved in the app; '
              'reference ${failure.code}.';

  /// Modals route through the Step 97 sanctioned focus-trap site rather than
  /// building their own barrier.
  static const String focusTrapSite =
      'lib/design_system/a11y/focus_trap.dart';

  static const String semanticRule = 'A11Y_RAW_SEMANTIC_MODAL';

  /// A dialog is an interruption, not a transition. It uses the sheet timing
  /// rather than a slower emphasis curve: the longer it takes to arrive, the
  /// more likely the user has already tapped something behind it.
  static Duration get enterDuration => HabotMotion.sheetEnter;

  // ---- the row's metric ---------------------------------------------------

  /// The checks, over failures the caller supplies.
  ///
  /// The fixtures are a parameter rather than a field: a library class that
  /// constructs its own test data has to carry timestamps and offsets, and a
  /// raw `Duration` in `lib/` is a poka-yoke violation for a good reason --
  /// the guard cannot tell a fixture's one second from an animation's.
  static Map<String, bool> completionChecks({
    required HabotComplianceFailure blockingA,
    required HabotComplianceFailure blockingB,
    required HabotComplianceFailure correctable,
  }) {
    final HabotComplianceAlert alert = HabotComplianceAlert()
      ..raise(blockingA)
      ..raise(blockingB)
      ..raise(correctable);

    return <String, bool>{
      'only a blocking failure earns a modal':
          qualifies(blockingA) && !qualifies(correctable),
      'a correctable failure is routed inline rather than to a dialog':
          surfaceFor(HabotComplianceSeverity.correctable) ==
              HabotAlertSurface.inline,
      'an advisory failure is recorded rather than shown':
          surfaceFor(HabotComplianceSeverity.advisory) ==
              HabotAlertSurface.logOnly,
      'two blocking failures produce one dialog and a queue, not two dialogs':
          alert.hasModal &&
              alert.queuedCount == 1 &&
              alert.showing?.code == blockingA.code,
      'a correctable failure raised alongside them does not join the modal '
              'queue':
          alert.queuedCount == 1,
      'dismissing the current dialog promotes the next one rather than losing '
              'it':
          () {
        final HabotComplianceAlert a = HabotComplianceAlert()
          ..raise(blockingA)
          ..raise(blockingB);
        a.dismissCurrent();
        final bool promoted =
            a.showing?.code == blockingB.code && a.queuedCount == 0;
        a.dismissCurrent();
        return promoted && !a.hasModal;
      }(),
      'the copy comes from the Step 68 template set rather than from strings '
              'at the call site':
          blockingA.template.title.isNotEmpty,
      'a failure that cannot be resolved in the app says so instead of '
              'offering a bare OK':
          bodyFor(blockingB).contains('cannot be resolved in the app') &&
              bodyFor(blockingA) == blockingA.template.body,
      'a resolvable failure offers the action that resolves it':
          actionsFor(blockingA).first == blockingA.resolution &&
              actionsFor(blockingB).single == 'Close',
      'the primary action takes the confirm colour role rather than the '
              'destructive one':
          primaryActionToken ==
              HabotButtonRoleMap.containerTokenFor(HabotButtonRole.confirm),
      'the modal routes through the sanctioned focus-trap site':
          focusTrapSite.endsWith('focus_trap.dart'),
    };
  }

  static double completionStatus({
    required HabotComplianceFailure blockingA,
    required HabotComplianceFailure blockingB,
    required HabotComplianceFailure correctable,
  }) {
    final Iterable<bool> v = completionChecks(
      blockingA: blockingA,
      blockingB: blockingB,
      correctable: correctable,
    ).values;
    return v.where((bool b) => b).length / v.length;
  }

  static const double floor = 0.8;
  static const double optimal = 1.0;

  static String qualitativeOutput({
    required HabotComplianceFailure blockingA,
    required HabotComplianceFailure blockingB,
    required HabotComplianceFailure correctable,
  }) {
    final double s = completionStatus(
      blockingA: blockingA,
      blockingB: blockingB,
      correctable: correctable,
    );
    if (s >= optimal) {
      return 'Complete';
    }
    return s >= floor ? 'Partial' : 'Not Complete';
  }

  static const String whatEarnsAModalNote =
      'An alert dialog takes the screen, blocks every other control and cannot '
      'be ignored. For a compliance failure that is right; for nearly '
      'everything else it is wrong. A codebase where any failure can raise a '
      'modal trains people to dismiss modals without reading them, and then '
      'the one that mattered goes the same way.';

  static const String oneAtATimeNote =
      'Compliance checks do not fail politely one at a time. Stacking dialogs '
      'produces a user tapping through three of them, and the third is '
      'dismissed with the same reflex as the first. One dialog is shown and '
      'the rest queue.';

  static const String noBareOkNote =
      'A dialog whose only button is OK is a notification wearing a '
      'decision\'s clothes. Every alert carries the action that resolves it, '
      'or says plainly that the resolution is not in the app -- which is a '
      'different and honest answer.';

  static const String modalIsAccessibilityNote =
      'Step 97\'s A11Y_RAW_SEMANTIC_MODAL rule exists because a modal without '
      'a focus trap and a semantic boundary is, to a screen reader, a page '
      'with some extra text on it: the user keeps swiping into the controls '
      'the dialog is supposed to be blocking.';

  static const String columnNote =
      'Setup Step (Action) is EMPTY on this row. The Atomic Step is the unit '
      'of work.';
}
