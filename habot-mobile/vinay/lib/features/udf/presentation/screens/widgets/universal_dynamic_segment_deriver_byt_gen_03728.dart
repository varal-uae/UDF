// GEN-03728 — Universal Dynamic Segment Deriver Byt Component.
// Reusable M3 Elevated Card widget displaying segment deriver step completion state with status chips, 48x48dp touch targets, and responsive single/multi-column layout support.

import 'package:flutter/material.dart';

enum SegmentReusabilityStatus { high, medium, low }

class SegmentDeriverStepData {
  final String stepId;
  final String title;
  final SegmentReusabilityStatus status;
  final double reusabilityScore;
  final DateTime lastUpdated;
  final bool isHealthy;

  const SegmentDeriverStepData({
    required this.stepId,
    required this.title,
    required this.status,
    required this.reusabilityScore,
    required this.lastUpdated,
    required this.isHealthy,
  });
}

class MockSegmentDeriverRepository {
  static List<SegmentDeriverStepData> getMockSteps() {
    return [
      SegmentDeriverStepData(
        stepId: 'GEN-03728-01',
        title: 'Universal Dynamic Segment Deriver Byt Component',
        status: SegmentReusabilityStatus.high,
        reusabilityScore: 0.95,
        lastUpdated: DateTime.now().subtract(const Duration(minutes: 2)),
        isHealthy: true,
      ),
      SegmentDeriverStepData(
        stepId: 'GEN-03728-02',
        title: 'Segment Configuration Validation',
        status: SegmentReusabilityStatus.medium,
        reusabilityScore: 0.82,
        lastUpdated: DateTime.now().subtract(const Duration(minutes: 5)),
        isHealthy: true,
      ),
      SegmentDeriverStepData(
        stepId: 'GEN-03728-03',
        title: 'CI/CD Pipeline Gate Check',
        status: SegmentReusabilityStatus.low,
        reusabilityScore: 0.45,
        lastUpdated: DateTime.now().subtract(const Duration(minutes: 10)),
        isHealthy: false,
      ),
    ];
  }
}

class UniversalDynamicSegmentDeriverBytComponent extends StatefulWidget {
  final VoidCallback? onDeepLinkDrillDown;

  const UniversalDynamicSegmentDeriverBytComponent({
    super.key,
    this.onDeepLinkDrillDown,
  });

  @override
  State<UniversalDynamicSegmentDeriverBytComponent> createState() =>
      _UniversalDynamicSegmentDeriverBytComponentState();
}

class _UniversalDynamicSegmentDeriverBytComponentState
    extends State<UniversalDynamicSegmentDeriverBytComponent> {
  late List<SegmentDeriverStepData> _steps;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _steps = MockSegmentDeriverRepository.getMockSteps();
    _startPolling();
  }

  void _startPolling() {
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted) {
        _refreshData();
        _startPolling();
      }
    });
  }

  Future<void> _refreshData() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() {
        _steps = MockSegmentDeriverRepository.getMockSteps();
        _isLoading = false;
      });
    }
  }

  Color _getStatusColor(SegmentReusabilityStatus status, ThemeData theme) {
    switch (status) {
      case SegmentReusabilityStatus.high:
        return theme.colorScheme.primary;
      case SegmentReusabilityStatus.medium:
        return theme.colorScheme.tertiary;
      case SegmentReusabilityStatus.low:
        return theme.colorScheme.error;
    }
  }

  String _getStatusLabel(SegmentReusabilityStatus status) {
    switch (status) {
      case SegmentReusabilityStatus.high:
        return 'High';
      case SegmentReusabilityStatus.medium:
        return 'Medium';
      case SegmentReusabilityStatus.low:
        return 'Low';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTabletOrDesktop = screenWidth >= 840;

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (isTabletOrDesktop) {
            return _buildMultiColumnLayout(theme, constraints);
          }
          return _buildSingleColumnLayout(theme, isMobile);
        },
      ),
    );
  }

  Widget _buildSingleColumnLayout(ThemeData theme, bool isMobile) {
    return ListView.builder(
      padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
      itemCount: _steps.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          if (_isLoading) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: LinearProgressIndicator(),
            );
          }
          return const SizedBox.shrink();
        }
        final step = _steps[index - 1];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: _buildStepCard(step, theme),
        );
      },
    );
  }

  Widget _buildMultiColumnLayout(ThemeData theme, BoxConstraints constraints) {
    final crossAxisCount = constraints.maxWidth >= 1200 ? 3 : 2;
    return GridView.builder(
      padding: const EdgeInsets.all(24.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        childAspectRatio: 1.4,
      ),
      itemCount: _steps.length,
      itemBuilder: (context, index) {
        return _buildStepCard(_steps[index], theme);
      },
    );
  }

  Widget _buildStepCard(SegmentDeriverStepData step, ThemeData theme) {
    final statusColor = _getStatusColor(step.status, theme);

    return Semantics(
      label: '${step.title}, Status: ${_getStatusLabel(step.status)}, '
          'Reusability Score: ${(step.reusabilityScore * 100).toStringAsFixed(0)} percent',
      button: true,
      child: InkWell(
        onTap: () {
          widget.onDeepLinkDrillDown?.call();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Navigating to details for ${step.stepId}'),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12.0),
        child: Card(
          elevation: 3.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
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
                    Expanded(
                      child: Text(
                        step.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Chip(
                      label: Text(
                        _getStatusLabel(step.status),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      backgroundColor: statusColor,
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ],
                ),
                const SizedBox(height: 12.0),
                Row(
                  children: [
                    Icon(
                      step.isHealthy ? Icons.check_circle_outline : Icons.error_outline,
                      color: step.isHealthy
                          ? theme.colorScheme.primary
                          : theme.colorScheme.error,
                      size: 20.0,
                    ),
                    const SizedBox(width: 8.0),
                    Text(
                      'Health: ${step.isHealthy ? "Passing" : "Failing"}',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                Row(
                  children: [
                    Text(
                      'Reusability:',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: step.reusabilityScore.clamp(0.0, 1.0),
                        minHeight: 6.0,
                        backgroundColor: theme.colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                        borderRadius: BorderRadius.circular(3.0),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Text(
                      '${(step.reusabilityScore * 100).toStringAsFixed(0)}%',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Align(
                  alignment: Alignment.bottomRight,
                  child: SizedBox(
                    height: 48.0,
                    width: 48.0,
                    child: IconButton(
                      icon: const Icon(Icons.open_in_new),
                      tooltip: 'View Details',
                      onPressed: () {
                        widget.onDeepLinkDrillDown?.call();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
