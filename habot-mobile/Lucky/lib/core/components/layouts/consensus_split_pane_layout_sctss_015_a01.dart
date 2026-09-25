// SCTSS-015-A01 — Consensus Split-Pane Layout for Asynchronous Voting.
// Defines responsive split-pane ratios, vertical stacking on mobile (evidence top, action bottom),
// scroll-to-unlock voting CTA Poka-Yoke, and expiration auto-abstain timer.

import 'dart:async';
import 'package:flutter/material.dart';

/// Mock data model representing evidence to be reviewed before voting.
class EvidenceItem {
  final String id;
  final String title;
  final String content;
  final String syncType;
  final String syncStatus;
  final DateTime lastSyncDate;
  final int syncConflicts;
  final Duration syncDuration;

  const EvidenceItem({
    required this.id,
    required this.title,
    required this.content,
    required this.syncType,
    required this.syncStatus,
    required this.lastSyncDate,
    required this.syncConflicts,
    required this.syncDuration,
  });
}

/// Local mock repository providing realistic dummy data for the voting workflow.
class MockVotingRepository {
  static const List<EvidenceItem> evidenceItems = [
    EvidenceItem(
      id: 'EVD-001',
      title: 'System Downtime Report - Q3',
      content:
          'Detailed analysis of system downtime events during Q3. Includes root cause analysis, affected services, and mitigation strategies applied. Review carefully before casting your consensus vote on the proposed SLA adjustments.',
      syncType: 'ASYNC',
      syncStatus: 'COMPLETED',
      lastSyncDate: null, // Placeholder for compile-time const
      syncConflicts: 0,
      syncDuration: Duration(seconds: 45),
    ),
    EvidenceItem(
      id: 'EVD-002',
      title: 'Infrastructure Upgrade Proposal',
      content:
          'Proposal for migrating legacy database clusters to GCP BigQuery aligned architecture. Expected improvements in real-time polling of vote states and reduced synchronization meeting overhead. Please review cost-benefit analysis attached in context.',
      syncType: 'ASYNC',
      syncStatus: 'PENDING_REVIEW',
      lastSyncDate: null,
      syncConflicts: 1,
      syncDuration: Duration(minutes: 2),
    ),
  ];

  // Workaround for const DateTime limitation in mock data
  static List<EvidenceItem> getEvidence() {
    return evidenceItems.map((e) {
      return EvidenceItem(
        id: e.id,
        title: e.title,
        content: e.content,
        syncType: e.syncType,
        syncStatus: e.syncStatus,
        lastSyncDate: DateTime.now().subtract(const Duration(days: 2)),
        syncConflicts: e.syncConflicts,
        syncDuration: e.syncDuration,
      );
    }).toList();
  }
}

/// Responsive split-pane layout component for asynchronous consensus voting.
/// Utilizes LayoutBuilder to determine viewport constraints.
/// Mobile (<600px): Stacks panes vertically (Evidence top, Action bottom).
/// Desktop/Tablet (>=600px): Horizontal split with defined ratios.
class ConsensusSplitPaneLayout extends StatefulWidget {
  final List<EvidenceItem> evidence;
  final Duration expirationDuration;
  final VoidCallback? onVoteCast;
  final VoidCallback? onAutoAbstain;

  const ConsensusSplitPaneLayout({
    super.key,
    required this.evidence,
    this.expirationDuration = const Duration(minutes: 5),
    this.onVoteCast,
    this.onAutoAbstain,
  });

  @override
  State<ConsensusSplitPaneLayout> createState() =>
      _ConsensusSplitPaneLayoutState();
}

class _ConsensusSplitPaneLayoutState extends State<ConsensusSplitPaneLayout> {
  bool _hasScrolledToBottom = false;
  late Timer _expirationTimer;
  int _remainingSeconds = 0;
  bool _isAbstained = false;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.expirationDuration.inSeconds;
    _startExpirationTimer();
  }

  void _startExpirationTimer() {
    _expirationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 1) {
        timer.cancel();
        setState(() {
          _isAbstained = true;
        });
        widget.onAutoAbstain?.call();
      } else {
        setState(() {
          _remainingSeconds--;
        });
      }
    });
  }

  @override
  void dispose() {
    if (_expirationTimer.isActive) {
      _expirationTimer.cancel();
    }
    super.dispose();
  }

  void _handleScroll(ScrollNotification notification) {
    if (notification is ScrollEndNotification) {
      final metrics = notification.metrics;
      // Poka-Yoke: Unlock voting CTA only when user scrolls to the bottom of evidence pane
      if (metrics.pixels >= metrics.maxScrollExtent - 10) {
        if (!_hasScrolledToBottom) {
          setState(() {
            _hasScrolledToBottom = true;
          });
        }
      }
    }
  }

  void _submitVote(String vote) {
    _expirationTimer.cancel();
    widget.onVoteCast?.call();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vote "$vote" cast successfully.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        if (isMobile) {
          // Mobile-First Implication: Stacks panes vertically
          return Column(
            children: [
              Expanded(
                flex: 6, // Ratio: Evidence takes 60%
                child: _buildEvidencePane(),
              ),
              const Divider(height: 1, thickness: 2),
              Expanded(
                flex: 4, // Ratio: Action takes 40%
                child: _buildActionPane(isMobile: true),
              ),
            ],
          );
        } else {
          // Desktop/Tablet: Horizontal split-pane
          return Row(
            children: [
              Expanded(
                flex: 6, // Ratio: Evidence takes 60%
                child: _buildEvidencePane(),
              ),
              const VerticalDivider(width: 1, thickness: 2),
              Expanded(
                flex: 4, // Ratio: Action takes 40%
                child: _buildActionPane(isMobile: false),
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildEvidencePane() {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        _handleScroll(notification);
        return false;
      },
      child: Container(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        child: ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: widget.evidence.length,
          itemBuilder: (context, index) {
            final item = widget.evidence[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16.0),
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.content,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Chip(
                          label: Text('Sync: ${item.syncType}'),
                          backgroundColor:
                              Theme.of(context).colorScheme.secondaryContainer,
                        ),
                        Chip(
                          label: Text('Status: ${item.syncStatus}'),
                          backgroundColor:
                              Theme.of(context).colorScheme.tertiaryContainer,
                        ),
                        Chip(
                          label: Text('Conflicts: ${item.syncConflicts}'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildActionPane({required bool isMobile}) {
    final theme = Theme.of(context);

    if (_isAbstained) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.timer_off, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(
              'Session Expired. Auto-logged as "Abstain".',
              style: theme.textTheme.titleMedium
                  ?.copyWith(color: theme.colorScheme.error),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16.0),
      color: theme.colorScheme.surfaceContainerHighest,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Consensus Voting Action',
            style: theme.textTheme.headlineSmall,
            textAlign: isMobile ? TextAlign.center : TextAlign.start,
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: _remainingSeconds / widget.expirationDuration.inSeconds,
            backgroundColor: theme.colorScheme.surfaceVariant,
            valueColor: AlwaysStoppedAnimation<Color>(
              _remainingSeconds < 60
                  ? theme.colorScheme.error
                  : theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Time remaining: $_remainingSeconds seconds',
            style: theme.textTheme.bodySmall?.copyWith(
              color: _remainingSeconds < 60
                  ? theme.colorScheme.error
                  : theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: isMobile ? TextAlign.center : TextAlign.start,
          ),
          const SizedBox(height: 24),
          if (!_hasScrolledToBottom)
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline,
                      color: theme.colorScheme.onErrorContainer),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Please scroll to the bottom of the evidence pane to unlock voting actions.',
                      style: TextStyle(
                          color: theme.colorScheme.onErrorContainer,
                          fontSize: 12),
                    ),
                  ),
                ],
              ),
            )
          else ...[
            FilledButton.icon(
              onPressed: () => _submitVote('Approve'),
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Approve Consensus'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _submitVote('Reject'),
              icon: const Icon(Icons.cancel_outlined),
              label: const Text('Reject Consensus'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => _submitVote('Abstain'),
              child: const Text('Abstain Manually'),
            ),
          ],
          const Spacer(),
          Text(
            'Task Execution Quality Score Target: 4.5/5.0',
            style: theme.textTheme.labelSmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Example usage screen demonstrating the ConsensusSplitPaneLayout integration.
class AsynchronousVotingScreen extends StatelessWidget {
  const AsynchronousVotingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mockEvidence = MockVotingRepository.getEvidence();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Asynchronous Consensus Voting'),
        centerTitle: true,
      ),
      body: ConsensusSplitPaneLayout(
        evidence: mockEvidence,
        expirationDuration: const Duration(minutes: 5),
        onVoteCast: () {
          // Telemetry / BigQuery alignment hook would go here
        },
        onAutoAbstain: () {
          // System logs accurate downtime causes without bias
        },
      ),
    );
  }
}
