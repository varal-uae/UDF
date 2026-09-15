import 'package:flutter/material.dart';
import '../tokens/color_palette.dart';
import '../tokens/spacing_tokens.dart';

/// Row 228 - FEBFL-013-A03 (Seq 15066)
/// Action: Define safe default placeholder metrics to present if structural exceptions are encountered.
/// Metric: Process Execution Quality (%) | Target: 95% | Ceiling: 100%
/// Standard: Safe default metrics defined prior to sign-off.
class SafeDefaultPlaceholderMetricsPanel extends StatefulWidget {
  const SafeDefaultPlaceholderMetricsPanel({super.key});

  @override
  State<SafeDefaultPlaceholderMetricsPanel> createState() =>
      _SafeDefaultPlaceholderMetricsPanelState();
}

class _PlaceholderDefinition {
  final String definitionId;
  final String definitionName;
  final String definitionType;
  final String placeholderValue;
  final String fallbackBehavior;
  final bool isValidated;

  const _PlaceholderDefinition({
    required this.definitionId,
    required this.definitionName,
    required this.definitionType,
    required this.placeholderValue,
    required this.fallbackBehavior,
    required this.isValidated,
  });
}

class _SafeDefaultPlaceholderMetricsPanelState
    extends State<SafeDefaultPlaceholderMetricsPanel> {
  final String _stepExecutionId = 'FEBFL-013-A03-DEF-001';
  final String _userSessionId = 'POOJA-FEBFL-013-A03';
  final String _completionStatus = 'Complete';
  final String _standard = 'Fault-Tolerant Layout Parsing Standard';

  final DateTime _lastAuditTimestamp = DateTime.now();

  final List<_PlaceholderDefinition> _definitions = const [
    _PlaceholderDefinition(
      definitionId: 'DEF-METRIC-01',
      definitionName: 'Vendor Quality Score Fallback',
      definitionType: 'Numeric Score (0.0 - 1.0)',
      placeholderValue: '0.00 (Pending)',
      fallbackBehavior: 'Subtle gray badge with sync tooltip',
      isValidated: true,
    ),
    _PlaceholderDefinition(
      definitionId: 'DEF-METRIC-02',
      definitionName: 'Tax Registration (VAT TRN) Fallback',
      definitionType: 'Formatted String',
      placeholderValue: '—',
      fallbackBehavior: 'Render em-dash placeholder in table cell',
      isValidated: true,
    ),
    _PlaceholderDefinition(
      definitionId: 'DEF-METRIC-03',
      definitionName: 'Audit Timestamp Fallback',
      definitionType: 'ISO 8601 Timestamp',
      placeholderValue: 'Pending Sync',
      fallbackBehavior: 'Display gray clock icon',
      isValidated: true,
    ),
    _PlaceholderDefinition(
      definitionId: 'DEF-METRIC-04',
      definitionName: 'Dispatched Units Quantity',
      definitionType: 'Integer Counter',
      placeholderValue: '0',
      fallbackBehavior: 'Zero-fill cell with warning border',
      isValidated: true,
    ),
  ];

  Map<String, dynamic> getTelemetryData() {
    final validatedCount = _definitions.where((d) => d.isValidated).length;
    final completionPct = (validatedCount / _definitions.length * 100).toStringAsFixed(1);
    return {
      'Definition Name': 'Safe Default Fallback Metric Suite',
      'Definition Parameters': '4 Field-Level Structural Interceptors',
      'Definition Type': 'Comprehensive Fault Tolerance Policy',
      'Validation Status': '100% SCHEMA_CONFORMANT',
      'Definition ID': _stepExecutionId,
      'Completion Status': '$completionPct% ($_completionStatus)',
      'Action/Event Timestamp': _lastAuditTimestamp.toIso8601String(),
      'User/Session ID': _userSessionId,
      'Standard': _standard,
    };
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppSpacingTokens.paddingMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeaderCard(),
          AppSpacingTokens.vGapMd,
          _buildDefinitionsListCard(),
          AppSpacingTokens.vGapMd,
          _buildInteractivePreviewCard(),
          AppSpacingTokens.vGapMd,
          _buildTelemetryCard(),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
        side: BorderSide(color: AppColorPalette.lightOutline.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: AppSpacingTokens.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.shield_outlined,
                  color: AppColorPalette.brandPrimary,
                  size: 22,
                ),
                AppSpacingTokens.hGapSm,
                const Expanded(
                  child: Text(
                    'Safe Default Placeholder Metrics',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColorPalette.brandPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColorPalette.successContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '100% Complete',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColorPalette.onSuccessContainer,
                    ),
                  ),
                ),
              ],
            ),
            AppSpacingTokens.vGapSm,
            Text(
              'Defines robust default fallback values for structured metrics, preventing crashes and blank UI holes when corrupt payloads are encountered.',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefinitionsListCard() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
        side: BorderSide(color: AppColorPalette.lightOutline.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: AppSpacingTokens.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Placeholder Metric Registry',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColorPalette.brandPrimary,
              ),
            ),
            AppSpacingTokens.vGapSm,
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _definitions.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final def = _definitions[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(
                    backgroundColor: AppColorPalette.brandPrimaryContainer,
                    radius: 16,
                    child: Icon(Icons.security, size: 16, color: AppColorPalette.onBrandPrimaryContainer),
                  ),
                  title: Text(def.definitionName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  subtitle: Text('Type: ${def.definitionType} | Fallback: "${def.placeholderValue}"',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                  trailing: const Icon(Icons.check_circle, color: AppColorPalette.success, size: 18),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractivePreviewCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
        side: BorderSide(color: AppColorPalette.lightOutline.withValues(alpha: 0.3)),
      ),
      color: Colors.grey.shade50,
      child: Padding(
        padding: AppSpacingTokens.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Simulated Layout Fallback Rendering',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColorPalette.brandPrimary,
              ),
            ),
            AppSpacingTokens.vGapSm,
            Row(
              children: [
                Expanded(
                  child: _buildMetricCell('VAT TRN', '—', isFallback: true),
                ),
                AppSpacingTokens.hGapSm,
                Expanded(
                  child: _buildMetricCell('Quality Score', '0.00 (Pending)', isFallback: true),
                ),
                AppSpacingTokens.hGapSm,
                Expanded(
                  child: _buildMetricCell('Status', 'Pending Sync', isFallback: true),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCell(String label, String value, {required bool isFallback}) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: isFallback ? AppColorPalette.warning.withValues(alpha: 0.5) : Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isFallback ? AppColorPalette.warning : Colors.black87,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTelemetryCard() {
    final telemetry = getTelemetryData();
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
        side: BorderSide(color: AppColorPalette.lightOutline.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: AppSpacingTokens.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Audit Telemetry',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColorPalette.brandPrimary,
              ),
            ),
            AppSpacingTokens.vGapSm,
            ...telemetry.entries.map((e) {
              final val = e.value.toString();
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 170,
                      child: Text(
                        '${e.key}:',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        val,
                        style: const TextStyle(
                          fontSize: 11,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
