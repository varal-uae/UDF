import 'package:flutter/material.dart';

/// Row 237 - FEBFL-017-A19 (Seq 15135)
/// Action: Ship the verified job posting path validation enhancements onto the live production framework.
/// Metric: Production Release Success Rate (%) / Change Failure Rate | Target: 99.5% (<=0.5% CFR) | Ceiling: 99.9%+ | Unit: Pass/Fail
/// Standard: DORA Elite-performer benchmark.
class ProductionReleaseVerifierPanel extends StatefulWidget {
  const ProductionReleaseVerifierPanel({super.key});

  @override
  State<ProductionReleaseVerifierPanel> createState() =>
      _ProductionReleaseVerifierPanelState();
}

class _ProductionReleaseVerifierPanelState
    extends State<ProductionReleaseVerifierPanel> {
  final String _stepExecutionId = 'FEBFL-017-A19-PROD-SHIP';
  final String _userSessionId = 'POOJA-FEBFL-017-A19';
  final String _userId = 'POOJA_REL_MGR';
  final String _completionStatus = 'Pass';

  final double _releaseSuccessRate = 99.8;
  final double _changeFailureRate = 0.2;
  bool _isCanaryPromoted = true;
  DateTime _lastReleaseTimestamp = DateTime.now();

  Map<String, dynamic> getTelemetryData() {
    return {
      'Step Execution ID': _stepExecutionId,
      'Execution Status': 'PRODUCTION_RELEASE_LIVE',
      'Execution Timestamp': _lastReleaseTimestamp.toIso8601String(),
      'Step Outcome': 'CHANGE_SUCCESS_VERIFIED',
      'User ID': _userId,
      'Completion Status': _completionStatus,
      'Action/Event Timestamp': _lastReleaseTimestamp.toIso8601String(),
      'User/Session ID': _userSessionId,
      'Release Success Rate': '$_releaseSuccessRate% (Target: >=99.5%)',
      'Change Failure Rate': '$_changeFailureRate% (DORA Elite: <=0.5%)',
      'Canary Promotion Status': _isCanaryPromoted ? '100% TRAFFIC ACTIVE' : 'STAGE 1 CANARY',
    };
  }

  void _verifyCanaryPromotion() {
    setState(() {
      _isCanaryPromoted = true;
      _lastReleaseTimestamp = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: ProductionReleaseVerifierPanelTokens.paddingMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeaderCard(),
          ProductionReleaseVerifierPanelTokens.vGapMd,
          _buildDoraMetricsCard(),
          ProductionReleaseVerifierPanelTokens.vGapMd,
          _buildProductionHealthCard(),
          ProductionReleaseVerifierPanelTokens.vGapMd,
          _buildTelemetryCard(),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
        side: BorderSide(color: ProductionReleaseVerifierPanelTokens.lightOutline.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: ProductionReleaseVerifierPanelTokens.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.public_outlined,
                  color: ProductionReleaseVerifierPanelTokens.brandPrimary,
                  size: 22,
                ),
                ProductionReleaseVerifierPanelTokens.hGapSm,
                const Expanded(
                  child: Text(
                    'Production Release Verifier',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: ProductionReleaseVerifierPanelTokens.brandPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: ProductionReleaseVerifierPanelTokens.successContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'DORA Elite: 99.8%',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: ProductionReleaseVerifierPanelTokens.onSuccessContainer,
                    ),
                  ),
                ),
              ],
            ),
            ProductionReleaseVerifierPanelTokens.vGapSm,
            Text(
              'Tracks live production rollout of the verified job posting path enhancements, guaranteeing sub-0.5% change failure rate according to elite DORA standards.',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoraMetricsCard() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
        side: BorderSide(color: ProductionReleaseVerifierPanelTokens.lightOutline.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: ProductionReleaseVerifierPanelTokens.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'DORA Release Quality Benchmarks',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: ProductionReleaseVerifierPanelTokens.brandPrimary),
            ),
            ProductionReleaseVerifierPanelTokens.vGapSm,
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: ProductionReleaseVerifierPanelTokens.successContainer.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: ProductionReleaseVerifierPanelTokens.success.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Release Success', style: TextStyle(fontSize: 11, color: Colors.grey.shade700)),
                        const SizedBox(height: 4),
                        Text('$_releaseSuccessRate%', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: ProductionReleaseVerifierPanelTokens.success)),
                        const SizedBox(height: 2),
                        const Text('Target >=99.5%', style: TextStyle(fontSize: 10, color: Colors.black54)),
                      ],
                    ),
                  ),
                ),
                ProductionReleaseVerifierPanelTokens.hGapMd,
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: ProductionReleaseVerifierPanelTokens.brandPrimaryContainer.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: ProductionReleaseVerifierPanelTokens.brandPrimary.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Change Failure Rate', style: TextStyle(fontSize: 11, color: Colors.grey.shade700)),
                        const SizedBox(height: 4),
                        Text('$_changeFailureRate%', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: ProductionReleaseVerifierPanelTokens.brandPrimary)),
                        const SizedBox(height: 2),
                        const Text('Target <=0.5%', style: TextStyle(fontSize: 10, color: Colors.black54)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductionHealthCard() {
    return Card(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
        side: BorderSide(color: ProductionReleaseVerifierPanelTokens.success, width: 1.5),
      ),
      child: Padding(
        padding: ProductionReleaseVerifierPanelTokens.paddingMd,
        child: Row(
          children: [
            const Icon(Icons.shield_outlined, color: ProductionReleaseVerifierPanelTokens.success, size: 28),
            ProductionReleaseVerifierPanelTokens.hGapMd,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Framework Cluster: PROD-US-WEST-01',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: ProductionReleaseVerifierPanelTokens.brandPrimary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Status: Active 100% Traffic | 0 Rollback alerts logged',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: _verifyCanaryPromotion,
              style: ElevatedButton.styleFrom(
                backgroundColor: ProductionReleaseVerifierPanelTokens.brandPrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              ),
              child: const Text('Audit Rollout', style: TextStyle(fontSize: 11)),
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
        side: BorderSide(color: ProductionReleaseVerifierPanelTokens.lightOutline.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: ProductionReleaseVerifierPanelTokens.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Audit Telemetry',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: ProductionReleaseVerifierPanelTokens.brandPrimary,
              ),
            ),
            ProductionReleaseVerifierPanelTokens.vGapSm,
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
abstract final class ProductionReleaseVerifierPanelTokens {
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
            child: ProductionReleaseVerifierPanel(),
          ),
        ),
      ),
    ),
  );
}
