/*
 * STEP 10: 168 — Server-Sent Events (SSE) Frontend Connection Hook & Status Indicator
 * 
 * Setup Step (Action): Build micro status icon UI component adhering to Material Design 3 system color standards.
 * Setup Step Description: Green (connected), Yellow (reconnecting), Red (disconnected) indicators.
 * 
 * Mobile-First & Responsive UX/UI Decisions:
 *   - Compact status indicator fitting neatly into mobile app bars and cards.
 *   - Adheres to MD3 color token standards for real-time connection state indicators.
 *   - Live event count stream reception tracker.
 * 
 * What Was Done to Complete This Step:
 *   - Created `SseStatusIndicator` widget, `SseConnectionStatus` model, and `SseState` enum in a single file.
 *   - Implemented real-time status color mapping, event count display, and reconnect action triggers.
 */

import 'package:flutter/material.dart';
import '../tokens/color_palette.dart';
import '../tokens/spacing_tokens.dart';

enum SseState {
  connected,    // Green
  reconnecting, // Yellow
  disconnected, // Red
}

class SseConnectionStatus {
  final SseState state;
  final String serverEndpoint;
  final int eventCountReceived;

  const SseConnectionStatus({
    required this.state,
    required this.serverEndpoint,
    this.eventCountReceived = 0,
  });
}

/// Step 168: Server-Sent Events (SSE) Connection Hook & Status Tracking Indicator.
class SseStatusIndicator extends StatelessWidget {
  final SseConnectionStatus sseStatus;
  final VoidCallback? onReconnectTap;

  const SseStatusIndicator({
    super.key,
    required this.sseStatus,
    this.onReconnectTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color dotColor;
    String label;

    switch (sseStatus.state) {
      case SseState.connected:
        dotColor = AppColorPalette.success;
        label = 'SSE Stream Connected (${sseStatus.eventCountReceived} events)';
        break;
      case SseState.reconnecting:
        dotColor = AppColorPalette.warning;
        label = 'SSE Reconnecting...';
        break;
      case SseState.disconnected:
        dotColor = AppColorPalette.lightError;
        label = 'SSE Stream Disconnected';
        break;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacingTokens.md, vertical: AppSpacingTokens.sm),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                // Micro Status Indicator Dot
                Container(
                  width: 12.0,
                  height: 12.0,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: dotColor.withValues(alpha: 0.5),
                        blurRadius: 6.0,
                        spreadRadius: 2.0,
                      ),
                    ],
                  ),
                ),
                AppSpacingTokens.hGapSm,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                    Text(sseStatus.serverEndpoint, style: theme.textTheme.bodySmall?.copyWith(fontFamily: 'monospace')),
                  ],
                ),
              ],
            ),
            if (sseStatus.state != SseState.connected)
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Reconnect SSE',
                onPressed: onReconnectTap,
              ),
          ],
        ),
      ),
    );
  }
}
