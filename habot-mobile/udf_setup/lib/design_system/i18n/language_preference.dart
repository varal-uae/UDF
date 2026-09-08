/// AISS Step 143 -- GEN-04583
/// Setup Step (Action) / Atomic Step: "Build a dynamic language switching
///   setting option in app preferences."
/// Metric: Translation/Localization Coverage -- Floor 0.95, Optimal 1.0,
///         Ceiling 1.0. Complete / Partial / Not Complete.
///
/// **THE POKA-YOKE IS THE 0.95 FLOOR BEING REFUSED.** The metric permits 95%
/// coverage. This implementation will not offer a language below 100%, and
/// that is a deliberate deviation upward from the floor, recorded here rather
/// than done quietly.
///
/// The reason: a 95%-translated screen is not 95% as good as a translated one.
/// One English sentence in the middle of Welsh does not read as "mostly
/// translated", it reads as a broken app -- and the missing 5% is never
/// distributed evenly. It concentrates in the strings added last, which are
/// the newest features and the error messages. Per-string fallback to English
/// also HIDES the gap from the very metric meant to expose it: the app looks
/// finished, the coverage number is whatever the last import produced, and
/// nobody is accountable for the difference. Step 138 recorded this as
/// decision D-3 before any of this was written.
///
/// **"INSTANT" (STEP 138, D-2) MEANS NO AWAIT ON THE LOOKUP PATH.**
/// [HabotLanguagePreference.stringOf] is synchronous and reads from memory,
/// for the same reason the Step 134 flag dispatcher is: a string fetched
/// inside `build()` produces a flash of the previous language, and on a device
/// that has never reached the network it produces English forever. Catalogues
/// ship in the bundle and are installed at startup.
///
/// **THE BOUNDARY, STATED: THIS STEP DELIVERS THE MECHANISM AND THE SOURCE
/// LANGUAGE, NOT THE TRANSLATIONS.** The English catalogue is here because
/// English is the source language and these are its own strings. Welsh, Urdu,
/// Punjabi and Polish catalogues are a translation deliverable produced by
/// people who speak those languages; inventing them here would put text in
/// front of users that no speaker had checked, which is worse than an
/// untranslated app and much harder to notice. What this step guarantees is
/// that a language cannot be OFFERED until its catalogue is complete -- so the
/// gap is visible in the coverage report rather than on a user's screen.
///
/// DIRECTION TRAVELS WITH THE LANGUAGE (Step 138, F-1). Selecting Urdu is not
/// a change of strings, it is a change of layout direction, and
/// [HabotLanguagePreference.direction] is the single place the rest of the app
/// reads it from.
library;

import 'package:flutter/foundation.dart';

import '../forms/field_validation.dart';
import 'localization_objective.dart';

/// Every message key the app can ask for.
///
/// Declared rather than discovered: a catalogue is only measurable against a
/// list of what it is supposed to contain, and a key that exists in English
/// and nowhere else is exactly the kind of gap this registry exists to find.
class HabotMessageKeys {
  const HabotMessageKeys._();

  /// App chrome and navigation.
  static const List<String> chrome = <String>[
    'app.title',
    'action.back',
    'action.next',
    'action.done',
    'action.cancel',
    'action.save',
    'action.retry',
    'status.offline',
    'status.saving',
    'status.saved',
    'settings.language',
    'settings.notifications',
    'wizard.stepOfTotal',
    'wizard.blocked.validation',
    'wizard.blocked.atFirst',
    'wizard.blocked.atLast',
  ];

  /// One error message per Critical Data Element.
  ///
  /// Step 138 finding F-4: the objective says "UI and FORM TEXT translation",
  /// and form text is mostly error messages. They are the highest-value
  /// strings in the app to translate -- a form that switches language and
  /// then rejects an entry in English fails the user at the exact moment they
  /// most need to understand what is wrong -- and the easiest to forget,
  /// because they live in HabotFieldRules rather than in a screen.
  static List<String> get fieldErrors =>
      HabotCde.values.map((HabotCde c) => 'error.${c.name}').toList();

  static List<String> get all => <String>[...chrome, ...fieldErrors];

  static int get count => all.length;
}

/// The installed strings for one language.
class HabotStringCatalogue {
  const HabotStringCatalogue({
    required this.localeCode,
    required this.strings,
    required this.source,
  });

  final String localeCode;
  final Map<String, String> strings;

  /// Who produced this catalogue. A translation with no provenance cannot be
  /// corrected, because nobody knows who to ask.
  final String source;

  /// Keys the registry declares that this catalogue does not have.
  List<String> get missingKeys => HabotMessageKeys.all
      .where((String k) =>
          !strings.containsKey(k) || strings[k]!.trim().isEmpty)
      .toList();

  /// Keys this catalogue has that the registry does not declare. Reported as
  /// well as the gaps: a stale key is dead weight a translator was paid for,
  /// and it usually means a string was renamed without the catalogues being
  /// told.
  List<String> get orphanKeys {
    final Set<String> declared = HabotMessageKeys.all.toSet();
    return strings.keys.where((String k) => !declared.contains(k)).toList();
  }

  double get coverage => HabotMessageKeys.count == 0
      ? 0
      : (HabotMessageKeys.count - missingKeys.length) /
          HabotMessageKeys.count;

  bool get isComplete => missingKeys.isEmpty;
}

/// The English catalogue. English is the source language, so these are not
/// translations -- they are the strings themselves.
class HabotEnglishStrings {
  const HabotEnglishStrings._();

  static const Map<String, String> values = <String, String>{
    'app.title': 'Habot',
    'action.back': 'Back',
    'action.next': 'Next',
    'action.done': 'Done',
    'action.cancel': 'Cancel',
    'action.save': 'Save',
    'action.retry': 'Try again',
    'status.offline': 'Offline',
    'status.saving': 'Saving',
    'status.saved': 'Saved',
    'settings.language': 'Language',
    // Shortened from 'Notification preferences' by the Step 144 expansion
    // audit: 24 characters overflows the 28-character header cap in Welsh
    // and Polish.
    'settings.notifications': 'Notifications',
    'wizard.stepOfTotal': 'Step {current} of {total}',
    // Step 149: the forward control refuses with a reason rather than being
    // greyed out, and the reason is translated like everything else.
    'wizard.blocked.validation': 'Answer this before moving on.',
    'wizard.blocked.atFirst': 'This is the first step.',
    'wizard.blocked.atLast': 'This is the last step.',
    'error.freeText': 'Enter this using ordinary letters and numbers.',
    'error.personName': 'Enter a name.',
    'error.emailAddress': 'Enter an email address, like name@example.com.',
    'error.phoneNumber': 'Enter a phone number.',
    'error.postalCode': 'Enter a postcode.',
    'error.addressLine': 'Enter the address.',
    'error.currencyAmount': 'Enter an amount, like 45.00.',
    'error.quantity': 'Enter a whole number.',
    'error.percentage': 'Enter a percentage between 0 and 100.',
    'error.dateIso': 'Enter a date, like 2026-09-08.',
    'error.dateUs': 'Enter a date, like 09/08/2026.',
    'error.timeOfDay': 'Enter a time, like 14:05.',
    'error.accountNumber': 'Enter the account number.',
  };

  static HabotStringCatalogue get catalogue => const HabotStringCatalogue(
        localeCode: 'en',
        strings: values,
        source: 'Source language, written in repo',
      );
}

/// The language preference, and the switch itself.
class HabotLanguagePreference extends ChangeNotifier {
  HabotLanguagePreference({
    List<HabotStringCatalogue>? catalogues,
    String initialLocale = 'en',
    Future<void> Function(String localeCode)? persist,
  }) : _persist = persist {
    for (final HabotStringCatalogue c
        in catalogues ?? <HabotStringCatalogue>[
          HabotEnglishStrings.catalogue,
        ]) {
      _catalogues[c.localeCode] = c;
    }
    _active = _catalogues.containsKey(initialLocale) ? initialLocale : 'en';
  }

  final Map<String, HabotStringCatalogue> _catalogues =
      <String, HabotStringCatalogue>{};
  final Future<void> Function(String localeCode)? _persist;

  late String _active;

  /// The source language. Always present, always complete, never removable:
  /// an app with no catalogue at all has to show something.
  static const String sourceLocale = 'en';

  String get activeLocale => _active;

  HabotLanguage get activeLanguage =>
      HabotLocalizationObjective.byCode(_active);

  /// Step 138 F-1: direction travels with the language, and this is the one
  /// place the rest of the app reads it from.
  HabotTextDirectionality get direction => activeLanguage.direction;

  bool get isRightToLeft => activeLanguage.isRightToLeft;

  void install(HabotStringCatalogue catalogue) {
    _catalogues[catalogue.localeCode] = catalogue;
    notifyListeners();
  }

  Iterable<String> get installedLocales => _catalogues.keys;

  HabotStringCatalogue? catalogueFor(String code) => _catalogues[code];

  /// Coverage per installed language.
  Map<String, double> get coverageByLocale => <String, double>{
        for (final MapEntry<String, HabotStringCatalogue> e
            in _catalogues.entries)
          e.key: e.value.coverage,
      };

  /// The languages a user may actually choose.
  ///
  /// **Complete or not offered.** See the header: this refuses the metric's
  /// own 0.95 floor deliberately.
  List<String> get offerableLocales => _catalogues.entries
      .where((MapEntry<String, HabotStringCatalogue> e) => e.value.isComplete)
      .map((MapEntry<String, HabotStringCatalogue> e) => e.key)
      .toList();

  /// Languages that have a catalogue but are not offered, with what is
  /// missing. This is the report the translation work is driven from; without
  /// it "not offered" would be indistinguishable from "not started".
  Map<String, List<String>> get withheldLocales => <String, List<String>>{
        for (final MapEntry<String, HabotStringCatalogue> e
            in _catalogues.entries)
          if (!e.value.isComplete) e.key: e.value.missingKeys,
      };

  bool canOffer(String code) => offerableLocales.contains(code);

  /// Switch language. Synchronous in effect: the strings change and listeners
  /// are notified before this returns. Persistence is fire-and-forget,
  /// because waiting for a disk write to change a label is what makes a
  /// setting feel unresponsive -- and because the write can fail without the
  /// user's choice needing to fail with it.
  bool activate(String code) {
    if (!canOffer(code)) {
      return false;
    }
    if (_active == code) {
      return true;
    }
    _active = code;
    notifyListeners();
    _persist?.call(code);
    return true;
  }

  /// Look up a string. Synchronous, from memory -- Step 138 decision D-2.
  ///
  /// A key missing from a COMPLETE catalogue cannot happen; a key missing
  /// from the source catalogue is a programming error and returns the key
  /// itself, which is ugly on screen and therefore gets fixed. It does not
  /// return an empty string: an invisible failure is the one nobody reports.
  String stringOf(String key) {
    final String? s = _catalogues[_active]?.strings[key];
    if (s != null && s.isNotEmpty) {
      return s;
    }
    return _catalogues[sourceLocale]?.strings[key] ?? key;
  }

  /// A string with `{placeholder}` substitution. Positional interpolation is
  /// avoided on purpose: word order changes between languages, and a
  /// translator handed "%s of %s" cannot tell which is which.
  String format(String key, Map<String, String> values) {
    String out = stringOf(key);
    for (final MapEntry<String, String> e in values.entries) {
      out = out.replaceAll('{${e.key}}', e.value);
    }
    return out;
  }

  // ---- the row's metric ---------------------------------------------------

  /// The row's metric, over the languages the objective names.
  ///
  /// Measured against the FULL named scope rather than against what happens
  /// to be installed -- otherwise an app with only English installed would
  /// report 100% localisation coverage, which is the number a team reports
  /// when it has done nothing.
  double get localizationCoverage {
    final List<HabotLanguage> scope = HabotLocalizationObjective.languages;
    if (scope.isEmpty) {
      return 0;
    }
    double total = 0;
    for (final HabotLanguage l in scope) {
      total += _catalogues[l.code]?.coverage ?? 0;
    }
    return total / scope.length;
  }

  /// Languages in the objective's scope with no catalogue at all.
  List<String> get untranslatedLocales => HabotLocalizationObjective.languages
      .where((HabotLanguage l) => !_catalogues.containsKey(l.code))
      .map((HabotLanguage l) => '${l.englishName} (${l.code})')
      .toList();

  static const double floor = 0.95;
  static const double optimal = 1.0;

  String get qualitativeOutput {
    if (localizationCoverage >= optimal) {
      return 'Complete';
    }
    return localizationCoverage > 0 ? 'Partial' : 'Not Complete';
  }

  static const String floorRefusedNote =
      'The row permits 95% coverage. This implementation will not offer a '
      'language below 100%, which is a deliberate deviation upward from the '
      'floor. A 95%-translated screen is not 95% as good as a translated one: '
      'one English sentence in the middle of Welsh reads as a broken app, and '
      'the missing 5% is never spread evenly -- it concentrates in the strings '
      'added last, which are the newest features and the error messages. '
      'Per-string fallback would also hide the gap from the metric meant to '
      'expose it. Recorded at Step 138 as decision D-3, before this was '
      'written.';

  static const String translationBoundaryNote =
      'This step delivers the switching mechanism and the English catalogue. '
      'English is the source language, so those are the strings themselves '
      'rather than translations. The Welsh, Urdu, Punjabi and Polish '
      'catalogues are a content deliverable produced by people who speak '
      'those languages; inventing them in code would put text in front of '
      'users that no speaker had checked -- worse than an untranslated app, '
      'and much harder to notice. What the mechanism guarantees is that a '
      'language cannot be offered until its catalogue is complete, so the gap '
      'appears in withheldLocales rather than on a screen.';

  static const String namedPlaceholderNote =
      'Interpolation is by name ("{current} of {total}"), never positional. '
      'Word order changes between languages, and a translator handed '
      '"%s of %s" cannot tell which number is which -- so positional '
      'placeholders produce translations that are correct in the catalogue '
      'and wrong on the screen.';
}
