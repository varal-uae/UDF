// SSELC-020-A11 — Consensus Split-Pane Layout with Scroll Tracking.
// Implements a responsive 60/40 horizontal split view for widescreen and vertical stacking for mobile, including scroll-to-unlock voting CTA, hit-box expansion, back navigation, and expiration timer auto-abstain logic.

import 'dart:async';
import 'package:flutter/material.dart';

// --- Mock Data & Models ---

class StepExecutionRecord {
  final String stepExecutionId;
  final String userId;
  final String executionStatus;
  final DateTime executionTimestamp;
  final String stepOutcome;

  const StepExecutionRecord({
    required this.stepExecutionId,
    required this.userId,
    required this.executionStatus,
    required this.executionTimestamp,
    required this.stepOutcome,
  });

  Map<String, dynamic> toJson() => {
        'step_execution_id': stepExecutionId,
        'user_id': userId,
        'execution_status': executionStatus,
        'execution_timestamp': executionTimestamp.toIso8601String(),
        'step_outcome': stepOutcome,
      };
}

final List<String> mockEvidenceData = List.generate(
  30,
  (i) => 'Evidence Item ${i + 1}: Detailed asynchronous consensus data requiring independent evaluation. '
      'This ensures voters make informed decisions without leaving context. '
      'Structured agreement protocols enforce binding compliance rates above 0.90 floor boundary.',
);

// --- Main Widget ---

class ConsensusSplitPaneLayout extends StatefulWidget {
  final VoidCallback? onBackToTable;
  final ValueChanged<StepExecutionRecord>? onVoteCast;
  final Duration expirationDuration;

  const ConsensusSplitPaneLayout({
    super.key,
    this.onBackToTable,
    this.onVoteCast,
    this.expirationDuration = const Duration(minutes: 5),
  });

  @override
  State<ConsensusSplitPaneLayout> createState() => _ConsensusSplitPaneLayoutState();
}

class _ConsensusSplitPaneLayoutState extends State<ConsensusSplitPaneLayout> {
  final ScrollController _evidenceScrollController = ScrollController();
  bool _hasScrolledToBottom = false;
  Timer? _expirationTimer;
  int _remainingSeconds = 0;

  static const double _kFloorBoundary = 0.90;
  static const double _kOptimalTarget = 0.99;
  static const double _kCeilingBoundary = 1.0;
  static const double _kHitBoxExpansion = 12.0;

  @override
  void initState() {
    super.initState();
    _evidenceScrollController.addListener(_onEvidenceScroll);
    _startExpirationTimer();
  }

  void _startExpirationTimer() {
    _remainingSeconds = widget.expirationDuration.inSeconds;
    _expirationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _remainingSeconds--;
        if (_remainingSeconds <= 0) {
          timer.cancel();
          _autoLogAbstain();
        }
      });
    });
  }

  void _onEvidenceScroll() {
    if (!_evidenceScrollController.hasClients) return;
    final maxScroll = _evidenceScrollController.position.maxScrollExtent;
    final currentScroll = _evidenceScrollController.position.pixels;
    // Poka-Yoke: Unlock voting CTA only when scrolled to bottom (with small tolerance)
    if (currentScroll >= maxScroll - 20.0 && !_hasScrolledToBottom) {
      setState(() {
        _hasScrolledToBottom = true;
      });
    }
  }

  void _autoLogAbstain() {
    final record = StepExecutionRecord(
      stepExecutionId: 'SSELC-020-A11-${DateTime.now().millisecondsSinceEpoch}',
      userId: 'mock_user_001',
      executionStatus: 'AUTO_ABSTAIN',
      executionTimestamp: DateTime.now(),
      stepOutcome: 'Abstained due to expiration timer',
    );
    widget.onVoteCast?.call(record);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session expired. Vote automatically logged as Abstain.')),
      );
    }
  }

  void _castVote(String decision) {
    _expirationTimer?.cancel();
    final record = StepExecutionRecord(
      stepExecutionId: 'SSELC-020-A11-${DateTime.now().millisecondsSinceEpoch}',
      userId: 'mock_user_001',
      executionStatus: 'COMPLETED',
      executionTimestamp: DateTime.now(),
      stepOutcome: decision,
    );
    widget.onVoteCast?.call(record);
  }

  @override
  void dispose() {
    _expirationTimer?.cancel();
    _evidenceScrollController.removeListener(_onEvidenceScroll);
    _evidenceScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWidescreen = constraints.maxWidth > 768;
        if (isWidescreen) {
          return _buildHorizontalSplitView(constraints);
        } else {
          return _buildVerticalStackedView(constraints);
        }
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Row(
        children: [
          // Clear, large "Back to Table" arrow button within mobile detail headers
          Padding(
            padding: const EdgeInsets.all(_kHitBoxExpansion / 2),
            child: SizedBox(
              width: 48 + _kHitBoxExpansion,
              height: 48 + _kHitBoxExpansion,
              child: IconButton(
                iconSize: 28,
                tooltip: 'Back to Table',
                onPressed: widget.onBackToTable,
                icon: const Icon(Icons.arrow_back_rounded),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Consensus Review',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Time remaining: ${(_remainingSeconds ~/ 60).toString().padLeft(2, '0')}:${(_remainingSeconds % 60).toString().padLeft(2, '0')}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _remainingSeconds < 60 ? Colors.red : null,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEvidencePane(BoxConstraints constraints, {required bool isPrimary}) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Evidence Review Pane',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: Scrollbar(
              controller: _evidenceScrollController,
              thumbVisibility: true,
              child: ListView.builder(
                controller: _evidenceScrollController,
                padding: const EdgeInsets.all(16.0),
                itemCount: mockEvidenceData.length,
                itemBuilder: (context, index) {
                  // Keep selected rows distinctly highlighted
                  final isSelected = index == 0; 
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12.0),
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
                          : Theme.of(context).colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(8.0),
                      border: isSelected
                          ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2)
                          : null,
                    ),
                    child: Text(mockEvidenceData[index]),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionPane(BoxConstraints constraints) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Cast Your Decision',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Compliance Target: Optimal $_kOptimalTarget | Floor $_kFloorBoundary',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 32),
          if (!_hasScrolledToBottom)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                'Please scroll to the bottom of the evidence pane to unlock voting.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          // Configure hit-box expansion boundaries around compact visual elements
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: SizedBox(
              height: 56 + _kHitBoxExpansion,
              child: FilledButton.icon(
                onPressed: _hasScrolledToBottom ? () => _castVote('APPROVE') : null,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Approve'),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: SizedBox(
              height: 56 + _kHitBoxExpansion,
              child: OutlinedButton.icon(
                onPressed: _hasScrolledToBottom ? () => _castVote('REJECT') : null,
                icon: const Icon(Icons.cancel_outlined),
                label: const Text('Reject'),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: SizedBox(
              height: 56 + _kHitBoxExpansion,
              child: TextButton.icon(
                onPressed: _hasScrolledToBottom ? () => _castVote('ABSTAIN') : null,
                icon: const Icon(Icons.remove_circle_outline),
                label: const Text('Abstain'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Open details inside an elegant 60/40 horizontal split view across widescreen layouts
  Widget _buildHorizontalSplitView(BoxConstraints constraints) {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: Row(
            children: [
              // 60% Evidence Pane
              Flexible(
                flex: 6,
                child: _buildEvidencePane(constraints, isPrimary: true),
              ),
              VerticalDivider(
                width: 1,
                thickness: 1,
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              // 40% Action Pane
              Flexible(
                flex: 4,
                child: _buildActionPane(constraints),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Stacks panes vertically (Evidence top, Action bottom) ensuring the voting CTA is always reachable
  // CSS Flexbox column equivalent in Flutter
  Widget _buildVerticalStackedView(BoxConstraints constraints) {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          flex: 6,
          child: _buildEvidencePane(constraints, isPrimary: true),
        ),
        Divider(
          height: 1,
          thickness: 1,
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
        Expanded(
          flex: 4,
          child: _buildActionPane(constraints),
        ),
      ],
    );
  }
}