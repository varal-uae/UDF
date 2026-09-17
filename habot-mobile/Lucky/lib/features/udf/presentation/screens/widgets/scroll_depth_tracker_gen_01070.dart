// GEN-01070 — Viewport Scroll-Depth Event Tracker.
// Attaches scroll-depth event listeners to a vertical container, emitting telemetry events and displaying M3 status cards with qualitative health metrics.

import 'dart:async';
import 'package:flutter/material.dart';

/// Mock telemetry service representing BigQuery streaming alignment.
class _MockTelemetryService {
  static void logScrollDepthEvent({
    required String traceId,
    required double depthPercentage,
    required String qualitativeOutput,
  }) {
    // In production, this streams to BigQuery partitioned by event_date, clustered by trace_id.
    debugPrint(
      '[GEN-01070 Telemetry] trace_id: $traceId | depth: ${depthPercentage.toStringAsFixed(2)}% | status: $qualitativeOutput',
    );
  }
}

/// Evaluates scroll depth against Baymard Institute Mobile UX Benchmark thresholds.
String _evaluateQualitativeStatus(double depth) {
  if (depth >= 0.95) return 'Good';
  if (depth >= 0.60) return 'Average';
  return 'Poor';
}

/// A wrapper widget that attaches viewport scroll-depth event listeners
/// to its vertical child container.
class ScrollDepthTracker extends StatefulWidget {
  const ScrollDepthTracker({
    super.key,
    required this.child,
    this.onDepthChanged,
  });

  final Widget child;
  final ValueChanged<double>? onDepthChanged;

  @override
  State<ScrollDepthTracker> createState() => _ScrollDepthTrackerState();
}

class _ScrollDepthTrackerState extends State<ScrollDepthTracker> {
  final ScrollController _scrollController = ScrollController();
  double _currentDepth = 0.0;
  Timer? _pollingTimer;
  String _traceId = '';

  @override
  void initState() {
    super.initState();
    _traceId = DateTime.now().millisecondsSinceEpoch.toRadixString(36);
    _scrollController.addListener(_onScroll);
    // Background polling refreshes data every 30 seconds as per requirement.
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _emitTelemetry();
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxExtent = _scrollController.position.maxScrollExtent;
    if (maxExtent <= 0) {
      _updateDepth(0.0);
      return;
    }
    final offset = _scrollController.offset;
    final depth = (offset / maxExtent).clamp(0.0, 1.0);
    _updateDepth(depth);
  }

  void _updateDepth(double depth) {
    if (_currentDepth != depth) {
      setState(() {
        _currentDepth = depth;
      });
      widget.onDepthChanged?.call(depth);
      _emitTelemetry();
    }
  }

  void _emitTelemetry() {
    final status = _evaluateQualitativeStatus(_currentDepth);
    _MockTelemetryService.logScrollDepthEvent(
      traceId: _traceId,
      depthPercentage: _currentDepth * 100,
      qualitativeOutput: status,
    );
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollUpdateNotification ||
            notification is OverscrollNotification) {
          _onScroll();
        }
        return false;
      },
      child: SingleChildScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        child: widget.child,
      ),
    );
  }
}

/// M3 Elevated Card Level 2 (3dp) displaying step completion state and scroll depth health.
class ScrollDepthStatusCard extends StatelessWidget {
  const ScrollDepthStatusCard({
    super.key,
    required this.depthPercentage,
  });

  final double depthPercentage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final status = _evaluateQualitativeStatus(depthPercentage / 100.0);

    final Color chipColor;
    switch (status) {
      case 'Good':
        chipColor = colorScheme.primaryContainer;
        break;
      case 'Average':
        chipColor = colorScheme.tertiaryContainer;
        break;
      default:
        chipColor = colorScheme.errorContainer;
    }

    return Card(
      elevation: 3.0, // M3 Elevated Cards Level 2 (3dp)
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Viewport Scroll Depth',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${depthPercentage.toStringAsFixed(1)}%',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        'Baymard Benchmark Target: ≥60%',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                // M3 Status Chip for health indicator
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 6.0,
                  ),
                  decoration: BoxDecoration(
                    color: chipColor,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text(
                    status,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: status == 'Good'
                          ? colorScheme.onPrimaryContainer
                          : status == 'Average'
                              ? colorScheme.onTertiaryContainer
                              : colorScheme.onErrorContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            LinearProgressIndicator(
              value: (depthPercentage / 100.0).clamp(0.0, 1.0),
              minHeight: 6.0,
              backgroundColor: colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
              borderRadius: BorderRadius.circular(3.0),
            ),
          ],
        ),
      ),
    );
  }
}

/// Example usage demonstrating the single-column mobile layout (<600dp)
/// and multi-column desktop layout (≥840dp) with M3 status cards.
class ScrollDepthDashboardScreen extends StatelessWidget {
  const ScrollDepthDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 840;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scroll Depth Engineering Console'),
        centerTitle: false,
      ),
      body: ScrollDepthTracker(
        onDepthChanged: (depth) {
          // Hook for additional downstream logic
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: isDesktop
              ? _buildMultiColumnLayout()
              : _buildSingleColumnLayout(),
        ),
      ),
    );
  }

  Widget _buildSingleColumnLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const ScrollDepthStatusCard(depthPercentage: 75.5),
        const SizedBox(height: 16.0),
        ...List.generate(
          20,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Card(
              elevation: 1.0,
              child: ListTile(
                minVerticalPadding: 16.0,
                title: Text('Vertical Container Item ${index + 1}'),
                subtitle: const Text('Scroll down to track depth events'),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMultiColumnLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: List.generate(
              30,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Card(
                  elevation: 1.0,
                  child: ListTile(
                    title: Text('Desktop Item ${index + 1}'),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 24.0),
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: const [
              ScrollDepthStatusCard(depthPercentage: 75.5),
              SizedBox(height: 16.0),
              ScrollDepthStatusCard(depthPercentage: 45.0),
            ],
          ),
        ),
      ],
    );
  }
}
