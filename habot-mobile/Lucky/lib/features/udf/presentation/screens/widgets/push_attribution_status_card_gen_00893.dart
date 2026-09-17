// GEN-00893 — UI Widget: Reusable M3 Elevated Card (Level 2) displaying event health.
// Uses an M3 status chip, 48x48dp touch targets and sub-100ms latency indicator.

import 'package:flutter/material.dart';

import '../models/push_attribution_event_gen_00893.dart';

/// M3 Elevated Card presenting a single push attribution conversion event.
class PushAttributionStatusCard extends StatelessWidget {
  const PushAttributionStatusCard({
    required this.event,
    this.onTap,
    super.key,
  });

  final PushAttributionEvent event;
  final VoidCallback? onTap;

  bool get _isPassing => event.completionStatus == CompletionStatus.pass;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 72),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        event.campaignId,
                        style: theme.textTheme.titleMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${event.channel.name} • ${event.latencyMs} ms',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'trace: ${event.traceId}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _StatusChip(isPassing: _isPassing),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.isPassing});

  final bool isPassing;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color background = isPassing
        ? scheme.secondaryContainer
        : scheme.errorContainer;
    final Color foreground = isPassing
        ? scheme.onSecondaryContainer
        : scheme.onErrorContainer;

    return Semantics(
      label: isPassing ? 'Status pass' : 'Status fail',
      child: Container(
        constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          isPassing ? 'Pass' : 'Fail',
          style: TextStyle(
            color: foreground,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
