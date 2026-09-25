// SLPLU-015-A14 — Trace Time Line Chart Widget.
// Interactive Material 3 line chart visualizing lineage trace efficiency and system latency with a locked Y-axis, threshold demarcation, swipe-to-scrub, and red highlights for SLA breaches.

import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Mock data model representing a single trace time data point.
class TraceDataPoint {
  final DateTime timestamp;
  final double latencyMs;
  final String testType;
  final String testResult;
  final double testCoverage;
  final String testLogPath;

  const TraceDataPoint({
    required this.timestamp,
    required this.latencyMs,
    required this.testType,
    required this.testResult,
    required this.testCoverage,
    required this.testLogPath,
  });
}

/// Hardcoded mock data simulating BigQuery analytics output.
const double kSlaThresholdMs = 250.0;
const double kLockedYAxisMax = 500.0;

final List<TraceDataPoint> kMockTraceData = [
  TraceDataPoint(timestamp: DateTime(2026, 9, 25, 10, 0), latencyMs: 120.0, testType: 'Integration', testResult: 'Pass', testCoverage: 98.5, testLogPath: '/logs/int_001.log'),
  TraceDataPoint(timestamp: DateTime(2026, 9, 25, 10, 5), latencyMs: 145.0, testType: 'Unit', testResult: 'Pass', testCoverage: 99.1, testLogPath: '/logs/unit_002.log'),
  TraceDataPoint(timestamp: DateTime(2026, 9, 25, 10, 10), latencyMs: 210.0, testType: 'E2E', testResult: 'Pass', testCoverage: 96.2, testLogPath: '/logs/e2e_003.log'),
  TraceDataPoint(timestamp: DateTime(2026, 9, 25, 10, 15), latencyMs: 310.0, testType: 'Load', testResult: 'Fail', testCoverage: 94.0, testLogPath: '/logs/load_004.log'), // Breach
  TraceDataPoint(timestamp: DateTime(2026, 9, 25, 10, 20), latencyMs: 280.0, testType: 'Integration', testResult: 'Fail', testCoverage: 95.5, testLogPath: '/logs/int_005.log'), // Breach
  TraceDataPoint(timestamp: DateTime(2026, 9, 25, 10, 25), latencyMs: 190.0, testType: 'Unit', testResult: 'Pass', testCoverage: 99.8, testLogPath: '/logs/unit_006.log'),
  TraceDataPoint(timestamp: DateTime(2026, 9, 25, 10, 30), latencyMs: 160.0, testType: 'E2E', testResult: 'Pass', testCoverage: 97.3, testLogPath: '/logs/e2e_007.log'),
  TraceDataPoint(timestamp: DateTime(2026, 9, 25, 10, 35), latencyMs: 130.0, testType: 'Integration', testResult: 'Pass', testCoverage: 98.9, testLogPath: '/logs/int_008.log'),
];

/// A responsive, interactive line chart component for tracing API response times.
/// Implements Material 3 guidelines, locked Y-axis (Poka-Yoke), and mobile-first UX.
class TraceTimeLineChart extends StatefulWidget {
  final List<TraceDataPoint> data;
  final double thresholdMs;

  const TraceTimeLineChart({
    super.key,
    this.data = kMockTraceData,
    this.thresholdMs = kSlaThresholdMs,
  });

  @override
  State<TraceTimeLineChart> createState() => _TraceTimeLineChartState();
}

class _TraceTimeLineChartState extends State<TraceTimeLineChart> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  int? _scrubbedIndex;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animation = CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details, double chartWidth) {
    if (widget.data.isEmpty) return;
    final localX = details.localPosition.dx;
    final stepWidth = chartWidth / (widget.data.length - 1);
    int index = (localX / stepWidth).round();
    index = index.clamp(0, widget.data.length - 1);
    setState(() => _scrubbedIndex = index);
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    setState(() => _scrubbedIndex = null);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMediumOrLarger = constraints.maxWidth >= 600;

        return Card(
          elevation: 2,
          color: theme.colorScheme.surfaceContainerLow,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Subtitle locked to md.sys.typescale.body-medium
                Text(
                  'Trace Time Line Chart',
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'SLA Threshold: ${widget.thresholdMs.toStringAsFixed(0)}ms | Y-Axis Locked at ${kLockedYAxisMax.toStringAsFixed(0)}ms',
                  style: textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 16),
                
                // Two-column split layout for Medium size class views
                if (isMediumOrLarger)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: _buildChartArea(constraints.maxWidth * 0.7, theme)),
                      const SizedBox(width: 16),
                      Expanded(flex: 1, child: _buildHighlightPanel(theme)),
                    ],
                  )
                else
                  Column(
                    children: [
                      _buildChartArea(constraints.maxWidth, theme),
                      const SizedBox(height: 16),
                      _buildHighlightPanel(theme),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildChartArea(double availableWidth, ThemeData theme) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) => _onHorizontalDragUpdate(details, availableWidth),
      onHorizontalDragEnd: _onHorizontalDragEnd,
      child: SizedBox(
        height: 250,
        width: availableWidth,
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return CustomPaint(
              painter: _LineChartPainter(
                data: widget.data,
                threshold: widget.thresholdMs,
                maxY: kLockedYAxisMax,
                animationValue: _animation.value,
                scrubbedIndex: _scrubbedIndex,
                lineColor: theme.colorScheme.primary,
                thresholdColor: theme.colorScheme.error,
                gridColor: theme.colorScheme.outlineVariant.withOpacity(0.3),
                breachColor: theme.colorScheme.error,
                textColor: theme.colorScheme.onSurfaceVariant,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHighlightPanel(ThemeData theme) {
    final breachedCount = widget.data.where((d) => d.latencyMs > widget.thresholdMs).length;
    final passRate = ((widget.data.length - breachedCount) / widget.data.length) * 100;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('System Health', style: theme.textTheme.labelLarge),
          const SizedBox(height: 8),
          // Material 3 progress widget
          LinearProgressIndicator(
            value: passRate / 100,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            color: passRate >= 95 ? theme.colorScheme.primary : theme.colorScheme.error,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 8),
          Text(
            'Test Suite Pass Rate: ${passRate.toStringAsFixed(1)}%',
            style: theme.textTheme.bodyMedium,
          ),
          if (_scrubbedIndex != null && _scrubbedIndex! < widget.data.length) ...[
            const Divider(height: 24),
            Text('Scrubbed Point:', style: theme.textTheme.labelMedium),
            const SizedBox(height: 4),
            Text('Latency: ${widget.data[_scrubbedIndex!].latencyMs}ms', style: theme.textTheme.bodySmall),
            Text('Result: ${widget.data[_scrubbedIndex!].testResult}', style: theme.textTheme.bodySmall),
          ],
          if (breachedCount > 0) ...[
            const SizedBox(height: 12),
            // Context-aware alert banner condensed into crisp icon block
            Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: theme.colorScheme.error, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '$breachedCount SLA Breaches detected.',
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<TraceDataPoint> data;
  final double threshold;
  final double maxY;
  final double animationValue;
  final int? scrubbedIndex;
  final Color lineColor;
  final Color thresholdColor;
  final Color gridColor;
  final Color breachColor;
  final Color textColor;

  _LineChartPainter({
    required this.data,
    required this.threshold,
    required this.maxY,
    required this.animationValue,
    required this.scrubbedIndex,
    required this.lineColor,
    required this.thresholdColor,
    required this.gridColor,
    required this.breachColor,
    required this.textColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paddingLeft = 40.0;
    final paddingRight = 10.0;
    final paddingTop = 10.0;
    final paddingBottom = 30.0;

    final chartWidth = size.width - paddingLeft - paddingRight;
    final chartHeight = size.height - paddingTop - paddingBottom;

    final paintGrid = Paint()
      ..color = gridColor
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Draw horizontal grid lines
    for (int i = 0; i <= 4; i++) {
      final y = paddingTop + (chartHeight / 4) * i;
      canvas.drawLine(Offset(paddingLeft, y), Offset(size.width - paddingRight, y), paintGrid);
      
      // Y-axis labels (locked scale)
      final val = maxY - (maxY / 4) * i;
      final tp = TextPainter(
        text: TextSpan(text: '${val.toInt()}ms', style: TextStyle(color: textColor, fontSize: 10)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(0, y - tp.height / 2));
    }

    // Draw Threshold Line
    final thresholdY = paddingTop + chartHeight * (1 - (threshold / maxY));
    final paintThreshold = Paint()
      ..color = thresholdColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    // Dashed threshold line
    final dashWidth = 6.0;
    final dashSpace = 4.0;
    var startX = paddingLeft;
    while (startX < size.width - paddingRight) {
      canvas.drawLine(
        Offset(startX, thresholdY),
        Offset(math.min(startX + dashWidth, size.width - paddingRight), thresholdY),
        paintThreshold,
      );
      startX += dashWidth + dashSpace;
    }

    // Calculate points
    final points = <Offset>[];
    for (int i = 0; i < data.length; i++) {
      final x = paddingLeft + (i / (data.length - 1)) * chartWidth;
      final normalizedY = math.min(data[i].latencyMs / maxY, 1.0);
      final y = paddingTop + chartHeight * (1 - normalizedY);
      points.add(Offset(x, y));
    }

    // Apply animation to path drawing
    final animatedPoints = points.map((p) {
      return Offset(p.dx, paddingTop + chartHeight - (paddingTop + chartHeight - p.dy) * animationValue);
    }).toList();

    // Draw Line
    final paintLine = Paint()
      ..color = lineColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    final path = Path();
    if (animatedPoints.isNotEmpty) {
      path.moveTo(animatedPoints.first.dx, animatedPoints.first.dy);
      for (var point in animatedPoints.skip(1)) {
        path.lineTo(point.dx, point.dy);
      }
    }
    canvas.drawPath(path, paintLine);

    // Draw Data Points & Highlights
    for (int i = 0; i < animatedPoints.length; i++) {
      final isBreach = data[i].latencyMs > threshold;
      final isScrubbed = i == scrubbedIndex;
      
      final pointPaint = Paint()
        ..color = isBreach ? breachColor : lineColor
        ..style = PaintingStyle.fill;

      final radius = isScrubbed ? 6.0 : 4.0;
      canvas.drawCircle(animatedPoints[i], radius, pointPaint);

      if (isScrubbed) {
        final scrubPaint = Paint()
          ..color = lineColor.withOpacity(0.2)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(animatedPoints[i], 12.0, scrubPaint);
      }

      // X-axis labels
      if (i % math.max(1, (data.length / 5).floor()) == 0 || i == data.length - 1) {
        final timeStr = '${data[i].timestamp.hour.toString().padLeft(2, '0')}:${data[i].timestamp.minute.toString().padLeft(2, '0')}';
        final tp = TextPainter(
          text: TextSpan(text: timeStr, style: TextStyle(color: textColor, fontSize: 10)),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(animatedPoints[i].dx - tp.width / 2, size.height - paddingBottom + 8));
      }
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.scrubbedIndex != scrubbedIndex ||
        oldDelegate.data != data;
  }
}