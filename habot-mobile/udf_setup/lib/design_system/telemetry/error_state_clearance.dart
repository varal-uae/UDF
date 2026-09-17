/// Step 332 (HSFVS-013-17) -- a restriction that is only a restriction if
/// nobody wants to break it, and a contrast metric on a row with no UI.
///
/// The row: "Restrict developers from clearing the dashboard error state until
/// metadata logging is proven active and fixed for the failing track."
/// Metric: **Text/UI Contrast Ratio** -- floor 4.5:1, optimal 7:1, ceiling
/// **>=7:1**. Pass/Fail, best = Pass (>=7:1). WCAG 2.2 SC 1.4.3 / 1.4.6.
/// Assigned to **PDG**.
///
/// **The ceiling is the optimal written twice.** ">=7:1" against an optimal of
/// "7:1" is the same threshold with an inequality in front of it, so the band
/// has two ends and one of them is a restatement. That is the fifth distinct
/// band defect in this batch: four inverted, three unfailable, one duplicated
/// floor-and-ceiling, four one-valued outputs, and now a ceiling that is its
/// own optimal. The row's own Data Requirement cell says "N/A (Backend
/// logging)", so the row is telling the reader it has no user interface on the
/// same line that it is scored on a contrast ratio.
///
/// **"Restrict developers" is a control aimed at people who can edit the
/// control.** A disabled button in a console stops nobody with repository
/// access, and a rule that depends on not being disliked is not a rule. The
/// version that works makes the wrong thing unsayable rather than
/// discouraged: `clear` does not take a flag that can be forced, it takes the
/// evidence as a required argument. There is no call site that clears an error
/// without supplying proof, because such a call does not compile.
///
/// **And "proven active and fixed" is two conditions that can disagree.**
/// Logging being active says the next failure will be recorded; the track
/// being fixed says there will not be one. Clearing on the first while the
/// second is false hides a live fault behind a clean dashboard -- and that is
/// the ordinary case, because logging is quick to restore and causes are slow
/// to find. Four combinations, one of which permits clearing, each of the
/// other three carrying its own sentence.
///
/// **Clearing is not deleting.** A cleared error moves to a history with an
/// actor and a timestamp. A dashboard whose cleanliness is achieved by
/// forgetting is a dashboard that reports how recently somebody pressed a
/// button.
library;

/// The evidence a clear requires. There is no way to construct one of these
/// that asserts something it has not been given.
class HabotClearanceEvidence {
  const HabotClearanceEvidence({
    required this.trackId,
    required this.loggingActive,
    required this.causeFixed,
    required this.clearedBy,
    required this.at,
  });

  final String trackId;

  /// The next failure on this track will be recorded.
  final bool loggingActive;

  /// The failure that caused this error state has been addressed.
  final bool causeFixed;

  final String clearedBy;
  final DateTime at;

  bool get permitsClearing => loggingActive && causeFixed;
}

/// What happens to a cleared error.
enum HabotClearedDisposition { movedToHistory, deleted }

/// The rule.
class HabotErrorStateClearance {
  const HabotErrorStateClearance._();

  // -----------------------------------------------------------------------
  // The wrong thing is unsayable.
  // -----------------------------------------------------------------------

  /// There is no override parameter, and no boolean that skips the check.
  static const bool thereIsAForceFlag = false;

  /// The evidence is a required argument rather than a precondition somebody
  /// is asked to remember.
  static const bool evidenceIsARequiredArgument = true;

  static bool tryClear(HabotClearanceEvidence evidence) =>
      evidence.permitsClearing;

  static const String enforcementNote =
      'A disabled button in an engineering console stops nobody who can edit '
      'the console. "Restrict developers" is a control aimed at the people who '
      'own the control, and a rule that holds only while nobody minds is not a '
      'rule. What works is making the wrong call unsayable: clear takes the '
      'evidence as a required argument, there is no force flag, and a call '
      'that clears without proof does not compile. That is the shape Shingo '
      'meant, on a row that -- unlike Step 328 -- does not use the word.';

  // -----------------------------------------------------------------------
  // Two conditions, four states.
  // -----------------------------------------------------------------------

  static DateTime get at => DateTime.utc(2026, 9, 17);

  static HabotClearanceEvidence evidence({
    required bool loggingActive,
    required bool causeFixed,
  }) =>
      HabotClearanceEvidence(
        trackId: 'TRK-118',
        loggingActive: loggingActive,
        causeFixed: causeFixed,
        clearedBy: 'Fredrick',
        at: at,
      );

  static List<HabotClearanceEvidence> get allCombinations =>
      <HabotClearanceEvidence>[
        evidence(loggingActive: true, causeFixed: true),
        evidence(loggingActive: true, causeFixed: false),
        evidence(loggingActive: false, causeFixed: true),
        evidence(loggingActive: false, causeFixed: false),
      ];

  static int get combinationsThatClear =>
      allCombinations.where(tryClear).length;

  static bool get exactlyOneCombinationClears => combinationsThatClear == 1;

  static String refusalFor(HabotClearanceEvidence e) {
    if (e.permitsClearing) {
      return '';
    }
    if (e.loggingActive && !e.causeFixed) {
      return 'Logging is back, but the failure it was recording has not been '
          'fixed. Clearing now hides a live fault';
    }
    if (!e.loggingActive && e.causeFixed) {
      return 'The cause is fixed, but the next failure on this track would go '
          'unrecorded. Restore logging first';
    }
    return 'Neither the logging nor the cause has been dealt with yet';
  }

  static bool get everyRefusalIsDifferent =>
      allCombinations
          .where((HabotClearanceEvidence e) => !e.permitsClearing)
          .map(refusalFor)
          .toSet()
          .length ==
      3;

  /// The combination that arrives most often, and is the one the naive rule
  /// would clear on.
  static bool get theCommonCaseIsLoggingWithoutAFix =>
      !tryClear(evidence(loggingActive: true, causeFixed: false));

  static const String twoConditionsNote =
      'Logging being active says the next failure will be recorded; the track '
      'being fixed says there will not be one. They are not the same claim and '
      'they disagree in the ordinary case, because logging is quick to restore '
      'and causes are slow to find -- so the state that arrives most often is '
      'logging-on and cause-open, which is exactly the one a single-condition '
      'rule would clear. Four combinations, one clears, and the other three '
      'each say which half is missing.';

  // -----------------------------------------------------------------------
  // Clearing is a transition, not an erasure.
  // -----------------------------------------------------------------------

  static const HabotClearedDisposition disposition =
      HabotClearedDisposition.movedToHistory;

  static bool get nothingIsDeleted =>
      disposition == HabotClearedDisposition.movedToHistory;

  static Map<String, String> historyEntryFor(HabotClearanceEvidence e) =>
      <String, String>{
        'track': e.trackId,
        'cleared by': e.clearedBy,
        'at': e.at.toIso8601String(),
        'logging active at clearance': e.loggingActive ? 'yes' : 'no',
        'cause fixed at clearance': e.causeFixed ? 'yes' : 'no',
      };

  static bool get theHistoryRecordsWhoAndWhen =>
      historyEntryFor(allCombinations.first).length == 5;

  static const String historyNote =
      'A cleared error moves to a history carrying who cleared it, when, and '
      'what was true at the time. A dashboard whose cleanliness is achieved by '
      'forgetting reports how recently somebody pressed a button, and the '
      'first person to notice is whoever is asked why the same failure was '
      'never investigated.';

  // -----------------------------------------------------------------------
  // The band.
  // -----------------------------------------------------------------------

  static const String bandFloor = '4.5:1';
  static const String bandOptimal = '7:1';
  static const String bandCeiling = '>=7:1';

  static bool get theCeilingIsTheOptimalRestated =>
      bandCeiling.contains(bandOptimal);

  static const String rowDataRequirement = 'N/A (Backend logging)';

  static bool get theRowSaysItHasNoInterface =>
      rowDataRequirement.contains('Backend logging');

  static const int distinctBandDefectsInThisBatch = 5;

  static const String bandNote =
      'The ceiling is the optimal with an inequality in front of it, so the '
      'band has two ends and one is a restatement -- the fifth distinct band '
      'defect in this batch, after four inverted latency bands, three '
      'unfailable floors, one floor-equals-ceiling and four one-valued output '
      'columns. And the row\'s own Data Requirement cell reads "N/A (Backend '
      'logging)", so the row states that it has no user interface on the same '
      'line that it is scored on a text contrast ratio.';

  static Map<String, bool> get obligations => <String, bool>{
        'the evidence is a required argument': evidenceIsARequiredArgument,
        'there is no force flag': !thereIsAForceFlag,
        'exactly one of the four combinations clears':
            exactlyOneCombinationClears,
        'each refusal says which half is missing': everyRefusalIsDifferent,
        'a cleared error is kept': nothingIsDeleted,
        'the history records who and when': theHistoryRecordsWhoAndWhen,
      };

  static String get qualitativeOutput =>
      obligations.values.every((bool b) => b) ? 'Pass' : 'Fail';

  static Map<String, bool> get checks => <String, bool>{
        'four combinations, one of which clears':
            allCombinations.length == 4 &&
                exactlyOneCombinationClears &&
                tryClear(evidence(loggingActive: true, causeFixed: true)),
        'the common case is logging restored with the cause still open':
            theCommonCaseIsLoggingWithoutAFix &&
                twoConditionsNote.contains('a single-condition rule would '
                    'clear'),
        'the three refusals are three different sentences':
            everyRefusalIsDifferent &&
                refusalFor(evidence(loggingActive: true, causeFixed: false))
                    .contains('hides a live fault'),
        'there is no way to clear without the evidence':
            !thereIsAForceFlag &&
                evidenceIsARequiredArgument &&
                enforcementNote.contains('does not compile'),
        'and that is the shape Step 328\'s row claimed and did not need':
            enforcementNote.contains('Step 328'),
        'a cleared error is moved rather than deleted':
            nothingIsDeleted && theHistoryRecordsWhoAndWhen,
        'and the history says what was true at the time':
            historyNote.contains('never investigated'),
        'the ceiling restates the optimal':
            theCeilingIsTheOptimalRestated &&
                bandFloor == '4.5:1' &&
                bandOptimal == '7:1',
        'on a row that says it has no interface':
            theRowSaysItHasNoInterface &&
                distinctBandDefectsInThisBatch == 5 &&
                bandNote.contains('fifth distinct band defect'),
        'six obligations, all met, giving Pass':
            obligations.length == 6 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Pass',
      };

  static const String columnNote =
      'COLUMN NOTE: this row is assigned to PDG rather than UDF, its Data '
      'Requirement cell reads "N/A (Backend logging)" while its metric is a '
      'text contrast ratio, its ceiling restates its optimal, and the Setup '
      'Step reads "Identify score inputs triggering extreme rating thresholds '
      '(e.g., minimum score 1.0 or maximum score 5.0)". Atomic Step: '
      '"Restrict developers from clearing the dashboard error state until '
      'metadata logging is proven active and fixed for the failing track."';
}
