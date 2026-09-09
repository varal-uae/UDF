// BPTR-0206-A07 — Build High-Performance Gesture-Driven Swipe Actions for Lists.
// Reusable Material 3 list tile that reveals left/right contextual actions behind a translated foreground.
// Includes 40% commit threshold, fade-out foreground, GPU-friendly Transform.translate, and 3-second undo snackbar.

import 'package:flutter/material.dart';

/// A single swipe-revealed action inside a [GestureDrivenSwipeActionTile].
class SwipeAction {
  const SwipeAction({
    required this.label,
    required this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.semanticLabel,
  });

  final String label;
  final IconData icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final String? semanticLabel;
}

enum SwipeSide { left, right }

/// High-performance, reusable swipe-action wrapper for list or tabular rows.
class GestureDrivenSwipeActionTile extends StatefulWidget {
  const GestureDrivenSwipeActionTile({
    super.key,
    required this.child,
    this.leftActions = const [],
    this.rightActions = const [],
    this.commitThreshold = 0.4,
    this.undoDuration = const Duration(seconds: 3),
    this.onActionTriggered,
    this.onUndo,
    this.onGestureThresholdReached,
  }) : assert(commitThreshold > 0 && commitThreshold <= 1);

  final Widget child;
  final List<SwipeAction> leftActions;
  final List<SwipeAction> rightActions;
  final double commitThreshold;
  final Duration undoDuration;

  /// Called when a swipe threshold commits a primary action.
  final void Function(SwipeAction action, SwipeSide side)? onActionTriggered;

  /// Called when the user taps Undo in the snackbar.
  final void Function(SwipeAction action, SwipeSide side)? onUndo;

  /// Fired exactly when a drag crosses the configured threshold.
  final void Function(SwipeSide side)? onGestureThresholdReached;

  @override
  State<GestureDrivenSwipeActionTile> createState() =>
      _GestureDrivenSwipeActionTileState();
}

class _GestureDrivenSwipeActionTileState
    extends State<GestureDrivenSwipeActionTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  double _itemWidth = 0;
  double _currentOffset = 0;
  double _animationStart = 0;
  double _animationEnd = 0;

  SwipeAction? _pendingAction;
  SwipeSide? _pendingSide;
  bool _isCommitting = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    )
      ..addListener(() {
        setState(() {
          _currentOffset =
              _animationStart + (_animationEnd - _animationStart) * _controller.value;
        });
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed && _isCommitting) {
          _isCommitting = false;
          _commitPrimaryAction();
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleDragStart(DragStartDetails details) {
    if (_controller.isAnimating) {
      _controller.stop();
    }
    _animationStart = _currentOffset;
    _animationEnd = _currentOffset;
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    setState(() {
      _currentOffset += details.delta.dx;
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    final threshold = _itemWidth * widget.commitThreshold;
    final commitOffset = threshold;

    if (_currentOffset > threshold && widget.leftActions.isNotEmpty) {
      _pendingAction = widget.leftActions.first;
      _pendingSide = SwipeSide.left;
      _isCommitting = true;
      widget.onGestureThresholdReached?.call(SwipeSide.left);
      _animateTo(commitOffset);
    } else if (_currentOffset < -threshold && widget.rightActions.isNotEmpty) {
      _pendingAction = widget.rightActions.first;
      _pendingSide = SwipeSide.right;
      _isCommitting = true;
      widget.onGestureThresholdReached?.call(SwipeSide.right);
      _animateTo(-commitOffset);
    } else {
      _animateTo(0);
    }
  }

  void _animateTo(double target) {
    _animationStart = _currentOffset;
    _animationEnd = target;
    _controller.forward(from: 0);
  }

  void _commitPrimaryAction() {
    final action = _pendingAction;
    final side = _pendingSide;
    _pendingAction = null;
    _pendingSide = null;

    if (action == null || side == null) {
      _animateTo(0);
      return;
    }

    widget.onActionTriggered?.call(action, side);
    _showUndoSnackbar(action, side);
    _animateTo(0);
  }

  void _showUndoSnackbar(SwipeAction action, SwipeSide side) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text('${action.label} triggered'),
        duration: widget.undoDuration,
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            widget.onUndo?.call(action, side);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _itemWidth = constraints.maxWidth;

        final effectiveWidth = _itemWidth * widget.commitThreshold;
        final opacity = effectiveWidth <= 0
            ? 1.0
            : (1 - (_currentOffset.abs() / effectiveWidth))
                .clamp(0.0, 1.0)
                .toDouble();

        return GestureDetector(
          onHorizontalDragStart: _handleDragStart,
          onHorizontalDragUpdate: _handleDragUpdate,
          onHorizontalDragEnd: _handleDragEnd,
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              if (widget.leftActions.isNotEmpty)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: effectiveWidth,
                  child: _ActionZone(
                    action: widget.leftActions.first,
                    side: SwipeSide.left,
                  ),
                ),
              if (widget.rightActions.isNotEmpty)
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  width: effectiveWidth,
                  child: _ActionZone(
                    action: widget.rightActions.first,
                    side: SwipeSide.right,
                  ),
                ),
              Transform.translate(
                offset: Offset(_currentOffset, 0),
                child: Opacity(
                  opacity: opacity,
                  child: widget.child,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ActionZone extends StatelessWidget {
  const _ActionZone({
    required this.action,
    required this.side,
  });

  final SwipeAction action;
  final SwipeSide side;

  @override
  Widget build(BuildContext context) {
    final background = action.backgroundColor ??
        Theme.of(context).colorScheme.errorContainer;
    final foreground = action.foregroundColor ??
        Theme.of(context).colorScheme.onErrorContainer;

    return Container(
      color: background,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      alignment: side == SwipeSide.left
          ? Alignment.centerLeft
          : Alignment.centerRight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (side == SwipeSide.left) ...[
            Icon(action.icon, color: foreground, semanticLabel: action.semanticLabel),
            const SizedBox(width: 8),
            Text(
              action.label,
              style: TextStyle(color: foreground, fontWeight: FontWeight.w600),
            ),
          ] else ...[
            Text(
              action.label,
              style: TextStyle(color: foreground, fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 8),
            Icon(action.icon, color: foreground, semanticLabel: action.semanticLabel),
          ],
        ],
      ),
    );
  }
}
