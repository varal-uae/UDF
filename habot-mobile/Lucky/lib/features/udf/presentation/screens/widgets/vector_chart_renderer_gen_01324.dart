// GEN-01324 — Vector mobile chart rendering library integration for budget visualization.
// Provides a reusable vector-based chart widget using Flutter's CustomPainter with M3 ElevatedCard layout, Material You dynamic color, and local mock data.

import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Mock data representing Budget Visualization Data Accuracy metrics.
class _MockBudgetData {
  final String label;
  final double value; // Normalized 0.0 - 1.0
  final Color color;

  const _MockBudgetData({
    required this.label,
    required this.value,
    required this.color,
  });
}

final List<_MockBudgetData> _mockChartData = [
  const _MockBudgetData(label: 'Q1', value: 0.985, color: Colors.blue),
  const _MockBudgetData(label: 'Q2', value: 0.992, color: Colors.green),
  const _MockBudgetData(label: 'Q3', value: 0.978, color: Colors.orange),
  const _MockBudgetData(label: 'Q4', value: 0.999, color: Colors.purple),
];

/// ISO/IEC 25012 Metric Configuration
const double kFloorThreshold = 0.98;
const double kOptimalTarget = 0.999;
const double kCeilingBoundary = 1.0;

/// Custom Painter for vector-based bar chart rendering.
class _VectorBarChartPainter extends CustomPainter {
  final List<_MockBudgetData> data;
  final Color floorLineColor;
  final Color targetLineColor;

  _VectorBarChartPainter({
    required this.data,
    required this.floorLineColor,
    required this.targetLineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final double padding = 16.0;
    final double chartWidth = size.width - (padding * 2);
    final double chartHeight = size.height - (padding * 2);
    final double barWidth = chartWidth / (data.length * 2);
    final double spacing = barWidth;

    // Draw Floor Threshold Line (0.98)
    final double floorY = padding + chartHeight * (1.0 - kFloorThreshold);
    final Paint floorPaint = Paint()
      ..color = floorLineColor
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(padding, floorY),
      Offset(size.width - padding, floorY),
      floorPaint,
    );

    // Draw Optimal Target Line (0.999)
    final double targetY = padding + chartHeight * (1.0 - kOptimalTarget);
    final Paint targetPaint = Paint()
      ..color = targetLineColor
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    // Dashed line effect approximation
    double startX = padding;
    while (startX < size.width - padding) {
      canvas.drawLine(
        Offset(startX, targetY),
        Offset(math.min(startX + 8, size.width - padding), targetY),
        targetPaint,
      );
      startX += 16;
    }

    // Draw Bars
    for (int i = 0; i < data.length; i++) {
      final item = data[i];
      final double x = padding + (i * (barWidth + spacing)) + (spacing / 2);
      final double barHeight = chartHeight * item.value;
      final double y = padding + chartHeight - barHeight;

      final Rect rect = Rect.fromLTWH(x, y, barWidth, barHeight);
      final RRect rrect = RRect.fromRectAndRadius(rect, const Radius.circular(4.0));

      final Paint barPaint = Paint()
        ..color = item.value >= kFloorThreshold ? item.color : Colors.red
        ..style = PaintingStyle.fill;

      canvas.drawRRect(rrect, barPaint);

      // Draw Label
      final TextSpan span = TextSpan(
        text: item.label,
        style: TextStyle(
          fontSize: 12,
          color: item.color,
          fontWeight: FontWeight.w500,
        ),
      );
      final TextPainter tp = TextPainter(
        text: span,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: barWidth + spacing);
      tp.paint(canvas, Offset(x - (tp.width - barWidth) / 2, size.height - padding + 4));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Reusable Vector Chart Widget wrapped in M3 Elevated Card.
class VectorChartRendererGen01324 extends StatelessWidget {
  const VectorChartRendererGen01324({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Card(
      elevation: 3.0, // M3 Elevated Cards Level 2 (3dp)
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Budget Visualization Data Accuracy',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Chip(
                  label: const Text('Pass'),
                  backgroundColor: colorScheme.primaryContainer,
                  labelStyle: TextStyle(color: colorScheme.onPrimaryContainer),
                  avatar: Icon(Icons.check_circle, color: colorScheme.primary, size: 18),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            SizedBox(
              height: 200.0,
              width: double.infinity,
              child: CustomPaint(
                painter: _VectorBarChartPainter(
                  data: _mockChartData,
                  floorLineColor: colorScheme.error.withOpacity(0.6),
                  targetLineColor: colorScheme.tertiary.withOpacity(0.8),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildLegendItem('Floor (${kFloorThreshold.toStringAsFixed(2)})', colorScheme.error),
                _buildLegendItem('Target (${kOptimalTarget.toStringAsFixed(3)})', colorScheme.tertiary),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: color),
        ),
      ],
    );
  }
}