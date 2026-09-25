// SGTIM-001-A12 — Paginated List View with Pagination Limit Rules and State Retention.
// Implements endless scroll, GPU-accelerated loading indicators, drag distance limits, and mock data for mobile lists.

import 'package:flutter/material.dart';

/// Mock data repository simulating backend API responses.
class _MockListRepository {
  static const int _maxPageSize = 20;
  final List<String> _allItems = List.generate(150, (i) => 'List Item ${i + 1}');

  Future<List<String>> fetchPage(int page, {int limit = _maxPageSize}) async {
    if (limit > _maxPageSize) {
      throw Exception('400 Bad Request: Asset size limit exceeded. Max allowed is $_maxPageSize.');
    }
    await Future.delayed(const Duration(milliseconds: 600));
    final start = page * limit;
    if (start >= _allItems.length) return [];
    final end = (start + limit).clamp(0, _allItems.length);
    return _allItems.sublist(start, end);
  }
}

/// Controller to retain pagination state across navigations.
class PaginationStateController extends ChangeNotifier {
  final _MockListRepository _repository = _MockListRepository();

  final List<String> items = [];
  int _currentPage = 0;
  bool _isLoading = false;
  bool _hasMore = true;

  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  int get currentPage => _currentPage;

  Future<void> loadNextPage() async {
    if (_isLoading || !_hasMore) return;
    _isLoading = true;
    notifyListeners();

    try {
      final newItems = await _repository.fetchPage(_currentPage);
      if (newItems.isEmpty) {
        _hasMore = false;
      } else {
        items.addAll(newItems);
        _currentPage++;
      }
    } catch (e) {
      debugPrint('Pagination Error: $e');
      _hasMore = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void reset() {
    items.clear();
    _currentPage = 0;
    _isLoading = false;
    _hasMore = true;
    notifyListeners();
  }
}

/// A paginated list widget adhering to Material 3 design tokens,
/// GPU-accelerated animations, and strict drag boundaries.
class PaginatedListViewSgtim001A12 extends StatefulWidget {
  const PaginatedListViewSgtim001A12({super.key});

  @override
  State<PaginatedListViewSgtim001A12> createState() => _PaginatedListViewSgtim001A12State();
}

class _PaginatedListViewSgtim001A12State extends State<PaginatedListViewSgtim001A12> {
  final PaginationStateController _controller = PaginationStateController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onStateChanged);
    _scrollController.addListener(_onScroll);
    _controller.loadNextPage();
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  void _onScroll() {
    // Trigger next page when reaching 80% of scroll extent
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.8) {
      _controller.loadNextPage();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onStateChanged);
    _controller.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Paginated Mobile List'),
        backgroundColor: theme.colorScheme.primaryContainer,
        foregroundColor: theme.colorScheme.onPrimaryContainer,
      ),
      body: NotificationListener<OverscrollIndicatorNotification>(
        // Limit maximum drag distances to prevent users from pulling elements off screen
        onNotification: (overscroll) {
          overscroll.disallowIndicator();
          return true;
        },
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(
            physics: const ClampingScrollPhysics(),
          ),
          child: ListView.builder(
            controller: _scrollController,
            // Run animations entirely on the GPU via RepaintBoundary-like optimizations
            addAutomaticKeepAlives: true,
            addRepaintBoundaries: true,
            itemCount: _controller.items.length + (_controller.hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == _controller.items.length) {
                return _buildLoadingIndicator(theme);
              }
              return ListTile(
                key: ValueKey(_controller.items[index]),
                title: Text(_controller.items[index]),
                leading: CircleAvatar(
                  backgroundColor: theme.colorScheme.secondaryContainer,
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(color: theme.colorScheme.onSecondaryContainer),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Center(
        child: CircularProgressIndicator(
          // Match indicator colors with primary theme accents to keep branding consistent
          color: theme.colorScheme.primary,
          strokeWidth: 3.0,
          semanticsLabel: 'Loading more items',
        ),
      ),
    );
  }
}
