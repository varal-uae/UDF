// SCTSS-019-A03 — Expiry Timeline Tracker Visual Data Map.
// Scalable horizontal timeline UI component for tracking legal restrictions with read-only dates, skeleton loading, and self-chasing padlock overlay on rehire actions.

import 'package:flutter/material.dart';

/// Atomic-level data model for timeline mapping.
class TimelineMappingData {
  final String sourceElementId;
  final String targetElementId;
  final String mappingRule;
  final String mappingStatus;
  final bool mappingValidation;

  const TimelineMappingData({
    required this.sourceElementId,
    required this.targetElementId,
    required this.mappingRule,
    required this.mappingStatus,
    required this.mappingValidation,
  });
}

/// Represents a single employee's non-compete or legal restriction timeline.
class ExpiryTimelineEntry {
  final String employeeId;
  final String employeeName;
  final String restrictionType;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final TimelineMappingData mappingData;

  const ExpiryTimelineEntry({
    required this.employeeId,
    required this.employeeName,
    required this.restrictionType,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    required this.mappingData,
  });
}

/// Mock repository providing realistic local data for the timeline tracker.
class TimelineTrackerMockRepository {
  static List<ExpiryTimelineEntry> getMockTimelines() {
    final now = DateTime.now();
    return [
      ExpiryTimelineEntry(
        employeeId: 'EMP-001',
        employeeName: 'John Doe',
        restrictionType: 'Non-Compete Agreement',
        startDate: now.subtract(const Duration(days: 60)),
        endDate: now.add(const Duration(days: 120)),
        isActive: true,
        mappingData: const TimelineMappingData(
          sourceElementId: 'SRC-NC-01',
          targetElementId: 'TGT-EMP-001',
          mappingRule: 'Direct Legal Binding',
          mappingStatus: 'Validated',
          mappingValidation: true,
        ),
      ),
      ExpiryTimelineEntry(
        employeeId: 'EMP-002',
        employeeName: 'Jane Smith',
        restrictionType: 'Non-Disclosure Agreement',
        startDate: now.subtract(const Duration(days: 200)),
        endDate: now.subtract(const Duration(days: 20)),
        isActive: false,
        mappingData: const TimelineMappingData(
          sourceElementId: 'SRC-NDA-02',
          targetElementId: 'TGT-EMP-002',
          mappingRule: 'Post-Exit Compliance',
          mappingStatus: 'Expired',
          mappingValidation: true,
        ),
      ),
      ExpiryTimelineEntry(
        employeeId: 'EMP-003',
        employeeName: 'Ahmed Al Farsi',
        restrictionType: 'Non-Solicitation Clause',
        startDate: now.subtract(const Duration(days: 10)),
        endDate: now.add(const Duration(days: 355)),
        isActive: true,
        mappingData: const TimelineMappingData(
          sourceElementId: 'SRC-NS-03',
          targetElementId: 'TGT-EMP-003',
          mappingRule: 'Conditional Restriction',
          mappingStatus: 'Active Monitoring',
          mappingValidation: true,
        ),
      ),
    ];
  }
}

/// Main dashboard widget aggregating expiry timelines.
/// Implements 8dp baseline grid, explicit layout margins, and vertical responsive detail rows.
class TimelineTrackerDashboard extends StatefulWidget {
  const TimelineTrackerDashboard({super.key});

  @override
  State<TimelineTrackerDashboard> createState() => _TimelineTrackerDashboardState();
}

class _TimelineTrackerDashboardState extends State<TimelineTrackerDashboard> {
  late Future<List<ExpiryTimelineEntry>> _timelinesFuture;

  @override
  void initState() {
    super.initState();
    // Configure listeners to fire automatically on every app launch (simulated via initState fetch)
    _loadTimelines();
  }

  void _loadTimelines() {
    _timelinesFuture = Future.delayed(
      const Duration(milliseconds: 1500), // Simulate database history fetch
      () => TimelineTrackerMockRepository.getMockTimelines(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post-Exit Compliance Dashboard'),
        centerTitle: false,
      ),
      body: FutureBuilder<List<ExpiryTimelineEntry>>(
        future: _timelinesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const _TimelineSkeletonLoader();
          }

          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No timeline data available.'));
          }

          final timelines = snapshot.data!;

          // Frame listing components inside explicit layout margins (8dp baseline grid)
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ListView.separated(
              itemCount: timelines.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16.0),
              itemBuilder: (context, index) {
                final entry = timelines[index];
                return _TimelineCard(entry: entry);
              },
            ),
          );
        },
      ),
    );
  }
}

/// Skeleton cards included during active database history fetches.
class _TimelineSkeletonLoader extends StatelessWidget {
  const _TimelineSkeletonLoader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView.separated(
        itemCount: 3,
        separatorBuilder: (_, __) => const SizedBox(height: 16.0),
        itemBuilder: (context, index) {
          return Card(
            elevation: 0,
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 16.0, width: 120.0, color: Colors.grey.shade300),
                  const SizedBox(height: 16.0),
                  Container(height: 24.0, width: double.infinity, color: Colors.grey.shade300),
                  const SizedBox(height: 16.0),
                  Container(height: 16.0, width: 200.0, color: Colors.grey.shade300),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Node-based timeline card organizing complex change parameters into vertical responsive detail rows.
class _TimelineCard extends StatelessWidget {
  final ExpiryTimelineEntry entry;

  const _TimelineCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Card(
      elevation: 1.0,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0), // 8dp baseline grid alignment
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    entry.employeeName,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildStatusChip(theme),
              ],
            ),
            const SizedBox(height: 8.0),
            Text(
              entry.restrictionType,
              style: textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16.0),

            // Horizontal Timeline Component optimized for mobile side-scrolling gestures
            SizedBox(
              height: 64.0,
              child: _HorizontalGanttTimeline(
                startDate: entry.startDate,
                endDate: entry.endDate,
                isActive: entry.isActive,
              ),
            ),
            const SizedBox(height: 16.0),

            // Vertical responsive detail rows
            _DetailRow(label: 'Start Date', value: _formatDate(entry.startDate)),
            const Divider(height: 16.0, thickness: 1.0),
            _DetailRow(label: 'End Date', value: _formatDate(entry.endDate)),
            const Divider(height: 16.0, thickness: 1.0),
            _DetailRow(label: 'Mapping Status', value: entry.mappingData.mappingStatus),
            const Divider(height: 16.0, thickness: 1.0),
            _DetailRow(label: 'Validation', value: entry.mappingData.mappingValidation ? 'Pass' : 'Fail'),
            const SizedBox(height: 24.0),

            // Self-Chasing: Active non-compete visually overlays a padlock icon on "Rehire" button
            Align(
              alignment: Alignment.centerRight,
              child: _RehireButton(isLocked: entry.isActive),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(ThemeData theme) {
    return Chip(
      label: Text(
        entry.isActive ? 'Active' : 'Expired',
        style: theme.textTheme.labelSmall?.copyWith(
          color: entry.isActive ? theme.colorScheme.onErrorContainer : theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: entry.isActive
          ? theme.colorScheme.errorContainer
          : theme.colorScheme.surfaceContainerHighest,
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

/// Detail row component enforcing high-contrast text styling profiles.
class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        // Highlight execution change indicators with high-contrast text styling profiles
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

/// Gantt-style horizontal progress bar scaling visually from start date to end date.
/// Optimized for mobile side-scrolling gestures.
class _HorizontalGanttTimeline extends StatelessWidget {
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;

  const _HorizontalGanttTimeline({
    required this.startDate,
    required this.endDate,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final totalDuration = endDate.difference(startDate).inDays;
    final elapsedDuration = now.difference(startDate).inDays;

    // Calculate progress safely bounded between 0.0 and 1.0
    double progress = 0.0;
    if (totalDuration > 0) {
      progress = (elapsedDuration / totalDuration).clamp(0.0, 1.0);
    }

    // Read-only hard-rendered dates (Poka-Yoke)
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          alignment: Alignment.centerLeft,
          children: [
            // Background track
            Container(
              width: constraints.maxWidth,
              height: 8.0,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(4.0),
              ),
            ),
            // Progress indicator
            if (isActive && progress > 0)
              Container(
                width: constraints.maxWidth * progress,
                height: 8.0,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(4.0),
                ),
              ),
            // Start node
            Positioned(
              left: 0,
              child: _TimelineNode(color: theme.colorScheme.outline),
            ),
            // Current progress node
            if (isActive && progress > 0 && progress < 1.0)
              Positioned(
                left: (constraints.maxWidth * progress) - 8.0,
                child: _TimelineNode(color: theme.colorScheme.primary),
              ),
            // End node
            Positioned(
              right: 0,
              child: _TimelineNode(color: isActive ? theme.colorScheme.error : theme.colorScheme.outline),
            ),
            // Read-only labels
            Positioned(
              top: 24.0,
              left: 0,
              child: Text(
                _formatShortDate(startDate),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            Positioned(
              top: 24.0,
              right: 0,
              child: Text(
                _formatShortDate(endDate),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatShortDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

class _TimelineNode extends StatelessWidget {
  final Color color;

  const _TimelineNode({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16.0,
      height: 16.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: Border.all(color: Colors.white, width: 2.0),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 4.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }
}

/// Rehire button implementing Self-Chasing Poka-Yoke.
/// If active non-compete exists, physically cannot click to edit or shorten dates.
/// Overlays a padlock icon chasing HR to wait until timeline expires.
class _RehireButton extends StatelessWidget {
  final bool isLocked;

  const _RehireButton({required this.isLocked});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ElevatedButton.icon(
      onPressed: isLocked
          ? null // Hard-rendered as read-only; HR physically cannot click
          : () {
              // Action when unlocked
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Initiating rehire process...')),
              );
            },
      icon: Icon(
        isLocked ? Icons.lock_outline : Icons.how_to_reg_outlined,
        size: 18.0,
      ),
      label: Text(isLocked ? 'Restricted' : 'Rehire'),
      style: ElevatedButton.styleFrom(
        backgroundColor: isLocked ? theme.colorScheme.surfaceContainerHighest : theme.colorScheme.primary,
        foregroundColor: isLocked ? theme.colorScheme.onSurfaceVariant : theme.colorScheme.onPrimary,
        disabledBackgroundColor: theme.colorScheme.errorContainer.withOpacity(0.3),
        disabledForegroundColor: theme.colorScheme.onErrorContainer.withOpacity(0.7),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }
}
