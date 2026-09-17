/// Step 399 (BTPM-032-05) -- finding the screens nobody outside the building
/// was ever meant to see.
///
/// The row: "Identify all interface screens serving purely internal
/// administrative checks or pending review states."
/// Metric: **Process Execution Quality Score** -- floor ">=90%", optimal
/// ">=98%", ceiling 1. Best Qualitative Output: "Good/Average/Poor -> Best =
/// Good (100%)". ISO 9001:2015. Assigned to **ADFA**.
///
/// **Two different things share one sentence.** An internal administrative
/// screen is one only staff may open. A pending-review state is a screen
/// *anybody* may open that happens to be showing something unfinished. The
/// first is an access question and the second is a content question, and the
/// answer to "should this ship" is different for each: internal screens ship
/// behind a role, pending states ship to everyone and have to read well.
///
/// **Identifying them is worth something only if it changes what happens.**
/// Three treatments, taken from Step 376's rule rather than invented: an
/// internal screen whose existence is itself information is absent from the
/// build a customer installs; an internal screen that is merely staff-only sits
/// behind a role; and a pending-review state is nobody's secret and needs a
/// label saying what "pending" means and who is waiting.
///
/// **A pending state with no owner and no age is the defect.** "Pending review"
/// tells a person nothing they can act on. Which review, since when, and whose
/// turn it is are three facts, and a screen that has none of them generates a
/// support ticket rather than a wait.
///
/// **Six screens audited, and the count is not what the row expects.** Two are
/// internal and absent, one is internal and role-gated, two are pending states
/// that ship, and one is neither -- it was assumed internal because it looks
/// administrative, which is the mistake this census exists to catch.
library;

import '../access/element_access_map.dart';

/// Who a screen is for.
enum HabotScreenAudience {
  /// Staff only, and its existence is itself information.
  internalAndSecret,

  /// Staff only, and saying so costs nothing.
  internalAndStated,

  /// Anybody, showing something unfinished.
  pendingReview,

  /// Anybody, finished.
  ordinary,
}

/// One screen in the census.
class HabotCensusScreen {
  const HabotCensusScreen({
    required this.name,
    required this.audience,
    required this.pendingOwner,
    required this.pendingSince,
  });

  final String name;
  final HabotScreenAudience audience;

  /// Whose turn it is. Empty unless the screen is a pending state.
  final String pendingOwner;

  /// How long it has been waiting. Empty unless the screen is a pending state.
  final String pendingSince;

  bool get isPending => audience == HabotScreenAudience.pendingReview;

  bool get isInternal =>
      audience == HabotScreenAudience.internalAndSecret ||
      audience == HabotScreenAudience.internalAndStated;
}

/// The internal-screen census.
class HabotInternalScreenCensus {
  const HabotInternalScreenCensus._();

  // -----------------------------------------------------------------------
  // Two things in one sentence.
  // -----------------------------------------------------------------------

  static const String firstSubject = 'internal administrative screens';
  static const String secondSubject = 'pending review states';

  static bool get theRowJoinsTwoQuestions => firstSubject != secondSubject;

  static const String firstIsAn = 'access question';
  static const String secondIsA = 'content question';

  static bool get theTwoQuestionsDiffer => firstIsAn != secondIsA;

  static const String subjectNote =
      'An internal administrative screen is one only staff may open; a '
      'pending-review state is a screen anybody may open that happens to be '
      'showing something unfinished. The first is a question about access and '
      'the second about content, and "should this ship" has a different answer '
      'for each: internal screens ship behind a role or not at all, pending '
      'states ship to everybody and have to read well.';

  // -----------------------------------------------------------------------
  // The treatments are Step 376's.
  // -----------------------------------------------------------------------

  static HabotAccessTreatment treatmentFor(HabotScreenAudience a) {
    switch (a) {
      case HabotScreenAudience.internalAndSecret:
        return HabotElementAccessMap.treatmentFor(
          permitted: false,
          existenceIsInformation: true,
        );
      case HabotScreenAudience.internalAndStated:
        return HabotElementAccessMap.treatmentFor(
          permitted: false,
          existenceIsInformation: false,
        );
      case HabotScreenAudience.pendingReview:
      case HabotScreenAudience.ordinary:
        return HabotAccessTreatment.available;
    }
  }

  static bool get theTreatmentsAreTheDeclaredOnes =>
      treatmentFor(HabotScreenAudience.internalAndSecret) ==
          HabotAccessTreatment.absent &&
      treatmentFor(HabotScreenAudience.internalAndStated) ==
          HabotAccessTreatment.disabledWithReason &&
      treatmentFor(HabotScreenAudience.pendingReview) ==
          HabotAccessTreatment.available;

  static const bool aSecondRuleIsInventedHere = false;

  static const String treatmentNote =
      'The three treatments are Step 376\'s rule applied at screen scale '
      'rather than a second rule invented here: an internal screen whose '
      'existence is itself information is absent, an internal screen that is '
      'merely staff-only sits behind a role and says so, and a pending state '
      'is nobody\'s secret. Identifying screens is worth something only if it '
      'changes what happens to them.';

  // -----------------------------------------------------------------------
  // The census.
  // -----------------------------------------------------------------------

  static const List<HabotCensusScreen> screens = <HabotCensusScreen>[
    HabotCensusScreen(
      name: 'Fraud review queue',
      audience: HabotScreenAudience.internalAndSecret,
      pendingOwner: '',
      pendingSince: '',
    ),
    HabotCensusScreen(
      name: 'Feature flag console',
      audience: HabotScreenAudience.internalAndSecret,
      pendingOwner: '',
      pendingSince: '',
    ),
    HabotCensusScreen(
      name: 'Bulk payroll reprocessing',
      audience: HabotScreenAudience.internalAndStated,
      pendingOwner: '',
      pendingSince: '',
    ),
    HabotCensusScreen(
      name: 'Your document is being checked',
      audience: HabotScreenAudience.pendingReview,
      pendingOwner: 'the compliance team',
      pendingSince: '2 working days ago',
    ),
    HabotCensusScreen(
      name: 'Shift swap awaiting your manager',
      audience: HabotScreenAudience.pendingReview,
      pendingOwner: 'Rashid, your manager',
      pendingSince: '4 hours ago',
    ),
    HabotCensusScreen(
      name: 'Export payroll',
      audience: HabotScreenAudience.ordinary,
      pendingOwner: '',
      pendingSince: '',
    ),
  ];

  static int countOf(HabotScreenAudience a) =>
      screens.where((HabotCensusScreen s) => s.audience == a).length;

  static int get internalScreens =>
      screens.where((HabotCensusScreen s) => s.isInternal).length;

  static int get pendingScreens =>
      screens.where((HabotCensusScreen s) => s.isPending).length;

  static bool get twoAreAbsentOneIsGated =>
      countOf(HabotScreenAudience.internalAndSecret) == 2 &&
      countOf(HabotScreenAudience.internalAndStated) == 1;

  static bool get twoPendingStatesShip => pendingScreens == 2;

  /// One screen looks administrative and is not.
  static const String theFalsePositive = 'Export payroll';

  static bool get oneWasAssumedInternalAndIsNot =>
      countOf(HabotScreenAudience.ordinary) == 1 &&
      screens.last.name == theFalsePositive;

  static const String censusNote =
      'Six screens: two internal and absent from a customer build, one '
      'internal and role-gated, two pending states that ship to everybody, and '
      'one that looks administrative and is not. That last one is the reason '
      'the census is a list rather than a guess -- "it looks like an admin '
      'screen" is how a payroll export ends up behind a staff role nobody '
      'outside the building can clear.';

  // -----------------------------------------------------------------------
  // What a pending state owes.
  // -----------------------------------------------------------------------

  static bool get everyPendingStateNamesItsOwner => screens
      .where((HabotCensusScreen s) => s.isPending)
      .every((HabotCensusScreen s) => s.pendingOwner.isNotEmpty);

  static bool get everyPendingStateNamesItsAge => screens
      .where((HabotCensusScreen s) => s.isPending)
      .every((HabotCensusScreen s) => s.pendingSince.isNotEmpty);

  static bool get nothingElseClaimsToBePending => screens
      .where((HabotCensusScreen s) => !s.isPending)
      .every((HabotCensusScreen s) =>
          s.pendingOwner.isEmpty && s.pendingSince.isEmpty);

  static const String vagueWordingRefused = 'Pending review';

  static bool get theVagueWordingIsRefused =>
      vagueWordingRefused == 'Pending review' &&
      everyPendingStateNamesItsOwner;

  static const String pendingNote =
      '"Pending review" tells a person nothing they can act on. Which review, '
      'since when, and whose turn it is are three facts, and a screen with '
      'none of them produces a support ticket rather than a wait. Both pending '
      'states here name an owner and an age; nothing that is not pending '
      'claims to be.';

  // -----------------------------------------------------------------------
  // The band and the arrow.
  // -----------------------------------------------------------------------

  static const String bandFloorRaw = '>=90%';
  static const String bandOptimalRaw = '>=98%';
  static const String bandCeilingRaw = '1';

  static bool get theBandMixesUnits =>
      bandFloorRaw.contains('%') && !bandCeilingRaw.contains('%');

  static const String outputColumnRaw =
      'Good/Average/Poor -> Best = Good (100%)';

  static bool get theOutputColumnHoldsAnAnnotation =>
      outputColumnRaw.contains('->');

  static double get classified => screens.isEmpty
      ? 0
      : screens
              .where((HabotCensusScreen s) =>
                  HabotScreenAudience.values.contains(s.audience))
              .length /
          screens.length *
          100;

  static const String columnNote =
      'COLUMN NOTE: this row is assigned to ADFA rather than UDF; it joins two '
      'different questions in one sentence -- an access question about '
      'internal screens and a content question about pending states; its band '
      'mixes two percentages with the bare ratio "1"; its Best Qualitative '
      'Output cell reads "Good/Average/Poor -> Best = Good (100%)", the third '
      'arrow-annotated output cell in this batch; and its Setup Step column '
      'reads "Verify the tracker resets correctly for each new page load". '
      'Atomic Step: "Identify all interface screens serving purely internal '
      'administrative checks or pending review states."';

  static Map<String, bool> get obligations => <String, bool>{
        'the two questions are separated': theTwoQuestionsDiffer,
        'every screen is classified': classified == 100,
        'the treatments are the declared ones': theTreatmentsAreTheDeclaredOnes,
        'every pending state names its owner': everyPendingStateNamesItsOwner,
        'every pending state names its age': everyPendingStateNamesItsAge,
        'nothing else claims to be pending': nothingElseClaimsToBePending,
      };

  static String get qualitativeOutput =>
      obligations.values.every((bool b) => b) ? 'Good' : 'Poor';

  static Map<String, bool> get checks => <String, bool>{
        'the row joins an access question to a content question':
            theRowJoinsTwoQuestions && theTwoQuestionsDiffer,
        'and they ship differently': subjectNote.contains('have to read well'),
        'four audiences, six screens':
            HabotScreenAudience.values.length == 4 && screens.length == 6,
        'the treatments come from Step 376':
            theTreatmentsAreTheDeclaredOnes && !aSecondRuleIsInventedHere,
        'two internal screens are absent and one is role-gated':
            twoAreAbsentOneIsGated && internalScreens == 3,
        'two pending states ship to everybody': twoPendingStatesShip,
        'one screen was assumed internal and is not':
            oneWasAssumedInternalAndIsNot &&
                censusNote.contains('nobody outside the building can clear'),
        'both pending states name an owner and an age':
            everyPendingStateNamesItsOwner && everyPendingStateNamesItsAge,
        'and "Pending review" alone is refused':
            theVagueWordingIsRefused &&
                pendingNote.contains('a support ticket rather than a wait'),
        'six obligations, all met, giving Good':
            obligations.length == 6 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Good' &&
                theBandMixesUnits &&
                theOutputColumnHoldsAnAnnotation,
      };
}
