// GEN-03827 — SAF-T / FEC XML Model Generation Status Card.
// M3 Elevated Card displaying step completion state, generation speed metrics, and health indicators for the engineering console dashboard.

import 'package:flutter/material.dart';

/// Mock data model representing a SAF-T XML generation step.
class SaftGenerationStep {
  final String atomicId;
  final String description;
  final bool isCompleted;
  final double generationSpeedSeconds;
  final DateTime timestamp;

  const SaftGenerationStep({
    required this.atomicId,
    required this.description,
    required this.isCompleted,
    required this.generationSpeedSeconds,
    required this.timestamp,
  });
}

/// Realistic local mock data for BigQuery SAF-T XML generation models.
const List<SaftGenerationStep> kMockSaftSteps = [
  SaftGenerationStep(
    atomicId: 'GEN-03827',
    description: 'Build standardized SAF-T / FEC XML file generation models in BigQuery.',
    isCompleted: true,
    generationSpeedSeconds: 4.2,
    timestamp: DateTime(2026, 9, 28, 10, 15, 0),
  ),
  SaftGenerationStep(
    atomicId: 'GEN-03826',
    description: 'Prior foundational configuration step.',
    isCompleted: true,
    generationSpeedSeconds: 2.1,
    timestamp: DateTime(2026, 9, 28, 10, 10, 0),
  ),
];

/// M3 Elevated Card (Level 2, 3dp) displaying SAF-T XML generation status.
/// Implements single-column mobile layout (<600dp) and multi-column desktop (>=840dp).
/// Touch targets are minimum 48x48dp. Includes deep-link drill-down capability.
class SaftXmlStatusCardGen03827 extends StatelessWidget {
  final SaftGenerationStep step;
  final VoidCallback? onDrillDown;

  const SaftXmlStatusCardGen03827({
    super.key,
    required this.step,
    this.onDrillDown,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;

    final bool isOptimal = step.generationSpeedSeconds < 5.0;
    final bool isWithinFloor = step.generationSpeedSeconds < 30.0;
    final bool isFailed = !step.isCompleted || step.generationSpeedSeconds >= 60.0;

    final Color chipColor = isFailed
        ? colorScheme.errorContainer
        : isOptimal
            ? colorScheme.primaryContainer
            : isWithinFloor
                ? colorScheme.tertiaryContainer
                : colorScheme.secondaryContainer;

    final Color chipTextColor = isFailed
        ? colorScheme.onErrorContainer
        : isOptimal
            ? colorScheme.onPrimaryContainer
            : isWithinFloor
                ? colorScheme.onTertiaryContainer
                : colorScheme.onSecondaryContainer;

    final String statusLabel = isFailed
        ? 'Fail'
        : step.isCompleted
            ? 'Pass'
            : 'Pending';

    return Semantics(
      label: 'SAF-T XML Generation Step ${step.atomicId}, Status: $statusLabel',
      child: Card(
        elevation: 3.0, // M3 Elevated Cards Level 2 (3dp)
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onDrillDown,
          customBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        step.atomicId,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    // M3 Status Chip for health indicator
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 6.0,
                      ),
                      decoration: BoxDecoration(
                        color: chipColor,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(
                        statusLabel,
                        style: textTheme.labelLarge?.copyWith(
                          color: chipTextColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12.0),
                Text(
                  step.description,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _MetricTile(
                      label: 'Generation Speed',
                      value: '${step.generationSpeedSeconds.toStringAsFixed(1)}s',
                      isOptimal: isOptimal,
                      theme: theme,
                    ),
                    _MetricTile(
                      label: 'Target',
                      value: '< 5.0s',
                      isOptimal: true,
                      theme: theme,
                    ),
                    _MetricTile(
                      label: 'Floor',
                      value: '< 30.0s',
                      isOptimal: isWithinFloor,
                      theme: theme,
                    ),
                  ],
                ),
                if (onDrillDown != null) ...[
                  const SizedBox(height: 12.0),
                  Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      height: 48.0, // 48x48dp touch target
                      width: 48.0,
                      child: IconButton(
                        onPressed: onDrillDown,
                        icon: Icon(
                          Icons.arrow_forward_rounded,
                          color: colorScheme.primary,
                        ),
                        tooltip: 'Drill down into step details',
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final bool isOptimal;
  final ThemeData theme;

  const _MetricTile({
    required this.label,
    required this.value,
    required this.isOptimal,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4.0),
        Text(
          value,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: isOptimal
                ? theme.colorScheme.primary
                : theme.colorScheme.error,
          ),
        ),
      ],
    );
  }
}

/// Dashboard screen demonstrating the single-column mobile layout
/// and background polling refresh pattern.
class SaftEngineeringConsoleScreenGen03827 extends StatefulWidget {
  const SaftEngineeringConsoleScreenGen03827({super.key});

  @override
  State<SaftEngineeringConsoleScreenGen03827> createState() =>
      _SaftEngineeringConsoleScreenStateGen03827();
}

class _SaftEngineeringConsoleScreenStateGen03827
    extends State<SaftEngineeringConsoleScreenGen03827> {
  late List<SaftGenerationStep> _steps;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _steps = kMockSaftSteps;
    _startPolling();
  }

  void _startPolling() {
    // Background polling refreshes data every 30 seconds
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted) {
        _refreshData();
        _startPolling();
      }
    });
  }

  Future<void> _refreshData() async {
    setState(() => _isRefreshing = true);
    // Simulate network fetch with mock data
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      setState(() {
        _isRefreshing = false;
        _steps = kMockSaftSteps;
      });
    }
  }

  void _showDrillDownBottomSheet(SaftGenerationStep step) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Configuration Details',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16.0),
                Text('Atomic ID: ${step.atomicId}'),
                Text('Description: ${step.description}'),
                Text('Speed: ${step.generationSpeedSeconds}s'),
                Text('Status: ${step.isCompleted ? "Pass" : "Fail"}'),
                const SizedBox(height: 24.0),
                SizedBox(
                  width: double.infinity,
                  height: 48.0, // 48x48dp touch target
                  child: FilledButton(
                    onPressed: () {
                      Navigator.pop(context);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Configuration saved successfully.'),
                            behavior: SnackBarBehavior.floating,
                            action: SnackBarAction(
                              label: 'DISMISS',
                              onPressed: () {},
                            ),
                          ),
                        );
                      }
                    },
                    child: const Text('Apply Configuration'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Engineering Console'),
        centerTitle: false,
        actions: [
          if (_isRefreshing)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20.0,
                height: 20.0,
                child: CircularProgressIndicator(strokeWidth: 2.0),
              ),
            )
          else
            IconButton(
              onPressed: _refreshData,
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'Manual Sync',
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final bool isDesktop = constraints.maxWidth >= 840;

            if (isDesktop) {
              // Multi-column on desktop (>=840dp)
              return GridView.builder(
                padding: const EdgeInsets.all(16.0),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 420.0,
                  mainAxisSpacing: 16.0,
                  crossAxisSpacing: 16.0,
                  childAspectRatio: 1.4,
                ),
                itemCount: _steps.length,
                itemBuilder: (BuildContext context, int index) {
                  return SaftXmlStatusCardGen03827(
                    step: _steps[index],
                    onDrillDown: () => _showDrillDownBottomSheet(_steps[index]),
                  );
                },
              );
            }

            // Single-column mobile layout (<600dp)
            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              itemCount: _steps.length,
              itemBuilder: (BuildContext context, int index) {
                return SaftXmlStatusCardGen03827(
                  step: _steps[index],
                  onDrillDown: () => _showDrillDownBottomSheet(_steps[index]),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
