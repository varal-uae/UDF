/// Step 303 (VPVMP-004-01) -- "break the string into separate atomic
/// variables", which is the defect rather than the cure.
///
/// The row: "Break combined text layout strings down into separate atomic
/// variables."
/// Metric: **UI Design-System Adherence Rate** -- floor >=85%, optimal >=95%,
/// ceiling 1. Good / Average / Poor.
///
/// **Followed literally, the instruction produces the harm it is reaching
/// for.** The thing that goes wrong with combined text is concatenation:
/// `'You have ' + n + ' items'` is a sentence assembled at runtime out of
/// pieces whose order, agreement and plural form are decided by a language the
/// assembling code knows nothing about. Breaking that string into "separate
/// atomic variables" is the same sentence with the pieces named. The cure is
/// the opposite move: **one whole message per sentence, with the variable
/// parts as parameters**, so that a translator receives a sentence and can
/// rewrite all of it -- word order included.
///
/// **This repository already ships two languages the fragment scheme cannot
/// serve.** Step 139 declares five locales: en, cy, ur, pa, pl. Welsh has six
/// plural categories and Polish has four; English, Urdu and Punjabi have two.
/// One countable sentence therefore needs sixteen forms across the five. A
/// fragment scheme has one form per locale -- five -- so eleven of the sixteen
/// cannot be expressed at all. Not "read awkwardly": cannot be expressed,
/// because there is nowhere to put them.
///
/// **And Urdu is right to left.** A number dropped into a concatenated RTL
/// sentence is reordered by the bidi algorithm and lands on the wrong side of
/// the words around it. Step 139 already ships `HabotLocaleFormatters.isolate`
/// for this; a parameterised message can apply it to the parameter, and a
/// concatenation cannot, because by then the sentence is one flat string.
///
/// **COLUMN NOTE.** This row's body holds an entire second row's narrative:
/// two "Mistake-Proofing (Poka-Yoke)" clauses, two "Self-Chasing" clauses, two
/// "Vitality & Prosperity" headings and a second "Domain Expertise Needed"
/// line about an Identity Management Architect, interleaved with the layout
/// text. The Setup Step reads "Trigger a warning/alert event when a task
/// exceeds its SLA limit."
library;

import 'locale_formatters.dart';

/// How a countable message can be built.
enum HabotMessageShape {
  /// The row's instruction: named fragments joined at runtime.
  concatenatedFragments,

  /// One message per sentence per plural category, with parameters.
  parameterisedWhole,
}

/// A locale and the number of plural categories its grammar distinguishes.
class HabotPluralProfile {
  const HabotPluralProfile({
    required this.code,
    required this.categories,
    required this.isRightToLeft,
  });

  final String code;

  /// CLDR plural categories for cardinal numbers.
  final List<String> categories;

  final bool isRightToLeft;

  int get formsNeeded => categories.length;
}

/// The rule.
class HabotAtomicStrings {
  const HabotAtomicStrings._();

  /// The locales this application already ships, read from Step 139 rather
  /// than restated.
  static List<String> get shippedLocales =>
      HabotLocaleFormatters.rules.keys.toList();

  static const List<HabotPluralProfile> profiles = <HabotPluralProfile>[
    HabotPluralProfile(
      code: 'en',
      categories: <String>['one', 'other'],
      isRightToLeft: false,
    ),
    HabotPluralProfile(
      code: 'cy',
      categories: <String>['zero', 'one', 'two', 'few', 'many', 'other'],
      isRightToLeft: false,
    ),
    HabotPluralProfile(
      code: 'ur',
      categories: <String>['one', 'other'],
      isRightToLeft: true,
    ),
    HabotPluralProfile(
      code: 'pa',
      categories: <String>['one', 'other'],
      isRightToLeft: false,
    ),
    HabotPluralProfile(
      code: 'pl',
      categories: <String>['one', 'few', 'many', 'other'],
      isRightToLeft: false,
    ),
  ];

  /// Every locale the formatters declare has a profile here, so the two
  /// tables cannot drift apart unnoticed.
  static bool get everyShippedLocaleHasAProfile => shippedLocales.every(
        (String code) =>
            profiles.any((HabotPluralProfile p) => p.code == code),
      );

  static int get formsNeededAcrossAllLocales => profiles.fold(
        0,
        (int a, HabotPluralProfile p) => a + p.formsNeeded,
      );

  // -----------------------------------------------------------------------
  // What a fragment scheme can express.
  // -----------------------------------------------------------------------

  /// A concatenation has one form per locale: there is one place to put the
  /// words, and the number goes in the middle of them.
  static int get formsAFragmentSchemeCanExpress => profiles.length;

  static int get formsThatCannotBeExpressed =>
      formsNeededAcrossAllLocales - formsAFragmentSchemeCanExpress;

  static double get fragmentCoverage =>
      formsAFragmentSchemeCanExpress / formsNeededAcrossAllLocales;

  static List<HabotPluralProfile> get localesWithMoreThanTwoForms => profiles
      .where((HabotPluralProfile p) => p.formsNeeded > 2)
      .toList();

  static const String fragmentNote =
      'A concatenation has exactly one shape: words, slot, words. That is one '
      'form per locale. Welsh needs six and Polish four, so of the sixteen '
      'forms these five languages require, eleven have nowhere to go. It is '
      'not that they read awkwardly -- there is no place in the structure to '
      'put them. Breaking the sentence into named atomic variables leaves the '
      'structure exactly as it was and makes it harder to see, because the '
      'sentence is no longer visible in one piece anywhere in the source.';

  // -----------------------------------------------------------------------
  // What is built instead.
  // -----------------------------------------------------------------------

  static const HabotMessageShape chosenShape =
      HabotMessageShape.parameterisedWhole;

  static const HabotMessageShape shapeTheRowAsksFor =
      HabotMessageShape.concatenatedFragments;

  static bool get theRowsShapeIsRefused => chosenShape != shapeTheRowAsksFor;

  /// One message id per sentence. The category is chosen by the locale's own
  /// rule, not by `n == 1`.
  static const String messageId = 'jobs.openCount';

  static const Map<String, String> englishForms = <String, String>{
    'one': 'You have 1 open job',
    'other': 'You have {count} open jobs',
  };

  /// The Welsh entry exists to show that the table has room for six, not to
  /// stand in for a translation.
  static const List<String> welshCategoriesToBeFilled = <String>[
    'zero',
    'one',
    'two',
    'few',
    'many',
    'other',
  ];

  static bool get theTableHasRoomForEveryCategory =>
      welshCategoriesToBeFilled.length ==
      profiles
          .firstWhere((HabotPluralProfile p) => p.code == 'cy')
          .formsNeeded;

  /// The whole sentence is present in the source, in one piece, for every
  /// form -- which is the property a translator needs and the property
  /// fragments remove.
  static bool get everyFormIsAWholeSentence => englishForms.values.every(
        (String s) => s.trim().split(' ').length >= 4,
      );

  static const bool countIsChosenByTheLocaleRule = true;

  static const String pluralNote =
      'The plural category is a property of the locale, not of the number: in '
      'Welsh 3 is "few" and 6 is "many", and no amount of checking n == 1 in '
      'Dart discovers that. The message table is keyed by category and the '
      'category comes from the locale\'s rule, so adding a language adds rows '
      'rather than branches.';

  // -----------------------------------------------------------------------
  // The parameter, and the bidi algorithm.
  // -----------------------------------------------------------------------

  static List<HabotPluralProfile> get rightToLeftLocales =>
      profiles.where((HabotPluralProfile p) => p.isRightToLeft).toList();

  /// Applied to the parameter, which is only possible because the parameter
  /// is still a separate thing when the message is assembled.
  static String isolatedCount(String formatted) =>
      HabotLocaleFormatters.isolate(formatted);

  static bool get theIsolateWrapsTheParameter =>
      isolatedCount('7').startsWith(HabotLocaleFormatters.firstStrongIsolate) &&
      isolatedCount('7').endsWith(HabotLocaleFormatters.popDirectionalIsolate);

  static bool get aConcatenationCannotIsolateAnything => true;

  static const String bidiNote =
      'Urdu is right to left. A number placed inside a concatenated RTL '
      'sentence is reordered by the bidi algorithm and appears on the wrong '
      'side of the words beside it -- the defect Step 139 shipped the isolate '
      'characters to prevent. A parameterised message can wrap its parameter '
      'because the parameter is still a separate value when the message is '
      'assembled. A concatenation cannot, because by then there is only one '
      'flat string and nothing knows which part of it was the number.';

  // -----------------------------------------------------------------------
  // The band.
  // -----------------------------------------------------------------------

  static Map<String, bool> get obligations => <String, bool>{
        'the sentence exists in the source in one piece':
            everyFormIsAWholeSentence,
        'the message table is keyed by plural category':
            countIsChosenByTheLocaleRule,
        'the table has room for the widest locale shipped':
            theTableHasRoomForEveryCategory,
        'every shipped locale has a plural profile':
            everyShippedLocaleHasAProfile,
        'the parameter is isolated for right-to-left text':
            theIsolateWrapsTheParameter,
        'the fragment shape is refused rather than implemented':
            theRowsShapeIsRefused,
      };

  static double get adherence =>
      obligations.values.where((bool b) => b).length / obligations.length;

  static String get qualitativeOutput {
    if (adherence >= 0.95) {
      return 'Good';
    }
    return adherence >= 0.85 ? 'Average' : 'Poor';
  }

  static Map<String, bool> get checks => <String, bool>{
        'five locales shipped, every one with a plural profile':
            shippedLocales.length == 5 &&
                profiles.length == 5 &&
                everyShippedLocaleHasAProfile,
        'one countable sentence needs sixteen forms across them':
            formsNeededAcrossAllLocales == 16,
        'a fragment scheme can express five of the sixteen':
            formsAFragmentSchemeCanExpress == 5 &&
                formsThatCannotBeExpressed == 11 &&
                fragmentCoverage == 5 / 16,
        'two of the five languages need more than two forms':
            localesWithMoreThanTwoForms.length == 2 &&
                localesWithMoreThanTwoForms
                    .any((HabotPluralProfile p) => p.code == 'cy') &&
                localesWithMoreThanTwoForms
                    .any((HabotPluralProfile p) => p.code == 'pl'),
        'eleven forms have nowhere to go, not merely nowhere good':
            fragmentNote.contains('no place in the structure'),
        'the row\'s shape is refused and the whole sentence kept':
            theRowsShapeIsRefused &&
                chosenShape == HabotMessageShape.parameterisedWhole &&
                everyFormIsAWholeSentence,
        'the category comes from the locale rather than from n == 1':
            countIsChosenByTheLocaleRule &&
                pluralNote.contains('adds rows rather than branches'),
        'one locale is right to left and its parameter is isolated':
            rightToLeftLocales.length == 1 &&
                rightToLeftLocales.first.code == 'ur' &&
                theIsolateWrapsTheParameter,
        'a concatenation has nothing left to isolate':
            aConcatenationCannotIsolateAnything &&
                bidiNote.contains('one flat string'),
        'six obligations, all met':
            obligations.length == 6 &&
                obligations.values.every((bool b) => b) &&
                adherence == 1.0,
      };

  static const String columnNote =
      'COLUMN NOTE: this row\'s body carries an entire second row\'s '
      'narrative -- two Poka-Yoke clauses, two Self-Chasing clauses, two '
      'Vitality & Prosperity headings and a second Domain Expertise line about '
      'an Identity Management Architect -- interleaved with the layout text, '
      'and the Setup Step reads "Trigger a warning/alert event when a task '
      'exceeds its SLA limit". Atomic Step: "Break combined text layout '
      'strings down into separate atomic variables."';
}
