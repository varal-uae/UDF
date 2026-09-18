// GEN-01435 — Category Selection Benchmark Card.
// M3 Elevated Card displaying category selection tap response time benchmarks with Good/Average/Poor status chips and sub-100ms rendering targets.

import 'package:flutter/material.dart';

enum BenchmarkStatus { good, average, poor }

class CategoryBenchmarkData {
  final String categoryId;
  final String categoryName;
  final double responseTimeMs;
  final DateTime timestamp;
  final BenchmarkStatus status;

  const CategoryBenchmarkData({
    required this.categoryId,
    required this.categoryName,
    required this.responseTimeMs,
    required this.timestamp,
    required this.status,
  });
}

class _MockBenchmarkRepository {
  static List<CategoryBenchmarkData> getBenchmarks() {
    return [
      CategoryBenchmarkData(
        categoryId: 'cat_001',
        categoryName: 'Electronics',
        responseTimeMs: 45.2,
        timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
        status: BenchmarkStatus.good,
      ),
      CategoryBenchmarkData(
        categoryId: 'cat_002',
        categoryName: 'Apparel',
        responseTimeMs: 89.7,
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        status: BenchmarkStatus.good,
      ),
      CategoryBenchmarkData(
        categoryId: 'cat_003',
        categoryName: 'Home & Garden',
        responseTimeMs: 156.3,
        timestamp: DateTime.now().subtract(const Duration(minutes: 8)),
        status: BenchmarkStatus.average,
      ),
      CategoryBenchmarkData(
        categoryId: 'cat_004',
        categoryName: 'Automotive',
        responseTimeMs: 312.8,
        timestamp: DateTime.now().subtract(const Duration(minutes: 12)),
        status: BenchmarkStatus.poor,
      ),
    ];
  }
}

class CategoryBenchmarkCard extends StatefulWidget {
  const CategoryBenchmarkCard({super.key});

  @override
  State<CategoryBenchmarkCard> createState() => _CategoryBenchmarkCardState();
}

class _CategoryBenchmarkCardState extends State<CategoryBenchmarkCard> {
  late List<CategoryBenchmarkData> _benchmarks;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _loadBenchmarks();
  }

  void _loadBenchmarks() {
    setState(() {
      _benchmarks = _MockBenchmarkRepository.getBenchmarks();
    });
  }

  Future<void> _handleRefresh() async {
    setState(() => _isRefreshing = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      _loadBenchmarks();
      setState(() => _isRefreshing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Benchmark data synchronized'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Color _getStatusColor(BenchmarkStatus status, ColorScheme colorScheme) {
    switch (status) {
      case BenchmarkStatus.good:
        return colorScheme.primary;
      case BenchmarkStatus.average:
        return colorScheme.tertiary;
      case BenchmarkStatus.poor:
        return colorScheme.error;
    }
  }

  String _getStatusLabel(BenchmarkStatus status) {
    switch (status) {
      case BenchmarkStatus.good:
        return 'Good';
      case BenchmarkStatus.average:
        return 'Average';
      case BenchmarkStatus.poor:
        return 'Poor';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;
          final crossAxisCount = isMobile ? 1 : (constraints.maxWidth >= 840 ? 2 : 1);

          return GridView.builder(
            padding: const EdgeInsets.all(16.0),
            physics: const AlwaysScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 12.0,
              crossAxisSpacing: 12.0,
              childAspectRatio: isMobile ? 3.5 : 3.0,
            ),
            itemCount: _benchmarks.length,
            itemBuilder: (context, index) {
              final benchmark = _benchmarks[index];
              return _buildElevatedCard(benchmark, colorScheme, theme);
            },
          );
        },
      ),
    );
  }

  Widget _buildElevatedCard(
    CategoryBenchmarkData benchmark,
    ColorScheme colorScheme,
    ThemeData theme,
  ) {
    final statusColor = _getStatusColor(benchmark.status, colorScheme);

    return Card(
      elevation: 3.0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: InkWell(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      benchmark.categoryName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      '${benchmark.responseTimeMs.toStringAsFixed(1)} ms',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12.0),
              Chip(
                label: Text(
                  _getStatusLabel(benchmark.status),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor: statusColor.withOpacity(0.12),
                side: BorderSide.none,
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}