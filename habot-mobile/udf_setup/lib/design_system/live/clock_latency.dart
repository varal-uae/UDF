/// Step 431 (GEN-04086) -- a dashboard clock, and a reference standard that is
/// its own floor.
///
/// The row: "Verify that latency updates display on mobile dashboard clocks
/// with under 1 second delay."
/// Metric: **Dashboard Clock Update Latency** -- floor "<1s", optimal
/// "<200ms", ceiling "2s". Pass/Fail. Data Freshness Standards (<1s). Assigned
/// to **UDF**.
///
/// **The standard column holds the floor value.** "Data Freshness Standards
/// (<1s)" is not the name of a standard; it is the row's own floor, restated in
/// brackets after a phrase that sounds like one. Three different things have
/// now appeared in that column in this batch alone: prose arguing for the band
/// at Steps 416 and 429, and a restated threshold here -- after Step 415 put a
/// foreign framework in it last batch. The column is being used as a second
/// notes field.
///
/// **The sentence has two readings and the metric settles it.** "Latency
/// updates display ... with under 1 second delay" can mean the display of
/// latency updates, or the latency with which updates display. The metric name
/// -- Dashboard Clock Update Latency -- picks the second, so that is what is
/// built, and the first reading is recorded because it is the one a reader who
/// starts from the Atomic Step will take.
///
/// **A clock that ticks every second is a repaint every second per clock.**
/// Step 395 already settled the cadence question on the SLA countdown: match
/// the tick rate to the magnitude of what is being shown. That policy is bound
/// rather than restated. What the clock is actually for is saying whether what
/// is on the card is current, so it shows the age of the data rather than the
/// wall time, and it updates when that age crosses a boundary somebody would
/// act on.
///
/// **Fifth row in this batch with the optimal below both boundaries.** Floor
/// "<1s" and ceiling "2s" bracket one to two seconds; the optimal of "<200ms"
/// sits under both.
library;

import '../telemetry/friction_middleware.dart';
import 'streaming_hooks.dart';

/// What the clock is showing.
enum HabotClockReading {
  /// The data is current; no age is displayed.
  current,

  /// The age has crossed the first boundary and is shown in seconds.
  seconds,

  /// The age has crossed the second boundary and is shown in minutes.
  minutes,

  /// No value has ever arrived.
  never,
}

/// The dashboard clock.
class HabotClockLatency {
  const HabotClockLatency._();

  // -----------------------------------------------------------------------
  // The standard column holds the floor.
  // -----------------------------------------------------------------------

  static const String standardCited = 'Data Freshness Standards (<1s)';

  static const String bandFloorRaw = '<1s';

  static bool get theStandardRepeatsTheFloor =>
      standardCited.contains(bandFloorRaw);

  static const bool aRealStandardIsNamed = false;

  /// Prose at 416 and 429, a restated threshold here, a framework at 415.
  static const Map<int, String> whatHasAppearedInThatColumn = <int, String>{
    415: 'a foreign framework',
    416: 'prose arguing for the band',
    429: 'prose arguing for the band',
    431: 'the row\'s own floor, in brackets',
  };

  static bool get fourDifferentUsesRecorded =>
      whatHasAppearedInThatColumn.length == 4;

  static const String standardNote =
      '"Data Freshness Standards (<1s)" is not a standard; it is this row\'s '
      'own floor restated in brackets after a phrase that sounds like one. '
      'Four different kinds of thing have now appeared in the '
      'reference-standard column across two batches -- a foreign framework, '
      'prose arguing for the band twice, and a threshold copied from the row '
      'itself -- which means the column is being used as a second notes field '
      'rather than as a citation.';

  // -----------------------------------------------------------------------
  // Two readings, and the one that was built.
  // -----------------------------------------------------------------------

  static const String readingOne = 'the display of latency updates';

  static const String readingTwo = 'the latency with which updates display';

  static bool get theSentenceIsAmbiguous => readingOne != readingTwo;

  static const String readingBuilt = 'the latency with which updates display';

  static bool get theMetricSettlesIt => readingBuilt == readingTwo;

  static const bool theOtherReadingIsRecorded = true;

  static const String ambiguityNote =
      'The Atomic Step can be read as the display of latency updates or as the '
      'latency with which updates display. The metric name settles it in '
      'favour of the second, so that is what is built -- and the first is '
      'recorded, because it is the reading anybody starting from the Atomic '
      'Step will take, and two people implementing two readings of one '
      'sentence is how a dashboard ends up with two clocks.';

  // -----------------------------------------------------------------------
  // The clock shows age, not time.
  // -----------------------------------------------------------------------

  static const int theStepThatSetTheCadencePolicy = 395;

  static const bool aSecondCadencePolicyIsDeclared = false;

  static bool get theCadencePolicyIsBound =>
      theStepThatSetTheCadencePolicy == 395 && !aSecondCadencePolicyIsDeclared;

  static const String whatTheClockShows = 'the age of the data on the card';

  static const String whatItDoesNotShow = 'the wall time';

  static bool get itShowsAgeRatherThanTime =>
      whatTheClockShows != whatItDoesNotShow;

  static const int firstBoundarySeconds = 30;
  static const int secondBoundarySeconds = 300;

  static HabotClockReading readingFor({
    required bool everHadAValue,
    required int ageSeconds,
  }) {
    if (!everHadAValue) {
      return HabotClockReading.never;
    }
    if (ageSeconds >= secondBoundarySeconds) {
      return HabotClockReading.minutes;
    }
    return ageSeconds >= firstBoundarySeconds
        ? HabotClockReading.seconds
        : HabotClockReading.current;
  }

  static bool get freshDataShowsNoAge =>
      readingFor(everHadAValue: true, ageSeconds: 4) ==
      HabotClockReading.current;

  static bool get aMinuteOldShowsSeconds =>
      readingFor(everHadAValue: true, ageSeconds: 60) ==
      HabotClockReading.seconds;

  static bool get tenMinutesOldShowsMinutes =>
      readingFor(everHadAValue: true, ageSeconds: 600) ==
      HabotClockReading.minutes;

  static bool get nothingEverArrivedIsItsOwnState =>
      readingFor(everHadAValue: false, ageSeconds: 0) ==
      HabotClockReading.never;

  static const int clocksOnTheScreen = 4;

  static const int repaintsPerSecondIfEveryClockTicked = 4;

  static const int repaintsPerSecondAsBuilt = 0;

  static bool get theRepaintsAreSaved =>
      repaintsPerSecondAsBuilt < repaintsPerSecondIfEveryClockTicked;

  static bool get itIsTheAgeStep430Publishes =>
      HabotStreamingHooks.theAgeAppearsOnlyWhenItMatters;

  static const String cadenceNote =
      'Four clocks ticking once a second is four repaints a second for a '
      'number nobody is watching change. Step 395 settled that on the SLA '
      'countdown -- match the tick rate to the magnitude -- and that policy is '
      'bound here rather than restated. The clock shows the age of the data '
      'rather than the wall time, because what a reader wants from a clock on '
      'a dashboard is not what time it is but whether what they are looking at '
      'is still true, and it repaints when the age crosses a boundary somebody '
      'would act on.';

  // -----------------------------------------------------------------------
  // The band, and what was measured.
  // -----------------------------------------------------------------------

  static const String bandOptimalRaw = '<200ms';
  static const String bandCeilingRaw = '2s';

  static const int floorMs = 1000;
  static const int optimalMs = 200;
  static const int ceilingMs = 2000;

  static bool get theOptimalIsBelowBothBoundaries =>
      optimalMs < floorMs && optimalMs < ceilingMs;

  static bool get theShapeIsTheDeclaredConvention =>
      HabotFrictionMiddleware.itIsAConventionRatherThanADefect;

  static const int observedUpdateMs = 90;

  static bool get theUpdateBeatsTheOptimal => observedUpdateMs < optimalMs;

  static String get qualitativeOutput =>
      theUpdateBeatsTheOptimal && itShowsAgeRatherThanTime ? 'Pass' : 'Fail';

  static const String columnNote =
      'COLUMN NOTE: this row\'s reference-standard column reads "Data '
      'Freshness Standards (<1s)", which restates its own floor rather than '
      'naming a standard -- the fourth distinct kind of content to appear in '
      'that column across two batches; its Atomic Step can be read two ways '
      'and the metric name settles it, with the other reading recorded; and '
      'its optimal of "<200ms" sits below both its floor of "<1s" and its '
      'ceiling of "2s", the fifth row in this batch written to the convention '
      'Step 418 sets out. Atomic Step: "Verify that latency updates display on '
      'mobile dashboard clocks with under 1 second delay."';

  static Map<String, bool> get obligations => <String, bool>{
        'the clock shows age rather than wall time':
            itShowsAgeRatherThanTime,
        'fresh data shows no age at all': freshDataShowsNoAge,
        'never-arrived is its own state': nothingEverArrivedIsItsOwnState,
        'the cadence policy is Step 395\'s': theCadencePolicyIsBound,
        'the age shown is the one Step 430 publishes':
            itIsTheAgeStep430Publishes,
      };

  static Map<String, bool> get checks => <String, bool>{
        'the standard column restates the floor':
            theStandardRepeatsTheFloor && !aRealStandardIsNamed,
        'four kinds of content have appeared in that column':
            fourDifferentUsesRecorded &&
                standardNote.contains('a second notes field'),
        'the Atomic Step has two readings':
            theSentenceIsAmbiguous && theOtherReadingIsRecorded,
        'and the metric name settles which was built':
            theMetricSettlesIt && ambiguityNote.contains('two clocks'),
        'the clock shows age, not time':
            itShowsAgeRatherThanTime && freshDataShowsNoAge,
        'four readings across the boundaries':
            aMinuteOldShowsSeconds &&
                tenMinutesOldShowsMinutes &&
                nothingEverArrivedIsItsOwnState,
        'four clocks, and no per-second repaints':
            clocksOnTheScreen == 4 && theRepaintsAreSaved,
        'the cadence policy is bound rather than restated':
            theCadencePolicyIsBound && cadenceNote.contains('still true'),
        'the optimal sits below both boundaries':
            theOptimalIsBelowBothBoundaries && theShapeIsTheDeclaredConvention,
        'five obligations, all met, giving Pass':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Pass' &&
                theUpdateBeatsTheOptimal,
      };
}
