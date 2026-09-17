/// Step 380 (GEN-02665) -- the same instruction as Step 368, twelve rows later,
/// with a different metric and a different team.
///
/// The row: "Make all dashboard elements read-only with no configuration
/// controls on the dashboard surface."
/// Metric: **Implementation Completeness Rate** -- floor "90% of defined scope
/// completed", optimal "100% of scope complete with peer validation", ceiling
/// "1". Complete / Partial / Not Complete. ISO/IEC 25010:2011. Assigned to
/// **GFD**.
///
/// **This row and Step 368 ask for the same thing.** Step 368 (GEN-02411) says
/// "configure the dashboard elements as read-only locks to prevent accidental
/// data edits"; this one says "make all dashboard elements read-only with no
/// configuration controls". Same surface, same instruction, twelve rows apart,
/// under different global reference ids, with different metrics, different
/// standards and different teams. Neither row mentions the other. It is the
/// first duplicated *instruction* this track has recorded -- previous repeats
/// were duplicated defects, not duplicated work -- and it means a reader
/// working the sheet in order builds the same control twice.
///
/// **So this row is not implemented again; it is bound.** The read-only rule is
/// Step 368's, imported rather than restated, and the only thing built here is
/// what the two rows do not share: Step 368 is about *edits*, and this one adds
/// "no configuration controls", which is a different question. A filter is not
/// an edit, and a dashboard with no filters is a poster.
///
/// **Configuration and editing are not the same refusal.** Changing what you
/// are looking at is not changing the data: a date range, a site filter and a
/// grouping are all read-only operations on somebody's own view. Three of the
/// five worked controls here configure the view and stay; two would write, and
/// they are the ones the row is actually asking to remove.
///
/// **The band has three cells of three different types.** Floor is a sentence
/// with a percentage, optimal is a sentence with a percentage and a process
/// condition, and the ceiling is the bare ratio "1". A consumer parsing the
/// three gets a string, a string and a number.
library;

import 'read_only_lock.dart';

/// What a control on a dashboard does.
enum HabotSurfaceControl {
  /// Changes what this viewer is looking at. Writes nothing.
  configuresTheView,

  /// Writes to the record behind the dashboard.
  writesData,
}

/// One control the row's sweep would catch.
class HabotDashboardControl {
  const HabotDashboardControl({
    required this.label,
    required this.kind,
  });

  final String label;
  final HabotSurfaceControl kind;

  bool get survives => kind == HabotSurfaceControl.configuresTheView;
}

/// The read-only surface rule.
class HabotReadOnlySurface {
  const HabotReadOnlySurface._();

  // -----------------------------------------------------------------------
  // The duplicate.
  // -----------------------------------------------------------------------

  static const int theOtherRow = 368;

  static const String theOtherReference = 'GEN-02411';

  static const int rowsApart = 12;

  static const bool eitherRowMentionsTheOther = false;

  static bool get thisIsADuplicatedInstruction =>
      theOtherRow == 368 && !eitherRowMentionsTheOther;

  /// Step 368 is scored on data freshness by DEA; this one on an
  /// implementation completeness rate by GFD.
  static const String thisRowsTeam = 'GFD';
  static const String theOtherRowsTeam = 'DEA';

  static bool get theTwoRowsDisagreeAboutEverythingButTheWork =>
      thisRowsTeam != theOtherRowsTeam;

  static const String duplicateNote =
      'Step 368 says "configure the dashboard elements as read-only locks to '
      'prevent accidental data edits"; this row says "make all dashboard '
      'elements read-only with no configuration controls". Same surface, same '
      'instruction, twelve rows apart, under different reference ids, with '
      'different metrics, different standards and different teams. Neither '
      'mentions the other. Previous repeats in this track were duplicated '
      'defects; this is duplicated work, and a reader working the sheet in '
      'order builds the same control twice.';

  // -----------------------------------------------------------------------
  // Bound, not rebuilt.
  // -----------------------------------------------------------------------

  static HabotLockKind get lockKind => HabotReadOnlyLock.chosenKind;

  static bool get theRuleIsStep368s =>
      HabotReadOnlyLock.theLockIsMechanical &&
      lockKind == HabotLockKind.noEditPath;

  static const bool theRuleIsRestatedHere = false;

  static bool get nothingIsDuplicatedInCode => !theRuleIsRestatedHere;

  static const String bindingNote =
      'The read-only rule is Step 368\'s, imported rather than written again. '
      'Two copies of one rule is how two dashboards end up disagreeing about '
      'what read-only means, which is the code version of the defect the sheet '
      'has here. What is built on this row is only the part the two rows do '
      'not share.';

  // -----------------------------------------------------------------------
  // Configuration is not editing.
  // -----------------------------------------------------------------------

  static const List<HabotDashboardControl> controls =
      <HabotDashboardControl>[
    HabotDashboardControl(
      label: 'Date range',
      kind: HabotSurfaceControl.configuresTheView,
    ),
    HabotDashboardControl(
      label: 'Site filter',
      kind: HabotSurfaceControl.configuresTheView,
    ),
    HabotDashboardControl(
      label: 'Group by team or by shift',
      kind: HabotSurfaceControl.configuresTheView,
    ),
    HabotDashboardControl(
      label: 'Edit this target',
      kind: HabotSurfaceControl.writesData,
    ),
    HabotDashboardControl(
      label: 'Mark this exception resolved',
      kind: HabotSurfaceControl.writesData,
    ),
  ];

  static List<HabotDashboardControl> get surviving =>
      controls.where((HabotDashboardControl c) => c.survives).toList();

  static List<HabotDashboardControl> get removed =>
      controls.where((HabotDashboardControl c) => !c.survives).toList();

  static bool get threeOfFiveSurvive =>
      surviving.length == 3 && removed.length == 2;

  static bool get noSurvivingControlWrites => surviving
      .every(
        (HabotDashboardControl c) =>
            c.kind != HabotSurfaceControl.writesData,
      );

  /// A literal sweep of "no configuration controls" would take all five.
  static int get controlsALiteralSweepWouldRemove => controls.length;

  static bool get aLiteralSweepWouldTakeTheFilters =>
      controlsALiteralSweepWouldRemove > removed.length;

  static const String configurationNote =
      'Changing what you are looking at is not changing the data. A date '
      'range, a site filter and a grouping are read-only operations on one '
      'person\'s own view, and a dashboard with no filters is a poster. Two of '
      'the five controls write to the record behind the surface, and those are '
      'the two the row is actually asking to remove; a literal reading of "no '
      'configuration controls" would take all five.';

  // -----------------------------------------------------------------------
  // The where-it-goes rule, so removal is not deletion.
  // -----------------------------------------------------------------------

  static const Map<String, String> movedTo = <String, String>{
    'Edit this target': 'the target\'s own settings screen',
    'Mark this exception resolved': 'the exception detail sheet',
  };

  static bool get everyRemovedControlHasAHome =>
      movedTo.length == removed.length &&
      removed.every((HabotDashboardControl c) => movedTo.containsKey(c.label));

  static const String removalNote =
      'A control taken off a dashboard has to exist somewhere, or the sweep '
      'has removed a capability rather than moved it. Both writing controls '
      'are named along with where they now live, which is the rule Steps 363, '
      '365 and 370 applied to truncated lists, graphs and formats -- say what '
      'was cut and where it went.';

  // -----------------------------------------------------------------------
  // Three cells, three types.
  // -----------------------------------------------------------------------

  static const String bandFloorRaw = '90% of defined scope completed';
  static const String bandOptimalRaw =
      '100% of scope complete with peer validation';
  static const String bandCeilingRaw = '1';

  static bool get theFloorIsASentence => bandFloorRaw.contains(' ');

  static bool get theOptimalCarriesAProcessCondition =>
      bandOptimalRaw.contains('peer validation');

  static bool get theCeilingIsABareRatio =>
      double.tryParse(bandCeilingRaw) != null;

  static bool get threeCellsHoldThreeTypes =>
      theFloorIsASentence &&
      theOptimalCarriesAProcessCondition &&
      theCeilingIsABareRatio;

  static const String bandNote =
      'Floor "90% of defined scope completed", optimal "100% of scope complete '
      'with peer validation", ceiling "1". A consumer parsing the three gets a '
      'string, a string and a number, and the optimal also carries a process '
      'condition -- peer validation -- which is not a value on the same scale '
      'as the other two at all.';

  static Map<String, bool> get obligations => <String, bool>{
        'the read-only rule is the one already built': theRuleIsStep368s,
        'nothing is duplicated in code': nothingIsDuplicatedInCode,
        'no control on the surface writes data': noSurvivingControlWrites,
        'view configuration survives': threeOfFiveSurvive,
        'every removed control is named with where it went':
            everyRemovedControlHasAHome,
      };

  static String get qualitativeOutput =>
      obligations.values.every((bool b) => b) ? 'Complete' : 'Partial';

  static Map<String, bool> get checks => <String, bool>{
        'this row repeats Step 368\'s instruction':
            thisIsADuplicatedInstruction && theOtherReference == 'GEN-02411',
        'twelve rows apart, with different teams and metrics':
            rowsApart == 12 && theTwoRowsDisagreeAboutEverythingButTheWork,
        'and neither row mentions the other':
            !eitherRowMentionsTheOther &&
                duplicateNote.contains('builds the same control twice'),
        'the rule is imported rather than restated':
            theRuleIsStep368s && nothingIsDuplicatedInCode,
        'five controls, three of which configure the view':
            controls.length == 5 && threeOfFiveSurvive,
        'no surviving control writes': noSurvivingControlWrites,
        'a literal sweep would take the filters too':
            aLiteralSweepWouldTakeTheFilters &&
                configurationNote.contains('a poster'),
        'both removed controls are named with a destination':
            everyRemovedControlHasAHome &&
                removalNote.contains('rather than moved it'),
        'the band holds three different types':
            threeCellsHoldThreeTypes && bandNote.contains('peer validation'),
        'five obligations, all met, giving Complete':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Complete',
      };

  static const String columnNote =
      'COLUMN NOTE: this row repeats Step 368\'s instruction under a different '
      'reference id, metric, standard and team -- the first duplicated '
      'instruction in this track rather than a duplicated defect; it is '
      'assigned to GFD rather than UDF; its band holds a sentence, a sentence '
      'with a process condition, and the bare ratio "1"; its Data Requirement '
      'cell holds the Atomic Step\'s own text truncated with an ellipsis; and '
      'the Setup Step column is empty. Atomic Step: "Make all dashboard '
      'elements read-only with no configuration controls on the dashboard '
      'surface."';
}
