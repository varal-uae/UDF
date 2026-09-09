// BPTR-0128-A14 — Atomic Interactive Byt Micro-Interaction Boundary Button.
// Enforces minimum 48x48 touch targets with 8px external separation and dynamic internal padding while supporting Material ripple feedback.
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

/// A reusable interactive button that enforces Flutter Material touch-target
/// boundaries and logs console warnings when the rendered tap target falls
/// below the 48x48px threshold.
class Bptr0128A14InteractiveButton extends StatefulWidget {
  const Bptr0128A14InteractiveButton({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.backgroundColor,
    this.foregroundColor,
    this.overlayColor,
    this.borderRadius,
    this.internalPadding = const EdgeInsets.all(8),
    this.outerSpacing = const EdgeInsets.all(4),
    this.minimumSize = const Size(48, 48),
    this.enableHapticFeedback = true,
    this.semanticLabel,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? overlayColor;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry internalPadding;
  final EdgeInsetsGeometry outerSpacing;
  final Size minimumSize;
  final bool enableHapticFeedback;
  final String? semanticLabel;

  @override
  State<Bptr0128A14InteractiveButton> createState() =>
      _Bptr0128A14InteractiveButtonState();
}

class _Bptr0128A14InteractiveButtonState
    extends State<Bptr0128A14InteractiveButton> {
  final GlobalKey _sizeKey = GlobalKey();
  bool _sizeCheckScheduled = false;

  void _scheduleSizeCheck() {
    if (_sizeCheckScheduled) return;
    _sizeCheckScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sizeCheckScheduled = false;
      final renderBox =
          _sizeKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox == null) return;
      final size = renderBox.size;
      if (size.width < widget.minimumSize.width ||
          size.height < widget.minimumSize.height) {
        debugPrint(
          'BPTR-0128-A14 WARNING: Interactive tap target $size is below ${widget.minimumSize}.',
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _scheduleSizeCheck();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final background =
        widget.backgroundColor ?? colorScheme.primary;
    final foreground =
        widget.foregroundColor ?? colorScheme.onPrimary;
    final overlay =
        widget.overlayColor ?? colorScheme.primary.withOpacity(0.08);
    final radius = widget.borderRadius ?? BorderRadius.circular(12);

    return Padding(
      padding: widget.outerSpacing,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: widget.minimumSize.width,
          minHeight: widget.minimumSize.height,
        ),
        child: Material(
          key: _sizeKey,
          color: background,
          borderRadius: radius,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: widget.onTap,
            onLongPress: widget.onLongPress,
            enableFeedback: widget.enableHapticFeedback,
            overlayColor: WidgetStatePropertyAll<Color>(overlay),
            child: Semantics(
              label: widget.semanticLabel,
              button: true,
              child: Padding(
                padding: widget.internalPadding,
                child: Center(
                  widthFactor: 1,
                  heightFactor: 1,
                  child: DefaultTextStyle.merge(
                    style: TextStyle(color: foreground),
                    child: widget.child,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
