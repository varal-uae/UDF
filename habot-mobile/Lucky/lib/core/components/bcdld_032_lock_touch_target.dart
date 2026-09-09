// BCDLD-032 — Lock Touch Target & Compliance Action Card.
// Enforces a 48dp minimum interactive footprint, applies opacity 0.38 to non-compliant states, and debounces taps to block double-taps.
import 'package:flutter/material.dart';

/// A reusable Material 3 action card for lock/unlock actions with a strict
/// 48dp touch target, double-tap protection, and adaptive width behavior.
class Bcdld032LockTouchTarget extends StatefulWidget {
  const Bcdld032LockTouchTarget({
    super.key,
    required this.child,
    required this.onTap,
    this.enabled = true,
    this.lockStatus = 'Unknown',
    this.lockedBy,
    this.lockReason,
    this.semanticLabel,
  });

  final Widget child;
  final VoidCallback? onTap;
  final bool enabled;
  final String lockStatus;
  final String? lockedBy;
  final String? lockReason;
  final String? semanticLabel;

  @override
  State<Bcdld032LockTouchTarget> createState() => _Bcdld032LockTouchTargetState();
}

class _Bcdld032LockTouchTargetState extends State<Bcdld032LockTouchTarget> {
  DateTime? _lastTapTime;
  static const Duration _tapDebounce = Duration(milliseconds: 500);

  void _handleTap() {
    if (!widget.enabled) return;
    final now = DateTime.now();
    if (_lastTapTime != null && now.difference(_lastTapTime!) < _tapDebounce) {
      return; // Ignore rapid second tap / double-tap.
    }
    _lastTapTime = now;
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool disabled = !widget.enabled;
    final Color containerColor = disabled
        ? theme.colorScheme.surfaceContainerHighest.withOpacity(0.38)
        : theme.colorScheme.surfaceContainerLow;
    final Color contentColor = disabled
        ? theme.colorScheme.onSurface.withOpacity(0.38)
        : theme.colorScheme.onSurface;

    return Semantics(
      label: widget.semanticLabel ?? 'Lock action: ${widget.lockStatus}',
      enabled: widget.enabled,
      button: true,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool expanded = constraints.maxWidth > 600;
          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: expanded ? 640 : double.infinity,
              ),
              child: Opacity(
                opacity: disabled ? 0.38 : 1.0,
                child: AbsorbPointer(
                  absorbing: disabled,
                  child: Card(
                    elevation: 0,
                    color: containerColor,
                    margin: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      onTap: _handleTap,
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            minWidth: 48,
                            minHeight: 48,
                          ),
                          child: DefaultTextStyle.merge(
                            style: TextStyle(color: contentColor),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.lock_outline,
                                  size: 24,
                                  color: contentColor,
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      widget.child,
                                      if (widget.lockedBy != null ||
                                          widget.lockReason != null) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          widget.lockReason ?? 'Locked by ${widget.lockedBy}',
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: contentColor.withOpacity(0.7),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
