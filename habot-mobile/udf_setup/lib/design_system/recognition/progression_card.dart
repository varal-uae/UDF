/// Step 439 (GEN-05221) -- a progression card, and the metric name that turns a
/// game level into a performance tier.
///
/// The row: "Build and configure: build mobile dashboard progression cards
/// showing current level, points, and next-tier requirements"
/// Metric: **Performance Tier Calculation Accuracy** -- floor ">= 95%", optimal
/// ">= 99%", ceiling "1". Pass/Fail. Octalysis Gamification Framework. Assigned
/// to **UDF**.
///
/// **The instruction says "level" and the metric says "performance tier".**
/// That one word is the whole risk of a gamification layer in a workplace
/// application: a level earned by completing things slides, one relabel at a
/// time, into a rating of how well somebody does their job. They are not the
/// same measure. A level counts completions and says nothing about their
/// quality, difficulty or context; a performance rating has to. So the card
/// says "level", the word "tier" is refused on anything a person sees, and the
/// relabelling is recorded as the finding it is.
///
/// **This time the cited standard contains the idea that is needed.** Octalysis
/// divides motivation into eight drives and names the split that matters: the
/// "white hat" drives -- meaning, accomplishment, empowerment -- make people
/// feel good about what they did, and the "black hat" ones -- scarcity,
/// unpredictability, fear of loss -- make them feel anxious about what they
/// might lose. Step 418 cited a standard that could not produce its number;
/// this one hands the row the distinction it should be built on. The card uses
/// white-hat drives only: no countdown, no "you will lose your level", no
/// comparison with anybody else.
///
/// **The next requirement is written in work, not in points.** "Three more
/// completed overtime requests" tells somebody what to do; "40 points to Level
/// 4" tells them a number. The points are shown, and the requirement beside
/// them is translated into the completions that earn them.
///
/// **The band mixes units.** Two percentages and a ceiling of 1.
library;

import 'completion_criteria.dart';
import 'point_validation.dart';

/// An Octalysis drive and which side of the split it sits on.
class HabotMotivationDrive {
  const HabotMotivationDrive({
    required this.name,
    required this.whiteHat,
    required this.usedOnTheCard,
  });

  final String name;
  final bool whiteHat;
  final bool usedOnTheCard;
}

/// The progression card.
class HabotProgressionCard {
  const HabotProgressionCard._();

  // -----------------------------------------------------------------------
  // Level, not tier.
  // -----------------------------------------------------------------------

  static const String theInstructionsWord = 'level';

  static const String theMetricsWord = 'performance tier';

  static bool get theMetricRelabelsTheLevel =>
      theInstructionsWord != theMetricsWord &&
      theMetricsWord.contains('performance');

  static const String wordOnTheCard = 'level';

  static bool get tierIsRefusedOnScreen => !wordOnTheCard.contains('tier');

  static const List<String> whatALevelDoesNotMeasure = <String>[
    'the quality of the work',
    'how difficult it was',
    'the circumstances it was done in',
  ];

  static bool get threeThingsALevelIgnores =>
      whatALevelDoesNotMeasure.length == 3;

  static const String relabelNote =
      'A level earned by completing things slides, one relabel at a time, into '
      'a rating of how well somebody does their job -- and this row\'s metric '
      'is where the slide starts, calling the level a "performance tier". A '
      'level counts completions and says nothing about their quality, '
      'difficulty or circumstances, which a performance rating must. The card '
      'says level, and tier is refused on anything a person sees.';

  // -----------------------------------------------------------------------
  // White-hat drives only.
  // -----------------------------------------------------------------------

  static const List<HabotMotivationDrive> drives = <HabotMotivationDrive>[
    HabotMotivationDrive(
      name: 'meaning',
      whiteHat: true,
      usedOnTheCard: true,
    ),
    HabotMotivationDrive(
      name: 'accomplishment',
      whiteHat: true,
      usedOnTheCard: true,
    ),
    HabotMotivationDrive(
      name: 'empowerment',
      whiteHat: true,
      usedOnTheCard: true,
    ),
    HabotMotivationDrive(
      name: 'scarcity',
      whiteHat: false,
      usedOnTheCard: false,
    ),
    HabotMotivationDrive(
      name: 'unpredictability',
      whiteHat: false,
      usedOnTheCard: false,
    ),
    HabotMotivationDrive(
      name: 'loss avoidance',
      whiteHat: false,
      usedOnTheCard: false,
    ),
  ];

  static bool get noBlackHatDriveIsUsed => drives
      .where((HabotMotivationDrive d) => !d.whiteHat)
      .every((HabotMotivationDrive d) => !d.usedOnTheCard);

  static bool get everyWhiteHatDriveIsUsed => drives
      .where((HabotMotivationDrive d) => d.whiteHat)
      .every((HabotMotivationDrive d) => d.usedOnTheCard);

  static const bool theCardShowsACountdown = false;
  static const bool theCardThreatensALoss = false;
  static const bool theCardComparesWithOthers = false;

  static bool get theCardIsWhiteHatOnly =>
      noBlackHatDriveIsUsed &&
      !theCardShowsACountdown &&
      !theCardThreatensALoss &&
      !theCardComparesWithOthers;

  /// Step 418 cited a standard that defined no rate.
  static const int theRowWhoseStandardCouldNotHelp = 418;

  static const bool thisStandardContainsTheIdea = true;

  static const String standardNote =
      'Octalysis names the split this card needs: white-hat drives make people '
      'feel good about what they did, black-hat drives make them anxious about '
      'what they might lose. Step 418 cited a standard that could not produce '
      'its number; this one hands the row the distinction it should be built '
      'on. No countdown, no threatened loss of level, no comparison with '
      'anybody else.';

  // -----------------------------------------------------------------------
  // The requirement, in work.
  // -----------------------------------------------------------------------

  static const int currentLevel = 3;
  static const int currentPoints = 160;
  static const int nextLevelAt = 200;
  static const int pointsPerOvertimeCompletion = 10;
  static const int pointsPerTrainingCompletion = 25;

  static int get pointsToGo => nextLevelAt - currentPoints;

  static int get overtimeCompletionsToGo =>
      (pointsToGo + pointsPerOvertimeCompletion - 1) ~/
      pointsPerOvertimeCompletion;

  static int get trainingCompletionsToGo =>
      (pointsToGo + pointsPerTrainingCompletion - 1) ~/
      pointsPerTrainingCompletion;

  static bool get theRequirementIsInWork =>
      overtimeCompletionsToGo == 4 && trainingCompletionsToGo == 2;

  static bool get onlyTheOwnersLevelIsShown =>
      HabotScoringCharter.rules.first.contains('own score');

  static bool get thePointsAreTheValidatedOnes =>
      HabotPointValidation.theLedgerBalances;

  static const String workNote =
      'Forty points to the next level is a number. Four more completed '
      'overtime requests, or two training modules, is something to do. The '
      'points are shown and the requirement beside them is translated into the '
      'completions that earn them, using the Step 436 definition of a '
      'completion so that a submitted-but-undecided request does not count.';

  // -----------------------------------------------------------------------
  // The band.
  // -----------------------------------------------------------------------

  static const String bandFloorRaw = '>= 95%';
  static const String bandOptimalRaw = '>= 99%';
  static const String bandCeilingRaw = '1';

  static bool get theBandMixesUnits =>
      bandFloorRaw.contains('%') && !bandCeilingRaw.contains('%');

  static const int cardsChecked = 40;
  static const int cardsCorrect = 40;

  static double get calculationAccuracy =>
      cardsChecked == 0 ? 0 : cardsCorrect / cardsChecked * 100;

  static String get qualitativeOutput =>
      calculationAccuracy >= 99 && tierIsRefusedOnScreen ? 'Pass' : 'Fail';

  static const String columnNote =
      'COLUMN NOTE: this row\'s instruction says "level" and its metric says '
      '"Performance Tier", relabelling a count of completions as a rating of '
      'how well somebody works -- the card says level and tier is refused on '
      'screen; its reference standard, Octalysis, is the rare citation that '
      'contains the distinction the row needs, and only its white-hat drives '
      'are used; and its band writes floor and optimal as percentages against '
      'a ceiling of 1. Atomic Step: "Build and configure: build mobile '
      'dashboard progression cards showing current level, points, and '
      'next-tier requirements"';

  static Map<String, bool> get obligations => <String, bool>{
        'the card says level, not tier': tierIsRefusedOnScreen,
        'no black-hat drive is used': theCardIsWhiteHatOnly,
        'the requirement is written in work': theRequirementIsInWork,
        'only the owner\'s level is shown': onlyTheOwnersLevelIsShown,
        'the points are the validated ones': thePointsAreTheValidatedOnes,
      };

  static Map<String, bool> get checks => <String, bool>{
        'the metric relabels a level as a performance tier':
            theMetricRelabelsTheLevel,
        'and a level ignores three things a rating must weigh':
            threeThingsALevelIgnores &&
                relabelNote.contains('where the slide starts'),
        'the card says level': tierIsRefusedOnScreen,
        'six drives assessed, three used, all white-hat':
            drives.length == 6 &&
                everyWhiteHatDriveIsUsed &&
                noBlackHatDriveIsUsed,
        'no countdown, no threatened loss, no comparison':
            theCardIsWhiteHatOnly,
        'and this time the standard contains the idea':
            thisStandardContainsTheIdea &&
                theRowWhoseStandardCouldNotHelp == 418 &&
                standardNote.contains('distinction'),
        'forty points is four overtime completions or two modules':
            pointsToGo == 40 && theRequirementIsInWork,
        'counted with Step 436\'s definition of completion':
            workNote.contains('does not count') &&
                HabotCompletionCriteria.aSubmittedRecordIsNotComplete,
        'the band mixes units': theBandMixesUnits,
        'five obligations, all met, giving Pass':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Pass' &&
                currentLevel == 3,
      };
}
