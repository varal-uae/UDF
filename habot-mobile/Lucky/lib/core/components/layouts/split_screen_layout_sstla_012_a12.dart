// SSTLA-012-A12 — Unified Split-Screen Layout Container for Mobile Contextual Mirror.
// Provides a responsive split-screen layout with double-tap snap ratios, clear boundary borders, and touch physics for the screen splitter.

import 'package:flutter/material.dart';

/// Mock template configuration data to satisfy atomic-level data requirements
/// without relying on backend services.
class TemplateConfigMock {
  static const String templateName = 'ContextualMirrorLayout';
  static const String templateVersion = '1.0.0';
  static const String templateType = 'SplitScreen';
  static const Map<String, dynamic> templateConfiguration = {
    'defaultRatio': 0.5,
    'snapRatios': [0.33, 0.5, 0.67],
    'minPanelSize': 80.0,
    'dividerThickness': 8.0,
  };
}

/// Master layout wrapper that all split-screen views must extend.
/// Code linters or architectural reviews should enforce this inheritance
/// to satisfy Poka-Yoke mistake-proofing requirements.
abstract class MasterSplitLayoutWrapper extends StatefulWidget {
  const MasterSplitLayoutWrapper({super.key});
}

/// A unified layout container component that presents evidence and action panels
/// in a mobile-first split-screen (Contextual Mirror) configuration.
class SplitScreenLayoutSstla012A12 extends MasterSplitLayoutWrapper {
  final Widget evidencePanel;
  final Widget actionPanel;

  const SplitScreenLayoutSstla012A12({
    super.key,
    required this.evidencePanel,
    required this.actionPanel,
  });

  @override
  State<SplitScreenLayoutSstla012A12> createState() => _SplitScreenLayoutSstla012A12State();
}

class _SplitScreenLayoutSstla012A12State extends State<SplitScreenLayoutSstla012A12>
    with SingleTickerProviderStateMixin {
  // Snap ratios for double-tapping panel bars
  final List<double> _snapRatios =
      List<double>.from(TemplateConfigMock.templateConfiguration['snapRatios'] as List);
  double _currentRatio = TemplateConfigMock.templateConfiguration['defaultRatio'] as double;
  int _currentSnapIndex = 1;

  late AnimationController _animationController;
  late Animation<double> _ratioAnimation;

  final double _minPanelSize = TemplateConfigMock.templateConfiguration['minPanelSize'] as double;
  final double _dividerThickness =
      TemplateConfigMock.templateConfiguration['dividerThickness'] as double;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onDoubleTapSnap() {
    _currentSnapIndex = (_currentSnapIndex + 1) % _snapRatios.length;
    final targetRatio = _snapRatios[_currentSnapIndex];

    _ratioAnimation = Tween<double>(
      begin: _currentRatio,
      end: targetRatio,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward(from: 0.0).then((_) {
      setState(() {
        _currentRatio = targetRatio;
      });
    });
  }

  void _onDividerDragUpdate(DragUpdateDetails details, double totalHeight) {
    setState(() {
      final newRatio = _currentRatio + (details.delta.dy / totalHeight);
      final minRatio = _minPanelSize / totalHeight;
      final maxRatio = 1.0 - (_minPanelSize / totalHeight);
      _currentRatio = newRatio.clamp(minRatio, maxRatio);
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isLandscape = constraints.maxWidth > constraints.maxHeight;
        final totalMainAxisSize =
            isLandscape ? constraints.maxWidth : constraints.maxHeight;

        // Calculate sizes maintaining target sizes across rotations
        final primarySize =
            (totalMainAxisSize * _currentRatio) - (_dividerThickness / 2);
        final secondarySize =
            (totalMainAxisSize * (1.0 - _currentRatio)) - (_dividerThickness / 2);

        final animatedPrimarySize = _animationController.isAnimating
            ? (totalMainAxisSize * _ratioAnimation.value) - (_dividerThickness / 2)
            : primarySize;
        final animatedSecondarySize = _animationController.isAnimating
            ? (totalMainAxisSize * (1.0 - _ratioAnimation.value)) -
                (_dividerThickness / 2)
            : secondarySize;

        final divider = GestureDetector(
          onVerticalDragUpdate: isLandscape
              ? null
              : (details) => _onDividerDragUpdate(details, totalMainAxisSize),
          onHorizontalDragUpdate: !isLandscape
              ? null
              : (details) => _onDividerDragUpdate(details, totalMainAxisSize),
          child: MouseRegion(
            cursor: isLandscape
                ? SystemMouseCursors.resizeColumn
                : SystemMouseCursors.resizeRow,
            child: Container(
              width: isLandscape ? _dividerThickness : double.infinity,
              height: isLandscape ? double.infinity : _dividerThickness,
              color: Theme.of(context).colorScheme.primaryContainer,
              // Mobile-First UI GMRD Decision: Use clear boundary borders to highlight active panels
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    width: 1.0,
                  ),
                ),
              ),
            ),
          ),
        );

        // Panel bar with double-tap gesture recognizer
        final evidencePanelBar = GestureDetector(
          onDoubleTap: _onDoubleTapSnap,
          behavior: HitTestBehavior.opaque,
          child: SizedBox(
            width: isLandscape ? animatedPrimarySize : double.infinity,
            height: isLandscape ? double.infinity : animatedPrimarySize,
            child: widget.evidencePanel,
          ),
        );

        final actionPanelBar = GestureDetector(
          onDoubleTap: _onDoubleTapSnap,
          behavior: HitTestBehavior.opaque,
          child: SizedBox(
            width: isLandscape ? animatedSecondarySize : double.infinity,
            height: isLandscape ? double.infinity : secondarySize,
            child: widget.actionPanel,
          ),
        );

        if (isLandscape) {
          return Row(
            children: [
              evidencePanelBar,
              divider,
              actionPanelBar,
            ],
          );
        }

        return Column(
          children: [
            evidencePanelBar,
            divider,
            actionPanelBar,
          ],
        );
      },
    );
  }
}

/// Sample Evidence Component to be mounted into the template panel region.
class SampleEvidencePanel extends StatelessWidget {
  const SampleEvidencePanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.fact_check, size: 48, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 8),
            Text(
              'Evidence Panel',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Template: ${TemplateConfigMock.templateName}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

/// Sample Action Component to be mounted into the template panel region.
/// Anchors validation buttons safely along lower viewport limits.
class SampleActionPanel extends StatelessWidget {
  const SampleActionPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Action Panel',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Spacer(),
            // Mobile-First UX GMRD Decision: Anchor validation buttons safely along lower viewport limits
            SafeArea(
              top: false,
              left: false,
              right: false,
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Validate & Submit'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
