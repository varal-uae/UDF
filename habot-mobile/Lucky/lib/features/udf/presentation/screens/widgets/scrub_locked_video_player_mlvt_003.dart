// MLVTP-003 — Scrub-Locked Video Player UX with Material 3 Error Feedback.
// Provides a responsive 16:9 video player widget that prevents scrubbing, displays concise warning typography beneath upload cards, and forces error dialogs to center fluidly across smartphone view boundaries using bright contrast styling.

import 'package:flutter/material.dart';

/// Mock data representing the atomic-level access fields required by MLVTP-003.
class _MockAccessData {
  final String accessType;
  final String userRole;
  final int permissionLevel;
  final String accessLog;
  final DateTime accessTimestamp;

  const _MockAccessData({
    required this.accessType,
    required this.userRole,
    required this.permissionLevel,
    required this.accessLog,
    required this.accessTimestamp,
  });
}

const _MockAccessData _mockSession = _MockAccessData(
  accessType: 'Mobile_App',
  userRole: 'Learner',
  permissionLevel: 2,
  accessLog: 'Initial cold state payload fetch',
  accessTimestamp: null as dynamic,
);

/// A scrub-locked video player container enforcing 16:9 aspect ratio,
/// Material 3 error tracking feedback patterns, and bright contrast warnings.
class ScrubLockedVideoPlayerMlvtp003 extends StatefulWidget {
  const ScrubLockedVideoPlayerMlvtp003({super.key});

  @override
  State<ScrubLockedVideoPlayerMlvtp003> createState() => _ScrubLockedVideoPlayerMlvtp003State();
}

class _ScrubLockedVideoPlayerMlvtp003State extends State<ScrubLockedVideoPlayerMlvtp003> {
  bool _isPlaying = false;
  bool _hasError = false;

  void _togglePlayback() {
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  void _triggerSecurityWarning() {
    setState(() {
      _hasError = true;
    });
    _showCenteredErrorDialog();
  }

  void _showCenteredErrorDialog() {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
          title: Text(
            'Security Protocol Enforced',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onErrorContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Legacy TLS connections are rejected. Ensure your network complies with TLS 1.3 minimum requirements.',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _hasError = false;
                });
              },
              child: Text(
                'Acknowledge',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 16:9 Responsive Video Container (Aspect-ratio CSS box equivalent)
        AspectRatio(
          aspectRatio: 16 / 9,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(
                color: _hasError ? colorScheme.error : colorScheme.outlineVariant,
                width: 2.0,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Mock Video Surface
                Center(
                  child: Icon(
                    _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                    size: 72.0,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                // Scrub Lock Overlay (Prevents interaction with seek bars)
                Positioned.fill(
                  child: GestureDetector(
                    onTap: _togglePlayback,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      color: Colors.transparent,
                    ),
                  ),
                ),
                // Bright Contrast Security Badge
                Positioned(
                  top: 12.0,
                  right: 12.0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.lock_outline, size: 14.0, color: colorScheme.onPrimaryContainer),
                        const SizedBox(width: 4.0),
                        Text(
                          'TLS 1.3 SECURE',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12.0),

        // Highly concise warning typography blocks directly beneath upload cards/player
        if (_hasError || true)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: colorScheme.errorContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: colorScheme.error.withOpacity(0.5)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: colorScheme.error,
                  size: 20.0,
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Text(
                    'Scrubbing is disabled for compliance. Continuous, frictionless upskilling requires sequential playback. Downgrade vulnerabilities are actively monitored.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onErrorContainer,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 16.0),

        // Action Buttons simulating infrastructure triggers in UI
        OutlinedButton.icon(
          onPressed: _triggerSecurityWarning,
          icon: const Icon(Icons.security_update_warning),
          label: const Text('Simulate Handshake Anomaly'),
          style: OutlinedButton.styleFrom(
            foregroundColor: colorScheme.error,
            side: BorderSide(color: colorScheme.error),
          ),
        ),
      ],
    );
  }
}
