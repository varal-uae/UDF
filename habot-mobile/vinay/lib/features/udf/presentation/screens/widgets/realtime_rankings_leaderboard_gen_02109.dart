// GEN-02109 — Real-time Rankings Leaderboard Widget.
// Renders real-time rankings automatically on mobile profile leaderboards using M3 Elevated Cards, background polling every 30 seconds, and pull-to-refresh.

import 'dart:async';
import 'package:flutter/material.dart';

enum DataFreshnessStatus { good, fair, poor }

class MockRankingEntry {
  final String traceId;
  final String userId;
  final String userName;
  final int rank;
  final double score;
  final DateTime timestamp;

  const MockRankingEntry({
    required this.traceId,
    required this.userId,
    required this.userName,
    required this.rank,
    required this.score,
    required this.timestamp,
  });
}

class MockRankingRepository {
  static const List<MockRankingEntry> _mockData = [
    MockRankingEntry(traceId: 'trace-001', userId: 'usr-101', userName: 'Alice Johnson', rank: 1, score: 9850.5, timestamp: DateTime(2026, 9, 24, 10, 0)),
    MockRankingEntry(traceId: 'trace-002', userId: 'usr-102', userName: 'Bob Smith', rank: 2, score: 9420.0, timestamp: DateTime(2026, 9, 24, 10, 0)),
    MockRankingEntry(traceId: 'trace-003', userId: 'usr-103', userName: 'Charlie Davis', rank: 3, score: 8990.75, timestamp: DateTime(2026, 9, 24, 10, 0)),
    MockRankingEntry(traceId: 'trace-004', userId: 'usr-104', userName: 'Diana Prince', rank: 4, score: 8540.2, timestamp: DateTime(2026, 9, 24, 10, 0)),
    MockRankingEntry(traceId: 'trace-005', userId: 'usr-105', userName: 'Evan Wright', rank: 5, score: 8100.0, timestamp: DateTime(2026, 9, 24, 10, 0)),
  ];

  Future<List<MockRankingEntry>> fetchRankings() async {
    await Future.delayed(const Duration(milliseconds: 80)); // Simulate sub-100ms latency
    return _mockData;
  }
}

class RealtimeRankingsLeaderboardGen02109 extends StatefulWidget {
  const RealtimeRankingsLeaderboardGen02109({super.key});

  @override
  State<RealtimeRankingsLeaderboardGen02109> createState() => _RealtimeRankingsLeaderboardGen02109State();
}

class _RealtimeRankingsLeaderboardGen02109State extends State<RealtimeRankingsLeaderboardGen02109> {
  final MockRankingRepository _repository = MockRankingRepository();
  List<MockRankingEntry> _rankings = [];
  bool _isLoading = true;
  Timer? _pollingTimer;
  DateTime? _lastUpdated;

  @override
  void initState() {
    super.initState();
    _fetchData();
    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _fetchData();
    });
  }

  Future<void> _fetchData() async {
    if (!mounted) return;
    try {
      final data = await _repository.fetchRankings();
      if (mounted) {
        setState(() {
          _rankings = data;
          _isLoading = false;
          _lastUpdated = DateTime.now();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load rankings: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _onRefresh() async {
    setState(() => _isLoading = true);
    await _fetchData();
  }

  DataFreshnessStatus _evaluateFreshness() {
    if (_lastUpdated == null) return DataFreshnessStatus.poor;
    final diff = DateTime.now().difference(_lastUpdated!).inSeconds;
    if (diff <= 10) return DataFreshnessStatus.good;
    if (diff <= 60) return DataFreshnessStatus.fair;
    return DataFreshnessStatus.poor;
  }

  Color _getFreshnessColor(DataFreshnessStatus status, ThemeData theme) {
    switch (status) {
      case DataFreshnessStatus.good:
        return theme.colorScheme.primary;
      case DataFreshnessStatus.fair:
        return theme.colorScheme.tertiary;
      case DataFreshnessStatus.poor:
        return theme.colorScheme.error;
    }
  }

  String _getFreshnessLabel(DataFreshnessStatus status) {
    switch (status) {
      case DataFreshnessStatus.good:
        return 'Good';
      case DataFreshnessStatus.fair:
        return 'Fair';
      case DataFreshnessStatus.poor:
        return 'Poor';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final freshness = _evaluateFreshness();

    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: theme.colorScheme.primary,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;
          final crossAxisCount = isMobile ? 1 : (constraints.maxWidth >= 840 ? 2 : 1);

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    elevation: 3.0, // M3 Elevated Cards Level 2 (3dp)
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Profile Leaderboard',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Chip(
                            avatar: Icon(
                              Icons.circle,
                              size: 12.0,
                              color: _getFreshnessColor(freshness, theme),
                            ),
                            label: Text(_getFreshnessLabel(freshness)),
                            backgroundColor: theme.colorScheme.surfaceContainerHighest,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (_isLoading && _rankings.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_rankings.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: Text('No rankings available.')),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: 12.0,
                      crossAxisSpacing: 12.0,
                      childAspectRatio: isMobile ? 3.5 : 3.0,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final entry = _rankings[index];
                        return _buildRankingCard(entry, theme);
                      },
                      childCount: _rankings.length,
                    ),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 24.0)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRankingCard(MockRankingEntry entry, ThemeData theme) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Drill-down for ${entry.userName} (Trace: ${entry.traceId})'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12.0),
      child: Card(
        elevation: 3.0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              SizedBox(
                width: 48.0,
                height: 48.0, // 48x48dp touch targets
                child: Center(
                  child: CircleAvatar(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Text(
                      '#${entry.rank}',
                      style: TextStyle(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      entry.userName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      'Score: ${entry.score.toStringAsFixed(2)}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
