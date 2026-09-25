// SGTIM-005-A12 — InfiniteScrollManager for continuous list scrolling with background data fetching.
// Implements scroll position listeners, duplicate call prevention, network drop halting, and scroll position restoration using Material 3 design patterns.

import 'dart:async';
import 'package:flutter/material.dart';

/// Represents a single row of atomic-level data fetched during infinite scroll.
class ScrollDataRow {
  final String stepExecutionId;
  final String executionStatus;
  final DateTime executionTimestamp;
  final String stepOutcome;
  final String userId;

  const ScrollDataRow({
    required this.stepExecutionId,
    required this.executionStatus,
    required this.executionTimestamp,
    required this.stepOutcome,
    required this.userId,
  });
}

/// Mock repository simulating backend API calls for paginated data fetching.
class MockScrollDataRepository {
  static const int _pageSize = 20;

  Future<List<ScrollDataRow>> fetchPage(int pageIndex) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final List<ScrollDataRow> mockData = [];
    for (int i = 0; i < _pageSize; i++) {
      final int globalIndex = (pageIndex * _pageSize) + i;
      mockData.add(ScrollDataRow(
        stepExecutionId: 'STEP-EXEC-$globalIndex',
        executionStatus: globalIndex % 5 == 0 ? 'Failed' : 'Completed',
        executionTimestamp: DateTime.now().subtract(Duration(hours: globalIndex)),
        stepOutcome: 'Outcome details for item $globalIndex',
        userId: 'USER-${globalIndex % 10}',
      ));
    }
    return mockData;
  }
}

/// Core reusable widget implementing continuous infinite scrolling.
/// Replaces traditional page number navigation grids with a natural vertical scroll flow.
class InfiniteScrollManager extends StatefulWidget {
  final MockScrollDataRepository repository;

  const InfiniteScrollManager({
    super.key,
    required this.repository,
  });

  @override
  State<InfiniteScrollManager> createState() => _InfiniteScrollManagerState();
}

class _InfiniteScrollManagerState extends State<InfiniteScrollManager>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final List<ScrollDataRow> _items = [];
  
  bool _isLoading = false;
  bool _hasMoreData = true;
  int _currentPage = 0;
  bool _isNetworkAvailable = true;
  
  // Poka-Yoke: Rapid click/scroll block filter to prevent duplicate data calls.
  DateTime? _lastFetchTime;
  static const Duration _fetchThrottle = Duration(milliseconds: 1500);
  
  // Elastic animation controller for spatial context cues
  late AnimationController _animController;
  late Animation<double> _elasticAnimation;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _elasticAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.elasticOut,
    );
    
    _fetchNextPage();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _animController.dispose();
    super.dispose();
  }

  /// Self-Chasing: Simulates remembering the exact row a user was exploring.
  Future<void> _restoreScrollPosition(double savedOffset) async {
    if (_scrollController.hasClients && savedOffset > 0) {
      await Future.delayed(const Duration(milliseconds: 300));
      _scrollController.animateTo(
        savedOffset,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _onScroll() {
    // Trigger background data calls when reaching 85% of the scroll extent
    if (!_isLoading && _hasMoreData && _isNetworkAvailable) {
      final double maxScroll = _scrollController.position.maxScrollExtent;
      final double currentScroll = _scrollController.position.pixels;
      if (currentScroll >= maxScroll * 0.85) {
        _fetchNextPage();
      }
    }
  }

  /// AISS: Insert a condition ensuring the loading flag status is false before launching requests.
  Future<void> _fetchNextPage() async {
    // Mistake-Proofing (Poka-Yoke): Halt background data requests instantly if connection monitors report a total network drop.
    if (!_isNetworkAvailable) return;
    
    // Ensure loading flag is false
    if (_isLoading) return;

    // Rapid click-block filters to scroll triggers
    final now = DateTime.now();
    if (_lastFetchTime != null && now.difference(_lastFetchTime!) < _fetchThrottle) {
      return;
    }
    _lastFetchTime = now;

    setState(() {
      _isLoading = true;
    });

    try {
      final newData = await widget.repository.fetchPage(_currentPage);
      
      if (!mounted) return;
      
      setState(() {
        _items.addAll(newData);
        _currentPage++;
        _isLoading = false;
        // Stop after 5 pages for mock demonstration purposes
        if (_currentPage >= 5) {
          _hasMoreData = false;
        }
      });
      
      // Animate component translations elastically to give users clear spatial context
      if (_animController.isCompleted) {
        _animController.reset();
      }
      _animController.forward();
      
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Simulates a network drop event for testing Poka-Yoke behavior
  void _simulateNetworkDrop() {
    setState(() {
      _isNetworkAvailable = false;
    });
  }

  void _simulateNetworkRestore() {
    setState(() {
      _isNetworkAvailable = true;
    });
    _fetchNextPage();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Asset List'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(
              _isNetworkAvailable ? Icons.wifi : Icons.wifi_off,
              color: _isNetworkAvailable ? null : colorScheme.error,
            ),
            tooltip: 'Toggle Network Status',
            onPressed: () {
              if (_isNetworkAvailable) {
                _simulateNetworkDrop();
              } else {
                _simulateNetworkRestore();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Warning container using color cues to signify hidden action / network state
          if (!_isNetworkAvailable)
            ScaleTransition(
              scale: _elasticAnimation,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                color: colorScheme.errorContainer,
                child: Text(
                  'Network connection lost. Background requests halted.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onErrorContainer,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification notification) {
                // Additional hook for gesture paths cleanly matching natural finger reach zones
                return false;
              },
              child: ListView.builder(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                itemCount: _items.length + (_isLoading || !_hasMoreData ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _items.length) {
                    if (_isLoading) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24.0),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (!_hasMoreData) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24.0),
                        child: Center(
                          child: Text(
                            'End of records reached.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      );
                    }
                  }

                  final item = _items[index];
                  return _buildCompactDataRow(item, theme, colorScheme);
                },
              ),
            ),
          ),
          
          // Quiet, continuous total row counter replacing traditional page number footer bars
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              border: Border(top: BorderSide(color: colorScheme.outlineVariant, width: 0.5)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Rows: ${_items.length}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  'Page: $_currentPage',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Keep data row layouts compact on mobile to maximize information visible on small displays.
  Widget _buildCompactDataRow(ScrollDataRow item, ThemeData theme, ColorScheme colorScheme) {
    final bool isFailed = item.executionStatus == 'Failed';
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: BorderSide(
          color: isFailed ? colorScheme.error.withOpacity(0.5) : colorScheme.outlineVariant.withOpacity(0.3),
          width: 1.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Visual status indicator
            Container(
              width: 4.0,
              height: 40.0,
              margin: const EdgeInsets.only(right: 12.0),
              decoration: BoxDecoration(
                color: isFailed ? colorScheme.error : colorScheme.primary,
                borderRadius: BorderRadius.circular(2.0),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.stepExecutionId,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    item.stepOutcome,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.executionStatus,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isFailed ? colorScheme.error : colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  '${item.executionTimestamp.hour}:${item.executionTimestamp.minute.toString().padLeft(2, '0')}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
