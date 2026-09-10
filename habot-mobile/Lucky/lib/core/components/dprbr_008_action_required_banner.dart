// DPRBR-008 — Mobile dunning action-required banner and double-tap detector.
// Provides a pinned, non-dismissible Material 3 error banner for critical billing updates
// and a reusable widget that encapsulates double-tap detection for mobile recovery flows.

import 'package:flutter/material.dart';

class Dprbr008ActionRequiredBanner extends StatelessWidget {
  const Dprbr008ActionRequiredBanner({
    super.key,
    required this.message,
    this.actionLabel,
    this.onActionPressed,
    this.pinned = true,
  });

  final String message;
  final String? actionLabel;
  final VoidCallback? onActionPressed;
  final bool pinned;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final banner = Material(
      color: colorScheme.errorContainer,
      elevation: 0,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.error_outline, color: colorScheme.onErrorContainer),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onErrorContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (actionLabel != null && onActionPressed != null) ...[
                const SizedBox(width: 8),
                TextButton(
                  onPressed: onActionPressed,
                  style: TextButton.styleFrom(
                    foregroundColor: colorScheme.onErrorContainer,
                    textStyle: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  child: Text(actionLabel!),
                ),
              ],
            ],
          ),
        ),
      ),
    );

    if (!pinned) return banner;
    return Align(
      alignment: Alignment.topCenter,
      child: banner,
    );
  }
}

class Dprbr008DoubleTapDetector extends StatefulWidget {
  const Dprbr008DoubleTapDetector({
    super.key,
    required this.child,
    required this.onDoubleTap,
    this.interval = const Duration(milliseconds: 300),
  });

  final Widget child;
  final VoidCallback onDoubleTap;
  final Duration interval;

  @override
  State<Dprbr008DoubleTapDetector> createState() => _Dprbr008DoubleTapDetectorState();
}

class _Dprbr008DoubleTapDetectorState extends State<Dprbr008DoubleTapDetector> {
  DateTime? _lastTap;

  void _handleTap() {
    final now = DateTime.now();
    final lastTap = _lastTap;
    if (lastTap != null && now.difference(lastTap) <= widget.interval) {
      _lastTap = null;
      widget.onDoubleTap();
      return;
    }
    _lastTap = now;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _handleTap,
      child: widget.child,
    );
  }
}
