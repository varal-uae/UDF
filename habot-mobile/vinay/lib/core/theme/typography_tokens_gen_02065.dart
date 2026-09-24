// GEN-02065 — Global Typography Tokens for Design System.
// Stores typography tokens globally using Material 3 standards with M3 Elevated Cards, Status Chips, and responsive single/multi-column layouts.

import 'package:flutter/material.dart';

/// Global typography tokens stored for the UDF Design System.
class TypographyTokensGen02065 {
  TypographyTokensGen02065._();

  static const String metricName = 'Typography Token Coverage (%)';
  static const int floorBoundary = 85;
  static const int optimalTarget = 100;
  static const int ceilingBoundary = 100;
  static const String qualitativeOutputType = 'ISO/IEC 25010:2023 & Typography Performance Guidelines';

  /// Returns the global TextTheme configured with M3 standards.
  static TextTheme get textTheme => const TextTheme(
        displayLarge: TextStyle(fontSize: 57, fontWeight: FontWeight.w400, letterSpacing: -0.25, height: 1.12),
        displayMedium: TextStyle(fontSize: 45, fontWeight: FontWeight.w400, letterSpacing: 0.0, height: 1.16),
        displaySmall: TextStyle(fontSize: 36, fontWeight: FontWeight.w400, letterSpacing: 0.0, height: 1.22),
        headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w400, letterSpacing: 0.0, height: 1.25),
        headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w400, letterSpacing: 0.0, height: 1.29),
        headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w400, letterSpacing: 0.0, height: 1.33),
        titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w500, letterSpacing: 0.0, height: 1.27),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, letterSpacing: 0.15, height: 1.50),
        titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1, height: 1.43),
        bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: 0.5, height: 1.50),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: 0.25, height: 1.43),
        bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 0.4, height: 1.33),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1, height: 1.43),
        labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.5, height: 1.33),
        labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.5, height: 1.45),
      );
}

/// Mock data model representing a step's completion state.
class StepCompletionDataGen02065 {
  final String atomicId;
  final String description;
  final String status; // Complete, Partial, Not Complete
  final double coveragePercentage;
  final DateTime timestamp;

  const StepCompletionDataGen02065({
    required this.atomicId,
    required this.description,
    required this.status,
    required this.coveragePercentage,
    required this.timestamp,
  });
}

/// Mock repository providing local telemetry and step data.
class MockTelemetryRepositoryGen02065 {
  static List<StepCompletionDataGen02065> fetchSteps() {
    return [
      StepCompletionDataGen02065(
        atomicId: 'GEN-02065',
        description: 'Store the typography tokens globally in the Design System.',
        status: 'Complete',
        coveragePercentage: 100.0,
        timestamp: DateTime.now(),
      ),
      StepCompletionDataGen02065(
        atomicId: 'GEN-02064',
        description: 'Prior foundational dependency step.',
        status: 'Complete',
        coveragePercentage: 95.0,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      ),
    ];
  }
}

/// Engineering Console Screen displaying M3 KPI cards with deep-link drill-down.
/// Responsive layout: single-column on mobile (<600dp), multi-column on desktop (>=840dp).
class TypographyConsoleScreenGen02065 extends StatefulWidget {
  const TypographyConsoleScreenGen02065({super.key});

  @override
  State<TypographyConsoleScreenGen02065> createState() => _TypographyConsoleScreenGen02065State();
}

class _TypographyConsoleScreenGen02065State extends State<TypographyConsoleScreenGen02065> {
  late List<StepCompletionDataGen02065> _steps;
  bool _isPolling = true;

  @override
  void initState() {
    super.initState();
    _loadData();
    _startPolling();
  }

  void _loadData() {
    setState(() {
      _steps = MockTelemetryRepositoryGen02065.fetchSteps();
    });
  }

  void _startPolling() {
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted && _isPolling) {
        _loadData();
        _startPolling();
      }
    });
  }

  @override
  void dispose() {
    _isPolling = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Engineering Console - Typography Tokens'),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadData();
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 600;
            final crossAxisCount = isMobile ? 1 : (constraints.maxWidth >= 840 ? 3 : 2);

            return GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 16.0,
                crossAxisSpacing: 16.0,
                childAspectRatio: isMobile ? 2.5 : 2.0,
              ),
              itemCount: _steps.length,
              itemBuilder: (context, index) {
                final step = _steps[index];
                return _StepElevatedCard(step: step);
              },
            );
          },
        ),
      ),
    );
  }
}

/// M3 Elevated Card Level 2 (3dp elevation) with inline status chip.
class _StepElevatedCard extends StatelessWidget {
  final StepCompletionDataGen02065 step;

  const _StepElevatedCard({required this.step});

  Color _getStatusColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (step.status) {
      case 'Complete':
        return colorScheme.primary;
      case 'Partial':
        return colorScheme.tertiary;
      default:
        return colorScheme.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 3.0, // M3 Elevated Cards Level 2
      surfaceTintColor: colorScheme.surfaceTint,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.0),
        onTap: () {
          _showConfigurationBottomSheet(context);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      step.atomicId,
                      style: textTheme.titleMedium?.copyWith(color: colorScheme.primary),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // M3 Status Chip
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                    decoration: BoxDecoration(
                      color: _getStatusColor(context).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text(
                      step.status,
                      style: textTheme.labelLarge?.copyWith(
                        color: _getStatusColor(context),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
              Text(
                step.description,
                style: textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12.0),
              Row(
                children: [
                  Text(
                    '${TypographyTokensGen02065.metricName}: ',
                    style: textTheme.labelMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                  Text(
                    '${step.coveragePercentage.toStringAsFixed(1)}%',
                    style: textTheme.labelLarge?.copyWith(
                      color: step.coveragePercentage >= TypographyTokensGen02065.floorBoundary
                          ? colorScheme.primary
                          : colorScheme.error,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// M3 Bottom Sheet for configuration inputs / deep-link drill-down.
  void _showConfigurationBottomSheet(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Step Details: ${step.atomicId}', style: textTheme.headlineSmall),
              const SizedBox(height: 16.0),
              Text(step.description, style: textTheme.bodyLarge),
              const SizedBox(height: 16.0),
              Text('Status: ${step.status}', style: textTheme.bodyMedium),
              Text('Coverage: ${step.coveragePercentage}%', style: textTheme.bodyMedium),
              Text('Timestamp: ${step.timestamp.toIso8601String()}', style: textTheme.bodySmall),
              const SizedBox(height: 24.0),
              SizedBox(
                width: double.infinity,
                height: 48.0, // 48x48dp touch target
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Configuration synced successfully.'),
                        behavior: SnackBarBehavior.floating,
                        action: SnackBarAction(
                          label: 'DISMISS',
                          onPressed: () {},
                        ),
                      ),
                    );
                  },
                  child: const Text('Acknowledge & Sync'),
                ),
              ),
              const SizedBox(height: 16.0),
            ],
          ),
        );
      },
    );
  }
}
