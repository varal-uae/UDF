// GEN-02121 — API Equation Gate Status Card.
// M3 Elevated Card displaying step completion state for blocking API execution until all equations equal zero. Includes mock data, 30s polling, and responsive layout support.

import 'dart:async';
import 'package:flutter/material.dart';

enum StepCompletionStatus { complete, partial, notComplete }

class EquationGateData {
  final String stepId;
  final String description;
  final StepCompletionStatus status;
  final double completionRate;
  final DateTime lastChecked;

  const EquationGateData({
    required this.stepId,
    required this.description,
    required this.status,
    required this.completionRate,
    required this.lastChecked,
  });
}

class MockEquationGateRepository {
  static EquationGateData fetchCurrentState() {
    return EquationGateData(
      stepId: 'GEN-02121',
      description: 'Physically block the API call execution until all equations equal exactly zero.',
      status: StepCompletionStatus.complete,
      completionRate: 100.0,
      lastChecked: DateTime.now(),
    );
  }
}

class ApiEquationGateCardGen02121 extends StatefulWidget {
  const ApiEquationGateCardGen02121({super.key});

  @override
  State<ApiEquationGateCardGen02121> createState() => _ApiEquationGateCardGen02121State();
}

class _ApiEquationGateCardGen02121State extends State<ApiEquationGateCardGen02121> {
  late EquationGateData _data;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _data = MockEquationGateRepository.fetchCurrentState();
    _startPolling();
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _refreshData();
    });
  }

  Future<void> _refreshData() async {
    setState(() {
      _data = MockEquationGateRepository.fetchCurrentState();
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Color _getStatusColor(BuildContext context, StepCompletionStatus status) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (status) {
      case StepCompletionStatus.complete:
        return colorScheme.primary;
      case StepCompletionStatus.partial:
        return colorScheme.tertiary;
      case StepCompletionStatus.notComplete:
        return colorScheme.error;
    }
  }

  String _getStatusText(StepCompletionStatus status) {
    switch (status) {
      case StepCompletionStatus.complete:
        return 'Complete';
      case StepCompletionStatus.partial:
        return 'Partial';
      case StepCompletionStatus.notComplete:
        return 'Not Complete';
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 600;
              final isTabletOrDesktop = constraints.maxWidth >= 840;

              if (isMobile) {
                return _buildSingleColumnLayout(context, textTheme, colorScheme);
              } else if (isTabletOrDesktop) {
                return _buildMultiColumnLayout(context, textTheme, colorScheme);
              }
              return _buildSingleColumnLayout(context, textTheme, colorScheme);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSingleColumnLayout(BuildContext context, TextTheme textTheme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildMainCard(context, textTheme, colorScheme),
        const SizedBox(height: 16),
        _buildMetricsCard(context, textTheme, colorScheme),
      ],
    );
  }

  Widget _buildMultiColumnLayout(BuildContext context, TextTheme textTheme, ColorScheme colorScheme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 2, child: _buildMainCard(context, textTheme, colorScheme)),
        const SizedBox(width: 16),
        Expanded(flex: 1, child: _buildMetricsCard(context, textTheme, colorScheme)),
      ],
    );
  }

  Widget _buildMainCard(BuildContext context, TextTheme textTheme, ColorScheme colorScheme) {
    return Card(
      elevation: 3.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('API Execution Gate', style: textTheme.titleLarge),
                Chip(
                  label: Text(
                    _getStatusText(_data.status),
                    style: TextStyle(color: colorScheme.onPrimary),
                  ),
                  backgroundColor: _getStatusColor(context, _data.status),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(_data.description, style: textTheme.bodyMedium),
            const SizedBox(height: 16),
            Text('Reference ID: ${_data.stepId}', style: textTheme.labelSmall),
            Text('Standard: ISO/IEC 27001:2022 General Standards', style: textTheme.labelSmall),
            const SizedBox(height: 16),
            SizedBox(
              height: 48,
              width: 48,
              child: IconButton(
                iconSize: 48,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Configuration opened'),
                      behavior: SnackBarBehavior.floating,
                      action: SnackBarAction(
                        label: 'Dismiss',
                        onPressed: () {},
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.settings_outlined),
                tooltip: 'Open Configuration',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsCard(BuildContext context, TextTheme textTheme, ColorScheme colorScheme) {
    return Card(
      elevation: 3.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Step Completion Rate (%)', style: textTheme.titleMedium),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: _data.completionRate / 100.0,
              minHeight: 8,
              backgroundColor: colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(_getStatusColor(context, _data.status)),
            ),
            const SizedBox(height: 8),
            Text('${_data.completionRate.toStringAsFixed(1)}%', style: textTheme.headlineSmall),
            const SizedBox(height: 16),
            Text('Floor Boundary: 90%', style: textTheme.bodySmall),
            Text('Optimal Target: 99%', style: textTheme.bodySmall),
            Text('Ceiling Boundary: 100%', style: textTheme.bodySmall),
            const Divider(height: 32),
            Text('Last Checked:', style: textTheme.labelMedium),
            Text(
              '${_data.lastChecked.hour}:${_data.lastChecked.minute.toString().padLeft(2, '0')}:${_data.lastChecked.second.toString().padLeft(2, '0')}',
              style: textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
