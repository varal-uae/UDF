// GEN-01853 — Paginated Layout Wrappers Library.
// Provides reusable paginated wrapper widgets stored in the shared layout library, implementing M3 Elevated Cards (Level 2, 3dp), status chips, 48x48dp touch targets, and responsive single-column/multi-column layouts with mock data support.

import 'package:flutter/material.dart';

/// Mock data model representing a step completion state for the engineering console.
class StepCompletionData {
  final String traceId;
  final String title;
  final String description;
  final StepStatus status;
  final double completionRate;
  final DateTime timestamp;

  const StepCompletionData({
    required this.traceId,
    required this.title,
    required this.description,
    required this.status,
    required this.completionRate,
    required this.timestamp,
  });
}

enum StepStatus { complete, partial, notComplete }

/// Local mock data simulating backend API responses partitioned by event_date and clustered by trace_id.
final List<StepCompletionData> kMockPaginatedSteps = List.generate(
  45,
  (index) => StepCompletionData(
    traceId: 'trace_${1000 + index}',
    title: 'Layout Wrapper Step ${index + 1}',
    description: 'Validated implementation of paginated wrapper configuration.',
    status: index % 5 == 0
        ? StepStatus.notComplete
        : index % 3 == 0
            ? StepStatus.partial
            : StepStatus.complete,
    completionRate: (90.0 + (index % 11)).clamp(0.0, 100.0),
    timestamp: DateTime.now().subtract(Duration(hours: index)),
  ),
);

/// A reusable paginated wrapper widget that displays M3 status cards.
/// Implements background polling simulation, pull-to-refresh, and responsive layouts.
class PaginatedLayoutWrapper extends StatefulWidget {
  final List<StepCompletionData> initialData;
  final int pageSize;

  const PaginatedLayoutWrapper({
    super.key,
    this.initialData = const [],
    this.pageSize = 10,
  });

  @override
  State<PaginatedLayoutWrapper> createState() => _PaginatedLayoutWrapperState();
}

class _PaginatedLayoutWrapperState extends State<PaginatedLayoutWrapper> {
  late List<StepCompletionData> _allData;
  late List<StepCompletionData> _visibleData;
  int _currentPage = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _allData = widget.initialData.isEmpty ? kMockPaginatedSteps : widget.initialData;
    _loadPage(0);
    _startPolling();
  }

  void _startPolling() {
    // Simulates background polling every 30 seconds as per requirement
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted) {
        _refreshData();
        _startPolling();
      }
    });
  }

  Future<void> _refreshData() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 80)); // Sub-100ms simulated latency
    if (mounted) {
      setState(() {
        _allData = List.from(kMockPaginatedSteps)..shuffle();
        _loadPage(_currentPage);
        _isLoading = false;
      });
    }
  }

  void _loadPage(int page) {
    final start = page * widget.pageSize;
    final end = (start + widget.pageSize).clamp(0, _allData.length);
    setState(() {
      _currentPage = page;
      _visibleData = _allData.sublist(start, end);
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        final isTabletOrDesktop = constraints.maxWidth >= 840;

        return RefreshIndicator(
          onRefresh: _refreshData,
          color: Theme.of(context).colorScheme.primary,
          child: Column(
            children: [
              Expanded(
                child: isTabletOrDesktop
                    ? _buildMultiColumnLayout()
                    : _buildSingleColumnLayout(isMobile),
              ),
              _buildPaginationControls(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSingleColumnLayout(bool isMobile) {
    return ListView.builder(
      padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
      itemCount: _visibleData.length,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: _StepCompletionCard(data: _visibleData[index]),
      ),
    );
  }

  Widget _buildMultiColumnLayout() {
    return GridView.builder(
      padding: const EdgeInsets.all(24.0),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 400,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.4,
      ),
      itemCount: _visibleData.length,
      itemBuilder: (context, index) => _StepCompletionCard(data: _visibleData[index]),
    );
  }

  Widget _buildPaginationControls() {
    final totalPages = (_allData.length / widget.pageSize).ceil();
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, -2))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: _currentPage > 0 ? () => _loadPage(_currentPage - 1) : null,
            icon: const Icon(Icons.chevron_left),
            iconSize: 48, // 48x48dp touch target minimum
            tooltip: 'Previous Page',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Page ${_currentPage + 1} of $totalPages',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          IconButton(
            onPressed: _currentPage < totalPages - 1 ? () => _loadPage(_currentPage + 1) : null,
            icon: const Icon(Icons.chevron_right),
            iconSize: 48, // 48x48dp touch target minimum
            tooltip: 'Next Page',
          ),
        ],
      ),
    );
  }
}

/// M3 Elevated Card Level 2 (3dp elevation) displaying step health via inline status chip.
class _StepCompletionCard extends StatelessWidget {
  final StepCompletionData data;

  const _StepCompletionCard({required this.data});

  Color _getStatusColor(BuildContext context) {
    switch (data.status) {
      case StepStatus.complete:
        return Theme.of(context).colorScheme.primary;
      case StepStatus.partial:
        return Theme.of(context).colorScheme.tertiary;
      case StepStatus.notComplete:
        return Theme.of(context).colorScheme.error;
    }
  }

  String _getStatusLabel() {
    switch (data.status) {
      case StepStatus.complete:
        return 'Complete';
      case StepStatus.partial:
        return 'Partial';
      case StepStatus.notComplete:
        return 'Not Complete';
    }
  }

  void _showConfigurationSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Configure Step', style: Theme.of(ctx).textTheme.headlineSmall),
            const SizedBox(height: 16),
            Text('Trace ID: ${data.traceId}', style: Theme.of(ctx).textTheme.bodyLarge),
            const SizedBox(height: 8),
            Text('Current Rate: ${data.completionRate.toStringAsFixed(1)}%', style: Theme.of(ctx).textTheme.bodyMedium),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48, // 48x48dp touch target
              child: FilledButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Configuration saved for ${data.traceId}'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: const Text('Apply Configuration'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(context);

    return Card(
      elevation: 3.0, // M3 Elevated Cards Level 2 (3dp)
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showConfigurationSheet(context),
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
                      data.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Chip(
                    label: Text(
                      _getStatusLabel(),
                      style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    backgroundColor: statusColor.withOpacity(0.12),
                    side: BorderSide.none,
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                data.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${data.completionRate.toStringAsFixed(1)}%',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  Text(
                    '${data.timestamp.hour}:${data.timestamp.minute.toString().padLeft(2, '0')}',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
