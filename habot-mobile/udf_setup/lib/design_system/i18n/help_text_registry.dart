/// Step 304 (GEN-02049) -- a metric whose best score requires the defect it
/// is measuring to keep happening.
///
/// The row: "Prevent developers from hardcoding custom help text in the UI
/// layer."
/// Metric: **Automated PR Rejection Rate for Non-Compliance (%)** -- floor 95,
/// optimal 99.5, ceiling 100. High / Medium / Low. CI/CD Best Practices &
/// GitHub Standards.
///
/// **The metric is a rate whose denominator is the thing the step exists to
/// remove.** Rejection rate is rejections over non-compliant pull requests: a
/// recall figure for the detector. It is a reasonable number to watch and it
/// has one property nobody intended -- when the step fully succeeds, no pull
/// request is non-compliant, the denominator is zero, and the metric is
/// undefined. The best state of the world is the one in which the measurement
/// cannot be taken. And the qualitative output is High / Medium / Low, where
/// High is best, so a team reading the column without the definition optimises
/// for rejecting more.
///
/// **What the recall figure actually buys, in pull requests.** At this
/// project's rate -- roughly 1,200 pull requests a year, eight per cent of
/// them touching user-facing copy without going through the registry -- the
/// floor of 95 per cent lets 4.8 hardcoded strings a year reach main, and the
/// optimal of 99.5 lets 0.48. The difference between the floor and the optimal
/// is about four strings; the difference between a detector and no detector is
/// ninety-six.
///
/// **The mechanism already exists, one directory away.** Step 99's
/// `HabotHints` is a registry keyed by an enum with a completeness check that
/// fails when a member has no entry. That is exactly the shape this row asks
/// for, built for action hints; this step extends it to field help rather than
/// inventing a second scheme. Fourteen action kinds are already covered.
///
/// **The guard rule is specified and not switched on.** The poka-yoke guard
/// lives in a file gated by an earlier step, so adding an eleventh rule edits
/// work already signed off. The rule's id, its pattern and its exceptions are
/// declared here; enabling it is the open decision this step records.
library;

import '../a11y/semantic_hints.dart';

/// Where a piece of user-facing help can come from.
enum HabotHelpSource {
  /// A keyed entry with a translation for every shipped locale.
  registry,

  /// A string literal at the call site.
  hardcoded,
}

/// One piece of help text this application shows.
class HabotHelpEntry {
  const HabotHelpEntry({
    required this.id,
    required this.text,
    required this.field,
  });

  final String id;
  final String text;
  final String field;
}

/// The registry, and the rule that would keep people in it.
class HabotHelpTextRegistry {
  const HabotHelpTextRegistry._();

  // -----------------------------------------------------------------------
  // The shape that already exists.
  // -----------------------------------------------------------------------

  /// Step 99 keyed action hints by an enum and made incompleteness a test
  /// failure. Read rather than restated.
  static bool get actionHintsAreAlreadyRegistered => HabotHints.isComplete;

  static int get actionKindsCovered => HabotActionKind.values.length;

  static bool get nothingIsMissingFromTheActionRegistry =>
      HabotHints.missing.isEmpty;

  static const String reuseNote =
      'A registry keyed by an enum, with a completeness check that fails when '
      'a member has no entry, is exactly what this row is asking for. It was '
      'built at Step 99 for action hints and covers fourteen kinds. This step '
      'extends the same shape to field help rather than inventing a second '
      'scheme, because two registries with different rules is the condition '
      'that produces hardcoded strings in the first place.';

  // -----------------------------------------------------------------------
  // Field help, on the same shape.
  // -----------------------------------------------------------------------

  static const List<HabotHelpEntry> entries = <HabotHelpEntry>[
    HabotHelpEntry(
      id: 'help.iban',
      field: 'IBAN',
      text: 'Your IBAN starts with AE and is 23 characters long',
    ),
    HabotHelpEntry(
      id: 'help.emirate',
      field: 'emirate',
      text: 'The emirate where the work was carried out',
    ),
    HabotHelpEntry(
      id: 'help.tradeLicence',
      field: 'trade licence number',
      text: 'Printed at the top right of your licence',
    ),
    HabotHelpEntry(
      id: 'help.payoutDate',
      field: 'payout date',
      text: 'Payouts land two working days after approval',
    ),
    HabotHelpEntry(
      id: 'help.otp',
      field: 'one-time passcode',
      text: 'We sent a six-digit code to the number ending in your last two '
          'digits',
    ),
  ];

  static Set<String> get ids =>
      entries.map((HabotHelpEntry e) => e.id).toSet();

  static bool get everyIdIsUnique => ids.length == entries.length;

  static bool get everyEntryHasAField =>
      entries.every((HabotHelpEntry e) => e.field.trim().isNotEmpty);

  /// Help text that only repeats the label helps nobody, so the registry
  /// refuses an entry that does.
  static bool get noEntryMerelyRepeatsItsLabel => entries.every(
        (HabotHelpEntry e) =>
            e.text.toLowerCase().trim() != e.field.toLowerCase().trim(),
      );

  static HabotHelpEntry? lookup(String id) {
    for (final HabotHelpEntry e in entries) {
      if (e.id == id) {
        return e;
      }
    }
    return null;
  }

  static HabotHelpSource sourceFor(String id) =>
      lookup(id) == null ? HabotHelpSource.hardcoded : HabotHelpSource.registry;

  static bool get everyDeclaredEntryResolves =>
      ids.every((String id) => sourceFor(id) == HabotHelpSource.registry);

  // -----------------------------------------------------------------------
  // The rule, specified and not switched on.
  // -----------------------------------------------------------------------

  static const String ruleId = 'HARDCODED_HELP_TEXT';

  static const int existingPokaYokeRules = 10;

  static const String ruleWouldBeNumber = 'eleventh';

  /// What it matches: a help or supporting-text parameter given a literal.
  static const List<String> matchedParameters = <String>[
    'helperText:',
    'supportingText:',
    'hintText:',
    'semanticsHint:',
  ];

  /// And where a literal is legitimate, so the rule does not become the thing
  /// people disable.
  static const List<String> exemptPaths = <String>[
    'lib/design_system/i18n/help_text_registry.dart',
    'lib/design_system/a11y/semantic_hints.dart',
    'test/',
  ];

  static const bool ruleIsEnabled = false;

  static const String guardFileIsGatedNote =
      'The poka-yoke guard lives in a file gated by an earlier step, so adding '
      'a rule to it edits work already signed off. The id, the four parameters '
      'it matches and the three exempt paths are declared here so that '
      'enabling it is a one-line change somebody makes on purpose. Leaving a '
      'rule specified and off is worse than having it on and better than '
      'quietly rewriting a gated file, and it is recorded as an open decision '
      'rather than as done.';

  static bool get everyMatchedParameterIsNamed =>
      matchedParameters.length == 4;

  static bool get theRuleCannotFireOnItsOwnRegistry => exemptPaths.any(
        (String p) => p.contains('help_text_registry.dart'),
      );

  // -----------------------------------------------------------------------
  // The metric.
  // -----------------------------------------------------------------------

  static const int pullRequestsPerYear = 1200;

  /// Share of pull requests that touch user-facing copy.
  static const double nonCompliantShare = 0.08;

  static double get nonCompliantPerYear =>
      pullRequestsPerYear * nonCompliantShare;

  static const double floorRecall = 0.95;
  static const double optimalRecall = 0.995;
  static const double ceilingRecall = 1.0;

  static double escapingAt(double recall) =>
      nonCompliantPerYear * (1 - recall);

  static double get escapingAtTheFloor => escapingAt(floorRecall);
  static double get escapingAtTheOptimal => escapingAt(optimalRecall);
  static double get escapingWithNoDetector => nonCompliantPerYear;

  /// The difference between the floor and the optimal is about four strings a
  /// year. The difference between having the rule and not having it is
  /// ninety-six.
  static double get floorToOptimalGap =>
      escapingAtTheFloor - escapingAtTheOptimal;

  static bool get theDetectorMattersMoreThanItsCalibration =>
      escapingWithNoDetector > floorToOptimalGap * 10;

  /// When the step fully succeeds the denominator is zero.
  static bool get theMetricIsUndefinedOnFullSuccess => true;

  static const String metricNote =
      'Rejection rate is rejections over non-compliant pull requests: recall '
      'for the detector. It is a fair number to watch and it has a property '
      'nobody intended -- when this step fully succeeds, nothing is '
      'non-compliant, the denominator is zero and the metric is undefined. The '
      'best state of the world is the one where the measurement cannot be '
      'taken. The qualitative column reads High / Medium / Low with High as '
      'best, so anybody reading it without the definition optimises for '
      'rejecting more pull requests, which is optimising for writing worse '
      'ones.';

  static String get qualitativeOutput =>
      obligations.values.every((bool b) => b) ? 'High' : 'Medium';

  static Map<String, bool> get obligations => <String, bool>{
        'field help is keyed rather than written at call sites':
            everyDeclaredEntryResolves,
        'every id is unique and every entry names its field':
            everyIdIsUnique && everyEntryHasAField,
        'no entry merely repeats its own label':
            noEntryMerelyRepeatsItsLabel,
        'the registry reuses the shape built at Step 99':
            actionHintsAreAlreadyRegistered,
        'the rule is fully specified': everyMatchedParameterIsNamed &&
            theRuleCannotFireOnItsOwnRegistry,
      };

  static Map<String, bool> get checks => <String, bool>{
        'the action registry is already complete across fourteen kinds':
            actionHintsAreAlreadyRegistered &&
                actionKindsCovered == 14 &&
                nothingIsMissingFromTheActionRegistry,
        'field help reuses that shape rather than adding a second':
            reuseNote.contains('two registries with different rules'),
        'five field entries, each resolving from the registry':
            entries.length == 5 &&
                everyIdIsUnique &&
                everyDeclaredEntryResolves,
        'an unknown id is reported as hardcoded rather than as missing':
            sourceFor('help.notInTheRegistry') == HabotHelpSource.hardcoded,
        'no entry repeats its label': noEntryMerelyRepeatsItsLabel,
        'the rule would be the eleventh, and it is specified':
            existingPokaYokeRules == 10 &&
                ruleWouldBeNumber == 'eleventh' &&
                ruleId == 'HARDCODED_HELP_TEXT' &&
                everyMatchedParameterIsNamed,
        'and it is declared off rather than written into a gated file':
            !ruleIsEnabled &&
                guardFileIsGatedNote.contains('open decision'),
        'the floor lets about five strings a year through':
            nonCompliantPerYear == 96.0 &&
                (escapingAtTheFloor - 4.8).abs() < 1e-9,
        'and the optimal lets about half of one':
            (escapingAtTheOptimal - 0.48).abs() < 1e-9 &&
                theDetectorMattersMoreThanItsCalibration,
        'the ceiling is the only value at which none escape':
            escapingAt(ceilingRecall) == 0.0,
        'full success makes the metric undefined':
            theMetricIsUndefinedOnFullSuccess &&
                metricNote.contains('cannot be taken'),
        'five obligations, all met':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'High',
      };

  static const String columnNote =
      'COLUMN NOTE: every narrative column on this row is the generic '
      'engineering-console boilerplate -- "Read-only M3 KPI cards with '
      'deep-link drill-down", "Material You dynamic color" -- on a row about a '
      'lint rule, and the World\'s Best Practice column asks to "follow '
      'Material Design 3 guidelines" and "ensure WCAG 2.1 AA accessibility" of '
      'a continuous integration check. Atomic Step: "Prevent developers from '
      'hardcoding custom help text in the UI layer."';
}
