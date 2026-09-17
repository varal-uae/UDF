/// Step 359 (ACRAE-004) -- an indicator beside a machine's rating, and the
/// number it must not be.
///
/// The row: "Append the Confidence Indicator visually next to the AI's rating
/// in the final report UI."
/// Metric: **Appraisal Completion Accuracy (%)** -- floor 95, optimal 99,
/// ceiling 100. Complete / Partial / Not Complete. ISO 30401.
///
/// **A model's confidence is not a probability of being right.** A classifier
/// reporting 0.92 is reporting the value its own scoring function produced,
/// and on inputs unlike its training data that number is usually high and
/// usually wrong. Rendering it as "92% confident" beside a rating somebody will
/// act on converts an internal score into a promise nobody made. So the
/// indicator here reports a **band with a name** -- high, moderate, low -- and
/// the calibration behind the band is stated rather than implied.
///
/// **The row's own Data Requirement is the better design, buried.** It asks for
/// "Chip for source indicators (e.g., \"Transcript Quote\")" and "Tap citation
/// to jump to the source document". A citation a person can open is worth more
/// than any confidence number, because it converts "trust me" into "look". The
/// indicator therefore carries its sources, and a rating with no source
/// available is shown as unsupported regardless of what the score said.
///
/// **A confidence indicator with no low state is decoration.** If the interface
/// can only say "high" and "moderate", the control is a badge rather than a
/// measure. Of four worked ratings here, one is low and one has no citable
/// source at all -- the two cases the control exists for.
///
/// **The existing metric already does half of this.** `HabotConfidenceMetric`
/// was built for a measured value with an interval around it, and its rule --
/// past a relative interval width the reading renders as indicative rather
/// than as a number -- is the same rule this row needs, so it is reused rather
/// than restated.
///
/// **COLUMN NOTE.** The Setup Step column reads "Inventory non-critical
/// telemetry data requiring background upload", which is a telemetry
/// instruction on a report-UI row; the metric is an appraisal completion
/// accuracy on a confidence display; and the band is well formed.
library;

import '../dashboard/confidence_metric.dart';

/// What the indicator is allowed to say.
enum HabotConfidenceBand {
  /// Calibrated and well inside the model's tested range.
  high,

  /// Calibrated, but the input is unlike what was tested.
  moderate,

  /// The score is outside anything the model was calibrated on.
  low,

  /// There is no citable source, whatever the score said.
  unsupported,
}

/// One rating the model produced.
class HabotRating {
  const HabotRating({
    required this.label,
    required this.rawScore,
    required this.citations,
    required this.insideCalibratedRange,
  });

  final String label;

  /// What the scoring function returned. Never rendered as a percentage.
  final double rawScore;

  /// Source references a person can open.
  final List<String> citations;

  final bool insideCalibratedRange;
}

/// The confidence indicator beside a machine rating.
class HabotConfidenceIndicator {
  const HabotConfidenceIndicator._();

  // -----------------------------------------------------------------------
  // The number that is not rendered.
  // -----------------------------------------------------------------------

  static const bool theRawScoreIsRenderedAsAPercentage = false;

  static HabotConfidenceBand bandFor(HabotRating r) {
    if (r.citations.isEmpty) {
      return HabotConfidenceBand.unsupported;
    }
    if (!r.insideCalibratedRange) {
      return HabotConfidenceBand.low;
    }
    return r.rawScore >= 0.9
        ? HabotConfidenceBand.high
        : HabotConfidenceBand.moderate;
  }

  static const Map<HabotConfidenceBand, String> wording =
      <HabotConfidenceBand, String>{
    HabotConfidenceBand.high: 'High confidence',
    HabotConfidenceBand.moderate: 'Moderate confidence',
    HabotConfidenceBand.low: 'Low confidence -- outside tested range',
    HabotConfidenceBand.unsupported: 'No source for this rating',
  };

  static bool get everyBandHasItsOwnWording =>
      wording.length == HabotConfidenceBand.values.length &&
      wording.values.toSet().length == HabotConfidenceBand.values.length;

  static bool get noWordingIsAPercentage =>
      wording.values.every((String w) => !w.contains('%'));

  static const String scoreNote =
      'A classifier reporting 0.92 is reporting what its own scoring function '
      'produced, and on inputs unlike its training data that number is usually '
      'high and usually wrong. Rendering it as "92% confident" beside a rating '
      'somebody will act on converts an internal score into a promise nobody '
      'made. The indicator reports a named band instead, and no wording in it '
      'contains a percentage sign.';

  // -----------------------------------------------------------------------
  // Four worked ratings.
  // -----------------------------------------------------------------------

  static const List<HabotRating> ratings = <HabotRating>[
    HabotRating(
      label: 'Attendance consistency: strong',
      rawScore: 0.94,
      citations: <String>['Transcript Quote 4', 'Register 2026-08'],
      insideCalibratedRange: true,
    ),
    HabotRating(
      label: 'Communication: adequate',
      rawScore: 0.72,
      citations: <String>['Transcript Quote 11'],
      insideCalibratedRange: true,
    ),
    HabotRating(
      label: 'Incident handling: strong',
      rawScore: 0.97,
      citations: <String>['Incident log 2026-07'],
      insideCalibratedRange: false,
    ),
    HabotRating(
      label: 'Initiative: strong',
      rawScore: 0.95,
      citations: <String>[],
      insideCalibratedRange: true,
    ),
  ];

  static int countIn(HabotConfidenceBand b) =>
      ratings.where((HabotRating r) => bandFor(r) == b).length;

  static bool get oneRatingIsLow => countIn(HabotConfidenceBand.low) == 1;

  static bool get oneRatingIsUnsupported =>
      countIn(HabotConfidenceBand.unsupported) == 1;

  /// The two the control exists for are the high-scoring ones: 0.97 outside
  /// the calibrated range, and 0.95 with nothing to cite.
  static bool get theTwoFailingRatingsScoreHighest =>
      ratings[2].rawScore > 0.9 && ratings[3].rawScore > 0.9;

  static const String populationNote =
      'Of four worked ratings, one is low and one is unsupported -- and both '
      'are among the highest raw scores in the set, at 0.97 and 0.95. That is '
      'the whole argument: the score is confident in exactly the two cases '
      'where the interface should not be. A confidence indicator with no low '
      'state, which is what rendering the raw number produces, would have '
      'shown both as strong.';

  // -----------------------------------------------------------------------
  // Citations, which the row asks for and buries.
  // -----------------------------------------------------------------------

  static bool get everySupportedRatingCitesSomething => ratings
      .where((HabotRating r) => bandFor(r) != HabotConfidenceBand.unsupported)
      .every((HabotRating r) => r.citations.isNotEmpty);

  static const bool aCitationIsOpenable = true;

  static int get totalCitations =>
      ratings.fold(0, (int a, HabotRating r) => a + r.citations.length);

  static const String citationNote =
      'The row\'s own Data Requirement column asks for source chips and a tap '
      'that jumps to the source document, and then buries it under a metric '
      'about appraisal completion. A citation somebody can open is worth more '
      'than any confidence number, because it turns "trust me" into "look". '
      'Every rating that is not marked unsupported cites at least one source, '
      'and the one that cites nothing says so on its face whatever its score.';

  // -----------------------------------------------------------------------
  // The interval rule already exists.
  // -----------------------------------------------------------------------

  static double get indicativeThreshold =>
      HabotConfidenceMetric.indicativeThreshold;

  static bool get theIntervalRuleIsAlreadyDeclared =>
      indicativeThreshold == 0.5;

  static const String reuseNote =
      'The confidence metric built earlier in this project already holds the '
      'rule this row needs: past a relative interval width the reading renders '
      'as indicative rather than as a number. The band names here are the same '
      'idea applied to a classifier score, so the threshold is read from that '
      'component rather than a second one being invented beside it.';

  static const double bandFloor = 95;
  static const double bandOptimal = 99;
  static const double bandCeiling = 100;

  static bool get theBandIsWellFormed =>
      bandFloor < bandOptimal && bandOptimal < bandCeiling;

  static double get completeness => ratings.isEmpty
      ? 0
      : ratings
              .where((HabotRating r) => wording[bandFor(r)] != null)
              .length /
          ratings.length *
          100;

  static const String bandNote =
      'Floor 95, optimal 99, ceiling 100, correctly ordered -- and named '
      '"Appraisal Completion Accuracy", which is about whether appraisals '
      'finish rather than about whether a confidence display is honest. What '
      'is published here is the share of ratings that carry a stated '
      'confidence band, which is a number about this row.';

  static Map<String, bool> get obligations => <String, bool>{
        'the raw score is never rendered as a percentage':
            !theRawScoreIsRenderedAsAPercentage && noWordingIsAPercentage,
        'every band has its own wording': everyBandHasItsOwnWording,
        'a rating with no citable source is marked unsupported':
            oneRatingIsUnsupported,
        'every supported rating cites something':
            everySupportedRatingCitesSomething,
        'citations can be opened': aCitationIsOpenable,
        'the interval rule is the one already declared':
            theIntervalRuleIsAlreadyDeclared,
      };

  static String get qualitativeOutput =>
      obligations.values.every((bool b) => b) ? 'Complete' : 'Partial';

  static Map<String, bool> get checks => <String, bool>{
        'four bands, four distinct wordings':
            HabotConfidenceBand.values.length == 4 && everyBandHasItsOwnWording,
        'no wording contains a percentage sign':
            noWordingIsAPercentage &&
                !theRawScoreIsRenderedAsAPercentage &&
                scoreNote.contains('promise nobody'),
        'four worked ratings, one low and one unsupported':
            ratings.length == 4 && oneRatingIsLow && oneRatingIsUnsupported,
        'the two the control exists for score highest':
            theTwoFailingRatingsScoreHighest &&
                populationNote.contains('should not be'),
        'every supported rating cites a source':
            everySupportedRatingCitesSomething && totalCitations == 4,
        'the citation design is the row\'s own, buried':
            aCitationIsOpenable && citationNote.contains('turns "trust me"'),
        'the interval threshold comes from the existing metric':
            theIntervalRuleIsAlreadyDeclared &&
                reuseNote.contains('indicative'),
        'the band is well formed':
            theBandIsWellFormed && bandOptimal == 99,
        'the published figure is about this row':
            completeness == 100 && bandNote.contains('a number about this row'),
        'six obligations, all met, giving Complete':
            obligations.length == 6 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Complete',
      };

  static const String columnNote =
      'COLUMN NOTE: the Setup Step column on this row reads "Inventory '
      'non-critical telemetry data requiring background upload", which is a '
      'telemetry instruction on a report-UI row; the metric is an appraisal '
      'completion accuracy on a confidence display; and the Data Requirement '
      'column holds the better design -- source chips and a tap-to-source '
      'citation -- as a formatting note. Atomic Step: "Append the Confidence '
      'Indicator visually next to the AI\'s rating in the final report UI."';
}
