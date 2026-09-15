/*
 * CKCKM-022-A16 — External Auditor Validation Sign-off Gateway
 * 
 * Setup Step (Action): Obtain final validation sign-off from the external auditor teams.
 * Metric Name: Task Execution Accuracy Rate (Floor: 95%, Target: 100%, Ceiling: 100%)
 * Quality Standard: General operational best practice benchmarks task execution against the approved specification, with deviations treated as defects requiring correction before sign-off.
 * Assigned Member: Pooja
 */

import 'package:flutter/material.dart';
import '../tokens/color_palette.dart';
import '../tokens/spacing_tokens.dart';

class AuditorValidationSignoffPanel extends StatefulWidget {
  final String globalRefId;
  final String atomicStepRefId;
  final String sequenceOrder;

  const AuditorValidationSignoffPanel({
    super.key,
    this.globalRefId = 'CKCKM-022',
    this.atomicStepRefId = 'CKCKM-022-A16',
    this.sequenceOrder = '8219',
  });

  @override
  State<AuditorValidationSignoffPanel> createState() => _AuditorValidationSignoffPanelState();
}

class _AuditorValidationSignoffPanelState extends State<AuditorValidationSignoffPanel> {
  final TextEditingController _auditorNameController = TextEditingController(text: 'Dr. Evelyn Reed (Ernst & Young LLP)');
  final TextEditingController _auditorCertIdController = TextEditingController(text: 'CERT-EY-FIN-2026-9041');
  
  bool _specComplianceChecked = true;
  bool _cryptoIntegrityChecked = true;
  bool _gdprRetentionChecked = true;
  bool _isSignedOff = false;
  String _auditResult = 'PENDING';
  String _auditTimestamp = 'Not Signed Off';
  double _executionAccuracy = 1.00;

  @override
  void dispose() {
    _auditorNameController.dispose();
    _auditorCertIdController.dispose();
    super.dispose();
  }

  bool get _canSignOff =>
      _specComplianceChecked &&
      _cryptoIntegrityChecked &&
      _gdprRetentionChecked &&
      _auditorNameController.text.isNotEmpty &&
      _auditorCertIdController.text.isNotEmpty;

  void _executeSignOff() {
    if (!_canSignOff) return;
    setState(() {
      _isSignedOff = true;
      _auditResult = 'PASS_CERTIFIED';
      _auditTimestamp = DateTime.now().toUtc().toIso8601String();
      _executionAccuracy = 1.00;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✓ External Auditor Validation Sign-off Confirmed: ${_auditorCertIdController.text}'),
        backgroundColor: AppColorPalette.success,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _revokeSignOff() {
    setState(() {
      _isSignedOff = false;
      _auditResult = 'REVOKED';
      _auditTimestamp = 'Revoked at ${DateTime.now().toUtc().toIso8601String().substring(11, 19)}';
    });
  }

  Map<String, dynamic> toExecutionLogJson() {
    return {
      'stepExecutionId': 'EXEC-${widget.globalRefId}-2026',
      'auditType': 'EXTERNAL_REGULATORY_FINANCIAL_AUDIT',
      'auditDate': _isSignedOff ? _auditTimestamp : DateTime.now().toUtc().toIso8601String(),
      'auditResult': _auditResult,
      'auditTrail': 'SHA256:7f83b1657ff1fc53b92dc18148a1d65dfc2d4b1fa3d677284addd200126d9069',
      'auditorInformation': '${_auditorNameController.text} | ${_auditorCertIdController.text}',
      'completionStatus': _isSignedOff ? 'Pass' : 'Pending',
      'actionEventTimestamp': DateTime.now().toUtc().toIso8601String(),
      'userSessionId': 'SESSION-${widget.globalRefId}',
      'metadata': {
        'taskCode': widget.globalRefId,
        'atomicStepCode': widget.atomicStepRefId,
        'row': 137,
        'seq': widget.sequenceOrder,
        'assigned': 'Pooja',
        'metricName': 'Task Execution Accuracy Rate',
        'floor': '95% accurate / on-spec execution',
        'target': '100% accurate / on-spec execution',
        'ceiling': '100% (zero deviation from specification)',
        'unit': 'Pass / Fail',
        'executionAccuracyRate': _executionAccuracy,
        'isSignedOff': _isSignedOff,
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 600;
        final isExpanded = constraints.maxWidth >= 840;
        final contentPadding = isCompact
            ? AppSpacingTokens.paddingSm
            : (isExpanded ? AppSpacingTokens.paddingLg : AppSpacingTokens.paddingMd);

        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: _isSignedOff
                  ? AppColorPalette.success
                  : AppColorPalette.brandPrimary.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Padding(
            padding: contentPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColorPalette.brandPrimary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.gavel_rounded,
                        color: AppColorPalette.brandPrimary,
                        size: 24,
                      ),
                    ),
                    AppSpacingTokens.hGapMd,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${widget.globalRefId} / ${widget.atomicStepRefId}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColorPalette.brandPrimary,
                              fontSize: isExpanded ? 16 : 14,
                            ),
                          ),
                          Text(
                            'External Auditor Sign-off Gateway (Seq: ${widget.sequenceOrder})',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: isCompact ? 10 : 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _isSignedOff ? AppColorPalette.successContainer : colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _isSignedOff ? 'Certified (100%)' : 'Pending Gate',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: _isSignedOff ? AppColorPalette.onSuccessContainer : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
                AppSpacingTokens.vGapMd,

                // Auditor Credentials Input Fields
                TextField(
                  controller: _auditorNameController,
                  decoration: const InputDecoration(
                    labelText: 'Lead External Auditor Name & Firm',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  enabled: !_isSignedOff,
                ),
                AppSpacingTokens.vGapSm,
                TextField(
                  controller: _auditorCertIdController,
                  decoration: const InputDecoration(
                    labelText: 'Auditor Certificate / Bar Identification',
                    prefixIcon: Icon(Icons.badge_outlined),
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  enabled: !_isSignedOff,
                ),
                AppSpacingTokens.vGapMd,

                // Checkpoint Gates
                Text(
                  'Statutory Verification Gates (All Required):',
                  style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                AppSpacingTokens.vGapSm,
                CheckboxListTile(
                  title: const Text('Approved Technical Specification Matching (Zero Deviation)', style: TextStyle(fontSize: 12)),
                  subtitle: const Text('Target 100% on-spec execution without scope drift', style: TextStyle(fontSize: 11)),
                  value: _specComplianceChecked,
                  onChanged: _isSignedOff ? null : (v) => setState(() => _specComplianceChecked = v ?? false),
                  dense: true,
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                CheckboxListTile(
                  title: const Text('HMAC-SHA-256 Cryptographic Non-Repudiation Pass', style: TextStyle(fontSize: 12)),
                  subtitle: const Text('NIST FIPS 180-4 deterministic signature validation', style: TextStyle(fontSize: 11)),
                  value: _cryptoIntegrityChecked,
                  onChanged: _isSignedOff ? null : (v) => setState(() => _cryptoIntegrityChecked = v ?? false),
                  dense: true,
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                CheckboxListTile(
                  title: const Text('GDPR/PDPL Privacy & Coordinate Retention Minimization', style: TextStyle(fontSize: 12)),
                  subtitle: const Text('Touch vectors truncated to 4 decimal places', style: TextStyle(fontSize: 11)),
                  value: _gdprRetentionChecked,
                  onChanged: _isSignedOff ? null : (v) => setState(() => _gdprRetentionChecked = v ?? false),
                  dense: true,
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                AppSpacingTokens.vGapMd,

                // Action Gateway Button (Min 48x48dp target)
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                      child: FilledButton.icon(
                        onPressed: _canSignOff && !_isSignedOff ? _executeSignOff : null,
                        icon: const Icon(Icons.verified_rounded),
                        label: const Text('Grant Final Auditor Sign-off'),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColorPalette.brandPrimary,
                          minimumSize: const Size(200, 48),
                        ),
                      ),
                    ),
                    if (_isSignedOff)
                      ConstrainedBox(
                        constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                        child: OutlinedButton.icon(
                          onPressed: _revokeSignOff,
                          icon: const Icon(Icons.restart_alt_rounded),
                          label: const Text('Revoke Sign-off'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(140, 48),
                          ),
                        ),
                      ),
                  ],
                ),
                AppSpacingTokens.vGapMd,

                // Telemetry Audit Box
                Container(
                  padding: AppSpacingTokens.paddingSm,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: colorScheme.outlineVariant),
                  ),
                  child: Column(
                    children: [
                      _buildAuditRow('Audit Result', _auditResult),
                      const Divider(height: 8),
                      _buildAuditRow('Audit Timestamp', _auditTimestamp),
                      const Divider(height: 8),
                      _buildAuditRow('Accuracy Rate', '${(_executionAccuracy * 100).toInt()}% (Target: 100%)'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAuditRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          Text(value, style: const TextStyle(fontSize: 11, fontFamily: 'monospace')),
        ],
      ),
    );
  }
}
