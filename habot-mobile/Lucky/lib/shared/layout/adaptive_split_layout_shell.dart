import 'package:flutter/material.dart';
import 'breakpoints.dart';

/// SSELC-029-A01 — Fluid master/detail split-panel layout wrapper.
///
/// - Compact  (<600dp) : Full-screen list. Row tap pushes detail as new route.
/// - Medium/Expanded (≥600dp) : 60/40 side-by-side split. Row tap updates
///   detail panel in-place without navigation.
///
/// Usage:
/// ```dart
/// AdaptiveSplitLayoutShell(
///   listPane: MyListView(onRowSelected: (id) => setState(() => _selectedId = id)),
///   detailPane: _selectedId != null ? MyDetailView(id: _selectedId!) : null,
///   onMobileDetailRoute: () => context.push('/detail/$_selectedId'),
/// )
/// ```
class AdaptiveSplitLayoutShell extends StatelessWidget {
  const AdaptiveSplitLayoutShell({
    super.key,
    required this.listPane,
    this.detailPane,
    this.onMobileDetailRoute,
    this.dividerColor,
  });

  /// Left/full-screen list panel.
  final Widget listPane;

  /// Right detail panel — shown only on wide layouts.
  /// Pass [null] to show the empty detail placeholder.
  final Widget? detailPane;

  /// Called on compact screens when a row is tapped.
  /// Caller should push the detail route via go_router.
  final VoidCallback? onMobileDetailRoute;

  /// Optional divider color between panels. Defaults to theme outline.
  final Color? dividerColor;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    if (HabotBreakpoints.isCompact(width)) {
      // Mobile — clean single-view list only.
      return listPane;
    }

    // Tablet / widescreen — 60/40 horizontal split.
    final listFlex = HabotBreakpoints.isExpanded(width) ? 6 : 5;
    final detailFlex = HabotBreakpoints.isExpanded(width) ? 4 : 5;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(flex: listFlex, child: listPane),
        VerticalDivider(
          width: 1,
          thickness: 1,
          color: dividerColor ?? Theme.of(context).colorScheme.outlineVariant,
        ),
        Expanded(
          flex: detailFlex,
          child: detailPane ?? const _EmptyDetailPlaceholder(),
        ),
      ],
    );
  }
}

class _EmptyDetailPlaceholder extends StatelessWidget {
  const _EmptyDetailPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.touch_app_outlined,
            size: 48,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'Select a row to view details',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}
