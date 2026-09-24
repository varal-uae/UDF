// GEN-02166 — Backward Data Lineage M3 Status Card.
// Displays trace backward data lineage from Offer Document to Source Requisition with M3 Elevated Card, status chips, and 30s polling refresh.

import 'dart:async';
import 'package:flutter/material.dart';

enum LineageValidationStatus { pass, fail, pending }

class LineageValidationResult {
  final String traceId;
  final String sourceRequisition;
  final String offerDocument;
  final LineageValidationStatus status;
  final double passRate;
  final DateTime timestamp;

  const LineageValidationResult({
    required this.traceId,
    required this.sourceRequisition,
    required this.offerDocument,
    required this.status,
    required this.passRate,
    required this.timestamp,
  });
}

class MockLineageRepository {
  static const List<LineageValidationResult> mockData = [
    LineageValidationResult(
      traceId: 'trace-001-gen-02166',
      sourceRequisition: 'REQ-2026-09-001',
      offerDocument: 'OFFER-DOC-8842',
      status: LineageValidationStatus.pass,
      passRate: 0.998,
      timestamp: DateTime(2026, 9, 24, 10, 15),
    ),
    LineageValidationResult(
      traceId: 'trace-002-gen-02166',
      sourceRequisition: 'REQ-2026-09-002',
      offerDocument: 'OFFER-DOC-8843',
      status: LineageValidationStatus.fail,
      passRate: 0.82,
      timestamp: DateTime(2026, 9, 24, 10, 16),
    ),
    LineageValidationResult(
      traceId: 'trace-003-gen-02166',
      sourceRequisition: 'REQ-2026-09-003',
      offerDocument: 'OFFER-DOC-8844',
      status: LineageValidationStatus.pass,
      passRate: 0.999,
      timestamp: DateTime(2026, 9, 24, 10, 17),
    ),
  ];

  Future<List<LineageValidationResult>> fetchLineageResults() async {
    await Future.delayed(const Duration(milliseconds: 80));
    return mockData;
  }
}

class BackwardLineageCardGen02166 extends StatefulWidget {
  const BackwardLineageCardGen02166({super.key});

  @override
  State<BackwardLineageCardGen02166> createState() => _BackwardLineageCardGen02166State();
}

class _BackwardLineageCardGen02166State extends State<BackwardLineageCardGen02166> {
  final MockLineageRepository _repository = MockLineageRepository();
  List<LineageValidationResult> _results = [];
  bool _isLoading = true;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _fetchData();
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) => _fetchData());
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
      final data = await _repository.fetchLineageResults();
      if (mounted) {
        setState(() {
          _results = data;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _onRefresh() async {
    await _fetchData();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Lineage data synchronized successfully.'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Color _statusColor(BuildContext context, LineageValidationStatus status) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (status) {
      case LineageValidationStatus.pass:
        return colorScheme.primary;
      case LineageValidationStatus.fail:
        return colorScheme.error;
      case LineageValidationStatus.pending:
        return colorScheme.tertiary;
    }
  }

  String _statusLabel(LineageValidationStatus status) {
    switch (status) {
      case LineageValidationStatus.pass:
        return 'Pass';
      case LineageValidationStatus.fail:
        return 'Fail';
      case LineageValidationStatus.pending:
        return 'Pending';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: colorScheme.primary,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 840;
          final crossAxisCount = isDesktop ? 2 : 1;

          if (_isLoading && _results.isEmpty) {
            return SizedBox(
              height: 300,
              child: Center(
                child: CircularProgressIndicator(color: colorScheme.primary),
              ),
            );
          }

          return GridView.builder(
            shrinkWrap: true,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: isDesktop ? 2.8 : 2.2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: _results.length,
            itemBuilder: (context, index) {
              final item = _results[index];
              return Semantics(
                label: 'Lineage validation for ${item.offerDocument}, status ${_statusLabel(item.status)}',
                child: Card(
                  elevation: 3,
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  color: colorScheme.surfaceContainerHighest,
                  child: InkWell(
                    onTap: () => _showDetailSheet(context, item),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  item.offerDocument,
                                  style: textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.onSurface,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _statusColor(context, item.status).withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  _statusLabel(item.status),
                                  style: textTheme.labelLarge?.copyWith(
                                    color: _statusColor(context, item.status),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Text(
                            'Source: ${item.sourceRequisition}',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Pass Rate: ${(item.passRate * 100).toStringAsFixed(1)}%',
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              Text(
                                'Trace: ${item.traceId}',
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showDetailSheet(BuildContext context, LineageValidationResult item) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 32,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colorScheme.onSurfaceVariant.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text('Lineage Detail', style: textTheme.headlineSmall),
                const SizedBox(height: 16),
                _detailRow('Offer Document', item.offerDocument, textTheme, colorScheme),
                _detailRow('Source Requisition', item.sourceRequisition, textTheme, colorScheme),
                _detailRow('Trace ID', item.traceId, textTheme, colorScheme),
                _detailRow('Status', _statusLabel(item.status), textTheme, colorScheme),
                _detailRow('Pass Rate', '${(item.passRate * 100).toStringAsFixed(2)}%', textTheme, colorScheme),
                _detailRow('Timestamp', item.timestamp.toIso8601String(), textTheme, colorScheme),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton.tonal(
                    onPressed: () => Navigator.of(context).pop(),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(48, 48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String value, TextTheme textTheme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
