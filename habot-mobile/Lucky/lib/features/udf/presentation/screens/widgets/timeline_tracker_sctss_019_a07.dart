// SCTSS-019-A07 — Expiry Timeline Tracker Component.
// A scalable horizontal timeline UI component for tracking legal restrictions and non-compete expiries, optimized for mobile side-scrolling with skeleton loading, dark/light mode support, and read-only date rendering.

import 'package:flutter/material.dart';

/// Mock data model representing a timeline node parsed from flat spreadsheet records.
class TimelineNode {
  final String stepExecutionId;
  final String employeeName;
  final String restrictionType;
  final DateTime startDate;
  final DateTime endDate;
  final bool isNonCompeteActive;
  final String executionStatus;

  const TimelineNode({
    required this.stepExecutionId,
    required this.employeeName,
    required this.restrictionType,
    required this.startDate,
    required this.endDate,
    required this.isNonCompeteActive,
    required this.executionStatus,
  });
}

/// Hardcoded mock repository simulating BigQuery daily updates.
class MockTimelineRepository {
  static List<TimelineNode> getMockNodes() {
    final now = DateTime.now();
    return [
      TimelineNode(
        stepExecutionId: 'EXEC-001',
        employeeName: 'John Doe',
        restrictionType: 'Non-Compete Agreement',
        startDate: now.subtract(const Duration(days: 180)),
        endDate: now.add(const Duration(days: 185)),
        isNonCompeteActive: true,
        executionStatus: 'Active',
      ),
      TimelineNode(
        stepExecutionId: 'EXEC-002',
        employeeName: 'Jane Smith',
        restrictionType: 'NDA Expiry',
        startDate: now.subtract(const Duration(days: 365)),
        endDate: now.subtract(const Duration(days: 10)),
        isNonCompeteActive: false,
        executionStatus: 'Expired',
      ),
      TimelineNode(
        stepExecutionId: 'EXEC-003',
        employeeName: 'Ahmed Hassan',
        restrictionType: 'Non-Solicitation',
        startDate: now.subtract(const Duration(days: 30)),
        endDate: now.add(const Duration(days: 90)),
        isNonCompeteActive: true,
        executionStatus: 'Active',
      ),
    ];
  }
}

/// Main screen demonstrating the TimelineTracker integration.
class TimelineTrackerScreen extends StatefulWidget {
  const TimelineTrackerScreen({super.key});

  @override
  State<TimelineTrackerScreen> createState() => _TimelineTrackerScreenState();
}

class _TimelineTrackerScreenState extends State<TimelineTrackerScreen> {
  late Future<List<TimelineNode>> _timelineFuture;

  @override
  void initState() {
    super.initState();
    // Simulate database history fetch delay for skeleton cards
    _timelineFuture = Future.delayed(
      const Duration(milliseconds: 1500),
      () => MockTimelineRepository.getMockNodes(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post-Exit Compliance Dashboard'),
      ),
      body: FutureBuilder<List<TimelineNode>>(
        future: _timelineFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const _TimelineSkeletonLoader();
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No timeline data available.'));
          }
          return _TimelineTrackerList(nodes: snapshot.data!);
        },
      ),
    );
  }
}

/// Skeleton cards displayed during active database history fetches.
class _TimelineSkeletonLoader extends StatelessWidget {
  const _TimelineSkeletonLoader();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 16.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 16, width: 150, color: Colors.grey.shade300),
                const SizedBox(height: 12),
                Container(height: 40, width: double.infinity, color: Colors.grey.shade200),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(height: 12, width: 80, color: Colors.grey.shade300),
                    Container(height: 12, width: 80, color: Colors.grey.shade300),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Vertical list containing horizontally scrollable timelines per employee.
class _TimelineTrackerList extends StatelessWidget {
  final List<TimelineNode> nodes;

  const _TimelineTrackerList({required this.nodes});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      itemCount: nodes.length,
      itemBuilder: (context, index) {
        final node = nodes[index];
        return _TimelineCard(node: node);
      },
    );
  }
}

/// Individual card framing the horizontal timeline within explicit layout margins.
class _TimelineCard extends StatelessWidget {
  final TimelineNode node;

  const _TimelineCard({required this.node});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = '${node.startDate.day}/${node.startDate.month}/${node.startDate.year} - ${node.endDate.day}/${node.endDate.month}/${node.endDate.year}';

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0), // Explicit layout margins
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // High-contrast text styling profiles for execution change indicators
            Text(
              node.employeeName,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              node.restrictionType,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            // Horizontal timeline component optimized for mobile side-scrolling gestures
            SizedBox(
              height: 60,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: _HorizontalTimelineVisual(
                  startDate: node.startDate,
                  endDate: node.endDate,
                  isActive: node.isNonCompeteActive,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Timeline dates hard-rendered as read-only; HR physically cannot click to edit
            IgnorePointer(
              ignoring: true,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Start: ${dateFormat.split(' - ').first}', style: theme.textTheme.bodySmall),
                  Text('End: ${dateFormat.split(' - ').last}', style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Rehire button with self-chasing padlock overlay if non-compete is active
            Align(
              alignment: Alignment.centerRight,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  ElevatedButton(
                    onPressed: node.isNonCompeteActive ? null : () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: node.isNonCompeteActive 
                          ? theme.colorScheme.surfaceContainerHighest 
                          : theme.colorScheme.primary,
                      foregroundColor: node.isNonCompeteActive 
                          ? theme.colorScheme.onSurfaceVariant 
                          : theme.colorScheme.onPrimary,
                    ),
                    child: const Text('Rehire'),
                  ),
                  if (node.isNonCompeteActive)
                    Positioned(
                      right: -8,
                      top: -8,
                      child: Icon(
                        Icons.lock,
                        color: theme.colorScheme.error,
                        size: 20,
                        semanticLabel: 'Non-compete active. Wait until timeline expires.',
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dynamic TimelineTracker UI scaling visually from start date to end date.
/// Uses an 8dp baseline grid for alignment.
class _HorizontalTimelineVisual extends StatelessWidget {
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;

  const _HorizontalTimelineVisual({
    required this.startDate,
    required this.endDate,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final totalDays = endDate.difference(startDate).inDays;
    final daysPassed = DateTime.now().difference(startDate).inDays.clamp(0, totalDays);
    final progress = totalDays > 0 ? daysPassed / totalDays : 0.0;
    
    // Minimum width of 320px to ensure side-scrolling gesture relevance on mobile
    const double minWidth = 320.0;
    const double trackHeight = 8.0; // 8dp baseline grid

    final theme = Theme.of(context);
    final activeColor = isActive ? theme.colorScheme.primary : theme.colorScheme.outline;
    final completedColor = isActive ? theme.colorScheme.tertiary : theme.colorScheme.outline;

    return SizedBox(
      width: minWidth + (totalDays * 1.5), // Scale dynamically based on duration
      child: Row(
        children: [
          // Start Node
          Container(
            width: 16.0,
            height: 16.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: activeColor,
            ),
          ),
          // Progress Track
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    // Background track
                    Container(
                      height: trackHeight,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                    ),
                    // Completed track
                    FractionallySizedBox(
                      widthFactor: progress.clamp(0.0, 1.0),
                      child: Container(
                        height: trackHeight,
                        decoration: BoxDecoration(
                          color: completedColor,
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                      ),
                    ),
                    // Current position indicator
                    if (isActive && progress > 0 && progress < 1)
                      Positioned(
                        left: (constraints.maxWidth * progress.clamp(0.0, 1.0)) - 6,
                        child: Container(
                          width: 12.0,
                          height: 12.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: theme.colorScheme.secondary,
                            border: Border.all(color: theme.colorScheme.surface, width: 2.0),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          // End Node
          Container(
            width: 16.0,
            height: 16.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: progress >= 1.0 ? completedColor : theme.colorScheme.surfaceContainerHighest,
              border: Border.all(color: activeColor, width: 2.0),
            ),
          ),
        ],
      ),
    );
  }
}
