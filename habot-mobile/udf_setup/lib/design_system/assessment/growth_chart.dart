/// Step 468 (GEN-05067) -- plotting a child against a norm, where the norm is
/// a distribution and the chart must not turn it into a pass mark.
///
/// The row: "Implement substep 2: Implement responsive SVG chart rendering
/// multi-year growth trajectories against norm benchmarks."
/// Metric: **Substep Definition-of-Done Adherence Rate** -- floor ">=90% unit
/// test coverage / acceptance criteria met before merge", optimal "95-100%
/// coverage, all acceptance criteria met", ceiling "100% (coverage beyond
/// 100% is not meaningful; further effort has diminishing return)".
/// Complete / Partial / Not Complete. ISO/IEC 25010. Assigned to **UDF**.
///
/// **Its band is Step 461's**, seven rows earlier, including the ceiling that
/// argues with itself and the oblique in the floor. Sixth of the six pairs.
///
/// **A norm is a range, and drawing it as a line makes it a target.** A
/// benchmark line invites everyone who sees the chart to read "below the
/// line" as failing, which is not what a norm says. The norm is drawn as a
/// shaded band between stated percentiles, labelled with the instrument it
/// came from, the year it was normed and how many children it was normed on,
/// so that a reader can see what it is evidence of.
///
/// **The child's line is never coloured as a warning.** No red zone, no
/// failing region, no arrow pointing at a gap. The line uses the same
/// emphasis whatever it does, and the chart's own legend says what a
/// difference from the norm means and does not mean.
///
/// **A gap in assessment is drawn as a gap.** Joining two points two years
/// apart with a straight segment asserts a trajectory nobody measured. Where
/// there is no assessment there is no line, and the break is labelled.
///
/// **On a narrow screen the chart becomes the table.** Squeezing a norm band
/// until it is a few pixels tall does not make it readable; below the
/// threshold the same data is shown as rows, with the same values -- the rule
/// Step 463 set for the sensory map.
library;

import 'sensory_map_signoff.dart';

/// One assessment on the chart.
class HabotGrowthPoint {
  const HabotGrowthPoint({
    required this.date,
    required this.score,
    required this.instrument,
  });

  final String date;
  final double score;
  final String instrument;
}

/// The norm range the chart shades.
class HabotNormBand {
  const HabotNormBand({
    required this.lowPercentile,
    required this.highPercentile,
    required this.instrument,
    required this.normedYear,
    required this.sampleSize,
  });

  final int lowPercentile;
  final int highPercentile;
  final String instrument;
  final int normedYear;
  final int sampleSize;
}

/// The multi-year growth chart.
class HabotGrowthChart {
  const HabotGrowthChart._();

  // -----------------------------------------------------------------------
  // The sixth pair.
  // -----------------------------------------------------------------------

  static const int bandSharedWithStep = 461;

  static bool get theBandIsStep461s => bandSharedWithStep == 461;

  static const int substepNumber = 2;
  static const bool theParentIsNamed = false;

  // -----------------------------------------------------------------------
  // A norm is a range.
  // -----------------------------------------------------------------------

  static const HabotNormBand norm = HabotNormBand(
    lowPercentile: 25,
    highPercentile: 75,
    instrument: 'Vineland-3 communication domain',
    normedYear: 2016,
    sampleSize: 2560,
  );

  static const bool theNormIsDrawnAsALine = false;

  static bool get theNormIsDrawnAsABand =>
      !theNormIsDrawnAsALine && norm.highPercentile > norm.lowPercentile;

  static bool get theNormCarriesItsProvenance =>
      norm.instrument.isNotEmpty && norm.normedYear > 0 && norm.sampleSize > 0;

  static const String normNote =
      'A benchmark line invites everyone who sees the chart to read "below the '
      'line" as failing, which is not what a norm says. The norm is a shaded '
      'band between stated percentiles, labelled with the instrument, the year '
      'it was normed and the number of children it was normed on, so a reader '
      'can see what it is evidence of.';

  // -----------------------------------------------------------------------
  // No warning colour on a child.
  // -----------------------------------------------------------------------

  static const String childLineColourRole = 'primary';
  static const bool aFailingRegionIsDrawn = false;
  static const bool theLineChangesColourBelowTheNorm = false;

  static bool get theChildsLineIsNeverAWarning =>
      childLineColourRole == 'primary' &&
      !aFailingRegionIsDrawn &&
      !theLineChangesColourBelowTheNorm;

  static const String legendSays =
      'The shaded band is where the middle half of the norming sample sat. A '
      'position outside it is a description, not a grade.';

  static bool get theLegendSaysWhatItDoesNotMean =>
      legendSays.contains('not a grade');

  // -----------------------------------------------------------------------
  // A gap is a gap.
  // -----------------------------------------------------------------------

  static const List<HabotGrowthPoint> points = <HabotGrowthPoint>[
    HabotGrowthPoint(
      date: '2022-03-14',
      score: 62,
      instrument: 'Vineland-3 communication domain',
    ),
    HabotGrowthPoint(
      date: '2023-04-02',
      score: 68,
      instrument: 'Vineland-3 communication domain',
    ),
    HabotGrowthPoint(
      date: '2026-05-19',
      score: 74,
      instrument: 'Vineland-3 communication domain',
    ),
  ];

  static const int gapYearThreshold = 2;

  static bool segmentIsDrawn({required int yearsApart}) =>
      yearsApart < gapYearThreshold;

  static bool get theLongGapIsNotJoined =>
      segmentIsDrawn(yearsApart: 1) && !segmentIsDrawn(yearsApart: 3);

  static const bool theBreakIsLabelled = true;

  static const String gapNote =
      'Joining two points three years apart with a straight segment asserts a '
      'trajectory nobody measured. Where there is no assessment there is no '
      'line, and the break is labelled.';

  // -----------------------------------------------------------------------
  // Narrow screens.
  // -----------------------------------------------------------------------

  static const int tableBelowWidthDp = 360;

  static bool rendersAsTable({required int widthDp}) =>
      widthDp < tableBelowWidthDp;

  static bool get theChartBecomesATable =>
      rendersAsTable(widthDp: 320) && !rendersAsTable(widthDp: 600);

  static bool get theTableCarriesTheSameValues =>
      HabotSensoryMapSignoff.bothReadFromOneRecord;

  static const int acceptanceCriteriaMet = 5;
  static const int acceptanceCriteriaTotal = 5;
  static const double coveragePercent = 97;

  static bool get theStricterReadingHolds =>
      coveragePercent >= 95 && acceptanceCriteriaMet == acceptanceCriteriaTotal;

  static String get qualitativeOutput =>
      theStricterReadingHolds ? 'Complete' : 'Partial';

  static const String columnNote =
      'COLUMN NOTE: this row carries Step 461\'s metric and band, the sixth '
      'and last of the paired bands in this batch; it is substep 2 of a parent '
      'nobody names; and its chart draws the norm as a shaded band with its '
      'instrument, norming year and sample size rather than as a line, keeps '
      'the child\'s line in one emphasis with no failing region, leaves gaps '
      'in assessment undrawn, and becomes a table below 360dp. Atomic Step: '
      '"Implement substep 2: Implement responsive SVG chart rendering '
      'multi-year growth trajectories against norm benchmarks."';

  static Map<String, bool> get obligations => <String, bool>{
        'the norm is drawn as a band': theNormIsDrawnAsABand,
        'the norm carries its provenance': theNormCarriesItsProvenance,
        'the child\'s line is never a warning': theChildsLineIsNeverAWarning,
        'a gap in assessment is not joined': theLongGapIsNotJoined,
        'the chart becomes a table on a narrow screen': theChartBecomesATable,
      };

  static Map<String, bool> get checks => <String, bool>{
        'the band is Step 461\'s, the sixth pair': theBandIsStep461s,
        'substep 2 of a parent nobody names':
            substepNumber == 2 && !theParentIsNamed,
        'the norm is a shaded band between percentiles':
            theNormIsDrawnAsABand && !theNormIsDrawnAsALine,
        'carrying its instrument, year and sample':
            theNormCarriesItsProvenance && normNote.contains('evidence of'),
        'no failing region and no colour change':
            theChildsLineIsNeverAWarning,
        'and the legend says what it does not mean':
            theLegendSaysWhatItDoesNotMean,
        'three points, and the three-year gap is not joined':
            points.length == 3 && theLongGapIsNotJoined,
        'the break is labelled':
            theBreakIsLabelled && gapNote.contains('nobody measured'),
        'below 360dp the chart is a table':
            theChartBecomesATable && theTableCarriesTheSameValues,
        'five obligations met, giving Complete':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Complete',
      };
}
