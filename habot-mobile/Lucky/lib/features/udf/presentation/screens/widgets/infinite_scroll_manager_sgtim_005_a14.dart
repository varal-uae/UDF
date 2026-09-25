// SGTIM-005-A14 — InfiniteScrollManager widget for continuous list scrolling.
// Implements scroll position listeners, background data fetching, duplicate call prevention, and network drop handling with mock data fallback.

import 'dart:async';
import 'package:flutter/material.dart';

/// Mock data model representing a row in the asset list.
class AssetRowData {
  final String id;
  final String syncType;
  final String syncStatus;
  final DateTime lastSyncDate;
  final int syncConflicts;
  final Duration syncDuration;
  final String title;

  const AssetRowData({
    required this.id,
    required this.syncType,
    required this.syncStatus,
    required this.lastSyncDate,
    required this.syncConflicts,
    required this.syncDuration,
    required this.title,
  });
}

/// Generates realistic local mock data to simulate backend API responses.
List<AssetRowData> _generateMockChunk(int startIndex, int count) {
  return List.generate(count, (index) {
    final i = startIndex + index;
    return AssetRowData(
      id: 'asset_$i',
      syncType: i % 3 == 0 ? 'Full' : 'Incremental',
      syncStatus: i % 5 == 0 ? 'Conflict' : 'Success',
      lastSyncDate: DateTime.now().subtract(Duration(hours: i)),
      syncConflicts: i % 5 == 0 ? 2 : 0,
      syncDuration: Duration(milliseconds: 150 + (i * 10)),
      title: 'Asset Item $i',
    );
  });
}

/// A reusable continuous list scroll rendering container that fetches
/// data in chunks as the user scrolls to the bottom.
class InfiniteScrollManager extends StatefulWidget {
  final int pageSize;
  final int totalItems;

  const InfiniteScrollManager({
    super.key,
    this.pageSize = 20,
    this.totalItems = 200,
  });

  @override
  State<InfiniteScrollManager> createState() => _InfiniteScrollManagerState();
}

class _InfiniteScrollManagerState extends State<InfiniteScrollManager> {
  final ScrollController _scrollController = ScrollController();
  final List<AssetRowData> _items = [];
  
  bool _isLoading = false;
  bool _hasMoreData = true;
  bool _isNetworkAvailable = true;
  
  // Rapid click-block filter / debounce mechanism to stop duplicate data calls
  Timer? _debounceTimer;
  int _currentPage = 0;

  // Self-Chasing: remembers exact row index for restoration
  int _lastViewedIndex = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _fetchNextChunk();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    
    // Track position for self-chasing behavior
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    
    if (currentScroll > 0 && maxScroll > 0) {
      final ratio = currentScroll / maxScroll;
      _lastViewedIndex = (_items.length * ratio).floor();
    }

    // Trigger fetch when reaching 80% of the scroll extent
    if (currentScroll >= maxScroll * 0.8 && !_isLoading && _hasMoreData) {
      _debouncedFetch();
    }
  }

  /// Prevents duplicate calls by adding rapid click-block filters to scroll triggers.
  void _debouncedFetch() {
    if (_debounceTimer?.isActive ?? false) return;
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _fetchNextChunk();
    });
  }

  /// Simulates an asynchronous background API network call to request the next chunk.
  Future<void> _fetchNextChunk() async {
    if (_isLoading || !_hasMoreData || !_isNetworkAvailable) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate network latency
      await Future.delayed(const Duration(milliseconds: 800));

      // Mistake-Proofing (Poka-Yoke): Halt requests instantly if connection drops
      if (!_isNetworkAvailable) {
        throw Exception('Network connection dropped.');
      }

      final startIdx = _currentPage * widget.pageSize;
      final newItems = _generateMockChunk(startIdx, widget.pageSize);

      if (!mounted) return;

      setState(() {
        _items.addAll(newItems);
        _currentPage++;
        _isLoading = false;
        if (_items.length >= widget.totalItems) {
          _hasMoreData = false;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      debugPrint('SGTIM-005-A14 Error fetching chunk: $e');
    }
  }

  /// Restores the user's exact scroll position (Self-Chasing requirement)
  void _restoreScrollPosition() {
    if (_items.isEmpty || !_scrollController.hasClients) return;
    
    final maxScroll = _scrollController.position.maxScrollExtent;
    final targetOffset = (_lastViewedIndex / _items.length) * maxScroll;
    
    _scrollController.animateTo(
      targetOffset.clamp(0.0, maxScroll),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Column(
      children: [
        // Continuous total row counter replacing traditional page number footer bars
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Rows Loaded: ${_items.length}',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, size: 20),
                tooltip: 'Restore Position',
                onPressed: _restoreScrollPosition,
              ),
            ],
          ),
        ),
        Expanded(
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              // Elastic animation context handled natively by Flutter's physics
              return false;
            },
            child: ListView.builder(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              padding: EdgeInsets.zero,
              itemCount: _items.length + (_hasMoreData ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _items.length) {
                  return _buildLoadingIndicator(theme);
                }
                return _buildDataRow(context, _items[index], isMobile, theme);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingIndicator(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2.0,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  /// Keep data row layouts compact on mobile to maximize information visible on small displays.
  Widget _buildDataRow(
    BuildContext context,
    AssetRowData data,
    bool isMobile,
    ThemeData theme,
  ) {
    final hasConflict = data.syncConflicts > 0;
    
    // Use color cues (e.g., warning container) to signify the type of hidden action/state
    final statusColor = hasConflict 
        ? theme.colorScheme.errorContainer 
        : theme.colorScheme.primaryContainer;
    final statusTextColor = hasConflict 
        ? theme.colorScheme.onErrorContainer 
        : theme.colorScheme.onPrimaryContainer;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 12.0 : 24.0,
            vertical: isMobile ? 8.0 : 12.0,
          ),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: theme.colorScheme.outlineVariant.withOpacity(0.3),
                width: 1.0,
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  data.title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (!isMobile)
                Expanded(
                  flex: 2,
                  child: Text(
                    data.syncType,
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              Expanded(
                flex: isMobile ? 2 : 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    data.syncStatus,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: statusTextColor,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${data.syncDuration.inMilliseconds}ms',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
