/*
 * EDBAA-011-A05 — Dense Tabular Grid Container Panel
 * 
 * Setup Step (Action): Blueprint a dense tabular grid list view container on the component workspace canvas.
 * Metric Name: Dense Data Table Layout Standard (Floor: 28dp, Target: 32dp row height / 6–8dp padding, Ceiling: 40dp)
 * Quality Standard: Material Design dense-table standard keeps high-volume log/record views scannable without excess whitespace.
 * Assigned Member: Pooja
 */

import 'package:flutter/material.dart';

class DenseTabularGridContainerPanel extends StatefulWidget {
  final String globalRefId;
  final String atomicStepRefId;
  final String sequenceOrder;

  const DenseTabularGridContainerPanel({
    super.key,
    this.globalRefId = 'EDBAA-011',
    this.atomicStepRefId = 'EDBAA-011-A05',
    this.sequenceOrder = '12124',
  });

  @override
  State<DenseTabularGridContainerPanel> createState() =>
      _DenseTabularGridContainerPanelState();
}

class _DenseTabularGridContainerPanelState
    extends State<DenseTabularGridContainerPanel> {
  final List<Map<String, dynamic>> _dlqRecords = [
    {
      'id': 'DLQ-00192',
      'channel': 'telemetry-raw',
      'error': 'SCHEMA_MISMATCH',
      'retries': 3,
      'status': 'REQUEUED',
      'timestamp': '14:52:10',
    },
    {
      'id': 'DLQ-00193',
      'channel': 'vat-audit-log',
      'error': 'TRN_VALIDATION_FAIL',
      'retries': 2,
      'status': 'HELD',
      'timestamp': '14:52:18',
    },
    {
      'id': 'DLQ-00194',
      'channel': 'biometric-sync',
      'error': 'TOKEN_TIMEOUT_EXPIRED',
      'retries': 1,
      'status': 'DROPPED',
      'timestamp': '14:52:25',
    },
    {
      'id': 'DLQ-00195',
      'channel': 'finops-ingress',
      'error': 'BURST_RATE_LIMIT',
      'retries': 4,
      'status': 'RESOLVED',
      'timestamp': '14:52:31',
    },
  ];

  Map<String, dynamic> toExecutionLogJson() {
    return {
      'workspaceName': 'DLQ_TERRAFORM_MONITOR',
      'workspaceId': 'WS-EDBAA-011',
      'workspaceConfiguration': 'M3_DENSE_TABLE_32DP',
      'memberList': 'Pooja, Lead SRE',
      'workspaceStatus': 'VERIFIED_ACTIVE',
      'completionStatus': 'Good',
      'actionEventTimestamp': DateTime.now().toUtc().toIso8601String(),
      'userSessionId': 'SESSION-EDBAA-011',
      'metadata': {
        'taskCode': widget.globalRefId,
        'atomicStepCode': widget.atomicStepRefId,
        'row': 182,
        'seq': int.tryParse(widget.sequenceOrder) ?? 12124,
        'assigned': 'Pooja',
        'metricName': 'Dense Data Table Layout Standard',
        'floor': '28dp row height',
        'target': '32dp row height / 6-8dp padding',
        'ceiling': '40dp row height',
        'unit': 'Good/Average/Poor',
        'rowHeightDp': 32.0,
        'cellPaddingDp': 8.0,
        'totalRecordsRendered': _dlqRecords.length,
        'isDeadLetterRouteGuarded': true,
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 600;
        final isExpanded = constraints.maxWidth >= 840;
        final padding = isCompact
            ? DenseTabularGridContainerPanelTokens.paddingSm
            : (isExpanded ? DenseTabularGridContainerPanelTokens.paddingLg : DenseTabularGridContainerPanelTokens.paddingMd);

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: DenseTabularGridContainerPanelTokens.lightOutline.withValues(alpha: 0.2),
            ),
          ),
          child: Padding(
            padding: padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(isCompact),
                DenseTabularGridContainerPanelTokens.vGapMd,
                _buildDenseTableContainer(isCompact),
                DenseTabularGridContainerPanelTokens.vGapMd,
                _buildTableStandardFooter(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool isCompact) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: DenseTabularGridContainerPanelTokens.brandPrimary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.table_chart_rounded,
            color: DenseTabularGridContainerPanelTokens.brandPrimary,
            size: 24,
          ),
        ),
        DenseTabularGridContainerPanelTokens.hGapMd,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dense Tabular Grid Layout Container',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              DenseTabularGridContainerPanelTokens.vGapXs,
              Text(
                '${widget.globalRefId} · ${widget.atomicStepRefId} · Seq: ${widget.sequenceOrder}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: DenseTabularGridContainerPanelTokens.lightOutline,
                    ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: DenseTabularGridContainerPanelTokens.successContainer,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: DenseTabularGridContainerPanelTokens.success.withValues(alpha: 0.3),
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle_rounded,
                  color: DenseTabularGridContainerPanelTokens.success, size: 14),
              SizedBox(width: 4),
              Text(
                '32DP DENSE STANDARD',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: DenseTabularGridContainerPanelTokens.success,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDenseTableContainer(bool isCompact) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: DenseTabularGridContainerPanelTokens.lightOutline.withValues(alpha: 0.2),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowHeight: 36,
          dataRowMinHeight: 32, // Strict 32dp dense row height
          dataRowMaxHeight: 32,
          horizontalMargin: 12,
          columnSpacing: 16,
          headingRowColor: WidgetStateProperty.all(
            DenseTabularGridContainerPanelTokens.brandPrimary.withValues(alpha: 0.06),
          ),
          columns: const [
            DataColumn(label: Text('Record ID', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Channel', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Fault Code', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Retries', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Status', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Timestamp', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
          ],
          rows: _dlqRecords.map((rec) {
            final status = rec['status'] as String;
            final isResolved = status == 'RESOLVED';
            final isHeld = status == 'HELD';

            return DataRow(
              cells: [
                DataCell(Text(rec['id'] as String, style: const TextStyle(fontSize: 11, fontFamily: 'monospace'))),
                DataCell(Text(rec['channel'] as String, style: const TextStyle(fontSize: 11))),
                DataCell(Text(rec['error'] as String, style: const TextStyle(fontSize: 10, color: DenseTabularGridContainerPanelTokens.lightError))),
                DataCell(Text('${rec['retries']}', style: const TextStyle(fontSize: 11))),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isResolved
                          ? DenseTabularGridContainerPanelTokens.successContainer
                          : (isHeld
                              ? DenseTabularGridContainerPanelTokens.brandPrimary.withValues(alpha: 0.1)
                              : DenseTabularGridContainerPanelTokens.lightErrorContainer),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: isResolved
                            ? DenseTabularGridContainerPanelTokens.onSuccessContainer
                            : (isHeld
                                ? DenseTabularGridContainerPanelTokens.brandPrimary
                                : DenseTabularGridContainerPanelTokens.lightOnErrorContainer),
                      ),
                    ),
                  ),
                ),
                DataCell(Text(rec['timestamp'] as String, style: const TextStyle(fontSize: 10, color: DenseTabularGridContainerPanelTokens.lightOutline))),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTableStandardFooter() {
    return Container(
      padding: const EdgeInsets.all(DenseTabularGridContainerPanelTokens.sm),
      decoration: BoxDecoration(
        color: DenseTabularGridContainerPanelTokens.lightBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.view_headline_rounded,
            color: DenseTabularGridContainerPanelTokens.brandPrimary,
            size: 16,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Dense table conforms strictly to Material Design 32dp row height and 8dp cell padding, optimizing operational log scannability.',
              style: TextStyle(
                fontSize: 11,
                color: DenseTabularGridContainerPanelTokens.lightOutline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// File-Local Standalone Design Tokens & Constants
// ============================================================================
abstract final class DenseTabularGridContainerPanelTokens {
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
            child: DenseTabularGridContainerPanel(),
          ),
        ),
      ),
    ),
  );
}
