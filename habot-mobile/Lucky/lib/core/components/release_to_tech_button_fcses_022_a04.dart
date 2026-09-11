// FCSES-022-A04 — Lock Release to Tech button fail-closed with Material 3 disabled states, tooltip, and grayed-out opacity.
// Provides a fail-closed release action: the button is disabled by default, exposes a reason on long-press/touch, and uses theme-driven disabled tokens.

import 'package:flutter/material.dart';

class ReleaseToTechButton extends StatelessWidget {
  const ReleaseToTechButton({
    super.key,
    this.isLocked = true,
    this.onPressed,
    this.lockedReason = 'Release to Tech is locked until all prerequisite checks pass.',
    this.label = 'Release to Tech',
  });

  final bool isLocked;
  final VoidCallback? onPressed;
  final String lockedReason;
  final String label;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bool canRelease = !isLocked && onPressed != null;
    final String? tooltipMessage = isLocked
        ? lockedReason
        : (onPressed == null ? 'Release action is currently unavailable.' : null);

    final Widget button = AnimatedOpacity(
      opacity: isLocked ? 0.6 : 1.0,
      duration: const Duration(milliseconds: 150),
      child: FilledButton.icon(
        onPressed: canRelease ? onPressed : null,
        icon: Icon(isLocked ? Icons.lock_outline : Icons.lock_open),
        label: Text(label),
        style: FilledButton.styleFrom(
          disabledBackgroundColor: colorScheme.onSurface.withOpacity(0.12),
          disabledForegroundColor: colorScheme.onSurface.withOpacity(0.38),
          minimumSize: const Size(160, 48),
        ),
      ),
    );

    return Semantics(
      button: true,
      enabled: canRelease,
      label: label,
      hint: isLocked ? lockedReason : null,
      child: tooltipMessage == null
          ? button
          : Tooltip(
              message: tooltipMessage,
              triggerMode: TooltipTriggerMode.longPress,
              showDuration: const Duration(seconds: 4),
              child: button,
            ),
    );
  }
}
