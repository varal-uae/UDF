// BPTR-0206-A15 — Gesture-driven swipe action list tile with spring-back, undo, and 40% width commit threshold.
// Implements Material swipe mechanics using Transform.translate, hidden contextual action backgrounds, threshold callbacks, and a 3-second undo snackbar.

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

/// A reusable swipe-to-action wrapper for list items.
class Bptr0206A15SwipeActionListTile extends StatefulWidget {
  const Bptr0206A15SwipeActionListTile({
    super.key,
    required this.child,
    this.rightAction,
    this.leftAction,
    this.thresholdRatio = 0.4,
    this.undoDuration = const Duration(seconds: 3),
    this.onActionTriggered,
    this.onUndo,
    this.onThresholdReached,
  }) : assert(thresholdRatio > 0 && thresholdRatio < 1);

  final Widget child;
  final SwipeAction? rightAction;
  final SwipeAction? leftAction;
  final double thresholdRatio;
  final Duration undoDuration;
  final void Function(SwipeAction action, SwipeDirection direction)? onActionTriggered;
  final void Function(SwipeAction action, SwipeDirection direction)? onUndo;
  final void Function(SwipeAction action, SwipeDirection direction)? onThresholdReached;

  @override
  State<Bptr0206A15SwipeActionListTile> createState() =>
      _Bptr0206A15SwipeActionListTileState();
}

enum SwipeDirection { left, right }

class SwipeAction {
  const SwipeAction({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    this.foregroundColor = Colors.white,
  });

  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;
}

class _Bptr0206A15SwipeActionListTileState
    extends State<Bptr0206A15SwipeActionListTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _rightThresholdReached = false;
  bool _leftThresholdReached = false;
  bool _committed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
      lowerBound: -1,
      upperBound: 1,
      value: 0,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double get _threshold => widget.thresholdRatio;

  void _handleDragUpdate(DragUpdateDetails details, double width) {
    if (_committed || width == 0) return;
    final delta = details.delta.dx / width;
    final next = (_controller.value + delta).clamp(-1.0, 1.0);
    _controller.value = next;
    _checkThresholdCallbacks(next);
  }

  void _checkThresholdCallbacks(double value) {
    if (widget.rightAction != null &&
        value <= -_threshold &&
        !_rightThresholdReached) {
      _rightThresholdReached = true;
      widget.onThresholdReached?.call(widget.rightAction!, SwipeDirection.left);
    }
    if (widget.leftAction != null &&
        value >= _threshold &&
        !_leftThresholdReached) {
      _leftThresholdReached = true;
      widget.onThresholdReached?.call(widget.leftAction!, SwipeDirection.right);
    }
  }

  void _handleDragEnd(DragEndDetails details, double width) {
    if (_committed) return;
    final value = _controller.value;
    if (widget.rightAction != null && value <= -_threshold) {
      _commit(widget.rightAction!, SwipeDirection.left, target: -1);
    } else if (widget.leftAction != null && value >= _threshold) {
      _commit(widget.leftAction!, SwipeDirection.right, target: 1);
    } else {
      _springBack();
    }
  }

  void _commit(SwipeAction action, SwipeDirection direction,
      {required double target}) {
    _committed = true;
    _animateTo(target, spring: true).then((_) {
      if (!mounted) return;
      widget.onActionTriggered?.call(action, direction);
      _showUndoSnackBar(action, direction);
    });
  }

  void _springBack() {
    _animateTo(0, spring: true);
  }

  Future<void> _animateTo(double target, {bool spring = false}) {
    if (spring) {
      final simulation = SpringSimulation(
        const SpringDescription(
          mass: 0.8,
          stiffness: 180,
          damping: 20,
        ),
        _controller.value,
        target,
        _controller.velocity,
      );
      return _controller.animateWith(simulation);
    }
    return _controller.animateTo(target, curve: Curves.easeOutCubic);
  }

  void _showUndoSnackBar(SwipeAction action, SwipeDirection direction) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text('${action.label} performed'),
        duration: widget.undoDuration,
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () {
            _committed = false;
            _animateTo(0, spring: true);
            widget.onUndo?.call(action, direction);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return RepaintBoundary(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragUpdate: (details) => _handleDragUpdate(details, width),
            onHorizontalDragEnd: (details) => _handleDragEnd(details, width),
            onHorizontalDragCancel: _springBack,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final value = _controller.value;
                final offset = width * value;
                final fadeOpacity =
                    (1 - value.abs() * 1.4).clamp(0.0, 1.0);
                return Stack(
                  clipBehavior: Clip.hardEdge,
                  children: [
                    if (widget.leftAction != null && value > 0)
                      Positioned.fill(
                        child: _ActionBackground(
                          action: widget.leftAction!,
                          align: Alignment.centerLeft,
                        ),
                      ),
                    if (widget.rightAction != null && value < 0)
                      Positioned.fill(
                        child: _ActionBackground(
                          action: widget.rightAction!,
                          align: Alignment.centerRight,
                        ),
                      ),
                    Transform.translate(
                      offset: Offset(offset, 0),
                      child: Opacity(
                        opacity: fadeOpacity,
                        child: widget.child,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _ActionBackground extends StatelessWidget {
  const _ActionBackground({required this.action, required this.align});

  final SwipeAction action;
  final Alignment align;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: action.backgroundColor,
      alignment: align,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(action.icon, color: action.foregroundColor),
          const SizedBox(width: 8),
          Text(
            action.label,
            style: TextStyle(
              color: action.foregroundColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
