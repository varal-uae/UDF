// GEN-03805 — Registry Deployment SLA Status Card.
// M3 Elevated Card displaying step completion state with background polling and pull-to-refresh support for mobile engineering console.

import 'dart:async';
import 'package:flutter/material.dart';

enum _DeploymentStatus { pass, fail, pending }

class _MockRegistryDeploymentData {
  final String atomicId;
  final String packageName;
  final _DeploymentStatus status;
  final double slaValue;
  final DateTime timestamp;
  final String sessionId;

  const _MockRegistryDeploymentData({
    required this.atomicId,
    required this.packageName,
    required this.status,
    required this.slaValue,
    required this.timestamp,
    required this.sessionId,
  });
}

class _MockRegistryRepository {
  static const List<_MockRegistryDeploymentData> _mockDb = [
    _MockRegistryDeploymentData(
      atomicId: 'GEN-03805',
      packageName: '@habot/trade-rebate-engine',
      status: _DeploymentStatus.pass,
      slaValue: 0.9999,
      timestamp: _MockRegistryRepository._fixedTime,
      sessionId: 'sess_udf_001',
    ),
  ];

  static const DateTime _fixedTime = DateTime(2026, 9, 28, 10, 0, 0);

  Future<_MockRegistryDeploymentData> fetchDeploymentStatus() async {
    await Future<void>.delayed(const Duration(milliseconds: 45));
    return _mockDb.first;
  }
}

class RegistryDeploymentCardGen03805 extends StatefulWidget {
  const RegistryDeploymentCardGen03805({super.key});

  @override
  State<RegistryDeploymentCardGen03805> createState() => _RegistryDeploymentCardGen03805State();
}

class _RegistryDeploymentCardGen03805State extends State<RegistryDeploymentCardGen03805> {
  final _MockRegistryRepository _repository = _MockRegistryRepository();
  _MockRegistryDeploymentData? _data;
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
      final data = await _repository.fetchDeploymentStatus();
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

  Future<void> _onRefresh() async {
    await _fetchData();
  }

  Color _statusColor(BuildContext context, _DeploymentStatus status) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (status) {
      case _DeploymentStatus.pass:
        return colorScheme.primary;
      case _DeploymentStatus.fail:
        return colorScheme.error;
      case _DeploymentStatus.pending:
        return colorScheme.surfaceTint;
    }
  }

  String _statusLabel(_DeploymentStatus status) {
    switch (status) {
      case _DeploymentStatus.pass:
        return 'Pass';
      case _DeploymentStatus.fail:
        return 'Fail';
      case _DeploymentStatus.pending:
        return 'Pending';
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;
          final isTabletOrDesktop = constraints.maxWidth >= 840;

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: isMobile ? _buildSingleColumn(textTheme, colorScheme) : _buildMultiColumn(textTheme, colorScheme, isTabletOrDesktop),
          );
        },
      ),
    );
  }

  Widget _buildSingleColumn(TextTheme textTheme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(textTheme),
        const SizedBox(height: 16),
        _buildStatusCard(textTheme, colorScheme),
        const SizedBox(height: 16),
        _buildDetailsCard(textTheme, colorScheme),
      ],
    );
  }

  Widget _buildMultiColumn(TextTheme textTheme, ColorScheme colorScheme, bool isDesktop) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: isDesktop ? 2 : 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(textTheme),
              const SizedBox(height: 16),
              _buildStatusCard(textTheme, colorScheme),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: isDesktop ? 3 : 2,
          child: _buildDetailsCard(textTheme, colorScheme),
        ),
      ],
    );
  }

  Widget _buildHeader(TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Publish Component to Common Library', style: textTheme.titleLarge),
        const SizedBox(height: 4),
        Text('Package: @habot/trade-rebate-engine', style: textTheme.bodyMedium),
        Text('Atomic ID: GEN-03805 | Step: 9999', style: textTheme.bodySmall),
      ],
    );
  }

  Widget _buildStatusCard(TextTheme textTheme, ColorScheme colorScheme) {
    if (_isLoading && _data == null) {
      return Card(
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(child: CircularProgressIndicator(color: colorScheme.primary)),
        ),
      );
    }

    final data = _data;
    if (data == null) return const SizedBox.shrink();

    final statusColor = _statusColor(context, data.status);

    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Registry Deployment SLA', style: textTheme.titleMedium),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Status', style: textTheme.bodyLarge),
                Chip(
                  avatar: Icon(Icons.circle, size: 12, color: statusColor),
                  label: Text(_statusLabel(data.status), style: TextStyle(color: statusColor, fontWeight: FontWeight.bold)),
                  backgroundColor: statusColor.withOpacity(0.1),
                  side: BorderSide.none,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('SLA Value', style: textTheme.bodyLarge),
                Text('${data.slaValue}', style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Floor Boundary', style: textTheme.bodyMedium),
                Text('0.999', style: textTheme.bodyMedium),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard(TextTheme textTheme, ColorScheme colorScheme) {
    final data = _data;
    if (data == null && !_isLoading) return const SizedBox.shrink();

    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Execution Details', style: textTheme.titleMedium),
            const Divider(),
            _buildDetailRow('Session ID', data?.sessionId ?? 'N/A', textTheme),
            _buildDetailRow('Timestamp', data?.timestamp.toIso8601String() ?? 'N/A', textTheme),
            _buildDetailRow('Dependency', 'GEN-03804', textTheme),
            _buildDetailRow('Target Library', '@habot/shared-library', textTheme),
            const SizedBox(height: 16),
            SizedBox(
              height: 48,
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Deep-link drill-down triggered for GEN-03805')),
                  );
                },
                icon: const Icon(Icons.open_in_new, size: 20),
                label: const Text('View Runbook & Logs'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(48, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: textTheme.bodyMedium?.copyWith(color: Colors.grey[600])),
          Flexible(child: Text(value, style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500), textAlign: TextAlign.end)),
        ],
      ),
    );
  }
}