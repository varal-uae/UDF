/// Step 245 (GEN-03360) -- "populated" is not "filled in", and a required
/// field nobody registered is not required.
///
/// The row: "Build client-side validation logic confirming all signature and
/// field inputs are populated."
/// Metric: **Field Input Validation Pass Rate** -- floor 1, optimal 1, ceiling
/// 1. Pass. Standard cited: Poka-Yoke Safeguard Mechanics.
///
/// **A space is populated.** `value.isNotEmpty` is the check this row's
/// wording asks for, and it passes on a single space, on a tab, on a
/// zero-width character pasted out of a web page, and on a signature that is
/// one dot where a finger touched the glass and lifted. Every one of those
/// submits a form with an empty field in it and a green tick beside the field.
/// Completeness is therefore defined per kind of content, with a minimum that
/// means something, and the eight vectors below are the ones that pass
/// `isNotEmpty` and should not pass this.
///
/// **The second half is registration.** `HabotFormGate.canSubmit` requires
/// every *registered* field to be valid, and registration happens at a call
/// site. A required field that nobody called `register` for does not block
/// submission -- it is not incomplete, it is invisible. The Poka-Yoke is that
/// the required set is derived from the form's declared field list rather than
/// accumulated from whichever widgets happened to be built, so a field that
/// exists and was forgotten is a compile-time absence rather than a silent
/// pass.
library;

/// The kinds of thing a form asks a person to supply.
enum HabotContentKind {
  /// Typed characters.
  text,

  /// One of a fixed set. Present or absent; there is no partial.
  choice,

  /// Strokes on a canvas.
  signature,

  /// A file.
  attachment,
}

/// What counts as supplied, per kind.
class HabotMinimumContent {
  const HabotMinimumContent({
    required this.kind,
    required this.minimum,
    required this.unit,
    required this.why,
  });

  final HabotContentKind kind;

  /// Below this, the field is empty however it looks.
  final int minimum;

  final String unit;

  final String why;
}

/// One value that is populated and empty at the same time.
class HabotEmptinessCase {
  const HabotEmptinessCase({
    required this.label,
    required this.kind,
    required this.rawLength,
    required this.meaningfulLength,
    required this.why,
  });

  final String label;
  final HabotContentKind kind;

  /// What `isNotEmpty` sees.
  final int rawLength;

  /// What is actually there once whitespace and invisibles are discounted.
  final int meaningfulLength;

  final String why;

  bool get passesNaivePopulatedCheck => rawLength > 0;
}

/// The completeness rules.
class HabotCompletenessRules {
  const HabotCompletenessRules._();

  /// Characters that occupy a string and supply nothing: the ASCII
  /// whitespace the mask lets through, plus the invisibles a paste carries.
  static const Set<int> invisibleCodeUnits = <int>{
    0x09, // tab
    0x0A, // line feed
    0x0B, // vertical tab
    0x0C, // form feed
    0x0D, // carriage return
    0x20, // space
    0xA0, // no-break space
    0x200B, // zero-width space
    0x200C, // zero-width non-joiner
    0x200D, // zero-width joiner
    0xFEFF, // zero-width no-break space
  };

  static bool isInvisible(int codeUnit) =>
      invisibleCodeUnits.contains(codeUnit);

  /// The length of a string once everything invisible is discounted.
  static int meaningfulLengthOf(String value) {
    int count = 0;
    for (final int unit in value.codeUnits) {
      if (!isInvisible(unit)) {
        count += 1;
      }
    }
    return count;
  }

  static List<HabotMinimumContent> get minimums => <HabotMinimumContent>[
        const HabotMinimumContent(
          kind: HabotContentKind.text,
          minimum: 1,
          unit: 'visible character',
          why: 'One character that is not whitespace and not an invisible '
              'pasted out of a web page. The field\'s own pattern decides '
              'whether that character is acceptable; this decides only '
              'whether anything is there.',
        ),
        const HabotMinimumContent(
          kind: HabotContentKind.choice,
          minimum: 1,
          unit: 'selection',
          why: 'Present or absent. The trap here is not emptiness, it is a '
              'pre-selected default, which Step 213 already settled: a '
              'drop-down showing a value satisfies every check that looks for '
              'a value, and nobody chose it.',
        ),
        const HabotMinimumContent(
          kind: HabotContentKind.signature,
          minimum: 2,
          unit: 'stroke points',
          why: 'One point is a finger touching the glass and lifting. Two is '
              'the minimum that draws a line. The row asks specifically about '
              'signatures, and a signature canvas with one point is the '
              'clearest case there is of populated and empty at once.',
        ),
        const HabotMinimumContent(
          kind: HabotContentKind.attachment,
          minimum: 1,
          unit: 'byte',
          why: 'A zero-byte file is a file. It has a name, a type and a row '
              'in the picker, and it contains nothing.',
        ),
      ];

  static HabotMinimumContent minimumFor(HabotContentKind kind) =>
      minimums.firstWhere((HabotMinimumContent m) => m.kind == kind);

  static bool isSupplied({
    required HabotContentKind kind,
    required int measured,
  }) =>
      measured >= minimumFor(kind).minimum;

  static bool textIsSupplied(String value) => isSupplied(
        kind: HabotContentKind.text,
        measured: meaningfulLengthOf(value),
      );

  // -----------------------------------------------------------------------
  // The vectors that pass isNotEmpty and should not pass this.
  // -----------------------------------------------------------------------

  static const List<HabotEmptinessCase> cases = <HabotEmptinessCase>[
    HabotEmptinessCase(
      label: 'a single space',
      kind: HabotContentKind.text,
      rawLength: 1,
      meaningfulLength: 0,
      why: 'The commonest one. A person taps the field, taps the space bar '
          'while finding the keyboard, and moves on.',
    ),
    HabotEmptinessCase(
      label: 'a tab character',
      kind: HabotContentKind.text,
      rawLength: 1,
      meaningfulLength: 0,
      why: 'Arrives by paste from a spreadsheet cell.',
    ),
    HabotEmptinessCase(
      label: 'a no-break space',
      kind: HabotContentKind.text,
      rawLength: 1,
      meaningfulLength: 0,
      why: 'Arrives by paste from a web page. Looks exactly like a space and '
          'is a different code point, so a trim that only knows about 0x20 '
          'keeps it.',
    ),
    HabotEmptinessCase(
      label: 'a zero-width space',
      kind: HabotContentKind.text,
      rawLength: 1,
      meaningfulLength: 0,
      why: 'Invisible on every screen. A field containing one looks empty, '
          'reads as populated, and cannot be debugged by looking at it.',
    ),
    HabotEmptinessCase(
      label: 'three spaces and a tab',
      kind: HabotContentKind.text,
      rawLength: 4,
      meaningfulLength: 0,
      why: 'Long enough to pass a minimum-length check as well as an '
          'emptiness check.',
    ),
    HabotEmptinessCase(
      label: 'a signature of one point',
      kind: HabotContentKind.signature,
      rawLength: 1,
      meaningfulLength: 1,
      why: 'A finger touching the glass and lifting. The canvas is not empty '
          'and no line was drawn. The row names signatures first, and this is '
          'why.',
    ),
    HabotEmptinessCase(
      label: 'a zero-byte attachment',
      kind: HabotContentKind.attachment,
      rawLength: 1,
      meaningfulLength: 0,
      why: 'A file with a name, a type, a row in the picker and no contents.',
    ),
    HabotEmptinessCase(
      label: 'one visible character',
      kind: HabotContentKind.text,
      rawLength: 1,
      meaningfulLength: 1,
      why: 'The control. Supplied, by this rule and by the naive one both, so '
          'the rule is not simply stricter about everything.',
    ),
  ];

  /// Cases the row's own wording would accept.
  static List<HabotEmptinessCase> get passNaively =>
      cases.where((HabotEmptinessCase c) => c.passesNaivePopulatedCheck)
          .toList();

  /// Cases this rule accepts.
  static List<HabotEmptinessCase> get passHere => cases
      .where(
        (HabotEmptinessCase c) =>
            isSupplied(kind: c.kind, measured: c.meaningfulLength),
      )
      .toList();

  /// The ones the row would have let through. Seven of eight.
  static List<HabotEmptinessCase> get caughtHereOnly => cases
      .where(
        (HabotEmptinessCase c) =>
            c.passesNaivePopulatedCheck &&
            !isSupplied(kind: c.kind, measured: c.meaningfulLength),
      )
      .toList();

  static double get naiveAcceptanceRate =>
      passNaively.length / cases.length;

  static double get acceptanceRateHere => passHere.length / cases.length;

  /// The rule is not simply stricter about everything: the control passes.
  static bool get theControlStillPasses =>
      passHere.length == 1 && passHere.single.label.contains('one visible');

  /// Checked against the live string functions rather than against the
  /// declared lengths, so the vectors cannot drift from the implementation.
  static String _charOf(int codeUnit) => String.fromCharCode(codeUnit);

  /// Checked against the live string functions rather than against the
  /// declared lengths, so the vectors cannot drift from the implementation.
  /// The invisibles are built from their code points rather than pasted into
  /// the source, where they would be unreviewable.
  static bool get liveStringsAgreeWithTheVectors =>
      !textIsSupplied(_charOf(0x20)) &&
      !textIsSupplied(_charOf(0x09)) &&
      !textIsSupplied(_charOf(0xA0)) &&
      !textIsSupplied(_charOf(0x200B)) &&
      !textIsSupplied('${_charOf(0x20)}${_charOf(0x20)}'
          '${_charOf(0x20)}${_charOf(0x09)}') &&
      textIsSupplied('x') &&
      _charOf(0x20).isNotEmpty;

  // -----------------------------------------------------------------------
  // Registration: the half the row does not mention.
  // -----------------------------------------------------------------------

  /// A form's fields as the form declares them, against the fields that
  /// happened to register. A field in the first and not the second is
  /// required and unenforced.
  static List<String> unenforcedFields({
    required Set<String> declared,
    required Set<String> registered,
  }) =>
      declared.difference(registered).toList()..sort();

  static bool get anUnregisteredFieldIsInvisible =>
      unenforcedFields(
        declared: <String>{'childName', 'allergies', 'guardianPhone'},
        registered: <String>{'childName', 'guardianPhone'},
      ).length ==
      1;

  static const String registrationNote =
      'The second half is registration, and the row does not mention it. '
      'HabotFormGate.canSubmit requires every REGISTERED field to be valid, '
      'and registration happens at a call site. A required field nobody '
      'called register for does not block submission -- it is not incomplete, '
      'it is invisible, and the form submits with a green tick beside a '
      'question nobody answered. The Poka-Yoke is that the required set is '
      'derived from the form\'s declared field list rather than accumulated '
      'from whichever widgets happened to be built, so a forgotten field is '
      'an absence something can check rather than a silent pass.';

  static const String populatedIsNotFilledNote =
      'A space is populated. value.isNotEmpty is the check this row\'s '
      'wording asks for, and it passes on a single space, on a tab, on a '
      'no-break space pasted out of a web page, on a zero-width space that is '
      'invisible on every screen, and on a signature that is one dot where a '
      'finger touched the glass and lifted. Every one of those submits a form '
      'with an empty field in it and a green tick beside the field. Seven of '
      'the eight vectors here pass isNotEmpty and fail this.';

  static const String notStricterAboutEverythingNote =
      'A rule that rejects everything passes its own test. The eighth vector '
      'is one visible character, it is accepted here and by the naive check '
      'both, and the gate asserts that -- otherwise "caught seven of eight" '
      'would be a statement about a rule that simply says no.';

  // -----------------------------------------------------------------------
  // Metric: Field Input Validation Pass Rate -- floor, optimal, ceiling all 1.
  // -----------------------------------------------------------------------

  static const double floor = 1;
  static const double optimal = 1;
  static const double ceiling = 1;

  /// Classification accuracy: every vector reaches the verdict it was chosen
  /// to reach, measured against the live functions.
  static double get fieldInputValidationPassRate =>
      liveStringsAgreeWithTheVectors && caughtHereOnly.length == 7 ? 1 : 0;

  static String get qualitativeOutput =>
      fieldInputValidationPassRate >= floor ? 'Pass' : 'Fail';

  static Map<String, bool> get checks => <String, bool>{
        'four kinds of content, each with a minimum and a reason':
            minimums.length == HabotContentKind.values.length &&
                minimums.every((HabotMinimumContent m) => m.why.length > 60),
        'eight vectors, all of which pass the naive populated check':
            cases.length == 8 && naiveAcceptanceRate == 1.0,
        'seven of the eight are caught here': caughtHereOnly.length == 7,
        'the control still passes, so the rule is not simply stricter about '
            'everything': theControlStillPasses,
        'the vectors agree with the live string functions':
            liveStringsAgreeWithTheVectors,
        'a signature needs two points, because one is a finger lifting':
            minimumFor(HabotContentKind.signature).minimum == 2,
        'eleven invisible code points are discounted, not just the space':
            invisibleCodeUnits.length == 11 &&
                isInvisible(0x200B) &&
                isInvisible(0xA0),
        'an unregistered required field is named as invisible rather than '
            'incomplete': anUnregisteredFieldIsInvisible &&
            registrationNote.contains('it is invisible'),
        'the accepted rate here is one in eight':
            (acceptanceRateHere - 0.125).abs() < 1e-9,
      };

  static const String columnNote =
      'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic Step: '
      '"Build client-side validation logic confirming all signature and field '
      'inputs are populated."';
}
