// SGTIM-005-A05 — InfiniteScrollManager component for continuous list scrolling.
// Provides scroll position listeners, background data fetching with debounce,
// duplicate call prevention, network drop halting, and scroll position memory.

import 'dart:async';
import 'package:flutter/material.dart';

/// Represents a single row of atomic-level data fetched via infinite scroll.
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

/// Mock repository simulating backend data delivery in small batches.
class MockScrollDataRepository {
  static const int _batchSize = 20;
  static const int _maxItems = 100;

  Future<List<ScrollDataRow>> fetchNextBatch(int currentCount) async {
    // Simulate network latency
    await Future.delayed(const Duration(milliseconds: 600));

    if (currentCount >= _maxItems) return [];

    final int end = (currentCount + _batchSize).clamp(0, _maxItems);
    return List.generate(end - currentCount, (index) {
      final int id = currentCount + index + 1;
      return ScrollDataRow(
        stepExecutionId: 'STEP-$id',
        executionStatus: id % 5 == 0 ? 'Failed' : 'Completed',
        executionTimestamp: DateTime.now().subtract(Duration(minutes: id * 3)),
        stepOutcome: 'Outcome description for step $id',
        userId: 'USER-${(id % 10) + 1}',
      );
    });
  }
}

/// Enum representing the current state of the infinite scroll manager.
enum InfiniteScrollState { idle, loading, error, exhausted }

/// A reusable continuous list scroll rendering container that replaces
/// traditional page number navigation with natural vertical scroll flow.
/// Implements rapid click-block filters, network drop handling, and
/// scroll position memory.
class InfiniteScrollManager extends StatefulWidget {
  final ScrollController? externalScrollController;
  final double loadMoreThreshold;
  final Widget Function(BuildContext context, ScrollDataRow item, int index) itemBuilder;
  final VoidCallback? onNetworkDrop;

  const InfiniteScrollManager({
    super.key,
    this.externalScrollController,
    this.loadMoreThreshold = 200.0,
    required this.itemBuilder,
    this.onNetworkDrop,
  });

  @override
  State<InfiniteScrollManager> createState() => _InfiniteScrollManagerState();
}

class _InfiniteScrollManagerState extends State<InfiniteScrollManager> {
  late final ScrollController _scrollController;
  final MockScrollDataRepository _repository = MockScrollDataRepository();
  final List<ScrollDataRow> _items = [];

  InfiniteScrollState _state = InfiniteScrollState.idle;
  Timer? _debounceTimer;
  bool _isFetching = false;
  double _rememberedScrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.externalScrollController ?? ScrollController();
    _scrollController.addListener(_onScroll);
    _fetchInitialData();
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

  /// Poka-Yoke: Halt background data requests instantly if connection drops.
  void _handleNetworkDrop() {
    if (!mounted) return;
    setState(() {
      _state = InfiniteScrollState.error;
      _isFetching = false;
    });
    _debounceTimer?.cancel();
    widget.onNetworkDrop?.call();
  }

  Future<void> _fetchInitialData() async {
    await _loadMoreData();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    // Self-Chasing: Remember exact row position
    _rememberedScrollOffset = _scrollController.offset;

    final double maxScroll = _scrollController.position.maxScrollExtent;
    final double currentScroll = _scrollController.position.pixels;

    // Trigger load when near bottom
    if (maxScroll - currentScroll <= widget.loadMoreThreshold) {
      _triggerLoadWithDebounce();
    }
  }

  /// Stop duplicate data calls by adding rapid click-block filters to scroll triggers.
  void _triggerLoadWithDebounce() {
    if (_isFetching || _state == InfiniteScrollState.exhausted || _state == InfiniteScrollState.error) {
      return;
    }

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _loadMoreData();
    });
  }

  Future<void> _loadMoreData() async {
    if (_isFetching || !mounted) return;

    setState(() {
      _isFetching = true;
      _state = InfiniteScrollState.loading;
    });

    try {
      // Simulate network connectivity check
      final bool isConnected = true; // Replace with actual connectivity monitor
      if (!isConnected) {
        _handleNetworkDrop();
        return;
      }

      final List<ScrollDataRow> newItems = await _repository.fetchNextBatch(_items.length);

      if (!mounted) return;

      setState(() {
        _items.addAll(newItems);
        _isFetching = false;
        if (newItems.isEmpty) {
          _state = InfiniteScrollState.exhausted;
        } else {
          _state = InfiniteScrollState.idle;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _state = InfiniteScrollState.error;
        _isFetching = false;
      });
    }
  }

  /// Returns user right back to their place if views reload.
  void _restoreScrollPosition() {
    if (_scrollController.hasClients && _rememberedScrollOffset > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final double maxOffset = _scrollController.position.maxScrollExtent;
        _scrollController.jumpTo(_rememberedScrollOffset.clamp(0.0, maxOffset));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _restoreScrollPosition();

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        // Wire a scroll interaction listener callback to the primary view list container
        return false;
      },
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: EdgeInsets.zero,
        itemCount: _items.length + (_state == InfiniteScrollState.loading ? 1 : 0) + (_state == InfiniteScrollState.exhausted ? 1 : 0),
        itemBuilder: (BuildContext context, int index) {
          if (index < _items.length) {
            return widget.itemBuilder(context, _items[index], index);
          }

          if (_state == InfiniteScrollState.loading) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Center(
                child: CircularProgressIndicator.adaptive(),
              ),
            );
          }

          if (_state == InfiniteScrollState.exhausted) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Center(
                child: Text(
                  'All records loaded',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

/// Compact data row layout optimized for mobile displays to maximize information visibility.
class CompactScrollDataRowWidget extends StatelessWidget {
  final ScrollDataRow item;
  final int index;

  const CompactScrollDataRowWidget({
    super.key,
    required this.item,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: BorderSide(color: colorScheme.outlineVariant, width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    item.stepExecutionId,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                  decoration: BoxDecoration(
                    color: item.executionStatus == 'Completed'
                        ? colorScheme.primaryContainer
                        : colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Text(
                    item.executionStatus,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: item.executionStatus == 'Completed'
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onErrorContainer,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6.0),
            Text(
              item.stepOutcome,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'User: ${item.userId}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.outline,
                  ),
                ),
                Text(
                  _formatTimestamp(item.executionTimestamp),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.outline,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    return '${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')} '
        '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}
