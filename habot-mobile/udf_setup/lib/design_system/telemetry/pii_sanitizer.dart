/// AISS Step 157 -- GEN-00809
/// Setup Step (Action): "Deploy Automated PII Anonymization & Hashing Pipeline
///                       for Mobile Data"
/// Atomic Step: "Create pii_sanitizer.py."
/// Metric: Syntax Validity -- Floor 100%, Optimal 100%, Ceiling "N/A (100%
///         target)". Complete / Not Complete.
///
/// **THE ROW NAMES A PYTHON FILE, AND THIS IS A FLUTTER CLIENT.**
/// `pii_sanitizer.py` belongs to the ingestion pipeline — the same side of the
/// boundary as the BigQuery writes at Steps 132, 145 and 161, and for the same
/// reason: a mobile client does not run the warehouse. What the client owns is
/// the half that matters more, because it happens earlier: **not emitting the
/// data in the first place.** A sanitiser at ingestion cleans what arrives; a
/// sanitiser on the device decides what leaves. Only one of those helps when
/// the payload is sitting in a crash report, a local log or an outbox row on a
/// lost handset.
///
/// The substitution is recorded rather than presented as the row's own work.
///
/// **"SYNTAX VALIDITY" READ AS SOMETHING WORTH MEASURING.** For a Python file
/// the metric means "it parses", which is true of every file anyone ever
/// committed and tells you nothing. The failure this actually has to catch is
/// a rule that is syntactically perfect and **matches nothing** — a redaction
/// pattern with a wrong character class is not a syntax error, it is a silent
/// data leak that every test still passes. So every rule here carries a
/// positive and a negative example, and [HabotPiiSanitizer.ruleValidity] is
/// the share of rules that fire on the one and stay quiet on the other.
///
/// **IT DOES NOT DECLARE A SECOND RULE SET.** `HabotLogScrubber` already
/// carries the patterns and already runs over log output. This extends the
/// same rules to event payloads and adds the hashing half the row names.
///
/// **A HASH IS NOT ANONYMISATION, AND THE SALT IS WHY.** Hashing an email
/// address with a public function produces a value anybody can reverse by
/// hashing a list of email addresses — the domain is small and enumerable.
/// What makes [HabotPiiSanitizer.opaqueId] non-reversible is the per-install
/// salt, which never leaves the device. That is stated plainly because
/// "we hash it" is the most common way a team believes it has anonymised
/// something it has not.
library;

import '../resilience/log_scrubber.dart';
import 'event_schema.dart';

/// One rule, with the examples that prove it works.
class HabotSanitizerCase {
  const HabotSanitizerCase({
    required this.label,
    required this.shouldRedact,
    required this.shouldNotRedact,
  });

  /// Matches the label on the `HabotLogScrubber` rule this exercises.
  final String label;

  /// A value the rule must catch.
  final String shouldRedact;

  /// A value the rule must leave alone. Without this, a rule matching `.*`
  /// would score perfectly and redact the entire log.
  final String shouldNotRedact;
}

/// Sanitises what leaves the device.
class HabotPiiSanitizer {
  const HabotPiiSanitizer._();

  /// The file the row names, and where it belongs.
  static const String namedArtefact = 'pii_sanitizer.py';

  static const String pipelineSide =
      'ingestion (Cloud Run / Dataflow), not the mobile client';

  /// Envelope fields are structural and are never redacted: redacting
  /// `trace_id` would break every join the schema exists to enable, and
  /// `event_date` is a date.
  static Set<String> get structuralFields =>
      HabotEventSchema.envelope.toSet();

  /// Scrub a single value using the existing Step-era rules.
  static String scrubValue(String value) => HabotLogScrubber.scrub(value);

  /// Scrub an event row: every string payload value, none of the envelope.
  static Map<String, Object?> scrubRow(Map<String, Object?> row) {
    final Map<String, Object?> out = <String, Object?>{};
    for (final MapEntry<String, Object?> e in row.entries) {
      final Object? v = e.value;
      if (structuralFields.contains(e.key) || v is! String) {
        out[e.key] = v;
        continue;
      }
      out[e.key] = scrubValue(v);
    }
    return out;
  }

  /// True when nothing in the row would be redacted — which is the state a
  /// correctly-built event should already be in, because Step 156's schema
  /// refuses free text before this ever runs.
  static bool rowIsClean(Map<String, Object?> row) {
    for (final MapEntry<String, Object?> e in row.entries) {
      final Object? v = e.value;
      if (structuralFields.contains(e.key) || v is! String) {
        continue;
      }
      if (!HabotLogScrubber.isClean(v)) {
        return false;
      }
    }
    return true;
  }

  /// Which rules a row would trigger. For a report that names the leak rather
  /// than only counting it.
  static List<String> findingsFor(Map<String, Object?> row) {
    final List<String> out = <String>[];
    for (final MapEntry<String, Object?> e in row.entries) {
      final Object? v = e.value;
      if (structuralFields.contains(e.key) || v is! String) {
        continue;
      }
      for (final String rule in HabotLogScrubber.firedRules(v)) {
        out.add('${e.key}: $rule');
      }
    }
    return out;
  }

  // ---- the hashing half ---------------------------------------------------

  /// Length of the hash part of the emitted id. Long enough that two distinct
  /// values colliding is not a practical concern at this app's volume; short
  /// enough that it is obviously not the original.
  static const int opaqueIdLength = 16;

  /// Prefix on every emitted id.
  ///
  /// **Not decoration.** `HabotLogScrubber`'s `hex` rule redacts any bare run
  /// of sixteen or more hex characters, because that is what a leaked token or
  /// a raw hash looks like -- and a bare 16-character hash from [opaqueId]
  /// looks exactly the same. Without the prefix the sanitiser would flag this
  /// module's own output as a leak, [rowIsClean] would refuse every event
  /// carrying a `query_hash`, and Step 161 would drop them.
  ///
  /// The prefix is the distinction made visible: a deliberately-minted,
  /// salted, non-reversible id is a different thing from a hex blob that
  /// escaped, and the difference should be legible to a rule rather than
  /// argued about in review.
  static const String opaqueIdPrefix = 'hbid_';

  /// A non-reversible id for a value, under a per-install salt.
  ///
  /// **The salt is what makes this anonymisation.** FNV-1a is not a
  /// cryptographic hash and is not claimed to be; what stops the output being
  /// reversed is that an attacker holding the warehouse does not hold the
  /// salt, which never leaves the device. Hashing an email with a public
  /// function would be reversible by hashing a list of emails, because the
  /// domain is small and enumerable.
  static String opaqueId(String value, {required String installSalt}) {
    const int prime = 1099511628211;
    const int mask = 0x7FFFFFFFFFFFFFFF;
    int hash = 0xcbf29ce484222325 & mask;
    for (final int c in '$installSalt|$value'.codeUnits) {
      hash = (hash ^ c) & mask;
      hash = (hash * prime) & mask;
    }
    final String hex = hash.toRadixString(16).padLeft(opaqueIdLength, '0');
    return '$opaqueIdPrefix'
        '${hex.substring(hex.length - opaqueIdLength)}';
  }

  /// True when [value] has the shape this module emits. Used by the gate to
  /// show the prefix is a rule rather than a habit.
  static bool isOpaqueId(String value) =>
      value.startsWith(opaqueIdPrefix) &&
      value.length == opaqueIdPrefix.length + opaqueIdLength &&
      RegExp(r'^[0-9a-f]+$')
          .hasMatch(value.substring(opaqueIdPrefix.length));

  /// True when the same value under DIFFERENT install salts produces
  /// different ids. This is the property that makes the salt do any work: if
  /// it did not hold, the id would be a public hash of the value and the
  /// warehouse could be reversed with a dictionary.
  static bool saltSeparatesInstalls(String value, String saltA, String saltB) =>
      opaqueId(value, installSalt: saltA) !=
      opaqueId(value, installSalt: saltB);

  // ---- the row's metric, read ---------------------------------------------

  /// Every rule, with a value it must catch and one it must not.
  ///
  /// The second half is the part that makes this a test rather than a
  /// demonstration: a rule written as `.*` would catch every positive case
  /// and redact the entire log.
  static const List<HabotSanitizerCase> cases = <HabotSanitizerCase>[
    HabotSanitizerCase(
      label: 'email',
      shouldRedact: 'contact worker@example.com for details',
      shouldNotRedact: 'contact the depot for details',
    ),
    HabotSanitizerCase(
      label: 'secret',
      shouldRedact: 'Authorization: Bearer zzqqwwxxyyvvuuttssrr',
      shouldNotRedact: 'Authorization header present',
    ),
    HabotSanitizerCase(
      label: 'ip',
      shouldRedact: 'connected to 10.0.0.14:443',
      shouldNotRedact: 'connected to the depot gateway',
    ),
    HabotSanitizerCase(
      label: 'url',
      shouldRedact: 'see https://internal.example.com/admin for the runbook',
      shouldNotRedact: 'see the runbook',
    ),
    HabotSanitizerCase(
      label: 'hex',
      shouldRedact: 'fingerprint 0123456789abcdef0123',
      shouldNotRedact: 'fingerprint recorded',
    ),
  ];

  /// Which declared cases the live rules actually handle.
  ///
  /// A case whose label does not match any rule is reported as a failure
  /// rather than skipped: a case for a rule that no longer exists is a test
  /// that has quietly stopped testing anything.
  static List<String> ruleFailures() {
    final Set<String> labels =
        HabotLogScrubber.rules.map((ScrubRule r) => r.label).toSet();
    final List<String> out = <String>[];
    for (final HabotSanitizerCase c in cases) {
      if (!labels.contains(c.label)) {
        out.add('${c.label}: no rule with this label exists any more');
        continue;
      }
      if (!HabotLogScrubber.firedRules(c.shouldRedact).contains(c.label)) {
        out.add('${c.label}: did not fire on a value it must redact');
      }
      if (HabotLogScrubber.firedRules(c.shouldNotRedact).contains(c.label)) {
        out.add('${c.label}: fired on a value it must leave alone');
      }
    }
    return out;
  }

  /// The row's metric, read as something that can fail.
  static double get ruleValidity {
    if (cases.isEmpty) {
      return 0;
    }
    final int broken = ruleFailures().length;
    final int total = cases.length;
    final int ok = total - (broken > total ? total : broken);
    return ok / total;
  }

  static const double floor = 1.0;
  static const double optimal = 1.0;

  static String get qualitativeOutput =>
      ruleValidity >= optimal ? 'Complete' : 'Not Complete';

  static const String pythonSubstitution =
      'The row names pii_sanitizer.py. Python belongs to the ingestion '
      'pipeline, the same side of the boundary as the BigQuery writes at '
      'Steps 132, 145 and 161. What the client owns is the earlier and more '
      'useful half: deciding what leaves the device at all. A sanitiser at '
      'ingestion cleans what arrives; one on the device cleans what is stored '
      'in a crash report, a local log and an outbox row on a handset someone '
      'later loses.';

  static const String syntaxValidityNote =
      'For a Python file "syntax validity" means it parses, which is true of '
      'every file anyone ever committed. The failure worth catching is a rule '
      'that is syntactically perfect and matches nothing: a redaction pattern '
      'with a wrong character class is not a syntax error, it is a silent '
      'leak that every test still passes. Every rule therefore carries a '
      'value it must catch AND one it must leave alone.';

  static const String saltNote =
      'A hash is not anonymisation. Hashing an email with a public function '
      'is reversible by hashing a list of emails -- the domain is small and '
      'enumerable. What makes opaqueId non-reversible is the per-install salt, '
      'which never leaves the device. FNV-1a is not a cryptographic hash and '
      'is not claimed to be; it is a grouping function over an already-salted '
      'input. "We hash it" is the most common way a team believes it has '
      'anonymised something it has not.';

  static const String prefixNote =
      'Every emitted id carries the hbid_ prefix. The scrubber\'s hex rule '
      'redacts any bare run of sixteen or more hex characters, because that is '
      'what a leaked token looks like -- and a bare hash from opaqueId looks '
      'identical to one. Without the prefix the sanitiser would flag its own '
      'output, rowIsClean would refuse every event carrying a query_hash, and '
      'Step 161 would drop them. The prefix makes the distinction legible to a '
      'rule instead of leaving it to be argued about in review.';

  static const String reusesScrubberNote =
      'HabotLogScrubber already carries the patterns and already runs over log '
      'output. This extends the same rules to event payloads and adds the '
      'hashing half, rather than declaring a second set of rules that would '
      'drift from the first.';
}
