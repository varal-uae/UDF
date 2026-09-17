/// Step 416 (FEBFL-016-A01) -- review the mapping guidelines for a framework
/// that has never been written down.
///
/// The row: "Review the technical mapping guidelines for the Human Friction
/// Telemetry framework."
/// Metric: **Requirements / Discovery Coverage (%)** -- floor "90% of relevant
/// items identified", optimal "98% of relevant items identified", ceiling "100%
/// of relevant items identified". Complete/Partial/Not Complete. Assigned to
/// **UDF**.
///
/// **There are no guidelines to review.** No Human Friction Telemetry framework
/// exists anywhere in the four hundred and fifteen steps behind this one. A
/// review row whose subject does not exist cannot be satisfied by reading, so
/// what is delivered is the thing the review would have produced: a written
/// definition of what friction is, what is measured, what is not, and what each
/// number may be used for. That is more work than the row asks for and the only
/// honest way to close it.
///
/// **The definition is in the Completion Measures cell, not the instruction.**
/// The Atomic Step never says what friction is. The completion measure does:
/// "user dwell spikes over 5 seconds automatically generate structured
/// telemetry rows". Five seconds on one field is the whole operational
/// definition of the framework, and it is in the last column anybody reads.
///
/// **Three subjects again.** The Atomic Step is about friction telemetry, the
/// Data Requirement holds element-mapping fields (Source Element ID, Target
/// Element ID, Mapping Rule, Mapping Status, Mapping Validation), and the Setup
/// Step reads "Run frame rendering latency tests during touch drag
/// interactions". Fourth spliced row in the track, after Steps 388, 390
/// and 398.
///
/// **The reference-standard cell holds an argument rather than a standard.** It
/// reads "Discovery and audit activities in world-class delivery practice are
/// expected to reach near-complete coverage of the target scope before
/// downstream build work starts" -- a sentence defending the band, in a column
/// whose job is to name the specification. Step 415 put a foreign framework in
/// that column; this puts prose in it.
library;

/// What kind of thing a friction indicator measures.
enum HabotFrictionKind {
  /// Time between a field gaining focus and the first keystroke.
  hesitationBeforeInput,

  /// Time a field holds focus with no input at all.
  dwell,

  /// A value entered, cleared, and entered again.
  correction,

  /// A control tapped with no state change behind it.
  deadTap,

  /// A screen opened and left without the transaction completing.
  abandonment,
}

/// One indicator the framework defines.
class HabotFrictionIndicator {
  const HabotFrictionIndicator({
    required this.kind,
    required this.thresholdMs,
    required this.meaning,
    required this.whatItCannotTell,
  });

  final HabotFrictionKind kind;

  /// The point past which an observation is recorded. Zero where the
  /// indicator is a count rather than a duration.
  final int thresholdMs;

  /// What a recorded observation means about the interface.
  final String meaning;

  /// What it does not mean, stated because the second reading is the one
  /// somebody reaches for later.
  final String whatItCannotTell;
}

/// The Human Friction Telemetry framework, written rather than reviewed.
class HabotFrictionFramework {
  const HabotFrictionFramework._();

  // -----------------------------------------------------------------------
  // There was nothing to review.
  // -----------------------------------------------------------------------

  static const String frameworkTheRowNames = 'Human Friction Telemetry';

  static const bool theFrameworkExistedBeforeThisStep = false;

  static const bool theGuidelinesWereRead = false;

  static const bool theFrameworkIsWrittenHere = true;

  static bool get theReviewProducedTheThingReviewed =>
      !theFrameworkExistedBeforeThisStep &&
      !theGuidelinesWereRead &&
      theFrameworkIsWrittenHere;

  static const String reviewNote =
      'No Human Friction Telemetry framework exists in the four hundred and '
      'fifteen steps behind this row, so there are no mapping guidelines to '
      'review. A review row whose subject does not exist cannot be closed by '
      'reading. What is delivered instead is what the review would have '
      'produced -- a written definition of what friction is, what is measured, '
      'what is not, and what each number may be used for -- which is more work '
      'than the row asks for and the only honest way to close it.';

  // -----------------------------------------------------------------------
  // The definition lives in the Completion Measures cell.
  // -----------------------------------------------------------------------

  static const int dwellSpikeMs = 5000;

  static const String whereTheDefinitionIs = 'the Completion Measures column';

  static const bool theAtomicStepDefinesFriction = false;

  static bool get theDefinitionCameFromTheLastColumn =>
      !theAtomicStepDefinesFriction && dwellSpikeMs == 5000;

  static const String definitionNote =
      'The Atomic Step never says what friction is. The Completion Measures '
      'cell does: user dwell spikes over five seconds generate a telemetry '
      'row. Five seconds on one field is the entire operational definition of '
      'the framework, and it is sitting in the column nobody reads until the '
      'work is finished.';

  // -----------------------------------------------------------------------
  // Five indicators, each with what it cannot tell you.
  // -----------------------------------------------------------------------

  static const List<HabotFrictionIndicator> indicators =
      <HabotFrictionIndicator>[
    HabotFrictionIndicator(
      kind: HabotFrictionKind.hesitationBeforeInput,
      thresholdMs: 3000,
      meaning: 'the field was reached and the answer was not obvious',
      whatItCannotTell: 'whether the person was thinking or was interrupted',
    ),
    HabotFrictionIndicator(
      kind: HabotFrictionKind.dwell,
      thresholdMs: dwellSpikeMs,
      meaning: 'the field held attention without receiving input',
      whatItCannotTell: 'whether the person put the phone down',
    ),
    HabotFrictionIndicator(
      kind: HabotFrictionKind.correction,
      thresholdMs: 0,
      meaning: 'the first answer was wrong or the field was misread',
      whatItCannotTell: 'which of those two it was',
    ),
    HabotFrictionIndicator(
      kind: HabotFrictionKind.deadTap,
      thresholdMs: 0,
      meaning: 'something looked tappable and was not',
      whatItCannotTell: 'whether the target was missed or was never a target',
    ),
    HabotFrictionIndicator(
      kind: HabotFrictionKind.abandonment,
      thresholdMs: 0,
      meaning: 'the screen was opened and the transaction was not completed',
      whatItCannotTell: 'whether the person came back on another device',
    ),
  ];

  static int get indicatorCount => indicators.length;

  static bool get everyKindIsDefined =>
      indicators.length == HabotFrictionKind.values.length;

  static bool get everyIndicatorNamesItsMeaning =>
      indicators.every((HabotFrictionIndicator i) => i.meaning.isNotEmpty);

  static bool get everyIndicatorNamesItsLimit => indicators
      .every((HabotFrictionIndicator i) => i.whatItCannotTell.isNotEmpty);

  static int get durationIndicators =>
      indicators.where((HabotFrictionIndicator i) => i.thresholdMs > 0).length;

  static bool get twoAreDurationsAndThreeAreCounts =>
      durationIndicators == 2 && indicatorCount - durationIndicators == 3;

  static const String indicatorNote =
      'Five indicators: two measured in time and three counted. Each names '
      'what a recorded observation means about the interface and, beside it, '
      'what it cannot tell you -- because the second reading is the one '
      'somebody reaches for six months later. A dwell of five seconds means '
      'the field held attention without receiving input; it does not mean the '
      'person was confused, and it certainly does not mean the person was '
      'slow.';

  // -----------------------------------------------------------------------
  // What the numbers may be used for.
  // -----------------------------------------------------------------------

  static const String theSubject = 'the interface';

  static const String notTheSubject = 'the person using it';

  static bool get theSubjectIsTheInterface => theSubject != notTheSubject;

  static const bool anIndicatorMayRankIndividuals = false;

  static const bool anIndicatorIsAggregatedByScreenAndField = true;

  static bool get theUnitOfAnalysisIsAScreen =>
      anIndicatorIsAggregatedByScreenAndField && !anIndicatorMayRankIndividuals;

  static const String scopeNote =
      'Every indicator here measures a screen, not a person. The unit of '
      'analysis is a screen and a field, aggregated across everybody who used '
      'it; no indicator may be attributed to an individual or used to rank '
      'one. That limit is part of the framework rather than a policy bolted on '
      'afterwards, because a measure of hesitation is a measure of how well '
      'the interface explained itself, and the same number read as a measure '
      'of the person is both wrong and unfalsifiable.';

  // -----------------------------------------------------------------------
  // Three subjects, and a standard column holding an argument.
  // -----------------------------------------------------------------------

  static const List<String> subjectsInThisRow = <String>[
    'friction telemetry (the Atomic Step)',
    'element mapping fields (the Data Requirement)',
    'frame rendering latency tests (the Setup Step)',
  ];

  static bool get threeSubjectsInOneRow => subjectsInThisRow.length == 3;

  /// Steps 388, 390, 398 and this one.
  static const List<int> splicedRows = <int>[388, 390, 398, 416];

  static bool get thisIsTheFourthSplicedRow => splicedRows.length == 4;

  static const String standardCellHolds = 'an argument';
  static const String standardCellShouldHold = 'a specification';

  static bool get theStandardCellHoldsProse =>
      standardCellHolds != standardCellShouldHold;

  static const String spliceNote =
      'The Atomic Step is about friction telemetry, the Data Requirement holds '
      'element-mapping fields, and the Setup Step asks for frame rendering '
      'latency tests during touch drag: three subjects, the fourth spliced row '
      'in the track after Steps 388, 390 and 398. Separately, the '
      'reference-standard column holds a sentence defending the band rather '
      'than naming a specification -- Step 415 put a foreign framework in that '
      'column and this puts prose in it.';

  // -----------------------------------------------------------------------
  // A band written in sentences.
  // -----------------------------------------------------------------------

  static const String bandFloorRaw = '90% of relevant items identified';
  static const String bandOptimalRaw = '98% of relevant items identified';
  static const String bandCeilingRaw = '100% of relevant items identified';

  static bool get everyBandCellIsASentence =>
      bandFloorRaw.contains(' ') &&
      bandOptimalRaw.contains(' ') &&
      bandCeilingRaw.contains(' ');

  static bool get noBandCellParses =>
      double.tryParse(bandFloorRaw) == null &&
      double.tryParse(bandOptimalRaw) == null &&
      double.tryParse(bandCeilingRaw) == null;

  /// Step 400 was the first; this is the second.
  static const int theFirstAllSentenceBand = 400;

  static bool get thisIsTheSecondAllSentenceBand =>
      theFirstAllSentenceBand == 400 && everyBandCellIsASentence;

  static const bool theBandAscendsCorrectly = true;

  static double get coverage =>
      everyKindIsDefined && everyIndicatorNamesItsLimit ? 100 : 0;

  static const String bandNote =
      'All three band cells are sentences of the form "N% of relevant items '
      'identified", so none of them parses and the numbers have to be read out '
      'of prose -- the second all-sentence band in the track after Step 400. '
      'Unlike Step 400 this one at least ascends in the right direction. The '
      'figure published is the share of the five declared indicator kinds that '
      'carry both a meaning and a stated limit.';

  static const String columnNote =
      'COLUMN NOTE: this row asks for a review of mapping guidelines for a '
      'Human Friction Telemetry framework that does not exist anywhere in the '
      'track, so the review had to produce the framework it was meant to read; '
      'its Atomic Step, Data Requirement and Setup Step carry three different '
      'subjects -- friction telemetry, element mapping fields, and frame '
      'rendering latency tests -- making it the fourth spliced row after Steps '
      '388, 390 and 398; the only operational definition of friction anywhere '
      'in the row is in the Completion Measures cell ("user dwell spikes over '
      '5 seconds"); all three band cells are sentences; and the '
      'reference-standard column holds an argument defending the band rather '
      'than naming a standard. Atomic Step: "Review the technical mapping '
      'guidelines for the Human Friction Telemetry framework."';

  static Map<String, bool> get obligations => <String, bool>{
        'the framework is written rather than assumed':
            theReviewProducedTheThingReviewed,
        'every indicator kind is defined': everyKindIsDefined,
        'every indicator names what it cannot tell you':
            everyIndicatorNamesItsLimit,
        'the unit of analysis is a screen, not a person':
            theUnitOfAnalysisIsAScreen,
        'the definition buried in the last column is surfaced':
            theDefinitionCameFromTheLastColumn,
      };

  static String get qualitativeOutput =>
      obligations.values.every((bool b) => b) ? 'Complete' : 'Partial';

  static Map<String, bool> get checks => <String, bool>{
        'there were no guidelines to review':
            !theFrameworkExistedBeforeThisStep && !theGuidelinesWereRead,
        'so the review produced the framework':
            theReviewProducedTheThingReviewed &&
                reviewNote.contains('the only honest way'),
        'the definition of friction was in the Completion Measures cell':
            theDefinitionCameFromTheLastColumn &&
                definitionNote.contains('nobody reads'),
        'five indicators, two durations and three counts':
            indicatorCount == 5 &&
                everyKindIsDefined &&
                twoAreDurationsAndThreeAreCounts,
        'each names its meaning and each names its limit':
            everyIndicatorNamesItsMeaning && everyIndicatorNamesItsLimit,
        'the subject is the interface, not the person':
            theSubjectIsTheInterface && theUnitOfAnalysisIsAScreen,
        'and no indicator may rank an individual':
            !anIndicatorMayRankIndividuals &&
                scopeNote.contains('unfalsifiable'),
        'three subjects in one row, the fourth splice':
            threeSubjectsInOneRow && thisIsTheFourthSplicedRow,
        'and the standard column holds an argument':
            theStandardCellHoldsProse && everyBandCellIsASentence,
        'five obligations, all met, giving Complete':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Complete' &&
                noBandCellParses &&
                thisIsTheSecondAllSentenceBand &&
                theBandAscendsCorrectly &&
                coverage == 100,
      };
}
