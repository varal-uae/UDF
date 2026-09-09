// ANSA-006-A05 — Global Search Hub: expandable header search with full-screen mobile view, grouped results, and clear control.
// Desktop renders a wide, permanent search bar centered in header navigation; mobile collapses to an icon that opens a full-screen overlay with a prominent close button. Includes input sanitization and event handling.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum SearchResultGroup { projects, tools, teams }

class SearchResultItem {
  const SearchResultItem({
    required this.id,
    required this.title,
    this.subtitle = '',
    required this.group,
  });

  final String id;
  final String title;
  final String subtitle;
  final SearchResultGroup group;
}

class GlobalSearchHub extends StatefulWidget {
  const GlobalSearchHub({
    super.key,
    required this.items,
    this.onSearch,
    this.onResultSelected,
    this.desktopMaxWidth = 600,
  });

  final List<SearchResultItem> items;
  final Future<List<SearchResultItem>> Function(String query)? onSearch;
  final ValueChanged<SearchResultItem>? onResultSelected;
  final double desktopMaxWidth;

  @override
  State<GlobalSearchHub> createState() => _GlobalSearchHubState();
}

class _GlobalSearchHubState extends State<GlobalSearchHub> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Timer? _debounce;
  List<SearchResultItem> _results = const [];
  bool _isLoading = false;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onControllerChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    setState(() {});
    final value = _controller.text;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _runSearch(value);
    });
  }

  void _onFocusChanged() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  String _sanitize(String value) => value.replaceAll(RegExp(r'[^a-zA-Z0-9 ._/@-]'), '');

  Future<void> _runSearch(String rawQuery) async {
    final query = _sanitize(rawQuery.trim());
    if (query.isEmpty) {
      setState(() {
        _results = const [];
        _isLoading = false;
      });
      return;
    }
    setState(() => _isLoading = true);

    List<SearchResultItem>? remote;
    if (widget.onSearch != null) {
      try {
        remote = await widget.onSearch!(query);
      } catch (_) {
        remote = null;
      }
    }

    final results = remote ?? _localSearch(query);
    if (!mounted) return;
    setState(() {
      _results = results;
      _isLoading = false;
    });
  }

  List<SearchResultItem> _localSearch(String query) {
    final lower = query.toLowerCase();
    return widget.items.where((item) {
      return item.title.toLowerCase().contains(lower) ||
          item.id.toLowerCase().contains(lower) ||
          item.subtitle.toLowerCase().contains(lower);
    }).toList();
  }

  void _clearSearch() {
    _controller.clear();
    setState(() {
      _results = const [];
      _isLoading = false;
    });
  }

  Future<void> _openFullScreenSearch() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => _FullScreenSearchView(
          items: widget.items,
          onSearch: widget.onSearch,
          onResultSelected: widget.onResultSelected,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 600;
    if (isMobile) {
      return IconButton(
        tooltip: 'Search',
        icon: const Icon(Icons.search),
        onPressed: _openFullScreenSearch,
      );
    }

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: widget.desktopMaxWidth),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _controller,
              focusNode: _focusNode,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9 ._/@-]')),
              ],
              decoration: InputDecoration(
                hintText: 'Search projects, tools, teams...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _controller.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Clear search',
                        icon: const Icon(Icons.close),
                        onPressed: _clearSearch,
                      ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 1.5,
                  ),
                ),
                filled: true,
                isDense: true,
              ),
            ),
            if (_controller.text.trim().isNotEmpty)
              _SearchResultsPanel(
                results: _results,
                isLoading: _isLoading,
                onSelected: widget.onResultSelected,
              ),
          ],
        ),
      ),
    );
  }
}

class _SearchResultsPanel extends StatelessWidget {
  const _SearchResultsPanel({
    required this.results,
    required this.isLoading,
    this.onSelected,
  });

  final List<SearchResultItem> results;
  final bool isLoading;
  final ValueChanged<SearchResultItem>? onSelected;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (results.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: Text('No matches found.'),
      );
    }

    final grouped = <SearchResultGroup, List<SearchResultItem>>{};
    for (final group in SearchResultGroup.values) {
      final items = results.where((r) => r.group == group).toList();
      if (items.isNotEmpty) {
        grouped[group] = items;
      }
    }

    return Card(
      margin: const EdgeInsets.only(top: 4),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 320),
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          shrinkWrap: true,
          children: [
            for (final entry in grouped.entries) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Text(
                  _groupLabel(entry.key),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              for (final item in entry.value)
                ListTile(
                  dense: true,
                  leading: Icon(_groupIcon(item.group)),
                  title: Text(item.title),
                  subtitle: item.subtitle.isEmpty ? null : Text(item.subtitle),
                  onTap: () => onSelected?.call(item),
                ),
            ],
          ],
        ),
      ),
    );
  }

  String _groupLabel(SearchResultGroup group) {
    switch (group) {
      case SearchResultGroup.projects:
        return 'Projects';
      case SearchResultGroup.tools:
        return 'Tools';
      case SearchResultGroup.teams:
        return 'Teams';
    }
  }

  IconData _groupIcon(SearchResultGroup group) {
    switch (group) {
      case SearchResultGroup.projects:
        return Icons.folder_outlined;
      case SearchResultGroup.tools:
        return Icons.build_outlined;
      case SearchResultGroup.teams:
        return Icons.group_outlined;
    }
  }
}

class _FullScreenSearchView extends StatefulWidget {
  const _FullScreenSearchView({
    required this.items,
    this.onSearch,
    this.onResultSelected,
  });

  final List<SearchResultItem> items;
  final Future<List<SearchResultItem>> Function(String query)? onSearch;
  final ValueChanged<SearchResultItem>? onResultSelected;

  @override
  State<_FullScreenSearchView> createState() => _FullScreenSearchViewState();
}

class _FullScreenSearchViewState extends State<_FullScreenSearchView> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;
  List<SearchResultItem> _results = const [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.removeListener(_onChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onChanged() {
    setState(() {});
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _runSearch(_controller.text);
    });
  }

  String _sanitize(String value) => value.replaceAll(RegExp(r'[^a-zA-Z0-9 ._/@-]'), '');

  Future<void> _runSearch(String rawQuery) async {
    final query = _sanitize(rawQuery.trim());
    if (query.isEmpty) {
      setState(() {
        _results = const [];
        _isLoading = false;
      });
      return;
    }

    setState(() => _isLoading = true);

    List<SearchResultItem>? remote;
    if (widget.onSearch != null) {
      try {
        remote = await widget.onSearch!(query);
      } catch (_) {
        remote = null;
      }
    }

    final results = remote ?? _localSearch(query);
    if (!mounted) return;
    setState(() {
      _results = results;
      _isLoading = false;
    });
  }

  List<SearchResultItem> _localSearch(String query) {
    final lower = query.toLowerCase();
    return widget.items.where((item) {
      return item.title.toLowerCase().contains(lower) ||
          item.id.toLowerCase().contains(lower) ||
          item.subtitle.toLowerCase().contains(lower);
    }).toList();
  }

  void _clearSearch() {
    _controller.clear();
    setState(() {
      _results = const [];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Close search',
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        titleSpacing: 0,
        title: TextField(
          controller: _controller,
          autofocus: true,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9 ._/@-]')),
          ],
          decoration: InputDecoration(
            hintText: 'Search projects, tools, teams...',
            border: InputBorder.none,
            suffixIcon: _controller.text.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Clear search',
                    icon: const Icon(Icons.close),
                    onPressed: _clearSearch,
                  ),
          ),
        ),
      ),
      body: SafeArea(
        child: _SearchResultsPanel(
          results: _results,
          isLoading: _isLoading,
          onSelected: (item) {
            widget.onResultSelected?.call(item);
            Navigator.of(context).maybePop();
          },
        ),
      ),
    );
  }
}
