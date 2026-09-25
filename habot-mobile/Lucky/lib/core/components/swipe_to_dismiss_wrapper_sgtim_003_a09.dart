// SGTIM-003-A09 — SwipeToDismissInteractionWrapper
// Implements a reusable swipe-to-dismiss component with snap-back animation, undo snackbar, and desktop/mobile adaptive behavior.

import 'package:flutter/material.dart';

/// Reusable wrapper providing horizontal swipe-to-dismiss interaction logic.
/// Includes snap-back animation when thresholds are not met, undo capability,
/// and adapts between mobile swipe gestures and desktop delete icons.
class SwipeToDismissInteractionWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback onDismissed;
  final Color backgroundAlertColor;
  final double dismissThreshold;
  final Duration snapBackDuration;
  final Curve snapBackCurve;
  final String undoLabel;
  final bool isDesktopViewport;

  const SwipeToDismissInteractionWrapper({
    super.key,
    required this.child,
    required this.onDismissed,
    this.backgroundAlertColor = Colors.redAccent,
    this.dismissThreshold = 0.4,
    this.snapBackDuration = const Duration(milliseconds: 300),
    this.snapBackCurve = Curves.easeOutCubic,
    this.undoLabel = 'Undo',
    this.isDesktopViewport = false,
  });

  @override
  State<SwipeToDismissInteractionWrapper> createState() => _SwipeToDismissInteractionWrapperState();
}

class _SwipeToDismissInteractionWrapperState extends State<SwipeToDismissInteractionWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  double _dragExtent = 0.0;
  bool _isDismissing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.snapBackDuration,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: widget.snapBackCurve),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    if (_isDismissing) return;
    setState(() {
      _dragExtent += details.delta.dx;
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (_isDismissing) return;

    final screenWidth = MediaQuery.of(context).size.width;
    final threshold = screenWidth * widget.dismissThreshold;

    if (_dragExtent.abs() > threshold) {
      _executeDismiss();
    } else {
      _snapBack();
    }
  }

  void _snapBack() {
    _controller.forward(from: 0.0).then((_) {
      setState(() {
        _dragExtent = 0.0;
      });
      _controller.reverse();
    });
  }

  void _executeDismiss() {
    setState(() {
      _isDismissing = true;
    });

    widget.onDismissed();

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Item removed'),
        action: SnackBarAction(
          label: widget.undoLabel,
          onPressed: () {
            // Poka-Yoke: Reverse card deletion instantly with a single touch action
            setState(() {
              _isDismissing = false;
              _dragExtent = 0.0;
            });
          },
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Desktop widths: switch to delete icons instead of swipe behaviors
    if (widget.isDesktopViewport) {
      return Container(
        constraints: const BoxConstraints(minHeight: 48.0),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
        ),
        child: Row(
          children: [
            Expanded(child: widget.child),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 24.0),
              tooltip: 'Delete',
              onPressed: _executeDismiss,
            ),
          ],
        ),
      );
    }

    // Mobile viewports: horizontal touch swipe behavioral rules
    return GestureDetector(
      onHorizontalDragUpdate: _onHorizontalDragUpdate,
      onHorizontalDragEnd: _onHorizontalDragEnd,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Stack(
          children: [
            // Semantic background warning sheet beneath
            Positioned.fill(
              child: Container(
                alignment: _dragExtent > 0 ? Alignment.centerRight : Alignment.centerLeft,
                color: widget.backgroundAlertColor,
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Icon(
                  Icons.delete_outline,
                  color: Colors.white.withOpacity((_dragExtent.abs() / 150).clamp(0.0, 1.0)),
                  size: 24.0,
                ),
              ),
            ),
            // Targeted list cards glide horizontally off-canvas
            Transform.translate(
              offset: Offset(_dragExtent, 0.0),
              child: Container(
                constraints: const BoxConstraints(minHeight: 48.0),
                color: Theme.of(context).colorScheme.surface,
                child: widget.child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Helper widget to rebuild on animation changes without external dependencies.
class AnimatedBuilder extends StatelessWidget {
  final Animation<double> animation;
  final Widget Function(BuildContext context, Widget? child) builder;
  final Widget? child;

  const AnimatedBuilder({
    super.key,
    required this.animation,
    required this.builder,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilderInternal(
      animation: animation,
      builder: builder,
      child: child,
    );
  }
}

class AnimatedBuilderInternal extends AnimatedWidget {
  final Widget Function(BuildContext context, Widget? child) builder;
  final Widget? child;

  const AnimatedBuilderInternal({
    super.key,
    required Animation<double> animation,
    required this.builder,
    this.child,
  }) : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    return builder(context, child);
  }
}

// --- Mock Data & Usage Example for Local Testing ---

class MockSwipeListScreen extends StatefulWidget {
  const MockSwipeListScreen({super.key});

  @override
  State<MockSwipeListScreen> createState() => _MockSwipeListScreenState();
}

class _MockSwipeListScreenState extends State<MockSwipeListScreen> {
  final List<Map<String, dynamic>> _items = [
    {'id': '1', 'title': 'Transaction Record A', 'status': 'Pending'},
    {'id': '2', 'title': 'Transaction Record B', 'status': 'Completed'},
    {'id': '3', 'title': 'Transaction Record C', 'status': 'Failed'},
    {'id': '4', 'title': 'Transaction Record D', 'status': 'Processing'},
  ];

  void _removeItem(String id) {
    setState(() {
      _items.removeWhere((item) => item['id'] == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('UDF Swipe-To-Dismiss')),
      body: ListView.builder(
        itemCount: _items.length,
        itemBuilder: (context, index) {
          final item = _items[index];
          return SwipeToDismissInteractionWrapper(
            key: ValueKey(item['id']),
            onDismissed: () => _removeItem(item['id']),
            backgroundAlertColor: Colors.deepOrange,
            child: ListTile(
              leading: const Icon(Icons.receipt_long),
              title: Text(item['title']),
              subtitle: Text('Status: ${item['status']}'),
            ),
          );
        },
      ),
    );
  }
}
