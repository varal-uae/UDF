import 'package:flutter/material.dart';
import 'breakpoints.dart';
import 'size_class.dart';
import 'screen_size_provider.dart';
import 'adaptive_split_layout_shell.dart';

/// SSELC-029-A01 — Adaptive panel router.
///
/// Evaluates device viewport width continuously (responds to rotations and
/// window resizes). Routes row-select events to:
///   - Independent full-screen push  → compact mobile
///   - In-place sidebar detail update → medium / expanded widescreen
///
/// Keeps selected row highlighted in the list at all times.
///
/// Usage:
/// ```dart
/// AdaptivePanelRouter<MyItem>(
///   items: _items,
///   listBuilder: (items, selectedId, onSelect) => MyListPane(
///     items: items,
///     selectedId: selectedId,
///     onSelect: onSelect,
///   ),
///   detailBuilder: (item) => MyDetailPane(item: item),
///   mobileDetailRouteBuilder: (context, item) => context.push('/detail/${item.id}'),
/// )
/// ```
class AdaptivePanelRouter<T extends Object> extends StatefulWidget {
  const AdaptivePanelRouter({
    super.key,
    required this.items,
    required this.listBuilder,
    required this.detailBuilder,
    this.mobileDetailRouteBuilder,
    this.initialSelectedItem,
  });

  final List<T> items;

  /// Builds the list pane. Receives [items], current [selectedItem], and
  /// [onItemSelected] callback — call it on row tap.
  final Widget Function(
    List<T> items,
    T? selectedItem,
    void Function(T item) onItemSelected,
  ) listBuilder;

  /// Builds the detail pane for the given selected item.
  final Widget Function(T item) detailBuilder;

  /// Called on compact screens when a row is tapped.
  /// Use go_router to push the detail screen.
  final void Function(BuildContext context, T item)? mobileDetailRouteBuilder;

  final T? initialSelectedItem;

  @override
  State<AdaptivePanelRouter<T>> createState() => _AdaptivePanelRouterState<T>();
}

class _AdaptivePanelRouterState<T extends Object>
    extends State<AdaptivePanelRouter<T>> {
  T? _selectedItem;

  @override
  void initState() {
    super.initState();
    _selectedItem = widget.initialSelectedItem;
  }

  void _onItemSelected(T item) {
    // Reads from centralised ScreenSizeProvider — not raw MediaQuery.
    final sizeClass = ScreenSizeProvider.of(context);

    if (sizeClass.isCompact) {
      widget.mobileDetailRouteBuilder?.call(context, item);
    } else {
      setState(() => _selectedItem = item);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveSplitLayoutShell(
      listPane: widget.listBuilder(
        widget.items,
        _selectedItem,
        _onItemSelected,
      ),
      detailPane: _selectedItem != null
          ? widget.detailBuilder(_selectedItem as T)
          : null,
    );
  }
}
