// GEN-01919 — Conflict Flag Status Card for UDF Engineering Console.
// Displays agent conflict resolution state using M3 ElevatedCard, status chips, and 48x48dp touch targets with mock data.

import 'package:flutter/material.dart';

enum StepCompletionState { complete, partial, notComplete }

class AgentSubmission {
  final String agentId;
  final String answer;

  const AgentSubmission({required this.agentId, required this.answer});
}

class ConflictFlagData {
  final String stepId;
  final List<AgentSubmission> submissions;
  final bool hasConflict;
  final StepCompletionState completionState;
  final DateTime timestamp;
  final double completionRate;

  const ConflictFlagData({
    required this.stepId,
    required this.submissions,
    required this.hasConflict,
    required this.completionState,
    required this.timestamp,
    required this.completionRate,
  });
}

class MockConflictRepository {
  static const ConflictFlagData mockData = ConflictFlagData(
    stepId: 'GEN-01919',
    submissions: [
      AgentSubmission(agentId: 'agent-alpha', answer: 'Approve configuration A'),
      AgentSubmission(agentId: 'agent-beta', answer: 'Reject due to ISO mismatch'),
      AgentSubmission(agentId: 'agent-gamma', answer: 'Request manual override'),
    ],
    hasConflict: true,
    completionState: StepCompletionState.partial,
    timestamp: null,
    completionRate: 92.5,
  );

  static ConflictFlagData fetch() {
    return ConflictFlagData(
      stepId: mockData.stepId,
      submissions: mockData.submissions,
      hasConflict: mockData.hasConflict,
      completionState: mockData.completionState,
      timestamp: DateTime.now(),
      completionRate: mockData.completionRate,
    );
  }
}

class ConflictFlagCard extends StatefulWidget {
  const ConflictFlagCard({super.key});

  @override
  State<ConflictFlagCard> createState() => _ConflictFlagCardState();
}

class _ConflictFlagCardState extends State<ConflictFlagCard> {
  late ConflictFlagData _data;

  @override
  void initState() {
    super.initState();
    _data = MockConflictRepository.fetch();
  }

  Color _statusColor(BuildContext context, StepCompletionState state) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (state) {
      case StepCompletionState.complete:
        return colorScheme.primary;
      case StepCompletionState.partial:
        return colorScheme.tertiary;
      case StepCompletionState.notComplete:
        return colorScheme.error;
    }
  }

  String _statusLabel(StepCompletionState state) {
    switch (state) {
      case StepCompletionState.complete:
        return 'Complete';
      case StepCompletionState.partial:
        return 'Partial';
      case StepCompletionState.notComplete:
        return 'Not Complete';
    }
  }

  void _showDetailsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Agent Submissions Detail', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              ..._data.submissions.map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.smart_toy_outlined, size: 24, color: Theme.of(context).colorScheme.secondary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.agentId, style: Theme.of(context).textTheme.labelLarge),
                          Text(s.answer, style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ),
                    ),
                  ],
                ),
              )).toList(),
              const SizedBox(height: 24),
              if (_data.hasConflict)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Theme.of(context).colorScheme.onErrorContainer),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Conflict flag raised: All 3 agents submitted differing answers.',
                          style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        return Card(
          elevation: 3,
          surfaceTintColor: colorScheme.surfaceTint,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: isMobile
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _buildContent(context, textTheme, colorScheme),
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 2, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: _buildContent(context, textTheme, colorScheme))),
                      const SizedBox(width: 24),
                      Expanded(flex: 1, child: _buildActionColumn(context)),
                    ],
                  ),
          ),
        );
      },
    );
  }

  List<Widget> _buildContent(BuildContext context, TextTheme textTheme, ColorScheme colorScheme) {
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Step ${_data.stepId}', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          Chip(
            avatar: Icon(Icons.circle, size: 12, color: _statusColor(context, _data.completionState)),
            label: Text(_statusLabel(_data.completionState), style: textTheme.labelSmall),
            backgroundColor: _statusColor(context, _data.completionState).withOpacity(0.1),
            side: BorderSide.none,
          ),
        ],
      ),
      const SizedBox(height: 12),
      Text('Raise a conflict flag if all 3 agents submit differing answers.', style: textTheme.bodyMedium),
      const SizedBox(height: 16),
      Row(
        children: [
          Icon(_data.hasConflict ? Icons.error_outline : Icons.check_circle_outline, color: _data.hasConflict ? colorScheme.error : colorScheme.primary, size: 20),
          const SizedBox(width: 8),
          Text(
            _data.hasConflict ? 'Conflict Detected' : 'No Conflict',
            style: textTheme.labelLarge?.copyWith(color: _data.hasConflict ? colorScheme.error : colorScheme.primary),
          ),
        ],
      ),
      const SizedBox(height: 8),
      LinearProgressIndicator(
        value: _data.completionRate / 100,
        minHeight: 6,
        borderRadius: BorderRadius.circular(3),
        backgroundColor: colorScheme.surfaceContainerHighest,
        valueColor: AlwaysStoppedAnimation<Color>(_data.completionRate >= 90 ? colorScheme.primary : colorScheme.error),
      ),
      const SizedBox(height: 4),
      Text('Completion Rate: ${_data.completionRate.toStringAsFixed(1)}% (Floor: 90%)', style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
    ];
  }

  Widget _buildActionColumn(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: SizedBox(
        width: 48,
        height: 48,
        child: IconButton(
          iconSize: 24,
          icon: const Icon(Icons.open_in_new),
          tooltip: 'View Details',
          onPressed: () => _showDetailsBottomSheet(context),
        ),
      ),
    );
  }
}