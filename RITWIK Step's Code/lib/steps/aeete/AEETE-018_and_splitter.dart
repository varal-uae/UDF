// =============================================================================
// AEETE-018 — Rule of And Splitting Hook
// Atomic Step: Implement regex-driven splitting hook in and_splitter.dart
// Metric:      Implementation Conformance Rate · Floor=0.92 · Optimal=0.98
// Standard:    ISO/IEC/IEEE 12207
// Module:      and_splitter.dart
// Repo:        github.com/RitwikHC/theme-typography · branch: ritwik
// Author:      Ritwik Sharma — Frontend Integration Specialist | UDF Team
// Date:        25-Aug-2026
// =============================================================================

import 'dart:convert';

/// Immutable list of AND-compound patterns.
/// immutable_IND = TRUE — do not modify at runtime.
const List<String> kAndPatterns = [
  r'\band\b',
  r'\bas well as\b',
  r'\balong with\b',
  r'\btogether with\b',
  r'\bin addition to\b',
  r'\bplus\b',
  r'\balso\b',
];

/// Result of splitting one compound statement.
/// Maps to splitter_execution_log table.
class SplitResult {
  final String original;
  final List<String> parts;
  final bool wasSplit;
  final String? matchedPattern;
  final String timestamp;

  const SplitResult({
    required this.original,
    required this.parts,
    required this.wasSplit,
    this.matchedPattern,
    required this.timestamp,
  });

  int get splitCount => parts.length;

  Map<String, dynamic> toJson() => {
    'original':        original,
    'parts':           parts,
    'was_split':       wasSplit,
    'matched_pattern': matchedPattern,
    'split_count':     splitCount,
    'split_result':    jsonEncode(parts),
    'timestamp':       timestamp,
  };
}

/// Validation report for a split run.
class SplitterValidationResult {
  final int totalStatements;
  final int correctlySplit;
  final int falseNegativeCount;
  final double conformanceRate;
  final bool gatePass; // conformanceRate >= 0.92 AND falseNegativeCount == 0

  const SplitterValidationResult({
    required this.totalStatements,
    required this.correctlySplit,
    required this.falseNegativeCount,
    required this.conformanceRate,
    required this.gatePass,
  });

  String get conformanceOutput =>
      conformanceRate >= 0.98 ? 'Complete' :
      conformanceRate >= 0.92 ? 'Partial'  : 'Not Complete';
}

/// AEETE-018: Regex-driven AND splitting hook.
///
/// Detects AND-compound statements and splits them into atomic parts.
/// Mirrors and_splitter.py — splitting_gate decorator pattern.
///
/// Usage:
/// ```dart
/// final hook = AndSplittingHook();
/// final result = hook.runSplittingGate('Open file and validate schema');
/// print(result.parts); // ['Open file', 'validate schema']
/// ```
class AndSplittingHook {
  final List<RegExp> _compiledPatterns;
  final bool immutable; // immutable_IND — patterns locked once true

  AndSplittingHook({this.immutable = true})
      : _compiledPatterns = kAndPatterns
            .map((p) => RegExp(p, caseSensitive: false))
            .toList();

  // ---------------------------------------------------------------------------
  // EC:3 — Check if statement contains compound AND pattern.
  // gate: false_negative_count must remain 0
  // ---------------------------------------------------------------------------
  bool matchesCompound(String statement) {
    return _compiledPatterns.any((re) => re.hasMatch(statement));
  }

  /// Returns the first matched pattern, or null if none.
  String? firstMatchedPattern(String statement) {
    for (int i = 0; i < _compiledPatterns.length; i++) {
      if (_compiledPatterns[i].hasMatch(statement)) {
        return kAndPatterns[i];
      }
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // EC:5 — Split compound statement into atomic parts.
  // ---------------------------------------------------------------------------
  List<String> splitCompound(String statement) {
    if (!matchesCompound(statement)) return [statement];

    String working = statement;
    // Replace all matched AND patterns with a safe delimiter
    for (final re in _compiledPatterns) {
      working = working.replaceAll(re, '|||');
    }

    return working
        .split('|||')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  // ---------------------------------------------------------------------------
  // EC:6 — Full splitting gate with audit log output.
  // Mirrors @splitting_gate decorator from and_splitter.py
  // ---------------------------------------------------------------------------
  SplitResult runSplittingGate(String statement) {
    final matched  = firstMatchedPattern(statement);
    final parts    = splitCompound(statement);
    final wasSplit = parts.length > 1;

    return SplitResult(
      original:       statement,
      parts:          parts,
      wasSplit:       wasSplit,
      matchedPattern: matched,
      timestamp:      DateTime.now().toUtc().toIso8601String(),
    );
  }

  // ---------------------------------------------------------------------------
  // EC:7 — Calculate conformance rate.
  // Floor = 0.92 · Optimal = 0.98
  // Gate: falseNegativeCount must be 0 (FAIL-CLOSED if not)
  // ---------------------------------------------------------------------------
  SplitterValidationResult calculateConformance({
    required int totalStatements,
    required int correctlySplit,
    required int falseNegativeCount,
  }) {
    assert(immutable, 'Conformance check requires immutable_IND=TRUE');
    final rate = totalStatements > 0
        ? correctlySplit / totalStatements
        : 0.0;
    final gatePass = rate >= 0.92 && falseNegativeCount == 0;
    return SplitterValidationResult(
      totalStatements:  totalStatements,
      correctlySplit:   correctlySplit,
      falseNegativeCount: falseNegativeCount,
      conformanceRate:  rate,
      gatePass:         gatePass,
    );
  }

  // ---------------------------------------------------------------------------
  // Triangular Check: statements_in - statements_out == 0
  // ---------------------------------------------------------------------------
  bool triangularCheck(int statementsIn, int statementsOut) {
    return (statementsIn - statementsOut) == 0;
  }
}
