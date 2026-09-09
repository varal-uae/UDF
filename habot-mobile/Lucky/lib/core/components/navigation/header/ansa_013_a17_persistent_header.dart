// ANSA-013-A17 — Persistent Header Layout System Implementation.
// A reusable top navigation bar with a fixed 56 dp content height, right-aligned actions,
// background blur, bottom divider, scroll-dependent elevation, and permission-aware action visibility.
import 'dart:ui';

import 'package:flutter/material.dart';

const double ansa013A17HeaderHeight = 56;

@immutable
class Ansa013A17HeaderAction {
  const Ansa013A17HeaderAction({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.isPermitted = true,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool isPermitted;
}

class Ansa013A17PersistentHeader extends StatefulWidget implements PreferredSizeWidget {
  const Ansa013A17PersistentHeader({
    super.key,
    this.title,
    this.leading,
    this.actions = const <Ansa013A17HeaderAction>[],
    this.scrollController,
    this.backgroundColor,
    this.dividerColor,
    this.blurSigma = 8,
  });

  final String? title;
  final Widget? leading;
  final List<Ansa013A17HeaderAction> actions;
  final ScrollController? scrollController;
  final Color? backgroundColor;
  final Color? dividerColor;
  final double blurSigma;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<Ansa013A17PersistentHeader> createState() => _Ansa013A17PersistentHeaderState();
}

class _Ansa013A17PersistentHeaderState extends State<Ansa013A17PersistentHeader> {
  ScrollController? _scrollController;
  double _elevation = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController;
    _scrollController?.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _scrollController?.removeListener(_handleScroll);
    super.dispose();
  }

  void _handleScroll() {
    if (_scrollController == null || !_scrollController!.hasClients) {
      return;
    }
    final bool isScrolling = _scrollController!.position.isScrollingNotifier.value;
    if (isScrolling != (_elevation > 0)) {
      setState(() {
        _elevation = isScrolling ? 1.0 : 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color background = widget.backgroundColor ?? colorScheme.surface.withValues(alpha: 0.72);
    final Color divider = widget.dividerColor ?? colorScheme.outlineVariant.withValues(alpha: 0.4);
    final List<Ansa013A17HeaderAction> visibleActions = widget.actions.where((action) => action.isPermitted).toList();

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: widget.blurSigma, sigmaY: widget.blurSigma),
        child: Material(
          color: background,
          elevation: _elevation,
          child: Container(
            height: kToolbarHeight,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: divider, width: 0.5),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                if (widget.leading != null) ...[
                  widget.leading!,
                  const SizedBox(width: 8),
                ],
                if (widget.title != null)
                  Expanded(
                    child: Text(
                      widget.title!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                else
                  const Spacer(),
                ...visibleActions.map((action) => IconButton(
                  tooltip: action.label,
                  onPressed: action.onPressed,
                  icon: Icon(action.icon),
                  color: colorScheme.onSurfaceVariant,
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}