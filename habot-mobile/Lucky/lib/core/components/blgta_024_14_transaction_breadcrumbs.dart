// BLGTA-024-14 — Transaction Location Breadcrumb Rail & High-Priority In-App Alert.
// Visualizes the single previous state location for each output field using Material 3 breadcrumbs with priority color tokens; supports an instant overlay alert for MTO devices.
import 'dart:async';
import 'package:flutter/material.dart';

class TransactionStep {
  final String label;
  final BreadcrumbPriority priority;
  final IconData icon;
  const TransactionStep({required this.label, required this.priority, this.icon = Icons.circle_outlined});
}

enum BreadcrumbPriority { low, medium, high, critical }

class TransactionBreadcrumbRail extends StatelessWidget {
  final List<TransactionStep> steps;
  final int currentStepIndex;
  final ValueChanged<int>? onStepTap;
  const TransactionBreadcrumbRail({super.key, required this.steps, required this.currentStepIndex, this.onStepTap});

  Color _priorityColor(BuildContext context, BreadcrumbPriority priority) {
    final scheme = Theme.of(context).colorScheme;
    switch (priority) {
      case BreadcrumbPriority.low:
        return scheme.tertiary;
      case BreadcrumbPriority.medium:
        return scheme.secondary;
      case BreadcrumbPriority.high:
        return scheme.primary;
      case BreadcrumbPriority.critical:
        return scheme.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (steps.isEmpty) return const SizedBox.shrink();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (int i = 0; i < steps.length; i++) ...[
            if (i > 0) Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Icon(Icons.chevron_right, size: 18, color: Theme.of(context).colorScheme.outline),
            ),
            _BreadcrumbItem(
              step: steps[i],
              color: _priorityColor(context, steps[i].priority),
              isCurrent: i == currentStepIndex,
              onTap: onStepTap == null ? null : () => onStepTap!(i),
            ),
          ],
        ],
      ),
    );
  }
}

class _BreadcrumbItem extends StatelessWidget {
  final TransactionStep step;
  final Color color;
  final bool isCurrent;
  final VoidCallback? onTap;
  const _BreadcrumbItem({required this.step, required this.color, required this.isCurrent, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isCurrent ? color.withOpacity(0.15) : Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(step.icon, size: 18, color: color),
              const SizedBox(width: 6),
              Text(
                step.label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: isCurrent ? color : Theme.of(context).colorScheme.onSurface,
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void showHighPriorityAlert(BuildContext context, {
  required String title,
  required String message,
  BreadcrumbPriority priority = BreadcrumbPriority.high,
  Duration duration = const Duration(seconds: 5),
}) {
  final overlay = Overlay.of(context);
  final color = _priorityColorFromPriority(context, priority);
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _HighPriorityAlertOverlay(
      title: title,
      message: message,
      color: color,
      onDismiss: () => entry.remove(),
    ),
  );
  overlay.insert(entry);
  Timer(duration, entry.remove);
}

Color _priorityColorFromPriority(BuildContext context, BreadcrumbPriority priority) {
  final scheme = Theme.of(context).colorScheme;
  switch (priority) {
    case BreadcrumbPriority.low:
      return scheme.tertiary;
    case BreadcrumbPriority.medium:
      return scheme.secondary;
    case BreadcrumbPriority.high:
      return scheme.primary;
    case BreadcrumbPriority.critical:
      return scheme.error;
  }
}

class _HighPriorityAlertOverlay extends StatelessWidget {
  final String title;
  final String message;
  final Color color;
  final VoidCallback onDismiss;
  const _HighPriorityAlertOverlay({required this.title, required this.message, required this.color, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 8,
      left: 16,
      right: 16,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(12),
        color: color,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              const Icon(Icons.notifications_active, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(message, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white)),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: onDismiss,
              ),
            ],
          ),
        ),
      ),
    );
  }
}