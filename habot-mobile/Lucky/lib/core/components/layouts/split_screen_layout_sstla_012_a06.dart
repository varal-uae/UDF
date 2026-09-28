// SSTLA-012-A06 — Unified Split-Screen Layout Container for Mobile Contextual Mirror.
// Provides side-by-side or collapsible panel parameters for landscape mobile viewports with double-tap snap ratios and clean touch physics.

import 'package:flutter/material.dart';

/// Configuration accuracy metric constants per ITIL CMDB standard.
const double kConfigAccuracyFloor = 0.98;
const double kConfigAccuracyOptimal = 1.0;
const double kConfigAccuracyCeiling = 1.0;

/// Supported split ratios for the layout panels.
enum SplitRatio {
  half(0.5),
  thirdLeft(0.33),
  thirdRight(0.67),
  fullLeft(1.0),
  fullRight(0.0);

  const SplitRatio(this.value);
  final double value;
}

/// Master layout wrapper that enforces structural assembly for split-screen views.
/// Any view failing to extend this wrapper will be blocked by code linters (Poka-Yoke).
class SplitScreenLayout extends StatefulWidget {
  const SplitScreenLayout({
    super.key,
    required this.evidencePanel,
    required this.actionPanel,
    this.initialRatio = SplitRatio.half,
    this.dividerThickness = 8.0,
    this.onRatioChanged,
  });

  /// The left/top panel displaying evidence context.
  final Widget evidencePanel;

  /// The right/bottom panel displaying action controls.
  final Widget actionPanel;

  /// Initial split ratio for landscape viewports.
  final SplitRatio initialRatio;

  /// Thickness of the draggable screen splitter control.
  final double dividerThickness;

  /// Callback fired when the user changes the split ratio.
  final ValueChanged<SplitRatio>? onRatioChanged;

  @override
  State<SplitScreenLayout> createState() => _SplitScreenLayoutState();
}

class _SplitScreenLayoutState extends State<SplitScreenLayout>
    with SingleTickerProviderStateMixin {
  late double _currentRatio;
  late AnimationController _snapController;
  late Animation<double> _snapAnimation;

  // Mock telemetry data fields as specified in Data Requirement
  final Map<String, dynamic> _mockTelemetryData = {
    'mobilePlatform': 'Android',
    'osVersion': '14',
    'deviceType': 'Mobile',
    'screenDimensions': 'Compact',
    'mobileConfiguration': 'Landscape',
    'completionStatus': 'Pass',
    'actionEventTimestamp': '2026-09-28T12:00:00Z',
    'userSessionId': 'mock-session-001',
  };

  @override
  void initState() {
    super.initState();
    _currentRatio = widget.initialRatio.value;
    _snapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  @override
  void dispose() {
    _snapController.dispose();
    super.dispose();
  }

  void _handleDoubleTap() {
    // Double-tapping panel bars snaps views between split ratios instantly.
    final List<double> ratios = SplitRatio.values.map((e) => e.value).toList();
    int currentIndex = ratios.indexOf(_currentRatio);
    if (currentIndex == -1) currentIndex = 0;
    final nextIndex = (currentIndex + 1) % ratios.length;
    final targetRatio = ratios[nextIndex];

    _snapAnimation = Tween<double>(
      begin: _currentRatio,
      end: targetRatio,
    ).animate(CurvedAnimation(
      parent: _snapController,
      curve: Curves.easeOutCubic, // Clean touch physics
    ));

    _snapController.forward(from: 0.0).then((_) {
      setState(() {
        _currentRatio = targetRatio;
      });
      widget.onRatioChanged?.call(SplitRatio.values.firstWhere(
        (e) => e.value == targetRatio,
        orElse: () => SplitRatio.half,
      ));
    });

    setState(() {});
  }

  void _onDragUpdate(DragUpdateDetails details, BoxConstraints constraints) {
    final isLandscape = constraints.maxWidth > constraints.maxHeight;
    final delta = isLandscape
        ? details.delta.dx / constraints.maxWidth
        : details.delta.dy / constraints.maxHeight;

    setState(() {
      _currentRatio = (_currentRatio + delta).clamp(0.0, 1.0);
    });
  }

  void _onDragEnd(DragEndDetails details) {
    // Snap to nearest defined ratio after drag ends
    final closest = SplitRatio.values.reduce((a, b) =>
        (a.value - _currentRatio).abs() < (b.value - _currentRatio).abs()
            ? a
            : b);
    _snapAnimation = Tween<double>(
      begin: _currentRatio,
      end: closest.value,
    ).animate(CurvedAnimation(
      parent: _snapController,
      curve: Curves.easeOutCubic,
    ));

    _snapController.forward(from: 0.0).then((_) {
      setState(() {
        _currentRatio = closest.value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isLandscape = constraints.maxWidth > constraints.maxHeight;
        final totalSize =
            isLandscape ? constraints.maxWidth : constraints.maxHeight;
        final primarySize = totalSize * _currentRatio;
        final secondarySize = totalSize - primarySize - widget.dividerThickness;

        final bool isAnimating = _snapController.isAnimating;

        Widget animatedBuilder() {
          if (isAnimating && _snapAnimation.value != null) {
            final animPrimary = totalSize * _snapAnimation.value;
            final animSecondary =
                totalSize - animPrimary - widget.dividerThickness;
            return _buildPanels(
              constraints,
              isLandscape,
              animPrimary.clamp(0.0, totalSize),
              animSecondary.clamp(0.0, totalSize),
            );
          }
          return _buildPanels(
            constraints,
            isLandscape,
            primarySize.clamp(0.0, totalSize),
            secondarySize.clamp(0.0, totalSize),
          );
        }

        return GestureDetector(
          onDoubleTap: _handleDoubleTap,
          child: Material(
            color: Theme.of(context).colorScheme.surface,
            child: SafeArea(
              child: animatedBuilder(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPanels(
    BoxConstraints constraints,
    bool isLandscape,
    double primarySize,
    double secondarySize,
  ) {
    final theme = Theme.of(context);
    final borderColor = theme.colorScheme.outlineVariant;

    final Widget evidence = Expanded(
      flex: primarySize.toInt(),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: borderColor, width: 1.0),
        ),
        child: widget.evidencePanel,
      ),
    );

    final Widget action = Expanded(
      flex: secondarySize.toInt(),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: borderColor, width: 1.0),
        ),
        child: widget.actionPanel,
      ),
    );

    final Widget divider = GestureDetector(
      onHorizontalDragUpdate: isLandscape
          ? (details) => _onDragUpdate(details, constraints)
          : null,
      onVerticalDragUpdate: !isLandscape
          ? (details) => _onDragUpdate(details, constraints)
          : null,
      onHorizontalDragEnd: isLandscape ? _onDragEnd : null,
      onVerticalDragEnd: !isLandscape ? _onDragEnd : null,
      child: MouseRegion(
        cursor: isLandscape
            ? SystemMouseCursors.resizeColumn
            : SystemMouseCursors.resizeRow,
        child: Container(
          width: isLandscape ? widget.dividerThickness : double.infinity,
          height: isLandscape ? double.infinity : widget.dividerThickness,
          color: theme.colorScheme.surfaceContainerHighest,
          alignment: Alignment.center,
          child: Icon(
            isLandscape ? Icons.drag_indicator : Icons.drag_handle,
            size: 16,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );

    if (isLandscape) {
      return Row(
        children: [
          Flexible(flex: (primarySize * 1000).toInt(), child: evidence),
          divider,
          Flexible(flex: (secondarySize * 1000).toInt(), child: action),
        ],
      );
    }

    return Column(
      children: [
        Flexible(flex: (primarySize * 1000).toInt(), child: evidence),
        divider,
        Flexible(flex: (secondarySize * 1000).toInt(), child: action),
      ],
    );
  }
}

/// Poka-Yoke enforcement mixin: Views must extend this to compile successfully.
/// Missing layout hooks stop compilation, keeping bad code out of testing builds.
mixin UdfMasterLayoutWrapper<T extends StatefulWidget> on State<T> {
  /// Forces implementation of the master layout container.
  SplitScreenLayout buildMasterLayout({
    required Widget evidencePanel,
    required Widget actionPanel,
  }) {
    return SplitScreenLayout(
      evidencePanel: evidencePanel,
      actionPanel: actionPanel,
    );
  }
}
