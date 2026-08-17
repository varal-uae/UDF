// TSIP-003 — Loading Button with dynamic service-tracking context.
// Features:
//   - Instant touch feedback (< 50ms) using visual scale/shrink + haptics.
//   - Physical double-tap protection (auto-disabled state on loading).
//   - Dynamic text label updates reflecting the backend/service status (e.g. "Connecting", "Authenticating").
//   - Subtle, smooth loading graphic (circular progress) that scales with the text style.
//   - Explicit icon indicators supporting clear visual cues.
//   - Spacing margins conforming to the strict >= 8dp design system guidelines.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Represents the current operational tracking context for the button's action.
class ServiceTrackingContext {
  const ServiceTrackingContext({
    required this.stateLabel,
    this.icon,
    this.isError = false,
  });

  /// The dynamic label corresponding to the current step (e.g., 'Connecting...', 'Authorizing...').
  final String stateLabel;

  /// Optional icon matching the current action state.
  final IconData? icon;

  /// Whether this state indicates an error.
  final bool isError;
}

/// A premium, Material 3 compliant loading button.
///
/// Provides visual feedback in < 50ms (instant scale down + haptic tap)
/// and displays subtle loading graphics while dynamically updating text
/// based on the underlying [serviceContext].
class LoadingButton extends StatefulWidget {
  const LoadingButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.serviceContext,
    this.margin = const EdgeInsets.symmetric(vertical: 8.0),
    this.hapticFeedback = true,
  });

  /// The resting label of the button.
  final String label;

  /// Callback when pressed. Automatically locked while [isLoading] is true.
  final VoidCallback? onPressed;

  /// Resting icon indicator.
  final IconData? icon;

  /// Triggers the active loading/progress state.
  final bool isLoading;

  /// The active service tracking details (label/icon) shown during loading state.
  final ServiceTrackingContext? serviceContext;

  /// Enforces spacing margins — default matches the >= 8dp visual alignment rule.
  final EdgeInsetsGeometry margin;

  /// If true, triggers a light haptic impact on tap for instantaneous sensory feedback.
  final bool hapticFeedback;

  @override
  State<LoadingButton> createState() => _LoadingButtonState();
}

class _LoadingButtonState extends State<LoadingButton> with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      _pressController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    _pressController.reverse();
  }

  void _handleTapCancel() {
    _pressController.reverse();
  }

  void _onTap() {
    if (widget.onPressed != null && !widget.isLoading) {
      if (widget.hapticFeedback) {
        HapticFeedback.lightImpact();
      }
      widget.onPressed!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    // Resolve dynamic label based on service tracking context
    final String activeLabel = widget.isLoading
        ? (widget.serviceContext?.stateLabel ?? 'Processing...')
        : widget.label;

    // Resolve icon matching the action/status context
    final IconData? activeIcon = widget.isLoading
        ? widget.serviceContext?.icon
        : widget.icon;

    final isButtonEnabled = widget.onPressed != null && !widget.isLoading;

    // Determine colors matching the error state if tracking state indicates a failure
    final isErrorState = widget.isLoading && (widget.serviceContext?.isError ?? false);
    final baseBgColor = isErrorState
        ? cs.errorContainer
        : isButtonEnabled
            ? cs.primary
            : cs.onSurface.withOpacity(0.12);
    final baseTextColor = isErrorState
        ? cs.onErrorContainer
        : isButtonEnabled
            ? cs.onPrimary
            : cs.onSurface.withOpacity(0.38);

    return Padding(
      padding: widget.margin,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: GestureDetector(
          onTapDown: _handleTapDown,
          onTapUp: _handleTapUp,
          onTapCancel: _handleTapCancel,
          onTap: isButtonEnabled ? _onTap : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            height: 48, // Enforces the standard 48dp touch target
            decoration: BoxDecoration(
              color: baseBgColor,
              borderRadius: BorderRadius.circular(100), // M3 pill shape
              boxShadow: isButtonEnabled
                  ? [
                      BoxShadow(
                        color: cs.shadow.withOpacity(0.15),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      )
                    ]
                  : null,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Subtle ripple / touch highlight
                  if (isButtonEnabled)
                    Positioned.fill(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _onTap,
                          splashColor: cs.onPrimary.withOpacity(0.08),
                          highlightColor: cs.onPrimary.withOpacity(0.04),
                        ),
                      ),
                    ),
                  
                  // Central Content Row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: ScaleTransition(scale: animation, child: child),
                        );
                      },
                      child: Row(
                        key: ValueKey<String>('${widget.isLoading}_$activeLabel'),
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 1. Loading Graphics (subtle CircularProgressIndicator)
                          if (widget.isLoading) ...[
                            SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: baseTextColor,
                              ),
                            ),
                            const SizedBox(width: 10),
                          ]
                          // 2. Action Icons (if provided and not loading)
                          else if (activeIcon != null) ...[
                            Icon(
                              activeIcon,
                              size: 20,
                              color: baseTextColor,
                            ),
                            const SizedBox(width: 8),
                          ],
                          
                          // 3. Dynamic Text Label
                          Text(
                            activeLabel,
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: baseTextColor,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.1,
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
        ),
      ),
    );
  }
}
