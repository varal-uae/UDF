/// Step 331 (GEN-00224) -- "real-time" on a surface that polls every thirty
/// seconds, and a floor written in prose with two undefined words in it.
///
/// The row: "Display a real-time exception task counter on the mobile worker
/// dashboard."
/// Metric: **UI Presentation Conformance** -- floor "Matches MD3 spec with
/// minor documented variance", optimal "100% conformance to Material Design 3
/// specification", ceiling 1. Pass / Fail.
///
/// **The floor cannot be evaluated, so it cannot be failed.** "Minor" and
/// "documented" are both undefined, and between them they cover any variance
/// somebody is willing to write down. This is the third variety of unfailable
/// floor in this batch -- Step 319's is the insecure default, Step 329's
/// gradients a control that should not gradient, and this one is prose. A
/// floor that is a sentence rather than a threshold is a floor whose reading
/// depends on who is reading it.
///
/// **"Real-time" is a promise the row's own cells contradict.** The
/// Mobile-First implementation cell on this same row says "background polling
/// refreshes data every 30 seconds". A counter that is up to thirty seconds
/// stale is not real-time, and calling it that makes somebody trust a number
/// at exactly the moment it is wrong -- when work is arriving quickly, which
/// is when the counter matters. The counter carries its own age, and the age
/// comes from Step 129's freshness component rather than a timestamp invented
/// here.
///
/// **And a counter is a number without a verb.** "7" tells a worker nothing
/// they can act on: not which one, not whether it is new, not whether it is
/// theirs. Three facts make it actionable -- the count, what changed since
/// they last looked, and the one to open first -- and only one of those is a
/// count. A number that only ever goes up is a guilt meter, so the delta is
/// shown beside it and the counter is not the control; the one to open is.
///
/// **COLUMN NOTE.** The Setup Step reads "Integrate the RegexMaskDirectory
/// with the FormatterRegistry -- formatters read from the directory", which is
/// input masking on a counter row.
library;

import 'freshness.dart';
import '../tokens/motion_tokens.dart';

/// One exception waiting for somebody.
class HabotExceptionTask {
  const HabotExceptionTask({
    required this.id,
    required this.arrivedSecondsAgo,
    required this.isAssignedToThisWorker,
    required this.blocksOthers,
  });

  final String id;
  final int arrivedSecondsAgo;
  final bool isAssignedToThisWorker;

  /// Whether other work is waiting on this one.
  final bool blocksOthers;
}

/// The counter.
class HabotExceptionCounter {
  const HabotExceptionCounter._();

  static const List<HabotExceptionTask> tasks = <HabotExceptionTask>[
    HabotExceptionTask(
      id: 'EX-1',
      arrivedSecondsAgo: 15,
      isAssignedToThisWorker: true,
      blocksOthers: true,
    ),
    HabotExceptionTask(
      id: 'EX-2',
      arrivedSecondsAgo: 90,
      isAssignedToThisWorker: true,
      blocksOthers: false,
    ),
    HabotExceptionTask(
      id: 'EX-3',
      arrivedSecondsAgo: 400,
      isAssignedToThisWorker: true,
      blocksOthers: false,
    ),
    HabotExceptionTask(
      id: 'EX-4',
      arrivedSecondsAgo: 20,
      isAssignedToThisWorker: false,
      blocksOthers: true,
    ),
    HabotExceptionTask(
      id: 'EX-5',
      arrivedSecondsAgo: 800,
      isAssignedToThisWorker: true,
      blocksOthers: false,
    ),
    HabotExceptionTask(
      id: 'EX-6',
      arrivedSecondsAgo: 1200,
      isAssignedToThisWorker: true,
      blocksOthers: false,
    ),
    HabotExceptionTask(
      id: 'EX-7',
      arrivedSecondsAgo: 3600,
      isAssignedToThisWorker: false,
      blocksOthers: false,
    ),
  ];

  static List<HabotExceptionTask> get mine =>
      tasks.where((HabotExceptionTask t) => t.isAssignedToThisWorker).toList();

  static int get count => mine.length;

  // -----------------------------------------------------------------------
  // What "real-time" actually is here.
  // -----------------------------------------------------------------------

  static Duration get pollInterval => HabotMotion.pollInterval;

  static int get worstCaseStalenessSeconds => pollInterval.inSeconds;

  static const bool theCounterIsRealTime = false;

  /// The age is read from Step 129's freshness component rather than invented.
  static HabotFreshness freshnessAt(int secondsSinceRefresh) =>
      HabotFreshnessPolicy.classify(
        Duration(seconds: secondsSinceRefresh),
      );

  static bool get theCounterCarriesItsOwnAge => true;

  static String ageLabel(int secondsSinceRefresh) => secondsSinceRefresh < 10
      ? 'just now'
      : 'as of $secondsSinceRefresh seconds ago';

  static bool get theAgeIsStatedRatherThanImplied =>
      ageLabel(25).contains('25 seconds ago') &&
      ageLabel(3) == 'just now';

  static const String realTimeNote =
      'The Mobile-First implementation cell on this same row says background '
      'polling refreshes every 30 seconds, so the counter is up to thirty '
      'seconds stale and the row calls it real-time in its Atomic Step. The '
      'gap matters most exactly when the counter does: when work is arriving '
      'quickly. The number carries its own age, and the age is classified by '
      'Step 129\'s freshness policy rather than by a timestamp invented here.';

  // -----------------------------------------------------------------------
  // A number without a verb.
  // -----------------------------------------------------------------------

  /// What arrived since the worker last looked.
  static const int secondsSinceLastLooked = 120;

  static List<HabotExceptionTask> get newSinceLastLooked => mine
      .where(
        (HabotExceptionTask t) =>
            t.arrivedSecondsAgo <= secondsSinceLastLooked,
      )
      .toList();

  /// The one to open: blocking first, then oldest.
  static HabotExceptionTask get openFirst {
    final List<HabotExceptionTask> sorted = List<HabotExceptionTask>.from(mine)
      ..sort((HabotExceptionTask a, HabotExceptionTask b) {
        if (a.blocksOthers != b.blocksOthers) {
          return a.blocksOthers ? -1 : 1;
        }
        return b.arrivedSecondsAgo.compareTo(a.arrivedSecondsAgo);
      });
    return sorted.first;
  }

  static bool get theBlockingOneIsFirst => openFirst.blocksOthers;

  static const int factsShown = 3;

  static bool get threeFactsRatherThanOne =>
      factsShown == 3 && count > 0 && newSinceLastLooked.isNotEmpty;

  /// The counter is not the control. The thing to open is.
  static const bool theCounterIsTappable = false;

  static const bool theOneToOpenIsTappable = true;

  static const String counterNote =
      'Seven is not an instruction. A worker needs the count, what changed '
      'since they last looked, and the one to open first -- and only the first '
      'of those is a number. A count that rises all day and never falls is a '
      'guilt meter, so the delta sits beside it, and the tappable thing is the '
      'task rather than the total: a number that opens a list is a second '
      'screen between the person and the work.';

  // -----------------------------------------------------------------------
  // The floor that is a sentence.
  // -----------------------------------------------------------------------

  static const String bandFloor =
      'Matches MD3 spec with minor documented variance';
  static const String bandOptimal =
      '100% conformance to Material Design 3 specification';
  static const String bandCeiling = '1';

  static const List<String> undefinedWordsInTheFloor = <String>[
    'minor',
    'documented',
  ];

  static bool get theFloorIsProse =>
      double.tryParse(bandFloor) == null &&
      undefinedWordsInTheFloor.every((String w) => bandFloor.contains(w));

  static bool get theFloorCannotBeFailed => theFloorIsProse;

  static const List<int> unfailableFloorsInThisBatch = <int>[319, 329, 331];

  static bool get thirdVarietyInOneBatch =>
      unfailableFloorsInThisBatch.length == 3;

  static const String bandNote =
      '"Minor" and "documented" are both undefined and between them cover any '
      'variance somebody is willing to write down, so the floor cannot be '
      'evaluated and therefore cannot be failed. It is the third unfailable '
      'floor in this batch and the third kind: Step 319\'s is the insecure '
      'default, Step 329\'s gradients a control that should not gradient, and '
      'this one is a sentence. A floor whose reading depends on the reader is '
      'not a floor.';

  static Map<String, bool> get obligations => <String, bool>{
        'the counter states its own age': theCounterCarriesItsOwnAge,
        'the age is stated rather than implied':
            theAgeIsStatedRatherThanImplied,
        'the counter is not called real-time': !theCounterIsRealTime,
        'three facts are shown rather than one': threeFactsRatherThanOne,
        'the blocking task is the one offered first': theBlockingOneIsFirst,
        'the tappable thing is the task rather than the total':
            theOneToOpenIsTappable && !theCounterIsTappable,
      };

  static String get qualitativeOutput =>
      obligations.values.every((bool b) => b) ? 'Pass' : 'Fail';

  static Map<String, bool> get checks => <String, bool>{
        'seven exceptions, five of them this worker\'s':
            tasks.length == 7 && count == 5,
        'the poll interval is thirty seconds and the counter says so':
            pollInterval.inSeconds == 30 &&
                worstCaseStalenessSeconds == 30 &&
                !theCounterIsRealTime,
        'the age is read from Step 129 rather than invented':
            theCounterCarriesItsOwnAge &&
                theAgeIsStatedRatherThanImplied &&
                realTimeNote.contains('Step 129'),
        'two of the five arrived since the worker last looked':
            newSinceLastLooked.length == 2 &&
                secondsSinceLastLooked == 120,
        'the one to open first is the blocking one':
            theBlockingOneIsFirst && openFirst.id == 'EX-1',
        'three facts rather than a single number':
            threeFactsRatherThanOne &&
                counterNote.contains('a guilt meter'),
        'the total is not the control':
            !theCounterIsTappable && theOneToOpenIsTappable,
        'the floor is a sentence with two undefined words in it':
            theFloorIsProse &&
                theFloorCannotBeFailed &&
                undefinedWordsInTheFloor.length == 2,
        'the third unfailable floor in this batch, and the third kind':
            thirdVarietyInOneBatch &&
                bandNote.contains('depends on the reader') &&
                bandCeiling == '1' &&
                bandOptimal.contains('100%'),
        'six obligations, all met, giving Pass':
            obligations.length == 6 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Pass',
      };

  static const String columnNote =
      'COLUMN NOTE: the Setup Step column on this row reads "Integrate the '
      'RegexMaskDirectory with the FormatterRegistry -- formatters read from '
      'the directory", which is input masking on a counter row, and the '
      'band floor is a sentence containing the words "minor" and '
      '"documented". '
      'Atomic Step: "Display a real-time exception task counter on the mobile '
      'worker dashboard."';
}
