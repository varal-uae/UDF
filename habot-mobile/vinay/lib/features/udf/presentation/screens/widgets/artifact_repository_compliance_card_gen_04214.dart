// GEN-04214 — Artifact Repository Compliance Status Card.
// Displays the compliance status of storing artifacts in @habot/mobile-feature-flags using M3 ElevatedCard, status chips, and responsive single/multi-column layout with 30s polling and pull-to-refresh.

import 'dart:async';
import 'package:flutter/material.dart';

enum _ComplianceStatus { pass, fail, pending }

class _MockArtifactData {
  final String repository;
  final String metricName;
  final _ComplianceStatus status;
  final DateTime timestamp;
  final String traceId;

  const _MockArtifactData({
    required this.repository,
    required this.metricName,
    required this.status,
    required this.timestamp,
    required this.traceId,
  });
}

class ArtifactRepositoryComplianceCardGen04214 extends StatefulWidget {
  const ArtifactRepositoryComplianceCardGen04214({super.key});

  @override
  State<ArtifactRepositoryComplianceCardGen04214> createState() =>
      _ArtifactRepositoryComplianceCardGen04214State();
}

class _ArtifactRepositoryComplianceCardGen04214State
    extends State<ArtifactRepositoryComplianceCardGen04214> {
  late _MockArtifactData _data;
  Timer? _pollingTimer;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _data = _fetchMockData();
    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  _MockArtifactData _fetchMockData() {
    return _MockArtifactData(
      repository: '@habot/mobile-feature-flags',
      metricName: 'Artifact Repository Compliance',
      status: _ComplianceStatus.pass,
      timestamp: DateTime.now(),
      traceId: 'trace-gen-04214-${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) {
        setState(() {
          _data = _fetchMockData();
        });
      }
    });
  }

  Future<void> _handleRefresh() async {
    setState(() => _isRefreshing = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      setState(() {
        _data = _fetchMockData();
        _isRefreshing = false;
      });
    }
  }

  Color _statusColor(BuildContext context, _ComplianceStatus status) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (status) {
      case _ComplianceStatus.pass:
        return colorScheme.primary;
      case _ComplianceStatus.fail:
        return colorScheme.error;
      case _ComplianceStatus.pending:
        return colorScheme.tertiary;
    }
  }

  String _statusLabel(_ComplianceStatus status) {
    switch (status) {
      case _ComplianceStatus.pass:
        return 'Pass';
      case _ComplianceStatus.fail:
        return 'Fail';
      case _ComplianceStatus.pending:
        return 'Pending';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isDesktop = screenWidth >= 840;

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: isDesktop
            ? _buildMultiColumnLayout(context)
            : _buildSingleColumnLayout(context),
      ),
    );
  }

  Widget _buildSingleColumnLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildKpiCard(context),
        const SizedBox(height: 16),
        _buildDetailsCard(context),
      ],
    );
  }

  Widget _buildMultiColumnLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildKpiCard(context)),
        const SizedBox(width: 24),
        Expanded(child: _buildDetailsCard(context)),
      ],
    );
  }

  Widget _buildKpiCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 3.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Step Health',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  _data.status == _ComplianceStatus.pass
                      ? Icons.check_circle_outline
                      : _data.status == _ComplianceStatus.fail
                          ? Icons.error_outline
                          : Icons.pending_outlined,
                  size: 48,
                  color: _statusColor(context, _data.status),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _data.metricName,
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Chip(
                      label: Text(
                        _statusLabel(_data.status),
                        style: TextStyle(
                          color: _statusColor(context, _data.status),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      backgroundColor: _statusColor(context, _data.status)
                          .withOpacity(0.12),
                      side: BorderSide.none,
                    ),
                  ],
                ),
              ],
            ),
            if (_isRefreshing) ...[
              const SizedBox(height: 16),
              const LinearProgressIndicator(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 3.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Configuration Details',
              style: theme.textTheme.titleMedium,
            ),
            const Divider(height: 32),
            _buildDetailRow('Repository', _data.repository),
            _buildDetailRow('Standard', 'ISO/IEC 12207'),
            _buildDetailRow('Governance Gate', 'Binary (Pass/Fail)'),
            _buildDetailRow('Trace ID', _data.traceId),
            _buildDetailRow(
              'Last Updated',
              '${_data.timestamp.hour}:${_data.timestamp.minute.toString().padLeft(2, '0')}:${_data.timestamp.second.toString().padLeft(2, '0')}',
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 48,
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _showConfigBottomSheet(context),
                icon: const Icon(Icons.settings, size: 24),
                label: const Text('View Configuration'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Flexible(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey.shade700),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _showConfigBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Artifact Configuration',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.storage, size: 48),
                          title: const Text('Target Repository'),
                          subtitle: const Text('@habot/mobile-feature-flags'),
                          contentPadding: EdgeInsets.zero,
                        ),
                        ListTile(
                          leading: const Icon(Icons.verified, size: 48),
                          title: const Text('Compliance Standard'),
                          subtitle:
                              const Text('ISO/IEC 12207 Software Life Cycle'),
                          contentPadding: EdgeInsets.zero,
                        ),
                        ListTile(
                          leading: const Icon(Icons.timer, size: 48),
                          title: const Text('Polling Interval'),
                          subtitle: const Text('30 seconds'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 48,
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Configuration acknowledged.'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: const Text('Close'),
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
}