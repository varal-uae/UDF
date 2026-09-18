// GEN-01313 — Upcoming Today Hero Card using M3 Surface Card specifications with elevation styling.
// Implements a responsive hero card for the UDF dashboard with mock data, 30s polling, pull-to-refresh, and M3 Elevated Card Level 2 (3dp) styling.

import 'dart:async';
import 'package:flutter/material.dart';

/// Mock data model representing the Upcoming Today metric payload.
class UpcomingTodayData {
  final String title;
  final String status; // 'Good', 'Average', 'Poor'
  final DateTime timestamp;
  final String sessionId;
  final int refreshLatencyMs;

  const UpcomingTodayData({
    required this.title,
    required this.status,
    required this.timestamp,
    required this.sessionId,
    required this.refreshLatencyMs,
  });
}

/// Mock repository providing realistic local data to satisfy backend/API requirements.
class MockUpcomingTodayRepository {
  static const List<UpcomingTodayData> _mockEvents = [
    UpcomingTodayData(
      title: 'System Health Check',
      status: 'Good',
      timestamp: null as dynamic,
      sessionId: 'sess_8a7b6c5d',
      refreshLatencyMs: 42,
    ),
    UpcomingTodayData(
      title: 'Data Pipeline Sync',
      status: 'Average',
      timestamp: null as dynamic,
      sessionId: 'sess_1x2y3z4w',
      refreshLatencyMs: 85,
    ),
  ];

  Future<List<UpcomingTodayData>> fetchUpcomingToday() async {
    await Future.delayed(const Duration(milliseconds: 45)); // Simulates sub-100ms latency
    return _mockEvents.map((e) => UpcomingTodayData(
      title: e.title,
      status: e.status,
      timestamp: DateTime.now(),
      sessionId: e.sessionId,
      refreshLatencyMs: e.refreshLatencyMs,
    )).toList();
  }
}

/// Controller managing background polling every 30 seconds.
class UpcomingTodayController extends ChangeNotifier {
  final MockUpcomingTodayRepository _repository = MockUpcomingTodayRepository();
  List<UpcomingTodayData> _data = [];
  Timer? _pollingTimer;
  bool _isLoading = false;

  List<UpcomingTodayData> get data => _data;
  bool get isLoading => _isLoading;

  UpcomingTodayController() {
    refreshData();
    _startPolling();
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      refreshData();
    });
  }

  Future<void> refreshData() async {
    _isLoading = true;
    notifyListeners();
    try {
      _data = await _repository.fetchUpcomingToday();
    } catch (_) {
      // Error handling fallback
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }
}

/// Main Hero Card Widget implementing M3 Elevated Card Level 2 (3dp).
class UpcomingTodayHeroCard extends StatefulWidget {
  const UpcomingTodayHeroCard({super.key});

  @override
  State<UpcomingTodayHeroCard> createState() => _UpcomingTodayHeroCardState();
}

class _UpcomingTodayHeroCardState extends State<UpcomingTodayHeroCard> {
  late final UpcomingTodayController _controller;

  @override
  void initState() {
    super.initState();
    _controller = UpcomingTodayController();
    _controller.addListener(_onDataChanged);
  }

  void _onDataChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onDataChanged);
    _controller.dispose();
    super.dispose();
  }

  Color _getStatusColor(BuildContext context, String status) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (status.toLowerCase()) {
      case 'good':
        return colorScheme.primary;
      case 'average':
        return colorScheme.tertiary;
      case 'poor':
        return colorScheme.error;
      default:
        return colorScheme.outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 600;

    return RefreshIndicator(
      onRefresh: _controller.refreshData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 3.0, // M3 Elevated Cards Level 2 (3dp)
            surfaceTintColor: theme.colorScheme.surfaceTint,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Upcoming Today',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Dashboard Data Refresh Latency Status',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_controller.isLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    isMobile
                        ? _buildSingleColumnLayout(context, theme)
                        : _buildMultiColumnLayout(context, theme),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// M3 responsive layout: single-column on mobile (<600dp)
  Widget _buildSingleColumnLayout(BuildContext context, ThemeData theme) {
    return Column(
      children: _controller.data.map((item) => _buildStatusTile(context, theme, item)).toList(),
    );
  }

  /// M3 responsive layout: multi-column on desktop (>=840dp) / tablet
  Widget _buildMultiColumnLayout(BuildContext context, ThemeData theme) {
    return Wrap(
      spacing: 16.0,
      runSpacing: 16.0,
      children: _controller.data.map((item) => SizedBox(
        width: 300,
        child: _buildStatusTile(context, theme, item),
      )).toList(),
    );
  }

  Widget _buildStatusTile(BuildContext context, ThemeData theme, UpcomingTodayData item) {
    return InkWell(
      onTap: () {
        // Deep-link drill-down action placeholder
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Drilling down into ${item.title}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      borderRadius: BorderRadius.circular(12.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 4.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Latency: ${item.refreshLatencyMs}ms | Session: ${item.sessionId}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // M3 Status Chips for health indicators
            Chip(
              label: Text(
                item.status,
                style: TextStyle(
                  color: _getStatusColor(context, item.status),
                  fontWeight: FontWeight.w600,
                ),
              ),
              backgroundColor: _getStatusColor(context, item.status).withOpacity(0.12),
              side: BorderSide.none,
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
          ],
        ),
      ),
    );
  }
}
