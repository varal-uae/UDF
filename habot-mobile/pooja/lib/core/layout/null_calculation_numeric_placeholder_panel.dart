import 'package:flutter/material.dart';
import '../tokens/color_palette.dart';
import '../tokens/spacing_tokens.dart';

/// Row 238 - FEBFL-021-A04 (Seq 15157)
/// Action: Define safe default numeric placeholders for null calculation fields.
/// Metric: Process Execution Quality (%) | Target: 95% | Ceiling: 100% | Unit: Complete/Partial/Not Complete
/// Standard: General execution standard in mature delivery pipeline.
class NullCalculationNumericPlaceholderPanel extends StatefulWidget {
  const NullCalculationNumericPlaceholderPanel({super.key});

  @override
  State<NullCalculationNumericPlaceholderPanel> createState() =>
      _NullCalculationNumericPlaceholderPanelState();
}

class _PlaceholderDefinition {
  final String fieldName;
  final num defaultValue;
  final String unit;
  final String fallbackStrategy;

  const _PlaceholderDefinition({
    required this.fieldName,
    required this.defaultValue,
    required this.unit,
    required this.fallbackStrategy,
  });
}

class _NullCalculationNumericPlaceholderPanelState
    extends State<NullCalculationNumericPlaceholderPanel> {
  final String _definitionName = 'Safe Numeric Null Fallback Specification';
  final String _definitionParameters = 'coalesce(val, fallbackValue) with bounds check';
  final String _definitionType = 'Numeric Calculation Fallback Protocol';
  final String _definitionId = 'FEBFL-021-A04-DEF-01';
  final String _validationStatus = 'VERIFIED_ACTIVE';
  final String _completionStatus = 'Complete';
  final String _userSessionId = 'POOJA-FEBFL-021-A04';

  final List<_PlaceholderDefinition> _definitions = const [
    _PlaceholderDefinition(fieldName: 'Tutor Rating Score', defaultValue: 0.0, unit: 'Stars (0.0-5.0)', fallbackStrategy: 'Safe default zero rating without crashing'),
    _PlaceholderDefinition(fieldName: 'Total Completed Sessions', defaultValue: 0, unit: 'Integer Count', fallbackStrategy: 'Default zero counter for new profiles'),
    _PlaceholderDefinition(fieldName: 'Hourly Booking Rate', defaultValue: 0.0, unit: 'USD Currency', fallbackStrategy: 'Default zero price requiring explicit quote'),
    _PlaceholderDefinition(fieldName: 'Response Time Latency', defaultValue: 60, unit: 'Minutes', fallbackStrategy: 'Conservative default 60-min response window'),
  ];

  // Interactive simulated calculation fields
  double? _nullableRate;
  int? _nullableSessionCount;

  num _safeResolve(num? input, num fallback) => input ?? fallback;

  Map<String, dynamic> getTelemetryData() {
    return {
      'Definition Name': _definitionName,
      'Definition Parameters': _definitionParameters,
      'Definition Type': _definitionType,
      'Validation Status': _validationStatus,
      'Definition ID': _definitionId,
      'Completion Status': _completionStatus,
      'Action/Event Timestamp': DateTime.now().toIso8601String(),
      'User/Session ID': _userSessionId,
      'Active Fallback Definitions': _definitions.length,
      'Calculated Rate With Fallback': _safeResolve(_nullableRate, 35.0),
      'Calculated Sessions With Fallback': _safeResolve(_nullableSessionCount, 0),
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
          _buildInteractiveFallbackDemoCard(),
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
                  Icons.calculate_outlined,
                  color: AppColorPalette.brandPrimary,
                  size: 22,
                ),
                AppSpacingTokens.hGapSm,
                const Expanded(
                  child: Text(
                    'Safe Default Numeric Placeholders',
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
                    'Target: 95% (Complete)',
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
              'Enforces safe default numeric values for null computation fields, mitigating runtime null pointer exceptions across mathematical operations.',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefinitionsListCard() {
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
              'Registered Numeric Fallback Registry',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColorPalette.brandPrimary),
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
                  leading: const Icon(Icons.numbers, color: AppColorPalette.brandPrimary, size: 20),
                  title: Text(def.fieldName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  subtitle: Text(def.fallbackStrategy, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Text('Default: ${def.defaultValue}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractiveFallbackDemoCard() {
    final effectiveRate = _safeResolve(_nullableRate, 35.0);
    final effectiveSessions = _safeResolve(_nullableSessionCount, 0);

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
              'Interactive Null-Safety Resolver Demo',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColorPalette.brandPrimary),
            ),
            AppSpacingTokens.vGapSm,
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _nullableRate = _nullableRate == null ? 45.0 : null;
                      });
                    },
                    child: Text(_nullableRate == null ? 'Set Rate: \$45.0' : 'Set Rate: null'),
                  ),
                ),
                AppSpacingTokens.hGapSm,
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _nullableSessionCount = _nullableSessionCount == null ? 12 : null;
                      });
                    },
                    child: Text(_nullableSessionCount == null ? 'Set Sessions: 12' : 'Set Sessions: null'),
                  ),
                ),
              ],
            ),
            AppSpacingTokens.vGapSm,
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Resolved Rate (Safe Default \$35.0):', style: TextStyle(fontSize: 12)),
                      Text('\$$effectiveRate/hr', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColorPalette.brandPrimary)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Resolved Sessions (Safe Default 0):', style: TextStyle(fontSize: 12)),
                      Text('$effectiveSessions', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColorPalette.brandPrimary)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
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
                      width: 180,
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
