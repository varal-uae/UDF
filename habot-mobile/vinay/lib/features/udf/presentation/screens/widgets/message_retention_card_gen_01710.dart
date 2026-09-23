// GEN-01710 — Message Retention Status Card.
// M3 Elevated Card displaying 99.9% message retention KPI during traffic simulations with polling and pull-to-refresh support.

import 'dart:async';
import 'package:flutter/material.dart';

/// Mock data model representing the message retention metric.
class MessageRetentionMetric {
  final String metricName;
  final double currentValue;
  final double floorBoundary;
  final double optimalTarget;
  final double ceilingBoundary;
  final String status;
  final DateTime timestamp;

  const MessageRetentionMetric({
    required this.metricName,
    required this.currentValue,
    required this.floorBoundary,
    required this.optimalTarget,
    required this.ceilingBoundary,
    required this.status,
    required this.timestamp,
  });

  bool get isPassing => currentValue >= floorBoundary;
}

/// Mock repository simulating backend API for message retention data.
class MockMessageRetentionRepository {
  static const MessageRetentionMetric _mockData = MessageRetentionMetric(
    metricName: 'Message Retention During Peak Load (%)',
    currentValue: 99.95,
    floorBoundary: 99.9,
    optimalTarget: 99.99,
    ceilingBoundary: 100.0,
    status: 'Pass',
    timestamp: null, // Will be populated dynamically in fetch
  );

  Future<MessageRetentionMetric> fetchRetentionMetric() async {
    // Simulate network latency < 100ms as per requirement
    await Future.delayed(const Duration(milliseconds: 80));
    return MessageRetentionMetric(
      metricName: _mockData.metricName,
      currentValue: _mockData.currentValue,
      floorBoundary: _mockData.floorBoundary,
      optimalTarget: _mockData.optimalTarget,
      ceilingBoundary: _mockData.ceilingBoundary,
      status: _mockData.status,
      timestamp: DateTime.now(),
    );
  }
}

/// Controller managing the 30-second background polling lifecycle.
class MessageRetentionController extends ChangeNotifier {
  final MockMessageRetentionRepository _repository = MockMessageRetentionRepository();
  MessageRetentionMetric? _metric;
  Timer? _pollingTimer;
  bool _isLoading = false;

  MessageRetentionMetric? get metric => _metric;
  bool get isLoading => _isLoading;

  MessageRetentionController() {
    fetchData();
    _startPolling();
  }

  void _startPolling() {
    // Background polling refreshes data every 30 seconds
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      fetchData();
    });
  }

  Future<void> fetchData() async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    try {
      _metric = await _repository.fetchRetentionMetric();
    } catch (e) {
      // Error handling would go here
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Triggered by pull-to-refresh manual sync
  Future<void> manualRefresh() async {
    await fetchData();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }
}

/// M3 Elevated Card Level 2 (3dp) widget for displaying step completion state.
/// Implements single-column mobile layout (<600dp) and multi-column desktop (>=840dp).
class MessageRetentionCardGen01710 extends StatefulWidget {
  const MessageRetentionCardGen01710({super.key});

  @override
  State<MessageRetentionCardGen01710> createState() => _MessageRetentionCardGen01710State();
}

class _MessageRetentionCardGen01710State extends State<MessageRetentionCardGen01710> {
  late final MessageRetentionController _controller;

  @override
  void initState() {
    super.initState();
    _controller = MessageRetentionController();
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final metric = _controller.metric;

    return RefreshIndicator(
      onRefresh: _controller.manualRefresh,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Responsive UX: single-column on mobile (<600dp), multi-column on desktop (>=840dp)
          final bool isDesktop = constraints.maxWidth >= 840;

          return Card(
            elevation: 3.0, // M3 Elevated Cards Level 2 (3dp)
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Flex(
                direction: isDesktop ? Axis.horizontal : Axis.vertical,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'GEN-01710: Traffic Simulation Retention',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          metric?.metricName ?? 'Loading metric configuration...',
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16.0),
                        if (metric != null) ...[
                          Text(
                            'Current Value: ${metric.currentValue.toStringAsFixed(2)}%',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: metric.isPassing ? colorScheme.primary : colorScheme.error,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            'Floor Threshold: ${metric.floorBoundary}% | Optimal: ${metric.optimalTarget}%',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ] else if (_controller.isLoading)
                          const LinearProgressIndicator()
                        else
                          Text(
                            'Awaiting data stream...',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (isDesktop) const SizedBox(width: 24.0),
                  if (!isDesktop) const SizedBox(height: 16.0),
                  // M3 Status Chip for health indicator with 48x48dp touch target
                  SizedBox(
                    height: 48.0,
                    width: 48.0,
                    child: Center(
                      child: ActionChip(
                        avatar: Icon(
                          metric == null
                              ? Icons.sync
                              : (metric.isPassing ? Icons.check_circle : Icons.error),
                          color: metric == null
                              ? colorScheme.onSurfaceVariant
                              : (metric.isPassing ? colorScheme.primary : colorScheme.error),
                        ),
                        label: Text(
                          metric?.status ?? 'N/A',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: metric?.isPassing == false ? colorScheme.error : null,
                          ),
                        ),
                        onPressed: () {
                          // Deep-link drill-down action
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Drill-down to detailed logs...'),
                              behavior: SnackBarBehavior.floating,
                              action: SnackBarAction(
                                label: 'OK',
                                onPressed: () {},
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}