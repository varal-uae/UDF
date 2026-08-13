import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';

// BPTR-0377-A01 — Z-Index Layer Manager.
// Controls all overlapping UI components via HabotZIndex constants.
// Hard-coded variables prevent arbitrary z-index numbers anywhere in the app.
//
// Layer scale (5 levels):
//   base(0) → stickyHeader(10) → overlay(20) → modal(30) → shaktiAlert(40)
//
// Usage:
//   ZLayer.base(child: MyCard())
//   ZLayer.overlay(child: MyDropdown())
//   ZLayer.shaktiAlert(child: MyAlert())

class ZLayer extends StatelessWidget {
  const ZLayer._({
    super.key,
    required this.child,
    required this.level,
  });

  final Widget child;
  final int level;

  /// Level 1 — Base content: body, lists, cards, data tables.
  factory ZLayer.base({Key? key, required Widget child}) =>
      ZLayer._(key: key, child: child, level: HabotZIndex.base);

  /// Level 2 — Sticky headers: app bars, pinned column headers, tab bars.
  factory ZLayer.stickyHeader({Key? key, required Widget child}) =>
      ZLayer._(key: key, child: child, level: HabotZIndex.stickyHeader);

  /// Level 3 — Overlays: dropdowns, tooltips, menus, bottom sheets, drawers.
  factory ZLayer.overlay({Key? key, required Widget child}) =>
      ZLayer._(key: key, child: child, level: HabotZIndex.overlay);

  /// Level 4 — Modals: dialogs, full-screen takeovers, side sheets.
  factory ZLayer.modal({Key? key, required Widget child}) =>
      ZLayer._(key: key, child: child, level: HabotZIndex.modal);

  /// Level 5 — Shakti Alert: critical system alerts, force-upgrade banners.
  /// Always topmost — never obscured by any other layer.
  factory ZLayer.shaktiAlert({Key? key, required Widget child}) =>
      ZLayer._(key: key, child: child, level: HabotZIndex.shaktiAlert);

  @override
  Widget build(BuildContext context) => child;
}

// ─── LAYERED STACK ────────────────────────────────────────────────────────────

/// Composes multiple [ZLayer] children into a correctly ordered [Stack].
/// Automatically sorts by [ZLayer.level] — highest level renders on top.
/// Prevents overlapping UI chaos on constrained mobile Z-axis.
///
/// Usage:
/// ```dart
/// LayeredStack(
///   children: [
///     ZLayer.base(child: DashboardBody()),
///     ZLayer.stickyHeader(child: AppHeaderBar()),
///     ZLayer.overlay(child: DropdownMenu()),
///     ZLayer.shaktiAlert(child: ShaktiAlertBanner()),
///   ],
/// )
/// ```
class LayeredStack extends StatelessWidget {
  const LayeredStack({
    super.key,
    required this.children,
    this.alignment = AlignmentDirectional.topStart,
  });

  final List<ZLayer> children;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    final sorted = [...children]
      ..sort((a, b) => a.level.compareTo(b.level));

    return Stack(
      alignment: alignment,
      children: sorted,
    );
  }
}
