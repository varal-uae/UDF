// GEN-03981 — Authorized View Status Card for Engineering Console.
// Displays M3 Elevated Card with status chip, metric thresholds, and mock data for authorized view masking configuration.

import 'dart:async';
import 'package:flutter/material.dart';

/// Mock data model representing the backend BigQuery Authorized View step.
class _AuthorizedViewMockData {
  final String atomicId;
  final String stepName;
  final String status;
  final double buildOverheadSeconds;
  final DateTime lastUpdated;
  final String assignedTeam;

  const _AuthorizedViewMockData({
    required this.atomicId,
    required this.stepName,
    required this.status,
    required this.buildOverheadSeconds,
    required this.lastUpdated,
    required this.assignedTeam,
  });
}

/// Hardcoded mock repository simulating backend API response.
class _MockAuthorizedViewRepository {
  static const _AuthorizedViewMockData currentStep = _AuthorizedViewMockData(
    atomicId: 'GEN-03981',
    stepName: 'Create Authorized Views masking encrypted or sensitive columns for non-privileged roles.',
    status: 'Pass',
    buildOverheadSeconds: 0.42,
    lastUpdated: null as dynamic, // replaced in factory
    assignedTeam: 'PDG',
  );

  static _AuthorizedViewMockData fetch() {
    return _AuthorizedViewMockData(
      atomicId: currentStep.atomicId,
      stepName: currentStep.stepName,
      status: currentStep.status,
      buildOverheadSeconds: currentStep.buildOverheadSeconds,
      lastUpdated: DateTime.now(),
      assignedTeam: currentStep.assignedTeam,
    );
  }
}

class AuthorizedViewStatusCardGen03981 extends StatefulWidget {
  const AuthorizedViewStatusCardGen03981({super.key});

  @override
  State<AuthorizedViewStatusCardGen03981> createState() => _AuthorizedViewStatusCardGen03981State();
}

class _AuthorizedViewStatusCardGen03981State extends State<AuthorizedViewStatusCardGen03981> {
  late _AuthorizedViewMockData _data;
  Timer? _pollingTimer;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _data = _MockAuthorizedViewRepository.fetch();
    // Background polling refreshes data every 30 seconds.
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) => _refreshData());
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _refreshData() async {
    if (!mounted) return;
    setState(() => _isRefreshing = true);
    // Simulate network latency
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    setState(() {
      _data = _MockAuthorizedViewRepository.fetch();
      _isRefreshing = false;
    });
  }

  Color _statusColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (_data.status == 'Pass') return colorScheme.primary;
    if (_data.buildOverheadSeconds >= 5.0) return colorScheme.error;
    return colorScheme.tertiary;
  }

  String _metricEvaluation() {
    if (_data.buildOverheadSeconds < 0.5) return 'Optimal (< 0.5s)';
    if (_data.buildOverheadSeconds < 2.0) return 'Within Floor (< 2.0s)';
    if (_data.buildOverheadSeconds <= 5.0) return 'Near Ceiling (<= 5.0s)';
    return 'Exceeded Ceiling (> 5.0s)';
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
              // M3 responsive layout: single-column on mobile (<600dp), multi-column on desktop (>=840dp).
              final isDesktop = constraints.maxWidth >= 840;

              final cardContent = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _data.atomicId,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      // M3 Status Chip for health indicator
                      Chip(
                        avatar: Icon(
                          _data.status == 'Pass' ? Icons.check_circle : Icons.warning,
                          size: 18,
                          color: _statusColor(context),
                        ),
                        label: Text(
                          _data.status,
                          style: textTheme.labelLarge?.copyWith(
                            color: _statusColor(context),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        backgroundColor: _statusColor(context).withOpacity(0.12),
                        side: BorderSide.none,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _data.stepName,
                    style: textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Metric KPI Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Authorized View Build Overhead',
                          style: textTheme.labelMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_data.buildOverheadSeconds.toStringAsFixed(2)} s',
                          style: textTheme.headlineMedium?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _metricEvaluation(),
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.group_outlined, size: 16, color: colorScheme.onSurfaceVariant),
                      const SizedBox(width: 8),
                      Text('Team: ${_data.assignedTeam}', style: textTheme.bodyMedium),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 16, color: colorScheme.onSurfaceVariant),
                      const SizedBox(width: 8),
                      Text(
                        'Last Sync: ${_data.lastUpdated.hour.toString().padLeft(2, '0')}:${_data.lastUpdated.minute.toString().padLeft(2, '0')}:${_data.lastUpdated.second.toString().padLeft(2, '0')}',
                        style: textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  if (_isRefreshing) ...[
                    const SizedBox(height: 16),
                    const LinearProgressIndicator(),
                  ],
                ],
              );

              // M3 Elevated Cards Level 2 (3dp)
              final elevatedCard = Card(
                elevation: 3.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: cardContent,
                ),
              );

              if (isDesktop) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: elevatedCard),
                    const SizedBox(width: 24),
                    Expanded(
                      flex: 1,
                      child: Card(
                        elevation: 1.0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Thresholds', style: textTheme.titleSmall),
                              const Divider(),
                              _buildThresholdRow(context, 'Optimal Target', '< 0.5 s'),
                              _buildThresholdRow(context, 'Floor Boundary', '< 2.0 s'),
                              _buildThresholdRow(context, 'Ceiling Boundary', '5.0 s'),
                              const SizedBox(height: 16),
                              Text('Standard Spec', style: textTheme.titleSmall),
                              const SizedBox(height: 8),
                              Text('BigQuery Data Masking Specs', style: textTheme.bodyMedium),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }

              return elevatedCard;
            },
          ),
        ),
      ),
    );
  }

  Widget _buildThresholdRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}