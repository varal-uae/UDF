// FCSES-019-14 — Operational Alert Panel with Dead Letter Queue Metrics.
// Displays background message volumes/performance, pins alert banners below top navigation, locks UI until thresholds match, and highlights modified comparison text with soft green tint.

import 'package:flutter/material.dart';

class Fcses01914OperationalAlertPanel extends StatefulWidget {
  const Fcses01914OperationalAlertPanel({
    super.key,
    required this.backgroundVolume,
    required this.performanceScore,
    required this.minimumScore,
    required this.modifiedFields,
  });

  final int backgroundVolume;
  final double performanceScore;
  final double minimumScore;
  final List<String> modifiedFields;

  @override
  State<Fcses01914OperationalAlertPanel> createState() => _Fcses01914OperationalAlertPanelState();
}

class _Fcses01914OperationalAlertPanelState extends State<Fcses01914OperationalAlertPanel> {
  bool _alertVisible = true;

  bool get _isLocked => widget.performanceScore < widget.minimumScore;

  Future<void> _confirmHideAlert() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm alert dismissal'),
        content: const Text('Clear action confirmation is required before hiding alert elements.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      setState(() {
        _alertVisible = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AbsorbPointer(
      absorbing: _isLocked,
      child: Opacity(
        opacity: _isLocked ? 0.6 : 1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _PinnedAlertBanner(
              visible: _alertVisible,
              isLocked: _isLocked,
              onDismiss: _confirmHideAlert,
            ),
            const SizedBox(height: 12),
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.security, color: colorScheme.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Operational Messaging Panel',
                            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        if (_isLocked)
                          Chip(
                            avatar: Icon(Icons.lock, size: 16, color: colorScheme.error),
                            label: const Text('Locked'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _MetricRow(
                      label: 'Background message volume',
                      value: widget.backgroundVolume.toString(),
                      icon: Icons.mark_email_unread_outlined,
                    ),
                    const SizedBox(height: 8),
                    _MetricRow(
                      label: 'Process execution quality score',
                      value: '${widget.performanceScore.toStringAsFixed(1)}%',
                      icon: Icons.speed,
                      isWarning: _isLocked,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Modified comparison fields',
                      style: textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.modifiedFields
                          .map(
                            (field) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDFF5E1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                field,
                                style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    if (_isLocked) ...[
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.warning_amber_rounded, color: colorScheme.error),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Interface remains locked until background values match the required rules.',
                              style: textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PinnedAlertBanner extends StatelessWidget {
  const _PinnedAlertBanner({
    required this.visible,
    required this.isLocked,
    required this.onDismiss,
  });

  final bool visible;
  final bool isLocked;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: colorScheme.errorContainer,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.warning, color: colorScheme.onErrorContainer),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Alert: background message thresholds require review.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onErrorContainer,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            IconButton(
              onPressed: isLocked ? null : onDismiss,
              icon: const Icon(Icons.close),
              tooltip: 'Dismiss alert',
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({
    required this.label,
    required this.value,
    required this.icon,
    this.isWarning = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final bool isWarning;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 20, color: isWarning ? colorScheme.error : colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(child: Text(label)),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isWarning ? colorScheme.error : null,
              ),
        ),
      ],
    );
  }
}
