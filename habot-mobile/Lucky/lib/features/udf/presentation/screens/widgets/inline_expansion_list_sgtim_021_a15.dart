// SGTIM-021-A15 — Inline Expansion List Blueprint and Component Schema.
// Implements MD3 ExpansionPanelList for progressive information disclosure with explicit chevrons, smooth height transitions, distinct background fills for expanded content, and local mock data.

import 'package:flutter/material.dart';

/// Domain model representing a single atomic record in the expansion list.
class InlineExpansionRecord {
  final String stepExecutionId;
  final String executionStatus;
  final DateTime executionTimestamp;
  final String stepOutcome;
  final String userId;
  final bool isMandatoryValidated;

  const InlineExpansionRecord({
    required this.stepExecutionId,
    required this.executionStatus,
    required this.executionTimestamp,
    required this.stepOutcome,
    required this.userId,
    this.isMandatoryValidated = true,
  });
}

/// Mock data repository providing realistic local data for UI implementation.
/// Satisfies backend/API dependency requirement via hardcoded static constants.
class MockExpansionDataRepository {
  static final List<InlineExpansionRecord> records = [
    InlineExpansionRecord(
      stepExecutionId: 'EXEC-001',
      executionStatus: 'Completed',
      executionTimestamp: DateTime(2026, 9, 24, 10, 15),
      stepOutcome: 'Success',
      userId: 'USR-8821',
    ),
    InlineExpansionRecord(
      stepExecutionId: 'EXEC-002',
      executionStatus: 'Pending Validation',
      executionTimestamp: DateTime(2026, 9, 24, 11, 30),
      stepOutcome: 'Awaiting Input',
      userId: 'USR-8822',
      isMandatoryValidated: false,
    ),
    InlineExpansionRecord(
      stepExecutionId: 'EXEC-003',
      executionStatus: 'Failed',
      executionTimestamp: DateTime(2026, 9, 25, 09, 00),
      stepOutcome: 'Timeout Error',
      userId: 'USR-8823',
    ),
    InlineExpansionRecord(
      stepExecutionId: 'EXEC-004',
      executionStatus: 'Completed',
      executionTimestamp: DateTime(2026, 9, 25, 14, 45),
      stepOutcome: 'Success',
      userId: 'USR-8821',
    ),
  ];
}

/// Universal inline expansion row wrapper component.
/// Applies MD3 Accordion / Expansion panel styling rules.
class InlineExpansionListView extends StatefulWidget {
  final List<InlineExpansionRecord> records;

  const InlineExpansionListView({
    super.key,
    this.records = const [],
  });

  @override
  State<InlineExpansionListView> createState() => _InlineExpansionListViewState();
}

class _InlineExpansionListViewState extends State<InlineExpansionListView> {
  late List<bool> _expandedStates;
  late List<InlineExpansionRecord> _data;

  @override
  void initState() {
    super.initState();
    _data = widget.records.isEmpty ? MockExpansionDataRepository.records : widget.records;
    _expandedStates = List<bool>.filled(_data.length, false);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      child: ExpansionPanelList(
        elevation: 0,
        dividerColor: colorScheme.outlineVariant,
        expandedHeaderPadding: const EdgeInsets.symmetric(vertical: 0),
        animationDuration: const Duration(milliseconds: 300),
        expandIconColor: colorScheme.primary,
        children: List.generate(_data.length, (index) {
          final record = _data[index];
          return ExpansionPanel(
            backgroundColor: colorScheme.surface,
            headerBuilder: (BuildContext context, bool isExpanded) {
              return ListTile(
                title: Text(
                  'Step ID: ${record.stepExecutionId}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    'Status: ${record.executionStatus}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                trailing: Icon(
                  isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: colorScheme.primary,
                  semanticLabel: isExpanded ? 'Collapse row' : 'Expand row',
                ),
              );
            },
            body: Container(
              // Distinct structural background fill for secondary info panels
              color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
              padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 1, thickness: 1),
                  const SizedBox(height: 16.0),
                  _buildDetailRow(context, 'User ID', record.userId),
                  const SizedBox(height: 12.0),
                  _buildDetailRow(
                    context,
                    'Timestamp',
                    '${record.executionTimestamp.year}-${record.executionTimestamp.month.toString().padLeft(2, '0')}-${record.executionTimestamp.day.toString().padLeft(2, '0')} ${record.executionTimestamp.hour.toString().padLeft(2, '0')}:${record.executionTimestamp.minute.toString().padLeft(2, '0')}',
                  ),
                  const SizedBox(height: 12.0),
                  _buildDetailRow(context, 'Outcome', record.stepOutcome),
                  const SizedBox(height: 12.0),
                  _buildDetailRow(
                    context,
                    'Validation Status',
                    record.isMandatoryValidated ? 'Validated' : 'Pending Mandatory Fields',
                  ),
                  if (!record.isMandatoryValidated) ...[
                    const SizedBox(height: 16.0),
                    // Self-Chasing: Expanded sub-drawers lock input submission actions until all internal mandatory elements validate.
                    OutlinedButton.icon(
                      onPressed: null, // Locked due to validation failure
                      icon: const Icon(Icons.lock_outline, size: 18),
                      label: const Text('Submit Action (Locked)'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colorScheme.onSurface.withOpacity(0.38),
                      ),
                    ),
                  ] else ...[
                    const SizedBox(height: 16.0),
                    FilledButton.tonalIcon(
                      onPressed: () {
                        // Action enabled only when validated
                      },
                      icon: const Icon(Icons.check_circle_outline, size: 18),
                      label: const Text('Submit Action'),
                    ),
                  ],
                ],
              ),
            ),
            isExpanded: _expandedStates[index],
            canTapOnHeader: true,
          );
        }),
        expansionCallback: (int index, bool isExpanded) {
          setState(() {
            _expandedStates[index] = !isExpanded;
          });
        },
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    final ThemeData theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: 8.0),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

/// Standalone screen wrapper to demonstrate the component in isolation.
class InlineExpansionListScreen extends StatelessWidget {
  const InlineExpansionListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detailed Execution Records'),
        centerTitle: false,
      ),
      body: const InlineExpansionListView(),
    );
  }
}
