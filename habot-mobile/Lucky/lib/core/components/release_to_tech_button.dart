import 'package:flutter/material.dart';

import '../workflow/release_gate.dart';

// FCSES-022-A03 — Lock "Release to Tech" Button Fail-Closed.
//
// Flutter equivalent of MUI Button disabled={!ready}:
//   - onPressed: null until ReleaseGateRegistry.isReleaseReady
//   - M3 disabled styling — grayed out, lowered opacity
//   - Long-press tooltip explains why the button is locked
//   - Fail-closed: tap does nothing when gates are unmet

/// Fail-closed "Release to Tech" control — physically disabled until all gates pass.
class ReleaseToTechButton extends StatelessWidget {
  const ReleaseToTechButton({
    super.key,
    required this.registry,
    required this.onRelease,
    this.userId = 'unknown',
    this.isLoading = false,
    this.loadingLabel = 'Submitting',
    this.fullWidth = true,
  });

  final ReleaseGateRegistry registry;
  final VoidCallback onRelease;
  final String userId;
  final bool isLoading;
  final String loadingLabel;
  final bool fullWidth;

  static const label = 'Release to Tech';

  void _handleRelease() {
    if (!registry.isReleaseReady || isLoading) return;

    ReleaseExecutionLog(
      executionStatus: 'ACTIONED',
      stepOutcome:     'RELEASED_TO_TECH',
      userId:          userId,
    );

    onRelease();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: registry,
      builder: (context, _) {
        final ready   = registry.isReleaseReady && !isLoading;
        final reason  = registry.allBlockReasons;
        final theme   = Theme.of(context);

        final button = FilledButton.icon(
          onPressed: ready ? _handleRelease : null,
          icon: isLoading
              ? SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: theme.colorScheme.onPrimary,
                  ),
                )
              : const Icon(Icons.rocket_launch_outlined, size: 20),
          label: Text(isLoading ? loadingLabel : label),
          style: FilledButton.styleFrom(
            minimumSize: Size(fullWidth ? double.infinity : 0, 48),
            disabledBackgroundColor:
                theme.colorScheme.onSurface.withOpacity(0.12),
            disabledForegroundColor:
                theme.colorScheme.onSurface.withOpacity(0.38),
          ),
        );

        final sized = fullWidth
            ? SizedBox(width: double.infinity, child: button)
            : button;

        if (ready || reason.isEmpty) return sized;

        // Fail-closed + tooltip on long-press when disabled
        return Tooltip(
          message: reason,
          triggerMode: TooltipTriggerMode.longPress,
          preferBelow: true,
          waitDuration: const Duration(milliseconds: 400),
          child: Semantics(
            button: true,
            enabled: false,
            child: _DisabledTapShield(
              child: Opacity(
                opacity: 0.55,
                child: _NonInteractiveButtonShell(child: sized),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Absorbs taps on the disabled shell while allowing long-press for [Tooltip].
class _DisabledTapShield extends StatelessWidget {
  const _DisabledTapShield({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        // Fail-closed — no action on tap
      },
      child: child,
    );
  }
}

/// Visual shell matching disabled button without enabling [FilledButton] presses.
class _NonInteractiveButtonShell extends StatelessWidget {
  const _NonInteractiveButtonShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(child: child);
  }
}
