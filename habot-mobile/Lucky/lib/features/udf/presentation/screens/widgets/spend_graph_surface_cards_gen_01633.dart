// GEN-01633 — M3 Surface Cards housing Bar and Donut spend graph components.
// Constructs responsive Material 3 Elevated Cards (Level 2, 3dp elevation) containing bar and donut chart visualizations for budget spend data with mock data, 30s polling, pull-to-refresh, and adaptive single/multi-column layout.

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Mock data model for spend visualization.
class SpendDataPoint {
  final String label;
  final double amount;
  final Color color;

  const SpendDataPoint({
    required this.label,
    required this.amount,
    required this.color,
  });
}

/// Mock repository providing realistic local budget visualization data.
class MockSpendRepository {
  static List<SpendDataPoint> getBarSpendData() {
    return const [
      SpendDataPoint(label: 'Housing', amount: 1500.0, color: Color(0xFF6750A4)),
      SpendDataPoint(label: 'Food', amount: 600.0, color: Color(0xFF625B71)),
      SpendDataPoint(label: 'Transport', amount: 300.0, color: Color(0xFF7D5260)),
      SpendDataPoint(label: 'Utilities', amount: 250.0, color: Color(0xFFB3261E)),
      SpendDataPoint(label: 'Entertainment', amount: 150.0, color: Color(0xFF006C4C)),
    ];
  }

  static List<SpendDataPoint> getDonutSpendData() {
    return const [
      SpendDataPoint(label: 'Needs', amount: 2150.0, color: Color(0xFF6750A4)),
      SpendDataPoint(label: 'Wants', amount: 450.0, color: Color(0xFF625B71)),
      SpendDataPoint(label: 'Savings', amount: 400.0, color: Color(0xFF006C4C)),
    ];
  }
}

/// Main widget constructing M3 Surface Cards housing Bar and Donut spend graph components.
/// Implements M3 responsive layout: single-column on mobile (<600dp), multi-column on desktop (>=840dp).
/// Includes background polling every 30 seconds and pull-to-refresh.
class SpendGraphSurfaceCards extends StatefulWidget {
  const SpendGraphSurfaceCards({super.key});

  @override
  State<SpendGraphSurfaceCards> createState() => _SpendGraphSurfaceCardsState();
}

class _SpendGraphSurfaceCardsState extends State<SpendGraphSurfaceCards> {
  late List<SpendDataPoint> _barData;
  late List<SpendDataPoint> _donutData;
  bool _isLoading = false;
  Timer? _pollingTimer;
  final GlobalKey<RefreshIndicatorState> _refreshKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _loadData();
    // Background polling refreshes data every 30 seconds.
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _loadData(silent: true);
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadData({bool silent = false}) async {
    if (!silent && mounted) {
      setState(() => _isLoading = true);
    }
    // Simulate sub-100ms API response latency via optimized mock fetch
    await Future.delayed(const Duration(milliseconds: 80));
    if (mounted) {
      setState(() {
        _barData = MockSpendRepository.getBarSpendData();
        _donutData = MockSpendRepository.getDonutSpendData();
        _isLoading = false;
      });
    }
  }

  Future<void> _handleRefresh() async {
    await _loadData();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Budget data synchronized successfully.'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      key: _refreshKey,
      onRefresh: _handleRefresh,
      color: Theme.of(context).colorScheme.primary,
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool isDesktop = constraints.maxWidth >= 840;
          final double totalDonut = _donutData.fold(0.0, (sum, item) => sum + item.amount);

          if (_isLoading && _barData.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (isDesktop) {
            // Multi-column on desktop (>=840dp)
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildBarChartCard(_barData),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: _buildDonutChartCard(_donutData, totalDonut),
                  ),
                ],
              ),
            );
          } else {
            // Single-column mobile layout (<600dp) / Tablet
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildBarChartCard(_barData),
                  const SizedBox(height: 16.0),
                  _buildDonutChartCard(_donutData, totalDonut),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  /// Constructs M3 Elevated Card Level 2 (3dp) for the Bar Spend Graph.
  Widget _buildBarChartCard(List<SpendDataPoint> data) {
    return Card(
      elevation: 3.0,
      surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Category Spend',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                _buildStatusChip('Pass'),
              ],
            ),
            const SizedBox(height: 24.0),
            SizedBox(
              height: 200.0,
              child: CustomPaint(
                size: const Size(double.infinity, 200.0),
                painter: _BarChartPainter(
                  data: data,
                  textColor: Theme.of(context).colorScheme.onSurfaceVariant,
                  textStyle: Theme.of(context).textTheme.labelSmall!,
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            Wrap(
              spacing: 16.0,
              runSpacing: 8.0,
              children: data.map((d) => _buildLegendItem(d)).toList(),
            ),
          ],
        ),
      ),
    );
  }

  /// Constructs M3 Elevated Card Level 2 (3dp) for the Donut Spend Graph.
  Widget _buildDonutChartCard(List<SpendDataPoint> data, double total) {
    return Card(
      elevation: 3.0,
      surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Budget Allocation',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                _buildStatusChip('Pass'),
              ],
            ),
            const SizedBox(height: 24.0),
            Center(
              child: SizedBox(
                width: 200.0,
                height: 200.0,
                child: CustomPaint(
                  painter: _DonutChartPainter(
                    data: data,
                    total: total,
                    centerColor: Theme.of(context).colorScheme.surface,
                    textColor: Theme.of(context).colorScheme.onSurface,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Total',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        Text(
                          '\$${total.toStringAsFixed(0)}',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24.0),
            ...data.map((d) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: _buildDonutLegendRow(d, total),
                )),
          ],
        ),
      ),
    );
  }

  /// M3 Status Chip for health indicators.
  Widget _buildStatusChip(String status) {
    final bool isPass = status == 'Pass';
    return Chip(
      avatar: Icon(
        isPass ? Icons.check_circle_outline : Icons.error_outline,
        size: 18.0,
        color: isPass ? Colors.green[700] : Colors.red[700],
      ),
      label: Text(status),
      backgroundColor: isPass ? Colors.green[50] : Colors.red[50],
      labelStyle: TextStyle(
        color: isPass ? Colors.green[900] : Colors.red[900],
        fontSize: 12.0,
        fontWeight: FontWeight.w500,
      ),
      side: BorderSide.none,
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildLegendItem(SpendDataPoint point) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12.0,
          height: 12.0,
          decoration: BoxDecoration(
            color: point.color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6.0),
        Text(
          point.label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildDonutLegendRow(SpendDataPoint point, double total) {
    final percentage = ((point.amount / total) * 100).toStringAsFixed(1);
    return Row(
      children: [
        Container(
          width: 16.0,
          height: 16.0,
          decoration: BoxDecoration(
            color: point.color,
            borderRadius: BorderRadius.circular(4.0),
          ),
        ),
        const SizedBox(width: 12.0),
        Expanded(
          child: Text(
            point.label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        Text(
          '\$${point.amount.toStringAsFixed(0)}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(width: 8.0),
        SizedBox(
          width: 48.0,
          child: Text(
            '$percentage%',
            textAlign: TextAlign.end,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ),
      ],
    );
  }
}

/// Custom painter for the Bar Chart component.
class _BarChartPainter extends CustomPainter {
  final List<SpendDataPoint> data;
  final Color textColor;
  final TextStyle textStyle;

  _BarChartPainter({
    required this.data,
    required this.textColor,
    required this.textStyle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final maxAmount = data.map((e) => e.amount).reduce(math.max);
    final barWidth = (size.width / data.length) * 0.6;
    final spacing = (size.width / data.length) * 0.4;
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    for (int i = 0; i < data.length; i++) {
      final point = data[i];
      final barHeight = (point.amount / maxAmount) * (size.height - 30);
      final x = i * (barWidth + spacing) + spacing / 2;
      final y = size.height - barHeight - 20;

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, barWidth, barHeight),
        const Radius.circular(4.0),
      );

      final paint = Paint()
        ..color = point.color
        ..style = PaintingStyle.fill;

      canvas.drawRRect(rect, paint);

      textPainter.text = TextSpan(
        text: point.label,
        style: textStyle.copyWith(color: textColor, fontSize: 10),
      );
      textPainter.layout(maxWidth: barWidth + spacing);
      textPainter.paint(
        canvas,
        Offset(x + (barWidth - textPainter.width) / 2, size.height - 16),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter oldDelegate) {
    return oldDelegate.data != data;
  }
}

/// Custom painter for the Donut Chart component.
class _DonutChartPainter extends CustomPainter {
  final List<SpendDataPoint> data;
  final double total;
  final Color centerColor;
  final Color textColor;

  _DonutChartPainter({
    required this.data,
    required this.total,
    required this.centerColor,
    required this.textColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty || total == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final strokeWidth = radius * 0.35;
    final rect = Rect.fromCircle(center: center, radius: radius - strokeWidth / 2);

    double startAngle = -math.pi / 2;

    for (final point in data) {
      final sweepAngle = (point.amount / total) * 2 * math.pi;
      final paint = Paint()
        ..color = point.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) {
    return oldDelegate.data != data || oldDelegate.total != total;
  }
}