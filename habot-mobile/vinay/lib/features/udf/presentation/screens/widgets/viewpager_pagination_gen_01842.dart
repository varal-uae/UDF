// GEN-01842 — Single-Action ViewPager Pagination with M3 Status Cards.
// Implements data chunking logic, background polling every 30 seconds, pull-to-refresh, and responsive single/multi-column layout.

import 'dart:async';
import 'package:flutter/material.dart';

enum StepCompletionStatus { complete, partial, notComplete }

class ChunkedStepData {
  final String traceId;
  final String title;
  final StepCompletionStatus status;
  final double completionRate;
  final DateTime timestamp;

  const ChunkedStepData({
    required this.traceId,
    required this.title,
    required this.status,
    required this.completionRate,
    required this.timestamp,
  });
}

class MockChunkRepository {
  static List<ChunkedStepData> fetchChunks() {
    return [
      ChunkedStepData(
        traceId: 'trace-001-gen-01842',
        title: 'Data Chunking Logic Initialization',
        status: StepCompletionStatus.complete,
        completionRate: 100.0,
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      ChunkedStepData(
        traceId: 'trace-002-gen-01842',
        title: 'ViewPager Smooth Flow Configuration',
        status: StepCompletionStatus.partial,
        completionRate: 92.5,
        timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
      ),
      ChunkedStepData(
        traceId: 'trace-003-gen-01842',
        title: 'Backend API Latency Optimization',
        status: StepCompletionStatus.notComplete,
        completionRate: 45.0,
        timestamp: DateTime.now(),
      ),
      ChunkedStepData(
        traceId: 'trace-004-gen-01842',
        title: 'M3 Elevated Card Rendering',
        status: StepCompletionStatus.complete,
        completionRate: 99.0,
        timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
      ),
    ];
  }
}

class ViewPagerPaginationGen01842 extends StatefulWidget {
  const ViewPagerPaginationGen01842({super.key});

  @override
  State<ViewPagerPaginationGen01842> createState() => _ViewPagerPaginationGen01842State();
}

class _ViewPagerPaginationGen01842State extends State<ViewPagerPaginationGen01842> {
  late PageController _pageController;
  List<ChunkedStepData> _chunks = [];
  bool _isLoading = false;
  Timer? _pollingTimer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.9);
    _loadData();
    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) {
      setState(() {
        _chunks = MockChunkRepository.fetchChunks();
        _isLoading = false;
      });
    }
  }

  Color _getStatusColor(StepCompletionStatus status, ColorScheme colorScheme) {
    switch (status) {
      case StepCompletionStatus.complete:
        return colorScheme.primary;
      case StepCompletionStatus.partial:
        return colorScheme.tertiary;
      case StepCompletionStatus.notComplete:
        return colorScheme.error;
    }
  }

  String _getStatusLabel(StepCompletionStatus status) {
    switch (status) {
      case StepCompletionStatus.complete:
        return 'Complete';
      case StepCompletionStatus.partial:
        return 'Partial';
      case StepCompletionStatus.notComplete:
        return 'Not Complete';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDesktop = MediaQuery.of(context).size.width >= 840;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Engineering Console'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: _isLoading && _chunks.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : isDesktop
                ? _buildMultiColumnLayout(colorScheme)
                : _buildSingleColumnViewPager(colorScheme),
      ),
    );
  }

  Widget _buildSingleColumnViewPager(ColorScheme colorScheme) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Text(
            'Step Completion Rate',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: _chunks.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: _buildElevatedCard(_chunks[index], colorScheme),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _chunks.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                width: _currentPage == index ? 12.0 : 8.0,
                height: 8.0,
                decoration: BoxDecoration(
                  color: _currentPage == index ? colorScheme.primary : colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(4.0),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMultiColumnLayout(ColorScheme colorScheme) {
    return GridView.builder(
      padding: const EdgeInsets.all(24.0),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 400,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: _chunks.length,
      itemBuilder: (context, index) {
        return _buildElevatedCard(_chunks[index], colorScheme);
      },
    );
  }

  Widget _buildElevatedCard(ChunkedStepData data, ColorScheme colorScheme) {
    return Card(
      elevation: 3.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showBottomSheet(data, colorScheme),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      data.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Chip(
                    label: Text(
                      _getStatusLabel(data.status),
                      style: TextStyle(
                        color: _getStatusColor(data.status, colorScheme),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    backgroundColor: _getStatusColor(data.status, colorScheme).withOpacity(0.1),
                    side: BorderSide.none,
                  ),
                ],
              ),
              const Spacer(),
              LinearProgressIndicator(
                value: data.completionRate / 100.0,
                minHeight: 6,
                backgroundColor: colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getStatusColor(data.status, colorScheme),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Rate: ${data.completionRate.toStringAsFixed(1)}%',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    'Trace: ${data.traceId}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.outline,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBottomSheet(ChunkedStepData data, ColorScheme colorScheme) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Configuration Details',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Trace ID'),
                subtitle: Text(data.traceId),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Completion Rate'),
                subtitle: Text('${data.completionRate.toStringAsFixed(1)}%'),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Status'),
                subtitle: Text(_getStatusLabel(data.status)),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Timestamp'),
                subtitle: Text(data.timestamp.toIso8601String()),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Configuration synced successfully.'),
                        behavior: SnackBarBehavior.floating,
                        action: SnackBarAction(
                          label: 'DISMISS',
                          onPressed: () {},
                        ),
                      ),
                    );
                  },
                  child: const Text('Confirm Sync'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}
