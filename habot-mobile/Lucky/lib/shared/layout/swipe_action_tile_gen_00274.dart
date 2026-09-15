// GEN-00274 — Swipe Action Tile with Fluid Scaling Icons.
// Renders check and flag action icons that scale fluidly based on swipe gesture distance,
// conforming to Material Design 3 guidelines with 48x48dp touch targets and haptic boundaries.

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Swipe direction enum representing user gesture intent.
enum SwipeActionType {
  none,
  check,
  flag,
}

/// Configuration defining layout spacing and thresholds.
class SwipeActionConfiguration {
  const SwipeActionConfiguration({
    this.minItemWidth = 280.0,
    this.interItemSpacing = 12.0,
    this.actionThreshold = 80.0,
    this.maxOvershoot = 140.0,
    this.minTouchTargetSize = 48.0,
  });

  final double minItemWidth;
  final double interItemSpacing;
  final double actionThreshold;
  final double maxOvershoot;
  final double minTouchTargetSize;
}

/// Interactive swipeable tile exposing check and flag action icons that scale
/// fluidly proportional to swipe drag displacement.
class SwipeActionTileGEN00274 extends StatefulWidget {
  const SwipeActionTileGEN00274({
    super.key,
    required this.child,
    this.onChecked,
    this.onFlagged,
    this.config = const SwipeActionConfiguration(),
    this.checkColor,
    this.flagColor,
  });

  final Widget child;
  final VoidCallback? onChecked;
  final VoidCallback? onFlagged;
  final SwipeActionConfiguration config;
  final Color? checkColor;
  final Color? flagColor;

  @override
  State<SwipeActionTileGEN00274> createState() => _SwipeActionTileGEN00274State();
}

class _SwipeActionTileGEN00274State extends State<SwipeActionTileGEN00274>
    with SingleTickerProviderStateMixin {
  late final AnimationController _settleController;
  late Animation<double> _settleAnimation;
  double _dragOffset = 0.0;
  bool _hasCrossedThreshold = false;

  @override
  void initState() {
    super.initState();
    _settleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _settleAnimation = const AlwaysStoppedAnimation(0.0);
  }

  @override
  void dispose() {
    _settleController.dispose();
    super.dispose();
  }

  /// Update drag offset during horizontal touch manipulation.
  void _updateDrag(DragUpdateDetails details) {
    if (_settleController.isAnimating) {
      _settleController.stop();
    }

    setState(() {
      _dragOffset += details.primaryDelta ?? 0.0;
      _dragOffset = _dragOffset.clamp(
        -widget.config.maxOvershoot,
        widget.config.maxOvershoot,
      );
    });

    final double absoluteOffset = _dragOffset.abs();
    if (absoluteOffset >= widget.config.actionThreshold && !_hasCrossedThreshold) {
      _hasCrossedThreshold = true;
      HapticFeedback.mediumImpact();
    } else if (absoluteOffset < widget.config.actionThreshold && _hasCrossedThreshold) {
      _hasCrossedThreshold = false;
      HapticFeedback.selectionClick();
    }
  }

  /// Complete swipe gesture and trigger respective callback or snap back.
  void _completeDrag(DragEndDetails details) {
    final double currentOffset = _dragOffset;
    final double threshold = widget.config.actionThreshold;

    if (currentOffset >= threshold && widget.onChecked != null) {
      HapticFeedback.lightImpact();
      widget.onChecked?.call();
    } else if (currentOffset <= -threshold && widget.onFlagged != null) {
      HapticFeedback.lightImpact();
      widget.onFlagged?.call();
    }

    _resetPosition();
  }

  /// Cancel active drag gesture and animate back to center.
  void _cancelDrag() {
    _resetPosition();
  }

  /// Animate offset back to zero with an elastic easing curve.
  void _resetPosition() {
    _hasCrossedThreshold = false;
    _settleAnimation = Tween<double>(
      begin: _dragOffset,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: _settleController,
        curve: Curves.easeOutCubic,
      ),
    )..addListener(() {
        setState(() {
          _dragOffset = _settleAnimation.value;
        });
      });

    _settleController.forward(from: 0.0);
  }

  /// Calculate dynamic scale factor based on drag distance ratio.
  double _calculateScale(double offset, double threshold) {
    final double ratio = (offset.abs() / threshold).clamp(0.0, 1.3);
    return Curves.easeOutBack.transform(ratio / 1.3) * 1.15;
  }

  /// Calculate dynamic opacity factor based on progress.
  double _calculateOpacity(double offset, double threshold) {
    return (offset.abs() / (threshold * 0.5)).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    final double checkScale = _dragOffset > 0
        ? _calculateScale(_dragOffset, widget.config.actionThreshold)
        : 0.0;
    final double checkOpacity = _dragOffset > 0
        ? _calculateOpacity(_dragOffset, widget.config.actionThreshold)
        : 0.0;

    final double flagScale = _dragOffset < 0
        ? _calculateScale(_dragOffset, widget.config.actionThreshold)
        : 0.0;
    final double flagOpacity = _dragOffset < 0
        ? _calculateOpacity(_dragOffset, widget.config.actionThreshold)
        : 0.0;

    final Color checkBgColor = widget.checkColor ?? colorScheme.primaryContainer;
    final Color checkIconColor = colorScheme.onPrimaryContainer;
    final Color flagBgColor = widget.flagColor ?? colorScheme.errorContainer;
    final Color flagIconColor = colorScheme.onErrorContainer;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: widget.config.interItemSpacing / 2),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: widget.config.minItemWidth,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            // Background Action Layer
            Positioned.fill(
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  return Row(
                    children: <Widget>[
                      // Swipe right -> Check action
                      Expanded(
                        child: Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(left: 20.0),
                          decoration: BoxDecoration(
                            color: checkBgColor,
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          child: Opacity(
                            opacity: checkOpacity,
                            child: Transform.scale(
                              scale: checkScale,
                              alignment: Alignment.centerLeft,
                              child:
                                  _buildActionIcon(Icons.check_circle_rounded, checkIconColor, 'Check action'),
                            ),
                          ),
                        ),
                      ),
                      // Swipe left -> Flag action
                      Expanded(
                        child: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20.0),
                          decoration: BoxDecoration(
                            color: flagBgColor,
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          child: Opacity(
                            opacity: flagOpacity,
                            child: Transform.scale(
                              scale: flagScale,
                              alignment: Alignment.centerRight,
                              child:
                                  _buildActionIcon(Icons.flag_rounded, flagIconColor, 'Flag action'),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // Foreground Content Layer
            Transform.translate(
              offset: Offset(_dragOffset, 0.0),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onHorizontalDragUpdate: _updateDrag,
                onHorizontalDragEnd: _completeDrag,
                onHorizontalDragCancel: _cancelDrag,
                child: Semantics(
                  container: true,
                  swipeHandler: null,
                  child: Material(
                    elevation: _dragOffset.abs() > 4.0 ? 3.0 : 1.0,
                    shadowColor: colorScheme.shadow.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16.0),
                    color: colorScheme.surfaceContainerLow,
                    child: widget.child,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build standard Material 3 compliant action icon with 48x48dp touch target constraint.
  Widget _buildActionIcon(IconData icon, Color color, String semanticsLabel) {
    return Semantics(
      label: semanticsLabel,
      button: true,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: widget.config.minTouchTargetSize,
          minHeight: widget.config.minTouchTargetSize,
        ),
        child: Center(
          child: Icon(
            icon,
            color: color,
            size: 28.0,
          ),
        ),
      ),
    );
  }
}
