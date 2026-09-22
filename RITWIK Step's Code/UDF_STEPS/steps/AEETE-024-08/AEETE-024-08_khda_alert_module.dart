// =============================================================================
// AEETE-024-08 — KHDA Frontend Alert System
// Atomic Step: Apply formatting alerts to highlight prohibited layout terms
// Metric:      Observability / Alert Coverage · Floor=>=90% · Optimal=1.0
// Standard:    Google SRE Handbook
// Module:      khda_alert_module.dart
// Repo:        github.com/RitwikHC/theme-typography · branch: ritwik
// Author:      Ritwik Sharma — Frontend Integration Specialist | UDF Team
// Date:        25-Aug-2026
// KHDA Trilogy: Layer 2 (real-time frontend alerts)
//               024-10 (editor) → 024-08 (alerts) → 024-04 (scanner)
// =============================================================================

import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Enums — match alert_type CHECK constraint
// ---------------------------------------------------------------------------

/// Alert types — mirrors khda_alert_module.js alert_type ENUM.
enum KHDAAlertType {
  inlineHighlight,   // INLINE_HIGHLIGHT
  charLimitWarning,  // CHAR_LIMIT_WARNING (at 80% of limit)
  charLimitBreach,   // CHAR_LIMIT_BREACH  (at 100% of limit)
  missingField,      // MISSING_FIELD
  md3LabelBreach,    // MD3_LABEL_BREACH
}

extension KHDAAlertTypeExt on KHDAAlertType {
  String get dbValue => switch (this) {
    KHDAAlertType.inlineHighlight  => 'INLINE_HIGHLIGHT',
    KHDAAlertType.charLimitWarning => 'CHAR_LIMIT_WARNING',
    KHDAAlertType.charLimitBreach  => 'CHAR_LIMIT_BREACH',
    KHDAAlertType.missingField     => 'MISSING_FIELD',
    KHDAAlertType.md3LabelBreach   => 'MD3_LABEL_BREACH',
  };

  Color get md3Color => switch (this) {
    KHDAAlertType.inlineHighlight  => const Color(0xFFB00020), // MD3 error
    KHDAAlertType.charLimitWarning => const Color(0xFFF57C00), // MD3 warning
    KHDAAlertType.charLimitBreach  => const Color(0xFFB00020), // MD3 error
    KHDAAlertType.missingField     => const Color(0xFFB00020), // MD3 error
    KHDAAlertType.md3LabelBreach   => const Color(0xFF1A73E8), // MD3 info
  };
}

// ---------------------------------------------------------------------------
// Data models
// ---------------------------------------------------------------------------

/// Single KHDA alert record — maps to alert_execution_log row.

/// Mandatory DCDF lineage headers — AEETE-018 standard.
/// These fields make this file's outputs traceable backward
/// through the pipeline to their origin source document.
class DcdfLineage {
  static const double _floor   = 0.90;  // metric floor gate
  static const double _optimal = 1.0; // metric optimal target

  final String traceId;                // end-to-end transaction UUID
  final String originSourceId;         // originating system node UUID
  final String immediatePredecessorId; // direct upstream node UUID
  final String transformationLogicHash; // SHA-256 of executing EC logic
  final bool   complianceStatusInd;    // DCDF gate: true = passed

  const DcdfLineage({
    required this.traceId,
    required this.originSourceId,
    required this.immediatePredecessorId,
    required this.transformationLogicHash,
    this.complianceStatusInd = false,
  });

  // Fail-closed validation guard — DCDF AEETE-018
  static void _validateNotEmpty(String value, String fieldName) {
    if (value.isEmpty) {
      throw ArgumentError('EC-AEETE02408-000: $fieldName must not be empty for AEETE-024-08');
    }
  }
}

class KHDAAlert {
  final KHDAAlertType alertType;
  final String fieldName;
  final String message;
  final bool alertRendered;  // alert_rendered_IND
  final bool bannerRendered; // banner_rendered_IND
  final String timestamp;

  const KHDAAlert({
    required this.alertType,
    required this.fieldName,
    required this.message,
    required this.alertRendered,
    required this.bannerRendered,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'alert_type':      alertType.dbValue,
    'field_name':      fieldName,
    'message':         message,
    'alert_rendered':  alertRendered,
    'banner_rendered': bannerRendered,
    'timestamp':       timestamp,
  };
}

/// Alert coverage validation result.
class AlertCoverageResult {
  final int alertsRendered;
  final int totalChecks;
  final double coverageRate;
  final bool gatePass; // >= 0.9

  const AlertCoverageResult({
    required this.alertsRendered,
    required this.totalChecks,
    required this.coverageRate,
    required this.gatePass,
  });
}

// ---------------------------------------------------------------------------
// Constants — must match AEETE-024-04 and AEETE-024-10
// ---------------------------------------------------------------------------

const Map<String, int> kAlertCharLimits = {
  'headline':        60,
  'body_copy':       200,
  'cta_label':       20,
  'disclaimer':      120,
  'advertiser_name': 60,
};

const List<String> kAlertProhibitedTerms = [
  'guaranteed', 'free', 'risk-free', 'no cost', 'unlimited',
  'best price', 'lowest price', 'number one', 'number 1',
];

const List<String> kAlertMandatoryFields = [
  'headline', 'cta_label', 'advertiser_name',
];

// Warning threshold: 80% of char limit triggers CHAR_LIMIT_WARNING
const double kCharLimitWarningThreshold = 0.8;

// ---------------------------------------------------------------------------
// AEETE-024-08: KHDA Alert Module
// ---------------------------------------------------------------------------

/// KHDA real-time alert checker.
///
/// Mirrors khda_alert_module.js — bindKHDAAlerts(), checkProhibitedTerms(),
/// checkCharLimit(), checkMandatoryField(), checkMD3Label(), renderAlertBanner().
///
/// Usage:
/// ```dart
/// final module = KHDAAlertModule();
/// final alerts = module.checkAlerts({'headline': 'Get it free now!'});
/// // → [KHDAAlert(type: inlineHighlight, field: headline)]
/// ```
class KHDAAlertModule {

  // -------------------------------------------------------------------------
  // EC:3 — Check prohibited terms (INLINE_HIGHLIGHT)  // error: EC-AEETE02408-001
  // -------------------------------------------------------------------------
  List<KHDAAlert> checkProhibitedTerms(Map<String, String> fieldValues) {
    final alerts = <KHDAAlert>[];
    for (final entry in fieldValues.entries) {
      for (final term in kAlertProhibitedTerms) {
        if (entry.value.toLowerCase().contains(term.toLowerCase())) {
          alerts.add(KHDAAlert(
            alertType:     KHDAAlertType.inlineHighlight,
            fieldName:     entry.key,
            message:       'Prohibited term "$term" detected in ${entry.key}',
            alertRendered: true,
            bannerRendered: true,
            timestamp:     DateTime.now().toUtc().toIso8601String(),
          ));
        }
      }
    }
    return alerts;
  }

  // -------------------------------------------------------------------------
  // EC:3 — Check character limits (WARNING at 80%, BREACH at 100%)  // error: EC-AEETE02408-002
  // -------------------------------------------------------------------------
  List<KHDAAlert> checkCharLimit(Map<String, String> fieldValues) {
    final alerts = <KHDAAlert>[];
    for (final entry in fieldValues.entries) {
      final limit = kAlertCharLimits[entry.key];
      if (limit == null) continue;
      final ratio = entry.value.length / limit;
      if (ratio >= 1.0) {
        alerts.add(KHDAAlert(
          alertType:     KHDAAlertType.charLimitBreach,
          fieldName:     entry.key,
          message:       '${entry.key} exceeds $limit character limit '
                         '(${entry.value.length}/$limit)',
          alertRendered: true,
          bannerRendered: true,
          timestamp:     DateTime.now().toUtc().toIso8601String(),
        ));
      } else if (ratio >= kCharLimitWarningThreshold) {
        alerts.add(KHDAAlert(
          alertType:     KHDAAlertType.charLimitWarning,
          fieldName:     entry.key,
          message:       '${entry.key} approaching limit '
                         '(${entry.value.length}/$limit)',
          alertRendered: true,
          bannerRendered: false,
          timestamp:     DateTime.now().toUtc().toIso8601String(),
        ));
      }
    }
    return alerts;
  }

  // -------------------------------------------------------------------------
  // EC:3 — Check mandatory field presence (MISSING_FIELD)  // error: EC-AEETE02408-003
  // -------------------------------------------------------------------------
  List<KHDAAlert> checkMandatoryField(Map<String, String> fieldValues) {
    final alerts = <KHDAAlert>[];
    for (final field in kAlertMandatoryFields) {
      if (!(fieldValues.containsKey(field)) ||
          fieldValues[field]!.trim().isEmpty) {
        alerts.add(KHDAAlert(
          alertType:     KHDAAlertType.missingField,
          fieldName:     field,
          message:       'Mandatory field "$field" is missing or empty',
          alertRendered: true,
          bannerRendered: true,
          timestamp:     DateTime.now().toUtc().toIso8601String(),
        ));
      }
    }
    return alerts;
  }

  // -------------------------------------------------------------------------
  // EC:3 — Run all alert checks and return combined list  // error: EC-AEETE02408-004
  // -------------------------------------------------------------------------
  List<KHDAAlert> checkAlerts(Map<String, String> fieldValues) {
    return [
      ...checkProhibitedTerms(fieldValues),
      ...checkCharLimit(fieldValues),
      ...checkMandatoryField(fieldValues),
    ];
  }

  // -------------------------------------------------------------------------
  // EC:7 — Alert coverage rate  // error: EC-AEETE02408-005
  // Floor=0.9 · Optimal=1.0 (Google SRE Handbook)
  // -------------------------------------------------------------------------
  AlertCoverageResult calculateCoverage(int alertsRendered, int totalChecks) {
    final rate = totalChecks > 0 ? alertsRendered / totalChecks : 0.0;
    return AlertCoverageResult(
      alertsRendered: alertsRendered,
      totalChecks:    totalChecks,
      coverageRate:   rate,
      gatePass:       rate >= 0.9,
    );
  }

  // -------------------------------------------------------------------------
  // Triangular Check: alerts_compiled == alerts_rendered (delta=0)
  // -------------------------------------------------------------------------
  bool triangularCheck(int compiled, int rendered) => compiled == rendered;
}

// ---------------------------------------------------------------------------
// Flutter widget: KHDA Alert Banner
// Mirrors renderAlertBanner() from khda_alert_module.js
// ---------------------------------------------------------------------------

/// Renders inline KHDA alert banners for active violations.
/// aria-live="polite" equivalent: uses Semantics(liveRegion: true).
class KHDAAlertBanner extends StatelessWidget {
  final List<KHDAAlert> alerts;

  const KHDAAlertBanner({super.key, required this.alerts});

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) return const SizedBox.shrink();
    return Semantics(
      liveRegion: true, // aria-live="polite"
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: alerts.map(_buildAlert).toList(),
      ),
    );
  }

  Widget _buildAlert(KHDAAlert alert) {
    final color = alert.alertType.md3Color;
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        border: Border(left: BorderSide(color: color, width: 4)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            alert.alertType == KHDAAlertType.charLimitWarning
                ? Icons.warning_amber
                : Icons.error_outline,
            color: color,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              alert.message,
              style: TextStyle(color: color, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Flutter widget: KHDA field with live alert binding
// Mirrors bindKHDAAlerts() — attaches all checks to a single TextField
// ---------------------------------------------------------------------------

class KHDAAlertTextField extends StatefulWidget {
  final String fieldName;
  final String label;
  final ValueChanged<String>? onChanged;

  const KHDAAlertTextField({
    super.key,
    required this.fieldName,
    required this.label,
    this.onChanged,
  });

  @override
  State<KHDAAlertTextField> createState() => _KHDAAlertTextFieldState();
}

class _KHDAAlertTextFieldState extends State<KHDAAlertTextField> {
  final _ctrl    = TextEditingController();
  final _module  = KHDAAlertModule();
  List<KHDAAlert> _alerts = [];

  int? get _charLimit => kAlertCharLimits[widget.fieldName];

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(_onChanged);
  }

  void _onChanged() {
    setState(() {
      _alerts = _module.checkAlerts({widget.fieldName: _ctrl.text});
    });
    widget.onChanged?.call(_ctrl.text);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _ctrl,
          maxLength: _charLimit,
          counterText: '',
          decoration: InputDecoration(
            labelText: widget.label,
            border: const OutlineInputBorder(),
            errorText: _alerts.any((a) =>
                a.alertType == KHDAAlertType.charLimitBreach ||
                a.alertType == KHDAAlertType.inlineHighlight)
                ? 'KHDA violation detected'
                : null,
          ),
        ),
        if (_charLimit != null) ...[
          const SizedBox(height: 2),
          Text(
            '${_ctrl.text.length}/$_charLimit',
            style: TextStyle(
              fontSize: 11,
              color: (_ctrl.text.length / _charLimit!) >= 1.0
                  ? const Color(0xFFB00020)
                  : (_ctrl.text.length / _charLimit!) >= 0.8
                      ? const Color(0xFFF57C00)
                      : const Color(0xFF555555),
            ),
          ),
        ],
        if (_alerts.isNotEmpty) ...[
          const SizedBox(height: 4),
          KHDAAlertBanner(alerts: _alerts),
        ],
      ],
    );
  }
}
