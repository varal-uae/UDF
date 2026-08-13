/// AISS: REF-197-A01 substep 2 -- "Configure error log scrubbers to remove
/// sensitive backend code path variables from user-facing logs."
/// Poka-Yoke: "Catch-all code structures strip out server-specific error
/// language automatically before messages reach the UI layer."
///
/// The scrubber is deliberately conservative: it is easier to defend a
/// redaction that was unnecessary than a leak that was not. Anything matching
/// a known shape of infrastructure detail is replaced with a fixed token, so
/// the redaction is visible in the log rather than silently blank.
library;

/// One redaction rule.
class ScrubRule {
  const ScrubRule(this.pattern, this.label);
  final RegExp pattern;

  /// Named in diagnostics so you learn a path was redacted without learning
  /// the path.
  final String label;
}

/// Redacts infrastructure detail from a string before it can reach a user or a
/// client-side log.
class HabotLogScrubber {
  const HabotLogScrubber._();

  static const String redaction = '[redacted]';

  /// Patterns of things that must never surface. Ordered most specific first,
  /// because an earlier replacement can otherwise destroy a later match.
  static final List<ScrubRule> rules = <ScrubRule>[
    // Bare URLs -- first, so the path rule cannot chew a URL in half.
    ScrubRule(RegExp(r'\bhttps?://[^\s]+'), 'url'),
    // package: / dart: / file: URIs.
    ScrubRule(RegExp(r'\b(?:package|dart|file):[\w./\-]+'), 'uri'),
    // Absolute file paths (POSIX and Windows).
    ScrubRule(RegExp(r'(?:[A-Za-z]:)?[\\/](?:[\w.\-]+[\\/])+[\w.\-]+'), 'path'),
    // IPv4 addresses, with optional port.
    ScrubRule(RegExp(r'\b\d{1,3}(?:\.\d{1,3}){3}(?::\d{1,5})?\b'), 'ip'),
    // Email addresses.
    ScrubRule(RegExp(r'\b[\w.+\-]+@[\w\-]+\.[\w.\-]+\b'), 'email'),
    // Stack frame markers.
    ScrubRule(RegExp(r'#\d+\s+\S+'), 'frame'),
    // Bearer tokens / API keys announced by their prefix.
    ScrubRule(
      RegExp(r'\b(?:Bearer|api[_-]?key|token)[=:\s]+\S+', caseSensitive: false),
      'secret',
    ),
    // Long hex blobs -- tokens, hashes, ids.
    ScrubRule(RegExp(r'\b[0-9a-fA-F]{16,}\b'), 'hex'),
    // SQL fragments.
    ScrubRule(
      RegExp(
        r'\b(?:SELECT|INSERT INTO|UPDATE|DELETE FROM)\b[^\n]*',
        caseSensitive: false,
      ),
      'sql',
    ),
  ];

  /// Returns [input] with every rule applied.
  static String scrub(String input) {
    String out = input;
    for (final ScrubRule rule in rules) {
      out = out.replaceAll(rule.pattern, redaction);
    }
    return out.trim();
  }

  /// True when [value] still contains something that looks like infrastructure
  /// detail. Used by the gate to prove the scrubber is exhaustive over its own
  /// rule set.
  static bool isClean(String value) => scrub(value) == value.trim();

  /// Which rule labels fired on [input]. Useful in a diagnostic log: you learn
  /// that a path was redacted without learning the path.
  static List<String> firedRules(String input) => <String>[
    for (final ScrubRule rule in rules)
      if (rule.pattern.hasMatch(input)) rule.label,
  ];
}
