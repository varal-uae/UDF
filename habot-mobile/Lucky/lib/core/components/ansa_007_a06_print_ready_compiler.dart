// ANSA-007-A06 — Print-ready style compiler for dashboard components.
// Hides interactive sliders/search boxes in print mode, forces white backgrounds, and exposes print preview state.

import 'package:flutter/material.dart';

/// Defines the current layout rendering mode.
enum AnsA007A06PrintMode { screen, print }

/// Scope that provides print mode to descendants.
class AnsA007A06PrintScope extends InheritedWidget {
  const AnsA007A06PrintScope({
    super.key,
    required this.mode,
    required super.child,
  });

  final AnsA007A06PrintMode mode;

  static AnsA007A06PrintMode of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AnsA007A06PrintScope>();
    return scope?.mode ?? AnsA007A06PrintMode.screen;
  }

  @override
  bool updateShouldNotify(AnsA007A06PrintScope oldWidget) => oldWidget.mode != mode;
}

/// Wraps interactive-only widgets so they are hidden in print mode.
class AnsA007A06PrintAwareVisibility extends StatelessWidget {
  const AnsA007A06PrintAwareVisibility({
    super.key,
    required this.interactiveElement,
  });

  final Widget interactiveElement;

  @override
  Widget build(BuildContext context) {
    final mode = AnsA007A06PrintScope.of(context);
    if (mode == AnsA007A06PrintMode.print) {
      return const SizedBox.shrink();
    }
    return interactiveElement;
  }
}

/// Converts a dark-mode dashboard to a clean white print canvas.
class AnsA007A06PrintCanvas extends StatelessWidget {
  const AnsA007A06PrintCanvas({
    super.key,
    required this.child,
    this.printMode = AnsA007A06PrintMode.screen,
  });

  final Widget child;
  final AnsA007A06PrintMode printMode;

  @override
  Widget build(BuildContext context) {
    final isPrint = printMode == AnsA007A06PrintMode.print;
    return AnsA007A06PrintScope(
      mode: printMode,
      child: ColoredBox(
        color: isPrint ? Colors.white : Colors.transparent,
        child: child,
      ),
    );
  }
}

/// Compiles a dashboard widget into its print-ready representation.
class AnsA007A06PrintStyleCompiler {
  const AnsA007A06PrintStyleCompiler._();

  static Widget compileForPrint(Widget dashboard) {
    return AnsA007A06PrintCanvas(
      printMode: AnsA007A06PrintMode.print,
      child: dashboard,
    );
  }
}
