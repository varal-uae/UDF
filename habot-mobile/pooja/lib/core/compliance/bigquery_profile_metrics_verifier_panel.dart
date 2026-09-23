import 'package:flutter/material.dart';

/// Row 254 - FIEVR-005-A17 (Seq 15462)
/// Action: Verify that profile records reflect target metrics inside BigQuery datasets post-execution.
/// Metric: First-Pass Validation Success (%) | Target: 99% | Ceiling: 100% | Unit: Pass/Fail
/// Standard: Independent validation checkpoints in mature delivery pipelines before sign-off.
class BigQueryProfileMetricsVerifierPanel extends StatefulWidget {
  const BigQueryProfileMetricsVerifierPanel({super.key});

  @override
  State<BigQueryProfileMetricsVerifierPanel> createState() =>
      _BigQueryProfileMetricsVerifierPanelState();
}

class _ProfileMetricRecord {
  final String metricField;
  final String expectedTarget;
  final String actualBigQueryValue;
  final bool isVerified;

  const _ProfileMetricRecord({
    required this.metricField,
    required this.expectedTarget,
    required this.actualBigQueryValue,
    required this.isVerified,
  });
}

class _BigQueryProfileMetricsVerifierPanelState
    extends State<BigQueryProfileMetricsVerifierPanel> {
  final String _stepExecutionId = 'FIEVR-005-A17-BQ-VERIFY';
  final String _userSessionId = 'POOJA-FIEVR-005-A17';
  final String _userId = 'POOJA_DATA_AUDIT';
  final String _completionStatus = 'Pass';
  final String _dataset = 'habot_enterprise_analytics.profile_metrics_v2';

  final List<_ProfileMetricRecord> _metrics = const [
    _ProfileMetricRecord(
      metricField: 'profile_completion_rate',
      expectedTarget: '>= 95.0%',
      actualBigQueryValue: '99.4%',
      isVerified: true,
    ),
    _ProfileMetricRecord(
      metricField: 'form_bounce_error_rate',
      expectedTarget: '< 2.0%',
      actualBigQueryValue: '0.42%',
      isVerified: true,
    ),
    _ProfileMetricRecord(
      metricField: 'post_execution_sync_latency',
      expectedTarget: '< 500ms',
      actualBigQueryValue: '184ms',
      isVerified: true,
    ),
    _ProfileMetricRecord(
      metricField: 'mandatory_field_coverage',
      expectedTarget: '100.0%',
      actualBigQueryValue: '100.0%',
      isVerified: true,
    ),
  ];

  final DateTime _lastAuditTimestamp = DateTime.now();

  Map<String, dynamic> getTelemetryData() {
    return {
      'Step Execution ID': _stepExecutionId,
      'Execution Status': 'BIGQUERY_METRICS_AUDITED',
      'Execution Timestamp': _lastAuditTimestamp.toIso8601String(),
      'Step Outcome': 'FIRST_PASS_VALIDATION_PASSED',
      'User ID': _userId,
      'Completion Status': _completionStatus,
      'Action/Event Timestamp': _lastAuditTimestamp.toIso8601String(),
      'User/Session ID': _userSessionId,
      'Dataset Path': _dataset,
      'Validation Success Rate': '99.4% (Target: ≥99%)',
      'Verified Metric Records': _metrics.length,
    };
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: BigqueryProfileMetricsVerifierPanelTokens.paddingMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeaderCard(),
          BigqueryProfileMetricsVerifierPanelTokens.vGapMd,
          _buildDatasetHeaderCard(),
          BigqueryProfileMetricsVerifierPanelTokens.vGapMd,
          _buildMetricsTableCard(),
          BigqueryProfileMetricsVerifierPanelTokens.vGapMd,
          _buildTelemetryCard(),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
        side: BorderSide(color: BigqueryProfileMetricsVerifierPanelTokens.lightOutline.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: BigqueryProfileMetricsVerifierPanelTokens.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.table_chart_outlined,
                  color: BigqueryProfileMetricsVerifierPanelTokens.brandPrimary,
                  size: 22,
                ),
                BigqueryProfileMetricsVerifierPanelTokens.hGapSm,
                const Expanded(
                  child: Text(
                    'BigQuery Profile Metrics Verifier',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: BigqueryProfileMetricsVerifierPanelTokens.brandPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: BigqueryProfileMetricsVerifierPanelTokens.successContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Target: 99% (Pass)',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: BigqueryProfileMetricsVerifierPanelTokens.onSuccessContainer,
                    ),
                  ),
                ),
              ],
            ),
            BigqueryProfileMetricsVerifierPanelTokens.vGapSm,
            Text(
              'Audits synchronized user profile records inside persistent BigQuery analytical datasets post-execution to confirm first-pass validation compliance.',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatasetHeaderCard() {
    return Card(
      elevation: 1,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
        side: BorderSide(color: BigqueryProfileMetricsVerifierPanelTokens.success, width: 1.5),
      ),
      child: Padding(
        padding: BigqueryProfileMetricsVerifierPanelTokens.paddingMd,
        child: Row(
          children: [
            const Icon(Icons.cloud_done_outlined, color: BigqueryProfileMetricsVerifierPanelTokens.success, size: 28),
            BigqueryProfileMetricsVerifierPanelTokens.hGapMd,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('BigQuery Stream: SYNC_CONFIRMED', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: BigqueryProfileMetricsVerifierPanelTokens.brandPrimary)),
                  const SizedBox(height: 2),
                  Text('Dataset: $_dataset', style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontFamily: 'monospace')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsTableCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
        side: BorderSide(color: BigqueryProfileMetricsVerifierPanelTokens.lightOutline.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: BigqueryProfileMetricsVerifierPanelTokens.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Verified Metrics Registry (Post-Execution)',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: BigqueryProfileMetricsVerifierPanelTokens.brandPrimary),
            ),
            BigqueryProfileMetricsVerifierPanelTokens.vGapSm,
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _metrics.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = _metrics[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.verified, color: BigqueryProfileMetricsVerifierPanelTokens.success, size: 18),
                  title: Text(item.metricField, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, fontFamily: 'monospace')),
                  subtitle: Text('Target: ${item.expectedTarget} | Actual: ${item.actualBigQueryValue}', style: TextStyle(fontSize: 11, color: Colors.grey.shade700)),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: BigqueryProfileMetricsVerifierPanelTokens.successContainer,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('PASSED', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: BigqueryProfileMetricsVerifierPanelTokens.onSuccessContainer)),
                  ),
                );
              },
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
        side: BorderSide(color: BigqueryProfileMetricsVerifierPanelTokens.lightOutline.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: BigqueryProfileMetricsVerifierPanelTokens.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Audit Telemetry',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: BigqueryProfileMetricsVerifierPanelTokens.brandPrimary,
              ),
            ),
            BigqueryProfileMetricsVerifierPanelTokens.vGapSm,
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
abstract final class BigqueryProfileMetricsVerifierPanelTokens {
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
            child: BigQueryProfileMetricsVerifierPanel(),
          ),
        ),
      ),
    ),
  );
}
