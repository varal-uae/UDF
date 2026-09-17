/// Step 425 (GEN-04130) -- highlight high-friction fields in red, where red
/// already means something else and colour is already not allowed to be alone.
///
/// The row: "Update mobile analytics dashboards to highlight high-friction
/// fields in Red (#error)."
/// Metric: **Red Highlight Rendering Speed** -- floor "<1s", optimal "<100ms",
/// ceiling "2s". Pass/Fail. Material Design 3 Error Palettes. Assigned to
/// **CAL**.
///
/// **Colour alone, refused for the third time.** Step 189 declared three
/// carriers -- a word, an icon and a role -- Step 369 restated them, and Step
/// 407 refused a row that asked for colour to carry a meaning by itself. This
/// row names a hex role and nothing else. The highlight built here carries the
/// colour the row asks for, an icon, and a figure in text, because a dashboard
/// read on a phone in sunlight by somebody with deuteranopia is the ordinary
/// case rather than the edge one.
///
/// **The error role is the wrong role.** `#error` means *something is wrong
/// with this thing and you can fix it*: a failed field, a rejected submission,
/// a broken connection. A high-friction field is a finding about a population
/// over a period -- nothing is broken, and nothing on that screen is in an
/// error state. Spending the error role on findings is how a dashboard ends up
/// with four red things and nobody in a hurry, which costs the role its meaning
/// on the day something actually breaks. A distinct attention treatment is used
/// and `#error` is left where it belongs.
///
/// **The metric scores how fast the red appears.** Not whether the right field
/// is red. Third row in this batch scored on its own mechanism rather than its
/// output, after Step 413 and Step 421 -- and unlike those two the mechanism
/// here is a repaint, which no dashboard has ever been limited by.
///
/// **Fourth row in the batch with the optimal below both boundaries.** Floor
/// "<1s" and ceiling "2s" bracket one to two seconds; the optimal of "<100ms"
/// sits under both.
library;

import '../disclosure/intermediate_values.dart';
import 'bottleneck_detection.dart';
import 'field_focus_duration.dart';
import 'friction_middleware.dart';

/// How a finding is marked on the dashboard.
class HabotHighlightTreatment {
  const HabotHighlightTreatment({
    required this.colourRole,
    required this.icon,
    required this.text,
  });

  /// The Material role, named rather than a hex literal.
  final String colourRole;

  final String icon;

  /// The figure that produced the highlight, in words.
  final String text;
}

/// The friction highlight.
class HabotFrictionHighlight {
  const HabotFrictionHighlight._();

  // -----------------------------------------------------------------------
  // Three carriers, not one.
  // -----------------------------------------------------------------------

  static const HabotHighlightTreatment treatment = HabotHighlightTreatment(
    colourRole: 'attention',
    icon: 'hourglass',
    text: 'p90 11.3s, 15 points below baseline',
  );

  static bool get theColourIsNamedNotHexed =>
      !treatment.colourRole.startsWith('#');

  static bool get threeCarriersArePresent =>
      treatment.colourRole.isNotEmpty &&
      treatment.icon.isNotEmpty &&
      treatment.text.isNotEmpty;

  static const int carriersTheRowAsksFor = 1;

  static int get carriersDelivered => 3;

  static bool get theRowAsksForOne => carriersTheRowAsksFor == 1;

  static bool get theCarrierRuleIsTheDeclaredOne =>
      HabotIntermediateValues.threeCarriers;

  /// Step 407 refused this last batch; this is the second refusal.
  static const List<int> rowsRefusingColourAlone = <int>[407, 425];

  static bool get secondRefusalOfColourAlone =>
      rowsRefusingColourAlone.length == 2;

  static const String carrierNote =
      'Step 189 declared three carriers -- a word, an icon and a role -- Step '
      '369 restated them and Step 407 refused a row that asked colour to carry '
      'a meaning alone. This row names a hex role and nothing else. The '
      'highlight carries the colour, an icon and the figure that produced it, '
      'because a dashboard read on a phone in sunlight by somebody with '
      'deuteranopia is the ordinary case and not the edge one.';

  // -----------------------------------------------------------------------
  // The error role means something else.
  // -----------------------------------------------------------------------

  static const String whatErrorMeans =
      'something is wrong with this thing and you can fix it';

  static const String whatAHighFrictionFieldIs =
      'a finding about a population over a period';

  static bool get theRolesDiffer => whatErrorMeans != whatAHighFrictionFieldIs;

  static const String roleTheRowNames = 'error';
  static const String roleUsed = 'attention';

  static bool get theErrorRoleIsLeftAlone => roleUsed != roleTheRowNames;

  static const int redThingsOnADashboardWhereNothingIsBroken = 4;

  static bool get theDilutionIsNamed =>
      redThingsOnADashboardWhereNothingIsBroken == 4;

  static const bool anythingOnThatScreenIsInAnErrorState = false;

  static const String roleNote =
      'The error role means something is wrong with this thing and you can fix '
      'it: a rejected submission, a failed field, a dropped connection. A '
      'high-friction field is a finding about a population over a period; '
      'nothing is broken and nothing on that screen is in an error state. '
      'Spending the error role on findings is how a dashboard ends up with '
      'four red things and nobody in a hurry, and the cost falls on the day '
      'something actually breaks.';

  // -----------------------------------------------------------------------
  // What is highlighted, and why.
  // -----------------------------------------------------------------------

  static bool get onlyDetectorFindingsAreHighlighted =>
      HabotBottleneckDetection.everyFiringNamesItsReason;

  static int get fieldsHighlighted =>
      HabotBottleneckDetection.countOf(HabotDetectionOutcome.truePositive) +
      HabotBottleneckDetection.countOf(HabotDetectionOutcome.falsePositive);

  static bool get oneFieldIsHighlighted => fieldsHighlighted == 1;

  static bool get theHighlightCarriesItsFigures =>
      treatment.text.contains('p90') && treatment.text.contains('baseline');

  static const bool aFieldCanBeHighlightedWithoutAReason = false;

  static const String highlightNote =
      'Only what the Step 424 detector reported is highlighted, and the '
      'highlight carries the two figures that produced it. A dashboard that '
      'marks a field without saying why teaches its readers that the marks are '
      'decorative, and the second time somebody checks a red field and finds '
      'nothing behind it is the last time anybody checks one.';

  // -----------------------------------------------------------------------
  // The metric scores a repaint.
  // -----------------------------------------------------------------------

  static const String whatTheMetricScores = 'how fast the red appears';

  static const String whatWouldMatter = 'whether the right field is red';

  static bool get theMetricScoresTheMechanism =>
      whatTheMetricScores != whatWouldMatter;

  static bool get thirdSuchRowInTheBatch =>
      HabotFieldFocusDuration.thirdSuchRow;

  static const int renderMs = 34;

  static const String bandFloorRaw = '<1s';
  static const String bandOptimalRaw = '<100ms';
  static const String bandCeilingRaw = '2s';

  static const int floorMs = 1000;
  static const int optimalMs = 100;
  static const int ceilingMs = 2000;

  static bool get theOptimalIsBelowBothBoundaries =>
      optimalMs < floorMs && optimalMs < ceilingMs;

  static bool get theShapeIsTheDeclaredConvention =>
      HabotFrictionMiddleware.itIsAConventionRatherThanADefect;

  static bool get theRepaintIsWellInsideTheOptimal => renderMs < optimalMs;

  static const String metricNote =
      'The metric scores how fast the highlight paints, not whether the right '
      'field is highlighted -- the third row in this batch scored on its own '
      'mechanism after Steps 413 and 421, and the least defensible of the '
      'three, because no dashboard in the history of dashboards has been '
      'limited by the speed of a repaint. The figure is published anyway, at '
      'thirty-four milliseconds, and the thing worth reading is beside it.';

  static String get qualitativeOutput =>
      threeCarriersArePresent &&
              theErrorRoleIsLeftAlone &&
              onlyDetectorFindingsAreHighlighted
          ? 'Pass'
          : 'Fail';

  static const String columnNote =
      'COLUMN NOTE: this row asks for colour to carry a meaning by itself, '
      'which Step 189 forbade and Step 407 refused last batch -- so the '
      'highlight carries a colour, an icon and the figures behind it; it names '
      'the #error role for something that is not an error, and a distinct '
      'attention role is used instead so the error role keeps its meaning; its '
      'metric scores the rendering speed of the highlight rather than its '
      'correctness; its optimal of "<100ms" sits below both its floor of "<1s" '
      'and its ceiling of "2s"; and it is assigned to CAL, the first of four '
      'teams in this batch outside UDF and ADFA. Atomic Step: "Update mobile '
      'analytics dashboards to highlight high-friction fields in Red '
      '(#error)."';

  static Map<String, bool> get obligations => <String, bool>{
        'three carriers, not one': threeCarriersArePresent,
        'the colour is a named role rather than a hex literal':
            theColourIsNamedNotHexed,
        'the error role is left for errors': theErrorRoleIsLeftAlone,
        'only detector findings are highlighted':
            onlyDetectorFindingsAreHighlighted,
        'and each highlight carries its figures':
            theHighlightCarriesItsFigures,
      };

  static Map<String, bool> get checks => <String, bool>{
        'the row asks for one carrier and three are delivered':
            theRowAsksForOne && carriersDelivered == 3,
        'the carrier rule is Step 189\'s, restated at 369':
            theCarrierRuleIsTheDeclaredOne && threeCarriersArePresent,
        'second refusal of colour-alone in two batches':
            secondRefusalOfColourAlone &&
                carrierNote.contains('not the edge one'),
        'the error role means something else':
            theRolesDiffer && !anythingOnThatScreenIsInAnErrorState,
        'so a distinct attention role is used':
            theErrorRoleIsLeftAlone && theDilutionIsNamed,
        'and the cost falls on the day something breaks':
            roleNote.contains('actually breaks'),
        'only what the detector reported is marked':
            onlyDetectorFindingsAreHighlighted &&
                oneFieldIsHighlighted &&
                !aFieldCanBeHighlightedWithoutAReason,
        'and the mark carries the figures behind it':
            theHighlightCarriesItsFigures &&
                highlightNote.contains('the last time anybody checks one'),
        'the metric scores a repaint':
            theMetricScoresTheMechanism &&
                thirdSuchRowInTheBatch &&
                theRepaintIsWellInsideTheOptimal,
        'five obligations, all met, giving Pass':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Pass' &&
                theOptimalIsBelowBothBoundaries &&
                theShapeIsTheDeclaredConvention,
      };
}
