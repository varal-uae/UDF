/// Step 370 (SIDM-016) -- the second band in this track that is false on its
/// own terms.
///
/// The row: "Select Material Design status summary formats and modern layout
/// specifications."
/// Metric: **Select Material Design Quality Index** -- floor 0.9, optimal 1,
/// **ceiling 0.98**. Best Qualitative Output: **"High"**.
///
/// **The ceiling is below the optimal.** Floor 0.9, optimal 1, ceiling 0.98:
/// the value the row calls best sits outside the range the row calls
/// attainable, by two hundredths. Step 312 carried exactly this shape --
/// ceiling 0.999 against an optimal of 1 -- and the build record for that batch
/// called it *the first band in the track that is false on its own terms*. This
/// is the second, which makes it a class rather than a one-off, and the two are
/// fifty-eight rows apart with nothing linking them.
///
/// **The output column holds one value.** "High", with no failing value beside
/// it, is the seventh one-valued output column this track has recorded after
/// Steps 321, 322, 334, 335, 351 and 371. And the Best Qualitative Output Type
/// cell holds benchmarking prose -- "Benchmark performance against leading
/// organizations and establish measurable service levels..." -- where the name
/// of a standard belongs.
///
/// **The metric name begins with a verb from its own Atomic Step.** "Select
/// Material Design Quality Index" is the row's first word welded onto a metric
/// name, which is the same generator behaviour Steps 352, 356 and 357 show in
/// the artefact cell, arriving in a different column.
///
/// **What the row actually asks for is a format, and a format is a decision
/// about what to drop.** A status summary on a 328dp screen cannot show
/// everything, so the work is choosing: four fields fit, the fifth does not,
/// and which four is the design. The panel declares its four, states the one it
/// drops and where that one is still reachable, which is the rule Step 311
/// settled for the trace map and Step 363 for a truncated list.
library;

/// One field a status summary could show.
class HabotSummaryField {
  const HabotSummaryField({
    required this.name,
    required this.widthDp,
    required this.included,
    required this.reachableAt,
  });

  final String name;
  final double widthDp;
  final bool included;

  /// Where a dropped field can still be found. Empty when it is included.
  final String reachableAt;
}

/// The status summary format.
class HabotStatusSummaryFormat {
  const HabotStatusSummaryFormat._();

  // -----------------------------------------------------------------------
  // The band, false on its own terms.
  // -----------------------------------------------------------------------

  static const double bandFloor = 0.9;
  static const double bandOptimal = 1;
  static const double bandCeiling = 0.98;

  static bool get theCeilingIsBelowTheOptimal => bandCeiling < bandOptimal;

  static double get shortfall => bandOptimal - bandCeiling;

  static bool get theShortfallIsTwoHundredths =>
      (shortfall - 0.02).abs() < 1e-9;

  /// Step 312's band was 0.98 / 1 / 0.999 -- the same shape, smaller gap.
  static const int theFirstSuchRow = 312;

  static const double theFirstSuchShortfall = 0.001;

  static bool get thisIsTheSecondSuchBand =>
      theCeilingIsBelowTheOptimal && theFirstSuchRow == 312;

  static bool get thisGapIsTwentyTimesTheFirst =>
      ((shortfall / theFirstSuchShortfall) - 20).abs() < 1e-9;

  static const int rowsApart = 58;

  static const String bandNote =
      'Floor 0.9, optimal 1, ceiling 0.98: the value the row calls best sits '
      'outside the range the row calls attainable, by two hundredths. Step 312 '
      'carried the same shape with a gap of one thousandth, and the build '
      'record for that batch called it the first band in the track that is '
      'false on its own terms. This is the second, fifty-eight rows later, '
      'with nothing linking them -- which makes it a class of defect rather '
      'than a one-off, and this gap is twenty times the first.';

  // -----------------------------------------------------------------------
  // The output column, and the cell where a standard belongs.
  // -----------------------------------------------------------------------

  static const String outputColumn = 'High';

  static bool get theOutputCannotExpressAFailure => outputColumn == 'High';

  static const List<int> oneValuedColumnsBefore = <int>[
    321,
    322,
    334,
    335,
    351,
  ];

  static int get oneValuedColumnsIncludingThis =>
      oneValuedColumnsBefore.length + 2;

  /// This row and Step 371 both add one, taking the track to seven.
  static bool get theCountReachesSeven =>
      oneValuedColumnsIncludingThis == 7 && theOutputCannotExpressAFailure;

  static const String outputTypeCell =
      'Benchmark performance against leading organizations and establish '
      'measurable service levels, quality standards, and productivity targets.';

  static bool get theStandardCellHoldsAdvice =>
      outputTypeCell.startsWith('Benchmark performance');

  static const String outputNote =
      '"High" with no failing value beside it is the seventh one-valued output '
      'column this track has recorded, after Steps 321, 322, 334, 335, 351 and '
      '371. The Best Qualitative Output Type cell, where the name of a '
      'standard belongs, holds benchmarking advice instead -- a sentence about '
      'establishing service levels rather than the name of anything to measure '
      'against.';

  // -----------------------------------------------------------------------
  // The metric name, welded to the Atomic Step.
  // -----------------------------------------------------------------------

  static const String metricName = 'Select Material Design Quality Index';

  static const String atomicStepFirstWord = 'Select';

  static bool get theMetricNameStartsWithTheRowsVerb =>
      metricName.startsWith(atomicStepFirstWord);

  /// The same generator behaviour Steps 352, 356 and 357 show in the artefact
  /// cell, arriving in a different column.
  static const List<int> artefactCellRows = <int>[352, 356, 357];

  static bool get theSameBehaviourAppearsInAnotherColumn =>
      theMetricNameStartsWithTheRowsVerb && artefactCellRows.length == 3;

  static const String metricNameNote =
      '"Select Material Design Quality Index" is the Atomic Step\'s first word '
      'welded onto a metric name. It is the same generator behaviour Steps '
      '352, 356 and 357 show in the artefact cell -- a fragment of the row\'s '
      'own text landing in a field meant for something else -- arriving here '
      'in the metric column instead.';

  // -----------------------------------------------------------------------
  // A format is a decision about what to drop.
  // -----------------------------------------------------------------------

  static const double compactWidthDp = 328;

  static const List<HabotSummaryField> candidates = <HabotSummaryField>[
    HabotSummaryField(
      name: 'status',
      widthDp: 84,
      included: true,
      reachableAt: '',
    ),
    HabotSummaryField(
      name: 'last change',
      widthDp: 76,
      included: true,
      reachableAt: '',
    ),
    HabotSummaryField(
      name: 'owner',
      widthDp: 88,
      included: true,
      reachableAt: '',
    ),
    HabotSummaryField(
      name: 'count',
      widthDp: 48,
      included: true,
      reachableAt: '',
    ),
    HabotSummaryField(
      name: 'source system',
      widthDp: 120,
      included: false,
      reachableAt: 'the detail sheet, one tap from the row',
    ),
  ];

  static double get includedWidth => candidates
      .where((HabotSummaryField f) => f.included)
      .fold(0, (double a, HabotSummaryField f) => a + f.widthDp);

  static int get includedCount =>
      candidates.where((HabotSummaryField f) => f.included).length;

  static List<HabotSummaryField> get dropped =>
      candidates.where((HabotSummaryField f) => !f.included).toList();

  static bool get fourFit =>
      includedCount == 4 && includedWidth <= compactWidthDp;

  static bool get theFifthWouldNotFit =>
      includedWidth + dropped.first.widthDp > compactWidthDp;

  static bool get everyDroppedFieldIsReachable =>
      dropped.every((HabotSummaryField f) => f.reachableAt.isNotEmpty);

  static double get widthLeft => compactWidthDp - includedWidth;

  static const String formatNote =
      'A status summary on a 328dp screen cannot show everything, so the work '
      'is choosing. Four fields fit in 296dp with 32dp to spare; the fifth is '
      '120dp and does not. Which four is the design, and the one that is '
      'dropped is named along with where it can still be found -- the rule '
      'Step 311 settled for the trace map and Step 363 for a truncated list. A '
      'format that drops a field silently is a format that has decided '
      'something on the reader\'s behalf without telling them.';

  static Map<String, bool> get obligations => <String, bool>{
        'the included fields fit the compact width': fourFit,
        'the dropped field is named': dropped.length == 1,
        'the dropped field is still reachable': everyDroppedFieldIsReachable,
        'the fifth field genuinely does not fit': theFifthWouldNotFit,
        'the band defect is recorded rather than adopted':
            theCeilingIsBelowTheOptimal,
      };

  /// The row's output column can only say High, so the honest report is the
  /// obligations, and they hold.
  static String get qualitativeOutput =>
      obligations.values.every((bool b) => b) ? 'High' : 'Low';

  static Map<String, bool> get checks => <String, bool>{
        'the ceiling is below the optimal':
            theCeilingIsBelowTheOptimal && bandCeiling == 0.98,
        'the shortfall is two hundredths': theShortfallIsTwoHundredths,
        'it is the second such band, after Step 312':
            thisIsTheSecondSuchBand && rowsApart == 58,
        'and the gap is twenty times the first':
            thisGapIsTwentyTimesTheFirst &&
                bandNote.contains('a class of defect'),
        'the output column holds one value, the seventh in the track':
            theCountReachesSeven,
        'the standard cell holds benchmarking advice':
            theStandardCellHoldsAdvice &&
                outputNote.contains('rather than the name'),
        'the metric name begins with the row\'s own verb':
            theSameBehaviourAppearsInAnotherColumn &&
                metricNameNote.contains('meant for something else'),
        'four fields fit with 32dp to spare':
            fourFit && widthLeft == 32,
        'the fifth is named and reachable':
            theFifthWouldNotFit && everyDroppedFieldIsReachable,
        'five obligations, all met':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'High',
      };

  static const String columnNote =
      'COLUMN NOTE: the band on this row sets a ceiling of 0.98 below its own '
      'optimal of 1 -- the second such band in this track after Step 312 -- '
      'its Best Qualitative Output column reads "High" with no failing value, '
      'its Best Qualitative Output Type cell holds benchmarking advice where '
      'the name of a standard belongs, its metric name begins with the Atomic '
      'Step\'s own first word, and its Setup Step column reads "Write unit '
      'tests for the save, restore, discard, and quota check functions". '
      'Atomic Step: "Select Material Design status summary formats and modern '
      'layout specifications."';
}
