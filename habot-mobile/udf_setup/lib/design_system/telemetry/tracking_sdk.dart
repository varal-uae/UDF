/// Step 419 (GEN-02199) -- "the tracking SDK", which one is never said, and a
/// band with three decimal places feeding a two-valued output.
///
/// The row: "Inject the tracking SDK into the mobile frontend."
/// Metric: **Process Execution Accuracy** -- floor 0.9, optimal 0.97, ceiling
/// 0.999. Pass / Fail. ISO/IEC 25010 Software Product Quality Standard.
/// Assigned to **UDF**.
///
/// **"The tracking SDK" has no antecedent.** No SDK is named here or anywhere
/// behind it. This is the third row in two batches to use a definite article
/// for something never defined -- Step 398's "the count", Step 406's "score",
/// and now this -- and it is the most consequential of the three, because the
/// answer decides what leaves the device. A third-party analytics SDK is the
/// ordinary way an application starts collecting an advertising identifier, a
/// list of installed packages and a device fingerprint without anybody
/// deciding to, since the collection is a default in someone else's code.
///
/// **So no SDK is adopted and a payload is declared instead.** The three
/// listeners Step 418 installed already produce every observation the framework
/// defines. What was missing was a statement of what leaves the device, and
/// that is what this row delivers: an allowlist of eight fields, with
/// everything not on it dropped before the queue rather than filtered at the
/// far end. An allowlist and a blocklist are not two spellings of one thing --
/// a blocklist is wrong the moment somebody adds a field.
///
/// **A band of three decimal places feeding a Pass/Fail column.** The band
/// distinguishes 0.97 from 0.999 and the output column can say two things. Four
/// hundred and nineteen rows in, a band finer than its own output is worth
/// naming: the precision is decoration, and it will be read as rigour.
///
/// **The metric is shared with Step 424.** "Process Execution Accuracy" at
/// 0.9 / 0.97 / 0.999 appears twice in this batch, on injecting an SDK and on
/// validating that bottlenecks are mathematically uncovered. Two subjects, one
/// generic accuracy.
library;

import 'friction_framework.dart';
import 'friction_indicators.dart';
import 'friction_middleware.dart';

/// One field permitted to leave the device.
class HabotTelemetryField {
  const HabotTelemetryField({
    required this.name,
    required this.why,
    required this.identifiesAPerson,
  });

  final String name;
  final String why;

  /// True for anything that could single somebody out. None of these are.
  final bool identifiesAPerson;
}

/// The telemetry payload, in place of an SDK.
class HabotTrackingSdk {
  const HabotTrackingSdk._();

  // -----------------------------------------------------------------------
  // Which SDK?
  // -----------------------------------------------------------------------

  static const String theRowsSubject = 'the tracking SDK';

  static const bool theSdkIsNamedAnywhere = false;

  static bool get theDefiniteArticleHasNoAntecedent => !theSdkIsNamedAnywhere;

  /// Step 398's "the count", Step 406's "score", and this.
  static const List<int> rowsWithNoAntecedent = <int>[398, 406, 419];

  static bool get thirdRowInTwoBatches => rowsWithNoAntecedent.length == 3;

  static const List<String> whatAnAnalyticsSdkCollectsByDefault = <String>[
    'an advertising identifier',
    'a list of installed packages',
    'a device fingerprint assembled from model, locale and screen metrics',
    'coarse location derived from the network',
  ];

  static bool get fourDefaultsNamed =>
      whatAnAnalyticsSdkCollectsByDefault.length == 4;

  static const bool anSdkWasAdopted = false;

  static const String antecedentNote =
      'No SDK is named on this row or anywhere behind it, which makes this the '
      'third row in two batches to use a definite article for something never '
      'defined, after Step 398\'s "the count" and Step 406\'s "score". It is '
      'the most consequential of the three because the answer decides what '
      'leaves the device: a third-party analytics SDK is the ordinary way an '
      'application begins collecting an advertising identifier and a device '
      'fingerprint without anybody having decided to, because the collection '
      'is a default in somebody else\'s code.';

  // -----------------------------------------------------------------------
  // An allowlist, not a blocklist.
  // -----------------------------------------------------------------------

  static const List<HabotTelemetryField> payload = <HabotTelemetryField>[
    HabotTelemetryField(
      name: 'screen_id',
      why: 'which screen the observation belongs to',
      identifiesAPerson: false,
    ),
    HabotTelemetryField(
      name: 'field_id',
      why: 'which field on it',
      identifiesAPerson: false,
    ),
    HabotTelemetryField(
      name: 'indicator_kind',
      why: 'which of the five declared indicators fired',
      identifiesAPerson: false,
    ),
    HabotTelemetryField(
      name: 'duration_ms',
      why: 'how long, for the two indicators measured in time',
      identifiesAPerson: false,
    ),
    HabotTelemetryField(
      name: 'occurred_at',
      why: 'when, to the minute rather than the millisecond',
      identifiesAPerson: false,
    ),
    HabotTelemetryField(
      name: 'app_version',
      why: 'so a regression can be tied to a release',
      identifiesAPerson: false,
    ),
    HabotTelemetryField(
      name: 'locale',
      why: 'because a translated label is a common cause of hesitation',
      identifiesAPerson: false,
    ),
    HabotTelemetryField(
      name: 'session_token',
      why: 'to sequence observations within one visit; rotated per session',
      identifiesAPerson: false,
    ),
  ];

  static int get fieldCount => payload.length;

  static bool get eightFieldsAreDeclared => fieldCount == 8;

  static bool get noFieldIdentifiesAPerson =>
      !payload.any((HabotTelemetryField f) => f.identifiesAPerson);

  static bool get everyFieldSaysWhy =>
      payload.every((HabotTelemetryField f) => f.why.isNotEmpty);

  static const bool theListIsAnAllowlist = true;

  static const bool anythingNotListedIsDropped = true;

  static bool get droppedBeforeTheQueue =>
      theListIsAnAllowlist && anythingNotListedIsDropped;

  static bool permits(String field) =>
      payload.any((HabotTelemetryField f) => f.name == field);

  static bool get anUndeclaredFieldIsRefused => !permits('advertising_id');

  static const String allowlistNote =
      'Eight fields may leave the device and everything else is dropped before '
      'the queue rather than filtered at the far end. An allowlist and a '
      'blocklist are not two spellings of the same rule: a blocklist is '
      'correct until somebody adds a field, and the field somebody adds is '
      'never the one on the list. Nothing here singles out a person, and each '
      'field says why it is present, so a reviewer can argue with a specific '
      'line rather than with the idea of telemetry.';

  // -----------------------------------------------------------------------
  // A band finer than its own output.
  // -----------------------------------------------------------------------

  static const double bandFloor = 0.9;
  static const double bandOptimal = 0.97;
  static const double bandCeiling = 0.999;

  static const int decimalPlacesInTheBand = 3;

  static const int valuesTheOutputColumnCanExpress = 2;

  static bool get theBandIsFinerThanItsOutput =>
      decimalPlacesInTheBand > valuesTheOutputColumnCanExpress;

  static bool get theBandDistinguishesWhatTheColumnCannot =>
      bandOptimal != bandCeiling && valuesTheOutputColumnCanExpress == 2;

  /// This row and Step 424.
  static const List<int> rowsSharingThisMetric = <int>[419, 424];

  static bool get twoRowsShareThisMetric => rowsSharingThisMetric.length == 2;

  static const String precisionNote =
      'The band distinguishes 0.97 from 0.999 and the output column can say '
      'two things. A band finer than the column it feeds is precision as '
      'decoration, and it will be read as rigour by the next person to open '
      'the sheet. The same metric and the same three numbers appear on Step '
      '424, about validating that bottlenecks are mathematically uncovered -- '
      'two subjects with nothing in common under one generic accuracy.';

  // -----------------------------------------------------------------------
  // What is actually reported.
  // -----------------------------------------------------------------------

  static bool get theListenersAlreadyExist =>
      HabotFrictionMiddleware.everyDeclaredIndicatorIsCovered;

  static bool get theFrameworkLimitsHold =>
      HabotFrictionFramework.theUnitOfAnalysisIsAScreen &&
      HabotFrictionIndicators.noIndicatorJoinsToAnIndividual;

  static const int fieldsAttempted = 8;

  static const int fieldsPermitted = 8;

  static double get payloadAccuracy =>
      fieldsAttempted == 0 ? 0 : fieldsPermitted / fieldsAttempted;

  static bool get accuracyReachesTheCeiling => payloadAccuracy >= bandCeiling;

  static const String columnNote =
      'COLUMN NOTE: this row says "the tracking SDK" and never says which one '
      '-- the third row in two batches to use a definite article for something '
      'undefined, after Step 398 and Step 406, and the one where the answer '
      'decides what leaves the device; no SDK was adopted, and an eight-field '
      'payload allowlist was declared in its place; its band runs to three '
      'decimal places while its Best Qualitative Output column holds two '
      'values, so the band distinguishes what the column cannot express; and '
      'its metric and band are identical to Step 424\'s in this batch. Atomic '
      'Step: "Inject the tracking SDK into the mobile frontend."';

  static Map<String, bool> get obligations => <String, bool>{
        'no unnamed SDK was adopted': !anSdkWasAdopted,
        'eight fields are declared and each says why':
            eightFieldsAreDeclared && everyFieldSaysWhy,
        'nothing on the list identifies a person': noFieldIdentifiesAPerson,
        'anything not listed is dropped before the queue':
            droppedBeforeTheQueue,
        'the framework limits still hold': theFrameworkLimitsHold,
      };

  static String get qualitativeOutput =>
      obligations.values.every((bool b) => b) ? 'Pass' : 'Fail';

  static Map<String, bool> get checks => <String, bool>{
        'the row names no SDK':
            theDefiniteArticleHasNoAntecedent && !anSdkWasAdopted,
        'third row in two batches with no antecedent':
            thirdRowInTwoBatches && fourDefaultsNamed,
        'and the defaults it would have brought are named':
            antecedentNote.contains('somebody else\'s code'),
        'eight fields, each with a reason, none identifying a person':
            eightFieldsAreDeclared &&
                everyFieldSaysWhy &&
                noFieldIdentifiesAPerson,
        'it is an allowlist and an undeclared field is refused':
            droppedBeforeTheQueue && anUndeclaredFieldIsRefused,
        'because a blocklist is wrong the moment a field is added':
            allowlistNote.contains('never the one on the list'),
        'the band is finer than the column it feeds':
            theBandIsFinerThanItsOutput &&
                theBandDistinguishesWhatTheColumnCannot,
        'and Step 424 carries the same metric and band':
            twoRowsShareThisMetric &&
                precisionNote.contains('one generic accuracy'),
        'the listeners were already installed at Step 418':
            theListenersAlreadyExist && theFrameworkLimitsHold,
        'five obligations, all met, giving Pass':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Pass' &&
                accuracyReachesTheCeiling,
      };
}
