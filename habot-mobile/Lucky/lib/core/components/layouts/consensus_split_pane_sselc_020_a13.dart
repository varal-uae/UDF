// SSELC-020-A13 — Consensus Split-Pane Layout with Responsive Voting UI.
// Implements a 60/40 horizontal split on widescreen and vertical stacking on mobile, with scroll-gated voting CTA and expiration timer auto-abstain logic.

import 'dart:async';
import 'package:flutter/material.dart';

/// Mock data for evidence pane demonstration.
class _MockEvidenceData {
  static const String installationId = 'INST-2026-09-25-001';
  static const String status = 'Pending Review';
  static const String timestamp = '2026-09-25T10:00:00Z';
  static const String configDetails = 'Standard consensus configuration v2.4';
  static const String systemPath = '/varal-uae/UDF/configs/consensus.json';
  static const List<String> evidenceItems = [
    'System log entry 1: Transaction initiated at 09:55 UTC.',
    'System log entry 2: Node A acknowledged receipt.',
    'System log entry 3: Validation hash matched expected output.',
    'System log entry 4: Latency recorded at 45ms (within optimal target of 2s).',
    'System log entry 5: No orphaned values detected in parameter mapping.',
    'System log entry 6: Configuration parameter accuracy passed floor boundary check.',
    'System log entry 7: User session ID linked to OPS decision group.',
    'System log entry 8: Installation status verified as active.',
    'System log entry 9: Completion measures validated at minimum widths.',
    'System log entry 10: End of evidence stream. Scroll complete.',
  ];
}

enum VoteState { pending, approved, rejected, abstained }

class ConsensusSplitPane extends StatefulWidget {
  final int expirationSeconds;
  final VoidCallback? onBackToTable;

  const ConsensusSplitPane({
    super.key,
    this.expirationSeconds = 120,
    this.onBackToTable,
  });

  @override
  State<ConsensusSplitPane> createState() => _ConsensusSplitPaneState();
}

class _ConsensusSplitPaneState extends State<ConsensusSplitPane> {
  final ScrollController _evidenceScrollController = ScrollController();
  bool _hasScrolledToBottom = false;
  VoteState _voteState = VoteState.pending;
  late Timer _expirationTimer;
  int _remainingSeconds = 0;

  // Real-time polling mock state
  final Map<String, VoteState> _incomingVotes = {
    'User_A': VoteState.approved,
    'User_B': VoteState.pending,
    'User_C': VoteState.rejected,
  };

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.expirationSeconds;
    _evidenceScrollController.addListener(_onEvidenceScroll);
    _startExpirationTimer();
    _startRealTimePollingMock();
  }

  void _startExpirationTimer() {
    _expirationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _remainingSeconds--;
        if (_remainingSeconds <= 0) {
          _submitVote(VoteState.abstained);
          timer.cancel();
        }
      });
    });
  }

  void _startRealTimePollingMock() {
    // Simulates real-time polling hooks updating incoming vote states dynamically
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _incomingVotes['User_B'] = VoteState.approved;
        });
      }
    });
  }

  void _onEvidenceScroll() {
    if (_evidenceScrollController.position.pixels >=
        _evidenceScrollController.position.maxScrollExtent - 10) {
      if (!_hasScrolledToBottom) {
        setState(() {
          _hasScrolledToBottom = true;
        });
      }
    }
  }

  void _submitVote(VoteState vote) {
    if (_expirationTimer.isActive) {
      _expirationTimer.cancel();
    }
    setState(() {
      _voteState = vote;
    });
  }

  @override
  void dispose() {
    _expirationTimer.cancel();
    _evidenceScrollController.removeListener(_onEvidenceScroll);
    _evidenceScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWideScreen = MediaQuery.of(context).size.width >= 800;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          tooltip: 'Back to Table',
          onPressed: widget.onBackToTable ?? () => Navigator.of(context).pop(),
        ),
        title: const Text('Consensus Review'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: Text(
                _voteState == VoteState.pending
                    ? 'Expires in: ${_remainingSeconds}s'
                    : 'Status: ${_voteState.name.toUpperCase()}',
                style: TextStyle(
                  color: _remainingSeconds < 15 && _voteState == VoteState.pending
                      ? Colors.redAccent
                      : null,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: isWideScreen ? _buildHorizontalSplit() : _buildVerticalStack(),
    );
  }

  /// Open details inside an elegant 60/40 horizontal split view across widescreen layouts.
  Widget _buildHorizontalSplit() {
    return Row(
      children: [
        Expanded(flex: 60, child: _buildEvidencePane()),
        const VerticalDivider(width: 1, thickness: 1),
        Expanded(flex: 40, child: _buildActionPane()),
      ],
    );
  }

  /// Stacks panes vertically (Evidence top, Action bottom) ensuring the voting CTA is always reachable.
  /// CSS Flexbox column equivalent implemented via Flutter Column.
  Widget _buildVerticalStack() {
    return Column(
      children: [
        Expanded(flex: 60, child: _buildEvidencePane()),
        const Divider(height: 1, thickness: 1),
        Expanded(flex: 40, child: _buildActionPane()),
      ],
    );
  }

  Widget _buildEvidencePane() {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Evidence Pane',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              controller: _evidenceScrollController,
              padding: const EdgeInsets.all(16.0),
              itemCount: _MockEvidenceData.evidenceItems.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildMetadataHeader();
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Text(
                    _MockEvidenceData.evidenceItems[index - 1],
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataHeader() {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Installation ID: ${_MockEvidenceData.installationId}', style: theme.textTheme.bodySmall),
            Text('Status: ${_MockEvidenceData.status}', style: theme.textTheme.bodySmall),
            Text('Timestamp: ${_MockEvidenceData.timestamp}', style: theme.textTheme.bodySmall),
            Text('Config: ${_MockEvidenceData.configDetails}', style: theme.textTheme.bodySmall),
            Text('Path: ${_MockEvidenceData.systemPath}', style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }

  Widget _buildActionPane() {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.surface,
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Decision Actions',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            'Incoming Vote States:',
            style: theme.textTheme.labelLarge,
          ),
          const SizedBox(height: 8),
          ..._incomingVotes.entries.map((entry) => Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(entry.key, style: theme.textTheme.bodyMedium),
                    Chip(
                      label: Text(entry.value.name.toUpperCase()),
                      backgroundColor: _getVoteColor(entry.value),
                      labelStyle: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ],
                ),
              )),
          const Spacer(),
          if (!_hasScrolledToBottom && _voteState == VoteState.pending)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                'Please scroll to the bottom of the evidence pane to unlock voting.',
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.orange),
                textAlign: TextAlign.center,
              ),
            ),
          if (_voteState == VoteState.pending) ...[
            FilledButton.icon(
              onPressed: _hasScrolledToBottom ? () => _submitVote(VoteState.approved) : null,
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Approve'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _hasScrolledToBottom ? () => _submitVote(VoteState.rejected) : null,
              icon: const Icon(Icons.cancel_outlined),
              label: const Text('Reject'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ] else ...[
            Center(
              child: Column(
                children: [
                  Icon(
                    _voteState == VoteState.approved
                        ? Icons.check_circle
                        : _voteState == VoteState.rejected
                            ? Icons.cancel
                            : Icons.hourglass_empty,
                    size: 64,
                    color: _getVoteColor(_voteState),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Vote Recorded: ${_voteState.name.toUpperCase()}',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _getVoteColor(_voteState),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getVoteColor(VoteState state) {
    switch (state) {
      case VoteState.approved:
        return Colors.green;
      case VoteState.rejected:
        return Colors.red;
      case VoteState.abstained:
        return Colors.grey;
      case VoteState.pending:
        return Colors.blue;
    }
  }
}