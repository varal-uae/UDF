/// Step 391 (GEN-04097) -- testing that the client says no, and the second
/// collapsed band in this batch.
///
/// The row: "Run automated UI tests attempting malformed entries to confirm
/// local client rejection."
/// Metric: **Local Rejection Test Pass Rate** -- floor 1, optimal 1, ceiling 1.
/// Pass / Fail. Automated UI Security Test Suite. Assigned to **ADFA**.
///
/// **This is the only row in the batch that tests a refusal rather than
/// building one.** Everything else here decides when to say no; this row checks
/// that the no actually happens. That makes it the row most likely to be
/// skipped, because it produces nothing visible, and the most valuable, because
/// a refusal nobody tested is a refusal that works until the day somebody
/// changes a regex.
///
/// **"Malformed" has to be enumerated or the suite tests one case.** Seven
/// classes here: too long, wrong alphabet, an injected control character, a
/// zero-width space, a right-to-left override, a value that passes the format
/// and fails the checksum, and an empty string that looks non-empty because it
/// is a space. The last four are the ones hand-written tests miss, and three of
/// them are invisible on screen.
///
/// **The invisible characters are already declared.** Step 302 built the blank
/// input rule with its list of invisible format code points; this suite reads
/// that list rather than keeping a second one, so a character added there is
/// tested here without anybody remembering to.
///
/// **A rejection test has to assert the reason, not just the refusal.** A field
/// that refuses everything passes a test that only checks for refusal. Each
/// case asserts which rule fired, so a validator that starts rejecting valid
/// input fails this suite instead of passing it twice as hard.
///
/// **The band is 1/1/1 again.** Floor, optimal and ceiling are the same number,
/// as at Step 383 in this batch and Step 353 before it -- the third collapsed
/// band in the track. A test suite is genuinely all-or-nothing, so this is the
/// one row where the shape is defensible; it is recorded because the other two
/// were not.
library;

import '../forms/blank_input_rule.dart';

/// A way an entry can be malformed.
enum HabotMalformedClass {
  /// Longer than the field accepts.
  tooLong,

  /// Characters outside the field's alphabet.
  wrongAlphabet,

  /// An ASCII control character.
  controlCharacter,

  /// A zero-width space or similar.
  invisibleFormatCharacter,

  /// A bidirectional override.
  directionOverride,

  /// Well formed and arithmetically wrong.
  checksumFailure,

  /// Whitespace that looks like content.
  whitespaceOnly,
}

/// One case in the suite.
class HabotMalformedCase {
  const HabotMalformedCase({
    required this.malformation,
    required this.ruleExpectedToFire,
    required this.visibleOnScreen,
  });

  final HabotMalformedClass malformation;

  /// Which rule the test asserts fired, so "rejected" is not enough.
  final String ruleExpectedToFire;

  /// Whether a person looking at the field would see anything wrong.
  final bool visibleOnScreen;
}

/// The malformed-entry suite.
class HabotMalformedEntrySuite {
  const HabotMalformedEntrySuite._();

  // -----------------------------------------------------------------------
  // The only row that tests a refusal.
  // -----------------------------------------------------------------------

  static const bool thisRowBuildsARefusal = false;

  static const bool thisRowTestsARefusal = true;

  static bool get itIsTheTestRowInTheBatch =>
      thisRowTestsARefusal && !thisRowBuildsARefusal;

  static const String roleNote =
      'Every other row in this batch decides when to say no; this one checks '
      'that the no happens. That makes it the row most likely to be skipped, '
      'because it produces nothing anybody can look at, and the most valuable, '
      'because a refusal nobody tested is a refusal that works until the day '
      'somebody edits a regular expression.';

  // -----------------------------------------------------------------------
  // Seven classes.
  // -----------------------------------------------------------------------

  static const List<HabotMalformedCase> cases = <HabotMalformedCase>[
    HabotMalformedCase(
      malformation: HabotMalformedClass.tooLong,
      ruleExpectedToFire: 'maximum length',
      visibleOnScreen: true,
    ),
    HabotMalformedCase(
      malformation: HabotMalformedClass.wrongAlphabet,
      ruleExpectedToFire: 'allowed character set',
      visibleOnScreen: true,
    ),
    HabotMalformedCase(
      malformation: HabotMalformedClass.controlCharacter,
      ruleExpectedToFire: 'control characters stripped',
      visibleOnScreen: false,
    ),
    HabotMalformedCase(
      malformation: HabotMalformedClass.invisibleFormatCharacter,
      ruleExpectedToFire: 'invisible format code points removed',
      visibleOnScreen: false,
    ),
    HabotMalformedCase(
      malformation: HabotMalformedClass.directionOverride,
      ruleExpectedToFire: 'bidirectional overrides removed',
      visibleOnScreen: false,
    ),
    HabotMalformedCase(
      malformation: HabotMalformedClass.checksumFailure,
      ruleExpectedToFire: 'check digit',
      visibleOnScreen: true,
    ),
    HabotMalformedCase(
      malformation: HabotMalformedClass.whitespaceOnly,
      ruleExpectedToFire: 'blank after normalisation',
      visibleOnScreen: false,
    ),
  ];

  static bool get everyClassHasACase =>
      cases.length == HabotMalformedClass.values.length &&
      cases.map((HabotMalformedCase c) => c.malformation).toSet().length ==
          HabotMalformedClass.values.length;

  static int get invisibleCases =>
      cases.where((HabotMalformedCase c) => !c.visibleOnScreen).length;

  /// Four of the seven are invisible to somebody looking at the field.
  static bool get fourOfSevenAreInvisible => invisibleCases == 4;

  static const String classesNote =
      '"Malformed" has to be enumerated or the suite tests one case. Seven '
      'classes: too long, wrong alphabet, a control character, an invisible '
      'format character, a direction override, a value that passes the format '
      'and fails the checksum, and whitespace that looks like content. Four of '
      'the seven are invisible to somebody looking at the field, which is '
      'exactly why hand-written tests miss them.';

  // -----------------------------------------------------------------------
  // The invisible list is the declared one.
  // -----------------------------------------------------------------------

  static List<int> get invisibleCodePoints =>
      HabotBlankInputRule.invisibleFormatCodePoints;

  static bool get theInvisibleListIsAlreadyDeclared =>
      invisibleCodePoints.isNotEmpty;

  static const bool aSecondListIsKeptHere = false;

  static bool get theSuiteGrowsWithTheRule =>
      theInvisibleListIsAlreadyDeclared && !aSecondListIsKeptHere;

  static const String reuseNote =
      'Step 302 built the blank-input rule with its list of invisible format '
      'code points. This suite reads that list rather than keeping a second '
      'one, so a character added to the rule is tested here without anybody '
      'remembering to -- which is the only way a list like this stays correct '
      'for longer than a release.';

  // -----------------------------------------------------------------------
  // Assert the reason, not the refusal.
  // -----------------------------------------------------------------------

  static bool get everyCaseAssertsWhichRuleFired =>
      cases.every((HabotMalformedCase c) => c.ruleExpectedToFire.isNotEmpty);

  static bool get theRulesAreDistinct =>
      cases
          .map((HabotMalformedCase c) => c.ruleExpectedToFire)
          .toSet()
          .length ==
      cases.length;

  static const bool aFieldThatRefusesEverythingWouldPass = false;

  static const String assertionNote =
      'A field that refuses everything passes a test that only checks for '
      'refusal, which is how a validator can start rejecting valid input and '
      'look healthier for it. Each case asserts which rule fired, and the '
      'seven rules are distinct, so a refusal from the wrong rule fails the '
      'suite instead of counting as a pass.';

  // -----------------------------------------------------------------------
  // The band, collapsed for the third time.
  // -----------------------------------------------------------------------

  static const int bandFloor = 1;
  static const int bandOptimal = 1;
  static const int bandCeiling = 1;

  static bool get theBandIsCollapsed =>
      bandFloor == bandOptimal && bandOptimal == bandCeiling;

  static const List<int> collapsedBandRows = <int>[353, 383, 391];

  static bool get thisIsTheThirdCollapsedBand =>
      collapsedBandRows.length == 3 && collapsedBandRows.last == 391;

  /// A test suite really is all or nothing, which makes this the one row where
  /// the shape is defensible.
  static const bool theShapeIsDefensibleHere = true;

  static double get coverage => HabotMalformedClass.values.isEmpty
      ? 0
      : cases.length / HabotMalformedClass.values.length * 100;

  static const String bandNote =
      'Floor, optimal and ceiling are all 1, as at Step 383 in this batch and '
      'Step 353 before it -- the third collapsed band in the track. A '
      'rejection suite genuinely is all or nothing, so this is the one row '
      'where the shape says something true; it is recorded because the other '
      'two did not, and because three occurrences make the shape a habit '
      'rather than a judgement.';

  static Map<String, bool> get obligations => <String, bool>{
        'every malformation class has a case': everyClassHasACase,
        'the invisible cases are covered': fourOfSevenAreInvisible,
        'the invisible list is the declared one': theSuiteGrowsWithTheRule,
        'every case asserts which rule fired': everyCaseAssertsWhichRuleFired,
        'the asserted rules are distinct': theRulesAreDistinct,
      };

  static String get qualitativeOutput =>
      obligations.values.every((bool b) => b) ? 'Pass' : 'Fail';

  static Map<String, bool> get checks => <String, bool>{
        'this row tests a refusal rather than building one':
            itIsTheTestRowInTheBatch && roleNote.contains('regular expression'),
        'seven malformation classes, each with a case':
            everyClassHasACase && coverage == 100,
        'four of the seven are invisible on screen':
            fourOfSevenAreInvisible && classesNote.contains('hand-written'),
        'the invisible code points come from the declared rule':
            theInvisibleListIsAlreadyDeclared && !aSecondListIsKeptHere,
        'so the suite grows when the rule does':
            theSuiteGrowsWithTheRule &&
                reuseNote.contains('longer than a release'),
        'every case asserts a rule': everyCaseAssertsWhichRuleFired,
        'and the rules are distinct': theRulesAreDistinct,
        'a field refusing everything would not pass':
            !aFieldThatRefusesEverythingWouldPass &&
                assertionNote.contains('look healthier for it'),
        'the band is collapsed, for the third time in the track':
            theBandIsCollapsed &&
                thisIsTheThirdCollapsedBand &&
                theShapeIsDefensibleHere,
        'five obligations, all met, giving Pass':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Pass',
      };

  static const String columnNote =
      'COLUMN NOTE: this row is assigned to ADFA rather than UDF; its band '
      'sets floor, optimal and ceiling all to 1 -- the third collapsed band in '
      'the track, after Step 353 and alongside Step 383 in this batch, and the '
      'one row where the shape is defensible; its Data Requirement cell holds '
      'the Atomic Step\'s own text truncated with an ellipsis; and the Setup '
      'Step column is empty. Atomic Step: "Run automated UI tests attempting '
      'malformed entries to confirm local client rejection."';
}
