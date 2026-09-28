// GEN-03739 — Component Library Publish Status Card.
// Displays the deployment SLA status of @habot/intercompany-recon-core using M3 Elevated Cards, responsive single/multi-column layout, and 30-second polling with pull-to-refresh.

import 'dart:async';
import 'package:flutter/material.dart';

enum DeploymentStatus { pass, fail }

class ComponentDeploymentData {
  final String packageName;
  final DeploymentStatus status;
  final double slaMetric;
  final DateTime timestamp;
  final String traceId;

  const ComponentDeploymentData({
    required this.packageName,
    required this.status,
    required this.slaMetric,
    required this.timestamp,
    required this.traceId,
  });
}

class MockDeploymentRepository {
  static ComponentDeploymentData fetchStatus() {
    return ComponentDeploymentData(
      packageName: '@habot/intercompany-recon-core',
      status: DeploymentStatus.pass,
      slaMetric: 0.9999,
      timestamp: DateTime.now(),
      traceId: 'trace-gen-03739-${DateTime.now().millisecondsSinceEpoch}',
    );
  }
}

class ComponentLibraryStatusCard extends StatefulWidget {
  const ComponentLibraryStatusCard({super.key});

  @override
  State<ComponentLibraryStatusCard> createState() => _ComponentLibraryStatusCardState();
}

class _ComponentLibraryStatusCardState extends State<ComponentLibraryStatusCard> {
  late ComponentDeploymentData _data;
  Timer? _pollingTimer;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _data = MockDeploymentRepository.fetchStatus();
    _startPolling();
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _refreshData();
    });
  }

  Future<void> _refreshData() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);
    
    await Future.delayed(const Duration(milliseconds: 60)); // Simulate sub-100ms latency
    
    if (mounted) {
      setState(() {
        _data = MockDeploymentRepository.fetchStatus();
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
    final isPass = _data.status == DeploymentStatus.pass;

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;
          final isDesktop = constraints.maxWidth >= 840;

          if (isDesktop) {
            return _buildMultiColumnLayout(theme, colorScheme, isPass);
          }
          return _buildSingleColumnLayout(theme, colorScheme, isPass, isMobile);
        },
      ),
    );
  }

  Widget _buildSingleColumnLayout(ThemeData theme, ColorScheme colorScheme, bool isPass, bool isMobile) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(theme, colorScheme, isPass),
          const SizedBox(height: 16),
          _buildMetricsCard(theme, colorScheme, isPass),
          const SizedBox(height: 16),
          _buildDetailsCard(theme, colorScheme),
        ],
      ),
    );
  }

  Widget _buildMultiColumnLayout(ThemeData theme, ColorScheme colorScheme, bool isPass) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(theme, colorScheme, isPass),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildMetricsCard(theme, colorScheme, isPass)),
              const SizedBox(width: 24),
              Expanded(child: _buildDetailsCard(theme, colorScheme)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, ColorScheme colorScheme, bool isPass) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            'Component Library Status',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (_isRefreshing)
          const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        else
          Chip(
            avatar: Icon(
              isPass ? Icons.check_circle_outline : Icons.error_outline,
              size: 18,
              color: isPass ? colorScheme.primary : colorScheme.error,
            ),
            label: Text(
              isPass ? 'PASS' : 'FAIL',
              style: theme.textTheme.labelLarge?.copyWith(
                color: isPass ? colorScheme.primary : colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: isPass
                ? colorScheme.primaryContainer.withOpacity(0.3)
                : colorScheme.errorContainer.withOpacity(0.3),
            side: BorderSide.none,
          ),
      ],
    );
  }

  Widget _buildMetricsCard(ThemeData theme, ColorScheme colorScheme, bool isPass) {
    return Card(
      elevation: 3.0, // M3 Elevated Card Level 2 (3dp)
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Private NPM Deployment SLA',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${(_data.slaMetric * 100).toStringAsFixed(3)}%',
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isPass ? colorScheme.primary : colorScheme.error,
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6.0),
                  child: Text(
                    '/ Target: 99.99%',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: _data.slaMetric.clamp(0.0, 1.0),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
              backgroundColor: colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(
                isPass ? colorScheme.primary : colorScheme.error,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard(ThemeData theme, ColorScheme colorScheme) {
    return Card(
      elevation: 3.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Deployment Details',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Divider(height: 32),
            _buildDetailRow(theme, 'Package', _data.packageName),
            const SizedBox(height: 16),
            _buildDetailRow(theme, 'Trace ID', _data.traceId),
            const SizedBox(height: 16),
            _buildDetailRow(
              theme,
              'Last Checked',
              '${_data.timestamp.hour.toString().padLeft(2, '0')}:${_data.timestamp.minute.toString().padLeft(2, '0')}:${_data.timestamp.second.toString().padLeft(2, '0')}',
            ),
            const SizedBox(height: 16),
            _buildDetailRow(theme, 'Standard', 'NPM Private Registry SLA'),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48, // 48x48dp touch target
              child: FilledButton.tonalIcon(
                onPressed: () => _showConfigBottomSheet(theme),
                icon: const Icon(Icons.settings_outlined, size: 20),
                label: const Text('View Configuration'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(ThemeData theme, String label, String value) {
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

  void _showConfigBottomSheet(ThemeData theme) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Step Configuration',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Text(
                'Publish/store the component in the common library: Package ${_data.packageName}.',
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Configuration synced successfully.'),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        action: SnackBarAction(
                          label: 'DISMISS',
                          onPressed: () {},
                        ),
                      ),
                    );
                  },
                  child: const Text('Apply & Sync'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}