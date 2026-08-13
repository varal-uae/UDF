/// AISS: CPNCA-006-A01 -- "Build a standardized list virtualization and
/// dynamic data chunking component for data tables."
///
/// 4 Substeps:
///   1. "Author a container component that calculates visible viewport
///       boundaries using real-time scroll tracking."
///   2. "Implement data partitioning hooks that fetch record batches (e.g., 20
///       items per request) rather than loading entire datasets at once."
///   3. "Create structural placeholder rows for records still loading."
///   4. "Verify element counts remain stable during continuous scrolling."
///
/// Completion Measure: "Loading a test collection of 10,000 items preserves a
/// consistent, low DOM element count during continuous scrolling."
///
/// Decision to be Made Before Setup Step: "Choose between using infinite
/// scrolling mechanics or clear 'Load More' action flags based on data
/// accessibility needs."
///   Recorded answer: infinite scroll, with a visible loading row at the seam
///   and an explicit "Load more" control when [HabotVirtualList.manualLoadMore]
///   is set. Infinite is right for a task queue the user works down; manual is
///   right for a table someone is auditing, where an automatic fetch moves the
///   ground under them. One component, one flag -- not two components.
///
/// The Flutter translation of "DOM element count" is the number of child
/// elements the framework has materialised. [ListView.builder] with a
/// [SliverChildBuilderDelegate] only builds what the viewport can show plus a
/// cache margin, which is what makes the count stay flat at 10,000 items --
/// and `CPNCA-006-G5` measures it rather than trusting it.
library;

import 'dart:async';

import 'package:flutter/material.dart';

import '../feedback/empty_state.dart';
import '../feedback/progress_indicators.dart';
import '../tokens/spacing_tokens.dart';
import '../tokens/surface_tokens.dart';

/// One page of records, as returned by a fetch.
class HabotChunk<T> {
  const HabotChunk({required this.items, required this.hasMore});

  final List<T> items;

  /// False when the source has nothing left. The list stops asking.
  final bool hasMore;

  static HabotChunk<T> end<T>() => HabotChunk<T>(items: <T>[], hasMore: false);
}

/// Fetches the chunk starting at [offset], at most [limit] records.
typedef HabotChunkFetcher<T> =
    Future<HabotChunk<T>> Function(int offset, int limit);

/// Owns the loaded window and the fetch state. Kept separate from the widget so
/// the chunking logic is unit-testable without a viewport.
class HabotChunkController<T> extends ChangeNotifier {
  HabotChunkController({
    required this.fetch,
    this.chunkSize = HabotDiscovery.chunkSize,
  });

  final HabotChunkFetcher<T> fetch;
  final int chunkSize;

  final List<T> _items = <T>[];
  bool _hasMore = true;
  bool _loading = false;
  int _fetchCount = 0;
  Object? _error;

  List<T> get items => List<T>.unmodifiable(_items);
  int get loadedCount => _items.length;
  bool get hasMore => _hasMore;
  bool get isLoading => _loading;
  Object? get error => _error;

  /// How many times the source was actually asked for data. The duplicate
  /// suppression gate reads this.
  int get fetchCount => _fetchCount;

  /// True when the loaded window is empty and nothing is in flight -- i.e. the
  /// list should show an empty state rather than a spinner.
  bool get isEmpty => _items.isEmpty && !_loading && !_hasMore;

  /// Requests the next chunk. Safe to call repeatedly: a fetch already in
  /// flight, or a source with nothing left, is a no-op rather than a second
  /// request. Substep 2's "rather than loading entire datasets at once" only
  /// holds if a fast scroll cannot stack ten overlapping fetches.
  Future<void> loadMore() async {
    if (_loading || !_hasMore) {
      return;
    }
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _fetchCount++;
      final HabotChunk<T> chunk = await fetch(_items.length, chunkSize);
      _items.addAll(chunk.items);
      _hasMore = chunk.hasMore && chunk.items.isNotEmpty;
    } catch (error) {
      _error = error;
      _hasMore = false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Substep 1: given the index the viewport has reached, decide whether the
  /// next chunk is due. Pure, so the gate can drive it with indices instead of
  /// synthetic scroll gestures.
  bool shouldPrefetch(int visibleIndex) =>
      _hasMore &&
      !_loading &&
      visibleIndex >= _items.length - HabotDiscovery.prefetchThreshold;

  void reset() {
    _items.clear();
    _hasMore = true;
    _loading = false;
    _error = null;
    notifyListeners();
  }
}

/// The virtualised list.
class HabotVirtualList<T> extends StatefulWidget {
  const HabotVirtualList({
    required this.controller,
    required this.itemBuilder,
    this.manualLoadMore = false,
    this.emptyReason = HabotEmptyReason.nothingYet,
    super.key,
  });

  final HabotChunkController<T> controller;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;

  /// The recorded decision, as a flag. See the library doc.
  final bool manualLoadMore;

  final HabotEmptyReason emptyReason;

  @override
  State<HabotVirtualList<T>> createState() => _HabotVirtualListState<T>();
}

class _HabotVirtualListState<T> extends State<HabotVirtualList<T>> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
    if (widget.controller.loadedCount == 0) {
      unawaited(widget.controller.loadMore());
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final HabotChunkController<T> controller = widget.controller;
    if (controller.isEmpty) {
      return HabotEmptyState(reason: widget.emptyReason);
    }
    return ListView.builder(
      itemCount: controller.loadedCount + (controller.hasMore ? 1 : 0),
      itemBuilder: (BuildContext context, int index) =>
          _buildRow(context, controller, index),
    );
  }

  Widget _buildRow(
    BuildContext context,
    HabotChunkController<T> controller,
    int index,
  ) {
    if (index >= controller.loadedCount) {
      return _SeamRow(controller: controller, manual: widget.manualLoadMore);
    }
    if (!widget.manualLoadMore && controller.shouldPrefetch(index)) {
      // Scheduled rather than called inline: a fetch that calls setState during
      // build is a framework error, and this runs while the row is building.
      scheduleMicrotask(controller.loadMore);
    }
    return widget.itemBuilder(context, controller.items[index], index);
  }
}

/// Substep 3: "structural placeholder rows for records still loading."
///
/// A row of the same height as a real one, so the scrollbar does not jump when
/// the chunk lands -- the placeholder is holding the space the record will use.
class _SeamRow extends StatelessWidget {
  const _SeamRow({required this.controller, required this.manual});

  final HabotChunkController<dynamic> controller;
  final bool manual;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: HabotDiscovery.searchResultRowHeight,
      child: Center(
        child: manual && !controller.isLoading
            ? TextButton(
                onPressed: controller.loadMore,
                child: const Text('Load more'),
              )
            : const Padding(
                padding: EdgeInsets.symmetric(horizontal: HabotSpacing.md),
                child: HabotProgressBar(value: null, label: 'Loading more'),
              ),
      ),
    );
  }
}
