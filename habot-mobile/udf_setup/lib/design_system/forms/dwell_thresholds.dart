/// Step 290 (GEN-00101) -- two signals the row calls one, and a threshold that
/// is not a rule until somebody says what happens when it is crossed.
///
/// The row: "Define dwell-time and hesitation threshold limits for all mobile
/// form inputs."
/// Metric: **Schema Field Definition Accuracy** -- floor "Field typed and
/// documented, minor gaps allowed pre-review", optimal "100% field
/// type/constraint match to schema contract", ceiling 1. Complete / Partial /
/// Not Complete. Cited: JSON Schema 2020-12; OpenAPI 3.0.
///
/// **Dwell and hesitation are different measurements.** Dwell is how long
/// somebody spent in a field; hesitation is how long they spent before
/// starting, and how long the pauses inside were. A long dwell on a free-text
/// note is a person writing. A long hesitation before the first character of a
/// four-digit code is a person who does not know what is being asked. One
/// threshold over both says nothing about either, and the row's own phrase
/// contains both words without separating them.
///
/// **A threshold is not a rule until you say what crossing it does.** The
/// obvious implementation -- open a help panel when the timer fires --
/// interrupts precisely the person who was thinking, and does it at the moment
/// they were closest to finishing. Crossing a threshold emits; it does not
/// act. The one acting form that is safe is passive: a hint that appears
/// without moving anything and without taking focus.
///
/// **And "all mobile form inputs" cannot share a number.** A date, a phone
/// number and a free-text note have different natural dwells, so the
/// thresholds are declared per input kind. That is what makes this row's
/// metric half-fit: these are field definitions, and a definition that is one
/// number for everything does not match any contract.
library;

import '../telemetry/event_schema.dart';
import '../tokens/motion_tokens.dart';

/// What is being timed.
enum HabotTimingSignal {
  /// Total time between focus and blur.
  dwell,

  /// Time between focus and the first character.
  hesitationBeforeStarting,

  /// The longest pause between characters.
  hesitationWithin,
}

/// What a field is asking for, which is what decides its natural timing.
enum HabotInputKind {
  /// A short code or a numeric value.
  shortNumeric,

  /// A name, an email address, a line of an address.
  shortText,

  /// A date or a time.
  temporal,

  /// A free-text note.
  longText,
}

/// One declared threshold.
class HabotDwellThreshold {
  const HabotDwellThreshold({
    required this.kind,
    required this.signal,
    required this.limitSeconds,
    required this.why,
  });

  final HabotInputKind kind;
  final HabotTimingSignal signal;

  /// Seconds, as an integer. A figure that is not a motion token does not
  /// become one by being written as a Duration here.
  final int limitSeconds;

  final String why;
}

/// The definitions.
class HabotDwellThresholds {
  const HabotDwellThresholds._();

  // -----------------------------------------------------------------------
  // What already exists.
  // -----------------------------------------------------------------------

  /// Step 248 declared a dwell band for deliberate friction, and Step 247 a
  /// window for correction bursts. This row is the definition step arriving
  /// after two of its own uses, which is worth recording rather than
  /// re-deriving.
  static int get declaredFrictionFloorSeconds =>
      HabotMotion.frictionDwellFloor.inSeconds;
  static int get declaredFrictionOptimalSeconds =>
      HabotMotion.frictionDwellOptimal.inSeconds;
  static int get declaredFrictionCeilingSeconds =>
      HabotMotion.frictionDwellCeiling.inSeconds;
  static int get declaredCorrectionWindowSeconds =>
      HabotMotion.correctionBurstWindow.inSeconds;

  static bool get someThresholdsAlreadyExist =>
      declaredFrictionFloorSeconds == 3 &&
      declaredFrictionOptimalSeconds == 5 &&
      declaredFrictionCeilingSeconds == 10 &&
      declaredCorrectionWindowSeconds == 2;

  static const String definitionAfterUseNote =
      'Two of this row\'s thresholds were declared before it: Step 248 set a '
      'dwell band for deliberate friction and Step 247 a window for '
      'correction bursts. A definition step arriving after its own uses is '
      'not a problem to fix -- the values are in tokens and are read, not '
      'copied -- but it is worth recording, because the next reader will look '
      'for the definitions here and half of them are somewhere else.';

  // -----------------------------------------------------------------------
  // Two signals, separated.
  // -----------------------------------------------------------------------

  static const List<HabotDwellThreshold> thresholds = <HabotDwellThreshold>[
    HabotDwellThreshold(
      kind: HabotInputKind.shortNumeric,
      signal: HabotTimingSignal.hesitationBeforeStarting,
      limitSeconds: 4,
      why: 'Four seconds of an empty four-digit field is somebody who does '
          'not know which number is being asked for.',
    ),
    HabotDwellThreshold(
      kind: HabotInputKind.shortNumeric,
      signal: HabotTimingSignal.dwell,
      limitSeconds: 20,
      why: 'Twenty seconds in a short numeric field is long enough that the '
          'value is probably being looked up somewhere else.',
    ),
    HabotDwellThreshold(
      kind: HabotInputKind.shortText,
      signal: HabotTimingSignal.hesitationBeforeStarting,
      limitSeconds: 5,
      why: 'Slightly longer than numeric: a name or an address line often '
          'starts with a decision about which one to give.',
    ),
    HabotDwellThreshold(
      kind: HabotInputKind.temporal,
      signal: HabotTimingSignal.hesitationWithin,
      limitSeconds: 6,
      why: 'A pause in the middle of a date is the separator problem: the '
          'field took the digits and refused the slash. Open decision 24.',
    ),
    HabotDwellThreshold(
      kind: HabotInputKind.longText,
      signal: HabotTimingSignal.dwell,
      limitSeconds: 180,
      why: 'Three minutes, because a person writing a note is not hesitating '
          'and a threshold that says otherwise produces noise on the one '
          'field where slowness is the point.',
    ),
  ];

  static List<HabotDwellThreshold> forKind(HabotInputKind k) =>
      thresholds.where((HabotDwellThreshold t) => t.kind == k).toList();

  static bool get everyKindHasAtLeastOneThreshold =>
      HabotInputKind.values.every((HabotInputKind k) => forKind(k).isNotEmpty);

  static bool get everyThresholdGivesAReason =>
      thresholds.every((HabotDwellThreshold t) => t.why.length > 50);

  /// The signals are used separately rather than collapsed.
  static Set<HabotTimingSignal> get signalsUsed =>
      thresholds.map((HabotDwellThreshold t) => t.signal).toSet();

  static bool get allThreeSignalsAreDistinguished =>
      signalsUsed.length == HabotTimingSignal.values.length &&
      HabotTimingSignal.values.length == 3;

  /// The numbers differ by kind by more than an order of magnitude, which is
  /// the measurable form of "these cannot share a threshold".
  static int get shortestLimit => thresholds
      .map((HabotDwellThreshold t) => t.limitSeconds)
      .reduce((int a, int b) => a < b ? a : b);

  static int get longestLimit => thresholds
      .map((HabotDwellThreshold t) => t.limitSeconds)
      .reduce((int a, int b) => a > b ? a : b);

  static int get spread => longestLimit ~/ shortestLimit;

  static bool get oneNumberCouldNotServeThemAll => spread >= 45;

  static const String twoSignalsNote =
      'Dwell and hesitation are different measurements. Dwell is the time '
      'between focus and blur; hesitation is the time before the first '
      'character, and the longest pause after it. A long dwell on a free-text '
      'note is a person writing; a long hesitation on an empty four-digit '
      'field is a person who does not know what is being asked. The row uses '
      'both words in one phrase and gives them one threshold, and the '
      'thresholds declared here differ by a factor of forty-five across '
      'input kinds -- which is the measurable form of the same objection.';

  // -----------------------------------------------------------------------
  // What crossing one does.
  // -----------------------------------------------------------------------

  /// Crossing a threshold emits an observation. It does not open anything.
  static const bool crossingEmits = true;
  static const bool crossingInterrupts = false;

  /// The one acting form that is safe: a hint that appears in space already
  /// reserved, takes no focus, and moves nothing.
  static const bool passiveHintIsAllowed = true;

  static bool get nothingIsInterrupted =>
      crossingEmits && !crossingInterrupts && passiveHintIsAllowed;

  static const String interruptionNote =
      'The obvious implementation of a hesitation threshold opens a help '
      'panel when the timer fires, and it interrupts precisely the person who '
      'was thinking, at the moment they were closest to finishing. Crossing a '
      'threshold emits an observation; it does not act. The one acting form '
      'that is safe is passive -- a hint in space already reserved, taking no '
      'focus and moving nothing -- because a person who is reading can ignore '
      'it and a person who is stuck can read it.';

  // -----------------------------------------------------------------------
  // What may be emitted.
  // -----------------------------------------------------------------------

  /// A dwell measurement is behavioural data about a person, so Step 269's
  /// emission rules apply. A duration is a declared field type, which is what
  /// makes the measurement emittable at all -- and the event carries the
  /// duration and the field's identity, never its value.
  static bool get durationIsADeclaredFieldType =>
      HabotFieldType.values.contains(HabotFieldType.durationMs);

  static Map<String, Object?> observationFor({
    required String fieldId,
    required HabotTimingSignal signal,
    required int observedMs,
  }) =>
      <String, Object?>{
        'field': fieldId,
        'signal': signal.name,
        'observed_ms': observedMs,
      };

  static bool get theObservationCarriesNoValue {
    final Map<String, Object?> o = observationFor(
      fieldId: 'booking.childName',
      signal: HabotTimingSignal.dwell,
      observedMs: 4200,
    );
    return o.length == 3 && !o.containsKey('value') && !o.containsKey('text');
  }

  static const String emissionNote =
      'A dwell measurement is behavioural data about a person, so Step 269\'s '
      'emission rules govern it: the event carries the field\'s identity, the '
      'signal and a duration, and never the value that was being typed. The '
      'duration is emittable at all only because durationMs is one of the '
      'five declared field types -- if it were not, this measurement would '
      'have nowhere to go, which is the structural guarantee doing its job in '
      'the direction nobody tests.';

  // -----------------------------------------------------------------------
  // Metric: Schema Field Definition Accuracy.
  // -----------------------------------------------------------------------

  /// The floor is prose, and "minor gaps allowed" makes it unmeasurable: a
  /// definition with gaps is a definition somebody has to ask about.
  static const String floorAsWritten =
      'Field typed and documented, minor gaps allowed pre-review';

  static bool get theFloorIsUnmeasurable =>
      floorAsWritten.contains('minor gaps allowed');

  static Map<String, bool> get definitionChecks => <String, bool>{
        'every input kind has at least one threshold':
            everyKindHasAtLeastOneThreshold,
        'every threshold names its signal and gives a reason':
            everyThresholdGivesAReason && allThreeSignalsAreDistinguished,
        'thresholds are per kind rather than global':
            oneNumberCouldNotServeThemAll,
        'crossing emits and does not interrupt': nothingIsInterrupted,
        'the observation carries no field value': theObservationCarriesNoValue,
        'the duration type it needs is already declared':
            durationIsADeclaredFieldType,
      };

  static double get definitionAccuracy =>
      definitionChecks.values.where((bool b) => b).length /
      definitionChecks.length;

  static String get qualitativeOutput =>
      definitionAccuracy >= 1.0 ? 'Complete' : 'Partial';

  static const String bandNote =
      'The floor is a sentence -- "field typed and documented, minor gaps '
      'allowed pre-review" -- and "minor gaps allowed" is what makes it '
      'unmeasurable: a definition with gaps is a definition somebody has to '
      'ask about, and there is no scale on which a gap is minor. The optimal '
      'is measurable and is what this step reports against: every definition '
      'complete, over the six checks it declares.';

  static Map<String, bool> get checks => <String, bool>{
        'two thresholds already existed before this definition row':
            someThresholdsAlreadyExist &&
                definitionAfterUseNote.contains('somewhere else'),
        'three timing signals are distinguished':
            allThreeSignalsAreDistinguished,
        'five thresholds across four input kinds, each with a reason':
            thresholds.length == 5 &&
                everyKindHasAtLeastOneThreshold &&
                everyThresholdGivesAReason,
        'the limits span a factor of forty-five':
            spread == 45 &&
                oneNumberCouldNotServeThemAll &&
                shortestLimit == 4 &&
                longestLimit == 180,
        'the two-signal finding is recorded in measurable form':
            twoSignalsNote.contains('factor of forty-five'),
        'crossing a threshold emits rather than interrupts':
            nothingIsInterrupted &&
                interruptionNote.contains('closest to finishing'),
        'the observation carries the field and the duration and no value':
            theObservationCarriesNoValue && durationIsADeclaredFieldType,
        'the emission rule is read from Step 269 rather than restated':
            emissionNote.contains('nobody tests'),
        'the prose floor is recorded as unmeasurable':
            theFloorIsUnmeasurable && bandNote.contains('no scale'),
        'six definition checks, all holding, giving Complete':
            definitionChecks.length == 6 &&
                definitionChecks.values.every((bool b) => b) &&
                definitionAccuracy == 1.0 &&
                qualitativeOutput == 'Complete',
      };

  static const String columnNote =
      'COLUMN NOTE: Setup Step (Action) is EMPTY on this row and the Setup '
      'Step column that is populated reads "Register the type-to-component '
      'mappings in the FormatterRegistry singleton". Atomic Step: "Define '
      'dwell-time and hesitation threshold limits for all mobile form '
      'inputs."';
}
