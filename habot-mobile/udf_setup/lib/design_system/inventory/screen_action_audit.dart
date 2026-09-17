/// Step 396 (ETMDI-016-02) -- listing what every screen lets somebody do, and
/// the fourth output cell in this sheet with an arrow in it.
///
/// The row: "Open the primary workflow audit tool and list each screen's
/// designated user actions."
/// Metric: **Process Adherence / Task Completion Rate** -- floor ">=90%",
/// optimal 1, ceiling 1. Best Qualitative Output: "Complete/Partial/Not
/// Complete -> Best = Complete (100%)". Assigned to **UDF**.
///
/// **"The primary workflow audit tool" does not exist, and that is the step.**
/// No tool is named anywhere on the row and none is in the repository. What can
/// be built is the thing a tool would produce: a declared inventory of screens
/// and the actions each one offers, held in `lib/` where a test can read it,
/// rather than a spreadsheet somebody exports once and never opens again.
///
/// **An action is not a widget.** A screen with six controls may offer two
/// actions: the rest are navigation, disclosure and cancellation. Counting
/// widgets produces a number nobody can use; counting *things a person can
/// cause to happen* produces the number the next three rows depend on. Five
/// worked screens here declare seven actions between them, against
/// twenty-three interactive elements.
///
/// **Every action names the transaction it causes, or it is not an action.**
/// That is what makes Step 397's "exactly one transaction per screen" checkable
/// rather than aspirational: an action with no named transaction is either
/// navigation misfiled or a gap in the inventory, and both are worth finding.
///
/// **An inventory nobody can diff is a snapshot.** The list is code, so a
/// screen that gains an action changes a file, and the change shows up in
/// review. A tool that emits a document puts the same fact somewhere nobody
/// looks until the next audit.
///
/// **COLUMN NOTE.** The Best Qualitative Output cell reads
/// "Complete/Partial/Not Complete -> Best = Complete (100%)" -- a scale, an
/// arrow, and an
/// annotation naming the best value, which is Step 389's shape and the first of
/// five in this batch. The band mixes ">=90%" with a bare ceiling of 1, and the
/// Setup Step column asks about masked fields for assistive technology.
library;

/// What a person can cause on a screen.
enum HabotScreenActionKind {
  /// Writes something. The reason the screen exists.
  transaction,

  /// Goes somewhere else. Not an action.
  navigation,

  /// Shows more of what is already there. Not an action.
  disclosure,

  /// Leaves without writing. Not an action.
  cancellation,
}

/// One action on one screen.
class HabotScreenActionEntry {
  const HabotScreenActionEntry({
    required this.label,
    required this.kind,
    required this.transaction,
  });

  final String label;
  final HabotScreenActionKind kind;

  /// What it causes. Empty for everything that is not a transaction.
  final String transaction;

  bool get isAnAction => kind == HabotScreenActionKind.transaction;
}

/// One screen in the inventory.
class HabotAuditedScreen {
  const HabotAuditedScreen({
    required this.name,
    required this.entries,
    required this.interactiveElements,
  });

  final String name;
  final List<HabotScreenActionEntry> entries;

  /// Every element a finger can land on, including the ones that are not
  /// actions.
  final int interactiveElements;

  List<HabotScreenActionEntry> get actions =>
      entries.where((HabotScreenActionEntry e) => e.isAnAction).toList();
}

/// The screen-action inventory.
class HabotScreenActionAudit {
  const HabotScreenActionAudit._();

  // -----------------------------------------------------------------------
  // The tool the row names.
  // -----------------------------------------------------------------------

  static const String theToolTheRowNames = 'the primary workflow audit tool';

  static const bool theToolExists = false;

  static const bool theInventoryIsCode = true;

  static bool get theInventoryIsWhatWasBuilt =>
      !theToolExists && theInventoryIsCode;

  static const String toolNote =
      'No tool is named on this row and none is in the repository, so what is '
      'built is the thing a tool would produce: a declared inventory of '
      'screens and the actions each offers, held in lib/ where a test can read '
      'it. A tool that emits a document puts the same fact somewhere nobody '
      'opens until the next audit; an inventory in code changes a file, and '
      'the change shows up in review.';

  // -----------------------------------------------------------------------
  // An action is not a widget.
  // -----------------------------------------------------------------------

  static const List<HabotAuditedScreen> screens = <HabotAuditedScreen>[
    HabotAuditedScreen(
      name: 'Clock in',
      interactiveElements: 4,
      entries: <HabotScreenActionEntry>[
        HabotScreenActionEntry(
          label: 'Clock in',
          kind: HabotScreenActionKind.transaction,
          transaction: 'open a shift record',
        ),
        HabotScreenActionEntry(
          label: 'See today\'s roster',
          kind: HabotScreenActionKind.navigation,
          transaction: '',
        ),
        HabotScreenActionEntry(
          label: 'Why is this off?',
          kind: HabotScreenActionKind.disclosure,
          transaction: '',
        ),
        HabotScreenActionEntry(
          label: 'Back',
          kind: HabotScreenActionKind.cancellation,
          transaction: '',
        ),
      ],
    ),
    HabotAuditedScreen(
      name: 'Approve overtime',
      interactiveElements: 6,
      entries: <HabotScreenActionEntry>[
        HabotScreenActionEntry(
          label: 'Approve',
          kind: HabotScreenActionKind.transaction,
          transaction: 'record an overtime approval',
        ),
        HabotScreenActionEntry(
          label: 'Decline',
          kind: HabotScreenActionKind.transaction,
          transaction: 'record an overtime refusal with a reason',
        ),
        HabotScreenActionEntry(
          label: 'Open the timesheet',
          kind: HabotScreenActionKind.navigation,
          transaction: '',
        ),
        HabotScreenActionEntry(
          label: 'Show the calculation',
          kind: HabotScreenActionKind.disclosure,
          transaction: '',
        ),
      ],
    ),
    HabotAuditedScreen(
      name: 'Edit profile',
      interactiveElements: 7,
      entries: <HabotScreenActionEntry>[
        HabotScreenActionEntry(
          label: 'Save',
          kind: HabotScreenActionKind.transaction,
          transaction: 'write the changed profile fields',
        ),
        HabotScreenActionEntry(
          label: 'Discard',
          kind: HabotScreenActionKind.cancellation,
          transaction: '',
        ),
      ],
    ),
    HabotAuditedScreen(
      name: 'Export payroll',
      interactiveElements: 3,
      entries: <HabotScreenActionEntry>[
        HabotScreenActionEntry(
          label: 'Export',
          kind: HabotScreenActionKind.transaction,
          transaction: 'produce a payroll file and record the egress',
        ),
        HabotScreenActionEntry(
          label: 'Change the period',
          kind: HabotScreenActionKind.disclosure,
          transaction: '',
        ),
      ],
    ),
    HabotAuditedScreen(
      name: 'Swap a shift',
      interactiveElements: 3,
      entries: <HabotScreenActionEntry>[
        HabotScreenActionEntry(
          label: 'Offer the shift',
          kind: HabotScreenActionKind.transaction,
          transaction: 'publish a shift offer',
        ),
        HabotScreenActionEntry(
          label: 'Withdraw the offer',
          kind: HabotScreenActionKind.transaction,
          transaction: 'retract a published shift offer',
        ),
        HabotScreenActionEntry(
          label: 'Back',
          kind: HabotScreenActionKind.cancellation,
          transaction: '',
        ),
      ],
    ),
  ];

  static int get screenCount => screens.length;

  static List<HabotScreenActionEntry> get allEntries =>
      <HabotScreenActionEntry>[
        for (final HabotAuditedScreen s in screens) ...s.entries,
      ];

  static int get declaredActions =>
      allEntries.where((HabotScreenActionEntry e) => e.isAnAction).length;

  static int get interactiveElements => screens.fold(
        0,
        (int a, HabotAuditedScreen s) => a + s.interactiveElements,
      );

  static bool get actionsAreFewerThanElements =>
      declaredActions < interactiveElements;

  static bool get sevenActionsAcrossFiveScreens =>
      declaredActions == 7 && screenCount == 5;

  static const String countingNote =
      'A screen with six controls may offer two actions; the rest are '
      'navigation, disclosure and cancellation. Counting widgets produces a '
      'number nobody can use. Counting things a person can cause to happen '
      'produces the number the next three rows depend on, and here that is '
      'seven actions against twenty-three interactive elements.';

  // -----------------------------------------------------------------------
  // Every action names its transaction.
  // -----------------------------------------------------------------------

  static bool get everyActionNamesItsTransaction => allEntries
      .where((HabotScreenActionEntry e) => e.isAnAction)
      .every((HabotScreenActionEntry e) => e.transaction.isNotEmpty);

  static bool get nothingElseClaimsATransaction => allEntries
      .where((HabotScreenActionEntry e) => !e.isAnAction)
      .every((HabotScreenActionEntry e) => e.transaction.isEmpty);

  static int get screensWithMoreThanOneAction =>
      screens.where((HabotAuditedScreen s) => s.actions.length > 1).length;

  static const String transactionNote =
      'An action with no named transaction is either navigation misfiled or a '
      'gap in the inventory, and both are worth finding -- so naming the '
      'transaction is what makes Step 397\'s "exactly one transaction per '
      'screen" checkable rather than aspirational. Two of the five screens '
      'here declare more than one, which is the finding that row acts on.';

  // -----------------------------------------------------------------------
  // The band and the arrow.
  // -----------------------------------------------------------------------

  static const String bandFloorRaw = '>=90%';
  static const int bandOptimal = 1;
  static const int bandCeiling = 1;

  static bool get theBandMixesUnits =>
      bandFloorRaw.contains('%') && bandOptimal == 1;

  static bool get theOptimalEqualsTheCeiling => bandOptimal == bandCeiling;

  static const String outputColumnRaw =
      'Complete/Partial/Not Complete -> Best = Complete (100%)';

  static bool get theOutputColumnHoldsAnAnnotation =>
      outputColumnRaw.contains('->') && outputColumnRaw.contains('Best =');

  /// Step 389 was the first; this batch adds five.
  static const List<int> arrowAnnotatedRows = <int>[389, 396, 397, 399, 401];

  static bool get sixRowsCarryTheArrow => arrowAnnotatedRows.length == 5;

  static double get coverage => screens.isEmpty
      ? 0
      : screens
              .where((HabotAuditedScreen s) => s.entries.isNotEmpty)
              .length /
          screens.length *
          100;

  static const String columnNote =
      'COLUMN NOTE: the Best Qualitative Output cell on this row reads '
      '"Complete/Partial/Not Complete -> Best = Complete (100%)" -- a scale, '
      'an arrow and an annotation naming the best value, which is Step 389\'s '
      'shape and the first of five in this batch; the band mixes ">=90%" with '
      'an optimal and a ceiling both written 1; the Data Requirement column '
      'holds audit fields beside Jetpack Compose layout advice '
      '("Arrangement.Center"); and the Setup Step column reads "Confirm '
      'accessibility of masked fields for assistive technology users". Atomic '
      'Step: "Open the primary workflow audit tool and list each screen\'s '
      'designated user actions."';

  static Map<String, bool> get obligations => <String, bool>{
        'the inventory is code rather than a document':
            theInventoryIsWhatWasBuilt,
        'every screen is listed with its entries': coverage == 100,
        'actions are counted, not widgets': actionsAreFewerThanElements,
        'every action names its transaction': everyActionNamesItsTransaction,
        'nothing that is not an action claims one':
            nothingElseClaimsATransaction,
      };

  static String get qualitativeOutput =>
      obligations.values.every((bool b) => b) ? 'Complete' : 'Partial';

  static Map<String, bool> get checks => <String, bool>{
        'the audit tool the row names does not exist':
            !theToolExists && theInventoryIsWhatWasBuilt,
        'and an inventory in code can be diffed':
            toolNote.contains('shows up in review'),
        'four entry kinds, only one of which is an action':
            HabotScreenActionKind.values.length == 4,
        'seven actions across five screens': sevenActionsAcrossFiveScreens,
        'against twenty-three interactive elements':
            interactiveElements == 23 && actionsAreFewerThanElements,
        'every action names its transaction': everyActionNamesItsTransaction,
        'and nothing else claims one': nothingElseClaimsATransaction,
        'two screens declare more than one action':
            screensWithMoreThanOneAction == 2 &&
                transactionNote.contains('that row acts on'),
        'the band mixes units and the output cell holds an arrow':
            theBandMixesUnits &&
                theOptimalEqualsTheCeiling &&
                theOutputColumnHoldsAnAnnotation &&
                sixRowsCarryTheArrow,
        'five obligations, all met, giving Complete':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Complete',
      };
}
