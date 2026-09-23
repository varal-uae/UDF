// GEN-01864 — Build Rejection Status Card for Engineering Console.
// M3 Elevated Card displaying implementation completion rate with status chip, 30s polling, and pull-to-refresh support.

import 'dart:async';
import 'package:flutter/material.dart';

enum ImplementationStatus { complete, partial, notComplete }

class BuildRejectionStepData {
  final String atomicId;
  final String stepName;
  final double completionRate;
  final ImplementationStatus status;
  final DateTime lastUpdated;
  final bool isHealthy;

  const BuildRejectionStepData({
    required this.atomicId,
    required this.stepName,
    required this.completionRate,
    required this.status,
    required this.lastUpdated,
    required this.isHealthy,
  });
}

class MockBuildRejectionRepository {
  static const BuildRejectionStepData mockData = BuildRejectionStepData(
    atomicId: 'GEN-01864',
    stepName: 'Configure build system to reject custom CSS injection',
    completionRate: 99.5,
    status: ImplementationStatus.complete,
    lastUpdated: null,
    isHealthy: true,
  );

  Future<BuildRejectionStepData> fetchStepData() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return BuildRejectionStepData(
      atomicId: mockData.atomicId,
      stepName: mockData.stepName,
      completionRate: mockData.completionRate,
      status: mockData.status,
      lastUpdated: DateTime.now(),
      isHealthy: mockData.isHealthy,
    );
  }
}

class BuildRejectionStatusCardGen01864 extends StatefulWidget {
  const BuildRejectionStatusCardGen01864({super.key});

  @override
  State<BuildRejectionStatusCardGen01864> createState() => _BuildRejectionStatusCardGen01864State();
}

class _BuildRejectionStatusCardGen01864State extends State<BuildRejectionStatusCardGen01864> {
  final MockBuildRejectionRepository _repository = MockBuildRejectionRepository();
  BuildRejectionStepData? _data;
  bool _isLoading = true;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _fetchData();
    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final data = await _repository.fetchStepData();
      if (mounted) {
        setState(() {
          _data = data;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) => _fetchData());
  }

  Color _getStatusColor(BuildContext context, ImplementationStatus status) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (status) {
      case ImplementationStatus.complete:
        return colorScheme.primary;
      case ImplementationStatus.partial:
        return colorScheme.tertiary;
      case ImplementationStatus.notComplete:
        return colorScheme.error;
    }
  }

  String _getStatusLabel(ImplementationStatus status) {
    switch (status) {
      case ImplementationStatus.complete:
        return 'Complete';
      case ImplementationStatus.partial:
        return 'Partial';
      case ImplementationStatus.notComplete:
        return 'Not Complete';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return RefreshIndicator(
      onRefresh: _fetchData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 3.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'GEN-01864',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      if (_data != null)
                        Chip(
                          avatar: Icon(
                            _data!.isHealthy ? Icons.check_circle : Icons.error,
                            size: 18.0,
                            color: _getStatusColor(context, _data!.status),
                          ),
                          label: Text(
                            _getStatusLabel(_data!.status),
                            style: textTheme.labelLarge?.copyWith(
                              color: _getStatusColor(context, _data!.status),
                            ),
                          ),
                          backgroundColor: _getStatusColor(context, _data!.status).withOpacity(0.12),
                          side: BorderSide.none,
                        ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    _data?.stepName ?? 'Configure build system to physically reject code attempting to inject custom CSS classes.',
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24.0),
                  if (_isLoading && _data == null)
                    const Center(child: CircularProgressIndicator())
                  else if (_data != null) ...[
                    Row(
                      children: [
                        Text(
                          'Implementation Completion Rate',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${_data!.completionRate.toStringAsFixed(1)}%',
                          style: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: _data!.completionRate >= 95.0
                                ? colorScheme.primary
                                : colorScheme.error,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12.0),
                    LinearProgressIndicator(
                      value: _data!.completionRate / 100.0,
                      minHeight: 8.0,
                      borderRadius: BorderRadius.circular(4.0),
                      backgroundColor: colorScheme.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _data!.completionRate >= 95.0
                            ? colorScheme.primary
                            : colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Floor: 95%', style: textTheme.labelSmall),
                        Text('Target: 99.5%', style: textTheme.labelSmall),
                        Text('Ceiling: 100%', style: textTheme.labelSmall),
                      ],
                    ),
                    const SizedBox(height: 24.0),
                    Divider(color: colorScheme.outlineVariant),
                    const SizedBox(height: 16.0),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 16.0, color: colorScheme.onSurfaceVariant),
                        const SizedBox(width: 8.0),
                        Text(
                          'Last updated: ${_data!.lastUpdated != null ? _formatDateTime(_data!.lastUpdated!) : 'N/A'}',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    Row(
                      children: [
                        Icon(Icons.sync, size: 16.0, color: colorScheme.onSurfaceVariant),
                        const SizedBox(width: 8.0),
                        Text(
                          'Auto-refresh: 30s polling active',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 24.0),
                  SizedBox(
                    width: double.infinity,
                    height: 48.0,
                    child: FilledButton.tonalIcon(
                      onPressed: () => _showConfigBottomSheet(context),
                      icon: const Icon(Icons.settings, size: 20.0),
                      label: const Text('View Configuration'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
  }

  void _showConfigBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.0)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 32.0,
                      height: 4.0,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(2.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24.0),
                  Text(
                    'Step Configuration Details',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      children: [
                        _buildConfigRow('Atomic ID', 'GEN-01864'),
                        _buildConfigRow('Standard', 'ISO/IEC 27001:2022'),
                        _buildConfigRow('Metric', 'Implementation Completion Rate (%)'),
                        _buildConfigRow('Floor Boundary', '95%'),
                        _buildConfigRow('Optimal Target', '99.5%'),
                        _buildConfigRow('Ceiling Boundary', '100%'),
                        _buildConfigRow('Shared Library', '@habot/shared-library'),
                        _buildConfigRow('Estimated Time', '4 Hours'),
                        _buildConfigRow('CI/CD Gate', 'Active - Blocks deployment on failure'),
                        _buildConfigRow('Liveness Monitor', '30s Automated Handshake'),
                        _buildConfigRow('Dependency', 'GEN-01863'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  SizedBox(
                    width: double.infinity,
                    height: 48.0,
                    child: FilledButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Configuration acknowledged'),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                        );
                      },
                      child: const Text('Acknowledge & Close'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildConfigRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140.0,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}