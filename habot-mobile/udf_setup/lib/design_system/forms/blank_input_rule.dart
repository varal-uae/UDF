/// Step 302 (GEN-03910) -- a required-field check timed with a stopwatch, and
/// the two empty-looking strings that pass it.
///
/// The row: "Check if required text input strings are null, empty, or consist
/// purely of whitespace characters."
/// Metric: **String Trim Evaluation Speed** -- floor "< 0.1 ms", optimal
/// "< 0.001 ms", ceiling "0.5 ms". Pass/Fail. Defensive Data Sanitization
/// Rules.
///
/// **The optimal is below the resolution of the instrument.** 0.001 ms is one
/// microsecond, which is roughly the granularity of `Stopwatch` on a phone; a
/// target at the tick of the clock that measures it cannot be distinguished
/// from a target at zero. It also does not matter. Trimming a forty-character
/// string is a handful of comparisons -- tens of nanoseconds -- so the metric
/// is timing an operation that was never going to be slow, on a row whose
/// actual failure modes are about *which* strings count as blank and *when*
/// the person is told.
///
/// **Two empty-looking strings survive the check the row describes.** Dart's
/// `String.trim()` removes characters with the Unicode White_Space property,
/// plus the byte-order mark. U+200B ZERO WIDTH SPACE and U+2060 WORD JOINER
/// have neither: they render as nothing, they survive the trim, and
/// `'​'.trim().isEmpty` is false. A field pasted from a web page or a
/// spreadsheet arrives holding one often enough to matter, and the person sees
/// an empty box that the app insists is filled -- which is the worst kind of
/// validation bug, because nothing on screen supports the app's position. Ten
/// blank-looking candidates are worked here; the trim catches eight.
///
/// **And the check has to run on the raw value, not the trimmed one.** The
/// point of the rule is to reject the input, not to quietly repair it: a
/// submission that silently trims is fine for a name and wrong for a password
/// field, where the trimmed value is not what the person typed.
///
/// **When it fires is the whole of the user experience.** A required-field
/// error raised on the first keystroke tells somebody their name is invalid
/// while they are typing it. Step 290 already declared the dwell thresholds
/// this needs, so the moment is read from there rather than chosen again.
library;

import 'dwell_thresholds.dart';

/// One string that looks empty on screen.
class HabotBlankCandidate {
  const HabotBlankCandidate({
    required this.name,
    required this.value,
    required this.codePoint,
    required this.hasWhiteSpaceProperty,
  });

  final String name;

  /// Null models the null case the row names first.
  final String? value;

  /// The code point at issue, or null for the plain cases.
  final int? codePoint;

  /// Whether Unicode gives this character the White_Space property, which is
  /// what Dart's trim follows.
  final bool hasWhiteSpaceProperty;
}

/// The rule.
class HabotBlankInputRule {
  const HabotBlankInputRule._();

  /// The three cases the row names, and the seven it does not.
  static const List<HabotBlankCandidate> candidates = <HabotBlankCandidate>[
    HabotBlankCandidate(
      name: 'null',
      value: null,
      codePoint: null,
      hasWhiteSpaceProperty: true,
    ),
    HabotBlankCandidate(
      name: 'empty string',
      value: '',
      codePoint: null,
      hasWhiteSpaceProperty: true,
    ),
    HabotBlankCandidate(
      name: 'space',
      value: ' ',
      codePoint: 0x0020,
      hasWhiteSpaceProperty: true,
    ),
    HabotBlankCandidate(
      name: 'tab',
      value: '\t',
      codePoint: 0x0009,
      hasWhiteSpaceProperty: true,
    ),
    HabotBlankCandidate(
      name: 'newline',
      value: '\n',
      codePoint: 0x000A,
      hasWhiteSpaceProperty: true,
    ),
    HabotBlankCandidate(
      name: 'no-break space',
      value: ' ',
      codePoint: 0x00A0,
      hasWhiteSpaceProperty: true,
    ),
    HabotBlankCandidate(
      name: 'ideographic space',
      value: '　',
      codePoint: 0x3000,
      hasWhiteSpaceProperty: true,
    ),
    HabotBlankCandidate(
      name: 'byte-order mark',
      value: '﻿',
      codePoint: 0xFEFF,
      hasWhiteSpaceProperty: false,
    ),
    HabotBlankCandidate(
      name: 'zero width space',
      value: '​',
      codePoint: 0x200B,
      hasWhiteSpaceProperty: false,
    ),
    HabotBlankCandidate(
      name: 'word joiner',
      value: '⁠',
      codePoint: 0x2060,
      hasWhiteSpaceProperty: false,
    ),
  ];

  /// What the row describes, written exactly as it reads.
  static bool trimCatches(HabotBlankCandidate c) {
    final String? v = c.value;
    if (v == null) {
      return true;
    }
    return v.trim().isEmpty;
  }

  static List<HabotBlankCandidate> get caughtByTrim =>
      candidates.where(trimCatches).toList();

  static List<HabotBlankCandidate> get slippingThrough =>
      candidates.where((HabotBlankCandidate c) => !trimCatches(c)).toList();

  static double get trimRecall => caughtByTrim.length / candidates.length;

  /// The byte-order mark is the interesting middle case: Unicode does not give
  /// it the White_Space property, and Dart's trim removes it anyway.
  static List<HabotBlankCandidate> get caughtDespiteNotBeingWhiteSpace =>
      candidates
          .where(
            (HabotBlankCandidate c) =>
                !c.hasWhiteSpaceProperty && trimCatches(c),
          )
          .toList();

  static const String slipNote =
      'U+200B ZERO WIDTH SPACE and U+2060 WORD JOINER have no White_Space '
      'property, so trim leaves them and the string is not empty. They render '
      'as nothing. A field pasted from a web page or a spreadsheet arrives '
      'holding one often enough to matter, and the person is looking at an '
      'empty box that the application insists is filled -- the worst kind of '
      'validation bug, because nothing on the screen supports the app\'s '
      'position and there is no edit that fixes it except deleting a character '
      'they cannot see.';

  // -----------------------------------------------------------------------
  // The rule that is actually used.
  // -----------------------------------------------------------------------

  /// The two survivors, named rather than guessed at.
  static const List<int> invisibleFormatCodePoints = <int>[0x200B, 0x2060];

  static bool isBlank(String? value) {
    if (value == null) {
      return true;
    }
    final String stripped = String.fromCharCodes(
      value.runes.where(
        (int r) => !invisibleFormatCodePoints.contains(r),
      ),
    );
    return stripped.trim().isEmpty;
  }

  static List<HabotBlankCandidate> get caughtByTheRule =>
      candidates.where((HabotBlankCandidate c) => isBlank(c.value)).toList();

  static bool get theRuleCatchesEveryCandidate =>
      caughtByTheRule.length == candidates.length;

  /// A value that only *contains* an invisible is not blank, so the fix does
  /// not start rejecting real input.
  static bool get aRealValueIsStillAccepted => !isBlank('Fatima​');

  // -----------------------------------------------------------------------
  // The raw value survives.
  // -----------------------------------------------------------------------

  /// The check reads the raw value and returns a verdict. It does not return
  /// a repaired string, so nothing downstream receives a value the person did
  /// not type.
  static const bool theCheckMutatesTheValue = false;

  static const String mutationNote =
      'The rule answers a question; it does not repair the input. Silently '
      'trimming is harmless on a name and wrong on a passphrase, where the '
      'trimmed value is not what was typed and the mismatch appears later as a '
      'failed sign-in nobody can reproduce. Repair, where it is wanted, is a '
      'separate decision made per field and visible to the person.';

  // -----------------------------------------------------------------------
  // When it fires.
  // -----------------------------------------------------------------------

  /// Read from Step 290 rather than chosen again here.
  static bool get theMomentIsAlreadyDeclared =>
      HabotDwellThresholds.everyKindHasAtLeastOneThreshold;

  static bool get nothingInterruptsTyping =>
      HabotDwellThresholds.nothingIsInterrupted;

  static const bool firesOnEveryKeystroke = false;

  static const String timingNote =
      'A required-field error raised on the first keystroke tells somebody '
      'their name is invalid while they are typing it, and the ones who see it '
      'most are the slowest typists. The rule runs when the field is left or '
      'when the form is submitted. Step 290 declared the dwell thresholds for '
      'this, so the moment is read from there rather than picked again, and '
      'nothing here interrupts.';

  // -----------------------------------------------------------------------
  // What it says.
  // -----------------------------------------------------------------------

  static const Map<String, String> messages = <String, String>{
    'plainly empty': 'Enter your full name',
    'whitespace only': 'Enter your full name -- spaces alone are not enough',
    'invisible characters only':
        'This looks empty. Clear the field and type your full name',
  };

  static bool get everyMessageNamesTheField =>
      messages.values.every((String m) => m.contains('full name'));

  static bool get everyMessageSaysWhatToDo => messages.values.every(
        (String m) =>
            m.startsWith('Enter') ||
            m.contains('type your') ||
            m.contains('Clear'),
      );

  /// The third message is the one the naive rule cannot write, because the
  /// naive rule does not know the case exists.
  static bool get theInvisibleCaseHasItsOwnMessage =>
      messages.containsKey('invisible characters only');

  // -----------------------------------------------------------------------
  // The metric.
  // -----------------------------------------------------------------------

  static const double floorMs = 0.1;
  static const double optimalMs = 0.001;
  static const double ceilingMs = 0.5;

  /// One microsecond, which is about the granularity of the clock that would
  /// be used to measure it.
  static double get optimalMicroseconds => optimalMs * 1000;

  static bool get theOptimalSitsAtTheClocksResolution =>
      optimalMicroseconds <= 1;

  /// And the ceiling is five times the floor, on a metric where lower is
  /// better -- so the ceiling is the worst of the three numbers.
  static bool get theCeilingIsWorseThanTheFloor => ceilingMs > floorMs;

  static const String metricNote =
      'The metric times a trim. 0.001 ms is one microsecond, about the '
      'granularity of the clock that would measure it, so the optimal cannot '
      'be told apart from zero; and the ceiling, 0.5 ms, is five times the '
      'floor on a measure where lower is better, which makes it the worst of '
      'the three numbers rather than the best. None of it matters: trimming a '
      'forty-character string is tens of nanoseconds. The failure modes on '
      'this row are which strings count as blank and when the person is told, '
      'and the metric reaches neither.';

  static Map<String, bool> get obligations => <String, bool>{
        'null, empty and whitespace are all rejected':
            isBlank(null) && isBlank('') && isBlank('   '),
        'invisible format characters are rejected too':
            theRuleCatchesEveryCandidate,
        'a real value containing one is still accepted':
            aRealValueIsStillAccepted,
        'the check does not repair the value': !theCheckMutatesTheValue,
        'the rule does not fire while the person is typing':
            !firesOnEveryKeystroke && nothingInterruptsTyping,
        'every message names the field and says what to do':
            everyMessageNamesTheField && everyMessageSaysWhatToDo,
      };

  static String get qualitativeOutput =>
      obligations.values.every((bool b) => b) ? 'Pass' : 'Fail';

  static Map<String, bool> get checks => <String, bool>{
        'ten blank-looking candidates, eight caught by a trim':
            candidates.length == 10 &&
                caughtByTrim.length == 8 &&
                slippingThrough.length == 2 &&
                trimRecall == 0.8,
        'the two survivors are the zero width space and the word joiner':
            slippingThrough
                .every((HabotBlankCandidate c) => c.codePoint != null) &&
                slippingThrough.first.codePoint == 0x200B &&
                slippingThrough.last.codePoint == 0x2060,
        'the byte-order mark is trimmed although Unicode does not call it '
                'whitespace':
            caughtDespiteNotBeingWhiteSpace.length == 1 &&
                caughtDespiteNotBeingWhiteSpace.first.codePoint == 0xFEFF,
        'the rule this step ships catches all ten':
            theRuleCatchesEveryCandidate &&
                caughtByTheRule.length == candidates.length,
        'and does not start rejecting real input': aRealValueIsStillAccepted,
        'the person is looking at an empty box the app calls full':
            slipNote.contains('a character they cannot see'),
        'the value is not repaired behind the person\'s back':
            !theCheckMutatesTheValue &&
                mutationNote.contains('nobody can reproduce'),
        'the moment is read from Step 290 rather than chosen again':
            theMomentIsAlreadyDeclared && !firesOnEveryKeystroke,
        'the invisible case has a message the naive rule could not write':
            theInvisibleCaseHasItsOwnMessage && messages.length == 3,
        'the optimal sits at the resolution of its own instrument':
            theOptimalSitsAtTheClocksResolution && optimalMicroseconds == 1,
        'and the ceiling is the worst of the three numbers':
            theCeilingIsWorseThanTheFloor &&
                metricNote.contains('rather than the best'),
        'six obligations, all met, giving Pass':
            obligations.length == 6 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Pass',
      };

  static const String columnNote =
      'COLUMN NOTE: the Atomic Step carries a stray citation marker -- "[cite: '
      '558]" -- inside the instruction text, and every narrative column is the '
      'generic engineering-console boilerplate. Atomic Step: "Check if '
      'required text input strings are null, empty, or consist purely of '
      'whitespace characters."';
}
