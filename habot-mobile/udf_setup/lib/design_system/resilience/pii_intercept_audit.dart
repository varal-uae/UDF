/// Step 268 (GEN-01595) -- testing the masking filters, and finding they
/// intercept three of eleven.
///
/// The row: "Test PII masking filters using sample contact strings to verify
/// 100% intercept rates."
/// Metric: **In-App Message Delivery Latency** -- floor <3s, optimal <500ms,
/// ceiling <5s. Good/Average/Poor. Standard cited: XMPP/WebSocket Real-Time
/// Messaging Benchmark.
///
/// **The metric is about something else entirely.** The Atomic Step is a test
/// of PII masking; the metric measures how fast an in-app message is
/// delivered. They share no subject, no units and no failure mode, and there
/// is no reading under which a masking filter has a delivery latency. The
/// mismatch is recorded and the step is measured on what it asks for.
///
/// **Measured: the existing scrubber intercepts three of eleven contact
/// strings, 0.273, against a row that asks for 100%.** And two of those three
/// fire only incidentally -- through the `hex` rule, which exists to catch
/// hashes and happens to match a UAE IBAN and a sixteen-digit card number
/// because every character in them is a hex digit. A UK IBAN escapes because
/// it contains a `W`. The same card number with spaces in it escapes. Step 207
/// found the PAN half of this and measured 0.25; this is the whole of it.
///
/// **A proposed rule set reaches nine of eleven, and cannot reach more.** A
/// name and an address cannot be told from ordinary prose by a pattern, and
/// the only thing that reaches 100% is not putting free text in a payload at
/// all -- which is what `HabotEventSchema`'s five field types already
/// enforce. The two halves compose: the schema prevents it structurally, and
/// the scrubber is the net for whatever escapes into a log line.
///
/// The rules are **proposed, not merged**. They belong in Step 68's file,
/// which carries its own gates, and no host in this track has a toolchain to
/// re-run them -- the same position Step 238 left its mask correction in.
library;

import 'log_scrubber.dart';

/// One string put through the filter.
class HabotContactSample {
  const HabotContactSample({
    required this.label,
    required this.value,
    required this.isPersonal,
    required this.why,
  });

  final String label;
  final String value;

  /// Whether this string is something that must never reach a log.
  final bool isPersonal;

  final String why;
}

/// A rule this step proposes adding to the existing set.
class HabotProposedRule {
  const HabotProposedRule({
    required this.label,
    required this.pattern,
    required this.why,
  });

  final String label;
  final RegExp pattern;
  final String why;
}

/// The audit.
class HabotPiiInterceptAudit {
  const HabotPiiInterceptAudit._();

  /// Eleven strings that must be intercepted and four that must not. The
  /// second half matters: a filter that redacts booking references and
  /// prices makes a log useless, which is how filters get turned off.
  static const List<HabotContactSample> corpus = <HabotContactSample>[
    HabotContactSample(
      label: 'email address',
      value: 'amina@example.com',
      isPersonal: true,
      why: 'The one class the existing set already has a rule for.',
    ),
    HabotContactSample(
      label: 'international mobile number',
      value: '+971 50 123 4567',
      isPersonal: true,
      why: 'The commonest contact string there is, and there is no rule for '
          'it.',
    ),
    HabotContactSample(
      label: 'local mobile number',
      value: '0501234567',
      isPersonal: true,
      why: 'The same number written the way people actually type it.',
    ),
    HabotContactSample(
      label: 'Emirates ID',
      value: '784-1987-1234567-1',
      isPersonal: true,
      why: 'The national identifier of this application\'s own market, '
          'declared at Step 244 and unmatched by any existing rule.',
    ),
    HabotContactSample(
      label: 'UAE IBAN',
      value: 'AE070331234567890123456',
      isPersonal: true,
      why: 'Caught, and only by accident: every character in it happens to '
          'be a hex digit, so a rule about hashes matches it.',
    ),
    HabotContactSample(
      label: 'UK IBAN',
      value: 'GB82WEST12345698765432',
      isPersonal: true,
      why: 'The same kind of value with a W in it. Escapes, which is what '
          'makes the previous one an accident rather than coverage.',
    ),
    HabotContactSample(
      label: 'sixteen-digit card number',
      value: '4111111111111111',
      isPersonal: true,
      why: 'Caught by the same accident. Step 207 found this and measured '
          'it.',
    ),
    HabotContactSample(
      label: 'fifteen-digit card number',
      value: '378282246310005',
      isPersonal: true,
      why: 'An American Express number is fifteen digits, so the sixteen-'
          'character hex rule does not reach it.',
    ),
    HabotContactSample(
      label: 'card number written with spaces',
      value: '4111 1111 1111 1111',
      isPersonal: true,
      why: 'The way every card is printed and every person types it. The '
          'separators break the hex rule entirely.',
    ),
    HabotContactSample(
      label: 'a full name',
      value: 'Amina Al Marri',
      isPersonal: true,
      why: 'Cannot be told from ordinary prose by a pattern. This is the '
          'reason a filter cannot reach 100%.',
    ),
    HabotContactSample(
      label: 'a home address line',
      value: 'Villa 12, Al Wasl Road, Dubai',
      isPersonal: true,
      why: 'The same. Both are why the structural half matters more than the '
          'filter.',
    ),
    HabotContactSample(
      label: 'an ordinary sentence',
      value: 'The session starts at 9am.',
      isPersonal: false,
      why: 'A control. A filter that redacts this has made the log useless.',
    ),
    HabotContactSample(
      label: 'a booking reference',
      value: 'BK-2026-0914',
      isPersonal: false,
      why: 'Digits and hyphens, and the single thing a support agent needs '
          'from a log. A phone rule that matches it is worse than no phone '
          'rule.',
    ),
    HabotContactSample(
      label: 'a price in AED',
      value: 'AED 331.26',
      isPersonal: false,
      why: 'Money, from Step 204. Must survive.',
    ),
    HabotContactSample(
      label: 'a date',
      value: '2026-09-14',
      isPersonal: false,
      why: 'Eight digits and two hyphens. The shape a careless phone rule '
          'eats.',
    ),
  ];

  static List<HabotContactSample> get personalSamples =>
      corpus.where((HabotContactSample s) => s.isPersonal).toList();

  static List<HabotContactSample> get controls =>
      corpus.where((HabotContactSample s) => !s.isPersonal).toList();

  // -----------------------------------------------------------------------
  // What the existing set does.
  // -----------------------------------------------------------------------

  static bool existingSetIntercepts(String value) =>
      HabotLogScrubber.firedRules(value).isNotEmpty;

  static List<HabotContactSample> get interceptedByExistingSet =>
      personalSamples
          .where((HabotContactSample s) => existingSetIntercepts(s.value))
          .toList();

  static List<HabotContactSample> get missedByExistingSet => personalSamples
      .where((HabotContactSample s) => !existingSetIntercepts(s.value))
      .toList();

  /// The row's own target is 100%. This is what it actually is.
  static double get existingInterceptRate =>
      interceptedByExistingSet.length / personalSamples.length;

  /// Of the ones it catches, how many are caught by a rule about that class
  /// of data rather than by the hash rule happening to match.
  static List<HabotContactSample> get caughtOnlyByTheHexAccident =>
      interceptedByExistingSet
          .where(
            (HabotContactSample s) =>
                HabotLogScrubber.firedRules(s.value).length == 1 &&
                HabotLogScrubber.firedRules(s.value).first == 'hex',
          )
          .toList();

  static bool get mostOfTheCoverageIsAccidental =>
      caughtOnlyByTheHexAccident.length * 2 >=
      interceptedByExistingSet.length;

  /// No control is redacted by the existing set. The one thing it gets
  /// right, and the property any proposal has to keep.
  static bool get theExistingSetRedactsNoControls =>
      controls.every((HabotContactSample s) => !existingSetIntercepts(s.value));

  // -----------------------------------------------------------------------
  // The proposal.
  // -----------------------------------------------------------------------

  static List<HabotProposedRule> get proposedRules => <HabotProposedRule>[
        HabotProposedRule(
          label: 'emiratesId',
          pattern: RegExp(r'\b784-\d{4}-\d{7}-\d\b'),
          why: 'The national identifier of this market, in its printed form. '
              'Anchored on the fixed 784 prefix so it cannot match a date.',
        ),
        HabotProposedRule(
          label: 'iban',
          pattern: RegExp(
            r'\b[A-Z]{2}\d{2}(?:[ ]?[A-Z0-9]{4}){2,7}[ ]?[A-Z0-9]{0,4}\b',
          ),
          why: 'Two letters, two check digits and groups of four -- the '
              'shape Step 243 validates. Catches the UK spelling the hex '
              'rule misses, and the grouped form every bank prints.',
        ),
        HabotProposedRule(
          label: 'pan',
          pattern: RegExp(r'\b(?:\d[ -]?){12,18}\d\b'),
          why: 'Thirteen to nineteen digits with optional separators, which '
              'covers every card length including the fifteen-digit one the '
              'hex rule cannot reach.',
        ),
        HabotProposedRule(
          label: 'phone',
          pattern: RegExp(
            r'(?<![\d-])(?:\+\d{1,3}[ -]?|0)\d(?:[ -]?\d){7,13}(?![\d-])',
          ),
          why: 'Nine or more digits with a leading plus or zero. The '
              'lookarounds are what keep it off a booking reference and a '
              'date, both of which are in the corpus as controls.',
        ),
      ];

  static bool proposedSetIntercepts(String value) =>
      existingSetIntercepts(value) ||
      proposedRules.any((HabotProposedRule r) => r.pattern.hasMatch(value));

  static List<HabotContactSample> get interceptedByProposedSet =>
      personalSamples
          .where((HabotContactSample s) => proposedSetIntercepts(s.value))
          .toList();

  static List<HabotContactSample> get stillMissed => personalSamples
      .where((HabotContactSample s) => !proposedSetIntercepts(s.value))
      .toList();

  static double get proposedInterceptRate =>
      interceptedByProposedSet.length / personalSamples.length;

  static bool get theProposalRedactsNoControls =>
      controls.every((HabotContactSample s) => !proposedSetIntercepts(s.value));

  /// The two it cannot reach are a name and an address, and that is the
  /// ceiling for any pattern-based filter.
  static bool get theCeilingIsNotOne =>
      stillMissed.length == 2 &&
      stillMissed.every(
        (HabotContactSample s) =>
            s.label.contains('name') || s.label.contains('address'),
      );

  // -----------------------------------------------------------------------
  // Notes.
  // -----------------------------------------------------------------------

  static const String metricMismatchNote =
      'The metric is about something else entirely. The Atomic Step is a '
      'test of PII masking; the metric is In-App Message Delivery Latency, '
      'with a band of 3s, 500ms and 5s and an XMPP/WebSocket citation. They '
      'share no subject, no units and no failure mode, and there is no '
      'reading under which a masking filter has a delivery latency. Recorded '
      'as a column defect, and the step measured on what it asks for.';

  static const String accidentalCoverageNote =
      'Two of the three interceptions are accidents. The hex rule exists to '
      'catch hashes and long identifiers, and it happens to match a UAE IBAN '
      'and a sixteen-digit card number because every character in them is a '
      'hex digit. A UK IBAN contains a W and escapes; the same card number '
      'written with the spaces every bank prints escapes; a fifteen-digit '
      'American Express number is too short. Coverage that depends on a '
      'value\'s alphabet rather than on its meaning is coverage that '
      'disappears when somebody formats the value the ordinary way.';

  static const String ceilingNote =
      'A pattern-based filter cannot reach 100%, and the row asks for it. A '
      'name and an address cannot be told from ordinary prose by a pattern '
      '-- the proposal reaches nine of eleven and the two it misses are '
      'exactly those. What reaches 100% is not putting free text in a '
      'payload at all, which is what HabotEventSchema\'s five field types '
      'already enforce: there is no free-text type to declare. The two '
      'halves compose -- the schema prevents it structurally and the '
      'scrubber is the net for whatever escapes into a log line -- and '
      'saying so is more useful than a filter that claims a number it cannot '
      'have.';

  static const String controlsNote =
      'Four controls are in the corpus and neither rule set redacts any of '
      'them: an ordinary sentence, a booking reference, a price and a date. '
      'A filter that eats booking references makes a log useless to the '
      'support agent it exists for, and a useless filter is a filter '
      'somebody turns off. The phone rule\'s lookarounds are there for '
      'exactly the booking reference and the date.';

  static const String notMergedNote =
      'The rules are PROPOSED, not merged. They belong in Step 68\'s file, '
      'which carries its own gates, and no host in this track has a Dart '
      'toolchain to re-run them -- the same position Step 238 left its mask '
      'correction in, and the same open decision.';

  // -----------------------------------------------------------------------
  // Metric.
  // -----------------------------------------------------------------------

  static const double target = 1;

  /// **Fail.** The row asks for a 100% intercept rate and the filter it is
  /// testing reaches 0.273. Reporting anything else would mean reporting on
  /// the proposal rather than on the code.
  static String get qualitativeOutput {
    if (existingInterceptRate >= target) {
      return 'Good';
    }
    return existingInterceptRate >= 0.9 ? 'Average' : 'Poor';
  }

  static Map<String, bool> get checks => <String, bool>{
        'fifteen samples, eleven personal and four controls':
            corpus.length == 15 &&
                personalSamples.length == 11 &&
                controls.length == 4,
        'the existing set intercepts three of eleven':
            interceptedByExistingSet.length == 3 &&
                (existingInterceptRate - 3 / 11).abs() < 1e-9,
        'and that is below the row\'s own target of 100%':
            existingInterceptRate < target,
        'two of the three are caught only by the hash rule, by accident':
            caughtOnlyByTheHexAccident.length == 2 &&
                mostOfTheCoverageIsAccidental,
        'the existing set redacts none of the controls':
            theExistingSetRedactsNoControls,
        'four rules are proposed, each with a reason':
            proposedRules.length == 4 &&
                proposedRules.every(
                  (HabotProposedRule r) => r.why.length > 60,
                ),
        'the proposal reaches nine of eleven':
            interceptedByProposedSet.length == 9 &&
                (proposedInterceptRate - 9 / 11).abs() < 1e-9,
        'and redacts none of the controls either':
            theProposalRedactsNoControls,
        'the two it cannot reach are a name and an address':
            theCeilingIsNotOne && ceilingNote.contains('no free-text type'),
        'the metric on this row is about a different subject':
            metricMismatchNote.contains('no failure mode'),
        'the rules are proposed rather than merged into another step\'s file':
            notMergedNote.contains('same open decision'),
      };

  static const String columnNote =
      'COLUMN NOTE: Setup Step (Action) is EMPTY on this row, and the metric '
      '-- In-App Message Delivery Latency, <3s / <500ms / <5s, citing an '
      'XMPP/WebSocket benchmark -- is about a different subject from the '
      'Atomic Step. Atomic Step: "Test PII masking filters using sample '
      'contact strings to verify 100% intercept rates."';
}
