// PELCE-036-06 — TC Pass Rate Auto-Freeze Thresholds Widget.
// Displays a percentage indicator with a 7-day sparkline trend in minimal vertical space, using Material 3 design tokens and mock execution data.

import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Mock data model representing atomic-level step execution fields.
class StepExecutionRecord {
  final String stepExecutionId;
  final String executionStatus;
  final DateTime executionTimestamp;
  final String stepOutcome;
  final String userId;
  final String completionStatus;

  const StepExecutionRecord({
    required this.stepExecutionId,
    required this.executionStatus,
    required this.executionTimestamp,
    required this.stepOutcome,
    required this.userId,
    required this.completionStatus,
  });
}

/// Hardcoded realistic local mock data for the 7-day trend.
const List<StepExecutionRecord> _mockExecutionData = [
  StepExecutionRecord(stepExecutionId: 'EXE-001', executionStatus: 'Passed', executionTimestamp: null, stepOutcome: 'Success', userId: 'USR-101', completionStatus: 'Good'),
  StepExecutionRecord(stepExecutionId: 'EXE-002', executionStatus: 'Passed', executionTimestamp: null, stepOutcome: 'Success', userId: 'USR-102', completionStatus: 'Good'),
  StepExecutionRecord(stepExecutionId: 'EXE-003', executionStatus: 'Failed', executionTimestamp: null, stepOutcome: 'Error', userId: 'USR-101', completionStatus: 'Poor'),
  StepExecutionRecord(stepExecutionId: 'EXE-004', executionStatus: 'Passed', executionTimestamp: null, stepOutcome: 'Success', userId: 'USR-103', completionStatus: 'Good'),
  StepExecutionRecord(stepExecutionId: 'EXE-005', executionStatus: 'Passed', executionTimestamp: null, stepOutcome: 'Success', userId: 'USR-104', completionStatus: 'Average'),
];

/// Simulated 7-day pass rate percentages for the sparkline.
const List<double> _mockSevenDayTrend = [91.0, 93.5, 89.0, 95.2, 97.1, 98.0, 98.5];

class TcPassRateAutoFreezeThresholdsPelce03606 extends StatefulWidget {
  const TcPassRateAutoFreezeThresholdsPelce03606({super.key});

  @override
  State<TcPassRateAutoFreezeThresholdsPelce03606> createState() => _TcPassRateAutoFreezeThresholdsPelce03606State();
}

class _TcPassRateAutoFreezeThresholdsPelce03606State extends State<TcPassRateAutoFreezeThresholdsPelce03606> with SingleTickerProviderStateMixin {
  late final AnimationController _fadeController;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  double get _currentPassRate => _mockSevenDayTrend.last;

  String get _qualitativeOutput {
    if (_currentPassRate >= 98.0) return 'Good';
    if (_currentPassRate >= 90.0) return 'Average';
    return 'Poor';
  }

  Color _getStatusColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (_currentPassRate >= 98.0) return colorScheme.primary;
    if (_currentPassRate >= 90.0) return colorScheme.tertiary;
    return colorScheme.error;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final statusColor = _getStatusColor(context);

    return FadeTransition(
      opacity: _fadeController,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
          side: BorderSide(color: statusColor.withOpacity(0.5), width: 2.0),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: InkWell(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          borderRadius: BorderRadius.circular(16.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.shield_outlined, color: statusColor, size: 24),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Process Execution Quality Score',
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${_currentPassRate.toStringAsFixed(1)}%',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 64,
                          height: 24,
                          child: CustomPaint(
                            painter: _SparklinePainter(data: _mockSevenDayTrend, lineColor: statusColor),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildChip(theme, _qualitativeOutput, statusColor),
                    const SizedBox(width: 8),
                    Text(
                      'ISO 9001:2015',
                      style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: _buildExpandedDetails(theme, colorScheme),
                  crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 300),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChip(ThemeData theme, String label, Color color) {
    return Chip(
      label: Text(label, style: theme.textTheme.labelSmall?.copyWith(color: color)),
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide.none,
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildExpandedDetails(ThemeData theme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(color: colorScheme.outlineVariant, thickness: 1),
          const SizedBox(height: 8),
          Text('Threshold Boundaries', style: theme.textTheme.labelLarge),
          const SizedBox(height: 8),
          _buildMetricRow(theme, 'Floor Boundary', '≥90%'),
          _buildMetricRow(theme, 'Optimal Target', '≥98%'),
          _buildMetricRow(theme, 'Ceiling Boundary', '100%'),
          const SizedBox(height: 16),
          Text('Recent Executions (Mock Data)', style: theme.textTheme.labelLarge),
          const SizedBox(height: 8),
          ..._mockExecutionData.map((record) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(record.stepExecutionId, style: theme.textTheme.bodyMedium),
                Text(record.completionStatus, style: theme.textTheme.bodyMedium?.copyWith(
                  color: record.completionStatus == 'Good' ? colorScheme.primary : colorScheme.error,
                  fontWeight: FontWeight.w600,
                )),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildMetricRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          Text(value, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> data;
  final Color lineColor;

  _SparklinePainter({required this.data, required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final maxVal = data.reduce(math.max);
    final minVal = data.reduce(math.min);
    final range = maxVal - minVal == 0 ? 1.0 : maxVal - minVal;

    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final y = size.height - ((data[i] - minVal) / range) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}