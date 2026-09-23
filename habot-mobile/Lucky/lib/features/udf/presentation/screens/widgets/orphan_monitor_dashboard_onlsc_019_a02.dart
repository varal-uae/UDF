// ONLSC-019-A02 — Orphan Monitor Dashboard Widget.
// Displays orphaned recruitment data nodes with bright red tags, side-by-side comparative rows, and single-tap metric drill-downs using Material 3 design tokens.

import 'package:flutter/material.dart';

enum _FormComponentMode { idle, editing, submitting, locked, error }

class _MockOrphanNode {
  final String id;
  final String parameter;
  final String currentSetting;
  final String previousSetting;
  final String changeLog;
  final DateTime timestamp;
  final bool isOrphan;

  const _MockOrphanNode({
    required this.id,
    required this.parameter,
    required this.currentSetting,
    required this.previousSetting,
    required this.changeLog,
    required this.timestamp,
    required this.isOrphan,
  });
}

const List<_MockOrphanNode> _mockNodes = [
  _MockOrphanNode(
    id: 'NODE-001',
    parameter: 'Recruitment Pipeline Stage',
    currentSetting: 'Screening',
    previousSetting: 'Applied',
    changeLog: 'Parent job requisition deleted',
    timestamp: null,
    isOrphan: true,
  ),
  _MockOrphanNode(
    id: 'NODE-002',
    parameter: 'Candidate Status',
    currentSetting: 'Interview',
    previousSetting: 'Shortlisted',
    changeLog: 'Updated by system sync',
    timestamp: null,
    isOrphan: false,
  ),
  _MockOrphanNode(
    id: 'NODE-003',
    parameter: 'Offer Generation',
    currentSetting: 'Pending',
    previousSetting: 'Draft',
    changeLog: 'Hiring manager removed',
    timestamp: null,
    isOrphan: true,
  ),
];

class OrphanMonitorDashboard extends StatefulWidget {
  const OrphanMonitorDashboard({super.key});

  @override
  State<OrphanMonitorDashboard> createState() => _OrphanMonitorDashboardState();
}

class _OrphanMonitorDashboardState extends State<OrphanMonitorDashboard> {
  _FormComponentMode _mode = _FormComponentMode.idle;

  void _onMetricDrillDown(_MockOrphanNode node) {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Root Calculation Parameters', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                Text('Parameter: ${node.parameter}', style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 8),
                Text('Current: ${node.currentSetting}', style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 8),
                Text('Previous: ${node.previousSetting}', style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 8),
                Text('Change Log: ${node.changeLog}', style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Monitor Orphan Nodes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Observability & Logging Completeness',
            onPressed: () {
              setState(() {
                _mode = _mode == _FormComponentMode.idle ? _FormComponentMode.editing : _FormComponentMode.idle;
              });
            },
          ),
        ],
      ),
      body: _mode == _FormComponentMode.locked
          ? const Center(child: Text('Dashboard is currently locked.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _mockNodes.length,
              itemBuilder: (BuildContext context, int index) {
                final _MockOrphanNode node = _mockNodes[index];
                return Card(
                  clipBehavior: Clip.antiAlias,
                  margin: const EdgeInsets.only(bottom: 12.0),
                  child: InkWell(
                    onTap: () => _onMetricDrillDown(node),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  node.parameter,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (node.isOrphan)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                                  decoration: BoxDecoration(
                                    color: Colors.redAccent,
                                    borderRadius: BorderRadius.circular(4.0),
                                  ),
                                  child: const Text(
                                    'Orphan',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12.0,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const Divider(height: 24.0),
                          // Side-by-side comparative rows
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Current Setting', style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                                    const SizedBox(height: 4.0),
                                    Text(node.currentSetting, style: theme.textTheme.bodyLarge),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Previous Setting', style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                                    const SizedBox(height: 4.0),
                                    Text(node.previousSetting, style: theme.textTheme.bodyLarge),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12.0),
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 16.0,
                                color: colorScheme.primary,
                              ),
                              const SizedBox(width: 8.0),
                              Text(
                                'Tap to uncover root calculation parameters',
                                style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.primary),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}