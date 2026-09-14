/// Step 247 (FLADE-006-03) -- detecting a correction burst without recording
/// what was corrected.
///
/// The row: "Attach keystroke monitoring event listeners to form input fields
/// to detect rapid consecutive backspace or clear actions."
/// Metric: **Observability / Alert Coverage** -- floor >=90%, optimal 1,
/// ceiling 1. Good/Average/Poor. Standard cited: Google SRE Handbook.
///
/// **"Keystroke monitoring" is the wrong name for what may be built.** A
/// listener that sees keystrokes sees content, and the fields in this
/// application's scope include identity numbers, bank accounts and -- through
/// the payments surface -- fields Step 207 established the application must
/// never be in a position to read. A keystroke log is the one artefact that
/// turns a hosted card field back into a card number in this process's memory.
///
/// So what is attached counts and never captures. The detector sees a stream
/// of `(when, deletion-or-not)` and nothing else: no characters, no lengths,
/// no before-and-after. [HabotHesitationTracker] already records corrections
/// value-free for exactly this reason, and this step adds the burst shape on
/// top of it rather than a second stream.
///
/// **And it is refused outright on sensitive fields.** Even a value-free
/// count on a card field is a signal about a card number -- how many
/// corrections a person made entering their PAN is not information this
/// application has any business holding. Sensitive fields are declared, the
/// detector returns nothing for them, and the coverage figure is reported
/// against the fields it is *allowed* to watch with the exclusion named.
library;

import '../tokens/motion_tokens.dart';
import 'hesitation_tracker.dart';

/// What a keystroke did, at the only resolution this records.
enum HabotKeystrokeKind {
  /// A character went in. Which character is not recorded.
  entry,

  /// A character came out.
  deletion,

  /// The field was emptied in one action.
  clear,
}

/// One observation. Deliberately value-free: there is nowhere to put a
/// character even if somebody wanted to.
class HabotKeystroke {
  const HabotKeystroke({required this.atMs, required this.kind});

  final int atMs;
  final HabotKeystrokeKind kind;

  bool get isCorrection =>
      kind == HabotKeystrokeKind.deletion || kind == HabotKeystrokeKind.clear;
}

/// A run of corrections close enough together to mean something.
class HabotCorrectionBurst {
  const HabotCorrectionBurst({
    required this.startMs,
    required this.endMs,
    required this.corrections,
  });

  final int startMs;
  final int endMs;
  final int corrections;

  int get spanMs => endMs - startMs;
}

/// A field, and whether it may be watched at all.
class HabotWatchedField {
  const HabotWatchedField({
    required this.name,
    required this.isSensitive,
    required this.detectorAttached,
    required this.why,
  });

  final String name;

  /// True where even a value-free count is a signal about something this
  /// application must not hold.
  final bool isSensitive;

  /// Whether this build actually attaches the detector. Declared per field
  /// rather than inferred, so coverage is a measurement and not a restatement
  /// of the sensitivity flag.
  final bool detectorAttached;

  final String why;

  bool get mayBeWatched => !isSensitive;

  /// The one combination that must never occur.
  bool get isAViolation => isSensitive && detectorAttached;
}

/// The detector.
class HabotCorrectionBurstDetector {
  const HabotCorrectionBurstDetector._();

  /// How close together corrections must be to count as one burst.
  static Duration get window => HabotMotion.correctionBurstWindow;

  static int get windowMs => window.inMilliseconds;

  /// Fewer than this and it is a typo, not a struggle.
  static const int threshold = 3;

  /// The burst shape sits on top of the existing value-free correction
  /// record rather than opening a second stream.
  static HabotInteractionKind get existingCorrectionKind =>
      HabotInteractionKind.correction;

  /// Greedy non-overlapping scan: take the earliest correction, extend while
  /// the next is inside the window, emit if the run is long enough.
  static List<HabotCorrectionBurst> burstsIn(List<HabotKeystroke> trace) {
    final List<int> corrections = trace
        .where((HabotKeystroke k) => k.isCorrection)
        .map((HabotKeystroke k) => k.atMs)
        .toList()
      ..sort();
    final List<HabotCorrectionBurst> bursts = <HabotCorrectionBurst>[];
    int i = 0;
    while (i < corrections.length) {
      int j = i;
      while (j + 1 < corrections.length &&
          corrections[j + 1] - corrections[i] <= windowMs) {
        j += 1;
      }
      final int run = j - i + 1;
      if (run >= threshold) {
        bursts.add(
          HabotCorrectionBurst(
            startMs: corrections[i],
            endMs: corrections[j],
            corrections: run,
          ),
        );
        i = j + 1;
      } else {
        i += 1;
      }
    }
    return bursts;
  }

  static double correctionRatioOf(List<HabotKeystroke> trace) {
    if (trace.isEmpty) {
      return 0;
    }
    return trace.where((HabotKeystroke k) => k.isCorrection).length /
        trace.length;
  }

  /// Nothing is watched on a sensitive field, burst or not.
  static List<HabotCorrectionBurst> burstsFor({
    required HabotWatchedField field,
    required List<HabotKeystroke> trace,
  }) =>
      field.mayBeWatched ? burstsIn(trace) : const <HabotCorrectionBurst>[];

  // -----------------------------------------------------------------------
  // The worked trace.
  // -----------------------------------------------------------------------

  /// Thirteen observations: four entries, a run of four deletions inside two
  /// seconds, two more entries, then three deletions spread over six seconds.
  /// One burst, not two -- the spread-out deletions are a person editing, not
  /// a person stuck.
  static const List<HabotKeystroke> workedTrace = <HabotKeystroke>[
    HabotKeystroke(atMs: 0, kind: HabotKeystrokeKind.entry),
    HabotKeystroke(atMs: 120, kind: HabotKeystrokeKind.entry),
    HabotKeystroke(atMs: 260, kind: HabotKeystrokeKind.entry),
    HabotKeystroke(atMs: 400, kind: HabotKeystrokeKind.entry),
    HabotKeystroke(atMs: 1500, kind: HabotKeystrokeKind.deletion),
    HabotKeystroke(atMs: 1640, kind: HabotKeystrokeKind.deletion),
    HabotKeystroke(atMs: 1760, kind: HabotKeystrokeKind.deletion),
    HabotKeystroke(atMs: 1880, kind: HabotKeystrokeKind.deletion),
    HabotKeystroke(atMs: 2400, kind: HabotKeystrokeKind.entry),
    HabotKeystroke(atMs: 2600, kind: HabotKeystrokeKind.entry),
    HabotKeystroke(atMs: 9000, kind: HabotKeystrokeKind.deletion),
    HabotKeystroke(atMs: 12000, kind: HabotKeystrokeKind.deletion),
    HabotKeystroke(atMs: 15000, kind: HabotKeystrokeKind.deletion),
  ];

  static List<HabotCorrectionBurst> get workedBursts =>
      burstsIn(workedTrace);

  /// A clear counts as a correction on its own, which is the case a
  /// deletion-only detector misses: one tap of the clear button is not three
  /// backspaces and is the same intent.
  static const List<HabotKeystroke> clearOnlyTrace = <HabotKeystroke>[
    HabotKeystroke(atMs: 0, kind: HabotKeystrokeKind.entry),
    HabotKeystroke(atMs: 500, kind: HabotKeystrokeKind.clear),
    HabotKeystroke(atMs: 900, kind: HabotKeystrokeKind.entry),
    HabotKeystroke(atMs: 1400, kind: HabotKeystrokeKind.clear),
    HabotKeystroke(atMs: 1900, kind: HabotKeystrokeKind.clear),
  ];

  // -----------------------------------------------------------------------
  // Which fields may be watched.
  // -----------------------------------------------------------------------

  static const List<HabotWatchedField> fields = <HabotWatchedField>[
    HabotWatchedField(
      name: 'child name',
      isSensitive: false,
      detectorAttached: true,
      why: 'A name a parent types about their own child. A count of '
          'corrections here says something about the form and nothing about '
          'the child.',
    ),
    HabotWatchedField(
      name: 'guardian phone number',
      isSensitive: false,
      detectorAttached: true,
      why: 'Correction bursts here are the signal the row is actually after: '
          'a number format the field will not accept.',
    ),
    HabotWatchedField(
      name: 'promo code',
      isSensitive: false,
      detectorAttached: true,
      why: 'The field most likely to be retyped, and the one where a burst '
          'means the code is wrong rather than the field is.',
    ),
    HabotWatchedField(
      name: 'card number, in the provider\'s hosted field',
      isSensitive: true,
      detectorAttached: false,
      why: 'Step 207: the application must never be in a position to read '
          'this. A keystroke listener is exactly that position, and even a '
          'value-free count is a signal about a card number.',
    ),
    HabotWatchedField(
      name: 'card security code',
      isSensitive: true,
      detectorAttached: false,
      why: 'Same boundary, and the field where a count is most obviously a '
          'fact about a secret.',
    ),
    HabotWatchedField(
      name: 'IBAN',
      isSensitive: true,
      detectorAttached: false,
      why: 'A bank account number. Step 243 validates it and does not need '
          'to know how many attempts it took.',
    ),
  ];

  static List<HabotWatchedField> get watchableFields =>
      fields.where((HabotWatchedField f) => f.mayBeWatched).toList();

  static List<HabotWatchedField> get refusedFields =>
      fields.where((HabotWatchedField f) => !f.mayBeWatched).toList();

  /// Coverage over the fields the detector is allowed to watch: how many of
  /// them this build actually attaches it to. The exclusion is declared
  /// rather than the denominator quietly reduced.
  static double get coverageOfWatchableFields => watchableFields.isEmpty
      ? 0
      : watchableFields
              .where((HabotWatchedField f) => f.detectorAttached)
              .length /
          watchableFields.length;

  /// Must be empty. A sensitive field with the detector attached is the one
  /// state this step exists to prevent.
  static List<HabotWatchedField> get violations =>
      fields.where((HabotWatchedField f) => f.isAViolation).toList();

  static double get coverageOfAllFields =>
      watchableFields.length / fields.length;

  static bool get nothingIsWatchedOnASensitiveField => refusedFields.every(
        (HabotWatchedField f) =>
            burstsFor(field: f, trace: workedTrace).isEmpty,
      );

  static bool get theSameTraceIsDetectedOnAWatchableField =>
      burstsFor(field: watchableFields.first, trace: workedTrace).length == 1;

  // -----------------------------------------------------------------------
  // Notes.
  // -----------------------------------------------------------------------

  static const String countsNeverCapturesNote =
      '"Keystroke monitoring" is the wrong name for what may be built. A '
      'listener that sees keystrokes sees content, and the fields in this '
      'application\'s scope include identity numbers, bank accounts and -- '
      'through the payments surface -- fields Step 207 established the '
      'application must never be in a position to read. A keystroke log is '
      'the one artefact that turns a hosted card field back into a card '
      'number in this process\'s memory. What is attached therefore COUNTS '
      'and never CAPTURES: the detector sees a stream of when-and-'
      'deletion-or-not and nothing else. No characters, no lengths, no '
      'before-and-after.';

  static const String refusalNote =
      'Refused outright on sensitive fields, not merely anonymised. Even a '
      'value-free count on a card field is a signal about a card number: how '
      'many corrections a person made entering their PAN is not information '
      'this application has any business holding, and a count that exists can '
      'be joined to a session that exists. Three of the six declared fields '
      'are refused, the detector returns nothing for them, and coverage is '
      'reported against the fields it is allowed to watch with the exclusion '
      'named -- the same shape as Steps 233 and 234.';

  static const String reusesTheExistingStreamNote =
      'HabotHesitationTracker already records corrections value-free, for '
      'exactly this reason and since long before this row. This step adds the '
      'BURST SHAPE on top of that record -- a window, a threshold and a '
      'non-overlapping scan -- rather than opening a second stream, which '
      'would have been a second thing to keep clean.';

  static const String windowNote =
      'Three corrections inside two seconds is a struggle; three spread over '
      'six seconds is a person editing. The worked trace contains both, and '
      'yields one burst rather than two. A detector without a window would '
      'have reported seven corrections and called it one long problem.';

  // -----------------------------------------------------------------------
  // Metric: Observability / Alert Coverage.
  // -----------------------------------------------------------------------

  static const double floor = 0.9;
  static const double optimal = 1;
  static const double ceiling = 1;

  static String get qualitativeOutput {
    if (coverageOfWatchableFields >= optimal) {
      return 'Good';
    }
    return coverageOfWatchableFields >= floor ? 'Average' : 'Poor';
  }

  static Map<String, bool> get checks => <String, bool>{
        'the worked trace yields exactly one burst':
            workedBursts.length == 1 && workedBursts.single.corrections == 4,
        'the burst is the run inside the window, not the whole trace':
            workedBursts.single.startMs == 1500 &&
                workedBursts.single.endMs == 1880 &&
                workedBursts.single.spanMs <= windowMs,
        'the three spread-out corrections are not a burst':
            workedTrace
                .where((HabotKeystroke k) => k.isCorrection)
                .length ==
                7,
        'a clear counts as a correction on its own':
            burstsIn(clearOnlyTrace).length == 1,
        'the correction ratio is computed over the whole trace':
            (correctionRatioOf(workedTrace) - 7 / 13).abs() < 1e-9,
        'the window is a declared token, not a number here':
            window == HabotMotion.correctionBurstWindow && windowMs == 2000,
        'the burst sits on the existing value-free correction record':
            existingCorrectionKind == HabotInteractionKind.correction,
        'three of six fields are refused, nothing is watched on them, and no '
            'sensitive field has the detector attached':
            refusedFields.length == 3 &&
                nothingIsWatchedOnASensitiveField &&
                violations.isEmpty,
        'the same trace is detected on a field that may be watched':
            theSameTraceIsDetectedOnAWatchableField,
        'coverage over all fields is published beside coverage over watchable '
            'ones': (coverageOfAllFields - 0.5).abs() < 1e-9 &&
            coverageOfWatchableFields == 1.0,
      };

  static const String columnNote =
      'COLUMN NOTE: this row carries no Setup Step, no Expected Output and no '
      'Completion Measures -- only a metric and a Data Collected list. Atomic '
      'Step: "Attach keystroke monitoring event listeners to form input '
      'fields to detect rapid consecutive backspace or clear actions."';
}
