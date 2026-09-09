// AWCV-013-A11 — Async Consensus Voting Card.
// A swipeable/binary-action card for asynchronous executive voting; swiping right agrees, left disagrees, and an expiry timer auto-casts Abstain.

import 'dart:async';

import 'package:flutter/material.dart';

enum VotingDecision { agree, disagree, abstain }

class Awcv013A11AsyncVotingCard extends StatefulWidget {
  const Awcv013A11AsyncVotingCard({
    super.key,
    required this.title,
    required this.summary,
    required this.expiryDuration,
    this.onVote,
  });

  final String title;
  final String summary;
  final Duration expiryDuration;
  final ValueChanged<VotingDecision>? onVote;

  @override
  State<Awcv013A11AsyncVotingCard> createState() =>
      _Awcv013A11AsyncVotingCardState();
}

class _Awcv013A11AsyncVotingCardState extends State<Awcv013A11AsyncVotingCard> {
  Timer? _expiryTimer;
  VotingDecision? _decision;
  bool _isExpired = false;

  @override
  void initState() {
    super.initState();
    _expiryTimer = Timer(widget.expiryDuration, _onExpired);
  }

  @override
  void dispose() {
    _expiryTimer?.cancel();
    super.dispose();
  }

  void _onExpired() {
    if (_decision != null) return;
    setState(() {
      _isExpired = true;
      _decision = VotingDecision.abstain;
    });
    widget.onVote?.call(VotingDecision.abstain);
  }

  void _cast(VotingDecision decision) {
    if (_decision != null || _isExpired) return;
    _expiryTimer?.cancel();
    setState(() => _decision = decision);
    widget.onVote?.call(decision);
  }

  void _handleDragEnd(DragEndDetails details) {
    if (_decision != null || _isExpired) return;
    final velocity = details.primaryVelocity ?? 0;
    if (velocity < -300) {
      _cast(VotingDecision.disagree);
    } else if (velocity > 300) {
      _cast(VotingDecision.agree);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isLocked = _decision != null || _isExpired;

    return Semantics(
      container: true,
      label: 'Voting card: ${widget.title}',
      hint: 'Swipe right to agree, left to disagree, or use the buttons below.',
      liveRegion: true,
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.all(8),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.title,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.summary,
                style: textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              if (_isExpired)
                Text(
                  'Expired — vote recorded as Abstain',
                  style: textTheme.labelLarge?.copyWith(
                    color: colors.error,
                  ),
                )
              else if (_decision != null)
                Text(
                  'Vote recorded: ${_decision!.name.toUpperCase()}',
                  style: textTheme.labelLarge?.copyWith(
                    color: _decision == VotingDecision.agree
                        ? colors.primary
                        : _decision == VotingDecision.disagree
                            ? colors.error
                            : colors.tertiary,
                  ),
                ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.tonalIcon(
                      onPressed: isLocked
                          ? null
                          : () => _cast(VotingDecision.disagree),
                      icon: const Icon(Icons.thumb_down_alt_outlined),
                      label: const Text('Disagree'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(56),
                        backgroundColor: colors.errorContainer,
                        foregroundColor: colors.onErrorContainer,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: isLocked
                          ? null
                          : () => _cast(VotingDecision.agree),
                      icon: const Icon(Icons.thumb_up_alt_outlined),
                      label: const Text('Agree'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(56),
                        backgroundColor: colors.primaryContainer,
                        foregroundColor: colors.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (!isLocked)
                GestureDetector(
                  onHorizontalDragEnd: _handleDragEnd,
                  child: Container(
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(color: colors.outlineVariant),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Swipe right = Agree  |  Swipe left = Disagree',
                      style: textTheme.labelMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
