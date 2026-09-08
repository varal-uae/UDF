/// AISS Step 144 -- GEN-05430
/// Setup Step (Action) / Atomic Step: "Build and configure: configure
///   touch-friendly language toggle controls embedded in top navigation bars."
/// Metric: Localization Coverage & Layout Accuracy -- Floor ">= 95%",
///         Optimal 1.0, Ceiling 1.0. Pass / Fail.
///
/// **THE METRIC NAMES TWO THINGS, AND THE SECOND ONE IS THE POINT.**
/// "Localization Coverage" is Step 143's number. "Layout Accuracy" is this
/// row's own, and it is the half a team reports as done because the strings
/// all exist. They exist and they do not fit: Welsh runs about 30% longer than
/// English and Polish about 25%, while every label in this app was laid out
/// against an English string and the header caps titles at
/// `HabotDensity.maxHeaderTitleChars` characters. A comfortable English title
/// goes over that cap in Welsh, and the header truncates it -- in exactly the
/// language the feature exists to serve. Step 138 recorded this as finding
/// F-2 before the toggle was designed.
///
/// So [HabotLanguageToggle.layoutAccuracy] audits every offered language
/// against the real constraint the header applies, using the expansion
/// factors declared at Step 138 -- and it audits against the WORST case, not
/// an average, because a label either fits in the worst language or the app is
/// broken in that language.
///
/// **IT IS A HEADER ACTION, NOT A NEW CONTROL.** Step 9 built the contextual
/// header with an action model, priority ordering and an overflow sheet;
/// Step 10 set the 48dp touch minimum. The "touch-friendly language toggle
/// control embedded in the top navigation bar" the row asks for is a
/// `HabotHeaderAction` -- so it inherits the touch target, the overflow
/// behaviour and the accessibility work rather than restating them, and it
/// cannot be laid out differently from every other header control.
///
/// **NOT A `PopupMenuButton`, AND THE REASON IS ALREADY IN THIS REPO.**
/// Step 24 (MUFCE-028) banned hover affordances, and Flutter wraps
/// `PopupMenuButton` in a `Tooltip` unconditionally with no API to switch it
/// off -- which is why the header's overflow is a bottom sheet. The language
/// chooser is the same: a sheet, opened by a tap.
///
/// **ENDONYMS, NOT ENGLISH NAMES** (Step 138, F-5). A list that says "Urdu"
/// rather than "اردو" cannot be read by the person looking for Urdu. That
/// makes the endonym the primary label and the English name the secondary
/// one -- the reverse of what an English-speaking team builds by default.
library;

import 'package:flutter/widgets.dart';

import '../navigation/contextual_header.dart';
import '../tokens/spacing_tokens.dart';
import 'language_preference.dart';
import 'localization_objective.dart';

/// One row of the language chooser.
class HabotLanguageOption {
  const HabotLanguageOption({
    required this.language,
    required this.isActive,
    required this.isOfferable,
  });

  final HabotLanguage language;
  final bool isActive;

  /// Step 143: a language below full coverage is not offered at all.
  final bool isOfferable;

  /// What the row shows first. The endonym, because someone who reads Urdu
  /// and not English cannot find "Urdu" in a list.
  String get primaryLabel => language.endonym;

  /// The English name, shown after it, for a support call where the two
  /// people do not share a language.
  String get secondaryLabel => language.englishName;
}

/// One label that has to survive translation.
class HabotTranslatedLabel {
  const HabotTranslatedLabel({
    required this.key,
    required this.english,
    required this.budgetChars,
    required this.where,
  });

  final String key;
  final String english;

  /// How many characters the surface can show before it truncates.
  final int budgetChars;

  final String where;

  /// The length this label is expected to reach in [language]. Rounded up:
  /// half a character over the budget is over the budget.
  int expandedLengthIn(HabotLanguage language) =>
      (english.length * language.expansionFactor).ceil();

  bool fitsIn(HabotLanguage language) =>
      expandedLengthIn(language) <= budgetChars;
}

/// The language toggle.
class HabotLanguageToggle {
  const HabotLanguageToggle._();

  /// The touch target the control must meet. Not restated -- read from the
  /// Step 10 standard, so it cannot drift away from every other control.
  static double get minTouchTarget => HabotDensity.minTouchTarget;

  /// Where it sits among the header's actions. High enough to stay out of
  /// the overflow sheet on a compact screen: a language switch that is itself
  /// only reachable through an English menu is not much of a language switch.
  static const int headerPriority = 1;

  /// The header title cap the row's "Layout Accuracy" is really about.
  static int get headerTitleBudget => HabotDensity.maxHeaderTitleChars;

  /// Labels this batch puts on constrained surfaces, with the budget each
  /// surface actually enforces.
  static List<HabotTranslatedLabel> get auditedLabels =>
      <HabotTranslatedLabel>[
        HabotTranslatedLabel(
          key: 'settings.language',
          english: 'Language',
          budgetChars: headerTitleBudget,
          where: 'Header title on the language settings screen',
        ),
        HabotTranslatedLabel(
          key: 'action.next',
          english: 'Next',
          budgetChars: buttonLabelBudget,
          where: 'Wizard forward button',
        ),
        HabotTranslatedLabel(
          key: 'action.back',
          english: 'Back',
          budgetChars: buttonLabelBudget,
          where: 'Wizard back button',
        ),
        HabotTranslatedLabel(
          key: 'action.done',
          english: 'Done',
          budgetChars: buttonLabelBudget,
          where: 'Wizard final button',
        ),
        HabotTranslatedLabel(
          key: 'status.offline',
          english: 'Offline',
          budgetChars: chipLabelBudget,
          where: 'Step 125 offline status chip (28dp, fixed height)',
        ),
        HabotTranslatedLabel(
          key: 'status.saving',
          english: 'Saving',
          budgetChars: chipLabelBudget,
          where: 'Step 153 autosave indicator',
        ),
        HabotTranslatedLabel(
          key: 'settings.notifications',
          english: 'Notifications',
          budgetChars: headerTitleBudget,
          where: 'Header title on the Step 50 notification preference screen',
        ),
      ];

  /// **Source strings this audit REJECTED, and what replaced them.**
  ///
  /// Without these the layout audit would be unfalsifiable: every shipped
  /// label fits, so a rate computed only over shipped labels is 1.0 whatever
  /// the implementation does. Each entry here is a label that WAS going to
  /// ship and that this audit stopped, and the gate checks that each one
  /// genuinely still overflows -- so the audit is shown to be capable of
  /// failing before its pass is believed.
  static List<HabotRejectedLabel> get rejectedForExpansion =>
      <HabotRejectedLabel>[
        HabotRejectedLabel(
          candidate: HabotTranslatedLabel(
            key: 'settings.notifications',
            english: 'Notification preferences',
            budgetChars: headerTitleBudget,
            where: 'Header title on the Step 50 notification preference '
                'screen',
          ),
          replacedWith: 'Notifications',
          reason: '24 English characters expands past the 28-character header '
              'cap in Welsh (32) and Polish (30). The header would have '
              'ellipsised the title in exactly two of the languages this '
              'feature exists to serve, and the English screen would have '
              'looked fine in review.',
        ),
        HabotRejectedLabel(
          candidate: HabotTranslatedLabel(
            key: 'action.save',
            english: 'Save and continue',
            budgetChars: buttonLabelBudget,
            where: 'Wizard forward button',
          ),
          replacedWith: 'Save',
          reason: 'A 17-character button label is already tight in English at '
              'a 12-character budget and wraps in every offered language. A '
              'wrapped label in a fixed-height button row clips rather than '
              'growing.',
        ),
      ];

  /// A wizard button is laid out for a short verb. Beyond this it wraps, and
  /// a wrapped button in a fixed-height row clips.
  static const int buttonLabelBudget = 12;

  /// The Step 125 chip is 28dp tall and sized to its content; beyond this it
  /// pushes the header actions off the compact layout.
  static const int chipLabelBudget = 14;

  /// Build the header action. It is a [HabotHeaderAction] so that it inherits
  /// the Step 9 ordering and the Step 10 touch target rather than restating
  /// them.
  static HabotHeaderAction actionFor(
    HabotLanguagePreference preference, {
    required IconData icon,
    required VoidCallback onOpenChooser,
  }) =>
      HabotHeaderAction(
        icon: icon,
        // The accessible name is the CURRENT language in its own script, not
        // the word "Language" -- a screen reader user needs to know what it is
        // set to, not what the control is called.
        label: preference.activeLanguage.endonym,
        onPressed: onOpenChooser,
        priority: headerPriority,
      );

  /// The glyph the control must use. Named rather than a flag: a flag is a
  /// country, languages are not countries, and picking one flag per language
  /// tells a large group of users the app was not built for them.
  static const String languageIconName = 'language';

  /// The chooser's rows.
  static List<HabotLanguageOption> optionsFor(
    HabotLanguagePreference preference,
  ) =>
      HabotLocalizationObjective.languages
          .map((HabotLanguage l) => HabotLanguageOption(
                language: l,
                isActive: l.code == preference.activeLocale,
                isOfferable: preference.canOffer(l.code),
              ))
          .toList();

  static const String noFlagsNote =
      'The control uses a language glyph, never a flag. A flag is a country; '
      'languages are not countries. Punjabi is spoken across two states and a '
      'diaspora, Urdu across several countries, and picking one flag per '
      'language tells a large group of users the app was not built for them.';

  // ---- the row's metric ---------------------------------------------------

  /// Every (label, language) pair that would truncate. Empty is the
  /// requirement; the list exists so a failure names the label, the surface
  /// and the language rather than only a percentage.
  static List<String> overflowingLabels(
    Iterable<HabotLanguage> languages,
  ) {
    final List<String> out = <String>[];
    for (final HabotTranslatedLabel l in auditedLabels) {
      for (final HabotLanguage lang in languages) {
        if (!l.fitsIn(lang)) {
          out.add(
            '"${l.english}" (${l.key}) in ${lang.englishName}: '
            '${l.expandedLengthIn(lang)} chars against a budget of '
            '${l.budgetChars} -- ${l.where}',
          );
        }
      }
    }
    return out;
  }

  /// The layout half of the row's metric: the share of (label, language)
  /// pairs that fit.
  static double layoutAccuracy(Iterable<HabotLanguage> languages) {
    final List<HabotLanguage> ls = languages.toList();
    final int pairs = auditedLabels.length * ls.length;
    if (pairs == 0) {
      return 0;
    }
    return (pairs - overflowingLabels(ls).length) / pairs;
  }

  /// Layout accuracy against every language the objective names -- including
  /// the ones not yet translated, because the layout has to hold when they
  /// arrive. Auditing only what is installed today would let a Welsh
  /// truncation ship as a future problem.
  static double get layoutAccuracyAcrossScope =>
      layoutAccuracy(HabotLocalizationObjective.languages);

  /// The row's combined metric.
  ///
  /// The two halves are multiplied rather than averaged. An app whose strings
  /// are 100% translated and whose labels truncate in half of them is not
  /// "75% localised" -- it is broken in those languages, and averaging would
  /// let a perfect score on the easy half carry the hard one.
  static double combined({
    required double coverage,
    required double accuracy,
  }) =>
      coverage * accuracy;

  static const double floor = 0.95;
  static const double optimal = 1.0;

  static const String twoHalvesNote =
      'The row names "Localization Coverage & Layout Accuracy". They are '
      'multiplied, not averaged: an app whose strings are fully translated '
      'and whose labels truncate in half of them is not 75% localised, it is '
      'broken in those languages -- and averaging would let a perfect score on '
      'the easy half carry the hard one.';

  /// Rejected candidates that would in fact still fit. Empty is the
  /// requirement: an entry here means the audit is claiming to have caught
  /// something it would not have caught.
  static List<String> get rejectionsThatWouldNotHaveFailed =>
      rejectedForExpansion
          .where((HabotRejectedLabel r) => HabotLocalizationObjective.languages
              .every((HabotLanguage l) => r.candidate.fitsIn(l)))
          .map((HabotRejectedLabel r) => r.candidate.english)
          .toList();

  static const String auditIsFalsifiableNote =
      'Every shipped label fits, so a rate computed only over shipped labels '
      'would be 1.0 whatever the implementation did. rejectedForExpansion '
      'holds the labels this audit actually stopped, and the gate checks that '
      'each one still overflows in at least one offered language -- so the '
      'audit is shown to be capable of failing before its pass is believed.';

  static const String worstCaseNote =
      'Labels are audited against the WORST expansion among the offered '
      'languages, not an average. A label either fits in the longest language '
      'or the app is broken in that language, and an average would hide '
      'exactly the case that matters.';
}

/// A source string the expansion audit refused, and what shipped instead.
class HabotRejectedLabel {
  const HabotRejectedLabel({
    required this.candidate,
    required this.replacedWith,
    required this.reason,
  });

  final HabotTranslatedLabel candidate;
  final String replacedWith;
  final String reason;

  /// The languages this candidate would have overflowed in.
  List<String> get overflowsIn => HabotLocalizationObjective.languages
      .where((HabotLanguage l) => !candidate.fitsIn(l))
      .map((HabotLanguage l) => l.englishName)
      .toList();
}
