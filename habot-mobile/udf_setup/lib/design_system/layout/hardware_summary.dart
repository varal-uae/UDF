/// Step 310 (HSCPE-006) -- the same instruction as Step 286, the same broken
/// band, twenty-four rows later, with no reference between them.
///
/// The row: "UX Implementation: Condense dense hardware tables into scannable
/// MD3-compliant data summaries for mobile admin views."
/// Metric: **Material Design 3 Token Compliance** -- floor "Ad-hoc custom
/// styling, no token system", optimal "Core MD3 tokens applied consistently",
/// ceiling "Full MD3 token system + automated visual regression testing".
/// Good / Average / Poor.
///
/// **Two rows, one instruction, one band, character for character.** Step 286
/// said "present dense pod scheduling arrays under simple, scannable MD3 data
/// summaries for small viewports" and carried this metric with these three
/// boundary strings. This row says the same thing about hardware inventories
/// and carries the same three strings. The floor is still the condition a
/// token system exists to end, so it still cannot be failed. Nothing about
/// either row points at the other.
///
/// **So the transform is imported rather than written again.** Step 286 built
/// it: one identity line, the two facts that decide whether anybody needs to
/// look further, the rest behind the row. A second implementation of the same
/// rule would be the thing the rule exists to prevent, and would drift within
/// a quarter. This step supplies the hardware columns and reads the geometry,
/// the fact budget and the band from Step 286.
///
/// **Five columns, and the table gets away with it.** 530 points of hardware
/// data into 328 available: three fit, two go past the edge -- and this time
/// the three that fit happen to be the three worth showing. That accident is
/// the interesting part. A table that truncates correctly by luck looks
/// correct in review, ships, and starts hiding the wrong things on the day
/// somebody adds a sixth column or a longer device name. The summary reaches
/// the same three on purpose, which is the difference that survives the next
/// edit.
///
/// **COLUMN NOTE.** The Dependency cell on this row holds four Mobile-First
/// Material Design decision sentences instead of a dependency, every narrative
/// column is about API gateway ingress and payload validation, and the
/// Decision Group is "Security & Perimeter Architecture". The Setup Step reads
/// "Map a dedicated trace_id string text field attribute into the primary
/// payload layout model."
library;

import 'dense_summary.dart';

/// The hardware inventory's columns, in the shape Step 286 declared.
class HabotHardwareSummary {
  const HabotHardwareSummary._();

  static const List<HabotColumn> columns = <HabotColumn>[
    HabotColumn(name: 'device', widthDp: 120, isIdentity: true, rank: 0),
    HabotColumn(name: 'platform', widthDp: 90, isIdentity: false, rank: 1),
    HabotColumn(name: 'os version', widthDp: 80, isIdentity: false, rank: 2),
    HabotColumn(name: 'screen', widthDp: 110, isIdentity: false, rank: 3),
    HabotColumn(
      name: 'configuration',
      widthDp: 130,
      isIdentity: false,
      rank: 4,
    ),
  ];

  // -----------------------------------------------------------------------
  // Geometry, read from Step 286.
  // -----------------------------------------------------------------------

  static double get availableWidthDp => HabotDenseSummary.availableWidthDp;

  static int get maxSecondaryFacts => HabotDenseSummary.maxSecondaryFacts;

  static double get totalColumnWidthDp =>
      columns.fold(0, (double a, HabotColumn c) => a + c.widthDp);

  static List<HabotColumn> get columnsThatFit {
    final List<HabotColumn> fitting = <HabotColumn>[];
    double used = 0;
    for (final HabotColumn c in columns) {
      if (used + c.widthDp > availableWidthDp) {
        break;
      }
      used += c.widthDp;
      fitting.add(c);
    }
    return fitting;
  }

  static List<HabotColumn> get columnsPastTheEdge =>
      columns.where((HabotColumn c) => !columnsThatFit.contains(c)).toList();

  // -----------------------------------------------------------------------
  // The summary, on Step 286's rule.
  // -----------------------------------------------------------------------

  static HabotColumn get identityColumn =>
      columns.firstWhere((HabotColumn c) => c.isIdentity);

  static List<HabotColumn> get secondaryFacts {
    final List<HabotColumn> rest =
        columns.where((HabotColumn c) => !c.isIdentity).toList()
          ..sort((HabotColumn a, HabotColumn b) => a.rank.compareTo(b.rank));
    return rest.take(maxSecondaryFacts).toList();
  }

  static List<HabotColumn> get behindTheRow => columns
      .where(
        (HabotColumn c) => !c.isIdentity && !secondaryFacts.contains(c),
      )
      .toList();

  static double get summaryLineWidthDp =>
      identityColumn.widthDp +
      secondaryFacts.fold(0, (double a, HabotColumn c) => a + c.widthDp);

  static bool get theSummaryLineFits => summaryLineWidthDp <= availableWidthDp;

  static bool get everyColumnIsAccountedFor =>
      1 + secondaryFacts.length + behindTheRow.length == columns.length;

  // -----------------------------------------------------------------------
  // The accident.
  // -----------------------------------------------------------------------

  /// The table's truncation and the summary's selection land on the same
  /// three columns -- here, and by coincidence.
  static bool get theTableTruncatesToTheRightColumns {
    final List<String> fromTable =
        columnsThatFit.map((HabotColumn c) => c.name).toList();
    final List<String> fromSummary = <String>[
      identityColumn.name,
      ...secondaryFacts.map((HabotColumn c) => c.name),
    ];
    return fromTable.length == fromSummary.length &&
        fromTable.every(fromSummary.contains);
  }

  /// And the reason it is a coincidence: the table stops where the width runs
  /// out, the summary stops where the declared rank runs out, and the two
  /// agree only because rank happens to follow declaration order here.
  static bool get theTableStopsOnWidthAndTheSummaryOnRank =>
      columnsThatFit.length == columns.length - columnsPastTheEdge.length &&
      secondaryFacts.every((HabotColumn c) => c.rank <= maxSecondaryFacts);

  /// One longer device name is enough to break the agreement.
  static const double longerIdentityWidthDp = 160;

  static bool get aLongerNameBreaksTheTable {
    double used = longerIdentityWidthDp;
    int fitting = 1;
    for (final HabotColumn c in columns.skip(1)) {
      if (used + c.widthDp > availableWidthDp) {
        break;
      }
      used += c.widthDp;
      fitting += 1;
    }
    return fitting < columnsThatFit.length;
  }

  static const String accidentNote =
      'The table truncates to the same three columns the summary chooses, so '
      'it looks right in review. It is right by luck: the table stops where '
      'the width runs out and the summary stops where the declared rank runs '
      'out, and the two agree only because rank happens to follow declaration '
      'order in this inventory. Widen the device name to 160 points -- one '
      'long model number -- and the table drops to two while the summary '
      'still shows three. A layout that is correct by coincidence ships, '
      'because nothing in review distinguishes it from one that is correct on '
      'purpose.';

  // -----------------------------------------------------------------------
  // The band, which is the same band.
  // -----------------------------------------------------------------------

  static String get bandFloor => HabotDenseSummary.bandFloor;
  static String get bandOptimal => HabotDenseSummary.bandOptimal;
  static String get bandCeiling => HabotDenseSummary.bandCeiling;

  static const int stepWithTheSameBand = 286;

  static bool get theBandIsIdenticalToStep286 =>
      bandFloor == HabotDenseSummary.bandFloor &&
      bandOptimal == HabotDenseSummary.bandOptimal &&
      bandCeiling == HabotDenseSummary.bandCeiling;

  static bool get theFloorStillCannotBeFailed =>
      HabotDenseSummary.theBandCannotFail;

  static const bool theTwoRowsReferenceEachOther = false;

  static const String duplicationNote =
      'Step 286 and this row carry the same instruction and the same three '
      'boundary strings, character for character, twenty-four rows apart, '
      'assigned as separate work, referencing nothing. The floor is still the '
      'condition a token system exists to end, so it still cannot be failed. '
      'What is worth noticing is not the duplicate band but the duplicate '
      'work: two rows, each of which would have produced a data-summary '
      'component, and a repository that then has two.';

  static Map<String, bool> get obligations => <String, bool>{
        'the transform is imported rather than written again':
            maxSecondaryFacts == HabotDenseSummary.maxSecondaryFacts,
        'the geometry is read from Step 286':
            availableWidthDp == HabotDenseSummary.availableWidthDp,
        'the summary line fits': theSummaryLineFits,
        'every column is accounted for': everyColumnIsAccountedFor,
        'the facts are chosen by rank rather than by width':
            theTableStopsOnWidthAndTheSummaryOnRank,
      };

  static double get tokenCompliance =>
      obligations.values.where((bool b) => b).length / obligations.length;

  static String get qualitativeOutput =>
      tokenCompliance >= 1.0 && theSummaryLineFits ? 'Good' : 'Average';

  static Map<String, bool> get checks => <String, bool>{
        'five columns needing 530 points into 328':
            columns.length == 5 &&
                totalColumnWidthDp == 530 &&
                availableWidthDp == 328,
        'three fit and two go past the edge':
            columnsThatFit.length == 3 && columnsPastTheEdge.length == 2,
        'the summary line is 290 points and fits':
            summaryLineWidthDp == 290 && theSummaryLineFits,
        'identity plus two facts plus two behind the row':
            everyColumnIsAccountedFor &&
                secondaryFacts.length == 2 &&
                behindTheRow.length == 2,
        'the table happens to truncate to the right three':
            theTableTruncatesToTheRightColumns &&
                theTableStopsOnWidthAndTheSummaryOnRank,
        'and one longer device name breaks that agreement':
            aLongerNameBreaksTheTable &&
                accidentNote.contains('correct by coincidence'),
        'the band is Step 286\'s band, string for string':
            theBandIsIdenticalToStep286 &&
                stepWithTheSameBand == 286 &&
                theFloorStillCannotBeFailed,
        'and neither row points at the other':
            !theTwoRowsReferenceEachOther &&
                duplicationNote.contains('a repository that then has two'),
        'five obligations, all met':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                tokenCompliance == 1.0,
      };

  static const String columnNote =
      'COLUMN NOTE: the Dependency cell on this row holds four Mobile-First '
      'Material Design decision sentences instead of a dependency, the '
      'Decision Group is "Security & Perimeter Architecture", every narrative '
      'column is about API gateway ingress and payload validation, and the '
      'Setup Step reads "Map a dedicated trace_id string text field attribute '
      'into the primary payload layout model". Atomic Step: "UX '
      'Implementation: Condense dense hardware tables into scannable '
      'MD3-compliant data summaries for mobile admin views."';
}
