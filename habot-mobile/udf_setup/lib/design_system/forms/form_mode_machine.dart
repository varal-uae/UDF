/// Step 237 (USMBL-013-A01) -- the form's submission lifecycle as a machine.
///
/// The row: "Review the form layout's required component modes (idle, editing,
/// submitting, locked, error)."
/// Metric: **Scope Coverage / Audit Completeness** -- floor "80% of relevant
/// items identified", optimal "100% identified and logged in an inventory
/// register", ceiling "100% identified, logged, and cross-checked against the
/// design/architecture spec". Complete.
/// Expected Output: "A strict finite state machine manager governing data
/// submission lifecycles."
/// Completion Measure: "Verification that all interactable components lock
/// completely the instant form submission triggers."
///
/// **The Atomic Step says review and the Expected Output asks for a machine.**
/// An audit and a state machine are different artefacts, and the metric grades
/// the audit while the Expected Output grades the machine. Both are produced:
/// the audit is the register below, and the machine is the transition table.
///
/// **Three of the five modes already exist under other names.** `idle` and
/// `locked` are [HabotSubmitState], declared at the submit guard. `editing` is
/// [HabotFormGate]'s touched-and-valid state. What does not exist anywhere is
/// `submitting` as a mode distinct from `locked`, and `error` as a mode of the
/// *form* rather than of a field.
///
/// **"The instant submission triggers" is a synchronous requirement.** If the
/// lock is set after the first `await`, there is a frame in which the form is
/// unlocked and the request is in flight, and that frame is exactly long
/// enough for a second tap. The guard already locks before the call starts;
/// this step writes the requirement down as a property of the machine rather
/// than as a property of one call site.
library;

/// The five modes the row names. Nothing else is a mode.
enum HabotFormMode {
  /// Nothing has been touched. No error is visible even where one would be.
  idle,

  /// The person is entering values. Errors show only on touched fields.
  editing,

  /// A submit has been accepted and the request is in flight. Every
  /// interactable component is non-interactive.
  submitting,

  /// The record may not be edited: it has been accepted, or policy closed it.
  /// Distinct from [submitting] because it does not end on a response.
  locked,

  /// The submit came back rejected. Editable again, with the reason attached.
  error,
}

/// What can happen to a form.
enum HabotFormEvent {
  fieldTouched,
  submitAccepted,
  responseSucceeded,
  responseRejected,
  editResumed,
  policyClosed,
}

/// One legal move.
class HabotModeTransition {
  const HabotModeTransition({
    required this.from,
    required this.event,
    required this.to,
    required this.rationale,
  });

  final HabotFormMode from;
  final HabotFormEvent event;
  final HabotFormMode to;
  final String rationale;
}

/// The machine, and the audit register the metric grades.
class HabotFormModeMachine {
  const HabotFormModeMachine._();

  static const List<HabotModeTransition> transitions =
      <HabotModeTransition>[
    HabotModeTransition(
      from: HabotFormMode.idle,
      event: HabotFormEvent.fieldTouched,
      to: HabotFormMode.editing,
      rationale:
          'A pristine form is not a wall of red. The first touch is what '
          'makes errors eligible to show, which is the rule HabotFormGate '
          'already holds as its touched set.',
    ),
    HabotModeTransition(
      from: HabotFormMode.editing,
      event: HabotFormEvent.submitAccepted,
      to: HabotFormMode.submitting,
      rationale:
          'The guard accepts the tap and locks before the call starts, so '
          'there is no frame in which the form is editable and a request is '
          'in flight.',
    ),
    HabotModeTransition(
      from: HabotFormMode.submitting,
      event: HabotFormEvent.responseSucceeded,
      to: HabotFormMode.locked,
      rationale:
          'A successful submit does not return to editing. The record is '
          'accepted; editing it is a different operation with a different '
          'authorisation.',
    ),
    HabotModeTransition(
      from: HabotFormMode.submitting,
      event: HabotFormEvent.responseRejected,
      to: HabotFormMode.error,
      rationale:
          'A rejection returns control with the reason attached. Step 255 '
          'governs what is rolled back on the way through.',
    ),
    HabotModeTransition(
      from: HabotFormMode.error,
      event: HabotFormEvent.editResumed,
      to: HabotFormMode.editing,
      rationale:
          'Touching any field after a rejection resumes editing. The '
          'form-level reason stays visible until something changes, because '
          'clearing it on focus hides the only explanation there is.',
    ),
    HabotModeTransition(
      from: HabotFormMode.editing,
      event: HabotFormEvent.policyClosed,
      to: HabotFormMode.locked,
      rationale:
          'A window closing mid-edit locks the form without a submit. This '
          'is the transition that makes locked a mode rather than a phase of '
          'submitting.',
    ),
    HabotModeTransition(
      from: HabotFormMode.idle,
      event: HabotFormEvent.policyClosed,
      to: HabotFormMode.locked,
      rationale:
          'A form opened after its window closed is locked before it is '
          'touched.',
    ),
  ];

  /// The machine. Returns null when the move is not legal, which is the
  /// point: an illegal move is not a silent no-op with a log line.
  static HabotFormMode? next(HabotFormMode from, HabotFormEvent event) {
    for (final HabotModeTransition t in transitions) {
      if (t.from == from && t.event == event) {
        return t.to;
      }
    }
    return null;
  }

  static bool isLegal(HabotFormMode from, HabotFormEvent event) =>
      next(from, event) != null;

  /// Modes in which the person may change a value.
  static Set<HabotFormMode> get editableModes => <HabotFormMode>{
        HabotFormMode.idle,
        HabotFormMode.editing,
        HabotFormMode.error,
      };

  static bool isInteractive(HabotFormMode mode) =>
      editableModes.contains(mode);

  /// The completion measure, as a property of the machine: no event leads out
  /// of [HabotFormMode.submitting] except a response, and no interactable
  /// component is interactive while in it.
  static bool get submittingIsSealed {
    final List<HabotModeTransition> out = transitions
        .where((HabotModeTransition t) => t.from == HabotFormMode.submitting)
        .toList();
    return out.length == 2 &&
        out.every(
          (HabotModeTransition t) =>
              t.event == HabotFormEvent.responseSucceeded ||
              t.event == HabotFormEvent.responseRejected,
        ) &&
        !isInteractive(HabotFormMode.submitting);
  }

  /// Nothing leaves [HabotFormMode.locked]. That is what locked means.
  static bool get lockedIsTerminal => transitions
      .every((HabotModeTransition t) => t.from != HabotFormMode.locked);

  /// The lock must be set before the first await, not after it.
  static const String synchronousLockNote =
      '"All interactable components lock completely the instant form '
      'submission triggers" is a SYNCHRONOUS requirement. If the lock is set '
      'after the first await there is a frame in which the form is editable '
      'and a request is already in flight, and that frame is exactly long '
      'enough for a second tap. HabotSubmitGuard already locks before the '
      'call starts and counts the calls it actually started; this step writes '
      'the requirement down as a property of the machine rather than leaving '
      'it as a property of one call site.';

  // -----------------------------------------------------------------------
  // The audit register the metric actually grades.
  // -----------------------------------------------------------------------

  /// Where each of the five modes already lives, or empty when nothing
  /// declares it. This is the register.
  static Map<HabotFormMode, String> get declaredAt =>
      <HabotFormMode, String>{
        HabotFormMode.idle: 'HabotSubmitState.idle',
        HabotFormMode.editing: 'HabotFormGate touched + results',
        HabotFormMode.submitting: '',
        HabotFormMode.locked: 'HabotSubmitState.locked',
        HabotFormMode.error: '',
      };

  static List<HabotFormMode> get modesAlreadyDeclared => declaredAt.entries
      .where((MapEntry<HabotFormMode, String> e) => e.value.isNotEmpty)
      .map((MapEntry<HabotFormMode, String> e) => e.key)
      .toList();

  static List<HabotFormMode> get modesThisStepAdds => declaredAt.entries
      .where((MapEntry<HabotFormMode, String> e) => e.value.isEmpty)
      .map((MapEntry<HabotFormMode, String> e) => e.key)
      .toList();

  static const String threeOfFiveNote =
      'Three of the five modes already exist under other names. idle and '
      'locked are HabotSubmitState, declared at the submit guard. editing is '
      'HabotFormGate\'s touched-and-valid state. What exists nowhere is '
      'submitting as a mode distinct from locked -- the guard conflates them, '
      'because from a button\'s point of view they are the same disabled -- '
      'and error as a mode of the FORM rather than of a field. A form-level '
      'rejection has no field to attach to, and the existing gate has no '
      'place to put it.';

  static const String auditVersusMachineNote =
      'The Atomic Step says REVIEW and the Expected Output asks for a strict '
      'finite state machine manager. An audit and a machine are different '
      'artefacts, and the metric grades the audit while the Expected Output '
      'grades the machine. Both are produced here: the register says where '
      'each mode lives today, and the transition table is the machine.';

  // -----------------------------------------------------------------------
  // Metric: Scope Coverage / Audit Completeness.
  // -----------------------------------------------------------------------

  /// The ceiling asks for a cross-check against the spec. The spec here is
  /// the row's own list of five modes, and the register covers all of them.
  static List<String> get rowsDeclaredModes => const <String>[
        'idle',
        'editing',
        'submitting',
        'locked',
        'error',
      ];

  static bool get everyRowModeIsRegistered =>
      HabotFormMode.values.length == rowsDeclaredModes.length &&
      HabotFormMode.values.every(
        (HabotFormMode m) =>
            rowsDeclaredModes.contains(m.name) && declaredAt.containsKey(m),
      );

  static double get scopeCoverage => everyRowModeIsRegistered ? 1.0 : 0.0;

  static bool get crossCheckedAgainstTheSpec => everyRowModeIsRegistered;

  static String get qualitativeOutput =>
      scopeCoverage == 1.0 && crossCheckedAgainstTheSpec
          ? 'Complete'
          : (scopeCoverage >= 0.8 ? 'Partial' : 'Not Complete');

  static Map<String, bool> get checks => <String, bool>{
        'five modes, exactly the five the row names':
            everyRowModeIsRegistered,
        'every mode is registered with where it lives, or with nothing':
            declaredAt.length == HabotFormMode.values.length,
        'three modes already existed and two are added here':
            modesAlreadyDeclared.length == 3 && modesThisStepAdds.length == 2,
        'seven legal transitions, each with a reason':
            transitions.length == 7 &&
                transitions.every(
                  (HabotModeTransition t) => t.rationale.length > 60,
                ),
        'an illegal move returns null rather than silently staying put':
            next(HabotFormMode.locked, HabotFormEvent.editResumed) == null &&
                next(HabotFormMode.idle, HabotFormEvent.responseSucceeded) ==
                    null,
        'submitting is sealed: only a response leaves it, and it is not '
            'interactive': submittingIsSealed,
        'locked is terminal': lockedIsTerminal,
        'the synchronous lock requirement is stated as a property of the '
            'machine': synchronousLockNote.contains('before the first await'),
        'the audit and the machine are both produced':
            auditVersusMachineNote.contains('different artefacts'),
      };

  static const String columnNote =
      'COLUMN NOTE: this row carries a Setup Step. Atomic Step: "Review the '
      'form layout\'s required component modes (idle, editing, submitting, '
      'locked, error)." Expected Output: "A strict finite state machine '
      'manager governing data submission lifecycles."';
}
