// GEN-02155 — Resume Schema Comparison Status Card.
// Displays the result of comparing parsed resume JSON against Job Requisition Schema requirements using M3 ElevatedCard and StatusChip. Implements single-column mobile layout (<600dp) with 48x48dp touch targets, 30-second background polling, and pull-to-refresh.

import 'dart:async';
import 'package:flutter/material.dart';

enum SchemaValidationStatus { pass, fail }

class SchemaComparisonResult {
  final String atomicId;
  final String metricName;
  final double passRate;
  final SchemaValidationStatus status;
  final DateTime timestamp;
  final String traceId;

  const SchemaComparisonResult({
    required this.atomicId,
    required this.metricName,
    required this.passRate,
    required this.status,
    required this.timestamp,
    required this.traceId,
  });
}

class MockSchemaComparisonRepository {
  static Future<SchemaComparisonResult> fetchComparisonResult() async {
    await Future.delayed(const Duration(milliseconds: 80)); // Sub-100ms mock latency
    return SchemaComparisonResult(
      atomicId: 'GEN-02155',
      metricName: 'Schema/Lineage Validation Pass Rate',
      passRate: 0.98,
      status: SchemaValidationStatus.pass,
      timestamp: DateTime.now(),
      traceId: 'trace-gen-02155-${DateTime.now().millisecondsSinceEpoch}',
    );
  }
}

class ResumeSchemaComparisonCard extends StatefulWidget {
  const ResumeSchemaComparisonCard({super.key});

  @override
  State<ResumeSchemaComparisonCard> createState() => _ResumeSchemaComparisonCardState();
}

class _ResumeSchemaComparisonCardState extends State<ResumeSchemaComparisonCard> {
  SchemaComparisonResult? _result;
  bool _isLoading = true;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _loadData();
    _startPolling();
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) _loadData();
    });
  }

  Future<void> _loadData() async {
    try {
      final result = await MockSchemaComparisonRepository.fetchComparisonResult();
      if (mounted) {
        setState(() {
          _result = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _onRefresh() async {
    setState(() => _isLoading = true);
    await _loadData();
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
    final isMobile = MediaQuery.sizeOf(context).width < 600;

    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: colorScheme.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final useSingleColumn = isMobile || constraints.maxWidth < 600;

              if (_isLoading && _result == null) {
                return const Center(child: CircularProgressIndicator());
              }

              if (_result == null) {
                return Text('No data available', style: theme.textTheme.bodyLarge);
              }

              final result = _result!;
              final isPass = result.status == SchemaValidationStatus.pass;
              final chipColor = isPass ? colorScheme.primaryContainer : colorScheme.errorContainer;
              final chipTextColor = isPass ? colorScheme.onPrimaryContainer : colorScheme.onErrorContainer;

              final cardContent = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Schema Validation',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Semantics(
                        label: isPass ? 'Validation Passed' : 'Validation Failed',
                        child: Chip(
                          label: Text(isPass ? 'Pass' : 'Fail'),
                          backgroundColor: chipColor,
                          labelStyle: TextStyle(color: chipTextColor),
                          side: BorderSide.none,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Atomic ID: ${result.atomicId}',
                    style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Metric: ${result.metricName}',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: result.passRate.clamp(0.0, 1.0),
                    minHeight: 8,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(isPass ? colorScheme.primary : colorScheme.error),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pass Rate: ${(result.passRate * 100).toStringAsFixed(2)}% (Floor: 95%)',
                    style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Trace ID: ${result.traceId}',
                    style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.outline),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Last Updated: ${result.timestamp.toLocal().toString().split('.').first}',
                    style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.outline),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 48, // 48x48dp touch target
                    width: useSingleColumn ? double.infinity : null,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Drill-down navigation triggered.'),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: colorScheme.inverseSurface,
                          ),
                        );
                      },
                      icon: const Icon(Icons.open_in_new, size: 20),
                      label: const Text('View Details'),
                    ),
                  ),
                ],
              );

              return Card(
                elevation: 3.0, // M3 Elevated Cards Level 2 (3dp)
                surfaceTintColor: colorScheme.surfaceTint,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: useSingleColumn
                      ? cardContent
                      : IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(flex: 2, child: cardContent),
                              const VerticalDivider(width: 32),
                              Expanded(
                                flex: 1,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      isPass ? Icons.check_circle_outline : Icons.error_outline,
                                      size: 64,
                                      color: isPass ? colorScheme.primary : colorScheme.error,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      isPass ? 'Compliant' : 'Non-Compliant',
                                      style: theme.textTheme.titleSmall,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
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