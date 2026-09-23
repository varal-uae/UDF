// GEN-01699 — Multi-Window Boundary Logic Resolver for Android vs iOS Split View.
// Resolves platform-specific boundary logic for multi-window rendering fidelity using M3 Elevated Cards and responsive breakpoints.

import 'package:flutter/material.dart';

/// Qualitative output classification for rendering fidelity.
enum RenderingFidelityLevel { high, medium, low }

/// Mock telemetry data representing the current multi-window rendering state.
class MultiWindowTelemetry {
  final double fidelityPercentage;
  final RenderingFidelityLevel qualitativeOutput;
  final DateTime timestamp;
  final String sessionId;

  const MultiWindowTelemetry({
    required this.fidelityPercentage,
    required this.qualitativeOutput,
    required this.timestamp,
    required this.sessionId,
  });
}

/// Provides realistic local mock data for engineering console dashboard.
class MockMultiWindowRepository {
  static const double floorBoundary = 95.0;
  static const double optimalTarget = 99.5;
  static const double ceilingBoundary = 100.0;

  static List<MultiWindowTelemetry> fetchMockTelemetry() {
    return [
      MultiWindowTelemetry(
        fidelityPercentage: 99.8,
        qualitativeOutput: RenderingFidelityLevel.high,
        timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
        sessionId: 'sess_ios_001',
      ),
      MultiWindowTelemetry(
        fidelityPercentage: 96.5,
        qualitativeOutput: RenderingFidelityLevel.medium,
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        sessionId: 'sess_android_002',
      ),
      MultiWindowTelemetry(
        fidelityPercentage: 94.2,
        qualitativeOutput: RenderingFidelityLevel.low,
        timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
        sessionId: 'sess_ios_003',
      ),
    ];
  }
}

/// Resolves boundary logic differences between Android multi-window and iOS Split View.
class MultiWindowBoundaryResolver {
  /// Determines if the current platform requires specific split-view handling.
  static bool isIosSplitView(TargetPlatform platform) =>
      platform == TargetPlatform.iOS;

  static bool isAndroidMultiWindow(TargetPlatform platform) =>
      platform == TargetPlatform.android;

  /// Evaluates fidelity against the 95% floor threshold.
  static bool isWithinFloorBoundary(double fidelity) =>
      fidelity >= MockMultiWindowRepository.floorBoundary;
}

/// M3 Status Chip indicating step health based on fidelity level.
class FidelityStatusChip extends StatelessWidget {
  final RenderingFidelityLevel level;

  const FidelityStatusChip({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor;
    final Color foregroundColor;
    final String label;

    switch (level) {
      case RenderingFidelityLevel.high:
        backgroundColor = Theme.of(context).colorScheme.primaryContainer;
        foregroundColor = Theme.of(context).colorScheme.onPrimaryContainer;
        label = 'High';
        break;
      case RenderingFidelityLevel.medium:
        backgroundColor = Theme.of(context).colorScheme.tertiaryContainer;
        foregroundColor = Theme.of(context).colorScheme.onTertiaryContainer;
        label = 'Medium';
        break;
      case RenderingFidelityLevel.low:
        backgroundColor = Theme.of(context).colorScheme.errorContainer;
        foregroundColor = Theme.of(context).colorScheme.onErrorContainer;
        label = 'Low';
        break;
    }

    return Chip(
      label: Text(label),
      backgroundColor: backgroundColor,
      labelStyle: TextStyle(color: foregroundColor, fontSize: 12),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      visualDensity: VisualDensity.compact,
    );
  }
}

/// M3 Elevated Card Level 2 (3dp) displaying a single telemetry KPI.
class TelemetryKpiCard extends StatelessWidget {
  final MultiWindowTelemetry telemetry;

  const TelemetryKpiCard({super.key, required this.telemetry});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3.0,
      surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Rendering Fidelity',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                FidelityStatusChip(level: telemetry.qualitativeOutput),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '${telemetry.fidelityPercentage.toStringAsFixed(1)}%',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: MultiWindowBoundaryResolver.isWithinFloorBoundary(
                            telemetry.fidelityPercentage)
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.error,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Session: ${telemetry.sessionId}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              'Timestamp: ${telemetry.timestamp.toIso8601String()}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

/// Engineering Console Screen implementing responsive layout:
/// Single-column on mobile (<600dp), multi-column on desktop (>=840dp).
/// Touch targets are 48x48dp minimum per M3 guidelines.
class MultiWindowEngineeringConsoleScreen extends StatefulWidget {
  const MultiWindowEngineeringConsoleScreen({super.key});

  @override
  State<MultiWindowEngineeringConsoleScreen> createState() =>
      _MultiWindowEngineeringConsoleScreenState();
}

class _MultiWindowEngineeringConsoleScreenState
    extends State<MultiWindowEngineeringConsoleScreen> {
  late List<MultiWindowTelemetry> _telemetryData;

  @override
  void initState() {
    super.initState();
    _telemetryData = MockMultiWindowRepository.fetchMockTelemetry();
    _startPolling();
  }

  void _startPolling() {
    // Background polling refreshes data every 30 seconds as per requirement.
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted) {
        setState(() {
          _telemetryData = MockMultiWindowRepository.fetchMockTelemetry();
        });
        _startPolling();
      }
    });
  }

  void _triggerManualSync() {
    setState(() {
      _telemetryData = MockMultiWindowRepository.fetchMockTelemetry();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Manual sync triggered successfully.'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        action: SnackBarAction(
          label: 'DISMISS',
          onPressed: () {},
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 840;
    final platform = Theme.of(context).platform;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Engineering Console'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Manual Sync',
            onPressed: _triggerManualSync,
            // Ensure 48x48dp touch target
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _triggerManualSync(),
        child: isDesktop
            ? _buildMultiColumnLayout(platform)
            : _buildSingleColumnLayout(platform),
      ),
    );
  }

  Widget _buildSingleColumnLayout(TargetPlatform platform) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: _telemetryData.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildPlatformHeader(platform);
        }
        return TelemetryKpiCard(telemetry: _telemetryData[index - 1]);
      },
    );
  }

  Widget _buildMultiColumnLayout(TargetPlatform platform) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: ListView(
            padding: const EdgeInsets.only(top: 16),
            children: [_buildPlatformHeader(platform)],
          ),
        ),
        Expanded(
          flex: 2,
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 16),
            itemCount: _telemetryData.length,
            itemBuilder: (context, index) =>
                TelemetryKpiCard(telemetry: _telemetryData[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildPlatformHeader(TargetPlatform platform) {
    final isIos = MultiWindowBoundaryResolver.isIosSplitView(platform);
    final isAndroid = MultiWindowBoundaryResolver.isAndroidMultiWindow(platform);

    return Card(
      elevation: 3.0,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Boundary Logic Resolution',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Active Platform Context: ${isIos ? "iOS Split View" : isAndroid ? "Android Multi-Window" : "Standard"}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Floor Threshold: ${MockMultiWindowRepository.floorBoundary}% | Optimal: ${MockMultiWindowRepository.optimalTarget}%',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
