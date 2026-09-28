// SSTLA-012-A03 — Unified Split-Screen Layout Container for Mobile Contextual Mirror.
// Provides a responsive split-screen layout with double-tap snap ratios, clean touch physics, and boundary borders for action/evidence panels.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Master layout wrapper that all split-screen views must extend.
/// Code linters should enforce this to prevent un-wrapped views (Poka-Yoke).
abstract class MasterSplitLayoutWrapper extends StatelessWidget {
  const MasterSplitLayoutWrapper({super.key});
}

/// Enum representing the available split ratios for the contextual mirror layout.
enum SplitRatio {
  half(0.5),
  evidenceDominant(0.7),
  actionDominant(0.3);

  final double ratio;
  const SplitRatio(this.ratio);
}

/// Mock telemetry data structure for GCP/BigQuery alignment.
class PanelViewMetric {
  final String stepExecutionId;
  final String executionStatus;
  final DateTime executionTimestamp;
  final String stepOutcome;
  final String userId;
  final SplitRatio activeRatio;

  const PanelViewMetric({
    required this.stepExecutionId,
    required this.executionStatus,
    required this.executionTimestamp,
    required this.stepOutcome,
    required this.userId,
    required this.activeRatio,
  });

  Map<String, dynamic> toJson() => {
        'step_execution_id': stepExecutionId,
        'execution_status': executionStatus,
        'execution_timestamp': executionTimestamp.toIso8601String(),
        'step_outcome': stepOutcome,
        'user_id': userId,
        'active_ratio': activeRatio.name,
      };
}

/// Mock repository for local telemetry sync.
class MockTelemetryRepository {
  static final List<PanelViewMetric> _metrics = [];

  static void logMetric(PanelViewMetric metric) {
    _metrics.add(metric);
    // In production, sync to GCP/BigQuery here.
  }

  static List<PanelViewMetric> get metrics => List.unmodifiable(_metrics);
}

/// The unified layout container component implementing the mobile split-screen.
class SplitScreenContextualMirror extends StatefulWidget {
  final Widget evidencePanel;
  final Widget actionPanel;
  final Orientation? forcedOrientation;

  const SplitScreenContextualMirror({
    super.key,
    required this.evidencePanel,
    required this.actionPanel,
    this.forcedOrientation,
  });

  @override
  State<SplitScreenContextualMirror> createState() => _SplitScreenContextualMirrorState();
}

class _SplitScreenContextualMirrorState extends State<SplitScreenContextualMirror>
    with SingleTickerProviderStateMixin
    implements MasterSplitLayoutWrapper {
  late AnimationController _animationController;
  late Animation<double> _ratioAnimation;

  final List<SplitRatio> _ratios = SplitRatio.values;
  int _currentRatioIndex = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _ratioAnimation = Tween<double>(
      begin: _ratios[0].ratio,
      end: _ratios[0].ratio,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic, // Clean touch physics
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onDoubleTap() {
    HapticFeedback.lightImpact();
    setState(() {
      _currentRatioIndex = (_currentRatioIndex + 1) % _ratios.length;
      _ratioAnimation = Tween<double>(
        begin: _ratioAnimation.value,
        end: _ratios[_currentRatioIndex].ratio,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ));
      _animationController.forward(from: 0.0);
    });

    // Log mock telemetry
    MockTelemetryRepository.logMetric(PanelViewMetric(
      stepExecutionId: 'SSTLA-012-A03-EXEC-001',
      executionStatus: 'SUCCESS',
      executionTimestamp: DateTime.now(),
      stepOutcome: 'RATIO_CHANGED',
      userId: 'MOCK_USER_01',
      activeRatio: _ratios[_currentRatioIndex],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final orientation = widget.forcedOrientation ?? MediaQuery.of(context).orientation;
        final isLandscape = orientation == Orientation.landscape;

        return GestureDetector(
          onDoubleTap: _onDoubleTap,
          behavior: HitTestBehavior.translucent,
          child: AnimatedBuilder(
            animation: _ratioAnimation,
            builder: (context, child) {
              final ratio = _ratioAnimation.value;
              if (isLandscape) {
                return Row(
                  children: [
                    _buildBorderedPanel(
                      flex: (ratio * 1000).toInt(),
                      child: widget.evidencePanel,
                      isLeftOrTop: true,
                    ),
                    _buildSplitter(isVertical: true),
                    _buildBorderedPanel(
                      flex: ((1 - ratio) * 1000).toInt(),
                      child: widget.actionPanel,
                      isLeftOrTop: false,
                    ),
                  ],
                );
              } else {
                return Column(
                  children: [
                    _buildBorderedPanel(
                      flex: (ratio * 1000).toInt(),
                      child: widget.evidencePanel,
                      isLeftOrTop: true,
                    ),
                    _buildSplitter(isVertical: false),
                    _buildBorderedPanel(
                      flex: ((1 - ratio) * 1000).toInt(),
                      child: widget.actionPanel,
                      isLeftOrTop: false,
                    ),
                  ],
                );
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildBorderedPanel({
    required int flex,
    required Widget child,
    required bool isLeftOrTop,
  }) {
    return Expanded(
      flex: flex,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: 1.0,
          ),
          color: Theme.of(context).colorScheme.surface,
        ),
        child: ClipRect(child: child),
      ),
    );
  }

  Widget _buildSplitter({required bool isVertical}) {
    return Container(
      width: isVertical ? 4.0 : double.infinity,
      height: isVertical ? double.infinity : 4.0,
      color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
    );
  }
}

/// Wrapper to use AnimatedBuilder since Flutter uses AnimatedBuilder internally via AnimatedWidget or similar.
/// Using standard AnimatedBuilder pattern.
class AnimatedBuilder extends StatelessWidget {
  final Animation<double> animation;
  final Widget Function(BuildContext context, Widget? child) builder;
  final Widget? child;

  const AnimatedBuilder({
    super.key,
    required this.animation,
    required this.builder,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilderInternal(
      animation: animation,
      builder: builder,
      child: child,
    );
  }
}

class AnimatedBuilderInternal extends AnimatedWidget {
  final Widget Function(BuildContext context, Widget? child) builder;
  final Widget? child;

  const AnimatedBuilderInternal({
    super.key,
    required Animation<double> animation,
    required this.builder,
    this.child,
  }) : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    return builder(context, child);
  }
}

/// Example Action Panel identifying data entry forms and approval/rejection triggers.
class MockActionPanel extends StatelessWidget {
  const MockActionPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Action Panel', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Evidence Reference ID',
              border: OutlineInputBorder(),
            ),
          ),
          const Spacer(),
          // Anchored safely along lower viewport limits
          SafeArea(
            top: false,
            child: Row(
              children: [
                Expanded(
                  child: FilledButton.tonal(
                    onPressed: () {},
                    child: const Text('Reject'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () {},
                    child: const Text('Approve'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Example Evidence Panel.
class MockEvidencePanel extends StatelessWidget {
  const MockEvidencePanel({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: 20,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8.0),
          child: ListTile(
            title: Text('Evidence Item ${index + 1}'),
            subtitle: const Text('Contextual data payload'),
          ),
        );
      },
    );
  }
}
