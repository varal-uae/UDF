// GEN-01247 — Gateway Tokenization Status Card.
// Displays PCI-DSS field tokenization compliance status using M3 ElevatedCard with 30-second background polling and pull-to-refresh support.

import 'dart:async';
import 'package:flutter/material.dart';

enum _TokenizationStatus { pass, fail, pending }

class _MockTokenizationData {
  final String traceId;
  final String cardLastFour;
  final String token;
  final _TokenizationStatus status;
  final DateTime timestamp;

  const _MockTokenizationData({
    required this.traceId,
    required this.cardLastFour,
    required this.token,
    required this.status,
    required this.timestamp,
  });
}

class _MockTokenizationRepository {
  static Future<_MockTokenizationData> fetchComplianceStatus() async {
    await Future.delayed(const Duration(milliseconds: 85));
    return _MockTokenizationData(
      traceId: 'trace-8a7b6c5d-01247',
      cardLastFour: '4242',
      token: 'tok_pci_dss_v4_mock_998877',
      status: _TokenizationStatus.pass,
      timestamp: DateTime.now(),
    );
  }
}

class GatewayTokenizationCardGen01247 extends StatefulWidget {
  const GatewayTokenizationCardGen01247({super.key});

  @override
  State<GatewayTokenizationCardGen01247> createState() => _GatewayTokenizationCardGen01247State();
}

class _GatewayTokenizationCardGen01247State extends State<GatewayTokenizationCardGen01247> {
  _MockTokenizationData? _data;
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
      final data = await _MockTokenizationRepository.fetchComplianceStatus();
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

  Color _statusColor(BuildContext context, _TokenizationStatus status) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (status) {
      case _TokenizationStatus.pass:
        return colorScheme.primary;
      case _TokenizationStatus.fail:
        return colorScheme.error;
      case _TokenizationStatus.pending:
        return colorScheme.tertiary;
    }
  }

  String _statusLabel(_TokenizationStatus status) {
    switch (status) {
      case _TokenizationStatus.pass:
        return 'Pass';
      case _TokenizationStatus.fail:
        return 'Fail';
      case _TokenizationStatus.pending:
        return 'Pending';
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PCI-DSS Field Tokenization Compliance',
                style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 3.0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: _isLoading && _data == null
                      ? const Center(child: CircularProgressIndicator())
                      : _buildContent(context, colorScheme, textTheme),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    final data = _data;
    if (data == null) {
      return const Center(child: Text('No data available'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text('Gateway Tokenization', style: textTheme.titleMedium),
            ),
            Chip(
              label: Text(
                _statusLabel(data.status),
                style: TextStyle(color: colorScheme.onPrimary, fontWeight: FontWeight.bold),
              ),
              backgroundColor: _statusColor(context, data.status),
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
          ],
        ),
        const Divider(height: 32),
        _InfoRow(label: 'Trace ID', value: data.traceId, textTheme: textTheme),
        const SizedBox(height: 12),
        _InfoRow(label: 'Card Last Four', value: '**** **** **** ${data.cardLastFour}', textTheme: textTheme),
        const SizedBox(height: 12),
        _InfoRow(label: 'Secure Token', value: data.token, textTheme: textTheme),
        const SizedBox(height: 12),
        _InfoRow(
          label: 'Timestamp',
          value: '${data.timestamp.year}-${data.timestamp.month.toString().padLeft(2, '0')}-${data.timestamp.day.toString().padLeft(2, '0')} ${data.timestamp.hour.toString().padLeft(2, '0')}:${data.timestamp.minute.toString().padLeft(2, '0')}:${data.timestamp.second.toString().padLeft(2, '0')}',
          textTheme: textTheme,
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: FilledButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Deep-link drill-down triggered for trace_id'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              );
            },
            icon: const Icon(Icons.open_in_new, size: 20),
            label: const Text('View Details'),
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final TextTheme textTheme;

  const _InfoRow({required this.label, required this.value, required this.textTheme});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(label, style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
        ),
        Expanded(
          child: Text(value, style: textTheme.bodyMedium),
        ),
      ],
    );
  }
}