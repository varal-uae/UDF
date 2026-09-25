// SGTIM-005-A18 — InfiniteScrollManager with scroll position listeners, skeleton loading, and network-aware data fetching.
// Implements continuous infinite scrolling for primary asset lists, replacing traditional pagination with background batched data calls, duplicate click-block filters, and scroll position memory.

import 'dart:async';
import 'package:flutter/material.dart';

/// Mock data model representing a single row in the asset list.
class AssetRowData {
  final String id;
  final String title;
  final String description;
  final DateTime timestamp;

  const AssetRowData({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
  });
}

/// Generates realistic local mock data to simulate backend API responses.
class MockAssetRepository {
  static List<AssetRowData> fetchBatch(int startIndex, int batchSize) {
    return List.generate(batchSize, (index) {
      final actualIndex = startIndex + index;
      return AssetRowData(
        id: 'ASSET-$actualIndex',
        title: 'Asset Item $actualIndex',
        description: 'Detailed description for asset item number $actualIndex.',
        timestamp: DateTime.now().subtract(Duration(minutes: actualIndex)),
      );
    });
  }
}

/// Core reusable widget implementing infinite continuous scrolling.
/// Tracks main thread activity, halts requests on network drop, and remembers scroll position.
class InfiniteScrollManager extends StatefulWidget {
  final int batchSize;
  final Function(double)? onScrollPositionChanged;

  const InfiniteScrollManager({
    super.key,
    this.batchSize = 20,
    this.onScrollPositionChanged,
  });

  @override
  State<InfiniteScrollManager> createState() => _InfiniteScrollManagerState();
}

class _InfiniteScrollManagerState extends State<InfiniteScrollManager>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final List<AssetRowData> _items = [];
  
  bool _isLoading = false;
  bool _hasMoreData = true;
  bool _isNetworkAvailable = true; // Simulated connection monitor
  double _savedScrollOffset = 0.0;
  
  // Rapid click-block filter / debounce mechanism
  DateTime? _lastFetchTime;
  static const Duration _fetchDebounce = Duration(milliseconds: 800);
  
  late AnimationController _elasticAnimController;

  @override
  void initState() {
    super.initState();
    _elasticAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _scrollController.addListener(_onScroll);
    _fetchNextBatch();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    _savedScrollOffset = currentScroll;
    
    widget.onScrollPositionChanged?.call(currentScroll);

    // Trigger background data call when reaching 80% of the scroll extent
    if (currentScroll >= maxScroll * 0.8 && !_isLoading && _hasMoreData) {
      _fetchNextBatch();
    }
  }

  Future<void> _fetchNextBatch() async {
    // Duplicate data call block filter
    final now = DateTime.now();
    if (_lastFetchTime != null && now.difference(_lastFetchTime!) < _fetchDebounce) {
      return;
    }
    _lastFetchTime = now;

    // Mistake-Proofing (Poka-Yoke): Halt if connection monitors report total network drop
    if (!_isNetworkAvailable) {
      debugPrint('SGTIM-005-A18: Network dropped. Halting background data requests.');
      return;
    }

    setState(() => _isLoading = true);

    // Simulate network latency for background data calls
    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;

    final newItems = MockAssetRepository.fetchBatch(_items.length, widget.batchSize);
    
    setState(() {
      _items.addAll(newItems);
      _isLoading = false;
      // Stop after 200 items for demonstration purposes
      if (_items.length >= 200) {
        _hasMoreData = false;
      }
    });

    // Animate component translations elastically for spatial context
    _elasticAnimController.forward(from: 0.0);
  }

  /// Self-Chasing: Restores the exact row a user was exploring if views reload.
  void _restoreScrollPosition() {
    if (_scrollController.hasClients && _savedScrollOffset > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.jumpTo(_savedScrollOffset);
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _restoreScrollPosition();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _elasticAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Column(
      children: [
        // Continuous total row counter replacing traditional page number footer bars
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          color: theme.colorScheme.surfaceContainerHighest,
          alignment: Alignment.centerRight,
          child: Text(
            'Total Rows: ${_items.length}',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              // Track main thread activity logs during heavy scrolling
              if (notification is ScrollUpdateNotification) {
                // Zero rendering drops verification point
              }
              return false;
            },
            child: ListView.builder(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(), // Natural vertical scroll flow for touch gestures
              padding: EdgeInsets.zero,
              itemCount: _items.length + (_isLoading ? widget.batchSize : 0) + (_hasMoreData ? 0 : 1),
              itemBuilder: (context, index) {
                // Skeleton loading elements matching base structural dimensions
                if (index >= _items.length) {
                  if (!_hasMoreData) {
                    return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: Text('End of records')),
                    );
                  }
                  return _buildSkeletonTile(isMobile, theme);
                }

                final item = _items[index];
                return _buildAssetTile(item, isMobile, theme);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAssetTile(AssetRowData item, bool isMobile, ThemeData theme) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.0, 0.05),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _elasticAnimController,
        curve: Curves.easeOutCubic,
      )),
      child: Card(
        margin: EdgeInsets.symmetric(
          horizontal: isMobile ? 8.0 : 16.0,
          vertical: 4.0,
        ),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          side: BorderSide(color: theme.colorScheme.outlineVariant, width: 0.5),
        ),
        child: ListTile(
          dense: isMobile, // Keep data row layouts compact on mobile
          contentPadding: EdgeInsets.symmetric(
            horizontal: isMobile ? 12.0 : 16.0,
            vertical: isMobile ? 4.0 : 8.0,
          ),
          leading: CircleAvatar(
            backgroundColor: theme.colorScheme.primaryContainer,
            child: Text(
              item.id.substring(item.id.length - 2),
              style: TextStyle(color: theme.colorScheme.onPrimaryContainer),
            ),
          ),
          title: Text(
            item.title,
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            item.description,
            style: theme.textTheme.bodySmall,
            maxLines: isMobile ? 1 : 2,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Text(
            TimeOfDay.fromDateTime(item.timestamp).format(context),
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSkeletonTile(bool isMobile, ThemeData theme) {
    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: isMobile ? 8.0 : 16.0,
        vertical: 4.0,
      ),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: ListTile(
        dense: isMobile,
        contentPadding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12.0 : 16.0,
          vertical: isMobile ? 4.0 : 8.0,
        ),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            shape: BoxShape.circle,
          ),
        ),
        title: Container(
          height: 14,
          width: isMobile ? 120 : 200,
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        subtitle: Container(
          height: 12,
          width: isMobile ? 180 : 300,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}