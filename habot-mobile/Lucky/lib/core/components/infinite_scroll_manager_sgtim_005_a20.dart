// SGTIM-005-A20 — InfiniteScrollManager widget with scroll position listeners, background data fetching, and network-aware debounce.
// Implements continuous scrolling for primary asset lists on mobile, replacing traditional pagination with batched data loading, rapid-click blocking, and connection monitoring.

import 'dart:async';
import 'package:flutter/material.dart';

/// Represents a single row of mock asset data for infinite scrolling demonstration.
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
  static List<AssetRowData> fetchBatch(int offset, int limit) {
    return List.generate(limit, (index) {
      final actualIndex = offset + index;
      return AssetRowData(
        id: 'AST-${actualIndex.toString().padLeft(5, '0')}',
        title: 'Asset Item $actualIndex',
        description: 'Detailed description for asset item number $actualIndex in the UDF module.',
        timestamp: DateTime.now().subtract(Duration(hours: actualIndex)),
      );
    });
  }
}

/// A reusable continuous list scroll rendering container that handles
/// infinite scrolling, debouncing, network state awareness, and scroll restoration.
class InfiniteScrollManager extends StatefulWidget {
  final ScrollController? externalScrollController;
  final double loadThreshold;
  final int batchSize;
  final Duration debounceDuration;
  final Widget Function(BuildContext context, AssetRowData item, int index) itemBuilder;
  final Widget? emptyStateWidget;
  final Widget? loadingIndicator;
  final Widget? errorWidget;
  final String? restoreScrollKey;

  const InfiniteScrollManager({
    super.key,
    this.externalScrollController,
    this.loadThreshold = 200.0,
    this.batchSize = 20,
    this.debounceDuration = const Duration(milliseconds: 300),
    required this.itemBuilder,
    this.emptyStateWidget,
    this.loadingIndicator,
    this.errorWidget,
    this.restoreScrollKey,
  });

  @override
  State<InfiniteScrollManager> createState() => _InfiniteScrollManagerState();
}

class _InfiniteScrollManagerState extends State<InfiniteScrollManager> {
  late final ScrollController _scrollController;
  final List<AssetRowData> _items = [];
  
  bool _isLoading = false;
  bool _hasMoreData = true;
  bool _isNetworkAvailable = true;
  bool _isBlocked = false; // Rapid click-block filter
  
  Timer? _debounceTimer;
  double? _restoredScrollOffset;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.externalScrollController ?? ScrollController();
    _scrollController.addListener(_onScroll);
    _loadInitialData();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _scrollController.removeListener(_onScroll);
    if (widget.externalScrollController == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  /// Simulates a network connectivity monitor.
  /// Halts background data requests instantly if connection monitors report a total network drop.
  void updateNetworkStatus(bool isAvailable) {
    if (_isNetworkAvailable != isAvailable) {
      setState(() {
        _isNetworkAvailable = isAvailable;
      });
      if (isAvailable && _hasMoreData && !_isLoading) {
        _fetchNextBatch();
      }
    }
  }

  void _onScroll() {
    if (!_isNetworkAvailable || _isBlocked || _isLoading || !_hasMoreData) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    if (maxScroll - currentScroll <= widget.loadThreshold) {
      _debounceFetch();
    }
  }

  /// Adds rapid click-block filters / debounce to scroll triggers to stop duplicate data calls.
  void _debounceFetch() {
    if (_isBlocked) return;
    
    _isBlocked = true;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(widget.debounceDuration, () {
      _isBlocked = false;
      _fetchNextBatch();
    });
  }

  Future<void> _loadInitialData() async {
    await _fetchNextBatch(isInitial: true);
  }

  Future<void> _fetchNextBatch({bool isInitial = false}) async {
    if (_isLoading || !_hasMoreData || !_isNetworkAvailable) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate network latency for background data call
      await Future.delayed(const Duration(milliseconds: 600));

      final newItems = MockAssetRepository.fetchBatch(_items.length, widget.batchSize);

      if (!mounted) return;

      setState(() {
        _items.addAll(newItems);
        _isLoading = false;
        // Stop after 200 items for mock purposes to demonstrate end-of-list behavior
        if (_items.length >= 200 || newItems.isEmpty) {
          _hasMoreData = false;
        }
      });

      // Self-Chasing: Restore exact scroll position if views reload
      if (isInitial && _restoredScrollOffset != null && _scrollController.hasClients) {
        _scrollController.jumpTo(_restoredScrollOffset!);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Public method to save scroll position for self-chasing (state restoration)
  void saveScrollPosition() {
    if (_scrollController.hasClients) {
      _restoredScrollOffset = _scrollController.offset;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_items.isEmpty && _isLoading) {
      return Center(
        child: widget.loadingIndicator ?? const CircularProgressIndicator(),
      );
    }

    if (_items.isEmpty && !_isLoading) {
      return widget.emptyStateWidget ??
          const Center(child: Text('No assets available.'));
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        // Material Design Implementation: Animate component translations elastically
        // handled natively by Flutter's ScrollPhysics (BouncingScrollPhysics for iOS, Clamping for Android)
        return false;
      },
      child: ListView.builder(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        padding: EdgeInsets.zero,
        itemCount: _items.length + (_hasMoreData ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _items.length) {
            if (!_isNetworkAvailable) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Center(
                  child: Text(
                    'Network unavailable. Reconnecting...',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              );
            }
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Center(
                child: widget.loadingIndicator ?? const CircularProgressIndicator(),
              ),
            );
          }
          return widget.itemBuilder(context, _items[index], index);
        },
      ),
    );
  }
}

/// A compact mobile-first row layout designed to maximize information visible on small displays.
class CompactAssetRow extends StatelessWidget {
  final AssetRowData data;

  const CompactAssetRow({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: colorScheme.outlineVariant.withOpacity(0.5),
              width: 1.0,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    data.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12.0),
            // Color cues to signify type/status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Text(
                data.id,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Example usage wrapper demonstrating how to integrate the InfiniteScrollManager
/// into a screen while adhering to Mobile-First & Responsive UX standards.
class InfiniteScrollExampleScreen extends StatefulWidget {
  const InfiniteScrollExampleScreen({super.key});

  @override
  State<InfiniteScrollExampleScreen> createState() => _InfiniteScrollExampleScreenState();
}

class _InfiniteScrollExampleScreenState extends State<InfiniteScrollExampleScreen> {
  final GlobalKey<InfiniteScrollManagerState> _scrollManagerKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asset Explorer'),
        centerTitle: false,
        elevation: 0.0,
      ),
      body: InfiniteScrollManager(
        key: _scrollManagerKey,
        batchSize: 20,
        loadThreshold: 250.0,
        itemBuilder: (context, item, index) => CompactAssetRow(data: item),
        emptyStateWidget: const Center(child: Text('No assets found.')),
      ),
    );
  }
}

/// Exposing state for external control if needed (e.g., saving scroll position from parent)
class InfiniteScrollManagerState extends State<InfiniteScrollManager> {
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}