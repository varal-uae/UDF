// GEN-01059 — Baseline Funnel View Template with Single Vertical Scroll Column.
// Restricts baseline funnel view templates to a single vertical scroll column on mobile (<600dp) and multi-column on desktop (>=840dp) using M3 Elevated Cards, Status Chips, 48x48dp touch targets, and 30-second background polling with pull-to-refresh.

import 'dart:async';
import 'package:flutter/material.dart';

enum StepHealth { good, average, poor }

class FunnelStepData {
  final String id;
  final String title;
  final StepHealth health;
  final double completionRate;
  final DateTime timestamp;

  const FunnelStepData({
    required this.id,
    required this.title,
    required this.health,
    required this.completionRate,
    required this.timestamp,
  });
}

class MockFunnelRepository {
  static List<FunnelStepData> fetchSteps() {
    return [
      FunnelStepData(
        id: 'trace_001',
        title: 'User Registration',
        health: StepHealth.good,
        completionRate: 0.85,
        timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
      ),
      FunnelStepData(
        id: 'trace_002',
        title: 'Profile Completion',
        health: StepHealth.average,
        completionRate: 0.65,
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      FunnelStepData(
        id: 'trace_003',
        title: 'Document Upload',
        health: StepHealth.poor,
        completionRate: 0.42,
        timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
      ),
      FunnelStepData(
        id: 'trace_004',
        title: 'Verification Pending',
        health: StepHealth.good,
        completionRate: 0.91,
        timestamp: DateTime.now(),
      ),
    ];
  }
}

class FunnelViewTemplate extends StatefulWidget {
  const FunnelViewTemplate({super.key});

  @override
  State<FunnelViewTemplate> createState() => _FunnelViewTemplateState();
}

class _FunnelViewTemplateState extends State<FunnelViewTemplate> {
  List<FunnelStepData> _steps = [];
  Timer? _pollingTimer;
  final GlobalKey<RefreshIndicatorState> _refreshKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _loadData();
    _startPolling();
  }

  void _loadData() {
    setState(() {
      _steps = MockFunnelRepository.fetchSteps();
    });
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) {
        _loadData();
      }
    });
  }

  Future<void> _handleRefresh() async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Funnel data synchronized successfully.'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  String _getQualitativeOutput(double rate) {
    if (rate >= 0.8) return 'Good';
    if (rate >= 0.6) return 'Average';
    return 'Poor';
  }

  Color _getHealthColor(StepHealth health, ThemeData theme) {
    switch (health) {
      case StepHealth.good:
        return theme.colorScheme.primary;
      case StepHealth.average:
        return theme.colorScheme.tertiary;
      case StepHealth.poor:
        return theme.colorScheme.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mobile Conversion Funnel'),
        centerTitle: false,
        elevation: 0,
      ),
      body: RefreshIndicator(
        key: _refreshKey,
        onRefresh: _handleRefresh,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 840;
            final crossAxisCount = isDesktop ? 2 : 1;

            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(16.0),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: 16.0,
                      crossAxisSpacing: 16.0,
                      childAspectRatio: isDesktop ? 2.5 : 2.2,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final step = _steps[index];
                        return _buildElevatedCard(step, theme);
                      },
                      childCount: _steps.length,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildElevatedCard(FunnelStepData step, ThemeData theme) {
    final healthColor = _getHealthColor(step.health, theme);
    final qualitative = _getQualitativeOutput(step.completionRate);

    return Card(
      elevation: 3.0, // M3 Elevated Cards Level 2 (3dp)
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          _showConfigurationSheet(step, theme);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      step.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Chip(
                    label: Text(
                      qualitative,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    backgroundColor: healthColor.withOpacity(0.15),
                    side: BorderSide.none,
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  Icon(
                    step.health == StepHealth.good
                        ? Icons.check_circle_outline
                        : step.health == StepHealth.average
                            ? Icons.warning_amber_rounded
                            : Icons.error_outline,
                    color: healthColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${(step.completionRate * 100).toStringAsFixed(1)}%',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: healthColor,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'ID: ${step.id}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showConfigurationSheet(FunnelStepData step, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Configure: ${step.title}',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Text(
                'Trace ID: ${step.id}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Baymard Institute Mobile UX Benchmark Target: 0.6 - 0.95',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Threshold Override',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 48, // 48x48dp touch target
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Configuration saved for ${step.title}'),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    );
                  },
                  child: const Text('Apply Configuration'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}
