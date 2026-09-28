// GEN-03541 — Code Coverage Gate Status Card.
// Displays CI/CD code coverage floor status using M3 Elevated Cards, responsive single/multi-column layout, 30s polling, and pull-to-refresh.

import 'dart:async';
import 'package:flutter/material.dart';

/// Mock data model representing the CI/CD Code Coverage Floor metric.
class CoverageMetricGen03541 {
  final String metricName;
  final double currentCoverage;
  final double floorThreshold;
  final double optimalTarget;
  final String status;
  final DateTime lastUpdated;
  final String traceId;

  const CoverageMetricGen03541({
    required this.metricName,
    required this.currentCoverage,
    required this.floorThreshold,
    required this.optimalTarget,
    required this.status,
    required this.lastUpdated,
    required this.traceId,
  });
}

/// Mock repository simulating backend/BigQuery data streaming.
class MockCoverageRepositoryGen03541 {
  static Future<CoverageMetricGen03541> fetchCoverageMetric() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return CoverageMetricGen03541(
      metricName: 'CI/CD Code Coverage Floor',
      currentCoverage: 0.87,
      floorThreshold: 0.80,
      optimalTarget: 0.85,
      status: 'Pass',
      lastUpdated: DateTime.now(),
      traceId: 'trace-gen-03541-${DateTime.now().millisecondsSinceEpoch}',
    );
  }
}

/// Controller managing background polling (30s) and manual refresh state.
class CoverageGateControllerGen03541 extends ChangeNotifier {
  CoverageMetricGen03541? _metric;
  Timer? _pollingTimer;
  bool _isLoading = false;

  CoverageMetricGen03541? get metric => _metric;
  bool get isLoading => _isLoading;

  CoverageGateControllerGen03541() {
    fetchMetric();
    _startPolling();
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      fetchMetric();
    });
  }

  Future<void> fetchMetric() async {
    _isLoading = true;
    notifyListeners();
    try {
      _metric = await MockCoverageRepositoryGen03541.fetchCoverageMetric();
    } catch (_) {
      // Handle error gracefully in production
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }
}

/// Main widget implementing M3 responsive layout and Elevated Card Level 2 (3dp).
class CodeCoverageGateCardGen03541 extends StatefulWidget {
  const CodeCoverageGateCardGen03541({super.key});

  @override
  State<CodeCoverageGateCardGen03541> createState() => _CodeCoverageGateCardGen03541State();
}

class _CodeCoverageGateCardGen03541State extends State<CodeCoverageGateCardGen03541> {
  late final CoverageGateControllerGen03541 _controller;

  @override
  void initState() {
    super.initState();
    _controller = CoverageGateControllerGen03541();
    _controller.addListener(_onControllerUpdate);
  }

  void _onControllerUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Engineering Console'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _controller.fetchMetric,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 600;
            final isTabletOrDesktop = constraints.maxWidth >= 840;

            final cardWidget = _buildElevatedCard(colorScheme, textTheme);

            if (isMobile) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                children: [cardWidget],
              );
            } else if (isTabletOrDesktop) {
              return GridView.count(
                physics: const AlwaysScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 2.5,
                padding: const EdgeInsets.all(24.0),
                mainAxisSpacing: 16.0,
                crossAxisSpacing: 16.0,
                children: [cardWidget],
              );
            } else {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20.0),
                children: [cardWidget],
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildElevatedCard(ColorScheme colorScheme, TextTheme textTheme) {
    final metric = _controller.metric;
    final isPassing = metric != null && metric.currentCoverage >= metric.floorThreshold;

    return Card(
      elevation: 3.0, // M3 Elevated Card Level 2 (3dp)
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      color: colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    metric?.metricName ?? 'Loading Metric...',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                _buildStatusChip(isPassing, colorScheme),
              ],
            ),
            const SizedBox(height: 16.0),
            if (_controller.isLoading)
              const LinearProgressIndicator()
            else if (metric != null) ...[
              Row(
                children: [
                  Text('Current Coverage: ', style: textTheme.bodyLarge),
                  Text(
                    '${(metric.currentCoverage * 100).toStringAsFixed(1)}%',
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isPassing ? colorScheme.primary : colorScheme.error,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
              Text(
                'Floor Boundary: > ${(metric.floorThreshold * 100).toStringAsFixed(0)}% | Optimal Target: > ${(metric.optimalTarget * 100).toStringAsFixed(0)}%',
                style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 8.0),
              Text(
                'Trace ID: ${metric.traceId}',
                style: textTheme.bodySmall?.copyWith(color: colorScheme.outline),
              ),
              const SizedBox(height: 4.0),
              Text(
                'Last Updated: ${metric.lastUpdated.toLocal().toString().split('.').first}',
                style: textTheme.bodySmall?.copyWith(color: colorScheme.outline),
              ),
            ] else
              Text('No data available.', style: textTheme.bodyMedium),
            const SizedBox(height: 16.0),
            SizedBox(
              height: 48.0, // 48x48dp touch target
              width: 48.0,
              child: IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: () => _showConfigBottomSheet(context),
                tooltip: 'Configuration Details',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(bool isPassing, ColorScheme colorScheme) {
    return Chip(
      avatar: Icon(
        isPassing ? Icons.check_circle : Icons.error,
        size: 18.0,
        color: isPassing ? colorScheme.onPrimaryContainer : colorScheme.onErrorContainer,
      ),
      label: Text(
        isPassing ? 'Pass' : 'Fail',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isPassing ? colorScheme.onPrimaryContainer : colorScheme.onErrorContainer,
        ),
      ),
      backgroundColor: isPassing ? colorScheme.primaryContainer : colorScheme.errorContainer,
      side: BorderSide.none,
    );
  }

  void _showConfigBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.0)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Step Configuration',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16.0),
              const Text(
                'Add code coverage gates automatically failing builds if unit test coverage drops below 80%. '
                'All step execution events stream to BigQuery partitioned by event_date, clustered by trace_id.',
              ),
              const SizedBox(height: 24.0),
              SizedBox(
                width: double.infinity,
                height: 48.0, // 48x48dp touch target
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Configuration acknowledged.')),
                    );
                  },
                  child: const Text('Acknowledge'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}