// GEN-03585 — Strict Input Masking (Poka-Yoke) Control.
// Provides reusable input formatters and validation utilities that physically block invalid data entry by human workers. Implements M3 Elevated Cards and Status Chips for engineering console display.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Poka-Yoke strict input masking control.
/// Physically blocks invalid characters at the framework level using [TextInputFormatter].
class StrictInputMaskingGen03585 {
  StrictInputMaskingGen03585._();

  /// Blocks any non-digit input. Used for numeric-only fields.
  static final TextInputFormatter digitsOnly = FilteringTextInputFormatter.digitsOnly;

  /// Blocks any non-alphanumeric input.
  static final TextInputFormatter alphaNumericOnly =
      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]'));

  /// Custom regex-based strict mask. Throws no errors, simply prevents invalid keystrokes.
  static TextInputFormatter customMask(String pattern) {
    return FilteringTextInputFormatter.allow(RegExp(pattern));
  }
}

/// Metric configuration for MTO Input Intercept Rate.
class MtoInputInterceptMetricGen03585 {
  final String metricName;
  final double floorBoundary;
  final double optimalTarget;
  final double ceilingBoundary;
  final bool isPassing;
  final DateTime timestamp;

  const MtoInputInterceptMetricGen03585({
    required this.metricName,
    required this.floorBoundary,
    required this.optimalTarget,
    required this.ceilingBoundary,
    required this.isPassing,
    required this.timestamp,
  });
}

/// Mock data simulating backend telemetry for the engineering console.
class MockTelemetryRepositoryGen03585 {
  static List<MtoInputInterceptMetricGen03585> getMockMetrics() {
    return [
      MtoInputInterceptMetricGen03585(
        metricName: 'MTO Input Intercept Rate',
        floorBoundary: 1.0,
        optimalTarget: 1.0,
        ceilingBoundary: 1.0,
        isPassing: true,
        timestamp: DateTime.now().subtract(const Duration(seconds: 30)),
      ),
      MtoInputInterceptMetricGen03585(
        metricName: 'MTO Input Intercept Rate',
        floorBoundary: 1.0,
        optimalTarget: 1.0,
        ceilingBoundary: 1.0,
        isPassing: true,
        timestamp: DateTime.now(),
      ),
    ];
  }
}

/// M3 Status Chip indicating Pass/Fail health of the Poka-Yoke step.
class PokaYokeStatusChipGen03585 extends StatelessWidget {
  final bool isPassing;

  const PokaYokeStatusChipGen03585({super.key, required this.isPassing});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Chip(
      avatar: Icon(
        isPassing ? Icons.check_circle_outline : Icons.error_outline,
        size: 18,
        color: isPassing ? colorScheme.primary : colorScheme.error,
      ),
      label: Text(
        isPassing ? 'Pass' : 'Fail',
        style: TextStyle(
          color: isPassing ? colorScheme.primary : colorScheme.error,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: isPassing
          ? colorScheme.primaryContainer.withOpacity(0.3)
          : colorScheme.errorContainer.withOpacity(0.3),
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}

/// M3 Elevated Card Level 2 (3dp) displaying step completion state and KPI metrics.
/// Single-column mobile layout (<600dp), multi-column on desktop (>=840dp).
class EngineeringConsoleCardGen03585 extends StatelessWidget {
  final MtoInputInterceptMetricGen03585 metric;

  const EngineeringConsoleCardGen03585({super.key, required this.metric});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 3.0, // M3 Elevated Cards Level 2
      surfaceTintColor: colorScheme.surfaceTint,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    metric.metricName,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                PokaYokeStatusChipGen03585(isPassing: metric.isPassing),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Strict Input Masking physically blocks invalid data entry.',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildStatColumn('Floor', metric.floorBoundary.toString(), textTheme),
                const SizedBox(width: 16),
                _buildStatColumn('Target', metric.optimalTarget.toString(), textTheme),
                const SizedBox(width: 16),
                _buildStatColumn('Ceiling', metric.ceilingBoundary.toString(), textTheme),
              ],
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () {
                  // Deep-link drill-down action placeholder
                },
                icon: const Icon(Icons.open_in_new, size: 18),
                label: const Text('Drill Down'),
                style: TextButton.styleFrom(
                  minimumSize: const Size(48, 48), // 48x48dp touch targets
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: textTheme.labelSmall),
        const SizedBox(height: 4),
        Text(value, style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

/// Example screen demonstrating the implementation in a single-column mobile layout.
class PokaYokeConsoleScreenGen03585 extends StatefulWidget {
  const PokaYokeConsoleScreenGen03585({super.key});

  @override
  State<PokaYokeConsoleScreenGen03585> createState() => _PokaYokeConsoleScreenGen03585State();
}

class _PokaYokeConsoleScreenGen03585State extends State<PokaYokeConsoleScreenGen03585> {
  late List<MtoInputInterceptMetricGen03585> _metrics;

  @override
  void initState() {
    super.initState();
    _metrics = MockTelemetryRepositoryGen03585.getMockMetrics();
  }

  Future<void> _handleRefresh() async {
    // Simulates pull-to-refresh manual sync
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() {
        _metrics = MockTelemetryRepositoryGen03585.getMockMetrics();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Engineering Console'),
        centerTitle: false,
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 840;
            
            if (isDesktop) {
              // Multi-column on desktop (>=840dp)
              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 400,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  mainAxisExtent: 220,
                ),
                itemCount: _metrics.length,
                itemBuilder: (context, index) {
                  return EngineeringConsoleCardGen03585(metric: _metrics[index]);
                },
              );
            }

            // Single-column mobile layout (<600dp)
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _metrics.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return EngineeringConsoleCardGen03585(metric: _metrics[index]);
              },
            );
          },
        ),
      ),
    );
  }
}