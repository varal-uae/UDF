// DPNDL-011-A13 — Global Top Application Bar.
// Reusable Material 3 header fixed at 64dp height with responsive width handling and accessible phantom touch targets.
import 'package:flutter/material.dart';

class Dpndl011A13GlobalTopAppBar extends StatelessWidget implements PreferredSizeWidget {
  const Dpndl011A13GlobalTopAppBar({
    super.key,
    required this.title,
    this.leading,
    this.actions = const <Widget>[],
    this.centerTitle = false,
    this.onDrawerTap,
    this.semanticLabel,
  });

  final String title;
  final Widget? leading;
  final List<Widget> actions;
  final bool centerTitle;
  final VoidCallback? onDrawerTap;
  final String? semanticLabel;

  static const double preferredHeight = 64.0;

  @override
  Size get preferredSize => const Size.fromHeight(preferredHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool compact = constraints.maxWidth < 360;
        final EdgeInsetsGeometry horizontalPadding = EdgeInsets.symmetric(
          horizontal: compact ? 8.0 : 16.0,
        );
        return Material(
          color: colorScheme.surface,
          elevation: 0,
          child: SafeArea(
            bottom: false,
            child: SizedBox(
              height: preferredHeight,
              child: Padding(
                padding: horizontalPadding,
                child: Row(
                  children: [
                    if (leading != null)
                      leading!
                    else if (onDrawerTap != null)
                      _PhantomTargetPadding(
                        child: IconButton(
                          onPressed: onDrawerTap,
                          icon: const Icon(Icons.menu),
                          tooltip: 'Open navigation menu',
                        ),
                      ),
                    Expanded(
                      child: Semantics(
                        header: true,
                        label: semanticLabel ?? title,
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: centerTitle ? TextAlign.center : TextAlign.start,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    if (actions.isNotEmpty)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: actions
                            .map((action) => _PhantomTargetPadding(child: action))
                            .toList(growable: false),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PhantomTargetPadding extends StatelessWidget {
  const _PhantomTargetPadding({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 48.0, minHeight: 48.0),
        child: child,
      ),
    );
  }
}