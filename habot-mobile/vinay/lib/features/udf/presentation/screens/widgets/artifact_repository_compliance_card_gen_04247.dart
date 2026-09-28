// GEN-04247 — Artifact Repository Compliance Status Card.
// Displays the compliance status of gateway policy artifacts using M3 Elevated Cards, status chips, and background polling every 30 seconds with pull-to-refresh support.

import 'dart:async';
import 'package:flutter/material.dart';

/// Mock data model representing the artifact repository compliance state.
class ArtifactComplianceModel {
  final String atomicId;
  final String repositoryName;
  final bool isCompliant;
  final DateTime lastChecked;
  final String standardReference;

  const ArtifactComplianceModel({
    required this.atomicId,
    required this.repositoryName,
    required this.isCompliant,
    required this.lastChecked,
    required this.standardReference,
  });
}

/// Provides mock data for the artifact compliance requirement.
class ArtifactComplianceMockRepository {
  static ArtifactComplianceModel fetchComplianceStatus() {
    return ArtifactComplianceModel(
      atomicId: 'GEN-04247',
      repositoryName: '@habot/gateway-policies',
      isCompliant: true,
      lastChecked: DateTime.now(),
      standardReference: 'ISO/IEC 12207 Software Life Cycle – Configuration Management',
    );
  }
}

/// M3 Elevated Card displaying the Artifact Repository Compliance KPI.
/// Implements single-column mobile layout (<600dp), 48x48dp touch targets,
/// 30-second background polling, and pull-to-refresh manual sync.
class ArtifactRepositoryComplianceCard extends StatefulWidget {
  const ArtifactRepositoryComplianceCard({super.key});

  @override
  State<ArtifactRepositoryComplianceCard> createState() => _ArtifactRepositoryComplianceCardState();
}

class _ArtifactRepositoryComplianceCardState extends State<ArtifactRepositoryComplianceCard> {
  late ArtifactComplianceModel _complianceData;
  Timer? _pollingTimer;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _complianceData = ArtifactComplianceMockRepository.fetchComplianceStatus();
    _startPolling();
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        _refreshData();
      }
    });
  }

  Future<void> _refreshData() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);
    
    // Simulate network delay for mock data
    await Future.delayed(const Duration(milliseconds: 600));
    
    if (mounted) {
      setState(() {
        _complianceData = ArtifactComplianceMockRepository.fetchComplianceStatus();
        _isRefreshing = false;
      });
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return RefreshIndicator(
      onRefresh: _refreshData,
      color: colorScheme.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 3.0, // M3 Elevated Cards Level 2 (3dp)
            surfaceTintColor: colorScheme.surfaceTint,
            shape: RoundedRectangleBorder(
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
                    children: [
                      Expanded(
                        child: Text(
                          'Artifact Repository Compliance',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      _buildStatusChip(colorScheme),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  _buildInfoRow(
                    label: 'Atomic ID',
                    value: _complianceData.atomicId,
                    theme: theme,
                  ),
                  const SizedBox(height: 8.0),
                  _buildInfoRow(
                    label: 'Repository',
                    value: _complianceData.repositoryName,
                    theme: theme,
                  ),
                  const SizedBox(height: 8.0),
                  _buildInfoRow(
                    label: 'Standard Reference',
                    value: _complianceData.standardReference,
                    theme: theme,
                  ),
                  const SizedBox(height: 8.0),
                  _buildInfoRow(
                    label: 'Last Checked',
                    value: '${_complianceData.lastChecked.hour.toString().padLeft(2, '0')}:${_complianceData.lastChecked.minute.toString().padLeft(2, '0')}:${_complianceData.lastChecked.second.toString().padLeft(2, '0')}',
                    theme: theme,
                  ),
                  const SizedBox(height: 24.0),
                  SizedBox(
                    width: double.infinity,
                    height: 48.0, // 48x48dp touch target
                    child: FilledButton.tonalIcon(
                      onPressed: _isRefreshing ? null : _refreshData,
                      icon: _isRefreshing
                          ? SizedBox(
                              width: 20.0,
                              height: 20.0,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.0,
                                color: colorScheme.onSecondaryContainer,
                              ),
                            )
                          : const Icon(Icons.sync, size: 20.0),
                      label: const Text('Manual Sync'),
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

  Widget _buildStatusChip(ColorScheme colorScheme) {
    final isPass = _complianceData.isCompliant;
    return Chip(
      avatar: Icon(
        isPass ? Icons.check_circle_outline : Icons.error_outline,
        size: 18.0,
        color: isPass ? colorScheme.primary : colorScheme.error,
      ),
      label: Text(
        isPass ? 'Pass' : 'Fail',
        style: TextStyle(
          color: isPass ? colorScheme.primary : colorScheme.error,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: isPass
          ? colorScheme.primaryContainer.withOpacity(0.3)
          : colorScheme.errorContainer.withOpacity(0.3),
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
    required ThemeData theme,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140.0,
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}