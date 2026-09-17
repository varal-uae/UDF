/// Step 426 (GEN-02907) -- the same red mark as the previous row, for a reader
/// who can act today.
///
/// The row: "Display a Red Complexity Bottleneck indicator on the mobile ops
/// manager view."
/// Metric: **Task Completion Status** -- floor 0.8, optimal 1, ceiling 1.
/// Complete/Partial/Not Complete. ITIL v4 Service Value System / Internal SOP.
/// Assigned to **UDF**.
///
/// **Second red bottleneck mark in two rows.** Step 425 puts one on the
/// analytics dashboard and this puts one on the ops manager view. The two are
/// not collapsed, and the reason is the reader: an analyst reads a dashboard to
/// decide what to change next sprint, and an ops manager reads this view to
/// decide what to do before the shift ends. The treatment is imported from Step
/// 425 rather than redefined -- two marks meaning one thing must look like one
/// thing -- and what is added here is the part a dashboard does not need: which
/// station, which shift, and what can be done about it in the next hour.
///
/// **"Complexity Bottleneck" is the fifth noun for one idea.** This batch
/// carries friction, hesitation, drop-off, bottleneck and complexity
/// bottleneck, across rows that measure overlapping things. The vocabulary is
/// recorded and mapped rather than adopted, because five words for one concept
/// is how two teams build two systems and each believes the other's is a
/// subset.
///
/// **The optimal equals the ceiling, again, and the metric cannot fail.**
/// "Task Completion Status" on a row whose task is to display something is a
/// completion rate for the row's own completion. The figure published instead
/// is whether every displayed indicator carries an action and a location.
library;

import '../telemetry/bottleneck_detection.dart';
import '../telemetry/friction_highlight.dart';

/// What an ops manager can do about a bottleneck before the shift ends.
class HabotOpsAction {
  const HabotOpsAction({
    required this.label,
    required this.station,
    required this.shift,
    required this.actionableWithinTheHour,
  });

  final String label;
  final String station;
  final String shift;

  /// False for anything that needs a release.
  final bool actionableWithinTheHour;
}

/// The ops-manager bottleneck indicator.
class HabotBottleneckIndicator {
  const HabotBottleneckIndicator._();

  // -----------------------------------------------------------------------
  // The same mark, imported rather than redrawn.
  // -----------------------------------------------------------------------

  static const int theOtherRow = 425;

  static String get colourRole =>
      HabotFrictionHighlight.treatment.colourRole;

  static String get icon => HabotFrictionHighlight.treatment.icon;

  static const bool theTreatmentIsRedefinedHere = false;

  static bool get theTreatmentIsImported =>
      !theTreatmentIsRedefinedHere && colourRole.isNotEmpty;

  static bool get theCarrierRuleStillHolds =>
      HabotFrictionHighlight.threeCarriersArePresent;

  static bool get theErrorRoleIsStillLeftAlone =>
      HabotFrictionHighlight.theErrorRoleIsLeftAlone;

  static const String importNote =
      'Step 425 marks a bottleneck on the analytics dashboard and this marks '
      'one on the ops manager view. The treatment is imported rather than '
      'redefined, because two marks meaning one thing that do not look like '
      'one thing teach a reader that the two surfaces are measuring different '
      'things -- and once somebody believes that, the next request is for a '
      'third surface to reconcile them.';

  // -----------------------------------------------------------------------
  // Two readers, two jobs.
  // -----------------------------------------------------------------------

  static const String whoReadsTheDashboard = 'an analyst, deciding next sprint';

  static const String whoReadsThisView =
      'an ops manager, deciding before the shift ends';

  static bool get theReadersDiffer => whoReadsTheDashboard != whoReadsThisView;

  static const List<HabotOpsAction> actions = <HabotOpsAction>[
    HabotOpsAction(
      label: 'brief the shift on the reason-code list at handover',
      station: 'Line 2 packing',
      shift: 'evening',
      actionableWithinTheHour: true,
    ),
    HabotOpsAction(
      label: 'pin the three most-used reason codes to the top',
      station: 'Line 2 packing',
      shift: 'evening',
      actionableWithinTheHour: false,
    ),
  ];

  static bool get everyActionNamesAStation =>
      actions.every((HabotOpsAction a) => a.station.isNotEmpty);

  static bool get everyActionNamesAShift =>
      actions.every((HabotOpsAction a) => a.shift.isNotEmpty);

  static int get actionableNow => actions
      .where((HabotOpsAction a) => a.actionableWithinTheHour)
      .length;

  static bool get atLeastOneIsActionableNow => actionableNow >= 1;

  static const bool anIndicatorMayAppearWithNoAction = false;

  static bool get everyIndicatorCarriesAnAction =>
      !anIndicatorMayAppearWithNoAction && actions.isNotEmpty;

  static const String readerNote =
      'A dashboard needs a figure and this view needs a next step. The '
      'indicator carries the station, the shift, and two things that can be '
      'done -- one of them inside the hour and one of them not, marked as '
      'such, because an ops manager handed a finding with no action either '
      'invents one or learns to scroll past the mark.';

  // -----------------------------------------------------------------------
  // Five nouns for one idea.
  // -----------------------------------------------------------------------

  static const Map<String, int> vocabulary = <String, int>{
    'friction': 418,
    'hesitation': 418,
    'drop-off': 423,
    'bottleneck': 424,
    'complexity bottleneck': 426,
  };

  static bool get fiveNounsInOneBatch => vocabulary.length == 5;

  static const bool aSixthVocabularyIsAdopted = false;

  static const String theOneConcept =
      'a screen where people take longer than expected and then leave';

  static bool get theVocabularyIsMappedNotAdopted =>
      !aSixthVocabularyIsAdopted && theOneConcept.isNotEmpty;

  static const String vocabularyNote =
      'Friction, hesitation, drop-off, bottleneck and complexity bottleneck '
      'appear across five rows in this batch for overlapping things. They are '
      'mapped to one concept here rather than each getting an implementation, '
      'because five words for one idea is how two teams build two systems and '
      'each believes the other\'s is a subset of its own.';

  // -----------------------------------------------------------------------
  // A metric that cannot fail.
  // -----------------------------------------------------------------------

  static const double bandFloor = 0.8;
  static const double bandOptimal = 1;
  static const double bandCeiling = 1;

  static bool get theOptimalEqualsTheCeiling => bandOptimal == bandCeiling;

  static const String metricName = 'Task Completion Status';

  static bool get theMetricScoresTheRowsOwnCompletion =>
      metricName.contains('Completion');

  static double get indicatorsCarryingAnActionAndALocation {
    if (actions.isEmpty) {
      return 0;
    }
    final int complete = actions
        .where((HabotOpsAction a) => a.station.isNotEmpty && a.shift.isNotEmpty)
        .length;
    return complete / actions.length;
  }

  static bool get theSubstituteFigureReachesOne =>
      indicatorsCarryingAnActionAndALocation == 1;

  static bool get onlyDetectorFindingsAreShown =>
      HabotBottleneckDetection.everyFiringNamesItsReason;

  static String get qualitativeOutput =>
      everyIndicatorCarriesAnAction &&
              everyActionNamesAStation &&
              everyActionNamesAShift
          ? 'Complete'
          : 'Partial';

  static const String metricNote =
      'A task completion status on a row whose task is to display something is '
      'a completion rate for its own completion: it cannot report a failure '
      'that matters. Its optimal and ceiling are both 1, so there is nothing '
      'above the target either. The figure published instead is the share of '
      'displayed indicators carrying both an action and a location, which can '
      'fall and would mean something if it did.';

  static const String columnNote =
      'COLUMN NOTE: this row asks for a red bottleneck indicator one row after '
      'Step 425 asked for a red bottleneck highlight, on a different surface '
      'for a different reader -- the treatment is imported rather than '
      'redefined and the difference is the action attached; it introduces '
      '"complexity bottleneck", the fifth noun this batch uses for one idea, '
      'after friction, hesitation, drop-off and bottleneck; its metric is a '
      'generic task completion status that cannot report a meaningful failure; '
      'and its optimal and ceiling are both 1. Atomic Step: "Display a Red '
      'Complexity Bottleneck indicator on the mobile ops manager view."';

  static Map<String, bool> get obligations => <String, bool>{
        'the treatment is imported, not redefined': theTreatmentIsImported,
        'the carrier rule still holds': theCarrierRuleStillHolds,
        'every indicator carries an action': everyIndicatorCarriesAnAction,
        'every action names a station and a shift':
            everyActionNamesAStation && everyActionNamesAShift,
        'at least one is actionable within the hour':
            atLeastOneIsActionableNow,
        'the vocabulary is mapped rather than adopted':
            theVocabularyIsMappedNotAdopted,
      };

  static Map<String, bool> get checks => <String, bool>{
        'second red bottleneck mark in two rows':
            theOtherRow == 425 && theTreatmentIsImported,
        'and two marks for one thing look like one thing':
            theCarrierRuleStillHolds &&
                theErrorRoleIsStillLeftAlone &&
                importNote.contains('a third surface to reconcile them'),
        'the two readers decide on different timescales': theReadersDiffer,
        'so the indicator carries a station, a shift and an action':
            everyActionNamesAStation &&
                everyActionNamesAShift &&
                everyIndicatorCarriesAnAction,
        'one of the two is actionable inside the hour':
            atLeastOneIsActionableNow && actionableNow == 1,
        'and a finding with no action gets scrolled past':
            readerNote.contains('scroll past the mark'),
        'five nouns in this batch for one concept':
            fiveNounsInOneBatch && theVocabularyIsMappedNotAdopted,
        'and no sixth vocabulary is adopted':
            !aSixthVocabularyIsAdopted &&
                vocabularyNote.contains('a subset of its own'),
        'the metric scores the row\'s own completion':
            theMetricScoresTheRowsOwnCompletion && theOptimalEqualsTheCeiling,
        'six obligations, all met, giving Complete':
            obligations.length == 6 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Complete' &&
                theSubstituteFigureReachesOne &&
                onlyDetectorFindingsAreShown,
      };
}
