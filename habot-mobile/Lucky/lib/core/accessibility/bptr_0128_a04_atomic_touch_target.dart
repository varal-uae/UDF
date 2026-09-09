// BPTR-0128-A04 — Global Atomic Interactive Touch Target Boundary.
// Enforces Material 3 minimum 48x48px tap targets and 8px separation between interactive controls.
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Wraps a child interactive element to guarantee mobile-friendly touch
/// target dimensions and dynamic padding expansion per BPTR-0128-A04.
class AtomicTouchTarget extends StatelessWidget {
  const AtomicTouchTarget({
    super.key,
    required this.child,
    this.onTap,
    this.semanticLabel,
    this.minTapSize = const Size(48, 48),
    this.outerSpacing = 4,
    this.showDiagnostics = false,
  }) : assert(minTapSize.width >= 48 && minTapSize.height >= 48,
            'BPTR-0128-A04: tap target must be at least 48x48px'),
       assert(outerSpacing >= 0);

  final Widget child;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final Size minTapSize;
  final double outerSpacing;
  final bool showDiagnostics;

  @override
  Widget build(BuildContext context) {
    final Widget constrained = ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: minTapSize.width,
        minHeight: minTapSize.height,
      ),
      child: child,
    );

    final Widget semantic = Semantics(
      button: onTap != null,
      label: semanticLabel,
      child: constrained,
    );

    final Widget tappable = onTap == null
        ? semantic
        : Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              child: semantic,
            ),
          );

    // 8px separation: half spacing each side yields full gap between adjacent targets.
    return Padding(
      padding: EdgeInsets.all(outerSpacing),
      child: showDiagnostics
          ? _DiagnosticTapTarget(child: tappable, minTapSize: minTapSize)
          : tappable,
    );
  }
}

class _DiagnosticTapTarget extends StatelessWidget {
  const _DiagnosticTapTarget({required this.child, required this.minTapSize});

  final Widget child;
  final Size minTapSize;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < minTapSize.width ||
            constraints.maxHeight < minTapSize.height) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            assert(() {
              debugPrint(
                'BPTR-0128-A04 WARNING: Interactive target '
                '${constraints.maxWidth.toStringAsFixed(1)}x'
                '${constraints.maxHeight.toStringAsFixed(1)} is below '
                '${minTapSize.width.toStringAsFixed(1)}x'
                '${minTapSize.height.toStringAsFixed(1)}.',
              );
              return true;
            }());
          });
        }
        return child;
      },
    );
  }
}
