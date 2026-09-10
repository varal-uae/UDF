// DPNDL-011-A05 — Global Top Application Bar (Master Header App Bar).
// Implements a Material 3 top app header with a fixed 64dp toolbar height,
// horizontal Row alignment rules, and phantom 48dp touch targets around vector assets.

import 'package:flutter/material.dart';

class GlobalTopApplicationBar extends StatelessWidget implements PreferredSizeWidget {
  const GlobalTopApplicationBar({
    super.key,
    this.leading,
    required this.title,
    this.actions = const <Widget>[],
    this.toolbarHeight = 64.0,
    this.backgroundColor,
    this.foregroundColor,
  });

  final Widget? leading;
  final Widget title;
  final List<Widget> actions;
  final double toolbarHeight;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Size get preferredSize => Size.fromHeight(toolbarHeight);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color effectiveBackground = backgroundColor ?? theme.colorScheme.surface;
    final Color effectiveForeground = foregroundColor ?? theme.colorScheme.onSurface;

    return AppBar(
      toolbarHeight: toolbarHeight,
      backgroundColor: effectiveBackground,
      foregroundColor: effectiveForeground,
      elevation: 0.0,
      scrolledUnderElevation: 0.0,
      centerTitle: false,
      titleSpacing: 0.0,
      leading: leading == null ? null : _PhantomTarget(child: leading!),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: DefaultTextStyle(
              style: theme.textTheme.titleLarge?.copyWith(
                    color: effectiveForeground,
                    fontWeight: FontWeight.w600,
                  ) ??
                  TextStyle(color: effectiveForeground),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              child: title,
            ),
          ),
        ],
      ),
      actions: actions
          .map((Widget action) => _PhantomTarget(child: action))
          .toList(growable: false),
    );
  }
}

class _PhantomTarget extends StatelessWidget {
  const _PhantomTarget({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: 48.0,
          minHeight: 48.0,
        ),
        child: Center(child: child),
      ),
    );
  }
}
