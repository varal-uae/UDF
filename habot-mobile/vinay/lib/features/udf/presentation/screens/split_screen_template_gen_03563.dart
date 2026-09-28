// GEN-03563 — Isolated 50/50 Split-Screen Mobile UI Template for Byt Evidence and Input Field.
// Implements Material Design 3 adaptive layout with single-column on mobile (<600dp) and 50/50 split on desktop (>=840dp), including M3 Elevated Cards, Status Chips, Bottom Sheet configuration, Snackbar confirmations, 30s polling, and pull-to-refresh.

import 'dart:async';
import 'package:flutter/material.dart';

/// Mock data representing Byt evidence artifacts.
class BytEvidence {
  final String id;
  final String title;
  final String description;
  final String status;
  final DateTime timestamp;

  const BytEvidence({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.timestamp,
  });
}

/// Local mock repository providing realistic dummy data.
class MockBytRepository {
  static List<BytEvidence> getEvidence() {
    return [
      BytEvidence(
        id: 'BYT-001',
        title: 'Identity Verification Hash',
        description: 'SHA-256 hash of the submitted identity document matching ledger record.',
        status: 'Verified',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      BytEvidence(
        id: 'BYT-002',
        title: 'Transaction Signature',
        description: 'Cryptographic signature confirming transaction origin and integrity.',
        status: 'Pending Review',
        timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
      ),
      BytEvidence(
        id: 'BYT-003',
        title: 'Node Consensus Receipt',
        description: 'Distributed node consensus receipt validating block inclusion.',
        status: 'Failed',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }
}

class SplitScreenTemplateGen03563 extends StatefulWidget {
  const SplitScreenTemplateGen03563({super.key});

  @override
  State<SplitScreenTemplateGen03563> createState() => _SplitScreenTemplateGen03563State();
}

class _SplitScreenTemplateGen03563State extends State<SplitScreenTemplateGen03563> {
  late List<BytEvidence> _evidenceList;
  bool _isLoading = false;
  Timer? _pollingTimer;
  final TextEditingController _inputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _evidenceList = MockBytRepository.getEvidence();
    _startPolling();
  }

  void _startPolling() {
    // Background polling refreshes data every 30 seconds
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _fetchData();
    });
  }

  Future<void> _fetchData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    
    // Simulate sub-100ms API response latency via optimized local fetch
    await Future.delayed(const Duration(milliseconds: 80));
    
    if (!mounted) return;
    setState(() {
      _evidenceList = MockBytRepository.getEvidence();
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _inputController.dispose();
    super.dispose();
  }

  void _showConfigurationBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Configuration Inputs', style: Theme.of(ctx).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextField(
                controller: _inputController,
                decoration: const InputDecoration(
                  labelText: 'Custom Evidence Filter',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Configuration saved: ${_inputController.text}'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: const Text('Apply Configuration'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status, ThemeData theme) {
    switch (status) {
      case 'Verified':
        return theme.colorScheme.primary;
      case 'Pending Review':
        return theme.colorScheme.tertiary;
      case 'Failed':
        return theme.colorScheme.error;
      default:
        return theme.colorScheme.outline;
    }
  }

  Widget _buildEvidencePanel(ThemeData theme) {
    return RefreshIndicator(
      onRefresh: _fetchData,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _evidenceList.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final evidence = _evidenceList[index];
          return Card(
            elevation: 3, // M3 Elevated Cards Level 2 (3dp)
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () {
                // Deep-link drill-down simulation
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Drilling down into ${evidence.id}')),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            evidence.title,
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                        Chip(
                          label: Text(evidence.status),
                          backgroundColor: _getStatusColor(evidence.status, theme).withOpacity(0.1),
                          labelStyle: TextStyle(color: _getStatusColor(evidence.status, theme)),
                          side: BorderSide.none,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(evidence.description, style: theme.textTheme.bodyMedium),
                    const SizedBox(height: 8),
                    Text(
                      'Timestamp: ${evidence.timestamp.toIso8601String()}',
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
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

  Widget _buildInputPanel(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Step Completion State', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.check_circle_outline, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text('Baseline Configuration Met', style: theme.textTheme.bodyLarge),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.pending_actions, color: theme.colorScheme.tertiary),
                      const SizedBox(width: 8),
                      Text('Validation Checks Pending', style: theme.textTheme.bodyLarge),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            minLines: 4,
            maxLines: 8,
            decoration: InputDecoration(
              labelText: 'Specific Byt Evidence Input',
              hintText: 'Enter evidence payload or reference ID...',
              border: const OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 24),
          // 48x48dp touch targets enforced by M3 defaults, explicitly setting minimum size
          SizedBox(
            height: 48,
            child: FilledButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Evidence submitted successfully.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              icon: const Icon(Icons.send),
              label: const Text('Submit Evidence'),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () => _showConfigurationBottomSheet(context),
              icon: const Icon(Icons.settings),
              label: const Text('Open Configuration'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;

    // M3 responsive layout: single-column on mobile (<600dp), multi-column on desktop (>=840dp)
    final bool isDesktop = width >= 840;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Byt Evidence Console'),
        centerTitle: false,
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              iconSize: 48, // Touch target consideration
              onPressed: _fetchData,
              icon: const Icon(Icons.sync),
              tooltip: 'Manual Sync',
            ),
        ],
      ),
      body: isDesktop
          ? Row(
              children: [
                // 50/50 split-screen
                Expanded(child: _buildEvidencePanel(theme)),
                VerticalDivider(width: 1, color: theme.colorScheme.outlineVariant),
                Expanded(child: _buildInputPanel(theme)),
              ],
            )
          : Column(
              children: [
                // Single-column mobile layout stacked vertically to maintain both views
                Expanded(child: _buildEvidencePanel(theme)),
                Divider(height: 1, color: theme.colorScheme.outlineVariant),
                Expanded(child: _buildInputPanel(theme)),
              ],
            ),
    );
  }
}
