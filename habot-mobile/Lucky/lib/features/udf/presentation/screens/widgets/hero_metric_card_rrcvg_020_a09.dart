// RRCVG-020-A09 — Core Release List Hero Metric Card with Expandable Detail Filters.
// Implements tapping actions to expand detail filters for granular log data, responsive layouts (grid on desktop, carousel/column on mobile), headline-large typography, and subtle elevation highlights.

import 'package:flutter/material.dart';

/// Mock data model representing atomic-level step execution fields.
class StepExecutionRecord {
  final String stepExecutionId;
  final String executionStatus;
  final DateTime executionTimestamp;
  final String stepOutcome;
  final String userId;
  final String completionStatus;

  const StepExecutionRecord({
    required this.stepExecutionId,
    required this.executionStatus,
    required this.executionTimestamp,
    required this.stepOutcome,
    required this.userId,
    required this.completionStatus,
  });
}

/// Local mock repository providing realistic dummy data.
class MockStepExecutionRepository {
  static const List<StepExecutionRecord> records = [
    StepExecutionRecord(
      stepExecutionId: 'STEP-001',
      executionStatus: 'Success',
      executionTimestamp: DateTime(2026, 9, 24, 10, 15),
      stepOutcome: 'Validated',
      userId: 'USR-8821',
      completionStatus: 'Complete',
    ),
    StepExecutionRecord(
      stepExecutionId: 'STEP-002',
      executionStatus: 'Failed',
      executionTimestamp: DateTime(2026, 9, 24, 10, 18),
      stepOutcome: 'Timeout',
      userId: 'USR-8822',
      completionStatus: 'Incomplete',
    ),
    StepExecutionRecord(
      stepExecutionId: 'STEP-003',
      executionStatus: 'Success',
      executionTimestamp: DateTime(2026, 9, 24, 10, 22),
      stepOutcome: 'Processed',
      userId: 'USR-8821',
      completionStatus: 'Complete',
    ),
    StepExecutionRecord(
      stepExecutionId: 'STEP-004',
      executionStatus: 'Pending',
      executionTimestamp: DateTime(2026, 9, 24, 10, 25),
      stepOutcome: 'Awaiting Input',
      userId: 'USR-8823',
      completionStatus: 'Incomplete',
    ),
  ];
}

/// A responsive Hero Metric Card that expands to show granular log data filters.
/// Applies Material 3 styling, headline-large typography, and subtle elevation.
class HeroMetricCard extends StatefulWidget {
  final String title;
  final String primaryStatistic;
  final List<StepExecutionRecord> records;

  const HeroMetricCard({
    super.key,
    required this.title,
    required this.primaryStatistic,
    required this.records,
  });

  @override
  State<HeroMetricCard> createState() => _HeroMetricCardState();
}

class _HeroMetricCardState extends State<HeroMetricCard>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    return Card(
      // Subtle elevation highlights to draw attention to interactive card elements
      elevation: _isExpanded ? 4.0 : 1.5,
      shadowColor: theme.colorScheme.shadow.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withOpacity(0.5),
          width: 1.0,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: _toggleExpand,
        borderRadius: BorderRadius.circular(16.0),
        hoverColor: theme.colorScheme.primaryContainer.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: theme.colorScheme.primary,
                  ),
                ],
              ),
              const SizedBox(height: 16.0),

              // Primary Statistic - Format using proper bold type scaling options (headline-large)
              Text(
                widget.primaryStatistic,
                style: textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8.0),

              // Refine spacing around toggle layouts to ensure clear separation from adjacent fields
              const Divider(height: 32.0, thickness: 1.0),

              // Expandable Detail Filters for Granular Log Data
              SizeTransition(
                sizeFactor: _expandAnimation,
                axisAlignment: -1.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Granular Execution Logs',
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16.0),

                    // Multiple inline metric card grids transform into clean, swipeable carousels
                    // or single columns on mobile displays
                    if (isDesktop)
                      _buildDesktopGrid(theme)
                    else
                      _buildMobileCarousel(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Ensure metric cards resize and distribute rows evenly across fluid desktop design layouts
  Widget _buildDesktopGrid(ThemeData theme) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 320.0,
            mainAxisExtent: 140.0,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
          ),
          itemCount: widget.records.length,
          itemBuilder: (context, index) {
            return _LogDetailCard(record: widget.records[index]);
          },
        );
      },
    );
  }

  /// Swipeable carousel / single column on mobile displays
  Widget _buildMobileCarousel() {
    if (widget.records.length <= 2) {
      return Column(
        children: widget.records
            .map((r) => Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: _LogDetailCard(record: r),
                ))
            .toList(),
      );
    }

    return SizedBox(
      height: 150.0,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: widget.records.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12.0),
        itemBuilder: (context, index) {
          return SizedBox(
            width: 260.0,
            child: _LogDetailCard(record: widget.records[index]),
          );
        },
      ),
    );
  }
}

/// Individual log detail card component
class _LogDetailCard extends StatelessWidget {
  final StepExecutionRecord record;

  const _LogDetailCard({required this.record});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    final Color statusColor;
    switch (record.executionStatus.toLowerCase()) {
      case 'success':
        statusColor = Colors.green.shade700;
        break;
      case 'failed':
        statusColor = Colors.red.shade700;
        break;
      default:
        statusColor = Colors.orange.shade700;
    }

    return Card(
      elevation: 0.5,
      color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.3)),
      ),
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
                  record.stepExecutionId,
                  style: textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text(
                    record.executionStatus,
                    style: textTheme.labelSmall?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              'Outcome: ${record.stepOutcome}',
              style: textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4.0),
            Text(
              'User: ${record.userId} | Status: ${record.completionStatus}',
              style: textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4.0),
            Text(
              '${record.executionTimestamp.year}-'
              '${record.executionTimestamp.month.toString().padLeft(2, '0')}-'
              '${record.executionTimestamp.day.toString().padLeft(2, '0')} '
              '${record.executionTimestamp.hour.toString().padLeft(2, '0')}:'
              '${record.executionTimestamp.minute.toString().padLeft(2, '0')}',
              style: textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Preview wrapper to demonstrate the Hero Metric Card in isolation.
class HeroMetricCardPreview extends StatelessWidget {
  const HeroMetricCardPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Core Release List - Hero Metric'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200.0),
            child: HeroMetricCard(
              title: 'Process Execution Fidelity',
              primaryStatistic: '98.5%',
              records: MockStepExecutionRepository.records,
            ),
          ),
        ),
      ),
    );
  }
}