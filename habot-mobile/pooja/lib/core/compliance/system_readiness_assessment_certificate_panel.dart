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
import '../tokens/color_palette.dart';
import '../tokens/spacing_tokens.dart';

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
      padding: AppSpacingTokens.paddingLg,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColorPalette.brandPrimary.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacingTokens.sm),
                decoration: BoxDecoration(
                  color: AppColorPalette.successContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.verified_user_outlined,
                  color: AppColorPalette.success,
                  size: 26,
                ),
              ),
              AppSpacingTokens.hGapMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.atomicStepRefId} (Seq: ${widget.sequenceOrder})',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: AppColorPalette.brandPrimary,
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
                  color: AppColorPalette.successContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'ISTQB / Six Sigma',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColorPalette.onSuccessContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          AppSpacingTokens.vGapMd,
          Container(
            width: double.infinity,
            padding: AppSpacingTokens.paddingLg,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColorPalette.lightOutline.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      const Icon(Icons.workspace_premium, color: AppColorPalette.brandPrimary, size: 40),
                      AppSpacingTokens.vGapXs,
                      Text(
                        'CERTIFICATE OF SYSTEM READINESS',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          color: AppColorPalette.brandPrimary,
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
                AppSpacingTokens.vGapMd,
                Divider(color: AppColorPalette.lightOutline.withValues(alpha: 0.2)),
                AppSpacingTokens.vGapSm,
                _buildCertRow('Validation Standard', 'ISTQB Software Testing Standard / Six Sigma (<3.4 DPMO)', theme, colorScheme),
                AppSpacingTokens.vGapXs,
                _buildCertRow('Test Type', _testType, theme, colorScheme),
                AppSpacingTokens.vGapXs,
                _buildCertRow('Validation Result', _testResult, theme, colorScheme, isHighlight: true),
                AppSpacingTokens.vGapXs,
                _buildCertRow('Test Coverage', _testCoverage, theme, colorScheme),
                AppSpacingTokens.vGapXs,
                _buildCertRow('Report Log Path', _testLogPath, theme, colorScheme, isCode: true),
                AppSpacingTokens.vGapXs,
                _buildCertRow('Digital Signature', _signatureHash, theme, colorScheme, isCode: true),
                AppSpacingTokens.vGapXs,
                _buildCertRow('Assigned Auditor', '$_userSessionId (Pooja)', theme, colorScheme),
              ],
            ),
          ),
          AppSpacingTokens.vGapMd,
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Certificate $_certId verified & ready for deployment'),
                        backgroundColor: AppColorPalette.success,
                      ),
                    );
                  },
                  icon: const Icon(Icons.verified),
                  label: const Text('Verify & Issue Certificate'),
                ),
              ),
              AppSpacingTokens.hGapSm,
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
                        color: AppColorPalette.success,
                        fontWeight: FontWeight.bold,
                      )
                    : theme.textTheme.bodySmall),
          ),
        ),
      ],
    );
  }
}
