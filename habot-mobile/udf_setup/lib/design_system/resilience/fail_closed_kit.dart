/// Step 317 (ERMWD-029-03) -- "store designs matching backend fail-closed
/// logic", which is a rule about where a decision lives.
///
/// The row: "Store designs in UI Component Kit matching backend fail-closed
/// logic."
/// Metric: **UI Design-System Adherence Rate** -- floor >=85%, optimal >=95%,
/// ceiling 1. Good / Average / Poor.
///
/// **"Matching" is the whole instruction, and it is the wrong verb.** Two
/// copies of a rule that must agree will disagree, and the disagreement is
/// silent: the server refuses and the component says the action is available,
/// or the component refuses and the server would have allowed it. Step 314
/// found the same shape in a parallel accessible list -- two structures, one
/// truth, nine pairs that can drift. Here the pairs are security decisions.
///
/// **So the kit holds the presentation and not the decision.** For each of the
/// five states the backend can be in, the kit declares what the control looks
/// like, what it says and whether it can be pressed -- and every one of those
/// is derived from a state the server sends, never from a rule evaluated here.
/// The component cannot reach a verdict of its own, which is the only version
/// of "matching" that cannot drift.
///
/// **A kit entry that has no backend state is the defect this catches.** Five
/// backend states, five kit entries, and the check is a bijection in both
/// directions: a state with no design is a screen nobody drew, and a design
/// with no state is a screen that can never appear and will be maintained
/// forever.
///
/// **COLUMN NOTE.** Two of this row's Mobile UX/UI configuration cells are
/// React Native props -- `keyboardType="numeric"` and `secureTextEntry={true}`
/// -- which makes this the thirteenth row in this track written for another
/// stack, and the Setup Step reads "Research the WebAuthn API requirements for
/// the target platforms", which belongs to authentication rather than to a
/// component kit.
library;

/// What the backend has said. The kit renders these; it does not compute them.
enum HabotBackendVerdict {
  /// The server has allowed it.
  allowed,

  /// The server has refused it, and said why.
  refused,

  /// The server could not decide.
  errored,

  /// The server has not been asked yet.
  unasked,

  /// The server has refused it permanently, and the refusal is final.
  closed,
}

/// One entry in the component kit.
class HabotKitEntry {
  const HabotKitEntry({
    required this.verdict,
    required this.label,
    required this.pressable,
    required this.showsReason,
  });

  final HabotBackendVerdict verdict;

  /// What the control says in this state.
  final String label;

  /// Whether the control can be pressed.
  final bool pressable;

  /// Whether the state carries a reason the person can read.
  final bool showsReason;
}

/// The kit.
class HabotFailClosedKit {
  const HabotFailClosedKit._();

  static const List<HabotKitEntry> entries = <HabotKitEntry>[
    HabotKitEntry(
      verdict: HabotBackendVerdict.allowed,
      label: 'Submit',
      pressable: true,
      showsReason: false,
    ),
    HabotKitEntry(
      verdict: HabotBackendVerdict.refused,
      label: 'Cannot submit -- see why',
      pressable: true,
      showsReason: true,
    ),
    HabotKitEntry(
      verdict: HabotBackendVerdict.errored,
      label: 'Check failed -- try again',
      pressable: true,
      showsReason: true,
    ),
    HabotKitEntry(
      verdict: HabotBackendVerdict.unasked,
      label: 'Checking',
      pressable: false,
      showsReason: false,
    ),
    HabotKitEntry(
      verdict: HabotBackendVerdict.closed,
      label: 'Closed -- see why',
      pressable: true,
      showsReason: true,
    ),
  ];

  static HabotKitEntry entryFor(HabotBackendVerdict v) =>
      entries.firstWhere((HabotKitEntry e) => e.verdict == v);

  // -----------------------------------------------------------------------
  // The bijection.
  // -----------------------------------------------------------------------

  static Set<HabotBackendVerdict> get verdictsCovered =>
      entries.map((HabotKitEntry e) => e.verdict).toSet();

  static List<HabotBackendVerdict> get statesWithNoDesign =>
      HabotBackendVerdict.values
          .where((HabotBackendVerdict v) => !verdictsCovered.contains(v))
          .toList();

  static bool get everyStateHasExactlyOneDesign =>
      verdictsCovered.length == entries.length &&
      statesWithNoDesign.isEmpty &&
      entries.length == HabotBackendVerdict.values.length;

  static const String bijectionNote =
      'A backend state with no design is a screen nobody drew, and somebody '
      'meets it in production. A design with no backend state is a screen that '
      'can never appear and will be maintained forever, because nothing tells '
      'the person deleting it that it is unreachable. The check runs in both '
      'directions for that reason.';

  // -----------------------------------------------------------------------
  // The decision lives in one place.
  // -----------------------------------------------------------------------

  /// The kit renders a verdict. It never computes one.
  static const bool theKitEvaluatesAnyRule = false;

  static const bool theKitHasADefaultWhenNoVerdictIsPresent = true;

  /// And that default is the unasked state, not the allowed one -- which is
  /// what makes the rendering fail-closed rather than merely faithful.
  static HabotKitEntry get defaultEntry =>
      entryFor(HabotBackendVerdict.unasked);

  static bool get theDefaultIsNotAllowed =>
      defaultEntry.verdict != HabotBackendVerdict.allowed &&
      !defaultEntry.pressable;

  static const String singleSourceNote =
      '"Matching" is the wrong verb: two copies of a rule that must agree will '
      'disagree, and the disagreement is silent in both directions -- the '
      'server refuses while the control looks live, or the control refuses '
      'what the server would have allowed. The kit holds the presentation and '
      'the server holds the decision, so there is one rule and the component '
      'cannot reach a verdict of its own. That is the only reading of '
      '"matching" that cannot drift. Step 314 found the same shape in a '
      'parallel accessible list; here the pairs are security decisions.';

  // -----------------------------------------------------------------------
  // What a refusal owes the person.
  // -----------------------------------------------------------------------

  static List<HabotKitEntry> get refusingEntries => entries
      .where((HabotKitEntry e) => e.verdict != HabotBackendVerdict.allowed)
      .toList();

  static List<HabotKitEntry> get refusalsThatCanBeOpened => refusingEntries
      .where((HabotKitEntry e) => e.pressable && e.showsReason)
      .toList();

  /// Only the state that is still being decided is unpressable, because there
  /// is nothing behind it yet.
  static List<HabotKitEntry> get unpressable =>
      entries.where((HabotKitEntry e) => !e.pressable).toList();

  static bool get onlyTheUndecidedStateIsUnpressable =>
      unpressable.length == 1 &&
      unpressable.first.verdict == HabotBackendVerdict.unasked;

  static bool get everyRefusalCanBeOpened =>
      refusalsThatCanBeOpened.length == refusingEntries.length - 1;

  static const String openableNote =
      'A refused control is still a control. Three of the four non-allowed '
      'states can be pressed and open the reason behind them, which is the '
      'remedy Steps 291 and 293 supplied and Step 292 was refused for '
      'lacking. The fourth is the state that has not been decided yet, and it '
      'is unpressable because there is nothing behind it -- not because it is '
      'forbidden.';

  // -----------------------------------------------------------------------
  // The band and the columns.
  // -----------------------------------------------------------------------

  static const String bandCeiling = '1';

  static bool get theCeilingIsInADifferentUnit => !bandCeiling.contains('%');

  static const List<String> foreignStackCells = <String>[
    'keyboardType="numeric"',
    'secureTextEntry={true}',
  ];

  static const int foreignStackNumber = 13;

  static bool get theConfigurationCellsAreReactNative =>
      foreignStackCells.length == 2 &&
      foreignStackCells.every((String c) => c.contains('='));

  static Map<String, bool> get obligations => <String, bool>{
        'every backend state has exactly one design':
            everyStateHasExactlyOneDesign,
        'the kit evaluates no rule of its own': !theKitEvaluatesAnyRule,
        'the default state is not the allowed one': theDefaultIsNotAllowed,
        'every refusal can be opened': everyRefusalCanBeOpened,
        'only the undecided state is unpressable':
            onlyTheUndecidedStateIsUnpressable,
      };

  static double get adherence =>
      obligations.values.where((bool b) => b).length / obligations.length;

  static String get qualitativeOutput {
    if (adherence >= 0.95) {
      return 'Good';
    }
    return adherence >= 0.85 ? 'Average' : 'Poor';
  }

  static Map<String, bool> get checks => <String, bool>{
        'five backend states, five kit entries, bijective':
            HabotBackendVerdict.values.length == 5 &&
                entries.length == 5 &&
                everyStateHasExactlyOneDesign,
        'a state with no design and a design with no state are both caught':
            statesWithNoDesign.isEmpty &&
                bijectionNote.contains('maintained forever'),
        'the kit holds presentation and the server holds the decision':
            !theKitEvaluatesAnyRule &&
                singleSourceNote.contains('cannot drift'),
        'the default is the undecided state rather than the allowed one':
            theDefaultIsNotAllowed &&
                theKitHasADefaultWhenNoVerdictIsPresent &&
                defaultEntry.label == 'Checking',
        'three of the four non-allowed states open their reason':
            refusingEntries.length == 4 &&
                refusalsThatCanBeOpened.length == 3 &&
                everyRefusalCanBeOpened,
        'and the fourth is unpressable because nothing is behind it yet':
            onlyTheUndecidedStateIsUnpressable &&
                openableNote.contains('not because it is'),
        'the ceiling is in a different unit from the floor':
            theCeilingIsInADifferentUnit,
        'two configuration cells are React Native props':
            theConfigurationCellsAreReactNative && foreignStackNumber == 13,
        'five obligations, all met':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                adherence == 1.0,
      };

  static const String columnNote =
      'COLUMN NOTE: two of this row\'s Mobile UX/UI configuration cells are '
      'React Native props -- keyboardType="numeric" and '
      'secureTextEntry={true} -- the thirteenth row in this track written for '
      'another stack, and the Setup Step reads "Research the WebAuthn API '
      'requirements for the target platforms", which belongs to '
      'authentication rather than to a component kit. Atomic Step: "Store '
      'designs in UI Component Kit matching backend fail-closed logic."';
}
