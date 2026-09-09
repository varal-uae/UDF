// BPTR-0019-A05 — F-Pattern Dashboard Layout.
// Provides a rigidly ordered dashboard grid that renders the most critical KPI top-left on desktop and top-stacked on mobile; disables dragging and pulses red on top-left KPI failure.

import 'package:flutter/material.dart';

/// A hard-coded F-pattern dashboard layout.
class FPatternDashboardLayout extends StatelessWidget {
  const FPatternDashboardLayout({
    super.key,
    required this.criticalKpi,
    required this.topRow,
    required this.leftColumn,
    required this.rightColumn,
    required this.bottomRow,
    this.criticalKpiHasError = false,
  });

  final Widget criticalKpi;
  final Widget topRow;
  final Widget leftColumn;
  final Widget rightColumn;
  final Widget bottomRow;
  final bool criticalKpiHasError;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        final criticalKpiWithError = _CriticalKpiWrapper(
          hasError: criticalKpiHasError,
          child: criticalKpi,
        );

        if (isMobile) {
          return _FPatternMobile(
            criticalKpi: criticalKpiWithError,
            topRow: topRow,
            leftColumn: leftColumn,
            rightColumn: rightColumn,
            bottomRow: bottomRow,
          );
        }

        return _FPatternDesktop(
          criticalKpi: criticalKpiWithError,
          topRow: topRow,
          leftColumn: leftColumn,
          rightColumn: rightColumn,
          bottomRow: bottomRow,
        );
      },
    );
  }
}

class _CriticalKpiWrapper extends StatefulWidget {
  const _CriticalKpiWrapper({required this.hasError, required this.child});

  final bool hasError;
  final Widget child;

  @override
  State<_CriticalKpiWrapper> createState() => _CriticalKpiWrapperState();
}

class _CriticalKpiWrapperState extends State<_CriticalKpiWrapper>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
      reverseDuration: const Duration(milliseconds: 600),
    );
    _colorAnimation = ColorTween(
      begin: Colors.transparent,
      end: Colors.red.shade100,
    ).animate(_controller);

    if (widget.hasError) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant _CriticalKpiWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.hasError && !oldWidget.hasError) {
      _controller.repeat(reverse: true);
    } else if (!widget.hasError && oldWidget.hasError) {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _colorAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            color: _colorAnimation.value,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(8),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _FPatternMobile extends StatelessWidget {
  const _FPatternMobile({
    required this.criticalKpi,
    required this.topRow,
    required this.leftColumn,
    required this.rightColumn,
    required this.bottomRow,
  });

  final Widget criticalKpi;
  final Widget topRow;
  final Widget leftColumn;
  final Widget rightColumn;
  final Widget bottomRow;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          criticalKpi,
          const SizedBox(height: 12),
          topRow,
          const SizedBox(height: 12),
          leftColumn,
          const SizedBox(height: 12),
          rightColumn,
          const SizedBox(height: 12),
          bottomRow,
        ],
      ),
    );
  }
}

class _FPatternDesktop extends StatelessWidget {
  const _FPatternDesktop({
    required this.criticalKpi,
    required this.topRow,
    required this.leftColumn,
    required this.rightColumn,
    required this.bottomRow,
  });

  final Widget criticalKpi;
  final Widget topRow;
  final Widget leftColumn;
  final Widget rightColumn;
  final Widget bottomRow;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 2, child: criticalKpi),
            const SizedBox(width: 12),
            Expanded(flex: 3, child: topRow),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 2, child: leftColumn),
            const SizedBox(width: 12),
            Expanded(flex: 3, child: rightColumn),
          ],
        ),
        const SizedBox(height: 12),
        bottomRow,
      ],
    );
  }
}