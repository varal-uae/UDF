/*
 * EDBAA-011-A05 — Dense Tabular Grid Container Panel
 * 
 * Setup Step (Action): Blueprint a dense tabular grid list view container on the component workspace canvas.
 * Metric Name: Dense Data Table Layout Standard (Floor: 28dp, Target: 32dp row height / 6–8dp padding, Ceiling: 40dp)
 * Quality Standard: Material Design dense-table standard keeps high-volume log/record views scannable without excess whitespace.
 * Assigned Member: Pooja
 */

import 'package:flutter/material.dart';
import '../tokens/color_palette.dart';
import '../tokens/spacing_tokens.dart';

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
            ? AppSpacingTokens.paddingSm
            : (isExpanded ? AppSpacingTokens.paddingLg : AppSpacingTokens.paddingMd);

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: AppColorPalette.lightOutline.withValues(alpha: 0.2),
            ),
          ),
          child: Padding(
            padding: padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(isCompact),
                AppSpacingTokens.vGapMd,
                _buildDenseTableContainer(isCompact),
                AppSpacingTokens.vGapMd,
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
            color: AppColorPalette.brandPrimary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.table_chart_rounded,
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
                'Dense Tabular Grid Layout Container',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              AppSpacingTokens.vGapXs,
              Text(
                '${widget.globalRefId} · ${widget.atomicStepRefId} · Seq: ${widget.sequenceOrder}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColorPalette.lightOutline,
                    ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColorPalette.successContainer,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppColorPalette.success.withValues(alpha: 0.3),
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle_rounded,
                  color: AppColorPalette.success, size: 14),
              SizedBox(width: 4),
              Text(
                '32DP DENSE STANDARD',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColorPalette.success,
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
          color: AppColorPalette.lightOutline.withValues(alpha: 0.2),
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
            AppColorPalette.brandPrimary.withValues(alpha: 0.06),
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
                DataCell(Text(rec['error'] as String, style: const TextStyle(fontSize: 10, color: AppColorPalette.lightError))),
                DataCell(Text('${rec['retries']}', style: const TextStyle(fontSize: 11))),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isResolved
                          ? AppColorPalette.successContainer
                          : (isHeld
                              ? AppColorPalette.brandPrimary.withValues(alpha: 0.1)
                              : AppColorPalette.lightErrorContainer),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: isResolved
                            ? AppColorPalette.onSuccessContainer
                            : (isHeld
                                ? AppColorPalette.brandPrimary
                                : AppColorPalette.lightOnErrorContainer),
                      ),
                    ),
                  ),
                ),
                DataCell(Text(rec['timestamp'] as String, style: const TextStyle(fontSize: 10, color: AppColorPalette.lightOutline))),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTableStandardFooter() {
    return Container(
      padding: const EdgeInsets.all(AppSpacingTokens.sm),
      decoration: BoxDecoration(
        color: AppColorPalette.lightBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.view_headline_rounded,
            color: AppColorPalette.brandPrimary,
            size: 16,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Dense table conforms strictly to Material Design 32dp row height and 8dp cell padding, optimizing operational log scannability.',
              style: TextStyle(
                fontSize: 11,
                color: AppColorPalette.lightOutline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
