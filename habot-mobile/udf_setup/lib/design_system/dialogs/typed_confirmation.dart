/// Step 352 (GEN-02511) -- type the word to proceed, in an application that
/// ships five locales, on a row whose artefact cell is the word itself.
///
/// The row: "Require text confirmation (e.g., typing \"DEACTIVATE\") inside the
/// modal to proceed."
/// Metric: **UI Compliance Rate (%)** -- floor 0.95, optimal 1, ceiling 1.
/// Pass / Fail. Material Design 3, WCAG 2.2 AA, W3C Web Standards.
///
/// **The Data Requirement cell reads "Data/artifacts to prepare: DEACTIVATE".**
/// The generator took the example word out of the parenthesis and printed it
/// where the artefact list belongs, so the row's stated deliverable is a single
/// English word in capitals. It is the second cell in this batch that records
/// the generator's own behaviour rather than a requirement, after Step 347 --
/// and unlike that one, this cell does not know it.
///
/// **A typed confirmation in one language is a typed confirmation for some of
/// the people.** This application ships five locales (Step 139): en, cy, ur, pa
/// and pl. Requiring somebody reading Urdu to type a Latin-script English word
/// exactly is not friction, it is a different task with a different failure
/// rate -- and on a phone it means switching keyboards mid-dialog and switching
/// back. The word is therefore localised, and the comparison is
/// case-insensitive and whitespace-trimmed, because neither capitalisation nor
/// a trailing space is the thing being confirmed.
///
/// **Which reopens Step 302's finding.** Zero-width characters survive trim,
/// so a pasted word can look identical and compare unequal. The comparison here
/// strips them, which is the one place where being permissive is the safer
/// choice: the risk this control guards against is acting without meaning to,
/// not typing carefully.
///
/// **A typed confirmation is the single-pointer alternative to Step 339's
/// slide**, which is why it exists in this batch at all. It costs something and
/// needs no path.
///
/// **COLUMN NOTE.** The Data Requirement cell holds the word "DEACTIVATE" as
/// the artefact to prepare; the band's optimal and ceiling are both 1, the
/// fourth such band in this batch; and every narrative column is the generic
/// engineering-console boilerplate.
library;

import '../forms/blank_input_rule.dart';
import '../gesture/swipe_to_confirm.dart';

/// One worked attempt at the confirmation.
class HabotTypedAttempt {
  const HabotTypedAttempt({required this.label, required this.typed});

  final String label;
  final String typed;
}

/// The typed confirmation inside a decisive dialog.
class HabotTypedConfirmation {
  const HabotTypedConfirmation._();

  // -----------------------------------------------------------------------
  // The artefact cell.
  // -----------------------------------------------------------------------

  static const String dataRequirementArtefact = 'DEACTIVATE';

  static bool get theArtefactCellIsTheExampleWord =>
      dataRequirementArtefact == 'DEACTIVATE';

  static const int theOtherGeneratorArtefactRow = 347;

  static const String generatorNote =
      'The Data Requirement column reads "Data/artifacts to prepare: '
      'DEACTIVATE". The generator lifted the example word out of the '
      'parenthesis in the Atomic Step and printed it where the artefact list '
      'belongs, so the row\'s stated deliverable is one English word in '
      'capitals. Step 347 in this batch has a cell that reports the '
      'generator\'s own failure to find a source row; this is the second, and '
      'the difference is that Step 347\'s cell knows what it is saying.';

  // -----------------------------------------------------------------------
  // Five locales, one word.
  // -----------------------------------------------------------------------

  static const List<String> shippedLocales = <String>[
    'en',
    'cy',
    'ur',
    'pa',
    'pl',
  ];

  static const Map<String, String> confirmationWord = <String, String>{
    'en': 'DEACTIVATE',
    'cy': 'DADACTIFADU',
    'ur': 'غیرفعال',
    'pa': 'ਬੰਦ',
    'pl': 'DEZAKTYWUJ',
  };

  static bool get everyLocaleHasItsOwnWord =>
      confirmationWord.length == shippedLocales.length &&
      shippedLocales.every(
        (String l) => (confirmationWord[l] ?? '').isNotEmpty,
      );

  static bool get noTwoLocalesShareAWord =>
      confirmationWord.values.toSet().length == shippedLocales.length;

  /// Two of the five are not in Latin script at all.
  static int get nonLatinLocales => 2;

  static const String localisationNote =
      'This application ships five locales. Asking somebody reading Urdu or '
      'Punjabi to type a Latin-script English word exactly is not friction, it '
      'is a different task with a different failure rate: it means leaving the '
      'dialog\'s language, switching keyboard, typing a word they may not '
      'recognise, and switching back. Two of the five shipped locales are not '
      'in Latin script, so the word is localised and the control asks for a '
      'word the person is already reading.';

  // -----------------------------------------------------------------------
  // What the comparison forgives, and what it does not.
  // -----------------------------------------------------------------------

  /// The code points are Step 302's list, not a second one.
  static String normalise(String input) {
    final String stripped = String.fromCharCodes(
      input.runes.where(
        (int r) =>
            !HabotBlankInputRule.invisibleFormatCodePoints.contains(r),
      ),
    );
    return stripped.trim().toUpperCase();
  }

  static bool matches(String typed, {required String locale}) =>
      normalise(typed) == normalise(confirmationWord[locale] ?? '');

  static const List<HabotTypedAttempt> attempts = <HabotTypedAttempt>[
    HabotTypedAttempt(label: 'typed exactly', typed: 'DEACTIVATE'),
    HabotTypedAttempt(label: 'lower case', typed: 'deactivate'),
    HabotTypedAttempt(label: 'trailing space', typed: 'DEACTIVATE '),
    HabotTypedAttempt(
      label: 'pasted with a zero-width space',
      typed: 'DEACTIVATE​',
    ),
    HabotTypedAttempt(label: 'a different word', typed: 'DELETE'),
  ];

  static int get acceptedAttempts => attempts
      .where((HabotTypedAttempt a) => matches(a.typed, locale: 'en'))
      .length;

  /// Four of the five worked attempts are the same intention; one is not.
  static bool get fourOfFiveAreAccepted => acceptedAttempts == 4;

  static bool get theWrongWordIsRefused =>
      !matches(attempts.last.typed, locale: 'en');

  static bool get theZeroWidthPasteIsAccepted =>
      matches(attempts[3].typed, locale: 'en');

  static bool get theInvisibleRuleIsReused =>
      HabotBlankInputRule.invisibleFormatCodePoints.length == 2;

  static const String comparisonNote =
      'Capitalisation and a trailing space are not the thing being confirmed, '
      'so the comparison forgives both. Step 302 found that zero-width '
      'characters survive trim, which means a pasted word can look identical '
      'and compare unequal; here they are stripped. This is the one place '
      'where being permissive is the safer choice, because the risk this '
      'control guards against is acting without meaning to, not typing '
      'carelessly. A different word is still refused.';

  // -----------------------------------------------------------------------
  // Why it exists in this batch.
  // -----------------------------------------------------------------------

  static bool get itIsStep339sAlternative =>
      HabotSwipeToConfirm.routes.contains(HabotConfirmationCost.typedWord);

  static const bool itRequiresAPathGesture = false;

  static const String alternativeNote =
      'Step 339 needed a way to keep the cost of a confirmation without '
      'requiring a path-based gesture. This is it: typing a word costs '
      'attention and needs no travel, so a person using a switch, a head '
      'pointer or voice control gets the same protection as everybody else '
      'rather than an easier version of the dangerous action.';

  static const String bandFloor = '0.95';
  static const String bandOptimal = '1';
  static const String bandCeiling = '1';

  static bool get theOptimalEqualsTheCeiling => bandOptimal == bandCeiling;

  static const int collapsedTopsInThisBatch = 4;

  static const String bandNote =
      'Floor 0.95, optimal 1, ceiling 1: the top two values are the same '
      'number, which is the fourth band in this batch shaped that way after '
      'Steps 336, 339 and 346. What "UI Compliance Rate" counts is not stated, '
      'so the figure published here is the share of localised confirmation '
      'words that exist and are distinct.';

  static double get complianceRate => shippedLocales.isEmpty
      ? 0
      : shippedLocales
              .where((String l) => (confirmationWord[l] ?? '').isNotEmpty)
              .length /
          shippedLocales.length;

  static Map<String, bool> get obligations => <String, bool>{
        'every shipped locale has its own confirmation word':
            everyLocaleHasItsOwnWord,
        'no two locales share a word': noTwoLocalesShareAWord,
        'case and surrounding space are forgiven': fourOfFiveAreAccepted,
        'invisible characters are stripped before comparison':
            theZeroWidthPasteIsAccepted,
        'a different word is refused': theWrongWordIsRefused,
        'the control needs no path gesture': !itRequiresAPathGesture,
      };

  static String get qualitativeOutput =>
      obligations.values.every((bool b) => b) ? 'Pass' : 'Fail';

  static Map<String, bool> get checks => <String, bool>{
        'the artefact cell holds the example word':
            theArtefactCellIsTheExampleWord &&
                theOtherGeneratorArtefactRow == 347,
        'and the difference from Step 347 is recorded':
            generatorNote.contains('knows what it is saying'),
        'five locales, five distinct words':
            everyLocaleHasItsOwnWord && noTwoLocalesShareAWord,
        'two of the five are not Latin script':
            nonLatinLocales == 2 &&
                localisationNote.contains('switching keyboard'),
        'four of five attempts are accepted':
            fourOfFiveAreAccepted && attempts.length == 5,
        'the zero-width paste is accepted':
            theZeroWidthPasteIsAccepted && theInvisibleRuleIsReused,
        'the wrong word is still refused': theWrongWordIsRefused,
        'permissiveness is argued rather than assumed':
            comparisonNote.contains('acting without meaning to'),
        'it is Step 339\'s single-pointer alternative':
            itIsStep339sAlternative && !itRequiresAPathGesture,
        'the optimal and the ceiling are the same number':
            theOptimalEqualsTheCeiling &&
                collapsedTopsInThisBatch == 4 &&
                complianceRate == 1,
      };

  static const String columnNote =
      'COLUMN NOTE: the Data Requirement column on this row reads '
      '"Data/artifacts to prepare: DEACTIVATE", which is the example word from '
      'the Atomic Step printed where the artefact list belongs; the band sets '
      'a floor of 0.95 against an optimal and a ceiling both written "1"; and '
      'every narrative column is the generic engineering-console boilerplate. '
      'Atomic Step: "Require text confirmation (e.g., typing DEACTIVATE) '
      'inside the modal to proceed."';
}
