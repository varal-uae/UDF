// GEN-04192 — Completion Measure Verification Card for Engineering Console.
// Displays M3 Elevated Card with status chip, background polling every 30s, and pull-to-refresh. Single-column mobile layout (<600dp), multi-column desktop (≥840dp).

import 'dart:async';
import 'package:flutter/material.dart';

enum CompletionStatus { pass, fail, pending }

class CompletionMeasureData {
  final String atomicId;
  final String stepName;
  final CompletionStatus status;
  final DateTime timestamp;
  final int customCssGridOverrides;

  const CompletionMeasureData({
    required this.atomicId,
    required this.stepName,
    required this.status,
    required this.timestamp,
    required this.customCssGridOverrides,
  });
}

class MockCompletionRepository {
  static Future<CompletionMeasureData> fetchVerificationData() async {
    await Future.delayed(const Duration(milliseconds: 80));
    return CompletionMeasureData(
      atomicId: 'GEN-04192',
      stepName: 'Verify the completion measure: 0 custom CSS grid overrides.',
      status: CompletionStatus.pass,
      timestamp: DateTime.now(),
      customCssGridOverrides: 0,
    );
  }
}

class CompletionMeasureCardGen04192 extends StatefulWidget {
  const CompletionMeasureCardGen04192({super.key});

  @override
  State<CompletionMeasureCardGen04192> createState() => _CompletionMeasureCardGen04192State();
}

class _CompletionMeasureCardGen04192State extends State<CompletionMeasureCardGen04192> {
  CompletionMeasureData? _data;
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
      final data = await MockCompletionRepository.fetchVerificationData();
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

  Color _statusColor(CompletionStatus status, ThemeData theme) {
    switch (status) {
      case CompletionStatus.pass:
        return theme.colorScheme.primary;
      case CompletionStatus.fail:
        return theme.colorScheme.error;
      case CompletionStatus.pending:
        return theme.colorScheme.tertiary;
    }
  }

  String _statusLabel(CompletionStatus status) {
    switch (status) {
      case CompletionStatus.pass:
        return 'Pass';
      case CompletionStatus.fail:
        return 'Fail';
      case CompletionStatus.pending:
        return 'Pending';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isDesktop = screenWidth >= 840;

    return RefreshIndicator(
      onRefresh: _loadData,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final card = _buildCard(theme, isDesktop);
          if (isDesktop) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: card),
                    const SizedBox(width: 16),
                    Expanded(child: _buildDetailsPanel(theme)),
                  ],
                ),
              ),
            );
          }
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: card,
            ),
          );
        },
      ),
    );
  }

  Widget _buildCard(ThemeData theme, bool isDesktop) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Completion Measure Verification',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (_data != null)
                  Chip(
                    avatar: Icon(
                      _data!.status == CompletionStatus.pass ? Icons.check_circle : Icons.error,
                      size: 18,
                      color: _statusColor(_data!.status, theme),
                    ),
                    label: Text(
                      _statusLabel(_data!.status),
                      style: TextStyle(color: _statusColor(_data!.status, theme)),
                    ),
                    backgroundColor: _statusColor(_data!.status, theme).withOpacity(0.12),
                    side: BorderSide.none,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_data != null) ...[
              Text(
                _data!.stepName,
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.data_object, size: 20, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Text(
                    'Custom CSS Grid Overrides: ${_data!.customCssGridOverrides}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.access_time, size: 20, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Text(
                    'Last Verified: ${_formatTimestamp(_data!.timestamp)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.tag, size: 20, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Text(
                    'Atomic ID: ${_data!.atomicId}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ] else
              Text('No data available.', style: theme.textTheme.bodyMedium),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                height: 48,
                width: 48,
                child: IconButton(
                  icon: const Icon(Icons.open_in_new),
                  tooltip: 'Drill-down details',
                  onPressed: () => _showBottomSheet(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsPanel(ThemeData theme) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Standard Reference', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            Text('ISO/IEC 25010 Quality-in-Use', style: theme.textTheme.bodyMedium),
            Text('Definition of Done (Agile/Scrum Guide)', style: theme.textTheme.bodyMedium),
            const SizedBox(height: 16),
            Text('Metric Configuration', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            Text('Floor Boundary: N/A', style: theme.textTheme.bodyMedium),
            Text('Optimal Target: 0 custom CSS grid overrides', style: theme.textTheme.bodyMedium),
            Text('Ceiling Boundary: N/A', style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(ctx).bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Configuration Details',
                style: Theme.of(ctx).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Text('Atomic ID: GEN-04192'),
              const SizedBox(height: 8),
              Text('Dependency: GEN-04191'),
              const SizedBox(height: 8),
              Text('Expected Output: Fully configured and validated implementation.'),
              const SizedBox(height: 8),
              Text('Completion Measures: 100% CI/CD pass rate.'),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Close'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  String _formatTimestamp(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
  }
}
