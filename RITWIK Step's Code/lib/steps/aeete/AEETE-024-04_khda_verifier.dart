// =============================================================================
// AEETE-024-04 — KHDA Ad Layout Scanner
// Atomic Step: Program text filtering systems to scan marketing content layout
// Metric:      UI Design-System Adherence Rate · Floor=>=85% · Optimal=>=95%
// Standard:    Material Design 3 / Nielsen Norman Group
// Module:      khda_verifier.dart
// Repo:        github.com/RitwikHC/theme-typography · branch: ritwik
// Author:      Ritwik Sharma — Frontend Integration Specialist | UDF Team
// Date:        25-Aug-2026
// KHDA Trilogy: Layer 1 (backend publish-time gate)
//               024-10 (editor) → 024-08 (alerts) → 024-04 (scanner/gate)
// =============================================================================

// ---------------------------------------------------------------------------
// Enums
// ---------------------------------------------------------------------------

/// KHDA rule types — mirrors khda_verifier.py RuleType enum.
enum KHDARuleType {
  prohibitedTerm,  // PROHIBITED_TERM
  charCount,       // CHAR_COUNT
  mandatoryField,  // MANDATORY_FIELD
  md3Label,        // MD3_LABEL
}

extension KHDARuleTypeExt on KHDARuleType {
  String get dbValue => switch (this) {
    KHDARuleType.prohibitedTerm  => 'PROHIBITED_TERM',
    KHDARuleType.charCount       => 'CHAR_COUNT',
    KHDARuleType.mandatoryField  => 'MANDATORY_FIELD',
    KHDARuleType.md3Label        => 'MD3_LABEL',
  };
}

/// Violation severity levels.
enum ViolationSeverity { high, medium, low }

// ---------------------------------------------------------------------------
// Data models
// ---------------------------------------------------------------------------

/// Single KHDA violation record — maps to violations JSON column.
class KHDAViolation {
  final KHDARuleType ruleType;
  final String fieldName;
  final String violationDetail;
  final ViolationSeverity severity;

  const KHDAViolation({
    required this.ruleType,
    required this.fieldName,
    required this.violationDetail,
    required this.severity,
  });

  Map<String, dynamic> toJson() => {
    'rule_type':         ruleType.dbValue,
    'field_name':        fieldName,
    'violation_detail':  violationDetail,
    'severity':          severity.name.toUpperCase(),
  };
}

/// Full scan result for one layout asset.
/// Maps to ad_verification_execution_log row.
class KHDAScanResult {
  final String layoutId;
  final double adherenceRatePct;
  final String adherenceOutput; // Good / Average / Poor
  final List<KHDAViolation> violations;
  final String timestamp;

  const KHDAScanResult({
    required this.layoutId,
    required this.adherenceRatePct,
    required this.adherenceOutput,
    required this.violations,
    required this.timestamp,
  });

  bool get gatePass  => adherenceRatePct >= 85;
  bool get isGood    => adherenceRatePct >= 95;
  bool get isAverage => adherenceRatePct >= 85 && adherenceRatePct < 95;
  bool get isPoor    => adherenceRatePct < 85;

  Map<String, dynamic> toJson() => {
    'layout_id':          layoutId,
    'adherence_rate_pct': adherenceRatePct,
    'adherence_output':   adherenceOutput,
    'violations':         violations.map((v) => v.toJson()).toList(),
    'timestamp':          timestamp,
  };
}

// ---------------------------------------------------------------------------
// Constants — KHDA rule definitions
// ---------------------------------------------------------------------------

/// Prohibited terms — HIGH severity.
const List<String> kKHDAProhibitedTerms = [
  'guaranteed', 'free', 'risk-free', 'no cost', 'unlimited',
  'best price', 'lowest price', 'number one', 'number 1',
  '#1', 'zero cost', 'complimentary',
];

/// Character limits per layout zone.
const Map<String, int> kKHDACharLimits = {
  'headline':        60,
  'body_copy':       200,
  'cta_label':       20,
  'disclaimer':      120,
  'advertiser_name': 60,
};

/// Mandatory fields — must be non-empty.
const List<String> kKHDAMandatoryFields = [
  'headline', 'cta_label', 'advertiser_name',
];

/// MD3 label compliance rules — field must end with valid MD3 label suffix.
const Map<String, List<String>> kMD3LabelRules = {
  'cta_label':   ['Learn More', 'Get Started', 'Shop Now', 'Sign Up', 'Contact Us'],
};

// ---------------------------------------------------------------------------
// AEETE-024-04: KHDA Verifier
// ---------------------------------------------------------------------------

/// KHDA ad layout content scanner.
///
/// Mirrors khda_verifier.py — KHDAVerifier + @khda_verify decorator pattern.
/// Backend publish-time gate for KHDA trilogy.
///
/// Usage:
/// ```dart
/// final verifier = KHDAVerifier();
/// final result = verifier.scan('layout_001', {
///   'headline': 'Best price guaranteed!',
///   'cta_label': 'Learn More',
///   'advertiser_name': 'Habot Connect',
/// });
/// if (result.isPoor) blockPublication();
/// ```
class KHDAVerifier {

  // -------------------------------------------------------------------------
  // EC:3 — Scan layout content for all 4 rule types.
  // -------------------------------------------------------------------------
  KHDAScanResult scan(String layoutId, Map<String, String> content) {
    final violations = <KHDAViolation>[];

    // Rule 1: Prohibited terms (HIGH severity)
    for (final entry in content.entries) {
      for (final term in kKHDAProhibitedTerms) {
        if (entry.value.toLowerCase().contains(term.toLowerCase())) {
          violations.add(KHDAViolation(
            ruleType:        KHDARuleType.prohibitedTerm,
            fieldName:       entry.key,
            violationDetail: 'Prohibited term "$term" found in ${entry.key}',
            severity:        ViolationSeverity.high,
          ));
        }
      }
    }

    // Rule 2: Character count limits (MEDIUM severity)
    for (final entry in kKHDACharLimits.entries) {
      final value = content[entry.key] ?? '';
      if (value.length > entry.value) {
        violations.add(KHDAViolation(
          ruleType:        KHDARuleType.charCount,
          fieldName:       entry.key,
          violationDetail: '${entry.key} exceeds ${entry.value} chars '
                           '(actual: ${value.length})',
          severity:        ViolationSeverity.medium,
        ));
      }
    }

    // Rule 3: Mandatory field presence (HIGH severity)
    for (final field in kKHDAMandatoryFields) {
      if (!(content.containsKey(field)) || content[field]!.trim().isEmpty) {
        violations.add(KHDAViolation(
          ruleType:        KHDARuleType.mandatoryField,
          fieldName:       field,
          violationDetail: 'Mandatory field "$field" is missing or empty',
          severity:        ViolationSeverity.high,
        ));
      }
    }

    // Rule 4: MD3 label compliance (MEDIUM severity)
    for (final entry in kMD3LabelRules.entries) {
      final value = content[entry.key] ?? '';
      if (value.isNotEmpty && !entry.value.contains(value)) {
        violations.add(KHDAViolation(
          ruleType:        KHDARuleType.md3Label,
          fieldName:       entry.key,
          violationDetail: '"${entry.key}" value "$value" is not in MD3 approved '
                           'label set: ${entry.value.join(", ")}',
          severity:        ViolationSeverity.medium,
        ));
      }
    }

    // EC:7 — Calculate adherence rate
    return _buildResult(layoutId, violations);
  }

  KHDAScanResult _buildResult(String layoutId, List<KHDAViolation> violations) {
    final totalChecks  = kKHDAProhibitedTerms.length +
                         kKHDACharLimits.length +
                         kKHDAMandatoryFields.length +
                         kMD3LabelRules.length;
    final passedChecks = totalChecks - violations.length;
    final rate         = passedChecks / totalChecks * 100;
    final output = rate >= 95 ? 'Good' : rate >= 85 ? 'Average' : 'Poor';

    return KHDAScanResult(
      layoutId:          layoutId,
      adherenceRatePct:  rate.clamp(0, 100),
      adherenceOutput:   output,
      violations:        violations,
      timestamp:         DateTime.now().toUtc().toIso8601String(),
    );
  }

  // -------------------------------------------------------------------------
  // EC:6 — Batch scan multiple layouts.
  // -------------------------------------------------------------------------
  List<KHDAScanResult> scanBatch(Map<String, Map<String, String>> layouts) {
    return layouts.entries
        .map((e) => scan(e.key, e.value))
        .toList();
  }

  // -------------------------------------------------------------------------
  // EC:7 — Overall adherence rate across a batch.
  // -------------------------------------------------------------------------
  double batchAdherenceRate(List<KHDAScanResult> results) {
    if (results.isEmpty) return 0;
    return results.map((r) => r.adherenceRatePct).reduce((a, b) => a + b) /
           results.length;
  }

  // -------------------------------------------------------------------------
  // Triangular Check: layouts_scanned == reports_published (delta=0)
  // -------------------------------------------------------------------------
  bool triangularCheck(int scanned, int published) => scanned == published;
}
