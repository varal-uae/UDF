// GEN-03904 — Right Button Touch Listener Widget.
// Attaches a touch event listener to the right button updating selectedValue to false, using M3 Elevated Card and 48x48dp touch targets.

import 'package:flutter/material.dart';

/// A reusable widget that provides a right-aligned button with a touch
/// event listener. When tapped, it updates [selectedValue] to false via
/// the provided [onSelectedValueChanged] callback.
/// Implements Material 3 standards with 48x48dp minimum touch targets.
class RightButtonTouchListenerGen03904 extends StatefulWidget {
  const RightButtonTouchListenerGen03904({
    super.key,
    required this.selectedValue,
    required this.onSelectedValueChanged,
    this.label = 'Right Action',
  });

  final bool selectedValue;
  final ValueChanged<bool> onSelectedValueChanged;
  final String label;

  @override
  State<RightButtonTouchListenerGen03904> createState() => _RightButtonTouchListenerGen03904State();
}

class _RightButtonTouchListenerGen03904State extends State<RightButtonTouchListenerGen03904> {
  late bool _localSelectedValue;

  @override
  void initState() {
    super.initState();
    _localSelectedValue = widget.selectedValue;
  }

  @override
  void didUpdateWidget(covariant RightButtonTouchListenerGen03904 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedValue != widget.selectedValue) {
      setState(() {
        _localSelectedValue = widget.selectedValue;
      });
    }
  }

  void _handleTouchDown(TapDownDetails details) {
    // Touch event listener attached: updating selectedValue to false.
    setState(() {
      _localSelectedValue = false;
    });
    widget.onSelectedValueChanged(false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTapDown: _handleTouchDown,
        behavior: HitTestBehavior.opaque,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: 48.0,
            minHeight: 48.0,
          ),
          child: Card(
            elevation: 3.0, // M3 Elevated Cards Level 2 (3dp)
            color: _localSelectedValue
                ? colorScheme.primaryContainer
                : colorScheme.surfaceContainerHighest,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _localSelectedValue ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: _localSelectedValue
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onSurfaceVariant,
                    size: 24.0,
                  ),
                  const SizedBox(width: 8.0),
                  Text(
                    widget.label,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: _localSelectedValue
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onSurfaceVariant,
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
