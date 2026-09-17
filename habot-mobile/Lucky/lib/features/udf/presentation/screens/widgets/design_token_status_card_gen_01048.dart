// GEN-01048 — Design Token Registry Status Card.
// M3 Elevated Card displaying @habot/ui-tokens publish status with adoption rate metric, completion state chip, and 30-second polling refresh.

import 'dart:async';
import 'package:flutter/material.dart';

enum _CompletionStatus { complete, partial, notComplete }

class _TokenRegistryMockData {
  final String tokenPackage;
  final double adoptionRate;
  final _CompletionStatus status;
  final DateTime lastUpdated;
  final String traceId;

  const _TokenRegistryMockData({
    required this.tokenPackage,
    required this.adoptionRate,
    required this.status,
    required this.lastUpdated,
    required this.traceId,
  });
}

const List<_TokenRegistryMockData> _mockRegistryData = [
  _TokenRegistryMockData(
    tokenPackage: '@habot/ui-tokens',
    adoptionRate: 1.0,
    status: _CompletionStatus.complete,
    lastUpdated: DateTime(2026, 9, 17, 10, 0),
    traceId: 'trace-gen-01048-001',
  ),
];

class DesignTokenStatusCardGen01048 extends StatefulWidget {
  const DesignTokenStatusCardGen01048({super.key});

  @override
  State<DesignTokenStatusCardGen01048> createState() =>
      _DesignTokenStatusCardGen01048State();
}

class _DesignTokenStatusCardGen01048State
    extends State<DesignTokenStatusCardGen01048> {
  late List<_TokenRegistryMockData> _currentData;
  Timer? _pollingTimer;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _currentData = List.from(_mockRegistryData);
    _startPolling();
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _fetchData();
    });
  }

  Future<void> _fetchData() async {
    if (!mounted) return;
    setState(() => _isRefreshing = true);
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    setState(() {
      _currentData = _mockRegistryData.map((e) {
        return _TokenRegistryMockData(
          tokenPackage: e.tokenPackage,
          adoptionRate: e.adoptionRate,
          status: e.status,
          lastUpdated: DateTime.now(),
          traceId: e.traceId,
        );
      }).toList();
      _isRefreshing = false;
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Color _statusColor(_CompletionStatus status, ColorScheme cs) {
    switch (status) {
      case _CompletionStatus.complete:
        return cs.primary;
      case _CompletionStatus.partial:
        return cs.tertiary;
      case _CompletionStatus.notComplete:
        return cs.error;
    }
  }

  String _statusLabel(_CompletionStatus status) {
    switch (status) {
      case _CompletionStatus.complete:
        return 'Complete';
      case _CompletionStatus.partial:
        return 'Partial';
      case _CompletionStatus.notComplete:
        return 'Not Complete';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final textTheme = theme.textTheme;

    return RefreshIndicator(
      onRefresh: _fetchData,
      color: cs.primary,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;
          final crossAxisCount = isMobile ? 1 : (constraints.maxWidth >= 840 ? 2 : 1);

          return GridView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 16.0,
              crossAxisSpacing: 16.0,
              mainAxisExtent: 220.0,
            ),
            itemCount: _currentData.length,
            itemBuilder: (context, index) {
              final item = _currentData[index];
              final meetsFloor = item.adoptionRate >= 0.9;

              return Card(
                elevation: 3.0,
                surfaceTintColor: cs.surfaceTint,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item.tokenPackage,
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (_isRefreshing)
                            SizedBox(
                              width: 20.0,
                              height: 20.0,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.0,
                                color: cs.primary,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12.0),
                      Row(
                        children: [
                          Text(
                            'Adoption Rate:',
                            style: textTheme.bodyMedium,
                          ),
                          const SizedBox(width: 8.0),
                          Text(
                            '${(item.adoptionRate * 100).toStringAsFixed(0)}%',
                            style: textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: meetsFloor ? cs.primary : cs.error,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8.0),
                      LinearProgressIndicator(
                        value: item.adoptionRate.clamp(0.0, 1.0),
                        minHeight: 6.0,
                        backgroundColor: cs.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          meetsFloor ? cs.primary : cs.error,
                        ),
                        borderRadius: BorderRadius.circular(3.0),
                      ),
                      const SizedBox(height: 16.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Chip(
                            avatar: Icon(
                              item.status == _CompletionStatus.complete
                                  ? Icons.check_circle
                                  : item.status == _CompletionStatus.partial
                                      ? Icons.warning_amber_rounded
                                      : Icons.error_outline,
                              size: 18.0,
                              color: _statusColor(item.status, cs),
                            ),
                            label: Text(
                              _statusLabel(item.status),
                              style: textTheme.labelMedium?.copyWith(
                                color: _statusColor(item.status, cs),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            backgroundColor: _statusColor(item.status, cs)
                                .withValues(alpha: 0.12),
                            side: BorderSide.none,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4.0,
                            ),
                          ),
                          Text(
                            'Trace: ${item.traceId}',
                            style: textTheme.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Text(
                          'Updated: ${item.lastUpdated.hour.toString().padLeft(2, '0')}:${item.lastUpdated.minute.toString().padLeft(2, '0')}',
                          style: textTheme.labelSmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}