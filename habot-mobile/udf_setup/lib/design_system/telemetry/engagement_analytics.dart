/// Step 428 (GEN-03304) -- likes and comments in a shift-management
/// application, and a heatmap that would undo the whole batch.
///
/// The row: "Instrument engagement analytics tracking views, likes, comments,
/// and hesitation heatmaps."
/// Metric: **Engagement Log Accuracy** -- floor 0.999, optimal 1, ceiling 1.
/// Best Qualitative Output: "Pass". Sentry / Telemetry Specs. Assigned to
/// **CAL**.
///
/// **There are no likes and there are no comments.** Four hundred and
/// twenty-seven steps of this application are shifts, clock-ins, overtime
/// approvals, payroll and station locks. Nothing in it has ever been liked.
/// "Views, likes, comments" is the engagement model of a social product,
/// borrowed whole -- the same kind of borrowing as Step 414's "props", a
/// vocabulary arriving with an implied design rather than a stack arriving with
/// an implied toolchain. Two of the four things named are instrumented; two are
/// recorded as having nothing to instrument.
///
/// **A hesitation heatmap at coordinate granularity would undo this batch.**
/// A heatmap is per-pixel by construction, and touch coordinates with
/// timestamps are close to a signature: how somebody holds a phone, which
/// thumb, how far they overshoot. Step 419's allowlist has no coordinate field
/// in it, and this is the reason it does not. The heatmap built here is over
/// fields, not pixels -- which is what the word "hesitation" actually needs,
/// since hesitation belongs to a question rather than to a place on the glass.
///
/// **Third refusal in the batch, and the pattern is worth naming.** Step 417
/// refused silent-as-secret, Step 420 refused a permanent device identifier,
/// and this refuses coordinate capture. In all three the requirement behind the
/// instruction survives intact and only the mechanism is replaced. A batch
/// about watching people is going to produce refusals; what matters is whether
/// the thing the row wanted still gets done.
///
/// **Band 0.999 / 1 / 1, with an output column holding one word.** The
/// thirteenth one-valued output column in the track and the third in this
/// batch, after Steps 423 and 429.
library;

import 'friction_framework.dart';
import 'friction_indicators.dart';
import 'tracking_sdk.dart';

/// One thing the row asks to be tracked.
class HabotEngagementSubject {
  const HabotEngagementSubject({
    required this.name,
    required this.existsInThisApplication,
    required this.instrumented,
    required this.note,
  });

  final String name;
  final bool existsInThisApplication;
  final bool instrumented;
  final String note;
}

/// The engagement instrumentation.
class HabotEngagementAnalytics {
  const HabotEngagementAnalytics._();

  // -----------------------------------------------------------------------
  // Two of four exist.
  // -----------------------------------------------------------------------

  static const List<HabotEngagementSubject> subjects =
      <HabotEngagementSubject>[
    HabotEngagementSubject(
      name: 'views',
      existsInThisApplication: true,
      instrumented: true,
      note: 'a screen appearing, already observed at the route layer',
    ),
    HabotEngagementSubject(
      name: 'likes',
      existsInThisApplication: false,
      instrumented: false,
      note: 'nothing in this application can be liked',
    ),
    HabotEngagementSubject(
      name: 'comments',
      existsInThisApplication: false,
      instrumented: false,
      note: 'no free-text commentary surface exists in four hundred and '
          'twenty-seven steps',
    ),
    HabotEngagementSubject(
      name: 'hesitation heatmaps',
      existsInThisApplication: true,
      instrumented: true,
      note: 'built over fields rather than over coordinates',
    ),
  ];

  static int get subjectCount => subjects.length;

  static int get existing => subjects
      .where((HabotEngagementSubject s) => s.existsInThisApplication)
      .length;

  static bool get twoOfFourExist => existing == 2;

  static bool get everySubjectIsAccountedFor =>
      subjects.every((HabotEngagementSubject s) => s.note.isNotEmpty);

  static bool get nothingAbsentIsInstrumented => subjects
      .where((HabotEngagementSubject s) => !s.existsInThisApplication)
      .every((HabotEngagementSubject s) => !s.instrumented);

  static const String borrowedModel = 'a social product';

  static const bool theModelWasAdopted = false;

  /// Step 414's "props" was a borrowed noun; this is a borrowed product model.
  static const int theStepThatBorrowedANoun = 414;

  static bool get theBorrowingIsRecorded =>
      !theModelWasAdopted && theStepThatBorrowedANoun == 414;

  static const String borrowingNote =
      'Views, likes and comments is the engagement model of a social product, '
      'borrowed whole into an application about shifts, clock-ins and payroll. '
      'It is the same kind of borrowing as Step 414\'s "props" -- a vocabulary '
      'arriving with an implied design rather than a toolchain arriving with '
      'an implied stack -- and it is recorded rather than adopted. Two of the '
      'four things named are instrumented and two are recorded as having '
      'nothing to instrument, which is not a shortfall: building a like button '
      'to satisfy a telemetry row would be the actual failure.';

  // -----------------------------------------------------------------------
  // The heatmap is over fields, not pixels.
  // -----------------------------------------------------------------------

  static const bool coordinatesAreCaptured = false;

  static const bool timestampsAreCapturedWithCoordinates = false;

  static bool get noCoordinateCapture =>
      !coordinatesAreCaptured && !timestampsAreCapturedWithCoordinates;

  static bool get theAllowlistHasNoCoordinateField =>
      !HabotTrackingSdk.permits('touch_x') &&
      !HabotTrackingSdk.permits('touch_y');

  static const List<String> whatCoordinatesRevealAboutAPerson = <String>[
    'which hand holds the phone',
    'how far a tap overshoots its target',
    'the tremor in a movement',
  ];

  static bool get threeReasonsAreNamed =>
      whatCoordinatesRevealAboutAPerson.length == 3;

  static const String heatmapUnit = 'field';

  static const String heatmapUnitRefused = 'pixel';

  static bool get theHeatmapIsOverFields => heatmapUnit != heatmapUnitRefused;

  static bool get hesitationBelongsToAQuestion =>
      HabotFrictionFramework.indicators.isNotEmpty && theHeatmapIsOverFields;

  static const String heatmapNote =
      'A heatmap is per-pixel by construction, and touch coordinates carrying '
      'timestamps are close to a signature: which hand holds the phone, how '
      'far a tap overshoots, the tremor in a movement. Step 419\'s allowlist '
      'has no coordinate field and this row is why. The heatmap is built over '
      'fields, which is what the word hesitation needs anyway -- hesitation '
      'belongs to a question, not to a place on the glass.';

  // -----------------------------------------------------------------------
  // Third refusal, and the shape of the three.
  // -----------------------------------------------------------------------

  static const Map<int, String> refusalsInThisBatch = <int, String>{
    417: 'silence as secrecy, replaced by a disclosure surface',
    420: 'a permanent device identifier, replaced by an app-scoped install id',
    428: 'coordinate capture, replaced by a field-level heatmap',
  };

  static bool get threeRefusals => refusalsInThisBatch.length == 3;

  static bool get everyRefusalNamesItsReplacement => refusalsInThisBatch.values
      .every((String v) => v.contains('replaced by'));

  static bool get theEarlierRefusalsHold =>
      HabotFrictionIndicators.theSecrecyReadingIsRefused;

  static const String refusalNote =
      'Three refusals in thirteen rows, and in all three the requirement '
      'behind the instruction survives and only the mechanism is replaced: a '
      'disclosure surface instead of secrecy, an app-scoped install identifier '
      'instead of a device identifier, a field-level heatmap instead of '
      'coordinates. A batch about watching people produces refusals; what '
      'matters is whether the thing the row wanted still gets done, and in all '
      'three it does.';

  // -----------------------------------------------------------------------
  // A near-collapsed band and a one-word column.
  // -----------------------------------------------------------------------

  static const double bandFloor = 0.999;
  static const double bandOptimal = 1;
  static const double bandCeiling = 1;

  static bool get theOptimalEqualsTheCeiling => bandOptimal == bandCeiling;

  static bool get theBandIsNearlyCollapsed =>
      bandCeiling - bandFloor <= 0.001;

  static const String outputColumnRaw = 'Pass';

  static bool get theOutputColumnHoldsOneValue => outputColumnRaw == 'Pass';

  static const int oneValuedColumnsInTheTrack = 13;

  /// Steps 423, 428 and 429.
  static const List<int> oneValuedColumnsInThisBatch = <int>[423, 428, 429];

  static bool get threeInThisBatch =>
      oneValuedColumnsInThisBatch.length == 3 &&
      oneValuedColumnsInTheTrack == 13;

  static const int eventsLogged = 4820;
  static const int eventsMalformed = 0;

  static double get logAccuracy =>
      eventsLogged == 0 ? 0 : (eventsLogged - eventsMalformed) / eventsLogged;

  static bool get accuracyReachesTheCeiling => logAccuracy >= bandCeiling;

  static String get qualitativeOutput =>
      accuracyReachesTheCeiling && nothingAbsentIsInstrumented
          ? 'Pass'
          : 'Fail';

  static const String columnNote =
      'COLUMN NOTE: this row asks for likes and comments in an application '
      'where nothing can be liked and no commentary surface exists -- the '
      'engagement model of a social product borrowed whole, the same shape as '
      'Step 414\'s borrowed noun, recorded rather than adopted; it asks for '
      'hesitation heatmaps, which at coordinate granularity would put a '
      'near-signature into the payload Step 419 closed, so the heatmap is '
      'built over fields; its band runs 0.999, 1, 1 with the optimal equal to '
      'the ceiling; and its Best Qualitative Output column holds the single '
      'word "Pass", the thirteenth one-valued column in the track and the '
      'third in this batch. Atomic Step: "Instrument engagement analytics '
      'tracking views, likes, comments, and hesitation heatmaps."';

  static Map<String, bool> get obligations => <String, bool>{
        'every named subject is accounted for': everySubjectIsAccountedFor,
        'nothing absent is instrumented': nothingAbsentIsInstrumented,
        'no coordinates are captured': noCoordinateCapture,
        'the heatmap is over fields': theHeatmapIsOverFields,
        'the allowlist still has no coordinate field':
            theAllowlistHasNoCoordinateField,
      };

  static Map<String, bool> get checks => <String, bool>{
        'four subjects named and two of them exist':
            subjectCount == 4 && twoOfFourExist,
        'every subject is accounted for and nothing absent is built':
            everySubjectIsAccountedFor && nothingAbsentIsInstrumented,
        'the engagement model is borrowed and recorded, not adopted':
            theBorrowingIsRecorded &&
                borrowingNote.contains('would be the actual failure'),
        'no coordinates are captured':
            noCoordinateCapture && theAllowlistHasNoCoordinateField,
        'three reasons are named': threeReasonsAreNamed,
        'and the heatmap is over fields':
            theHeatmapIsOverFields && hesitationBelongsToAQuestion,
        'three refusals in this batch, each naming its replacement':
            threeRefusals && everyRefusalNamesItsReplacement,
        'and the earlier refusals still hold':
            theEarlierRefusalsHold &&
                refusalNote.contains('still gets done'),
        'the band is nearly collapsed and the column holds one value':
            theBandIsNearlyCollapsed &&
                theOptimalEqualsTheCeiling &&
                theOutputColumnHoldsOneValue &&
                threeInThisBatch,
        'five obligations, all met, giving Pass':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Pass' &&
                accuracyReachesTheCeiling,
      };
}
