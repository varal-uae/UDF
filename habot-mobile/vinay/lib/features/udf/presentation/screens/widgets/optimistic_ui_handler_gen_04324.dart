// GEN-04324 — Optimistic UI State Updates with Rollback Capabilities.
// Implements a reusable optimistic update handler that applies state changes immediately and rolls back on failure, using M3 Elevated Cards and Status Chips for health indicators.

import 'dart:async';
import 'package:flutter/material.dart';

/// Represents the qualitative health status of an operation.
enum StepHealthStatus { good, average, poor }

/// Data model representing a single step's state in the UDF pipeline.
class StepStateData {
  final String traceId;
  final String title;
  final bool isCompleted;
  final StepHealthStatus health;
  final DateTime lastUpdated;

  const StepStateData({
    required this.traceId,
    required this.title,
    required this.isCompleted,
    required this.health,
    required this.lastUpdated,
  });

  StepStateData copyWith({
    String? traceId,
    String? title,
    bool? isCompleted,
    StepHealthStatus? health,
    DateTime? lastUpdated,
  }) {
    return StepStateData(
      traceId: traceId ?? this.traceId,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      health: health ?? this.health,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

/// Mock repository simulating backend API calls with realistic latency.
class MockStepRepository {
  static final List<StepStateData> _mockSteps = [
    StepStateData(
      traceId: 'trace_001',
      title: 'Initialize DCDF Engine',
      isCompleted: true,
      health: StepHealthStatus.good,
      lastUpdated: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    StepStateData(
      traceId: 'trace_002',
      title: 'Configure GCP BigQuery Stream',
      isCompleted: false,
      health: StepHealthStatus.average,
      lastUpdated: DateTime.now().subtract(const Duration(minutes: 2)),
    ),
    StepStateData(
      traceId: 'trace_003',
      title: 'Validate M3 Accessibility Compliance',
      isCompleted: false,
      health: StepHealthStatus.poor,
      lastUpdated: DateTime.now(),
    ),
  ];

  Future<List<StepStateData>> fetchSteps() async {
    await Future.delayed(const Duration(milliseconds: 80)); // Sub-100ms simulation
    return List.unmodifiable(_mockSteps);
  }

  Future<bool> updateStep(String traceId, bool isCompleted) async {
    await Future.delayed(const Duration(milliseconds: 150));
    // Simulate random failure to demonstrate rollback capability
    if (DateTime.now().millisecond % 5 == 0) {
      throw Exception('Simulated backend failure for traceId: $traceId');
    }
    final index = _mockSteps.indexWhere((s) => s.traceId == traceId);
    if (index != -1) {
      _mockSteps[index] = _mockSteps[index].copyWith(
        isCompleted: isCompleted,
        health: isCompleted ? StepHealthStatus.good : StepHealthStatus.average,
        lastUpdated: DateTime.now(),
      );
    }
    return true;
  }
}

/// Core optimistic UI controller handling state updates and rollbacks.
class OptimisticUiController extends ChangeNotifier {
  final MockStepRepository _repository;
  List<StepStateData> _steps = [];
  bool _isLoading = false;
  Timer? _pollingTimer;
  Timer? _livenessTimer;

  OptimisticUiController({MockStepRepository? repository})
      : _repository = repository ?? MockStepRepository();

  List<StepStateData> get steps => List.unmodifiable(_steps);
  bool get isLoading => _isLoading;

  void initialize() {
    refreshData();
    // Background polling every 30 seconds
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      refreshData();
    });

    // Automated Liveness Handshake every 30 seconds
    _livenessTimer?.cancel();
    _livenessTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _performLivenessCheck();
    });
  }

  Future<void> refreshData() async {
    _isLoading = true;
    notifyListeners();
    try {
      _steps = await _repository.fetchSteps();
    } catch (e) {
      debugPrint('GEN-04324: Failed to refresh data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Applies optimistic update immediately, rolls back on failure.
  Future<void> toggleStepCompletion(String traceId, BuildContext context) async {
    final index = _steps.indexWhere((s) => s.traceId == traceId);
    if (index == -1) return;

    final originalStep = _steps[index];
    final optimisticStep = originalStep.copyWith(
      isCompleted: !originalStep.isCompleted,
      health: !originalStep.isCompleted ? StepHealthStatus.good : StepHealthStatus.average,
      lastUpdated: DateTime.now(),
    );

    // Apply optimistic state
    _steps[index] = optimisticStep;
    notifyListeners();

    try {
      await _repository.updateStep(traceId, optimisticStep.isCompleted);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Step ${optimisticStep.isCompleted ? "completed" : "reverted"} successfully.'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Rollback on failure
      _steps[index] = originalStep;
      notifyListeners();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Update failed. State rolled back.'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _performLivenessCheck() {
    // Simulated liveness handshake logic
    debugPrint('GEN-04324: Liveness handshake executed at ${DateTime.now()}');
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _livenessTimer?.cancel();
    super.dispose();
  }
}

/// M3 Responsive Widget rendering the optimistic UI step list.
class OptimisticUiHandlerGen04324 extends StatefulWidget {
  const OptimisticUiHandlerGen04324({super.key});

  @override
  State<OptimisticUiHandlerGen04324> createState() => _OptimisticUiHandlerGen04324State();
}

class _OptimisticUiHandlerGen04324State extends State<OptimisticUiHandlerGen04324> {
  late final OptimisticUiController _controller;

  @override
  void initState() {
    super.initState();
    _controller = OptimisticUiController();
    _controller.initialize();
    _controller.addListener(_onStateChanged);
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onStateChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 840;

    return Scaffold(
      appBar: AppBar(
        title: const Text('UDF Engineering Console'),
        centerTitle: false,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _controller.refreshData,
        child: _controller.isLoading && _controller.steps.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = isDesktop ? 2 : 1;
                  return GridView.builder(
                    padding: const EdgeInsets.all(16.0),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: 16.0,
                      crossAxisSpacing: 16.0,
                      childAspectRatio: isDesktop ? 3.5 : 4.0,
                    ),
                    itemCount: _controller.steps.length,
                    itemBuilder: (context, index) {
                      final step = _controller.steps[index];
                      return _StepCard(
                        step: step,
                        onToggle: () => _controller.toggleStepCompletion(step.traceId, context),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
}

/// M3 Elevated Card Level 2 (3dp) with inline Status Chip.
class _StepCard extends StatelessWidget {
  final StepStateData step;
  final VoidCallback onToggle;

  const _StepCard({
    required this.step,
    required this.onToggle,
  });

  Color _getHealthColor(ColorScheme colorScheme) {
    switch (step.health) {
      case StepHealthStatus.good:
        return colorScheme.primary;
      case StepHealthStatus.average:
        return colorScheme.tertiary;
      case StepHealthStatus.poor:
        return colorScheme.error;
    }
  }

  String _getHealthLabel() {
    switch (step.health) {
      case StepHealthStatus.good:
        return 'Good';
      case StepHealthStatus.average:
        return 'Average';
      case StepHealthStatus.poor:
        return 'Poor';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final healthColor = _getHealthColor(colorScheme);

    return Card(
      elevation: 3.0, // M3 Elevated Cards Level 2 (3dp)
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: InkWell(
        onTap: onToggle,
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // 48x48dp touch target checkbox
              SizedBox(
                width: 48.0,
                height: 48.0,
                child: Checkbox(
                  value: step.isCompleted,
                  onChanged: (_) => onToggle(),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      step.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        decoration: step.isCompleted ? TextDecoration.lineThrough : null,
                        color: step.isCompleted ? colorScheme.outline : colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      'Trace: ${step.traceId}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              // M3 Status Chip for health indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                decoration: BoxDecoration(
                  color: healthColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(color: healthColor.withOpacity(0.5)),
                ),
                child: Text(
                  _getHealthLabel(),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: healthColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}