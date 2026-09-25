// SGTIM-005-A16 — InfiniteScrollManager widget for continuous list scrolling.
// Implements scroll position listeners, background data fetching with mock data, network drop halting, duplicate call prevention, and scroll position memory.

import 'dart:async';
import 'package:flutter/material.dart';

/// Data model representing a row in the asset list.
class AssetRowData {
  final String objectType;
  final String objectLocationPath;
  final bool openStatus;
  final DateTime timestamp;
  final String fileHandleId;

  const AssetRowData({
    required this.objectType,
    required this.objectLocationPath,
    required this.openStatus,
    required this.timestamp,
    required this.fileHandleId,
  });
}

/// Generates realistic local mock data to simulate backend delivery.
List<AssetRowData> _generateMockBatch(int startIndex, int count) {
  return List.generate(count, (index) {
    final i = startIndex + index;
    return AssetRowData(
      objectType: i % 3 == 0 ? 'Document' : (i % 3 == 1 ? 'Image' : 'Spreadsheet'),
      objectLocationPath: '/assets/workspace/project_alpha/file_$i.dat',
      openStatus: i % 2 == 0,
      timestamp: DateTime.now().subtract(Duration(hours: i)),
      fileHandleId: 'FH-${100000 + i}',
    );
  });
}

/// A reusable continuous list scroll rendering container.
/// Replaces traditional page number navigation with infinite scrolling.
class InfiniteScrollManager extends StatefulWidget {
  final int batchSize;
  final Widget Function(BuildContext context, AssetRowData item, int index)? itemBuilder;

  const InfiniteScrollManager({
    super.key,
    this.batchSize = 20,
    this.itemBuilder,
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
  double _lastSavedScrollOffset = 0.0;
  
  Timer? _networkMonitorTimer;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _fetchNextBatch();
    _startNetworkMonitor();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _networkMonitorTimer?.cancel();
    super.dispose();
  }

  /// Simulates connection monitoring; halts requests instantly on total network drop.
  void _startNetworkMonitor() {
    _networkMonitorTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      // In production, hook into ConnectivityPlus or similar.
      // Mocking a stable connection here.
      if (!_isNetworkAvailable && mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    
    // Self-Chasing: Remember exact row/position
    _lastSavedScrollOffset = _scrollController.offset;

    // Trigger background data calls when nearing the bottom
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _fetchNextBatch();
    }
  }

  Future<void> _fetchNextBatch() async {
    // Mistake-Proofing (Poka-Yoke): Stop duplicate data calls & halt on network drop
    if (_isLoading || !_hasMoreData || !_isNetworkAvailable) return;

    setState(() {
      _isLoading = true;
    });

    // Simulate network latency for batch fetching
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    final newItems = _generateMockBatch(_items.length, widget.batchSize);
    
    setState(() {
      _items.addAll(newItems);
      _isLoading = false;
      // Reset the data loading flag variable to false to open up the next scroll check cycle
      // Simulate end of mock data after 200 items
      if (_items.length >= 200) {
        _hasMoreData = false;
      }
    });

    // Restore scroll position if view reloaded (Self-Chasing)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients && _lastSavedScrollOffset > 0) {
        _scrollController.jumpTo(_lastSavedScrollOffset);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: NotificationListener<ScrollNotification>(
            onNotification: (scrollInfo) {
              // Additional scroll metrics can be captured here for telemetry
              return false;
            },
            child: ListView.builder(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              itemCount: _items.length + (_isLoading ? 1 : 0) + (!_hasMoreData ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= _items.length) {
                  if (_isLoading) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (!_hasMoreData) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Center(
                        child: Text('End of records', style: TextStyle(color: Colors.grey)),
                      ),
                    );
                  }
                }

                final item = _items[index];
                
                if (widget.itemBuilder != null) {
                  return widget.itemBuilder!(context, item, index);
                }

                // Default compact mobile layout maximizing visible information
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.1))),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            item.objectType == 'Document' ? Icons.description_outlined : 
                            item.objectType == 'Image' ? Icons.image_outlined : Icons.table_chart_outlined,
                            size: 20,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.fileHandleId,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  item.objectLocationPath,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: item.openStatus ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  item.openStatus ? 'Open' : 'Closed',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: item.openStatus ? Colors.green[700] : Colors.orange[700],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${item.timestamp.hour}:${item.timestamp.minute.toString().padLeft(2, '0')}',
                                style: Theme.of(context).textTheme.labelSmall,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        // Quiet, continuous total row counter replacing traditional page footer bars
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
          alignment: Alignment.center,
          child: Text(
            'Total Rows Loaded: ${_items.length}',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}