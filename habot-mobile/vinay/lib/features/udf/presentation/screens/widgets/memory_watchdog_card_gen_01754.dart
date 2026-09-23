// GEN-01754 — Memory Watchdog Status Card.
// Displays watchdog memory wipe compliance status using M3 ElevatedCard, status chips, and background polling every 30 seconds. Responsive single-column mobile layout with 48x48dp touch targets.

import 'dart:async';
import 'package:flutter/material.dart';

enum _ComplianceLevel { high, medium, low }

class _WatchdogMockData {
  final String stepId;
  final String description;
  final double rejectionRate;
  final _ComplianceLevel level;
  final DateTime lastChecked;
  final bool isHealthy;

  const _WatchdogMockData({
    required this.stepId,
    required this.description,
    required this.rejectionRate,
    required this.level,
    required this.lastChecked,
    required this.isHealthy,
  });
}

const List<_WatchdogMockData> _mockWatchdogEvents = [
  _WatchdogMockData(
    stepId: 'GEN-01754',
    description: 'Watchdog wiped unauthenticated memory block A',
    rejectionRate: 99.8,
    level: _ComplianceLevel.high,
    lastChecked: DateTime(2026, 9, 23, 10, 15),
    isHealthy: true,
  ),
  _WatchdogMockData(
    stepId: 'GEN-01754',
    description: 'Watchdog verified secure heap clearance',
    rejectionRate: 98.2,
    level: _ComplianceLevel.high,
    lastChecked: DateTime(2026, 9, 23, 10, 14),
    isHealthy: true,
  ),
  _WatchdogMockData(
    stepId: 'GEN-01754',
    description: 'Partial memory wipe detected - retrying',
    rejectionRate: 85.0,
    level: _ComplianceLevel.medium,
    lastChecked: DateTime(2026, 9, 23, 10, 13),
    isHealthy: false,
  ),
];

class MemoryWatchdogCardGen01754 extends StatefulWidget {
  const MemoryWatchdogCardGen01754({super.key});

  @override
  State<MemoryWatchdogCardGen01754> createState() => _MemoryWatchdogCardGen01754State();
}

class _MemoryWatchdogCardGen01754State extends State<MemoryWatchdogCardGen01754> {
  late List<_WatchdogMockData> _currentData;
  Timer? _pollingTimer;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _currentData = List.from(_mockWatchdogEvents);
    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _fetchData();
    });
  }

  Future<void> _fetchData() async {
    if (!mounted) return;
    setState(() => _isRefreshing = true);
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    setState(() {
      _currentData = List.from(_mockWatchdogEvents);
      _isRefreshing = false;
    });
  }

  Color _getChipColor(_ComplianceLevel level, ThemeData theme) {
    switch (level) {
      case _ComplianceLevel.high:
        return theme.colorScheme.primaryContainer;
      case _ComplianceLevel.medium:
        return theme.colorScheme.tertiaryContainer;
      case _ComplianceLevel.low:
        return theme.colorScheme.errorContainer;
    }
  }

  Color _getChipTextColor(_ComplianceLevel level, ThemeData theme) {
    switch (level) {
      case _ComplianceLevel.high:
        return theme.colorScheme.onPrimaryContainer;
      case _ComplianceLevel.medium:
        return theme.colorScheme.onTertiaryContainer;
      case _ComplianceLevel.low:
        return theme.colorScheme.onErrorContainer;
    }
  }

  String _levelToString(_ComplianceLevel level) {
    switch (level) {
      case _ComplianceLevel.high:
        return 'High';
      case _ComplianceLevel.medium:
        return 'Medium';
      case _ComplianceLevel.low:
        return 'Low';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isDesktop = screenWidth >= 840;

    return RefreshIndicator(
      onRefresh: _fetchData,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: isDesktop
                ? Wrap(
                    spacing: 16.0,
                    runSpacing: 16.0,
                    children: _currentData.map((e) => _buildCard(e, theme, constraints.maxWidth / 2 - 24)).toList(),
                  )
                : Column(
                    children: _currentData.map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: _buildCard(e, theme, constraints.maxWidth),
                    )).toList(),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildCard(_WatchdogMockData data, ThemeData theme, double width) {
    return SizedBox(
      width: width,
      child: Card(
        elevation: 3.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Drill-down for ${data.stepId}'),
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        data.stepId,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Chip(
                      label: Text(
                        _levelToString(data.level),
                        style: TextStyle(
                          color: _getChipTextColor(data.level, theme),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      backgroundColor: _getChipColor(data.level, theme),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
                const SizedBox(height: 12.0),
                Text(
                  data.description,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    Icon(
                      data.isHealthy ? Icons.check_circle_outline : Icons.warning_amber_rounded,
                      color: data.isHealthy ? theme.colorScheme.primary : theme.colorScheme.error,
                      size: 20.0,
                    ),
                    const SizedBox(width: 8.0),
                    Text(
                      'Rejection Rate: ${data.rejectionRate.toStringAsFixed(1)}%',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    if (_isRefreshing)
                      const SizedBox(
                        width: 16.0,
                        height: 16.0,
                        child: CircularProgressIndicator(strokeWidth: 2.0),
                      ),
                  ],
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Last checked: ${data.lastChecked.hour}:${data.lastChecked.minute.toString().padLeft(2, '0')}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
                const SizedBox(height: 8.0),
                SizedBox(
                  height: 48.0,
                  width: 48.0,
                  child: IconButton(
                    icon: const Icon(Icons.open_in_new),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (ctx) => SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Configuration Details', style: Theme.of(ctx).textTheme.titleLarge),
                                const SizedBox(height: 16.0),
                                Text('Step: ${data.stepId}'),
                                Text('Metric: Automated PR Rejection Rate for Non-Compliance (%)'),
                                Text('Floor Boundary: 95%'),
                                Text('Optimal Target: 99.5%'),
                                Text('Ceiling Boundary: 100%'),
                                const SizedBox(height: 24.0),
                                SizedBox(
                                  width: double.infinity,
                                  height: 48.0,
                                  child: FilledButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: const Text('Close'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    tooltip: 'View configuration details',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}