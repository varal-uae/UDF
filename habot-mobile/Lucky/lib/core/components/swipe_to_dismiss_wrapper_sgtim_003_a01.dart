// SGTIM-003-A01 — SwipeToDismissInteractionWrapper for mobile-first list item dismissal.
// Provides a reusable Dismissible wrapper with haptic feedback, undo snackbar, animated list reflow, and desktop fallback to icon-based deletion.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Mock data model representing a dismissible list item.
class SwipeDismissibleItem {
  final String id;
  final String title;
  final String subtitle;

  const SwipeDismissibleItem({
    required this.id,
    required this.title,
    required this.subtitle,
  });
}

/// Reusable wrapper that applies swipe-to-dismiss behavior on mobile viewports
/// and falls back to a delete icon button on desktop widths.
class SwipeToDismissInteractionWrapper extends StatelessWidget {
  final Widget child;
  final String itemId;
  final VoidCallback onDismissed;
  final Color backgroundWarningColor;
  final Icon backgroundIcon;
  final bool enableHaptics;

  const SwipeToDismissInteractionWrapper({
    super.key,
    required this.child,
    required this.itemId,
    required this.onDismissed,
    this.backgroundWarningColor = Colors.redAccent,
    this.backgroundIcon = const Icon(Icons.delete_outline, color: Colors.white),
    this.enableHaptics = true,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    const double desktopBreakpoint = 600.0;

    if (screenWidth >= desktopBreakpoint) {
      return _buildDesktopFallback(context);
    }

    return _buildMobileSwipeable(context);
  }

  Widget _buildMobileSwipeable(BuildContext context) {
    return Dismissible(
      key: ValueKey<String>(itemId),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        if (enableHaptics) {
          HapticFeedback.mediumImpact();
        }
        onDismissed();
        _showUndoSnackBar(context);
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24.0),
        color: backgroundWarningColor,
        child: backgroundIcon,
      ),
      movementDuration: const Duration(milliseconds: 300),
      resizeDuration: const Duration(milliseconds: 300),
      child: child,
    );
  }

  Widget _buildDesktopFallback(BuildContext context) {
    return Row(
      children: [
        Expanded(child: child),
        IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
          tooltip: 'Delete Item',
          onPressed: () {
            onDismissed();
            _showUndoSnackBar(context);
          },
        ),
      ],
    );
  }

  void _showUndoSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Item removed.'),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'UNDO',
          textColor: Colors.white,
          onPressed: () {
            // In production, dispatch restore event via Pub/Sub or local state manager.
            if (enableHaptics) {
              HapticFeedback.lightImpact();
            }
          },
        ),
      ),
    );
  }
}

/// Animated list controller managing mock items with smooth upward reflow.
class SwipeDismissibleListController extends StatefulWidget {
  const SwipeDismissibleListController({super.key});

  @override
  State<SwipeDismissibleListController> createState() => _SwipeDismissibleListControllerState();
}

class _SwipeDismissibleListControllerState extends State<SwipeDismissibleListController> {
  late List<SwipeDismissibleItem> _items;
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  @override
  void initState() {
    super.initState();
    _items = List.generate(
      15,
      (index) => SwipeDismissibleItem(
        id: 'item_$index',
        title: 'Record ${index + 1}',
        subtitle: 'Administrative data entry row',
      ),
    );
  }

  void _removeItem(int index) {
    final removedItem = _items[index];
    _items.removeAt(index);
    _listKey.currentState?.removeItem(
      index,
      (context, animation) => _buildAnimatedItem(removedItem, animation, index),
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Swipe-To-Dismiss Framework'),
        centerTitle: true,
      ),
      body: AnimatedList(
        key: _listKey,
        initialItemCount: _items.length,
        itemBuilder: (context, index, animation) {
          final item = _items[index];
          return _buildAnimatedItem(item, animation, index);
        },
      ),
    );
  }

  Widget _buildAnimatedItem(SwipeDismissibleItem item, Animation<double> animation, int index) {
    return SizeTransition(
      sizeFactor: animation.drive(CurveTween(curve: Curves.easeInOut)),
      child: FadeTransition(
        opacity: animation,
        child: SwipeToDismissInteractionWrapper(
          itemId: item.id,
          onDismissed: () => _removeItem(index),
          child: Card(
            elevation: 1.0,
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ListTile(
              title: Text(item.title, style: Theme.of(context).textTheme.titleMedium),
              subtitle: Text(item.subtitle, style: Theme.of(context).textTheme.bodySmall),
              leading: const CircleAvatar(child: Icon(Icons.list_alt)),
            ),
          ),
        ),
      ),
    );
  }
}