// GEN-04102 — Property-Based Testing Tool Selection Card for Mobile Engineering Console.
// Displays M3 Elevated Card with status chip, mock KPI data, 30s polling simulation, and responsive single/multi-column layout.

import 'dart:async';
import 'package:flutter/material.dart';

enum ToolIntegrationStatus { pass, fail, pending }

class MockTestingToolData {
  final String toolName;
  final String framework;
  final ToolIntegrationStatus status;
  final double metricValue;
  final DateTime lastChecked;

  const MockTestingToolData({
    required this.toolName,
    required this.framework,
    required this.status,
    required this.metricValue,
    required this.lastChecked,
  });
}

class PropertyTestingToolCardGen04102 extends StatefulWidget {
  const PropertyTestingToolCardGen04102({super.key});

  @override
  State<PropertyTestingToolCardGen04102> createState() => _PropertyTestingToolCardGen04102State();
}

class _PropertyTestingToolCardGen04102State extends State<PropertyTestingToolCardGen04102> {
  late MockTestingToolData _toolData;
  Timer? _pollingTimer;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _toolData = _getMockData();
    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  MockTestingToolData _getMockData() {
    return MockTestingToolData(
      toolName: 'Kea2',
      framework: 'Property-Based Testing Frameworks',
      status: ToolIntegrationStatus.pass,
      metricValue: 1.0,
      lastChecked: DateTime.now(),
    );
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _refreshData();
    });
  }

  Future<void> _refreshData() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      setState(() {
        _toolData = MockTestingToolData(
          toolName: _toolData.toolName,
          framework: _toolData.framework,
          status: _toolData.status,
          metricValue: _toolData.metricValue,
          lastChecked: DateTime.now(),
        );
        _isRefreshing = false;
      });
    }
  }

  Color _statusColor(BuildContext context, ToolIntegrationStatus status) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (status) {
      case ToolIntegrationStatus.pass:
        return colorScheme.primary;
      case ToolIntegrationStatus.fail:
        return colorScheme.error;
      case ToolIntegrationStatus.pending:
        return colorScheme.tertiary;
    }
  }

  String _statusLabel(ToolIntegrationStatus status) {
    switch (status) {
      case ToolIntegrationStatus.pass:
        return 'Pass';
      case ToolIntegrationStatus.fail:
        return 'Fail';
      case ToolIntegrationStatus.pending:
        return 'Pending';
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 840;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Engineering Console',
                  style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                if (isDesktop)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildKpiCard(context, textTheme, colorScheme)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildDetailsCard(context, textTheme, colorScheme)),
                    ],
                  )
                else
                  Column(
                    children: [
                      _buildKpiCard(context, textTheme, colorScheme),
                      const SizedBox(height: 16),
                      _buildDetailsCard(context, textTheme, colorScheme),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildKpiCard(BuildContext context, TextTheme textTheme, ColorScheme colorScheme) {
    return Card(
      elevation: 3.0,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Tooling Integration Success', style: textTheme.titleMedium),
                Chip(
                  avatar: Icon(
                    _toolData.status == ToolIntegrationStatus.pass ? Icons.check_circle : Icons.error_outline,
                    size: 18,
                    color: _statusColor(context, _toolData.status),
                  ),
                  label: Text(_statusLabel(_toolData.status)),
                  backgroundColor: _statusColor(context, _toolData.status).withOpacity(0.1),
                  labelStyle: TextStyle(color: _statusColor(context, _toolData.status)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Metric Value: ${_toolData.metricValue.toStringAsFixed(1)}', style: textTheme.bodyLarge),
            const SizedBox(height: 8),
            Text('Floor Threshold: 1.0', style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
            const SizedBox(height: 16),
            if (_isRefreshing)
              const LinearProgressIndicator()
            else
              const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard(BuildContext context, TextTheme textTheme, ColorScheme colorScheme) {
    return Card(
      elevation: 3.0,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Configuration Details', style: textTheme.titleMedium),
            const Divider(height: 24),
            _buildDetailRow('Selected Tool', _toolData.toolName, textTheme),
            _buildDetailRow('Framework Standard', _toolData.framework, textTheme),
            _buildDetailRow('Last Checked', '${_toolData.lastChecked.hour}:${_toolData.lastChecked.minute.toString().padLeft(2, '0')}', textTheme),
            _buildDetailRow('Step ID', 'GEN-04102', textTheme),
            const SizedBox(height: 24),
            SizedBox(
              height: 48,
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _showConfigBottomSheet(context),
                icon: const Icon(Icons.settings, size: 20),
                label: const Text('Configure Tool'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: textTheme.bodyMedium),
          Text(value, style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  void _showConfigBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 32,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text('Configure Property Testing', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Tool Name',
                  hintText: _toolData.toolName,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Framework Reference',
                  hintText: _toolData.framework,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 48,
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Configuration saved successfully.'),
                        behavior: SnackBarBehavior.floating,
                        action: SnackBarAction(
                          label: 'Dismiss',
                          onPressed: () {},
                        ),
                      ),
                    );
                  },
                  child: const Text('Save Configuration'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}