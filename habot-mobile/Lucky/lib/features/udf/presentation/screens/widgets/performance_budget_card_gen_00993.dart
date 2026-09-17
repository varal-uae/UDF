// GEN-00993 — Performance Budget Compliance Dashboard Card.
// Displays FCP, TTI, and Bundle Size thresholds with M3 ElevatedCard, status chips, 30s polling, pull-to-refresh, and bottom sheet configuration. Single-column mobile (<600dp), multi-column desktop (>=840dp). 48x48dp touch targets.

import 'dart:async';
import 'package:flutter/material.dart';

/// Mock data model representing performance budget metrics.
class PerformanceMetric {
  final String name;
  final String threshold;
  final double currentValue;
  final bool isPassing;

  const PerformanceMetric({
    required this.name,
    required this.threshold,
    required this.currentValue,
    required this.isPassing,
  });
}

/// Mock repository supplying local performance budget data.
class PerformanceBudgetMockRepository {
  static const List<PerformanceMetric> mockMetrics = [
    PerformanceMetric(
      name: 'First Contentful Paint (FCP)',
      threshold: '< 1.2s',
      currentValue: 0.95,
      isPassing: true,
    ),
    PerformanceMetric(
      name: 'Time to Interactive (TTI)',
      threshold: '< 1.8s',
      currentValue: 1.42,
      isPassing: true,
    ),
    PerformanceMetric(
      name: 'Bundle Size',
      threshold: '< 20MB',
      currentValue: 14.5,
      isPassing: true,
    ),
  ];

  Future<List<PerformanceMetric>> fetchMetrics() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return mockMetrics;
  }
}

/// Main widget implementing the performance budget compliance dashboard.
class PerformanceBudgetCardGen00993 extends StatefulWidget {
  const PerformanceBudgetCardGen00993({super.key});

  @override
  State<PerformanceBudgetCardGen00993> createState() => _PerformanceBudgetCardGen00993State();
}

class _PerformanceBudgetCardGen00993State extends State<PerformanceBudgetCardGen00993> {
  final PerformanceBudgetMockRepository _repository = PerformanceBudgetMockRepository();
  List<PerformanceMetric> _metrics = [];
  bool _isLoading = true;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _loadMetrics();
    // Background polling refreshes data every 30 seconds.
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) => _loadMetrics());
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadMetrics() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    final data = await _repository.fetchMetrics();
    if (!mounted) return;
    setState(() {
      _metrics = data;
      _isLoading = false;
    });
  }

  void _openConfigurationBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Configure Performance Budgets',
                style: Theme.of(ctx).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'KMS_Key_Ring_Path',
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
                controller: TextEditingController(text: 'projects/habot-prod/locations/global/keyRings/udf-ring'),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'FCP Threshold (s)',
                  border: OutlineInputBorder(),
                ),
                controller: TextEditingController(text: '1.2'),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'TTI Threshold (s)',
                  border: OutlineInputBorder(),
                ),
                controller: TextEditingController(text: '1.8'),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Bundle Size Threshold (MB)',
                  border: OutlineInputBorder(),
                ),
                controller: TextEditingController(text: '20'),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48, // 48x48dp touch target
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Configuration saved successfully.'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: const Text('Save Configuration'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool allPassing = _metrics.isNotEmpty && _metrics.every((m) => m.isPassing);
    final String overallStatus = allPassing ? 'Pass' : 'Fail';

    return RefreshIndicator(
      onRefresh: _loadMetrics,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // M3 responsive layout: single-column on mobile (<600dp), multi-column on desktop (>=840dp).
          final bool isDesktop = constraints.maxWidth >= 840;
          final int crossAxisCount = isDesktop ? 3 : 1;

          return CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Core Web Vitals Engine',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      SizedBox(
                        height: 48,
                        width: 48, // 48x48dp touch target
                        child: IconButton(
                          icon: const Icon(Icons.settings),
                          onPressed: () => _openConfigurationBottomSheet(context),
                          tooltip: 'Configure Thresholds',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: _buildOverallStatusCard(context, overallStatus),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: _isLoading
                    ? const SliverToBoxAdapter(
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          mainAxisSpacing: 16.0,
                          crossAxisSpacing: 16.0,
                          childAspectRatio: isDesktop ? 2.5 : 3.0,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => _buildMetricCard(context, _metrics[index]),
                          childCount: _metrics.length,
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Engineering console dashboard displays step health via M3 Elevated Card with inline status chip.
  Widget _buildOverallStatusCard(BuildContext context, String status) {
    final bool isPass = status == 'Pass';
    return Card(
      elevation: 3.0, // M3 Elevated Cards Level 2 (3dp)
      color: isPass
          ? Theme.of(context).colorScheme.primaryContainer
          : Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Performance Budget Compliance',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: isPass
                              ? Theme.of(context).colorScheme.onPrimaryContainer
                              : Theme.of(context).colorScheme.onErrorContainer,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Floor Boundary: 100% | Optimal Target: 100%',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isPass
                              ? Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.7)
                              : Theme.of(context).colorScheme.onErrorContainer.withOpacity(0.7),
                        ),
                  ),
                ],
              ),
            ),
            // M3 Status Chips for health indicators
            Chip(
              avatar: Icon(
                isPass ? Icons.check_circle : Icons.cancel,
                size: 18,
                color: isPass
                    ? Theme.of(context).colorScheme.onPrimaryContainer
                    : Theme.of(context).colorScheme.onErrorContainer,
              ),
              label: Text(
                status,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isPass
                      ? Theme.of(context).colorScheme.onPrimaryContainer
                      : Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
              backgroundColor: Colors.transparent,
              side: BorderSide.none,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(BuildContext context, PerformanceMetric metric) {
    return Card(
      elevation: 3.0, // M3 Elevated Cards Level 2 (3dp)
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          // Deep-link drill-down placeholder
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Drill-down into ${metric.name} triggered.')),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                metric.name,
                style: Theme.of(context).textTheme.titleSmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current: ${metric.currentValue}${metric.name.contains('Size') ? ' MB' : ' s'}',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        'Target: ${metric.threshold}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  // M3 Status Chips for health indicators
                  Chip(
                    label: Text(metric.isPassing ? 'Pass' : 'Fail'),
                    backgroundColor: metric.isPassing
                        ? Theme.of(context).colorScheme.secondaryContainer
                        : Theme.of(context).colorScheme.errorContainer,
                    labelStyle: TextStyle(
                      color: metric.isPassing
                          ? Theme.of(context).colorScheme.onSecondaryContainer
                          : Theme.of(context).colorScheme.onErrorContainer,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
