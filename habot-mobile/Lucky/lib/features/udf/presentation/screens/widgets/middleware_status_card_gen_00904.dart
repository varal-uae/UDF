// GEN-00904 — Middleware Status Card & Skeleton Wrapper for Cloud Run Cache-Control Monitoring.
// Displays M3 Elevated Card with status chip, background polling every 30s, pull-to-refresh, and conditional skeleton rendering based on isLoading state.

import 'dart:async';
import 'package:flutter/material.dart';

enum MiddlewareStatus { complete, notComplete, loading }

class MiddlewareMetricsMock {
  final String stepId;
  final String metricName;
  final double overheadMs;
  final MiddlewareStatus status;
  final DateTime timestamp;

  const MiddlewareMetricsMock({
    required this.stepId,
    required this.metricName,
    required this.overheadMs,
    required this.status,
    required this.timestamp,
  });
}

class MiddlewareMockRepository {
  static const List<MiddlewareMetricsMock> _mockData = [
    MiddlewareMetricsMock(
      stepId: 'GEN-00904',
      metricName: 'Middleware Execution Overhead',
      overheadMs: 0.4,
      status: MiddlewareStatus.complete,
      timestamp: DateTime(2026, 9, 17, 10, 0),
    ),
  ];

  Future<MiddlewareMetricsMock> fetchMetrics() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return _mockData.first;
  }
}

class MiddlewareStatusCardController extends ChangeNotifier {
  final MiddlewareMockRepository _repository = MiddlewareMockRepository();
  Timer? _pollingTimer;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  MiddlewareMetricsMock? _metrics;
  MiddlewareMetricsMock? get metrics => _metrics;

  MiddlewareStatusCardController() {
    _startPolling();
  }

  void _startPolling() {
    fetchData(isManualRefresh: false);
    _pollingTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => fetchData(isManualRefresh: false),
    );
  }

  Future<void> fetchData({bool isManualRefresh = false}) async {
    if (!isManualRefresh && !_isLoading) {
      _isLoading = true;
      notifyListeners();
    } else if (isManualRefresh) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      _metrics = await _repository.fetchMetrics();
    } catch (_) {
      _metrics = null;
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

class MiddlewareSkeletonWrapper extends StatelessWidget {
  final bool isLoading;
  final Widget child;

  const MiddlewareSkeletonWrapper({
    super.key,
    required this.isLoading,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildSkeleton(context);
    }
    return child;
  }

  Widget _buildSkeleton(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 3.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 20,
              width: 180,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(4.0),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 16,
              width: 120,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(4.0),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: 16,
              width: 100,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(4.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MiddlewareStatusCard extends StatefulWidget {
  const MiddlewareStatusCard({super.key});

  @override
  State<MiddlewareStatusCard> createState() => _MiddlewareStatusCardState();
}

class _MiddlewareStatusCardState extends State<MiddlewareStatusCard> {
  late final MiddlewareStatusCardController _controller;

  @override
  void initState() {
    super.initState();
    _controller = MiddlewareStatusCardController();
    _controller.addListener(_onStateChanged);
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onStateChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return RefreshIndicator(
      onRefresh: () => _controller.fetchData(isManualRefresh: true),
      color: colorScheme.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: MiddlewareSkeletonWrapper(
            isLoading: _controller.isLoading,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 600;
                return isMobile
                    ? _buildMobileLayout(textTheme, colorScheme)
                    : _buildDesktopLayout(textTheme, colorScheme);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(TextTheme textTheme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCardHeader(textTheme, colorScheme),
        const SizedBox(height: 16),
        _buildMetricsBody(textTheme, colorScheme),
      ],
    );
  }

  Widget _buildDesktopLayout(TextTheme textTheme, ColorScheme colorScheme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 2, child: _buildCardHeader(textTheme, colorScheme)),
        const SizedBox(width: 24),
        Expanded(flex: 3, child: _buildMetricsBody(textTheme, colorScheme)),
      ],
    );
  }

  Widget _buildCardHeader(TextTheme textTheme, ColorScheme colorScheme) {
    final metrics = _controller.metrics;
    final isComplete = metrics?.status == MiddlewareStatus.complete;

    return Card(
      elevation: 3.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cache-Control Middleware',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'GEN-00904',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Chip(
              avatar: Icon(
                isComplete ? Icons.check_circle : Icons.pending,
                size: 18,
                color: isComplete
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onErrorContainer,
              ),
              label: Text(
                isComplete ? 'Complete' : 'Not Complete',
                style: textTheme.labelLarge,
              ),
              backgroundColor: isComplete
                  ? colorScheme.primaryContainer
                  : colorScheme.errorContainer,
              labelStyle: TextStyle(
                color: isComplete
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onErrorContainer,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsBody(TextTheme textTheme, ColorScheme colorScheme) {
    final metrics = _controller.metrics;
    final overhead = metrics?.overheadMs ?? 0.0;
    final isOptimal = overhead <= 0.5;
    final isWithinFloor = overhead <= 2.0;

    return Card(
      elevation: 3.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Middleware Execution Overhead',
              style: textTheme.titleSmall,
            ),
            const SizedBox(height: 16),
            _buildMetricRow(
              'Current Value',
              '${overhead.toStringAsFixed(2)} ms',
              isOptimal
                  ? colorScheme.primary
                  : (isWithinFloor ? colorScheme.tertiary : colorScheme.error),
              textTheme,
            ),
            const Divider(height: 24),
            _buildMetricRow(
              'Optimal Target',
              '\u2264 0.5 ms',
              colorScheme.onSurfaceVariant,
              textTheme,
            ),
            const SizedBox(height: 8),
            _buildMetricRow(
              'Floor Boundary',
              '\u2264 2.0 ms',
              colorScheme.onSurfaceVariant,
              textTheme,
            ),
            const SizedBox(height: 8),
            _buildMetricRow(
              'Ceiling Boundary',
              '5.0 ms',
              colorScheme.onSurfaceVariant,
              textTheme,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 48,
              width: double.infinity,
              child: FilledButton.tonalIcon(
                onPressed: _showConfigurationSheet,
                icon: const Icon(Icons.settings_outlined, size: 20),
                label: const Text('View Configuration'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(
    String label,
    String value,
    Color valueColor,
    TextTheme textTheme,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: textTheme.bodyMedium),
        Text(
          value,
          style: textTheme.bodyMedium?.copyWith(
            color: valueColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  void _showConfigurationSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.0)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 32,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Django Middleware Configuration',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      children: const [
                        ListTile(
                          leading: Icon(Icons.http),
                          title: Text('Cache-Control Header Injection'),
                          subtitle: Text('Enabled via custom middleware class'),
                          dense: true,
                        ),
                        ListTile(
                          leading: Icon(Icons.speed),
                          title: Text('Execution Overhead Limit'),
                          subtitle: Text('Strict floor \u2264 2ms enforced in CI/CD'),
                          dense: true,
                        ),
                        ListTile(
                          leading: Icon(Icons.cloud_sync),
                          title: Text('Cloud Run Auto-Scaling'),
                          subtitle: Text('Thresholds configured per GCP blueprint'),
                          dense: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 48,
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Configuration acknowledged.'),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            action: SnackBarAction(
                              label: 'DISMISS',
                              onPressed: () {},
                            ),
                          ),
                        );
                      },
                      child: const Text('Confirm & Close'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}