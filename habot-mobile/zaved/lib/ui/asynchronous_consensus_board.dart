import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/semantic_status_colors.dart';

/// Data structure for consensus proposals
class ConsensusProposal {
  const ConsensusProposal({
    required this.id,
    required this.title,
    required this.description,
    required this.author,
    required this.category,
  });

  final String id;
  final String title;
  final String description;
  final String author;
  final String category;
}

/// Asynchronous Consensus Board widget with Tinder-like swipe gestures, fallback buttons, and auto-abstain timer.
class AsynchronousConsensusBoard extends StatefulWidget {
  const AsynchronousConsensusBoard({
    super.key,
    required this.proposal,
    required this.onVoteSubmitted,
    this.initialDurationSeconds = 15,
  });

  final ConsensusProposal proposal;
  final ValueChanged<String> onVoteSubmitted;
  final int initialDurationSeconds;

  @override
  State<AsynchronousConsensusBoard> createState() =>
      _AsynchronousConsensusBoardState();
}

class _AsynchronousConsensusBoardState
    extends State<AsynchronousConsensusBoard> {
  late int _remainingSeconds;
  Timer? _timer;
  double _dragDx = 0.0;
  bool _hasVoted = false;
  String? _voteResult;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.initialDurationSeconds;
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _timer?.cancel();
        // Poka-Yoke Rule: Auto-trigger 'Abstain' when timer hits 00:00:00
        if (!_hasVoted) {
          submitVote('Abstain');
        }
      }
    });
  }

  /// Triggers vote submission and cancels expiration timer
  void submitVote(String vote) {
    if (_hasVoted) return;

    _timer?.cancel();
    setState(() {
      _hasVoted = true;
      _voteResult = vote;
      if (vote == 'Agree') {
        _dragDx = 400.0;
      } else if (vote == 'Disagree') {
        _dragDx = -400.0;
      }
    });

    widget.onVoteSubmitted(vote);
  }

  /// Formatted timer HH:MM:SS
  String get _formattedTime {
    final duration = Duration(seconds: _remainingSeconds);
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColors = theme.extension<SemanticStatusColors>()!;

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 440.0),
        margin: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Expiration Timer Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.timer_outlined,
                    size: 20.0,
                    color: _remainingSeconds <= 5
                        ? statusColors.error
                        : theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8.0),
                  Text(
                    'Time Remaining: $_formattedTime',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.0,
                      color: _remainingSeconds <= 5
                          ? statusColors.error
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),

            // 1. Swipeable Card Layout & 2. Touch-Gesture Handling
            if (!_hasVoted)
              GestureDetector(
                onHorizontalDragUpdate: (details) {
                  setState(() {
                    _dragDx += details.delta.dx;
                  });
                },
                onHorizontalDragEnd: (details) {
                  // Swiping Right -> Agree, Swiping Left -> Disagree
                  if (_dragDx > 100) {
                    submitVote('Agree');
                  } else if (_dragDx < -100) {
                    submitVote('Disagree');
                  } else {
                    setState(() {
                      _dragDx = 0.0;
                    });
                  }
                },
                child: Transform.translate(
                  offset: Offset(_dragDx, 0),
                  child: Transform.rotate(
                    angle: _dragDx / 1000.0,
                    child: _buildCardContent(theme, statusColors),
                  ),
                ),
              )
            else
              _buildVotedCard(theme, statusColors),
          ],
        ),
      ),
    );
  }

  Widget _buildCardContent(
      ThemeData theme, SemanticStatusColors statusColors) {
    return Card(
      elevation: 6.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Top Pane for Data (Strings)
          Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16.0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Chip(
                      label: Text(widget.proposal.category),
                      backgroundColor: theme.colorScheme.primaryContainer,
                    ),
                    if (_dragDx > 40)
                      Text(
                        'AGREE',
                        style: TextStyle(
                          color: statusColors.success,
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                        ),
                      )
                    else if (_dragDx < -40)
                      Text(
                        'DISAGREE',
                        style: TextStyle(
                          color: statusColors.error,
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16.0),
                Text(
                  widget.proposal.title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  widget.proposal.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16.0),
                Text(
                  'Proposed by: ${widget.proposal.author}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // 1. Bottom Pane for Actions / 3. Massive Fallback Buttons
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLow,
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(16.0)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 56.0,
                    child: OutlinedButton.icon(
                      onPressed: () => submitVote('Disagree'),
                      icon: Icon(Icons.close, color: statusColors.error),
                      label: Text(
                        'Disagree',
                        style: TextStyle(
                          color: statusColors.error,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: statusColors.error, width: 2.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: SizedBox(
                    height: 56.0,
                    child: FilledButton.icon(
                      onPressed: () => submitVote('Agree'),
                      icon: const Icon(Icons.check),
                      label: const Text(
                        'Agree',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: statusColors.success,
                        foregroundColor: theme.colorScheme.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVotedCard(ThemeData theme, SemanticStatusColors statusColors) {
    final isAgree = _voteResult == 'Agree';
    final isDisagree = _voteResult == 'Disagree';

    final Color badgeColor = isAgree
        ? statusColors.success
        : (isDisagree ? statusColors.error : theme.colorScheme.outline);

    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isAgree
                  ? Icons.check_circle
                  : (isDisagree ? Icons.cancel : Icons.hourglass_disabled),
              size: 64.0,
              color: badgeColor,
            ),
            const SizedBox(height: 16.0),
            Text(
              'Vote Recorded: $_voteResult',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: badgeColor,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              _voteResult == 'Abstain'
                  ? 'Timer expired (00:00:00). Auto-Abstain was triggered.'
                  : 'Your vote on "${widget.proposal.title}" has been registered.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 24.0),
            OutlinedButton(
              onPressed: () {
                setState(() {
                  _hasVoted = false;
                  _dragDx = 0.0;
                  _remainingSeconds = widget.initialDurationSeconds;
                  _voteResult = null;
                });
                _startTimer();
              },
              child: const Text('Reset Proposal Vote'),
            ),
          ],
        ),
      ),
    );
  }
}
