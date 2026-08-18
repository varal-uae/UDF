// EDPS-002 — MD3 Event-Driven Real-Time Animated List.
// Manages real-time list insertion/removal animations using Flutter's AnimatedList.

import 'package:flutter/material.dart';

class RealtimeListItem {
  const RealtimeListItem({
    required this.id,
    required this.title,
    required this.timestamp,
  });

  final String id;
  final String title;
  final String timestamp;
}

class RealtimeAnimatedList extends StatefulWidget {
  const RealtimeAnimatedList({
    super.key,
    required this.items,
    required this.onRefresh,
    this.isRefreshing = false,
  });

  final List<RealtimeListItem> items;
  final RefreshCallback onRefresh;
  final bool isRefreshing;

  @override
  State<RealtimeAnimatedList> createState() => _RealtimeAnimatedListState();
}

class _RealtimeAnimatedListState extends State<RealtimeAnimatedList> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final List<RealtimeListItem> _displayedItems = [];

  @override
  void initState() {
    super.initState();
    _displayedItems.addAll(widget.items);
  }

  @override
  void didUpdateWidget(covariant RealtimeAnimatedList oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Detect inserted items
    for (int i = 0; i < widget.items.length; i++) {
      if (i >= _displayedItems.length || _displayedItems[i].id != widget.items[i].id) {
        _displayedItems.insert(i, widget.items[i]);
        _listKey.currentState?.insertItem(i, duration: const Duration(milliseconds: 300));
      }
    }
  }

  Widget _buildItem(BuildContext context, RealtimeListItem item, Animation<double> animation) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return SizeTransition(
      sizeFactor: animation,
      child: FadeTransition(
        opacity: animation,
        child: Card(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: cs.primaryContainer,
              child: Icon(Icons.bolt, color: cs.onPrimaryContainer, size: 20),
            ),
            title: Text(item.title, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
            subtitle: Text(item.timestamp, style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
            trailing: Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: Stack(
        children: [
          AnimatedList(
            key: _listKey,
            initialItemCount: _displayedItems.length,
            itemBuilder: (context, index, animation) {
              return _buildItem(context, _displayedItems[index], animation);
            },
          ),
          if (widget.isRefreshing)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(color: cs.primary),
            ),
        ],
      ),
    );
  }
}
