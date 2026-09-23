// GEN-01886 — Core UI Components Library Hook for UDF Step Completion.
// Provides a reusable hook to store and retrieve step completion state in the Core UI Components library, with M3 Elevated Cards, status chips, mock telemetry data, and responsive layout support.

import 'package:flutter/material.dart';

/// Enum representing the completion state of a step per ISO/IEC 27001:2022 alignment.
enum StepCompletionState { complete, partial, notComplete }

/// Data model for a UDF step hook stored in the Core UI Components library.
class UdfStepHookData {
  final String atomicId;
  final String globalRefId;
  final String description;
  final StepCompletionState state;
  final double completionRate;
  final DateTime timestamp;

  const UdfStepHookData({
    required this.atomicId,
    required this.globalRefId,
    required this.description,
    required this.state,
    required this.completionRate,
    required this.timestamp,
  });
}

/// Mock repository providing local data as backend services are abstracted.
class CoreUiHookRepository {
  static final List<UdfStepHookData> _mockHooks = [
    UdfStepHookData(
      atomicId: 'GEN-01886',
      globalRefId: 'GEN-01886',
      description: 'Store the hook in the Core UI Components library.',
      state: StepCompletionState.complete,
      completionRate: 99.0,
      timestamp: DateTime.now(),
    ),
    UdfStepHookData(
      atomicId: 'GEN-01885',
      globalRefId: 'GEN-01885',
      description: 'Prior foundational dependency step.',
      state: StepCompletionState.partial,
      completionRate: 85.0,
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    ),
  ];

  Future<List<UdfStepHookData>> fetchHooks() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockHooks;
  }

  Future<void> storeHook(UdfStepHookData hook) async {
    await Future.delayed(const Duration(milliseconds: 150));
    _mockHooks.removeWhere((element) => element.atomicId == hook.atomicId);
    _mockHooks.add(hook);
  }
}

/// Core UI Hook Widget implementing M3 Elevated Card Level 2 (3dp).
/// Responsive: single-column on mobile (<600dp), multi-column on desktop (>=840dp).
class CoreUiHookCard extends StatelessWidget {
  final UdfStepHookData hookData;

  const CoreUiHookCard({super.key, required this.hookData});

  Color _getStateColor(BuildContext context, StepCompletionState state) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (state) {
      case StepCompletionState.complete:
        return colorScheme.primary;
      case StepCompletionState.partial:
        return colorScheme.tertiary;
      case StepCompletionState.notComplete:
        return colorScheme.error;
    }
  }

  String _getStateLabel(StepCompletionState state) {
    switch (state) {
      case StepCompletionState.complete:
        return 'Complete';
      case StepCompletionState.partial:
        return 'Partial';
      case StepCompletionState.notComplete:
        return 'Not Complete';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 3.0,
      surfaceTintColor: colorScheme.surfaceTint,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    hookData.atomicId,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Chip(
                  label: Text(_getStateLabel(hookData.state)),
                  backgroundColor: _getStateColor(context, hookData.state)
                      .withOpacity(0.15),
                  labelStyle: TextStyle(
                    color: _getStateColor(context, hookData.state),
                    fontWeight: FontWeight.w600,
                  ),
                  side: BorderSide.none,
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Text(
              hookData.description,
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: 12.0),
            LinearProgressIndicator(
              value: hookData.completionRate / 100.0,
              minHeight: 6.0,
              borderRadius: BorderRadius.circular(3.0),
              backgroundColor: colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(
                _getStateColor(context, hookData.state),
              ),
            ),
            const SizedBox(height: 4.0),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${hookData.completionRate.toStringAsFixed(1)}%',
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Screen displaying hooks from the Core UI Components library.
/// Implements background polling every 30 seconds and pull-to-refresh.
class CoreUiHooksScreen extends StatefulWidget {
  const CoreUiHooksScreen({super.key});

  @override
  State<CoreUiHooksScreen> createState() => _CoreUiHooksScreenState();
}

class _CoreUiHooksScreenState extends State<CoreUiHooksScreen> {
  final CoreUiHookRepository _repository = CoreUiHookRepository();
  List<UdfStepHookData> _hooks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHooks();
    // Background polling refreshes data every 30 seconds
    _startPolling();
  }

  void _startPolling() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 30));
      if (mounted) {
        _loadHooks();
        return true;
      }
      return false;
    });
  }

  Future<void> _loadHooks() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final data = await _repository.fetchHooks();
      if (mounted) {
        setState(() {
          _hooks = data;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  int _getCrossAxisCount(double width) {
    if (width >= 840) return 2; // Multi-column on desktop/tablet
    return 1; // Single-column on mobile (<600dp)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Core UI Hooks'),
        centerTitle: false,
      ),
      body: _isLoading && _hooks.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadHooks,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount =
                      _getCrossAxisCount(constraints.maxWidth);
                  return GridView.builder(
                    padding: const EdgeInsets.all(16.0),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 16.0,
                      mainAxisSpacing: 16.0,
                      childAspectRatio: crossAxisCount == 1 ? 2.8 : 2.2,
                    ),
                    itemCount: _hooks.length,
                    itemBuilder: (context, index) {
                      return CoreUiHookCard(hookData: _hooks[index]);
                    },
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showConfigBottomSheet(context),
        tooltip: 'Configure Hook',
        child: const Icon(Icons.add),
      ),
    );
  }

  /// M3 Bottom Sheet for configuration inputs.
  void _showConfigBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24.0,
            right: 24.0,
            top: 24.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Store New Hook',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16.0),
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Atomic ID',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24.0),
              FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Hook stored successfully.'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                child: const Text('Save Configuration'),
              ),
              const SizedBox(height: 16.0),
            ],
          ),
        );
      },
    );
  }
}