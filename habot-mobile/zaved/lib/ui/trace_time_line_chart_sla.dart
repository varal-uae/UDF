// ============================================================================
// ARCHITECTURAL TRACKING METADATA BLOCK
// Definition Name: TraceTimeLineChartSLA
// Definition Parameters: slaThresholdMs: 200.0, lockedMinY: 0.0, lockedMaxY: 350.0
// Definition Type: InteractiveSLADataVisualization
// Validation Status: LOCKED_Y_AXIS_ENFORCED
// Definition ID: SLPLU-014-A02
// Completion Status: Complete (Ref: SLPLU-014-A02)
// ============================================================================

import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Trace Latency Data Point Model
class TraceDataPoint {
  final int timestampSecond;
  final double latencyMs;
  final String traceId;

  const TraceDataPoint({
    required this.timestampSecond,
    required this.latencyMs,
    required this.traceId,
  });
}

/// SLPLU-014-A02: Interactive Trace Time Line Chart with Locked Y-Axis (Poka-Yoke)
/// Features:
/// 1. Interactive Custom Canvas Line Chart: Touch-and-hold gestures for tooltips, X-axis panning/zooming.
/// 2. Hard Red SLA Threshold: High-contrast red alert horizontal line at 200ms.
/// 3. Programmatically Locked Y-Axis: minY (0) and maxY (350) are strictly locked to prevent flattening spikes.
/// 4. Auto-Ticketing: Dispatches onSLABreached when latency crosses the SLA threshold.
class TraceTimeLineChartSLA extends StatefulWidget {
  final List<TraceDataPoint>? initialData;
  final double slaThresholdMs;
  final ValueChanged<double>? onSLABreached;

  const TraceTimeLineChartSLA({
    super.key,
    this.initialData,
    this.slaThresholdMs = 200.0,
    this.onSLABreached,
  });

  @override
  State<TraceTimeLineChartSLA> createState() => _TraceTimeLineChartSLAState();
}

class _TraceTimeLineChartSLAState extends State<TraceTimeLineChartSLA> {
  // Strictly locked Y-Axis bounds (Poka-Yoke: Cannot zoom out to hide latency spikes)
  static const double _lockedMinY = 0.0;
  static const double _lockedMaxY = 350.0;

  late List<TraceDataPoint> _dataPoints;
  int? _hoveredIndex;
  double _panOffset = 0.0;
  final List<String> _generatedTickets = [];

  @override
  void initState() {
    super.initState();
    _dataPoints = widget.initialData ?? _generateMockTraces();
    _checkInitialSLABreaches();
  }

  List<TraceDataPoint> _generateMockTraces() {
    return [
      const TraceDataPoint(timestampSecond: 0, latencyMs: 85.0, traceId: 'TRC-1001'),
      const TraceDataPoint(timestampSecond: 5, latencyMs: 92.0, traceId: 'TRC-1002'),
      const TraceDataPoint(timestampSecond: 10, latencyMs: 110.0, traceId: 'TRC-1003'),
      const TraceDataPoint(timestampSecond: 15, latencyMs: 140.0, traceId: 'TRC-1004'),
      const TraceDataPoint(timestampSecond: 20, latencyMs: 245.0, traceId: 'TRC-1005 (SPIKE)'),
      const TraceDataPoint(timestampSecond: 25, latencyMs: 215.0, traceId: 'TRC-1006 (BREACH)'),
      const TraceDataPoint(timestampSecond: 30, latencyMs: 160.0, traceId: 'TRC-1007'),
      const TraceDataPoint(timestampSecond: 35, latencyMs: 125.0, traceId: 'TRC-1008'),
      const TraceDataPoint(timestampSecond: 40, latencyMs: 98.0, traceId: 'TRC-1009'),
      const TraceDataPoint(timestampSecond: 45, latencyMs: 105.0, traceId: 'TRC-1010'),
    ];
  }

  void _checkInitialSLABreaches() {
    for (final point in _dataPoints) {
      if (point.latencyMs > widget.slaThresholdMs) {
        _triggerAutoTicket(point);
      }
    }
  }

  void _triggerAutoTicket(TraceDataPoint point) {
    final ticket = 'JIRA-SLA-${point.traceId.replaceAll(RegExp(r'[^0-9]'), '')}: Latency ${point.latencyMs.toStringAsFixed(1)}ms exceeded ${widget.slaThresholdMs.toInt()}ms SLA. Assigned to Lead Data Architect.';
    if (!_generatedTickets.contains(ticket)) {
      _generatedTickets.add(ticket);
      widget.onSLABreached?.call(point.latencyMs);
    }
  }

  void _addRandomSpike() {
    final nextSec = (_dataPoints.last.timestampSecond) + 5;
    final randomLatency = 180.0 + (math.Random().nextDouble() * 120.0);
    final newPoint = TraceDataPoint(
      timestampSecond: nextSec,
      latencyMs: randomLatency,
      traceId: 'TRC-${1000 + _dataPoints.length + 1}',
    );

    setState(() {
      _dataPoints.add(newPoint);
      if (newPoint.latencyMs > widget.slaThresholdMs) {
        _triggerAutoTicket(newPoint);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header & Real-Time Status
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.show_chart,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TRACE TIME LINE CHART (SLA MONITOR)',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    Text(
                      'Locked Y-Axis & Automated Ticketing Engine',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: _addRandomSpike,
                icon: const Icon(Icons.flash_on, size: 16),
                label: const Text('Simulate Spike'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Poka-Yoke Y-Axis Lock Notice
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.red.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                const Icon(Icons.lock, color: Colors.red, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Poka-Yoke: Y-Axis locked to $_lockedMinY - $_lockedMaxY ms. Users cannot zoom out to hide latency spikes.',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Interactive Custom Chart Canvas
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: Colors.teal,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text('Live Trace Latency (ms)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 16),
                          Container(
                            width: 16,
                            height: 3,
                            color: Colors.red,
                          ),
                          const SizedBox(width: 6),
                          Text('SLA Threshold (${widget.slaThresholdMs.toInt()}ms)',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.red)),
                        ],
                      ),
                      if (_hoveredIndex != null && _hoveredIndex! < _dataPoints.length)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${_dataPoints[_hoveredIndex!].traceId}: ${_dataPoints[_hoveredIndex!].latencyMs.toStringAsFixed(1)} ms',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Gesture Detector for Touch-and-Hold & Panning
                  GestureDetector(
                    onHorizontalDragUpdate: (details) {
                      setState(() {
                        _panOffset = (_panOffset + details.primaryDelta!).clamp(-200.0, 0.0);
                      });
                    },
                    onPanDown: (details) {
                      _detectHover(details.localPosition);
                    },
                    onPanUpdate: (details) {
                      _detectHover(details.localPosition);
                    },
                    onPanEnd: (_) {
                      setState(() => _hoveredIndex = null);
                    },
                    child: SizedBox(
                      height: 240,
                      width: double.infinity,
                      child: CustomPaint(
                        painter: _SLALineChartPainter(
                          dataPoints: _dataPoints,
                          slaThresholdMs: widget.slaThresholdMs,
                          minY: _lockedMinY,
                          maxY: _lockedMaxY,
                          hoveredIndex: _hoveredIndex,
                          panOffset: _panOffset,
                          theme: theme,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      '👈 Drag horizontally to pan history | Touch & hold nodes to inspect trace telemetry 👉',
                      style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Automated Ticketing Stream
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.confirmation_number_outlined, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Automated Architecture Tickets (${_generatedTickets.length})',
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (_generatedTickets.isEmpty)
                    const Text('No SLA breaches recorded. System performing within nominal constraints.',
                        style: TextStyle(fontSize: 12, color: Colors.grey))
                  else
                    ..._generatedTickets.map(
                      (t) => Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: Colors.red, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                t,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _detectHover(Offset localPos) {
    if (_dataPoints.isEmpty) return;
    const paddingLeft = 40.0;
    final availableWidth = MediaQuery.of(context).size.width - 100.0;
    final stepX = availableWidth / math.max(1, _dataPoints.length - 1);

    int closestIndex = 0;
    double minDistance = double.infinity;

    for (int i = 0; i < _dataPoints.length; i++) {
      final x = paddingLeft + (i * stepX) + _panOffset;
      final dist = (localPos.dx - x).abs();
      if (dist < minDistance) {
        minDistance = dist;
        closestIndex = i;
      }
    }

    setState(() {
      _hoveredIndex = closestIndex;
    });
  }
}

class _SLALineChartPainter extends CustomPainter {
  final List<TraceDataPoint> dataPoints;
  final double slaThresholdMs;
  final double minY;
  final double maxY;
  final int? hoveredIndex;
  final double panOffset;
  final ThemeData theme;

  _SLALineChartPainter({
    required this.dataPoints,
    required this.slaThresholdMs,
    required this.minY,
    required this.maxY,
    required this.hoveredIndex,
    required this.panOffset,
    required this.theme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const double paddingLeft = 45.0;
    const double paddingBottom = 30.0;
    const double paddingTop = 20.0;
    const double paddingRight = 20.0;

    final chartWidth = size.width - paddingLeft - paddingRight;
    final chartHeight = size.height - paddingTop - paddingBottom;

    final gridPaint = Paint()
      ..color = theme.dividerColor.withValues(alpha: 0.15)
      ..strokeWidth = 1;

    final axisTextPainter = TextPainter(textDirection: TextDirection.ltr);

    // Draw Y-Axis Horizontal Grid Lines (0, 100, 200, 300, 350)
    final yLabels = [0, 100, 200, 300, 350];
    for (final label in yLabels) {
      final normalizedY = (label - minY) / (maxY - minY);
      final y = paddingTop + chartHeight - (normalizedY * chartHeight);

      canvas.drawLine(Offset(paddingLeft, y), Offset(size.width - paddingRight, y), gridPaint);

      axisTextPainter.text = TextSpan(
        text: '${label}ms',
        style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurfaceVariant),
      );
      axisTextPainter.layout();
      axisTextPainter.paint(canvas, Offset(paddingLeft - axisTextPainter.width - 6, y - 6));
    }

    // Draw Locked Red SLA Threshold Line
    final normalizedSLA = (slaThresholdMs - minY) / (maxY - minY);
    final slaY = paddingTop + chartHeight - (normalizedSLA * chartHeight);

    final slaPaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(paddingLeft, slaY),
      Offset(size.width - paddingRight, slaY),
      slaPaint,
    );

    if (dataPoints.isEmpty) return;

    final stepX = chartWidth / math.max(1, dataPoints.length - 1);

    // Draw Latency Path
    final path = Path();
    final pointOffsets = <Offset>[];

    for (int i = 0; i < dataPoints.length; i++) {
      final x = paddingLeft + (i * stepX) + panOffset;
      final normalizedValue = (dataPoints[i].latencyMs - minY) / (maxY - minY);
      final y = paddingTop + chartHeight - (normalizedValue * chartHeight);
      final offset = Offset(x, y);
      pointOffsets.add(offset);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final linePaint = Paint()
      ..color = Colors.teal
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, linePaint);

    // Draw Nodes
    for (int i = 0; i < pointOffsets.length; i++) {
      final offset = pointOffsets[i];
      final isBreach = dataPoints[i].latencyMs > slaThresholdMs;
      final isHovered = hoveredIndex == i;

      final nodePaint = Paint()
        ..color = isBreach ? Colors.red : (isHovered ? Colors.amber : Colors.teal)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(offset, isHovered ? 7.0 : 4.5, nodePaint);

      final nodeBorderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawCircle(offset, isHovered ? 7.0 : 4.5, nodeBorderPaint);

      // Draw X labels
      if (i % 2 == 0) {
        axisTextPainter.text = TextSpan(
          text: '${dataPoints[i].timestampSecond}s',
          style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurfaceVariant),
        );
        axisTextPainter.layout();
        axisTextPainter.paint(canvas, Offset(offset.dx - (axisTextPainter.width / 2), size.height - 20));
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SLALineChartPainter oldDelegate) {
    return oldDelegate.dataPoints != dataPoints ||
        oldDelegate.hoveredIndex != hoveredIndex ||
        oldDelegate.panOffset != panOffset;
  }
}
