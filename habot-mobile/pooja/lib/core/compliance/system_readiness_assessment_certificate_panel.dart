/*
 * EDBAA-024-A15 — System Readiness Assessment Certificate Panel
 * 
 * Setup Step (Action): Issue a System Readiness Validation Assessment Certificate upon successful test.
 * Metric Name: Verification & Test Coverage Completeness (Floor: <80%, Target: 95–100%, Ceiling: 100%)
 * Quality Standard: ISTQB Software Testing Standard / Six Sigma Defect Tolerance (<3.4 DPMO)
 * Telemetry: Test Type; Test Result; Test Coverage; Test Timestamp; Test Log Path; Completion Status ('Complete'); Action/Event Timestamp; User/Session ID
 * Assigned Member: Pooja
 */

import 'package:flutter/material.dart';

class SystemReadinessAssessmentCertificatePanel extends StatefulWidget {
  final String globalRefId;
  final String atomicStepRefId;
  final String sequenceOrder;

  const SystemReadinessAssessmentCertificatePanel({
    super.key,
    this.globalRefId = 'EDBAA-024',
    this.atomicStepRefId = 'EDBAA-024-A15',
    this.sequenceOrder = '12290',
  });

  @override
  State<SystemReadinessAssessmentCertificatePanel> createState() =>
      _SystemReadinessAssessmentCertificatePanelState();
}

class _SystemReadinessAssessmentCertificatePanelState
    extends State<SystemReadinessAssessmentCertificatePanel> {
  final String _certId = 'CERT-SRVA-2026-0909-PROD';
  final String _testType = 'Comprehensive Regression & Release Gate Validation';
  final String _testResult = 'PASSED (0 Defects / 0 Failures)';
  final String _testCoverage = '100% Case Coverage';
  final String _testTimestamp = '2026-09-09T12:00:00Z';
  final String _testLogPath = '/var/log/qa/system_readiness_validation_report.log';
  final String _completionStatus = 'Complete';
  final String _userSessionId = 'POOJA-EDBAA-024-A15';
  final String _signatureHash = '0x8f2d9c4b11ea572a9e01df3c44a2b910e527fca8';

  Map<String, dynamic> getTelemetryData() {
    return {
      'stepExecutionId': 'EXEC-EDBAA-024-A15-2026',
      'certificateId': _certId,
      'testType': _testType,
      'testResult': _testResult,
      'testCoverage': _testCoverage,
      'testTimestamp': _testTimestamp,
      'testLogPath': _testLogPath,
      'sixSigmaTolerance': '<3.4 DPMO (Zero Defect Tolerance Achieved)',
      'istqbCompliance': 'ISTQB Certified Ready for Production Release',
      'completionStatus': _completionStatus,
      'actionEventTimestamp': DateTime.now().toIso8601String(),
      'userSessionId': _userSessionId,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: SystemReadinessAssessmentCertificatePanelTokens.paddingLg,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SystemReadinessAssessmentCertificatePanelTokens.brandPrimary.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(SystemReadinessAssessmentCertificatePanelTokens.sm),
                decoration: BoxDecoration(
                  color: SystemReadinessAssessmentCertificatePanelTokens.successContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.verified_user_outlined,
                  color: SystemReadinessAssessmentCertificatePanelTokens.success,
                  size: 26,
                ),
              ),
              SystemReadinessAssessmentCertificatePanelTokens.hGapMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.atomicStepRefId} (Seq: ${widget.sequenceOrder})',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: SystemReadinessAssessmentCertificatePanelTokens.brandPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'System Readiness Assessment Certificate',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: SystemReadinessAssessmentCertificatePanelTokens.successContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'ISTQB / Six Sigma',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: SystemReadinessAssessmentCertificatePanelTokens.onSuccessContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SystemReadinessAssessmentCertificatePanelTokens.vGapMd,
          Container(
            width: double.infinity,
            padding: SystemReadinessAssessmentCertificatePanelTokens.paddingLg,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: SystemReadinessAssessmentCertificatePanelTokens.lightOutline.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      const Icon(Icons.workspace_premium, color: SystemReadinessAssessmentCertificatePanelTokens.brandPrimary, size: 40),
                      SystemReadinessAssessmentCertificatePanelTokens.vGapXs,
                      Text(
                        'CERTIFICATE OF SYSTEM READINESS',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          color: SystemReadinessAssessmentCertificatePanelTokens.brandPrimary,
                        ),
                      ),
                      Text(
                        _certId,
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontFamily: 'monospace',
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                SystemReadinessAssessmentCertificatePanelTokens.vGapMd,
                Divider(color: SystemReadinessAssessmentCertificatePanelTokens.lightOutline.withValues(alpha: 0.2)),
                SystemReadinessAssessmentCertificatePanelTokens.vGapSm,
                _buildCertRow('Validation Standard', 'ISTQB Software Testing Standard / Six Sigma (<3.4 DPMO)', theme, colorScheme),
                SystemReadinessAssessmentCertificatePanelTokens.vGapXs,
                _buildCertRow('Test Type', _testType, theme, colorScheme),
                SystemReadinessAssessmentCertificatePanelTokens.vGapXs,
                _buildCertRow('Validation Result', _testResult, theme, colorScheme, isHighlight: true),
                SystemReadinessAssessmentCertificatePanelTokens.vGapXs,
                _buildCertRow('Test Coverage', _testCoverage, theme, colorScheme),
                SystemReadinessAssessmentCertificatePanelTokens.vGapXs,
                _buildCertRow('Report Log Path', _testLogPath, theme, colorScheme, isCode: true),
                SystemReadinessAssessmentCertificatePanelTokens.vGapXs,
                _buildCertRow('Digital Signature', _signatureHash, theme, colorScheme, isCode: true),
                SystemReadinessAssessmentCertificatePanelTokens.vGapXs,
                _buildCertRow('Assigned Auditor', '$_userSessionId (Pooja)', theme, colorScheme),
              ],
            ),
          ),
          SystemReadinessAssessmentCertificatePanelTokens.vGapMd,
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Certificate $_certId verified & ready for deployment'),
                        backgroundColor: SystemReadinessAssessmentCertificatePanelTokens.success,
                      ),
                    );
                  },
                  icon: const Icon(Icons.verified),
                  label: const Text('Verify & Issue Certificate'),
                ),
              ),
              SystemReadinessAssessmentCertificatePanelTokens.hGapSm,
              OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Readiness audit log downloaded.')),
                  );
                },
                icon: const Icon(Icons.receipt_long),
                label: const Text('View Test Logs'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCertRow(
    String label,
    String value,
    ThemeData theme,
    ColorScheme colorScheme, {
    bool isCode = false,
    bool isHighlight = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: isCode
                ? theme.textTheme.bodySmall?.copyWith(fontFamily: 'monospace')
                : (isHighlight
                    ? theme.textTheme.bodySmall?.copyWith(
                        color: SystemReadinessAssessmentCertificatePanelTokens.success,
                        fontWeight: FontWeight.bold,
                      )
                    : theme.textTheme.bodySmall),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// File-Local Standalone Design Tokens & Constants
// ============================================================================
abstract final class SystemReadinessAssessmentCertificatePanelTokens {
  // Brand & Semantic Color Tokens
  static const Color brandPrimary = Color(0xFF2E86C1);
  static const Color onBrandPrimary = Color(0xFFFFFFFF);
  static const Color brandPrimaryContainer = Color(0xFFD6EAF8);
  static const Color onBrandPrimaryContainer = Color(0xFF1B4F72);
  static const Color brandPrimaryHoverOverlay = Color(0x1F2E86C1);
  static const Color brandPrimaryActiveOverlay = Color(0x3D2E86C1);

  static const Color primary = brandPrimary;
  static const Color primarySeed = Color(0xFF6750A4);
  static const Color secondarySeed = Color(0xFF625B71);
  static const Color tertiarySeed = Color(0xFF7D5260);
  static const Color neutralSeed = Color(0xFF605D62);

  static const Color success = Color(0xFF2E7D32);
  static const Color onSuccess = Color(0xFFFFFFFF);
  static const Color successContainer = Color(0xFFD0F8CE);
  static const Color onSuccessContainer = Color(0xFF002204);

  static const Color warning = Color(0xFFED6C02);
  static const Color onWarning = Color(0xFFFFFFFF);
  static const Color warningContainer = Color(0xFFFFDCC6);
  static const Color onWarningContainer = Color(0xFF341100);

  static const Color info = Color(0xFF0288D1);
  static const Color onInfo = Color(0xFFFFFFFF);
  static const Color infoContainer = Color(0xFFCBE6FF);
  static const Color onInfoContainer = Color(0xFF001E30);

  static const Color lightPrimary = Color(0xFF6750A4);
  static const Color lightOnPrimary = Color(0xFFFFFFFF);
  static const Color lightPrimaryContainer = Color(0xFFEADDFF);
  static const Color lightOnPrimaryContainer = Color(0xFF21005D);

  static const Color lightSecondary = Color(0xFF625B71);
  static const Color lightOnSecondary = Color(0xFFFFFFFF);
  static const Color lightSecondaryContainer = Color(0xFFE8DEF8);
  static const Color lightOnSecondaryContainer = Color(0xFF1D192B);

  static const Color lightTertiary = Color(0xFF7D5260);
  static const Color lightOnTertiary = Color(0xFFFFFFFF);
  static const Color lightTertiaryContainer = Color(0xFFFFD8E4);
  static const Color lightOnTertiaryContainer = Color(0xFF31111D);

  static const Color error = Color(0xFFB3261E);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFF9DEDC);
  static const Color onErrorContainer = Color(0xFF410E0B);
  static const Color lightError = Color(0xFFB3261E);
  static const Color lightOnError = Color(0xFFFFFFFF);
  static const Color lightErrorContainer = Color(0xFFF9DEDC);
  static const Color lightOnErrorContainer = Color(0xFF410E0B);

  static const Color lightBackground = Color(0xFFFEF7FF);
  static const Color lightOnBackground = Color(0xFF1D1B20);
  static const Color lightSurface = Color(0xFFFEF7FF);
  static const Color lightOnSurface = Color(0xFF1D1B20);
  static const Color lightSurfaceVariant = Color(0xFFE7E0EC);
  static const Color lightOnSurfaceVariant = Color(0xFF49454F);
  static const Color lightOutline = Color(0xFF79747E);
  static const Color lightOutlineVariant = Color(0xFFCAC4D0);

  static const Color neutralLight = Color(0xFFF5F5F5);
  static const Color neutralDark = Color(0xFF212121);

  // Elevation Tokens
  static const double level0 = 0.0;
  static const double level1 = 1.0;
  static const double level2 = 3.0;
  static const double level3 = 6.0;
  static const double level4 = 8.0;
  static const double level5 = 12.0;

  // Spacing & Layout Tokens (4dp Metric Grid)
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double mdSm = 12.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;

  static const EdgeInsets paddingXs = EdgeInsets.all(xs);
  static const EdgeInsets paddingSm = EdgeInsets.all(sm);
  static const EdgeInsets paddingMd = EdgeInsets.all(md);
  static const EdgeInsets paddingLg = EdgeInsets.all(lg);
  static const EdgeInsets paddingXl = EdgeInsets.all(xl);

  static const EdgeInsets paddingHorizontalSm = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets paddingHorizontalMd = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets paddingHorizontalLg = EdgeInsets.symmetric(horizontal: lg);

  static const EdgeInsets paddingVerticalSm = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets paddingVerticalMd = EdgeInsets.symmetric(vertical: md);

  static const Widget vGapXs = SizedBox(height: xs);
  static const Widget vGapSm = SizedBox(height: sm);
  static const Widget vGapMd = SizedBox(height: md);
  static const Widget vGapLg = SizedBox(height: lg);
  static const Widget vGapXl = SizedBox(height: xl);

  static const Widget hGapXs = SizedBox(width: xs);
  static const Widget hGapSm = SizedBox(width: sm);
  static const Widget hGapMd = SizedBox(width: md);
  static const Widget hGapLg = SizedBox(width: lg);
  static const Widget hGapXl = SizedBox(width: xl);
}

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: SystemReadinessAssessmentCertificatePanel(),
          ),
        ),
      ),
    ),
  );
}
