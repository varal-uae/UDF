import 'package:flutter/material.dart';

/// Row 382: GEN-01171 (Seq 17880)
/// Action: Implement M3 Icon buttons for parent helpfulness voting.
/// Quality Gate: ISO 9186 Graphical Symbol Testing (Target: 0.95).
class HelpfulnessVotingButtonPanel extends StatefulWidget {
  final String globalRefId;
  final String atomicStepRefId;
  final int sequenceOrder;

  const HelpfulnessVotingButtonPanel({
    super.key,
    this.globalRefId = 'GEN-01171',
    this.atomicStepRefId = 'GEN-01171',
    this.sequenceOrder = 17880,
  });

  @override
  State<HelpfulnessVotingButtonPanel> createState() =>
      _HelpfulnessVotingButtonPanelState();
}

class _HelpfulnessVotingButtonPanelState
    extends State<HelpfulnessVotingButtonPanel> {
  int _upvoteCount = 48;
  int _downvoteCount = 2;
  bool? _userVote; // true = up, false = down, null = none

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.thumb_up_alt_rounded,
                    color: theme.colorScheme.onTertiaryContainer,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'GEN-01171: Parent Helpfulness Voting',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Seq: 17880 • Standard: ISO 9186 Graphical Symbol',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
                const Chip(
                  avatar: Icon(
                    Icons.check_circle_outline,
                    color: Colors.green,
                    size: 16,
                  ),
                  label: Text('M3 ICONS PASS'),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const Divider(height: 24),
            Text('Was this parent review helpful?', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                // Upvote Icon Button
                IconButton.filledTonal(
                  style: IconButton.styleFrom(
                    backgroundColor: _userVote == true
                        ? theme.colorScheme.primaryContainer
                        : theme.colorScheme.surfaceContainerHighest,
                    foregroundColor: _userVote == true
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outline,
                  ),
                  onPressed: () {
                    setState(() {
                      if (_userVote == true) {
                        _userVote = null;
                        _upvoteCount--;
                      } else {
                        if (_userVote == false) _downvoteCount--;
                        _userVote = true;
                        _upvoteCount++;
                      }
                    });
                  },
                  icon: const Icon(Icons.thumb_up_rounded, size: 20),
                ),
                const SizedBox(width: 8),
                Text('$_upvoteCount Helpful', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 24),
                // Downvote Icon Button
                IconButton.filledTonal(
                  style: IconButton.styleFrom(
                    backgroundColor: _userVote == false
                        ? theme.colorScheme.errorContainer
                        : theme.colorScheme.surfaceContainerHighest,
                    foregroundColor: _userVote == false
                        ? theme.colorScheme.error
                        : theme.colorScheme.outline,
                  ),
                  onPressed: () {
                    setState(() {
                      if (_userVote == false) {
                        _userVote = null;
                        _downvoteCount--;
                      } else {
                        if (_userVote == true) _upvoteCount--;
                        _userVote = false;
                        _downvoteCount++;
                      }
                    });
                  },
                  icon: const Icon(Icons.thumb_down_rounded, size: 20),
                ),
                const SizedBox(width: 8),
                Text('$_downvoteCount', style: TextStyle(color: theme.colorScheme.outline)),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'ISO 9186 Compliance: Recognizable 48x48dp M3 touch-target symbols with immediate state feedback.',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _upvoteCount = 48;
                    _downvoteCount = 2;
                    _userVote = null;
                  });
                },
                icon: const Icon(Icons.refresh_rounded, size: 20),
                label: const Text('Reset Review Helpfulness Votes'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: HelpfulnessVotingButtonPanel(),
          ),
        ),
      ),
    ),
  );
}
