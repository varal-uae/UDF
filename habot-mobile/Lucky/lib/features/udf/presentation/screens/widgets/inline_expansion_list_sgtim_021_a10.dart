// SGTIM-021-A10 — Inline Expansion List Blueprint and Component Schema.
// Implements MD3 Accordion/Expansion panel styling with smooth 200-300ms height transitions, interactive chevrons, distinct background fills, and mock data for dense tabular disclosure.

import 'package:flutter/material.dart';

/// Mock data model representing atomic-level data fields for expansion rows.
class ExpansionRowMockData {
  final String stepExecutionId;
  final String executionStatus;
  final DateTime executionTimestamp;
  final String stepOutcome;
  final String userId;
  final Map<String, dynamic> metadata;

  const ExpansionRowMockData({
    required this.stepExecutionId,
    required this.executionStatus,
    required this.executionTimestamp,
    required this.stepOutcome,
    required this.userId,
    required this.metadata,
  });
}

/// Static mock repository to supply local data without backend dependency.
class MockExpansionRepository {
  static final List<ExpansionRowMockData> records = [
    ExpansionRowMockData(
      stepExecutionId: 'EXEC-001',
      executionStatus: 'Completed',
      executionTimestamp: DateTime(2026, 9, 24, 10, 15),
      stepOutcome: 'Success',
      userId: 'USR-8821',
      metadata: {
        'duration_ms': 245,
        'validation_passed': true,
        'error_code': null,
        'notes': 'Standard processing flow executed without interruption.',
      },
    ),
    ExpansionRowMockData(
      stepExecutionId: 'EXEC-002',
      executionStatus: 'Pending',
      executionTimestamp: DateTime(2026, 9, 24, 11, 30),
      stepOutcome: 'Awaiting Review',
      userId: 'USR-8822',
      metadata: {
        'duration_ms': 0,
        'validation_passed': false,
        'error_code': 'PENDING_MANUAL',
        'notes': 'Requires secondary approval from domain expert.',
      },
    ),
    ExpansionRowMockData(
      stepExecutionId: 'EXEC-003',
      executionStatus: 'Failed',
      executionTimestamp: DateTime(2026, 9, 25, 09, 05),
      stepOutcome: 'Validation Error',
      userId: 'USR-8823',
      metadata: {
        'duration_ms': 112,
        'validation_passed': false,
        'error_code': 'ERR_CONSTRAINT_04',
        'notes': 'Input mask validation failed on tertiary field.',
      },
    ),
  ];
}

/// Universal inline expansion row wrapper implementing progressive information disclosure.
class InlineExpansionList extends StatefulWidget {
  final List<ExpansionRowMockData> items;

  const InlineExpansionList({
    super.key,
    this.items = const [],
  });

  @override
  State<InlineExpansionList> createState() => _InlineExpansionListState();
}

class _InlineExpansionListState extends State<InlineExpansionList> {
  late List<ExpansionRowMockData> _data;
  final Set<int> _expandedIndices = {};

  @override
  void initState() {
    super.initState();
    _data = widget.items.isEmpty ? MockExpansionRepository.records : widget.items;
  }

  void _toggleExpansion(int index) {
    setState(() {
      if (_expandedIndices.contains(index)) {
        _expandedIndices.remove(index);
      } else {
        _expandedIndices.add(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      itemCount: _data.length,
      separatorBuilder: (_, __) => const Divider(height: 1, thickness: 1),
      itemBuilder: (context, index) {
        final item = _data[index];
        final isExpanded = _expandedIndices.contains(index);

        return _ExpansionTile(
          item: item,
          isExpanded: isExpanded,
          onTap: () => _toggleExpansion(index),
          theme: theme,
        );
      },
    );
  }
}

class _ExpansionTile extends StatelessWidget {
  final ExpansionRowMockData item;
  final bool isExpanded;
  final VoidCallback onTap;
  final ThemeData theme;

  const _ExpansionTile({
    required this.item,
    required this.isExpanded,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = theme.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Primary Row (Header)
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            color: colorScheme.surface,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.stepExecutionId,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${item.executionStatus} • ${item.userId}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                // Explicit interactive chevron providing visual affordance
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  child: Icon(
                    Icons.expand_more_rounded,
                    color: colorScheme.primary,
                    size: 28,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Secondary Info Panel with distinct structural background fill
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            color: colorScheme.surfaceContainerHighest.withOpacity(0.4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DetailRow('Outcome:', item.stepOutcome),
                const SizedBox(height: 8),
                _DetailRow(
                  'Timestamp:',
                  '${item.executionTimestamp.year}-${item.executionTimestamp.month.toString().padLeft(2, '0')}-${item.executionTimestamp.day.toString().padLeft(2, '0')} '
                  '${item.executionTimestamp.hour.toString().padLeft(2, '0')}:${item.executionTimestamp.minute.toString().padLeft(2, '0')}',
                ),
                const SizedBox(height: 12),
                const Divider(thickness: 1),
                const SizedBox(height: 12),
                Text(
                  'Metadata Details',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...item.metadata.entries.map((entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: _DetailRow(
                    '${_formatKey(entry.key)}:',
                    entry.value?.toString() ?? 'N/A',
                  ),
                )),
                const SizedBox(height: 16),
                // Human edit form controls placeholder
                OutlinedButton.icon(
                  onPressed: () {
                    // Self-chasing: lock input submission until validated
                  },
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Edit Record'),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: colorScheme.outline),
                  ),
                ),
              ],
            ),
          ),
          crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          // Motion/Transition Timing Standard: 250ms ease-in-out (within 200-300ms optimal target)
          duration: const Duration(milliseconds: 250),
          firstCurve: Curves.easeInOut,
          secondCurve: Curves.easeInOut,
          sizeCurve: Curves.easeInOut,
        ),
      ],
    );
  }

  String _formatKey(String key) {
    return key
        .split('_')
        .map((word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}

/// Preview/Demo screen to validate the component schema definitions.
class InlineExpansionListScreen extends StatelessWidget {
  const InlineExpansionListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inline Expansion List Blueprint'),
        centerTitle: true,
      ),
      body: const InlineExpansionList(),
    );
  }
}
