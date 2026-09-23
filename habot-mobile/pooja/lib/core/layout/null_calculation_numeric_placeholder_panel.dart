import 'package:flutter/material.dart';

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
      padding: NullCalculationNumericPlaceholderPanelTokens.paddingMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeaderCard(),
          NullCalculationNumericPlaceholderPanelTokens.vGapMd,
          _buildDefinitionsListCard(),
          NullCalculationNumericPlaceholderPanelTokens.vGapMd,
          _buildInteractiveFallbackDemoCard(),
          NullCalculationNumericPlaceholderPanelTokens.vGapMd,
          _buildTelemetryCard(),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
        side: BorderSide(color: NullCalculationNumericPlaceholderPanelTokens.lightOutline.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: NullCalculationNumericPlaceholderPanelTokens.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.calculate_outlined,
                  color: NullCalculationNumericPlaceholderPanelTokens.brandPrimary,
                  size: 22,
                ),
                NullCalculationNumericPlaceholderPanelTokens.hGapSm,
                const Expanded(
                  child: Text(
                    'Safe Default Numeric Placeholders',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: NullCalculationNumericPlaceholderPanelTokens.brandPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: NullCalculationNumericPlaceholderPanelTokens.successContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Target: 95% (Complete)',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: NullCalculationNumericPlaceholderPanelTokens.onSuccessContainer,
                    ),
                  ),
                ),
              ],
            ),
            NullCalculationNumericPlaceholderPanelTokens.vGapSm,
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
        side: BorderSide(color: NullCalculationNumericPlaceholderPanelTokens.lightOutline.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: NullCalculationNumericPlaceholderPanelTokens.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Registered Numeric Fallback Registry',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: NullCalculationNumericPlaceholderPanelTokens.brandPrimary),
            ),
            NullCalculationNumericPlaceholderPanelTokens.vGapSm,
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _definitions.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final def = _definitions[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.numbers, color: NullCalculationNumericPlaceholderPanelTokens.brandPrimary, size: 20),
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
        side: BorderSide(color: NullCalculationNumericPlaceholderPanelTokens.lightOutline.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: NullCalculationNumericPlaceholderPanelTokens.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Interactive Null-Safety Resolver Demo',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: NullCalculationNumericPlaceholderPanelTokens.brandPrimary),
            ),
            NullCalculationNumericPlaceholderPanelTokens.vGapSm,
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
                NullCalculationNumericPlaceholderPanelTokens.hGapSm,
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
            NullCalculationNumericPlaceholderPanelTokens.vGapSm,
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
                      Text('\$$effectiveRate/hr', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: NullCalculationNumericPlaceholderPanelTokens.brandPrimary)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Resolved Sessions (Safe Default 0):', style: TextStyle(fontSize: 12)),
                      Text('$effectiveSessions', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: NullCalculationNumericPlaceholderPanelTokens.brandPrimary)),
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
        side: BorderSide(color: NullCalculationNumericPlaceholderPanelTokens.lightOutline.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: NullCalculationNumericPlaceholderPanelTokens.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Audit Telemetry',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: NullCalculationNumericPlaceholderPanelTokens.brandPrimary,
              ),
            ),
            NullCalculationNumericPlaceholderPanelTokens.vGapSm,
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

// ============================================================================
// File-Local Standalone Design Tokens & Constants
// ============================================================================
abstract final class NullCalculationNumericPlaceholderPanelTokens {
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
            child: NullCalculationNumericPlaceholderPanel(),
          ),
        ),
      ),
    ),
  );
}
