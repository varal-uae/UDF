// GEN-04146 — CI/CD Compliance Status Card for Engineering Console.
// Displays operational compliance state using M3 ElevatedCard, status chips, 30s background polling, and pull-to-refresh.

import 'dart:async';
import 'package:flutter/material.dart';

enum ComplianceStatus { complete, partial, notComplete }

class CicdComplianceModel {
  final String atomicId;
  final String action;
  final ComplianceStatus status;
  final DateTime lastChecked;
  final String metricName;

  const CicdComplianceModel({
    required this.atomicId,
    required this.action,
    required this.status,
    required this.lastChecked,
    required this.metricName,
  });
}

class MockCicdRepository {
  static Future<CicdComplianceModel> fetchComplianceStatus() async {
    await Future.delayed(const Duration(milliseconds: 350));
    return CicdComplianceModel(
      atomicId: 'GEN-04146',
      action: 'Implement CI/CD checks to reject local CSS or hardcoded validation overrides in mobile apps.',
      status: ComplianceStatus.complete,
      lastChecked: DateTime.now(),
      metricName: 'General Process/Operational Compliance',
    );
  }
}

class CicdComplianceCardGen04146 extends StatefulWidget {
  const CicdComplianceCardGen04146({super.key});

  @override
  State<CicdComplianceCardGen04146> createState() => _CicdComplianceCardGen04146State();
}

class _CicdComplianceCardGen04146State extends State<CicdComplianceCardGen04146> {
  late Future<CicdComplianceModel> _complianceFuture;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _complianceFuture = MockCicdRepository.fetchComplianceStatus();
    _startPolling();
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _refreshData(silent: true);
    });
  }

  Future<void> _refreshData({bool silent = false}) async {
    if (silent) {
      final newData = await MockCicdRepository.fetchComplianceStatus();
      if (mounted) {
        setState(() {
          _complianceFuture = Future.value(newData);
        });
      }
    } else {
      setState(() {
        _complianceFuture = MockCicdRepository.fetchComplianceStatus();
      });
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Color _getStatusColor(ComplianceStatus status, ColorScheme colorScheme) {
    switch (status) {
      case ComplianceStatus.complete:
        return colorScheme.primary;
      case ComplianceStatus.partial:
        return colorScheme.tertiary;
      case ComplianceStatus.notComplete:
        return colorScheme.error;
    }
  }

  String _getStatusLabel(ComplianceStatus status) {
    switch (status) {
      case ComplianceStatus.complete:
        return 'Complete';
      case ComplianceStatus.partial:
        return 'Partial';
      case ComplianceStatus.notComplete:
        return 'Not Complete';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return RefreshIndicator(
      onRefresh: () => _refreshData(silent: false),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FutureBuilder<CicdComplianceModel>(
            future: _complianceFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Card(
                  elevation: 3.0,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text('Error loading compliance data', style: theme.textTheme.bodyLarge),
                  ),
                );
              }

              final data = snapshot.data!;
              final statusColor = _getStatusColor(data.status, colorScheme);

              return Card(
                elevation: 3.0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              data.atomicId,
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Chip(
                            label: Text(
                              _getStatusLabel(data.status),
                              style: theme.textTheme.labelMedium?.copyWith(color: colorScheme.onPrimary),
                            ),
                            backgroundColor: statusColor,
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                      Text(
                        data.action,
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16.0),
                      Divider(color: colorScheme.outlineVariant),
                      const SizedBox(height: 8.0),
                      Row(
                        children: [
                          Icon(Icons.assessment_outlined, size: 18.0, color: colorScheme.onSurfaceVariant),
                          const SizedBox(width: 8.0),
                          Text(
                            data.metricName,
                            style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8.0),
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 18.0, color: colorScheme.onSurfaceVariant),
                          const SizedBox(width: 8.0),
                          Text(
                            'Last checked: ${data.lastChecked.toIso8601String().substring(0, 19)}Z',
                            style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24.0),
                      SizedBox(
                        width: double.infinity,
                        height: 48.0,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Drill-down view is read-only in engineering console.')),
                            );
                          },
                          icon: const Icon(Icons.open_in_new, size: 20.0),
                          label: const Text('View Details'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}