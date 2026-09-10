// CPNCA-006-A15 — Standardized virtualized chunked list for mobile data tables.
// Lazily renders rows from paginated chunks, enforces max 50-row requests, supports MD3 pull-to-refresh, brand loading indicators, and frame-drop telemetry.
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

typedef ChunkFetcher<T> = Future<List<T>> Function(int offset, int limit);
typedef RowBuilder<T> = Widget Function(BuildContext context, T item, int index);

class VirtualizedChunkedList<T> extends StatefulWidget {
  const VirtualizedChunkedList({
    super.key,
    required this.fetchChunk,
    required this.itemBuilder,
    this.pageSize = 50,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.scrollPhysics,
    this.emptyBuilder,
    this.errorBuilder,
    this.onPerformanceFlag,
  }) : assert(pageSize > 0, 'pageSize must be positive');

  final ChunkFetcher<T> fetchChunk;
  final RowBuilder<T> itemBuilder;
  final int pageSize;
  final EdgeInsetsGeometry padding;
  final ScrollPhysics? scrollPhysics;
  final WidgetBuilder? emptyBuilder;
  final Widget Function(BuildContext context, Object error, VoidCallback retry)? errorBuilder;
  final ValueChanged<String>? onPerformanceFlag;

  @override
  State<VirtualizedChunkedList<T>> createState() => _VirtualizedChunkedListState<T>();
}

class _VirtualizedChunkedListState<T> extends State<VirtualizedChunkedList<T>> {
  final ScrollController _scrollController = ScrollController();
  final List<T> _items = <T>[];
  bool _isInitialLoading = true;
  bool _isLoading = false;
  bool _hasMore = true;
  Object? _error;
  int _offset = 0;
  TimingsCallback? _timingsCallback;
  DateTime _lastPerformanceFlag = DateTime.fromMillisecondsSinceEpoch(0);

  static const int _maxPageSize = 50;
  static const double _loadMoreExtent = 800;
  static const int _frameDropThresholdMicros = 22222;
  static const Duration _performanceFlagCooldown = Duration(seconds: 5);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _timingsCallback = _onFrameTimings;
    SchedulerBinding.instance.addTimingsCallback(_timingsCallback!);
    unawaited(_loadNextChunk());
  }

  @override
  void dispose() {
    if (_timingsCallback != null) {
      SchedulerBinding.instance.removeTimingsCallback(_timingsCallback!);
    }
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.extentAfter < _loadMoreExtent) {
      unawaited(_loadNextChunk());
    }
  }

  void _onFrameTimings(List<FrameTiming> timings) {
    if (widget.onPerformanceFlag == null) return;
    final now = DateTime.now();
    if (now.difference(_lastPerformanceFlag) < _performanceFlagCooldown) return;
    for (final timing in timings) {
      if (timing.totalSpan.inMicroseconds > _frameDropThresholdMicros) {
        _lastPerformanceFlag = now;
        widget.onPerformanceFlag!('Scroll rendering dropped below 45fps; optimization queue flag raised.');
        break;
      }
    }
  }

  Future<void> _loadNextChunk() async {
    if (_isLoading || !_hasMore) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final int limit = widget.pageSize > _maxPageSize ? _maxPageSize : widget.pageSize;
    try {
      final chunk = await widget.fetchChunk(_offset, limit);
      if (!mounted) return;
      setState(() {
        _items.addAll(chunk);
        _offset += chunk.length;
        _hasMore = chunk.length == limit;
        _isLoading = false;
        _isInitialLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error;
        _isLoading = false;
        _isInitialLoading = false;
      });
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _items.clear();
      _offset = 0;
      _hasMore = true;
      _error = null;
      _isLoading = false;
      _isInitialLoading = true;
    });
    await _loadNextChunk();
  }

  Widget _buildFooter(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: TextButton.icon(
            onPressed: () => unawaited(_loadNextChunk()),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry loading more'),
          ),
        ),
      );
    }
    if (_isLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CircularProgressIndicator(color: colorScheme.primary)),
      );
    }
    if (_hasMore) {
      return const SizedBox(height: 48);
    }
    return const SizedBox.shrink();
  }

  Widget _buildError(BuildContext context, Object error, VoidCallback retry) {
    if (widget.errorBuilder != null) return widget.errorBuilder!(context, error, retry);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 12),
            Text('Unable to load data.\n$error', textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(onPressed: retry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_isInitialLoading && _items.isEmpty) {
      return Center(child: CircularProgressIndicator(color: colorScheme.primary));
    }

    if (_error != null && _items.isEmpty) {
      return _buildError(context, _error!, () => unawaited(_refresh()));
    }

    if (_items.isEmpty) {
      return RefreshIndicator(
        color: colorScheme.primary,
        onRefresh: _refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: MediaQuery.sizeOf(context).height * 0.25),
            Center(child: widget.emptyBuilder?.call(context) ?? const Text('No records found.')),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: colorScheme.primary,
      onRefresh: _refresh,
      child: ListView.builder(
        controller: _scrollController,
        physics: widget.scrollPhysics ?? const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        padding: widget.padding,
        itemCount: _items.length + ((_isLoading || _hasMore || _error != null) ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= _items.length) return _buildFooter(context);
          final row = widget.itemBuilder(context, _items[index], index);
          return Semantics(
            container: true,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48),
              child: row,
            ),
          );
        },
      ),
    );
  }
}
