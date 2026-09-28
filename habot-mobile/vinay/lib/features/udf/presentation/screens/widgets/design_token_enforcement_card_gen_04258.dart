// GEN-04258 — Design Token Enforcement Status Card.
// Displays M3 Elevated Card with compliance status for private NPM design token enforcement, rejecting local CSS or hardcoded hex colors. Single-column mobile layout with 30s background polling and pull-to-refresh support.

import 'dart:async';
import 'package:flutter/material.dart';

enum ComplianceStatus { complete, partial, notComplete }

class DesignTokenEnforcementData {
  final String atomicId;
  final String globalRefId;
  final String metricName;
  final ComplianceStatus status;
  final DateTime lastChecked;
  final String description;

  const DesignTokenEnforcementData({
    required this.atomicId,
    required this.globalRefId,
    required this.metricName,
    required this.status,
    required this.lastChecked,
    required this.description,
  });
}

class MockDesignTokenRepository {
  static const DesignTokenEnforcementData mockData = DesignTokenEnforcementData(
    atomicId: 'GEN-04258',
    globalRefId: 'GEN-04258',
    metricName: 'General Process/Operational Compliance',
    status: ComplianceStatus.complete,
    lastChecked: null,
    description:
        'Enforce private NPM design token package imports, rejecting local CSS or hardcoded hex colors.',
  );

  Future<DesignTokenEnforcementData> fetchComplianceStatus() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return DesignTokenEnforcementData(
      atomicId: mockData.atomicId,
      globalRefId: mockData.globalRefId,
      metricName: mockData.metricName,
      status: mockData.status,
      lastChecked: DateTime.now(),
      description: mockData.description,
    );
  }
}

class DesignTokenEnforcementCard extends StatefulWidget {
  const DesignTokenEnforcementCard({super.key});

  @override
  State<DesignTokenEnforcementCard> createState() =>
      _DesignTokenEnforcementCardState();
}

class _DesignTokenEnforcementCardState
    extends State<DesignTokenEnforcementCard> {
  final MockDesignTokenRepository _repository = MockDesignTokenRepository();
  DesignTokenEnforcementData? _data;
  bool _isLoading = true;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _loadData();
    _startPolling();
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
      final data = await _repository.fetchComplianceStatus();
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

  void _startPolling() {
    _pollingTimer =
        Timer.periodic(const Duration(seconds: 30), (_) => _loadData());
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

  IconData _getStatusIcon(ComplianceStatus status) {
    switch (status) {
      case ComplianceStatus.complete:
        return Icons.check_circle_outline;
      case ComplianceStatus.partial:
        return Icons.warning_amber_rounded;
      case ComplianceStatus.notComplete:
        return Icons.error_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 600;
              return _buildCard(
                colorScheme,
                textTheme,
                isMobile,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCard(
    ColorScheme colorScheme,
    TextTheme textTheme,
    bool isMobile,
  ) {
    return Card(
      elevation: 3.0,
      clipBehavior: Clip.antiAlias,
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Design Token Enforcement',
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        _data?.atomicId ?? 'GEN-04258',
                        style: textTheme.labelMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!_isLoading && _data != null)
                  _buildStatusChip(colorScheme, _data!.status),
              ],
            ),
            const SizedBox(height: 16.0),
            Divider(color: colorScheme.outlineVariant, height: 1.0),
            const SizedBox(height: 16.0),
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_data == null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: Column(
                    children: [
                      Icon(Icons.error_outline,
                          size: 48.0, color: colorScheme.error),
                      const SizedBox(height: 8.0),
                      Text('Failed to load compliance data.',
                          style: TextStyle(color: colorScheme.error)),
                      const SizedBox(height: 16.0),
                      FilledButton.tonal(
                        onPressed: _loadData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
            else
              _buildContent(textTheme, colorScheme, _data!, isMobile),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(ColorScheme colorScheme, ComplianceStatus status) {
    return Chip(
      avatar: Icon(
        _getStatusIcon(status),
        size: 18.0,
        color: _getStatusColor(status, colorScheme),
      ),
      label: Text(
        _getStatusLabel(status),
        style: TextStyle(
          color: _getStatusColor(status, colorScheme),
          fontWeight: FontWeight.w600,
          fontSize: 12.0,
        ),
      ),
      backgroundColor:
          _getStatusColor(status, colorScheme).withValues(alpha: 0.12),
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
    );
  }

  Widget _buildContent(
    TextTheme textTheme,
    ColorScheme colorScheme,
    DesignTokenEnforcementData data,
    bool isMobile,
  ) {
    final items = <Widget>[
      _buildInfoRow(
        'Metric Name',
        data.metricName,
        textTheme,
        colorScheme,
      ),
      const SizedBox(height: 12.0),
      _buildInfoRow(
        'Global Reference ID',
        data.globalRefId,
        textTheme,
        colorScheme,
      ),
      const SizedBox(height: 12.0),
      _buildInfoRow(
        'Description',
        data.description,
        textTheme,
        colorScheme,
      ),
      const SizedBox(height: 12.0),
      _buildInfoRow(
        'Last Checked',
        data.lastChecked != null
            ? '${data.lastChecked!.toLocal()}'.split('.').first
            : 'N/A',
        textTheme,
        colorScheme,
      ),
      const SizedBox(height: 12.0),
      _buildInfoRow(
        'Governance Gate',
        'Binary – 100% CI/CD Pass Required',
        textTheme,
        colorScheme,
      ),
      const SizedBox(height: 12.0),
      _buildInfoRow(
        'Standard',
        'ITIL v4 General Management Practices',
        textTheme,
        colorScheme,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items,
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4.0),
        Text(
          value,
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}