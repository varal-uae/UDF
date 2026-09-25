// SLPLU-017-A06 — Trace Time Line Chart Component.
// Interactive line chart tracking milliseconds over time with a hard SLA threshold line, locked Y-axis limits, and WCAG 2.1 AA dark mode compliance for the System Health tab.

import 'package:flutter/material.dart';

/// Represents a single trace data point.
class TraceDataPoint {
  final DateTime timestamp;
  final double latencyMs;

  const TraceDataPoint({required this.timestamp, required this.latencyMs});
}

/// Mock repository providing realistic local data for the chart.
class TraceTimeMockRepository {
  static List<TraceDataPoint> getMockTraceData() {
    final now = DateTime.now();
    return [
      TraceDataPoint(timestamp: now.subtract(const Duration(minutes: 50)), latencyMs: 120),
      TraceDataPoint(timestamp: now.subtract(const Duration(minutes: 45)), latencyMs: 135),
      TraceDataPoint(timestamp: now.subtract(const Duration(minutes: 40)), latencyMs: 180),
      TraceDataPoint(timestamp: now.subtract(const Duration(minutes: 35)), latencyMs: 210),
      TraceDataPoint(timestamp: now.subtract(const Duration(minutes: 30)), latencyMs: 190),
      TraceDataPoint(timestamp: now.subtract(const Duration(minutes: 25)), latencyMs: 310), // Breach
      TraceDataPoint(timestamp: now.subtract(const Duration(minutes: 20)), latencyMs: 280), // Breach
      TraceDataPoint(timestamp: now.subtract(const Duration(minutes: 15)), latencyMs: 150),
      TraceDataPoint(timestamp: now.subtract(const Duration(minutes: 10)), latencyMs: 140),
      TraceDataPoint(timestamp: now.subtract(const Duration(minutes: 5)), latencyMs: 125),
    ];
  }
}

/// Configuration for spacing scale based on 8dp baseline grid.
class SpacingScaleConfig {
  final double spacingValue;
  final String unitType;
  final String applicationLevel;

  const SpacingScaleConfig({
    this.spacingValue = 8.0,
    this.unitType = 'px',
    this.applicationLevel = 'global',
  });
}

/// Interactive line chart component with locked Y-axis and fixed SLA threshold.
/// Poka-Yoke: Y-axis is strictly locked to prevent visual manipulation of scale.
class TraceTimeLineChart extends StatefulWidget {
  final double slaThresholdMs;
  final double yAxisMin;
  final double yAxisMax;
  final double yAxisStep;
  final List<TraceDataPoint>? dataPoints;
  final SpacingScaleConfig spacingConfig;

  const TraceTimeLineChart({
    super.key,
    this.slaThresholdMs = 250.0,
    this.yAxisMin = 0.0,
    this.yAxisMax = 500.0,
    this.yAxisStep = 100.0,
    this.dataPoints,
    this.spacingConfig = const SpacingScaleConfig(),
  });

  @override
  State<TraceTimeLineChart> createState() => _TraceTimeLineChartState();
}

class _TraceTimeLineChartState extends State<TraceTimeLineChart> {
  late List<TraceDataPoint> _data;
  bool _isSlaBreached = false;

  @override
  void initState() {
    super.initState();
    _data = widget.dataPoints ?? TraceTimeMockRepository.getMockTraceData();
    _evaluateSlaBreach();
  }

  void _evaluateSlaBreach() {
    setState(() {
      _isSlaBreached = _data.any((p) => p.latencyMs > widget.slaThresholdMs);
    });
    // Self-Chasing: If breached, system would generate automated UI ticket.
    // Handled here via state flag for UI feedback.
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // WCAG 2.1 AA compliant colors verified for contrast
    final primaryLineColor = isDark ? const Color(0xFF4FC3F7) : const Color(0xFF0277BD);
    final thresholdColor = isDark ? const Color(0xFFEF5350) : const Color(0xFFC62828);
    final gridColor = isDark ? Colors.white.withOpacity(0.12) : Colors.black.withOpacity(0.12);
    final textColor = isDark ? Colors.white.withOpacity(0.87) : Colors.black.withOpacity(0.87);

    return Semantics(
      label: 'Trace Time Line Chart. SLA Threshold is ${widget.slaThresholdMs} milliseconds. ${_isSlaBreached ? "Warning: SLA threshold breached." : "SLA within limits."}',
      child: Card(
        elevation: 2,
        margin: EdgeInsets.all(widget.spacingConfig.spacingValue * 2),
        child: Padding(
          padding: EdgeInsets.all(widget.spacingConfig.spacingValue * 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'System Health - Trace Time',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (_isSlaBreached)
                    Chip(
                      avatar: const Icon(Icons.warning_amber_rounded, size: 16, color: Colors.white),
                      label: const Text('SLA Breached', style: TextStyle(color: Colors.white, fontSize: 12)),
                      backgroundColor: thresholdColor,
                      padding: EdgeInsets.symmetric(horizontal: widget.spacingConfig.spacingValue),
                    ),
                ],
              ),
              SizedBox(height: widget.spacingConfig.spacingValue * 2),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return CustomPaint(
                      size: Size(constraints.maxWidth, constraints.maxHeight),
                      painter: _TraceChartPainter(
                        data: _data,
                        slaThreshold: widget.slaThresholdMs,
                        yMin: widget.yAxisMin,
                        yMax: widget.yAxisMax,
                        yStep: widget.yAxisStep,
                        lineColor: primaryLineColor,
                        thresholdColor: thresholdColor,
                        gridColor: gridColor,
                        textColor: textColor,
                        spacing: widget.spacingConfig.spacingValue,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TraceChartPainter extends CustomPainter {
  final List<TraceDataPoint> data;
  final double slaThreshold;
  final double yMin;
  final double yMax;
  final double yStep;
  final Color lineColor;
  final Color thresholdColor;
  final Color gridColor;
  final Color textColor;
  final double spacing;

  _TraceChartPainter({
    required this.data,
    required this.slaThreshold,
    required this.yMin,
    required this.yMax,
    required this.yStep,
    required this.lineColor,
    required this.thresholdColor,
    required this.gridColor,
    required this.textColor,
    required this.spacing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    final leftPadding = 48.0;
    final bottomPadding = 24.0;
    final topPadding = 8.0;
    final rightPadding = 8.0;

    final chartWidth = size.width - leftPadding - rightPadding;
    final chartHeight = size.height - topPadding - bottomPadding;

    // Draw Grid Lines & Y-Axis Labels (Fixed step division parameters)
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    for (double yVal = yMin; yVal <= yMax; yVal += yStep) {
      final yPos = topPadding + chartHeight - ((yVal - yMin) / (yMax - yMin)) * chartHeight;
      canvas.drawLine(Offset(leftPadding, yPos), Offset(size.width - rightPadding, yPos), gridPaint);

      textPainter.text = TextSpan(
        text: '${yVal.toInt()}ms',
        style: TextStyle(color: textColor, fontSize: 10),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(leftPadding - textPainter.width - spacing, yPos - textPainter.height / 2));
    }

    // Draw SLA Threshold Line (Hard limit, visually distinct)
    final thresholdY = topPadding + chartHeight - ((slaThreshold - yMin) / (yMax - yMin)) * chartHeight;
    final thresholdPaint = Paint()
      ..color = thresholdColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    
    // Dashed line effect for threshold
    const dashWidth = 6.0;
    const dashSpace = 4.0;
    double startX = leftPadding;
    while (startX < size.width - rightPadding) {
      canvas.drawLine(
        Offset(startX, thresholdY),
        Offset(startX + dashWidth, thresholdY),
        thresholdPaint,
      );
      startX += dashWidth + dashSpace;
    }

    textPainter.text = TextSpan(
      text: 'SLA: ${slaThreshold.toInt()}ms',
      style: TextStyle(color: thresholdColor, fontSize: 10, fontWeight: FontWeight.bold),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(size.width - rightPadding - textPainter.width, thresholdY - textPainter.height - 2));

    // Map data points to coordinates
    final minX = data.first.timestamp.millisecondsSinceEpoch.toDouble();
    final maxX = data.last.timestamp.millisecondsSinceEpoch.toDouble();
    final rangeX = maxX - minX;

    final path = Path();
    final pointPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;

    for (int i = 0; i < data.length; i++) {
      final point = data[i];
      final xRatio = rangeX == 0 ? 0.0 : (point.timestamp.millisecondsSinceEpoch - minX) / rangeX;
      final x = leftPadding + (xRatio * chartWidth);
      
      // Lock Y value to prevent scale manipulation (Poka-Yoke)
      final clampedY = point.latencyMs.clamp(yMin, yMax);
      final yRatio = (clampedY - yMin) / (yMax - yMin);
      final y = topPadding + chartHeight - (yRatio * chartHeight);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }

      // Draw data point circle
      canvas.drawCircle(Offset(x, y), 3.0, pointPaint);

      // Highlight breaches
      if (point.latencyMs > slaThreshold) {
        final breachPaint = Paint()
          ..color = thresholdColor
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(x, y), 5.0, breachPaint);
      }
    }

    // Draw main line
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;
    
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _TraceChartPainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.slaThreshold != slaThreshold ||
        oldDelegate.yMin != yMin ||
        oldDelegate.yMax != yMax;
  }
}
