// GEN-04003 — MTB Split-Screen Layout Widget.
// Implements the master split-screen layout with Evidence on top and Input on bottom, adapting to M3 single-column mobile (<600dp) and multi-column desktop (>=840dp) guidelines.

import 'package:flutter/material.dart';

/// Mock data representing evidence items for the top panel.
class _MockEvidenceItem {
  final String id;
  final String title;
  final String status;
  final DateTime timestamp;

  const _MockEvidenceItem({
    required this.id,
    required this.title,
    required this.status,
    required this.timestamp,
  });
}

const List<_MockEvidenceItem> _mockEvidenceData = [
  _MockEvidenceItem(
    id: 'EVD-001',
    title: 'System Initialization Log',
    status: 'Pass',
    timestamp: DateTime(2026, 9, 28, 10, 0),
  ),
  _MockEvidenceItem(
    id: 'EVD-002',
    title: 'API Latency Check',
    status: 'Pass',
    timestamp: DateTime(2026, 9, 28, 10, 5),
  ),
  _MockEvidenceItem(
    id: 'EVD-003',
    title: 'Security Compliance Scan',
    status: 'Fail',
    timestamp: DateTime(2026, 9, 28, 10, 15),
  ),
];

/// MTB Split-Screen Layout implementing Material Design 3 standards.
/// 
/// - Mobile (<600dp): Single-column vertical layout (Evidence top, Input bottom).
/// - Tablet/Desktop (>=840dp): Multi-column horizontal layout (Evidence left, Input right).
/// - Uses M3 Elevated Cards (Level 2, 3dp elevation).
/// - Uses M3 Status Chips for health indicators.
/// - Enforces 48x48dp minimum touch targets.
class MtbSplitScreenLayoutGen04003 extends StatefulWidget {
  const MtbSplitScreenLayoutGen04003({super.key});

  @override
  State<MtbSplitScreenLayoutGen04003> createState() => _MtbSplitScreenLayoutGen04003State();
}

class _MtbSplitScreenLayoutGen04003State extends State<MtbSplitScreenLayoutGen04003> {
  bool _isPolling = true;
  final TextEditingController _inputController = TextEditingController();

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _showConfigBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Configuration Inputs', style: Theme.of(ctx).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Custom Polling Interval (seconds)',
                  border: OutlineInputBorder(),
                ),
                // 48dp touch target enforced by default M3 input decorations
              ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Configuration saved successfully.')),
                      );
                    }
                  },
                  child: const Text('Apply'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double screenWidth = constraints.maxWidth;
        final bool isDesktop = screenWidth >= 840.0;

        if (isDesktop) {
          return _buildMultiColumnLayout(context);
        } else {
          return _buildSingleColumnLayout(context);
        }
      },
    );
  }

  /// Mobile / Tablet < 840dp: Vertical Split (Top / Bottom)
  Widget _buildSingleColumnLayout(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 1,
          child: _buildEvidencePanel(context),
        ),
        const Divider(height: 1),
        Expanded(
          flex: 1,
          child: _buildInputPanel(context),
        ),
      ],
    );
  }

  /// Desktop >= 840dp: Horizontal Split (Left / Right)
  Widget _buildMultiColumnLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 1,
          child: _buildEvidencePanel(context),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          flex: 1,
          child: _buildInputPanel(context),
        ),
      ],
    );
  }

  /// Top / Left Panel: Evidence Display
  Widget _buildEvidencePanel(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Card(
      elevation: 3.0, // M3 Elevated Card Level 2 (3dp)
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Evidence Panel', style: theme.textTheme.titleMedium),
                Row(
                  children: [
                    Chip(
                      label: Text(_isPolling ? 'Live' : 'Paused'),
                      backgroundColor: _isPolling
                          ? theme.colorScheme.primaryContainer
                          : theme.colorScheme.errorContainer,
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      iconSize: 24,
                      // Enforcing 48x48dp touch target
                      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                      icon: Icon(_isPolling ? Icons.pause_circle_outline : Icons.play_circle_outline),
                      onPressed: () {
                        setState(() {
                          _isPolling = !_isPolling;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(_isPolling ? 'Polling resumed' : 'Polling paused')),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  // Simulate manual sync pull-to-refresh
                  await Future<void>.delayed(const Duration(seconds: 1));
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Manual sync completed.')),
                    );
                  }
                },
                child: ListView.separated(
                  itemCount: _mockEvidenceData.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (BuildContext context, int index) {
                    final item = _mockEvidenceData[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      minVerticalPadding: 12, // Helps meet 48dp height target
                      title: Text(item.title, style: theme.textTheme.bodyLarge),
                      subtitle: Text(item.timestamp.toString()),
                      trailing: Chip(
                        label: Text(item.status),
                        avatar: Icon(
                          item.status == 'Pass' ? Icons.check_circle : Icons.cancel,
                          size: 18,
                          color: item.status == 'Pass'
                              ? theme.colorScheme.primary
                              : theme.colorScheme.error,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Bottom / Right Panel: Input & Configuration
  Widget _buildInputPanel(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Card(
      elevation: 3.0, // M3 Elevated Card Level 2 (3dp)
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Input & Configuration', style: theme.textTheme.titleMedium),
            const SizedBox(height: 24),
            TextField(
              controller: _inputController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Engineering Notes',
                hintText: 'Enter step execution notes...',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                FilledButton.icon(
                  // 48x48dp touch target naturally met by FilledButton in M3
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Submission recorded.')),
                    );
                  },
                  icon: const Icon(Icons.send),
                  label: const Text('Submit Evidence'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _showConfigBottomSheet(context),
                  icon: const Icon(Icons.settings),
                  label: const Text('Open Configurations'),
                ),
              ],
            ),
            const Spacer(),
            // KPI Health Indicator Card
            Card(
              color: theme.colorScheme.surfaceContainerHighest,
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Split-Screen Layout Compliance'),
                    Chip(
                      label: const Text('Pass'),
                      backgroundColor: theme.colorScheme.primaryContainer,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
