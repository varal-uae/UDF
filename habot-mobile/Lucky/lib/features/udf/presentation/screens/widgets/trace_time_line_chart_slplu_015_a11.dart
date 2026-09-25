// SLPLU-015-A11 — Trace Time Line Chart Widget.
// Interactive line chart visualizing step execution latency over time with a locked Y-axis, threshold demarcation, and red highlights for SLA breaches. Includes mock data and mobile-first Material 3 design adaptations.

import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Mock data model representing a single trace execution point.
class TraceExecutionData {
  final String stepExecutionId;
  final DateTime timestamp;
  final double latencyMs;
  final String status;
  final String outcome;
  final String userId;

  const TraceExecutionData({
    required this.stepExecutionId,
    required this.timestamp,
    required this.latencyMs,
    required this.status,
    required this.outcome,
    required this.userId,
  });
}

/// Hardcoded realistic mock data simulating BigQuery output for local rendering.
const List<TraceExecutionData> kMockTraceData = [
  TraceExecutionData(stepExecutionId: 'EXE-001', timestamp: DateTime(2026, 9, 25, 8, 0), latencyMs: 120.5, status: 'SUCCESS', outcome: 'COMPLETED', userId: 'USR-101'),
  TraceExecutionData(stepExecutionId: 'EXE-002', timestamp: DateTime(2026, 9, 25, 8, 15), latencyMs: 145.2, status: 'SUCCESS', outcome: 'COMPLETED', userId: 'USR-102'),
  TraceExecutionData(stepExecutionId: 'EXE-003', timestamp: DateTime(2026, 9, 25, 8, 30), latencyMs: 310.8, status: 'WARNING', outcome: 'SLOW', userId: 'USR-101'), // Breach
  TraceExecutionData(stepExecutionId: 'EXE-004', timestamp: DateTime(2026, 9, 25, 8, 45), latencyMs: 115.0, status: 'SUCCESS', outcome: 'COMPLETED', userId: 'USR-103'),
  TraceExecutionData(stepExecutionId: 'EXE-005', timestamp: DateTime(2026, 9, 25, 9, 0), latencyMs: 130.4, status: 'SUCCESS', outcome: 'COMPLETED', userId: 'USR-102'),
  TraceExecutionData(stepExecutionId: 'EXE-006', timestamp: DateTime(2026, 9, 25, 9, 15), latencyMs: 450.9, status: 'ERROR', outcome: 'TIMEOUT', userId: 'USR-104'), // Breach
  TraceExecutionData(stepExecutionId: 'EXE-007', timestamp: DateTime(2026, 9, 25, 9, 30), latencyMs: 125.1, status: 'SUCCESS', outcome: 'COMPLETED', userId: 'USR-101'),
  TraceExecutionData(stepExecutionId: 'EXE-008', timestamp: DateTime(2026, 9, 25, 9, 45), latencyMs: 140.0, status: 'SUCCESS', outcome: 'COMPLETED', userId: 'USR-105'),
];

/// The acceptable SLA threshold in milliseconds.
const double kSlaThresholdMs = 250.0;

/// Locked maximum Y-axis value to prevent users from zooming out to hide spikes (Poka-Yoke).
const double kLockedMaxY = 500.0;

class TraceTimeLineChart extends StatefulWidget {
  final List<TraceExecutionData> data;
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
  late Animation<double> _drawAnimation;
  int? _scrubbedIndex;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _drawAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    );
    _animationController.forward();
  }

  @override
  void didUpdateWidget(covariant TraceTimeLineChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details, BoxConstraints constraints) {
    final double dx = details.localPosition.dx;
    final double chartWidth = constraints.maxWidth - 60; // Account for padding/axes
    final double relativeX = (dx - 40).clamp(0.0, chartWidth);
    
    if (widget.data.isEmpty) return;

    final int index = ((relativeX / chartWidth) * (widget.data.length - 1)).round();
    setState(() {
      _scrubbedIndex = index.clamp(0, widget.data.length - 1);
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    setState(() {
      _scrubbedIndex = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;

    return Card(
      elevation: 2.0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Subtitle displays lock to standard text scaling guidelines (md.sys.typescale.body-medium)
            Text(
              'Trace Time Lineage Efficiency',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4.0),
            Text(
              'Latency over time (SLA Threshold: ${widget.thresholdMs.toStringAsFixed(0)}ms)',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16.0),
            SizedBox(
              height: 250.0,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return GestureDetector(
                    onHorizontalDragUpdate: (details) => _onHorizontalDragUpdate(details, constraints),
                    onHorizontalDragEnd: _onHorizontalDragEnd,
                    child: AnimatedBuilder(
                      animation: _drawAnimation,
                      builder: (context, child) {
                        return CustomPaint(
                          size: Size(constraints.maxWidth, constraints.maxHeight),
                          painter: _TraceChartPainter(
                            data: widget.data,
                            thresholdMs: widget.thresholdMs,
                            maxY: kLockedMaxY,
                            animationValue: _drawAnimation.value,
                            scrubbedIndex: _scrubbedIndex,
                            lineColor: colorScheme.primary,
                            breachColor: colorScheme.error,
                            thresholdColor: colorScheme.tertiary,
                            gridColor: colorScheme.outlineVariant.withOpacity(0.3),
                            textColor: colorScheme.onSurfaceVariant,
                            tooltipBg: colorScheme.surfaceContainerHighest,
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            if (_scrubbedIndex != null && _scrubbedIndex! < widget.data.length) ...[
              const SizedBox(height: 12.0),
              // Context-aware alert banners condense gracefully into crisp icon blocks on narrow phone screen limits
              _buildScrubInfoBanner(theme, widget.data[_scrubbedIndex!]),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildScrubInfoBanner(ThemeData theme, TraceExecutionData point) {
    final bool isBreach = point.latencyMs > widget.thresholdMs;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: isBreach ? theme.colorScheme.errorContainer : theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        children: [
          Icon(
            isBreach ? Icons.warning_amber_rounded : Icons.info_outline_rounded,
            size: 18.0,
            color: isBreach ? theme.colorScheme.onErrorContainer : theme.colorScheme.onSecondaryContainer,
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              '${point.timestamp.hour.toString().padLeft(2, '0')}:${point.timestamp.minute.toString().padLeft(2, '0')} | ${point.latencyMs.toStringAsFixed(1)}ms | ${point.status}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: isBreach ? theme.colorScheme.onErrorContainer : theme.colorScheme.onSecondaryContainer,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _TraceChartPainter extends CustomPainter {
  final List<TraceExecutionData> data;
  final double thresholdMs;
  final double maxY;
  final double animationValue;
  final int? scrubbedIndex;
  final Color lineColor;
  final Color breachColor;
  final Color thresholdColor;
  final Color gridColor;
  final Color textColor;
  final Color tooltipBg;

  _TraceChartPainter({
    required this.data,
    required this.thresholdMs,
    required this.maxY,
    required this.animationValue,
    required this.scrubbedIndex,
    required this.lineColor,
    required this.breachColor,
    required this.thresholdColor,
    required this.gridColor,
    required this.textColor,
    required this.tooltipBg,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final double leftPadding = 40.0;
    final double rightPadding = 10.0;
    final double topPadding = 10.0;
    final double bottomPadding = 30.0;

    final double chartWidth = size.width - leftPadding - rightPadding;
    final double chartHeight = size.height - topPadding - bottomPadding;

    final Paint gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final Paint thresholdPaint = Paint()
      ..color = thresholdColor
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..pathEffect = PathEffect.dashPath(
        const DashPathEffect([6.0, 4.0], 0.0),
      );

    final TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    // Draw horizontal grid lines & Y-axis labels (Locked scale)
    const int yDivisions = 5;
    for (int i = 0; i <= yDivisions; i++) {
      final double yVal = (maxY / yDivisions) * i;
      final double yPos = topPadding + chartHeight - (yVal / maxY) * chartHeight;
      
      canvas.drawLine(
        Offset(leftPadding, yPos),
        Offset(leftPadding + chartWidth, yPos),
        gridPaint,
      );

      textPainter.text = TextSpan(
        text: yVal.toStringAsFixed(0),
        style: TextStyle(color: textColor, fontSize: 10.0),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(leftPadding - textPainter.width - 4.0, yPos - textPainter.height / 2));
    }

    // Draw threshold line
    final double thresholdY = topPadding + chartHeight - (thresholdMs / maxY) * chartHeight;
    if (thresholdY >= topPadding && thresholdY <= topPadding + chartHeight) {
      canvas.drawLine(
        Offset(leftPadding, thresholdY),
        Offset(leftPadding + chartWidth, thresholdY),
        thresholdPaint,
      );
    }

    // Calculate points
    final List<Offset> points = [];
    for (int i = 0; i < data.length; i++) {
      final double x = leftPadding + (i / math.max(1, data.length - 1)) * chartWidth;
      final double clampedLatency = math.min(data[i].latencyMs, maxY);
      final double y = topPadding + chartHeight - (clampedLatency / maxY) * chartHeight;
      points.add(Offset(x, y));
    }

    // Apply animation (draw progressively)
    final int animatedPointCount = math.max(1, (points.length * animationValue).ceil());
    final List<Offset> visiblePoints = points.sublist(0, animatedPointCount);

    if (visiblePoints.length > 1) {
      // Draw area fill
      final Path areaPath = Path();
      areaPath.moveTo(visiblePoints.first.dx, topPadding + chartHeight);
      for (final p in visiblePoints) {
        areaPath.lineTo(p.dx, p.dy);
      }
      areaPath.lineTo(visiblePoints.last.dx, topPadding + chartHeight);
      areaPath.close();

      final Paint areaPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [lineColor.withOpacity(0.2), lineColor.withOpacity(0.0)],
        ).createShader(Rect.fromLTWH(leftPadding, topPadding, chartWidth, chartHeight));
      canvas.drawPath(areaPath, areaPaint);

      // Draw line segments (color changes based on threshold breach)
      for (int i = 0; i < visiblePoints.length - 1; i++) {
        final bool isBreach = data[i].latencyMs > thresholdMs || data[i + 1].latencyMs > thresholdMs;
        final Paint linePaint = Paint()
          ..color = isBreach ? breachColor : lineColor
          ..strokeWidth = 2.5
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;
        
        canvas.drawLine(visiblePoints[i], visiblePoints[i + 1], linePaint);
      }
    }

    // Draw data points
    for (int i = 0; i < visiblePoints.length; i++) {
      final bool isBreach = data[i].latencyMs > thresholdMs;
      final Paint dotPaint = Paint()
        ..color = isBreach ? breachColor : lineColor
        ..style = PaintingStyle.fill;
      
      final double radius = (scrubbedIndex == i) ? 6.0 : 3.5;
      canvas.drawCircle(visiblePoints[i], radius, dotPaint);

      if (isBreach) {
        final Paint ringPaint = Paint()
          ..color = breachColor.withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;
        canvas.drawCircle(visiblePoints[i], radius + 3.0, ringPaint);
      }
    }

    // Draw X-axis labels (simplified for mobile)
    final int labelStep = math.max(1, (data.length / 4).floor());
    for (int i = 0; i < data.length; i += labelStep) {
      final double x = leftPadding + (i / math.max(1, data.length - 1)) * chartWidth;
      final String timeStr = '${data[i].timestamp.hour.toString().padLeft(2, '0')}:${data[i].timestamp.minute.toString().padLeft(2, '0')}';
      textPainter.text = TextSpan(
        text: timeStr,
        style: TextStyle(color: textColor, fontSize: 10.0),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - textPainter.width / 2, topPadding + chartHeight + 8.0));
    }

    // Draw scrub indicator
    if (scrubbedIndex != null && scrubbedIndex! < visiblePoints.length) {
      final Offset scrubPoint = visiblePoints[scrubbedIndex!];
      final Paint scrubLinePaint = Paint()
        ..color = textColor.withOpacity(0.5)
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke
        ..pathEffect = PathEffect.dashPath(const DashPathEffect([4.0, 4.0], 0.0));
      
      canvas.drawLine(
        Offset(scrubPoint.dx, topPadding),
        Offset(scrubPoint.dx, topPadding + chartHeight),
        scrubLinePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TraceChartPainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.animationValue != animationValue ||
        oldDelegate.scrubbedIndex != scrubbedIndex;
  }
}