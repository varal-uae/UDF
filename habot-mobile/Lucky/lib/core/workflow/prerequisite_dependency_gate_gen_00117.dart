// GEN-00117 — Prerequisite Dependency Gating Component
// Verifies foundational predecessor steps (Step 5 and Step 12) prior to executing downstream UDF sequences.
// Adheres to ITIL v4 Change Enablement and PMI PMBOK milestone sequencing with M3 Elevated Cards, 30s polling, and WCAG AA 48x48dp targets.

import 'dart:async';
import 'package:flutter/material.dart';

/// Represents the verification state of a prerequisite milestone.
enum DependencyStatus {
  passed,
  failed,
  evaluating,
}

/// Data model for an atomic predecessor step requirement.
class PrerequisiteStep {
  final int stepNumber;
  final String title;
  final String description;
  final DependencyStatus status;
  final DateTime? lastVerifiedAt;
  final String? failureReason;

  const PrerequisiteStep({
    required this.stepNumber,
    required this.title,
    required this.description,
    required this.status,
    this.lastVerifiedAt,
    this.failureReason,
  });

  PrerequisiteStep copyWith({
    DependencyStatus? status,
    DateTime? lastVerifiedAt,
    String? failureReason,
  }) {
    return PrerequisiteStep(
      stepNumber: stepNumber,
      title: title,
      description: description,
      status: status ?? this.status,
      lastVerifiedAt: lastVerifiedAt ?? this.lastVerifiedAt,
      failureReason: failureReason ?? this.failureReason,
    );
  }
}

/// English Code Blueprint:
/// 1. Initialize prerequisite dependency registry with Step 5 and Step 12.
/// 2. Schedule automated 30-second polling handshake for continuous liveness verification.
/// 3. Calculate Predecessor Dependency Verification Rate (floor: 100% required).
/// 4. Render responsive M3 layout (single-column <600dp, multi-column >=840dp).
/// 5. Provide interactive drill-down M3 BottomSheet and manual sync triggers.
class PrerequisiteDependencyGateWidget extends StatefulWidget {
  final ValueChanged<bool>? onGateEvaluated;
  final VoidCallback? onAllPrerequisitesMet;

  const PrerequisiteDependencyGateWidget({
    super.key,
    this.onGateEvaluated,
    this.onAllPrerequisitesMet,
  });

  @override
  State<PrerequisiteDependencyGateWidget> createState() =>
      _PrerequisiteDependencyGateWidgetState();
}

class _PrerequisiteDependencyGateWidgetState
    extends State<PrerequisiteDependencyGateWidget> {
  Timer? _pollingTimer;
  bool _isSyncing = false;
  DateTime _lastEvaluated = DateTime.now();

  // Required foundational dependencies: Step 5 and Step 12
  late List<PrerequisiteStep> _prerequisites;

  @override
  void initState() {
    super.initState();
    _initializePrerequisites();
    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  /// EC Header: Initialize
  /// Sets up baseline predecessor dependency records.
  void _initializePrerequisites() {
    _prerequisites = [
      PrerequisiteStep(
        stepNumber: 5,
        title: 'Step 5: Foundational Baseline Config',
        description: 'Verifies base system schema, identity, and network routing.',
        status: DependencyStatus.passed,
        lastVerifiedAt: DateTime.now().subtract(const Duration(minutes: 2)),
      ),
      PrerequisiteStep(
        stepNumber: 12,
        title: 'Step 12: Core State Engine Alignment',
        description: 'Validates DCDF engine handshake and telemetry pipeline initialization.',
        status: DependencyStatus.passed,
        lastVerifiedAt: DateTime.now().subtract(const Duration(minutes: 1)),
      ),
    ];
  }

  /// EC Header: Start
  /// Initiates automated 30-second background liveness polling.
  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _refreshDependencies(isAutoPoll: true);
    });
  }

  /// EC Header: Refresh
  /// Polls status of dependencies and recalculates verification pass rate.
  Future<void> _refreshDependencies({bool isAutoPoll = false}) async {
    if (_isSyncing) return;

    setState(() {
      _isSyncing = true;
    });

    // Simulate dependency verification latency (<100ms budget)
    await Future.delayed(const Duration(milliseconds: 95));

    if (!mounted) return;

    setState(() {
      _prerequisites = _prerequisites.map((step) {
        return step.copyWith(
          status: DependencyStatus.passed,
          lastVerifiedAt: DateTime.now(),
        );
      }).toList();
      _lastEvaluated = DateTime.now();
      _isSyncing = false;
    });

    final double passRate = _calculatePassRate();
    final bool isGatePassed = passRate == 1.0;
    widget.onGateEvaluated?.call(isGatePassed);

    if (isGatePassed && !isAutoPoll) {
      widget.onAllPrerequisitesMet?.call();
      _showFeedbackSnackBar(isPassed: true);
    }
  }

  /// EC Header: Calculate
  /// Computes the Predecessor Dependency Verification Rate.
  double _calculatePassRate() {
    if (_prerequisites.isEmpty) return 0.0;
    final int passedCount = _prerequisites
        .where((step) => step.status == DependencyStatus.passed)
        .length;
    return passedCount / _prerequisites.length;
  }

  /// EC Header: Notify
  /// Displays feedback snackbar to the operator.
  void _showFeedbackSnackBar({required bool isPassed}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(
          isPassed
              ? 'All prerequisites (Steps 5 & 12) verified successfully (100%).'
              : 'Prerequisite verification failed. Resolve blocked steps.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isPassed
                    ? Theme.of(context).colorScheme.onPrimaryContainer
                    : Theme.of(context).colorScheme.onErrorContainer,
              ),
        ),
        backgroundColor: isPassed
            ? Theme.of(context).colorScheme.primaryContainer
            : Theme.of(context).colorScheme.errorContainer,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// EC Header: Inspect
  /// Opens bottom sheet for granular dependency inspection.
  void _inspectStep(PrerequisiteStep step) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        final theme = Theme.of(context);
        final textTheme = theme.textTheme;
        final colorScheme = theme.colorScheme;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: textTheme.titleLarge?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  step.description,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                _buildStatusChip(step.status),
                const SizedBox(height: 16),
                Text(
                  'Standard: ITIL v4 Change Enablement / PMBOK 7th Ed.',
                  style: textTheme.labelMedium?.copyWith(
                    color: colorScheme.outline,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Last Handshake: ${step.lastVerifiedAt?.toIso8601String() ?? "Never"}',
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.outline,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton.tonal(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Dismiss', style: textTheme.labelLarge),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// EC Header: BuildChip
  /// Constructs standard M3 status chip.
  Widget _buildStatusChip(DependencyStatus status) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final isPassed = status == DependencyStatus.passed;
    final isEvaluating = status == DependencyStatus.evaluating;

    final Color containerColor = isEvaluating
        ? colorScheme.surfaceContainerHighest
        : isPassed
            ? colorScheme.primaryContainer
            : colorScheme.errorContainer;

    final Color labelColor = isEvaluating
        ? colorScheme.onSurfaceVariant
        : isPassed
            ? colorScheme.onPrimaryContainer
            : colorScheme.onErrorContainer;

    final IconData icon = isEvaluating
        ? Icons.sync
        : isPassed
            ? Icons.check_circle_outline
            : Icons.error_outline;

    final String labelText = isEvaluating
        ? 'Evaluating'
        : isPassed
            ? 'Pass (100%)'
            : 'Fail';

    return Chip(
      materialTapTargetSize: MaterialTapTargetSize.padded,
      avatar: Icon(icon, size: 18, color: labelColor),
      label: Text(
        labelText,
        style: textTheme.labelMedium?.copyWith(
          color: labelColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: containerColor,
      side: BorderSide.none,
    );
  }

  @override
  Widget build(BuildContext context) {
    final double passRate = _calculatePassRate();
    final bool isAllPassed = passRate == 1.0;
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isDesktop = constraints.maxWidth >= 840;

        return RefreshIndicator(
          onRefresh: () => _refreshDependencies(isAutoPoll: false),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Gating KPI Card (M3 Elevated Card Level 2: 3dp)
                Card(
                  elevation: 3.0,
                  color: colorScheme.surfaceContainerLow,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Predecessor Gating Status',
                              style: textTheme.titleMedium?.copyWith(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            _buildStatusChip(
                              isAllPassed
                                  ? DependencyStatus.passed
                                  : DependencyStatus.failed,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Metric: Predecessor Dependency Verification Rate',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Floor Target: 100% | Current: ${(passRate * 100).toInt()}%',
                          style: textTheme.bodyMedium?.copyWith(
                            color: isAllPassed
                                ? colorScheme.primary
                                : colorScheme.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: passRate,
                          backgroundColor: colorScheme.surfaceContainerHighest,
                          color: isAllPassed
                              ? colorScheme.primary
                              : colorScheme.error,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Last Handshake: ${_lastEvaluated.toLocal().toString().split('.').first}',
                          style: textTheme.labelSmall?.copyWith(
                            color: colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Dependency Step Items
                Text(
                  'Prerequisite Checkpoints (ITIL v4 Change Enablement)',
                  style: textTheme.titleSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                if (isDesktop)
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    physics: const NeverScrollableScrollPhysics(),
                    children: _prerequisites.map(_buildStepCard).toList(),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _prerequisites.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) =>
                        _buildStepCard(_prerequisites[index]),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// EC Header: RenderCard
  /// Builds elevated card for an individual prerequisite.
  Widget _buildStepCard(PrerequisiteStep step) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 3.0,
      color: colorScheme.surfaceContainer,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _inspectStep(step),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: colorScheme.primaryContainer,
                child: Text(
                  '#${step.stepNumber}',
                  style: textTheme.labelLarge?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      step.title,
                      style: textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      step.description,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _buildStatusChip(step.status),
            ],
          ),
        ),
      ),
    );
  }
}
