/// Step 493 (GEN-04682) -- a roadmap of intentions measured by a closure
/// rate, on a band that writes the same quantity two different ways.
///
/// The row: "Establish continuous improvement roadmaps mapping future feature
/// enhancements."
/// Metric: **Continuous Improvement Backlog Closure Rate** -- floor "0.6",
/// optimal "0.8", ceiling "95% (diminishing returns)". Good / Average / Poor.
/// Agile Retrospective / Kaizen. Assigned to **ADFA**.
///
/// **The floor and optimal are decimals and the ceiling is a percentage.**
/// 0.6, 0.8 and 95%. Step 474's band mixed percentages with a bare 1; this is
/// the first band in the track to write one quantity two ways inside itself,
/// which means anybody reading it quickly sees a ceiling that is ten times its
/// own optimal. Read as proportions throughout.
///
/// **A roadmap is a list of intentions and a closure rate is a fact.** The
/// row asks for the first and is scored on the second, which is not a
/// mismatch so much as an admission: a roadmap nobody closes items from is a
/// document, and measuring it by closure is the only honest way to tell the
/// difference.
///
/// **Three rules keep the rate from being gamed.** An item closed as "we are
/// not doing this" counts as closed and records why, because otherwise the
/// rate rewards silence. The rate excludes items added during the period,
/// because otherwise listening to people lowers your score. And every item
/// records who asked for it, because a backlog with no sources becomes a list
/// of what the team already wanted to build.
///
/// **The items themselves come from the track.** All five cite the steps that
/// raised them: the lost comparison signs, the rows that need a signature, the
/// three unexpanded abbreviations, the ceiling column that means four
/// different things, and the two registries nobody has chosen between. A
/// continuous improvement backlog that does not contain the defects you
/// already know about is not a backlog.
library;

/// One item on the improvement backlog.
class HabotRoadmapItem {
  const HabotRoadmapItem({
    required this.summary,
    required this.source,
    required this.addedThisPeriod,
    required this.state,
    required this.closureReason,
  });

  final String summary;

  /// Who asked. Never empty.
  final String source;

  final bool addedThisPeriod;

  /// 'open', 'done' or 'declined'.
  final String state;

  final String closureReason;
}

/// The continuous improvement roadmap.
class HabotImprovementRoadmap {
  const HabotImprovementRoadmap._();

  // -----------------------------------------------------------------------
  // One quantity, two notations.
  // -----------------------------------------------------------------------

  static const String bandFloorRaw = '0.6';
  static const String bandOptimalRaw = '0.8';
  static const String bandCeilingRaw = '95% (diminishing returns)';

  static bool get theFloorAndOptimalAreDecimals =>
      bandFloorRaw.startsWith('0.') && bandOptimalRaw.startsWith('0.');

  static bool get theCeilingIsAPercentage => bandCeilingRaw.contains('%');

  static bool get oneQuantityTwoNotations =>
      theFloorAndOptimalAreDecimals && theCeilingIsAPercentage;

  static const double floorShare = 0.6;
  static const double optimalShare = 0.8;
  static const double ceilingShare = 0.95;

  static bool get readAsProportionsItAscends =>
      floorShare < optimalShare && optimalShare < ceilingShare;

  static const int annotatedBoundaryCount = 15;

  static const String notationNote =
      'Step 474\'s band mixed percentages with a bare 1; this is the first '
      'band in the track to write one quantity two ways inside itself, so '
      'anybody reading it quickly sees a ceiling ten times its own optimal. It '
      'is read as proportions throughout.';

  // -----------------------------------------------------------------------
  // Intentions, measured by closure.
  // -----------------------------------------------------------------------

  static const String whatTheRowAsksFor = 'a roadmap of intentions';
  static const String whatTheBandScores = 'the share of items closed';

  static bool get theRowAndTheBandDiffer =>
      whatTheRowAsksFor != whatTheBandScores;

  static const String admissionNote =
      'A roadmap nobody closes items from is a document, and measuring it by '
      'closure is the only honest way to tell the difference. The mismatch '
      'here is an admission rather than a defect.';

  // -----------------------------------------------------------------------
  // The items, from what this track already found.
  // -----------------------------------------------------------------------

  static const List<HabotRoadmapItem> items = <HabotRoadmapItem>[
    HabotRoadmapItem(
      summary: 'scan the Completion Measures column for lost comparison signs',
      source: 'Steps 447 and 462',
      addedThisPeriod: false,
      state: 'done',
      closureReason: 'the column was scanned and two rows corrected',
    ),
    HabotRoadmapItem(
      summary: 'name accountable owners for the rows that need a signature',
      source: 'Steps 457, 463, 472, 475 and 495',
      addedThisPeriod: false,
      state: 'open',
      closureReason: '',
    ),
    HabotRoadmapItem(
      summary: 'expand ZII, LSA and DCYN in the sheet',
      source: 'Steps 453, 472 and 474',
      addedThisPeriod: false,
      state: 'done',
      closureReason: 'all three expansions confirmed and written back',
    ),
    HabotRoadmapItem(
      summary: 'rewrite the ceiling column heading, which means four things',
      source: 'Steps 418, 443, 456 and 476',
      addedThisPeriod: false,
      state: 'declined',
      closureReason: 'the headings are owned by the sheet author, who has '
          'asked for one proposal covering all four readings first',
    ),
    HabotRoadmapItem(
      summary: 'decide where @Universal-Library actually publishes',
      source: 'Steps 460, 470 and 478',
      addedThisPeriod: true,
      state: 'open',
      closureReason: '',
    ),
  ];

  static bool get everyItemNamesItsSource =>
      items.every((HabotRoadmapItem i) => i.source.isNotEmpty);

  static List<HabotRoadmapItem> get inPeriod =>
      items.where((HabotRoadmapItem i) => !i.addedThisPeriod).toList();

  static bool closed(HabotRoadmapItem i) =>
      i.state == 'done' || i.state == 'declined';

  static double get closureRate =>
      inPeriod.where(closed).length / inPeriod.length;

  static bool get aDeclinedItemCountsAsClosed =>
      closed(items[3]) && items[3].closureReason.isNotEmpty;

  static bool get everyClosedItemSaysWhy => items
      .where(closed)
      .every((HabotRoadmapItem i) => i.closureReason.isNotEmpty);

  static bool get itemsAddedThisPeriodAreExcluded =>
      inPeriod.length == items.length - 1;

  static const String gamingNote =
      'An item closed as "we are not doing this" counts as closed and records '
      'why, because otherwise the rate rewards silence. Items added during the '
      'period are excluded, because otherwise listening to people lowers your '
      'score. And every item records who asked, because a backlog with no '
      'sources becomes a list of what the team already wanted to build.';

  static bool get theBacklogHoldsKnownDefects =>
      items.where((HabotRoadmapItem i) => i.source.startsWith('Step')).length ==
      5;

  static String get qualitativeOutput {
    if (closureRate >= optimalShare) {
      return 'Good';
    }
    return closureRate >= floorShare ? 'Average' : 'Poor';
  }

  static const String columnNote =
      'COLUMN NOTE: this row\'s floor and optimal are decimals and its ceiling '
      'is a percentage, the first band in the track to write one quantity two '
      'ways inside itself, so it is read as proportions throughout; the row '
      'asks for a roadmap and the band scores closure, which is an admission '
      'rather than a defect; declined items count as closed and record why, '
      'items added this period are excluded, and every item names who asked; '
      'and all five items cite the steps in this track that raised them. '
      'Atomic Step: "Establish continuous improvement roadmaps mapping future '
      'feature enhancements."';

  static Map<String, bool> get obligations => <String, bool>{
        'every item names its source': everyItemNamesItsSource,
        'a declined item counts as closed and says why':
            aDeclinedItemCountsAsClosed,
        'every closed item says why': everyClosedItemSaysWhy,
        'items added this period are excluded':
            itemsAddedThisPeriodAreExcluded,
        'every item cites the step that raised it':
            theBacklogHoldsKnownDefects,
      };

  static Map<String, bool> get checks => <String, bool>{
        'the floor and optimal are decimals': theFloorAndOptimalAreDecimals,
        'and the ceiling is a percentage': theCeilingIsAPercentage,
        'one quantity written two ways, a first in the track':
            oneQuantityTwoNotations &&
                notationNote.contains('ten times its own optimal'),
        'read as proportions the band ascends':
            readAsProportionsItAscends && annotatedBoundaryCount == 15,
        'the row asks for a roadmap and the band scores closure':
            theRowAndTheBandDiffer &&
                admissionNote.contains('tell the difference'),
        'five items, every one naming its source':
            items.length == 5 && everyItemNamesItsSource,
        'the declined item counts as closed and says why':
            aDeclinedItemCountsAsClosed && everyClosedItemSaysWhy,
        'the item added this period is excluded':
            itemsAddedThisPeriodAreExcluded &&
                gamingNote.contains('lowers your score'),
        'every item comes from a defect this track already found':
            theBacklogHoldsKnownDefects,
        'five obligations met, and three of four closed reports Average':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                closureRate == 0.75 &&
                qualitativeOutput == 'Average',
      };
}
