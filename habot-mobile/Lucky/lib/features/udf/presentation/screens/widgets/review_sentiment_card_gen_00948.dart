// GEN-00948 — Review Sentiment Attribution Engine Status Card.
// Displays M3 Elevated Card with ingestion metrics, NLP accuracy, and Pass/Fail status chip. Polls mock data every 30 seconds with pull-to-refresh support.

import 'dart:async';
import 'package:flutter/material.dart';

enum IngestionStatus { pass, fail }

class ReviewIngestionMetrics {
  final double ingestionWindowHours;
  final double nlpAccuracyPercent;
  final IngestionStatus status;
  final DateTime timestamp;

  const ReviewIngestionMetrics({
    required this.ingestionWindowHours,
    required this.nlpAccuracyPercent,
    required this.status,
    required this.timestamp,
  });
}

class MockReviewSentimentRepository {
  static const List<ReviewIngestionMetrics> _mockData = [
    ReviewIngestionMetrics(
      ingestionWindowHours: 0.8,
      nlpAccuracyPercent: 96.5,
      status: IngestionStatus.pass,
      timestamp: DateTime(2026, 9, 17, 10, 0),
    ),
    ReviewIngestionMetrics(
      ingestionWindowHours: 3.2,
      nlpAccuracyPercent: 88.1,
      status: IngestionStatus.pass,
      timestamp: DateTime(2026, 9, 17, 10, 30),
    ),
    ReviewIngestionMetrics(
      ingestionWindowHours: 4.5,
      nlpAccuracyPercent: 82.0,
      status: IngestionStatus.fail,
      timestamp: DateTime(2026, 9, 17, 11, 0),
    ),
  ];

  int _index = 0;

  Future<ReviewIngestionMetrics> fetchLatestMetrics() async {
    await Future.delayed(const Duration(milliseconds: 150));
    final metric = _mockData[_index % _mockData.length];
    _index++;
    return metric;
  }
}

class ReviewSentimentCardGen00948 extends StatefulWidget {
  const ReviewSentimentCardGen00948({super.key});

  @override
  State<ReviewSentimentCardGen00948> createState() => _ReviewSentimentCardGen00948State();
}

class _ReviewSentimentCardGen00948State extends State<ReviewSentimentCardGen00948> {
  final MockReviewSentimentRepository _repository = MockReviewSentimentRepository();
  ReviewIngestionMetrics? _metrics;
  bool _isLoading = true;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _loadMetrics();
    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) _loadMetrics();
    });
  }

  Future<void> _loadMetrics() async {
    try {
      final data = await _repository.fetchLatestMetrics();
      if (mounted) {
        setState(() {
          _metrics = data;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _onRefresh() async {
    setState(() => _isLoading = true);
    await _loadMetrics();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.sizeOf(context).width < 600;

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Review Sentiment Engine',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_metrics == null)
                const Center(child: Text('No metrics available'))
              else
                _buildMetricsCard(theme, isMobile),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricsCard(ThemeData theme, bool isMobile) {
    final metrics = _metrics!;
    final isPass = metrics.status == IngestionStatus.pass;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: isMobile ? _buildMobileLayout(metrics, isPass, theme) : _buildDesktopLayout(metrics, isPass, theme),
      ),
    );
  }

  Widget _buildMobileLayout(ReviewIngestionMetrics metrics, bool isPass, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(isPass, theme),
        const Divider(height: 32),
        _buildMetricRow('Ingestion Window', '${metrics.ingestionWindowHours.toStringAsFixed(1)} hours', metrics.ingestionWindowHours <= 4.0, theme),
        const SizedBox(height: 12),
        _buildMetricRow('NLP Accuracy', '${metrics.nlpAccuracyPercent.toStringAsFixed(1)}%', metrics.nlpAccuracyPercent >= 85.0, theme),
        const SizedBox(height: 16),
        Text(
          'Last Updated: ${TimeOfDay.fromDateTime(metrics.timestamp).format(context)}',
          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(ReviewIngestionMetrics metrics, bool isPass, ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildHeader(isPass, theme)),
        const SizedBox(width: 32),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMetricRow('Ingestion Window', '${metrics.ingestionWindowHours.toStringAsFixed(1)} hours', metrics.ingestionWindowHours <= 4.0, theme),
              const SizedBox(height: 12),
              _buildMetricRow('NLP Accuracy', '${metrics.nlpAccuracyPercent.toStringAsFixed(1)}%', metrics.nlpAccuracyPercent >= 85.0, theme),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(bool isPass, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Health Status', style: theme.textTheme.titleMedium),
        Chip(
          avatar: Icon(
            isPass ? Icons.check_circle : Icons.error,
            size: 18,
            color: isPass ? Colors.green : Colors.red,
          ),
          label: Text(
            isPass ? 'PASS' : 'FAIL',
            style: TextStyle(
              color: isPass ? Colors.green.shade800 : Colors.red.shade800,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: isPass ? Colors.green.shade50 : Colors.red.shade50,
          side: BorderSide.none,
        ),
      ],
    );
  }

  Widget _buildMetricRow(String label, String value, bool isWithinThreshold, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: theme.textTheme.bodyLarge),
        Row(
          children: [
            Text(value, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(width: 8),
            Icon(
              isWithinThreshold ? Icons.trending_up : Icons.trending_down,
              color: isWithinThreshold ? Colors.green : Colors.orange,
              size: 20,
            ),
          ],
        ),
      ],
    );
  }
}
