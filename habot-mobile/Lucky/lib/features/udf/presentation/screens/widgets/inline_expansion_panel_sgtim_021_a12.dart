// SGTIM-021-A12 — Inline Expansion Panel Widget for Detailed Lists.
// Implements MD3 Accordion/Expansion panel styling with animated chevron rotation, progressive information disclosure, and smooth height transitions (250ms) without document reflow.

import 'package:flutter/material.dart';

/// Mock data model representing a row in the detailed list.
class ExpansionRowData {
  final String stepExecutionId;
  final String title;
  final String status;
  final DateTime timestamp;
  final String outcome;
  final String userId;
  final Map<String, dynamic> metadata;

  const ExpansionRowData({
    required this.stepExecutionId,
    required this.title,
    required this.status,
    required this.timestamp,
    required this.outcome,
    required this.userId,
    required this.metadata,
  });
}

/// Local mock data repository to simulate backend API responses.
class MockExpansionRepository {
  static List<ExpansionRowData> getMockRows() {
    return [
      ExpansionRowData(
        stepExecutionId: 'EXEC-001',
        title: 'System Initialization Sequence',
        status: 'Completed',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        outcome: 'Success',
        userId: 'USR-9921',
        metadata: {
          'Module': 'Core Engine',
          'Duration': '145ms',
          'Memory Footprint': '12MB',
          'Validation Score': '98%',
        },
      ),
      ExpansionRowData(
        stepExecutionId: 'EXEC-002',
        title: 'Data Synchronization Task',
        status: 'Pending',
        timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
        outcome: 'In Progress',
        userId: 'USR-4410',
        metadata: {
          'Module': 'Network Layer',
          'Duration': 'N/A',
          'Memory Footprint': '8MB',
          'Validation Score': 'N/A',
        },
      ),
      ExpansionRowData(
        stepExecutionId: 'EXEC-003',
        title: 'UI Rendering Pipeline Check',
        status: 'Failed',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        outcome: 'Timeout Exception',
        userId: 'USR-1123',
        metadata: {
          'Module': 'Presentation',
          'Duration': '4000ms',
          'Memory Footprint': '45MB',
          'Validation Score': '0%',
        },
      ),
    ];
  }
}

/// A reusable inline expansion list widget adhering to Material Design 3 standards.
/// Provides progressive information disclosure tailored to mobile viewports.
class InlineExpansionList extends StatefulWidget {
  final List<ExpansionRowData> items;

  const InlineExpansionList({
    super.key,
    required this.items,
  });

  @override
  State<InlineExpansionList> createState() => _InlineExpansionListState();
}

class _InlineExpansionListState extends State<InlineExpansionList> {
  int? _expandedIndex;

  void _handleTap(int index) {
    setState(() {
      // Collapse if already expanded, otherwise expand the tapped item
      _expandedIndex = _expandedIndex == index ? null : index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView.separated(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.items.length,
      separatorBuilder: (context, index) => Divider(
        height: 1,
        thickness: 1,
        color: theme.colorScheme.outlineVariant.withOpacity(0.5),
      ),
      itemBuilder: (context, index) {
        final item = widget.items[index];
        final isExpanded = _expandedIndex == index;

        return _InlineExpansionPanel(
          item: item,
          isExpanded: isExpanded,
          onTap: () => _handleTap(index),
        );
      },
    );
  }
}

class _InlineExpansionPanel extends StatelessWidget {
  final ExpansionRowData item;
  final bool isExpanded;
  final VoidCallback onTap;

  const _InlineExpansionPanel({
    required this.item,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: ${item.stepExecutionId} • Status: ${item.status}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                // Animated Chevron with reversed rotation logic as per requirement
                AnimatedRotation(
                  turns: isExpanded ? 0.0 : 0.5, // Reversed: 0.5 when closed (pointing down/up standard), 0.0 when open
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  child: Icon(
                    Icons.expand_more,
                    color: colorScheme.primary,
                    semanticLabel: isExpanded ? 'Collapse details' : 'Expand details',
                  ),
                ),
              ],
            ),
          ),
        ),
        // Smooth expansion using AnimatedCrossFade to prevent jagged reflow
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: _buildExpandedContent(context, theme, colorScheme),
          crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 250),
          sizeCurve: Curves.easeInOut,
          layoutBuilder: (Widget topChild, Key topChildKey, Widget bottomChild, Key bottomChildKey) {
            return Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                Positioned(key: bottomChildKey, left: 0, right: 0, top: 0, child: bottomChild),
                Positioned(key: topChildKey, child: topChild),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildExpandedContent(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      // Distinct structural background fill for secondary info panels
      color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detailed Metadata',
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...item.metadata.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 140,
                    child: Text(
                      '${entry.key}:',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      entry.value.toString(),
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          const SizedBox(height: 8),
          Divider(color: colorScheme.outlineVariant),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Executed by: ${item.userId}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                'Timestamp: ${_formatTimestamp(item.timestamp)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Outcome: ${item.outcome}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: item.status == 'Failed' ? colorScheme.error : colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime time) {
    return '${time.year}-${time.month.toString().padLeft(2, '0')}-${time.day.toString().padLeft(2, '0')} '
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

/// Example usage / Preview screen for the Analytics UI Kit
class InlineExpansionPreviewScreen extends StatelessWidget {
  const InlineExpansionPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mockData = MockExpansionRepository.getMockRows();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inline Expansion Blueprint'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Execution Records',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: InlineExpansionList(items: mockData),
            ),
          ],
        ),
      ),
    );
  }
}
