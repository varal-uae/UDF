import 'package:flutter/material.dart';
import 'viewport_split_rules.dart';
import 'screen_size_provider.dart';

// SSTLA-020-A01 — Split Route State Controller.
// Tracks the active detail path code continuously.
// Handles two spec requirements:
//   1. Auto-close detail screen if selected row is deleted by another session.
//   2. Keep correct detail open during screen rotations (trackPathOnRotation).

class SplitRouteController<T extends Object> extends ChangeNotifier {
  SplitRouteController();

  T? _selectedItem;
  String? _selectedId;
  bool _isDetailOpen = false;

  T?     get selectedItem  => _selectedItem;
  String? get selectedId   => _selectedId;
  bool   get isDetailOpen  => _isDetailOpen;

  /// Called when user taps a row.
  void selectItem(T item, String id) {
    _selectedItem = item;
    _selectedId   = id;
    _isDetailOpen = true;
    notifyListeners();
  }

  /// Called when detail is dismissed (back button / navigation pop).
  void clearSelection() {
    _selectedItem = null;
    _selectedId   = null;
    _isDetailOpen = false;
    notifyListeners();
  }

  /// Spec: close active detail screen automatically if the selected row
  /// is deleted by another active user session.
  /// Call this when a real-time delete event arrives (e.g. WebSocket / Firestore).
  void onRemoteDelete(String deletedId) {
    if (_selectedId == deletedId) {
      clearSelection();
    }
  }

  /// Spec: layout tracking tools check active path codes continuously,
  /// keeping correct details open during screen rotations.
  /// Call this on every [didChangeMetrics] — restores detail state after rotation.
  void onRotation(BuildContext context) {
    final sizeClass = ScreenSizeProvider.of(context);
    final rule      = ViewportSplitRules.forSizeClass(sizeClass);

    if (!rule.trackPathOnRotation) return;

    // If rotating from compact (detail was a pushed route) to split pane,
    // the detail should now render in the split panel — not as a stacked route.
    // Notify listeners so the layout shell can re-evaluate.
    notifyListeners();
  }
}

// ─── SPLIT ROUTE SHELL ────────────────────────────────────────────────────────

/// Wraps [AdaptivePanelRouter] with [SplitRouteController] to add:
/// - Auto-close on remote delete
/// - Path tracking across rotations
/// - Rule-driven pane ratio from [ViewportSplitRules]
///
/// Usage:
/// ```dart
/// SplitRouteShell<MyItem>(
///   controller: _controller,
///   items: _items,
///   listBuilder: (items, selected, onSelect) => MyListPane(...),
///   detailBuilder: (item) => MyDetailPane(item: item),
///   mobileDetailRouteBuilder: (ctx, item) => ctx.push('/detail/${item.id}'),
/// )
/// ```
class SplitRouteShell<T extends Object> extends StatefulWidget {
  const SplitRouteShell({
    super.key,
    required this.controller,
    required this.items,
    required this.listBuilder,
    required this.detailBuilder,
    this.mobileDetailRouteBuilder,
  });

  final SplitRouteController<T> controller;
  final List<T> items;

  final Widget Function(
    List<T> items,
    T? selectedItem,
    void Function(T item, String id) onSelect,
  ) listBuilder;

  final Widget Function(T item) detailBuilder;
  final void Function(BuildContext context, T item)? mobileDetailRouteBuilder;

  @override
  State<SplitRouteShell<T>> createState() => _SplitRouteShellState<T>();
}

class _SplitRouteShellState<T extends Object>
    extends State<SplitRouteShell<T>> with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.controller.addListener(_onControllerChange);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.controller.removeListener(_onControllerChange);
    super.dispose();
  }

  @override
  void didChangeMetrics() => widget.controller.onRotation(context);

  void _onControllerChange() => setState(() {});

  void _onSelect(T item, String id) {
    final sizeClass = ScreenSizeProvider.of(context);
    final rule      = ViewportSplitRules.forSizeClass(sizeClass);

    widget.controller.selectItem(item, id);

    if (rule.navigationMode == NavigationMode.singleStack) {
      widget.mobileDetailRouteBuilder?.call(context, item);
    }
    // splitPane — detail renders in-place, no route push needed
  }

  @override
  Widget build(BuildContext context) {
    final sizeClass = ScreenSizeProvider.of(context);
    final rule      = ViewportSplitRules.forSizeClass(sizeClass);
    final selected  = widget.controller.selectedItem;

    if (rule.navigationMode == NavigationMode.singleStack) {
      return widget.listBuilder(widget.items, selected, _onSelect);
    }

    // Split pane — 60/40 or 50/50 based on rule
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: rule.paneRatio.list,
          child: widget.listBuilder(widget.items, selected, _onSelect),
        ),
        VerticalDivider(
          width: 1,
          thickness: 1,
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
        Expanded(
          flex: rule.paneRatio.detail,
          child: selected != null
              ? widget.detailBuilder(selected)
              : const _EmptyDetailPane(),
        ),
      ],
    );
  }
}

class _EmptyDetailPane extends StatelessWidget {
  const _EmptyDetailPane();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.touch_app_outlined,
              size: 48, color: Theme.of(context).colorScheme.outline),
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
