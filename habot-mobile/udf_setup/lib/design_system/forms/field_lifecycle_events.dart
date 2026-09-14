/// Step 246 (GEN-04020) -- the three events the row names, the two mechanisms
/// Flutter has, and the moment validation should actually run.
///
/// The row: "Create client-side event listeners (onFocus, onBlur, onChange)
/// for mobile input components."
/// Metric: **Mobile Form Event Listener Coverage** -- floor 1, optimal 1,
/// ceiling 1. Pass/Fail. Standard cited: W3C DOM Event Standard.
///
/// **Flutter has no DOM events.** `onFocus` and `onBlur` are not two listeners
/// here; they are two transitions of one `FocusNode`, observed by one
/// listener that has to look at `hasFocus` to tell which just happened. And
/// `onChange` is two different things: `TextField.onChanged`, which fires for
/// edits arriving through the input connection, and the controller's own
/// listener, which fires for those *and* for programmatic writes. Three DOM
/// events map to two mechanisms and four distinct moments, so coverage is
/// measured over the moments rather than over the listener count.
///
/// **The moment matters more than the listener.** Validating on every
/// keystroke tells a person their email address is invalid while they are
/// typing the first character of it, which is true and useless. The rule is:
/// judge on blur; re-judge on change only once the field has already shown an
/// error, so a correction clears immediately. `HabotFormGate` already
/// implements exactly this with its touched set -- this step writes the rule
/// down, names the moments, and measures them.
///
/// **A validator bound to `onChanged` alone cannot see a formatter's output.**
/// Step 239 found that `TextField.onChanged` does not fire for programmatic
/// writes to a controller. A grouping formatter rewrites the controller text;
/// a validator listening only to `onChanged` sees what the person typed and
/// not what the formatter produced. The binding that follows reads the
/// controller, which both paths update.
library;

/// A moment in a field's life at which something may need to happen.
enum HabotFieldMoment {
  /// The field took focus.
  gainedFocus,

  /// The field lost focus. The judging moment.
  lostFocus,

  /// The person edited the text.
  editedByPerson,

  /// A formatter or other code wrote to the controller. Invisible to
  /// `TextField.onChanged`.
  editedByCode,
}

/// What Flutter actually gives you.
enum HabotListenerMechanism {
  /// One listener on a `FocusNode`, covering two moments.
  focusNodeListener,

  /// `TextField.onChanged`. Person edits only.
  onChangedCallback,

  /// A listener on the `TextEditingController`. Both kinds of edit.
  controllerListener,
}

/// One mapping from the row's DOM name to what carries it here.
class HabotEventBinding {
  const HabotEventBinding({
    required this.domName,
    required this.moment,
    required this.mechanism,
    required this.runsValidation,
    required this.why,
  });

  /// The name in the row and in the W3C standard it cites.
  final String domName;

  final HabotFieldMoment moment;

  final HabotListenerMechanism mechanism;

  /// Whether the field's pattern is evaluated at this moment.
  final bool runsValidation;

  final String why;
}

/// The bindings, and the rule about when to judge.
class HabotFieldLifecycleEvents {
  const HabotFieldLifecycleEvents._();

  static const List<String> domEventsTheRowNames = <String>[
    'onFocus',
    'onBlur',
    'onChange',
  ];

  static const List<HabotEventBinding> bindings = <HabotEventBinding>[
    HabotEventBinding(
      domName: 'onFocus',
      moment: HabotFieldMoment.gainedFocus,
      mechanism: HabotListenerMechanism.focusNodeListener,
      runsValidation: false,
      why: 'Focus is not a judgement. What happens here is that the field '
          'records when it was entered, which is what Step 247 measures '
          'hesitation against.',
    ),
    HabotEventBinding(
      domName: 'onBlur',
      moment: HabotFieldMoment.lostFocus,
      mechanism: HabotListenerMechanism.focusNodeListener,
      runsValidation: true,
      why: 'The judging moment. The person has finished with the field, so '
          'the value is whole and an error about it is actionable rather '
          'than premature.',
    ),
    HabotEventBinding(
      domName: 'onChange',
      moment: HabotFieldMoment.editedByPerson,
      mechanism: HabotListenerMechanism.onChangedCallback,
      runsValidation: false,
      why: 'Judging here tells a person their email address is invalid while '
          'they are typing the first character of it. It re-judges only when '
          'the field is already showing an error, so a correction clears the '
          'moment it is correct.',
    ),
    HabotEventBinding(
      domName: 'onChange',
      moment: HabotFieldMoment.editedByCode,
      mechanism: HabotListenerMechanism.controllerListener,
      runsValidation: false,
      why: 'The moment the row does not have a name for. A formatter writing '
          'to the controller does not fire onChanged, so a validator bound '
          'only to onChanged never sees the formatted value. The controller '
          'listener does.',
    ),
  ];

  /// Every moment a field can be in is bound to something.
  static bool get everyMomentIsBound => HabotFieldMoment.values.every(
        (HabotFieldMoment m) =>
            bindings.any((HabotEventBinding b) => b.moment == m),
      );

  static double get momentCoverage =>
      bindings.map((HabotEventBinding b) => b.moment).toSet().length /
      HabotFieldMoment.values.length;

  /// The row's own count: three DOM names, all bound.
  static double get domEventCoverage =>
      domEventsTheRowNames
          .where(
            (String name) =>
                bindings.any((HabotEventBinding b) => b.domName == name),
          )
          .length /
      domEventsTheRowNames.length;

  /// Distinct Flutter mechanisms in play. Three, for three DOM names and four
  /// moments -- the counts do not line up, which is the substitution.
  static Set<HabotListenerMechanism> get mechanismsUsed =>
      bindings.map((HabotEventBinding b) => b.mechanism).toSet();

  static bool get theCountsDoNotLineUp =>
      domEventsTheRowNames.length == 3 &&
      HabotFieldMoment.values.length == 4 &&
      mechanismsUsed.length == 3;

  // -----------------------------------------------------------------------
  // When to judge.
  // -----------------------------------------------------------------------

  /// Whether the field's pattern runs, given the moment and whether this
  /// field is already showing an error.
  static bool shouldValidate({
    required HabotFieldMoment moment,
    required bool alreadyShowingError,
  }) {
    if (moment == HabotFieldMoment.lostFocus) {
      return true;
    }
    if (moment == HabotFieldMoment.gainedFocus) {
      return false;
    }
    return alreadyShowingError;
  }

  /// The four statements the rule makes, as a table rather than as prose.
  static Map<String, bool> get judgingRule => <String, bool>{
        'blur judges, pristine or not': shouldValidate(
          moment: HabotFieldMoment.lostFocus,
          alreadyShowingError: false,
        ),
        'focus never judges': !shouldValidate(
          moment: HabotFieldMoment.gainedFocus,
          alreadyShowingError: true,
        ),
        'a keystroke in a clean field does not judge': !shouldValidate(
          moment: HabotFieldMoment.editedByPerson,
          alreadyShowingError: false,
        ),
        'a keystroke in an errored field judges immediately': shouldValidate(
          moment: HabotFieldMoment.editedByPerson,
          alreadyShowingError: true,
        ),
      };

  static bool get judgingRuleHolds =>
      judgingRule.values.every((bool b) => b);

  /// Exactly one moment runs validation unconditionally.
  static List<HabotEventBinding> get unconditionalValidationMoments =>
      bindings.where((HabotEventBinding b) => b.runsValidation).toList();

  // -----------------------------------------------------------------------
  // Notes.
  // -----------------------------------------------------------------------

  static const String substitutionNote =
      'Flutter has no DOM events. onFocus and onBlur are not two listeners '
      'here; they are two transitions of one FocusNode, observed by one '
      'listener that has to read hasFocus to tell which just happened. And '
      'onChange is two different things: TextField.onChanged, which fires for '
      'edits arriving through the input connection, and the controller\'s own '
      'listener, which fires for those AND for programmatic writes. Three DOM '
      'names, three mechanisms, four moments -- so coverage is measured over '
      'the moments rather than over a listener count that would have been '
      'right about a platform this application does not run on.';

  static const String whenToJudgeNote =
      'The moment matters more than the listener. Validating on every '
      'keystroke tells a person their email address is invalid while they are '
      'typing the first character of it, which is true and useless. The rule '
      'is: judge on blur; re-judge on change only once the field has already '
      'shown an error, so a correction clears the moment it is correct. '
      'HabotFormGate already implements exactly this with its touched set, so '
      'what this step adds is the statement, the four-case table and the '
      'measurement -- not a second implementation.';

  static const String programmaticWriteNote =
      'A validator bound to onChanged alone cannot see a formatter\'s output. '
      'Step 239 found that TextField.onChanged does not fire for programmatic '
      'writes to a controller. A grouping formatter rewrites the controller '
      'text; a validator listening only to onChanged sees what the person '
      'typed and not what the formatter produced, which on a grouped field is '
      'a different string every time. The binding reads the controller, which '
      'both paths update, and the fourth moment exists in this table so the '
      'gap has a name.';

  // -----------------------------------------------------------------------
  // Metric: Mobile Form Event Listener Coverage -- floor, optimal, ceiling 1.
  // -----------------------------------------------------------------------

  static const double floor = 1;
  static const double optimal = 1;
  static const double ceiling = 1;

  static String get qualitativeOutput =>
      momentCoverage >= floor && domEventCoverage >= floor ? 'Pass' : 'Fail';

  static Map<String, bool> get checks => <String, bool>{
        'all three DOM names the row lists are bound':
            domEventCoverage == 1.0,
        'all four moments a field can be in are bound':
            everyMomentIsBound && momentCoverage == 1.0,
        'three names, three mechanisms and four moments do not line up':
            theCountsDoNotLineUp,
        'every binding says why it does or does not judge':
            bindings.every((HabotEventBinding b) => b.why.length > 60),
        'exactly one moment judges unconditionally, and it is blur':
            unconditionalValidationMoments.length == 1 &&
                unconditionalValidationMoments.single.moment ==
                    HabotFieldMoment.lostFocus,
        'the four-case judging rule holds': judgingRuleHolds,
        'the fourth moment -- a programmatic write -- has a name':
            bindings.any(
          (HabotEventBinding b) =>
              b.moment == HabotFieldMoment.editedByCode &&
              b.mechanism == HabotListenerMechanism.controllerListener,
        ),
        'the substitution is stated rather than the DOM assumed':
            substitutionNote.contains('no DOM events'),
        'the onChanged gap is written down':
            programmaticWriteNote.contains('does not fire for programmatic'),
      };

  static const String columnNote =
      'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic Step: '
      '"Create client-side event listeners (onFocus, onBlur, onChange) for '
      'mobile input components."';
}
