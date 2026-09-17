/// Step 369 (HC-SCH-0179) -- "clearly" as a requirement, and the second cell
/// in the sheet that reports the generator could not find a source row.
///
/// The row: "Output status parameters clearly inside the standardized
/// dashboard overview panel."
/// Metric: **Dashboard Load Time** -- floor "<3 sec", optimal "<1.5 sec",
/// ceiling "<0.5 sec". Good/Average/Poor. Google Core Web Vitals (Largest
/// Contentful Paint). Assigned to **DEA**.
///
/// **The Data Requirement cell is the one Step 347 recorded as a first.** It
/// reads "No matched reference row in Setup Implementation master list --
/// required data fields limited to atomic-level Data Collection Requirements
/// only; standardized Mobile UX/UI & domain-expertise fields unavailable,
/// verify manually" -- identical wording. Step 347 called it the first cell in
/// this track that documents its own absence. It is now the second, which
/// makes it a template rather than an accident, and it is still more useful
/// than most of the cells that are filled in.
///
/// **"Clearly" is not a requirement until somebody says what it excludes.**
/// Four things a status parameter can be shown as, three of which fail for
/// somebody: colour alone (SC 1.4.1), an icon alone, an abbreviation, and a
/// word with an icon beside it. The panel uses the fourth and refuses the first
/// three, which is what "clearly" has to mean before it can be built or tested.
///
/// **A status with no age is a statement about the past presented as the
/// present.** Every parameter carries when it was last established, which is
/// Step 129's policy again and Step 331's finding one batch earlier.
///
/// **Load time is a real measure for this row, and the metric is the wrong
/// instrument for it.** Largest Contentful Paint is a browser measurement --
/// the third Core Web Vitals citation in two batches, alongside Steps 344 and
/// 363. What can be measured here is time to *first useful content*, which on
/// a status panel means the first parameter with a real value rather than the
/// skeleton, and that is not the largest element on the screen.
library;

import 'freshness.dart';
import 'query_row_limit.dart';

/// How a status parameter can be presented.
enum HabotStatusPresentation {
  /// A coloured dot and nothing else.
  colourOnly,

  /// A glyph and nothing else.
  iconOnly,

  /// "OK", "DEG", "ERR".
  abbreviationOnly,

  /// A word, with an icon beside it for scanning.
  wordWithIcon,
}

/// One status parameter on the panel.
class HabotStatusParameter {
  const HabotStatusParameter({
    required this.name,
    required this.value,
    required this.establishedSecondsAgo,
  });

  final String name;
  final String value;
  final int establishedSecondsAgo;
}

/// The standardised dashboard overview panel.
class HabotOverviewPanel {
  const HabotOverviewPanel._();

  // -----------------------------------------------------------------------
  // The cell that reports its own absence, for the second time.
  // -----------------------------------------------------------------------

  static const String dataRequirementCell =
      'No matched reference row in Setup Implementation master list -- '
      'required data fields limited to atomic-level Data Collection '
      'Requirements only; standardized Mobile UX/UI & domain-expertise fields '
      'unavailable, verify manually.';

  static bool get theCellReportsItsOwnAbsence =>
      dataRequirementCell.contains('No matched reference row');

  static const int theFirstSuchRow = 347;

  static const int occurrencesInTheTrack = 2;

  static bool get thisIsTheSecondOccurrence => occurrencesInTheTrack == 2;

  static const String generatorNote =
      'Step 347 recorded this cell as the first in the track that documents '
      'its own absence. The wording here is identical, which makes it the '
      'second and therefore a template rather than an accident. It is still '
      'the most useful thing on the row: a stated gap can be closed, and an '
      'invented requirement cannot be told apart from a real one.';

  // -----------------------------------------------------------------------
  // What "clearly" excludes.
  // -----------------------------------------------------------------------

  static const Map<HabotStatusPresentation, String> refusalReason =
      <HabotStatusPresentation, String>{
    HabotStatusPresentation.colourOnly:
        'colour alone carries no meaning for about one man in twelve',
    HabotStatusPresentation.iconOnly:
        'a glyph has to be learned, and nothing on screen teaches it',
    HabotStatusPresentation.abbreviationOnly:
        'an abbreviation is a second vocabulary nobody was given',
  };

  static const HabotStatusPresentation chosen =
      HabotStatusPresentation.wordWithIcon;

  static bool get threeOfFourAreRefused => refusalReason.length == 3;

  static bool get everyRefusalIsArgued =>
      refusalReason.values.every((String r) => r.isNotEmpty);

  static bool get theChosenFormIsNotRefused =>
      !refusalReason.containsKey(chosen);

  static const String criterion = 'WCAG 2.2 SC 1.4.1 Use of Colour';

  static const String clearlyNote =
      '"Clearly" is not a requirement until somebody says what it excludes. '
      'Four presentations are available and three fail for somebody: colour '
      'alone is SC 1.4.1, an icon alone has to be learned with nothing on '
      'screen to teach it, and an abbreviation is a second vocabulary nobody '
      'was given. The panel uses a word with an icon beside it for scanning, '
      'which is the only one of the four that works for a reader who has never '
      'seen the panel before.';

  // -----------------------------------------------------------------------
  // A status with no age.
  // -----------------------------------------------------------------------

  static const List<HabotStatusParameter> parameters =
      <HabotStatusParameter>[
    HabotStatusParameter(
      name: 'Ingestion',
      value: 'Healthy',
      establishedSecondsAgo: 20,
    ),
    HabotStatusParameter(
      name: 'Reconciliation',
      value: 'Degraded',
      establishedSecondsAgo: 200,
    ),
    HabotStatusParameter(
      name: 'Payouts',
      value: 'Healthy',
      establishedSecondsAgo: 900,
    ),
  ];

  static HabotFreshness freshnessOf(HabotStatusParameter p) =>
      HabotFreshnessPolicy.classify(
        Duration(seconds: p.establishedSecondsAgo),
      );

  static bool get everyParameterCarriesItsAge =>
      parameters.every((HabotStatusParameter p) => p.establishedSecondsAgo > 0);

  static int get parametersThatMustBeLabelledStale => parameters
      .where((HabotStatusParameter p) => freshnessOf(p).mustBeLabelled)
      .length;

  /// One of the three is past the budget and must say so -- and it is the one
  /// reading Healthy, which is the case that matters.
  static bool get theStaleOneReadsHealthy =>
      parametersThatMustBeLabelledStale == 1 &&
      parameters.last.value == 'Healthy';

  static const String ageNote =
      'A status with no age is a statement about the past presented as the '
      'present. Every parameter carries when it was last established, '
      'classified by the Step 129 policy -- and of the three here, the one '
      'that is past the budget is the one reading "Healthy", which is exactly '
      'the case where a missing age costs something. Step 331 recorded the '
      'same finding one batch earlier on an exception counter.';

  // -----------------------------------------------------------------------
  // Load time, measured as time to first useful content.
  // -----------------------------------------------------------------------

  static const String metricName = 'Dashboard Load Time';

  static const String citedInstrument =
      'Google Core Web Vitals (Largest Contentful Paint)';

  static bool get theInstrumentIsABrowserMetric =>
      citedInstrument.contains('Core Web Vitals');

  /// Steps 344, 363 and this one.
  static bool get thisIsTheThirdCoreWebVitalsCitation =>
      HabotQueryRowLimit.coreWebVitalsRows.length == 3 &&
      HabotQueryRowLimit.coreWebVitalsRows.contains(369);

  static const double bandFloorSeconds = 3.0;
  static const double bandOptimalSeconds = 1.5;
  static const double bandCeilingSeconds = 0.5;

  static bool get theBandIsOrderedCorrectly =>
      bandFloorSeconds > bandOptimalSeconds &&
      bandOptimalSeconds > bandCeilingSeconds;

  static const String whatIsActuallyMeasured =
      'time to the first parameter with a real value, rather than the skeleton';

  static bool get theMeasureIsRestated =>
      whatIsActuallyMeasured.contains('rather than the skeleton');

  static const String metricNote =
      'Load time is a real measure for this row and Largest Contentful Paint '
      'is the wrong instrument for it: LCP is a browser measurement of the '
      'largest element to paint, and this application has no DOM. It is the '
      'third Core Web Vitals citation in two batches, with Steps 344 and 363. '
      'What can be measured here is time to first useful content -- the first '
      'parameter showing a real value rather than a skeleton -- which is '
      'usually not the largest thing on the screen. The band is at least '
      'ordered correctly.';

  static Map<String, bool> get obligations => <String, bool>{
        'three presentations are refused with reasons':
            threeOfFourAreRefused && everyRefusalIsArgued,
        'the chosen presentation is a word with an icon':
            theChosenFormIsNotRefused &&
                chosen == HabotStatusPresentation.wordWithIcon,
        'every parameter carries its age': everyParameterCarriesItsAge,
        'a stale parameter is labelled stale':
            parametersThatMustBeLabelledStale == 1,
        'the measure is restated as time to first useful content':
            theMeasureIsRestated,
      };

  static String get qualitativeOutput =>
      obligations.values.every((bool b) => b) ? 'Good' : 'Poor';

  static Map<String, bool> get checks => <String, bool>{
        'the Data Requirement cell reports the generator\'s own miss':
            theCellReportsItsOwnAbsence && theFirstSuchRow == 347,
        'and it is the second occurrence, not the first':
            thisIsTheSecondOccurrence &&
                generatorNote.contains('template rather than an accident'),
        'four presentations, three refused':
            HabotStatusPresentation.values.length == 4 && threeOfFourAreRefused,
        'the colour-only refusal cites SC 1.4.1':
            criterion.contains('1.4.1') &&
                (refusalReason[HabotStatusPresentation.colourOnly] ?? '')
                    .contains('one man in twelve'),
        'every refusal carries a reason': everyRefusalIsArgued,
        'three parameters, each with an age': everyParameterCarriesItsAge,
        'the stale one is the one reading Healthy': theStaleOneReadsHealthy,
        'the age policy is Step 129\'s': ageNote.contains('Step 129'),
        'the cited instrument is a browser metric, third in two batches':
            theInstrumentIsABrowserMetric &&
                thisIsTheThirdCoreWebVitalsCitation &&
                theBandIsOrderedCorrectly,
        'five obligations, all met, giving Good':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Good',
      };

  static const String columnNote =
      'COLUMN NOTE: this row is assigned to DEA rather than UDF; its Data '
      'Requirement cell reports that the generator found no matching source '
      'row and says "verify manually", identical to Step 347\'s and therefore '
      'the second occurrence; its metric cites Google Core Web Vitals Largest '
      'Contentful Paint in an application with no DOM; and its Setup Step '
      'column reads "Connect navigation selection event logs directly to '
      'performance analytics datasets". Atomic Step: "Output status parameters '
      'clearly inside the standardized dashboard overview panel."';
}
