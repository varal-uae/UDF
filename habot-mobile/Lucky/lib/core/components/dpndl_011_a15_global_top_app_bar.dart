// DPNDL-011-A15 — Global Top Application Bar (Master Header App Bar Component).
// Provides a static, Material 3 compliant top app bar with a strict 64dp toolbar height,
// accessible leading/action targets, and reusable title configurations for root templates.

import 'package:flutter/material.dart';

class GlobalTopApplicationBar extends StatelessWidget implements PreferredSizeWidget {
  const GlobalTopApplicationBar({
    super.key,
    this.title,
    this.titleConfig = GlobalTopApplicationBarTitleConfig.standard,
    this.leading,
    this.actions = const <Widget>[],
    this.onLeadingPressed,
    this.centerTitle = false,
    this.automaticallyImplyLeading = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 0,
    this.scrolledUnderElevation = 0,
    this.toolbarHeight = kGlobalTopApplicationBarHeight,
  }) : assert(toolbarHeight <= kGlobalTopApplicationBarHeight, 'Strict 64dp vertical layout limit must not be exceeded.');

  static const double kGlobalTopApplicationBarHeight = 64.0;
  static const EdgeInsets kPhantomTargetPadding = EdgeInsets.all(12.0);

  final Widget? title;
  final GlobalTopApplicationBarTitleConfig titleConfig;
  final Widget? leading;
  final List<Widget> actions;
  final VoidCallback? onLeadingPressed;
  final bool centerTitle;
  final bool automaticallyImplyLeading;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double elevation;
  final double scrolledUnderElevation;
  final double toolbarHeight;

  @override
  Size get preferredSize => Size.fromHeight(toolbarHeight);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color resolvedForeground = foregroundColor ?? theme.colorScheme.onSurface;
    final Color resolvedBackground = backgroundColor ?? theme.colorScheme.surface;

    return AppBar(
      toolbarHeight: toolbarHeight,
      leadingWidth: 72.0,
      centerTitle: centerTitle,
      automaticallyImplyLeading: automaticallyImplyLeading,
      backgroundColor: resolvedBackground,
      foregroundColor: resolvedForeground,
      elevation: elevation,
      scrolledUnderElevation: scrolledUnderElevation,
      leading: leading ?? _buildDefaultLeading(context, resolvedForeground),
      title: _buildTitle(context, resolvedForeground),
      actions: _buildActions(actions, resolvedForeground),
      titleSpacing: NavigationToolbar.kMiddleSpacing,
      shape: const Border(
        bottom: BorderSide(color: Color(0x1F000000), width: 1.0),
      ),
    );
  }

  Widget? _buildDefaultLeading(BuildContext context, Color foregroundColor) {
    if (!automaticallyImplyLeading && leading == null) return null;
    return _PhantomTargetIconButton(
      icon: Icons.menu,
      semanticLabel: 'Open navigation drawer',
      color: foregroundColor,
      onPressed: onLeadingPressed ?? () => Scaffold.maybeOf(context)?.openDrawer(),
    );
  }

  Widget? _buildTitle(BuildContext context, Color foregroundColor) {
    if (title == null) return null;
    final TextStyle baseStyle = Theme.of(context).textTheme.titleLarge ?? const TextStyle();
    switch (titleConfig) {
      case GlobalTopApplicationBarTitleConfig.standard:
        return DefaultTextStyle(
          style: baseStyle.copyWith(color: foregroundColor, fontWeight: FontWeight.w600),
          child: title!,
        );
      case GlobalTopApplicationBarTitleConfig.compact:
        return DefaultTextStyle(
          style: baseStyle.copyWith(color: foregroundColor, fontWeight: FontWeight.w600, fontSize: 18.0),
          child: title!,
        );
      case GlobalTopApplicationBarTitleConfig.rowLabel:
        return DefaultTextStyle(
          style: baseStyle.copyWith(color: foregroundColor, fontWeight: FontWeight.w500, letterSpacing: 0.15),
          child: title!,
        );
    }
  }

  List<Widget> _buildActions(List<Widget> sourceActions, Color foregroundColor) {
    return sourceActions.map<Widget>((Widget action) {
      if (action is IconButton || action is _PhantomTargetIconButton) return action;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: IconTheme(
          data: IconThemeData(color: foregroundColor),
          child: action,
        ),
      );
    }).toList(growable: false);
  }
}

enum GlobalTopApplicationBarTitleConfig { standard, compact, rowLabel }

class _PhantomTargetIconButton extends StatelessWidget {
  const _PhantomTargetIconButton({
    required this.icon,
    required this.semanticLabel,
    required this.onPressed,
    required this.color,
  });

  final IconData icon;
  final String semanticLabel;
  final VoidCallback? onPressed;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: GlobalTopApplicationBar.kPhantomTargetPadding,
      child: IconButton(
        icon: Icon(icon),
        color: color,
        tooltip: semanticLabel,
        onPressed: onPressed,
        constraints: const BoxConstraints(minWidth: 48.0, minHeight: 48.0),
        padding: EdgeInsets.zero,
        splashRadius: 24.0,
      ),
    );
  }
}
