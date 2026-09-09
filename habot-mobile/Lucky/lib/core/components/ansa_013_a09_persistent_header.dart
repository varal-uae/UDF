// ANSA-013-A09 — Persistent Header Layout System Implementation.
// Reusable Material 3 global header with 56dp compact height, blur-translucent background,
// right-aligned shortcut actions, bottom divider, smooth 200-300ms state transitions,
// scroll-driven elevation level 1, and permission-gated contextual actions.

import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Ansa013A09PersistentHeader extends StatelessWidget implements PreferredSizeWidget {
  const Ansa013A09PersistentHeader({
    super.key,
    this.title,
    this.actions = const <Widget>[],
    this.showContextualActions = true,
    this.elevation = 0,
    this.backgroundColor,
    this.foregroundColor,
  });

  final Widget? title;
  final List<Widget> actions;
  final bool showContextualActions;
  final double elevation;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final visibleActions = showContextualActions ? actions : const <Widget>[];
    final effectiveBackgroundColor =
        backgroundColor ?? theme.colorScheme.surface.withOpacity(0.72);
    final effectiveForegroundColor =
        foregroundColor ?? theme.colorScheme.onSurface;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOutCubic,
      height: preferredSize.height,
      child: Material(
        color: Colors.transparent,
        elevation: elevation,
        shadowColor: theme.colorScheme.shadow,
        clipBehavior: Clip.antiAlias,
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOutCubic,
              decoration: BoxDecoration(
                color: effectiveBackgroundColor,
                border: Border(
                  bottom: BorderSide(
                    color: theme.colorScheme.outlineVariant.withOpacity(0.4),
                    width: 0.5,
                  ),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: DefaultTextStyle(
                    style: theme.textTheme.titleMedium!.copyWith(
                      color: effectiveForegroundColor,
                      fontWeight: FontWeight.w600,
                    ),
                    child: Row(
                      children: <Widget>[
                        if (title != null) Expanded(child: title!),
                        if (visibleActions.isNotEmpty) ...visibleActions,
                      ],
                    ),
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

class Ansa013A09HeaderElevationController extends ChangeNotifier {
  double _elevation = 0;
  double get elevation => _elevation;

  void onScroll(ScrollNotification notification) {
    final next = notification.metrics.axis == Axis.vertical &&
            notification.metrics.pixels > 0
        ? 1.0
        : 0.0;
    if (next != _elevation) {
      _elevation = next;
      notifyListeners();
    }
  }
}