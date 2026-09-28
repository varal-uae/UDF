// GEN-03838 — Go-Live Deliverable Verification Status Card.
// M3 Elevated Card displaying Production Data Engine, Locked Master Schemas, and Real-Time Mobile Finance Console status with 30s polling and pull-to-refresh support.

import 'dart:async';
import 'package:flutter/material.dart';

enum _VerificationStatus { complete, notComplete, loading }

class _MockVerificationData {
  final String component;
  final _VerificationStatus status;
  final String timestamp;

  const _MockVerificationData({
    required this.component,
    required this.status,
    required this.timestamp,
  });
}

class GoLiveVerificationCardGen03838 extends StatefulWidget {
  const GoLiveVerificationCardGen03838({super.key});

  @override
  State<GoLiveVerificationCardGen03838> createState() => _GoLiveVerificationCardGen03838State();
}

class _GoLiveVerificationCardGen03838State extends State<GoLiveVerificationCardGen03838> {
  late List<_MockVerificationData> _data;
  Timer? _pollingTimer;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _loadMockData();
    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _loadMockData() {
    _data = const [
      _MockVerificationData(
        component: 'Production Data Engine',
        status: _VerificationStatus.complete,
        timestamp: '2026-09-28T10:00:00Z',
      ),
      _MockVerificationData(
        component: 'Master Schemas',
        status: _VerificationStatus.complete,
        timestamp: '2026-09-28T10:00:05Z',
      ),
      _MockVerificationData(
        component: 'Real-Time Mobile Finance Console',
        status: _VerificationStatus.notComplete,
        timestamp: '2026-09-28T10:00:10Z',
      ),
    ];
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) {
        setState(() {
          _loadMockData();
        });
      }
    });
  }

  Future<void> _handleRefresh() async {
    setState(() => _isRefreshing = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      setState(() {
        _loadMockData();
        _isRefreshing = false;
      });
    }
  }

  Color _statusColor(BuildContext context, _VerificationStatus status) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (status) {
      case _VerificationStatus.complete:
        return colorScheme.primary;
      case _VerificationStatus.notComplete:
        return colorScheme.error;
      case _VerificationStatus.loading:
        return colorScheme.outline;
    }
  }

  String _statusLabel(_VerificationStatus status) {
    switch (status) {
      case _VerificationStatus.complete:
        return 'Complete';
      case _VerificationStatus.notComplete:
        return 'Not Complete';
      case _VerificationStatus.loading:
        return 'Loading';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.sizeOf(context).width < 600;

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = isMobile ? 1 : (constraints.maxWidth >= 840 ? 3 : 2);

          return Card(
            elevation: 3.0,
            surfaceTintColor: theme.colorScheme.surfaceTint,
            margin: const EdgeInsets.all(16.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Go-Live Deliverable Verification',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (_isRefreshing)
                        const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2.0),
                        )
                      else
                        IconButton(
                          onPressed: _handleRefresh,
                          icon: const Icon(Icons.refresh),
                          tooltip: 'Manual Sync',
                          iconSize: 24,
                        ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    'CMMI Dev V2.0 Verification | GEN-03838',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: 12.0,
                      crossAxisSpacing: 12.0,
                      childAspectRatio: isMobile ? 3.5 : 2.5,
                    ),
                    itemCount: _data.length,
                    itemBuilder: (context, index) {
                      final item = _data[index];
                      return _buildStatusTile(context, item, theme);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusTile(BuildContext context, _MockVerificationData item, ThemeData theme) {
    return InkWell(
      onTap: () => _showDetailSheet(context, item),
      borderRadius: BorderRadius.circular(12.0),
      child: Container(
        constraints: const BoxConstraints(minHeight: 48.0, minWidth: 48.0),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withOpacity(0.5),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.component,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    item.timestamp,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12.0),
            Chip(
              label: Text(
                _statusLabel(item.status),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: _statusColor(context, item.status),
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: _statusColor(context, item.status).withOpacity(0.12),
              side: BorderSide.none,
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }

  void _showDetailSheet(BuildContext context, _MockVerificationData item) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) {
        final theme = Theme.of(context);
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.component,
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 16.0),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Status'),
                subtitle: Text(_statusLabel(item.status)),
                trailing: Icon(
                  item.status == _VerificationStatus.complete
                      ? Icons.check_circle
                      : Icons.cancel,
                  color: _statusColor(context, item.status),
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Timestamp'),
                subtitle: Text(item.timestamp),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Standard'),
                subtitle: const Text('CMMI Dev V2.0 Verification'),
              ),
              const SizedBox(height: 24.0),
              SizedBox(
                width: double.infinity,
                height: 48.0,
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Drill-down initiated for ${item.component}'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  child: const Text('View Full Trace'),
                ),
              ),
              const SizedBox(height: 16.0),
            ],
          ),
        );
      },
    );
  }
}
