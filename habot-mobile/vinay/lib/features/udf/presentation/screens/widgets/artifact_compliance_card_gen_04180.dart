// GEN-04180 — Artifact Repository Compliance Status Card.
// Displays a read-only M3 Elevated Card with status chip for artifact governance compliance, supporting responsive single/multi-column layouts and 30s background polling.

import 'dart:async';
import 'package:flutter/material.dart';

enum ArtifactComplianceStatus { pass, fail, pending }

class ArtifactComplianceData {
  final String packageId;
  final String metricName;
  final ArtifactComplianceStatus status;
  final DateTime timestamp;
  final String sessionId;

  const ArtifactComplianceData({
    required this.packageId,
    required this.metricName,
    required this.status,
    required this.timestamp,
    required this.sessionId,
  });
}

class MockArtifactRepository {
  static Future<ArtifactComplianceData> fetchComplianceStatus() async {
    await Future.delayed(const Duration(milliseconds: 80));
    return ArtifactComplianceData(
      packageId: '@habot/shakti-alert',
      metricName: 'Artifact Repository Compliance',
      status: ArtifactComplianceStatus.pass,
      timestamp: DateTime.now(),
      sessionId: 'sess_${DateTime.now().millisecondsSinceEpoch}',
    );
  }
}

class ArtifactComplianceCardGen04180 extends StatefulWidget {
  const ArtifactComplianceCardGen04180({super.key});

  @override
  State<ArtifactComplianceCardGen04180> createState() => _ArtifactComplianceCardGen04180State();
}

class _ArtifactComplianceCardGen04180State extends State<ArtifactComplianceCardGen04180> {
  ArtifactComplianceData? _data;
  bool _isLoading = true;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _loadData();
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) => _loadData());
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final data = await MockArtifactRepository.fetchComplianceStatus();
      if (mounted) {
        setState(() {
          _data = data;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Color _statusColor(ArtifactComplianceStatus status, ColorScheme colorScheme) {
    switch (status) {
      case ArtifactComplianceStatus.pass:
        return colorScheme.primary;
      case ArtifactComplianceStatus.fail:
        return colorScheme.error;
      case ArtifactComplianceStatus.pending:
        return colorScheme.tertiary;
    }
  }

  String _statusLabel(ArtifactComplianceStatus status) {
    switch (status) {
      case ArtifactComplianceStatus.pass:
        return 'Pass';
      case ArtifactComplianceStatus.fail:
        return 'Fail';
      case ArtifactComplianceStatus.pending:
        return 'Pending';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 840;

        return RefreshIndicator(
          onRefresh: _loadData,
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
                  child: _isLoading && _data == null
                      ? const Center(child: CircularProgressIndicator())
                      : _buildContent(theme, colorScheme, isDesktop),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(ThemeData theme, ColorScheme colorScheme, bool isDesktop) {
    final data = _data!;

    final header = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            'System Safety & Alert Governance',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Chip(
          avatar: Icon(
            data.status == ArtifactComplianceStatus.pass ? Icons.check_circle : Icons.error,
            size: 18,
            color: _statusColor(data.status, colorScheme),
          ),
          label: Text(
            _statusLabel(data.status),
            style: theme.textTheme.labelLarge?.copyWith(
              color: _statusColor(data.status, colorScheme),
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: _statusColor(data.status, colorScheme).withOpacity(0.12),
          side: BorderSide.none,
        ),
      ],
    );

    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRow('Package ID', data.packageId, theme),
        const SizedBox(height: 12),
        _buildDetailRow('Metric', data.metricName, theme),
        const SizedBox(height: 12),
        _buildDetailRow('Standard', 'ISO/IEC 12207', theme),
        const SizedBox(height: 12),
        _buildDetailRow('Last Checked', _formatTimestamp(data.timestamp), theme),
        const SizedBox(height: 12),
        _buildDetailRow('Session', data.sessionId, theme),
      ],
    );

    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 2, child: header),
          const SizedBox(width: 32),
          Expanded(flex: 3, child: details),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        header,
        const SizedBox(height: 24),
        details,
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  String _formatTimestamp(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
  }
}
