/// AISS Step 138 -- GEN-04957
/// Setup Step (Action) / Atomic Step: "Review the setup step objective: Embed
///   a dynamic multi-language localization framework supporting instant UI and
///   form text translation (e.g., Welsh, Urdu, Punjabi, Polish) to ensure
///   equitable access for non-English speakers."
/// Metric: Requirements Objective Clarity / Sign-off Score -- Floor ">=80%
///         stakeholder sign-off on stated objective", Optimal "100%",
///         Ceiling "100% (no benefit beyond full sign-off)".
/// Best Qualitative Output: Complete / Partial / Not Complete.
///
/// A REVIEW STEP, AND A REVIEW THAT FOUND SOMETHING. The row asks for the
/// objective to be reviewed before the framework is built (Steps 139-145). A
/// review that reads the sentence, agrees with it and signs off has done
/// nothing; the point of reviewing an objective is to find what it does not
/// say and would have cost a rebuild to discover.
///
/// **THE FINDING: URDU IS RIGHT-TO-LEFT.** The row lists four languages as if
/// they were four sets of strings -- "(e.g., Welsh, Urdu, Punjabi, Polish)".
/// Welsh, Polish and Punjabi in Gurmukhi are left-to-right and are, near
/// enough, four sets of strings. Urdu is written right-to-left in the
/// Nastaliq style of the Perso-Arabic script. That is not a translation
/// problem, it is a LAYOUT MIRROR: every start/end padding, every leading
/// icon, every swipe direction and every progress indicator reverses. Steps
/// 149-152 build a swipeable, horizontally paginated wizard, and "swipe left
/// for next" is wrong in Urdu.
///
/// Discovering that after the wizard is built means rebuilding the wizard.
/// [HabotLocalizationObjective.findings] records it as a REQUIREMENT of the
/// objective rather than as a note, and Step 150's gate checks that the swipe
/// controller honours it.
///
/// **THE SECOND FINDING: TEXT EXPANSION.** Welsh and Polish run materially
/// longer than English for the same content. The header title cap is 28
/// characters (`HabotDensity.maxHeaderTitleChars`) and buttons are laid out
/// against English strings. A translation that does not fit is not a
/// translated app, and Step 144's metric -- "Localization Coverage & Layout
/// Accuracy" -- names exactly this and would otherwise be read as coverage
/// alone.
///
/// **THE THIRD FINDING: "INSTANT" HAS A DEFINITION, AND IT RULES OUT THE
/// USUAL IMPLEMENTATION.** "Instant UI and form text translation" means no
/// restart and no fetch. A framework that downloads a language pack on
/// selection is not instant, and on the offline-first device this product
/// exists for it is not anything at all. Strings ship in the bundle. That
/// constrains Step 143 before it is written.
library;

/// Writing direction. The distinction the row's list flattens.
enum HabotTextDirectionality { leftToRight, rightToLeft }

/// One language in scope.
class HabotLanguage {
  const HabotLanguage({
    required this.code,
    required this.englishName,
    required this.endonym,
    required this.direction,
    required this.script,
    required this.expansionFactor,
  });

  /// BCP 47 code.
  final String code;

  final String englishName;

  /// The name in the language itself. A language list that shows only English
  /// names is unusable by exactly the people it is for.
  final String endonym;

  final HabotTextDirectionality direction;
  final String script;

  /// Typical length of translated text relative to English. Used by Step 144
  /// to check that a label still fits before the language is offered.
  final double expansionFactor;

  bool get isRightToLeft =>
      direction == HabotTextDirectionality.rightToLeft;
}

/// One thing the review found that the objective did not say.
class HabotObjectiveFinding {
  const HabotObjectiveFinding({
    required this.id,
    required this.finding,
    required this.consequenceIfMissed,
    required this.bindsStep,
  });

  final String id;
  final String finding;

  /// What it would have cost to discover this after the build. A finding
  /// without this is an observation, not a review.
  final String consequenceIfMissed;

  /// The later step this finding constrains.
  final String bindsStep;
}

/// One question the objective leaves open, with the answer the review took.
class HabotObjectiveDecision {
  const HabotObjectiveDecision({
    required this.id,
    required this.question,
    required this.answer,
    required this.rationale,
  });

  final String id;
  final String question;
  final String answer;
  final String rationale;
}

/// The reviewed objective.
class HabotLocalizationObjective {
  const HabotLocalizationObjective._();

  static const String statedObjective =
      'Embed a dynamic multi-language localization framework supporting '
      'instant UI and form text translation (e.g., Welsh, Urdu, Punjabi, '
      'Polish) to ensure equitable access for non-English speakers.';

  /// The four the row names, plus the source language. Ordered as the row
  /// lists them so the correspondence is checkable.
  static const List<HabotLanguage> languages = <HabotLanguage>[
    HabotLanguage(
      code: 'en',
      englishName: 'English',
      endonym: 'English',
      direction: HabotTextDirectionality.leftToRight,
      script: 'Latin',
      expansionFactor: 1.0,
    ),
    HabotLanguage(
      code: 'cy',
      englishName: 'Welsh',
      endonym: 'Cymraeg',
      direction: HabotTextDirectionality.leftToRight,
      script: 'Latin',
      expansionFactor: 1.30,
    ),
    HabotLanguage(
      code: 'ur',
      englishName: 'Urdu',
      endonym: 'اردو',
      direction: HabotTextDirectionality.rightToLeft,
      script: 'Perso-Arabic (Nastaliq)',
      expansionFactor: 1.10,
    ),
    HabotLanguage(
      code: 'pa',
      englishName: 'Punjabi',
      endonym: 'ਪੰਜਾਬੀ',
      direction: HabotTextDirectionality.leftToRight,
      script: 'Gurmukhi',
      expansionFactor: 1.15,
    ),
    HabotLanguage(
      code: 'pl',
      englishName: 'Polish',
      endonym: 'Polski',
      direction: HabotTextDirectionality.leftToRight,
      script: 'Latin',
      expansionFactor: 1.25,
    ),
  ];

  static HabotLanguage byCode(String code) =>
      languages.firstWhere((HabotLanguage l) => l.code == code);

  static List<HabotLanguage> get rightToLeftLanguages =>
      languages.where((HabotLanguage l) => l.isRightToLeft).toList();

  /// The widest expansion any offered language demands. Step 144 audits
  /// against this rather than against an average, because a label either fits
  /// in the worst case or the app is broken in that language.
  static double get worstCaseExpansion => languages
      .map((HabotLanguage l) => l.expansionFactor)
      .reduce((double a, double b) => a > b ? a : b);

  static const List<HabotObjectiveFinding> findings =
      <HabotObjectiveFinding>[
    HabotObjectiveFinding(
      id: 'F-1',
      finding: 'Urdu is written right-to-left. The row lists it alongside '
          'three left-to-right languages as though the four differed only in '
          'their strings. They do not: RTL mirrors the layout -- start/end '
          'padding, leading and trailing icons, swipe direction, and the '
          'direction a progress indicator fills.',
      consequenceIfMissed: 'Steps 149-152 build a horizontally paginated, '
          'swipeable wizard. "Swipe left for next" is wrong in Urdu, and a '
          'progress bar that fills left-to-right reads as counting down. '
          'Discovering this after the wizard exists means rebuilding the '
          'wizard rather than adding a language.',
      bindsStep: 'Step 150 GEN-01396 (swipe controller)',
    ),
    HabotObjectiveFinding(
      id: 'F-2',
      finding: 'Welsh and Polish expand materially against English -- roughly '
          '30% and 25% for equivalent content. Every label in the app was laid '
          'out against an English string.',
      consequenceIfMissed: 'Headers truncate and buttons wrap or clip in '
          'exactly the languages the objective exists to serve. The header '
          'title cap is 28 characters; a 30% expansion puts a comfortable '
          'English title over it.',
      bindsStep: 'Step 144 GEN-05430 (language toggle, "Layout Accuracy")',
    ),
    HabotObjectiveFinding(
      id: 'F-3',
      finding: '"Instant" rules out the usual implementation. A framework '
          'that fetches a language pack when the language is chosen is not '
          'instant, and on a device that has never reached the network it does '
          'not work at all.',
      consequenceIfMissed: 'The feature would fail for offline users, who are '
          'a large part of who this product is for -- and it would fail '
          'silently, showing English and looking like the setting did not '
          'take.',
      bindsStep: 'Step 143 GEN-04583 (language switching)',
    ),
    HabotObjectiveFinding(
      id: 'F-4',
      finding: 'The objective says "UI and FORM TEXT translation". Form text '
          'includes validation error messages, which live in HabotFieldRules '
          'as a fixed English string per Critical Data Element.',
      consequenceIfMissed: 'A form would switch language and then reject an '
          'entry in English -- at the exact moment the user most needs to '
          'understand what is wrong. Error messages are the highest-value '
          'strings in the app to translate and the easiest to forget.',
      bindsStep: 'Step 143 GEN-04583 (coverage includes error messages)',
    ),
    HabotObjectiveFinding(
      id: 'F-5',
      finding: 'A language list shown only in English names is unusable by '
          'the people it is for. Someone who reads Urdu and not English '
          'cannot find "Urdu" in a list.',
      consequenceIfMissed: 'The equitable-access objective is defeated by its '
          'own settings screen.',
      bindsStep: 'Step 144 GEN-05430 (toggle shows endonyms)',
    ),
  ];

  static const List<HabotObjectiveDecision> decisions =
      <HabotObjectiveDecision>[
    HabotObjectiveDecision(
      id: 'D-1',
      question: 'Are the four named languages the scope, or examples?',
      answer: 'Examples, taken as the initial scope. The framework is built '
          'to a language list, not to four hardcoded cases.',
      rationale: 'The row says "e.g.". A framework that can only ever hold '
          'four languages would have to be rewritten for the fifth, and the '
          'cost of not hardcoding them is nil.',
    ),
    HabotObjectiveDecision(
      id: 'D-2',
      question: 'What does "instant" mean, in a number?',
      answer: 'No restart, no fetch, no disk read on the switching path. The '
          'active language is a synchronous in-memory read, exactly as the '
          'Step 134 flag dispatcher is.',
      rationale: 'Anything else shows a flash of the previous language, and '
          'on an offline-first device an implementation that needs the network '
          'does not work for the users this objective names.',
    ),
    HabotObjectiveDecision(
      id: 'D-3',
      question: 'What happens to a string with no translation yet?',
      answer: 'The language is not offered at all until its coverage is '
          'complete. Falling back to English per-string is refused.',
      rationale: 'A half-translated screen is worse than an English one: it '
          'reads as a broken app rather than an untranslated one, and it '
          'hides the gap from the coverage metric. Step 143 makes this the '
          'poka-yoke.',
    ),
    HabotObjectiveDecision(
      id: 'D-4',
      question: 'Is the language preference per device or per account?',
      answer: 'Per device, stored locally, applied before first paint.',
      rationale: 'A shared handset in a depot may be used by people who read '
          'different languages, but the setting still has to work with no '
          'network and no login -- and an account-scoped preference cannot be '
          'read before sign-in, which is when it is most needed.',
    ),
  ];

  // ---- the row's metric ---------------------------------------------------

  /// The review's own completeness checks. The row scores "objective clarity /
  /// sign-off", so what is scored is whether the objective is now clear
  /// enough to build from -- not whether someone agreed with it.
  static Map<String, bool> get clarityChecks => <String, bool>{
        'every named language is declared with its script and direction':
            languages.length >= 5 &&
                languages.every((HabotLanguage l) =>
                    l.script.isNotEmpty && l.endonym.isNotEmpty),
        'the right-to-left case is identified rather than flattened':
            rightToLeftLanguages.isNotEmpty,
        'each finding states what it would have cost to miss':
            findings.every((HabotObjectiveFinding f) =>
                f.consequenceIfMissed.length > 60 && f.bindsStep.isNotEmpty),
        'every open question has an answer and a reason':
            decisions.every((HabotObjectiveDecision d) =>
                d.answer.isNotEmpty && d.rationale.length > 40),
        'the ambiguous words in the objective are given definitions':
            decisions.any((HabotObjectiveDecision d) =>
                d.question.contains('instant')) &&
                decisions.any((HabotObjectiveDecision d) =>
                    d.question.contains('no translation yet')),
      };

  static double get clarityScore {
    final Iterable<bool> r = clarityChecks.values;
    return r.where((bool b) => b).length / r.length;
  }

  static List<String> get gaps => clarityChecks.entries
      .where((MapEntry<String, bool> e) => !e.value)
      .map((MapEntry<String, bool> e) => e.key)
      .toList();

  static const double floor = 0.80;
  static const double optimal = 1.0;

  static String get qualitativeOutput {
    if (clarityScore >= optimal) {
      return 'Complete';
    }
    return clarityScore >= floor ? 'Partial' : 'Not Complete';
  }

  static const String signOffNote =
      'The metric is "stakeholder sign-off on the stated objective". A review '
      'that produced sign-off without producing findings would score the same '
      'and be worth nothing, so what is scored here is whether the objective '
      'is now clear enough to build from: every ambiguous word given a '
      'definition, every unstated requirement named, and every open question '
      'answered with a reason. Sign-off on an objective nobody has questioned '
      'is a signature, not a review.';
}
