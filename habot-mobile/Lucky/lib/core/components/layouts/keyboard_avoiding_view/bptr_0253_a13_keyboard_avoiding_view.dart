// BPTR-0253-A13 — Keyboard View Inset Adjustment Engine.
// A structural wrapper that animates bottom padding from MediaQuery.viewInsets and resets to zero when the keyboard hides. Includes tap-to-dismiss and FocusTraversalGroup for automated focus shifting.
import 'package:flutter/material.dart';

/// Standard structural wrapper for keyboard avoidance and form focus shifting.
class Bptr0253A13KeyboardAvoidingView extends StatefulWidget {
  const Bptr0253A13KeyboardAvoidingView({
    super.key,
    required this.child,
    this.extraBottomMargin = 0,
    this.animationDuration = const Duration(milliseconds: 200),
    this.enableTapToDismiss = true,
    this.enableSecondaryScrollCorrection = true,
    this.onKeyboardVisibilityChanged,
  });

  final Widget child;
  final double extraBottomMargin;
  final Duration animationDuration;
  final bool enableTapToDismiss;
  final bool enableSecondaryScrollCorrection;
  final ValueChanged<bool>? onKeyboardVisibilityChanged;

  @override
  State<Bptr0253A13KeyboardAvoidingView> createState() =>
      _Bptr0253A13KeyboardAvoidingViewState();
}

class _Bptr0253A13KeyboardAvoidingViewState
    extends State<Bptr0253A13KeyboardAvoidingView> {
  double _bottomInset = 0;
  bool _keyboardVisible = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncInset();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    _syncInset();
  }

  void _syncInset() {
    final viewInsets = MediaQuery.viewInsetsOf(context);
    final visible = viewInsets.bottom > 0;
    final target = visible ? viewInsets.bottom + widget.extraBottomMargin : 0.0;
    if (target != _bottomInset || visible != _keyboardVisible) {
      setState(() {
        _bottomInset = target;
        _keyboardVisible = visible;
      });
      widget.onKeyboardVisibilityChanged?.call(visible);
      if (visible && widget.enableSecondaryScrollCorrection) {
        _runSecondaryScrollCorrection();
      }
    }
  }

  void _runSecondaryScrollCorrection() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final focusedContext = FocusManager.instance.primaryFocus?.context;
      if (focusedContext != null) {
        Scrollable.ensureVisible(
          focusedContext,
          alignment: 0.1,
          duration: widget.animationDuration,
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  void _handleTapOutside() {
    if (widget.enableTapToDismiss) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FocusTraversalGroup(
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _handleTapOutside,
        child: AnimatedPadding(
          duration: widget.animationDuration,
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.only(bottom: _bottomInset),
          child: widget.child,
        ),
      ),
    );
  }
}
