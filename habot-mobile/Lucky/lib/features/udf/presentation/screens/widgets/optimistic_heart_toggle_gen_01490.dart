// GEN-01490 — Optimistic Heart Toggle Widget.
// Configures optimistic local state updates that immediately toggle the heart visual state to filled within 50ms of a user tap, using M3 Elevated Cards and Status Chips.

import 'package:flutter/material.dart';

/// Mock data model representing an item with a saved/favorited state.
class HeartToggleItemGen01490 {
  final String id;
  final String title;
  bool isSaved;

  HeartToggleItemGen01490({
    required this.id,
    required this.title,
    this.isSaved = false,
  });
}

/// Mock repository simulating backend persistence for saved state.
class MockSavedStateRepositoryGen01490 {
  static final Map<String, bool> _store = {};

  Future<bool> toggleSavedState(String itemId, bool newState) async {
    // Simulate network latency (backend mock)
    await Future.delayed(const Duration(milliseconds: 300));
    _store[itemId] = newState;
    return true; // Return success for Pass/Fail metric
  }

  bool getReliabilityStatus() => true; // Floor threshold 0.98 mock
}

/// Controller managing the optimistic UI update logic.
class HeartToggleControllerGen01490 extends ChangeNotifier {
  final List<HeartToggleItemGen01490> items = [
    HeartToggleItemGen01490(id: 'item_1', title: 'UDF Configuration Step A', isSaved: false),
    HeartToggleItemGen01490(id: 'item_2', title: 'UDF Configuration Step B', isSaved: true),
    HeartToggleItemGen01490(id: 'item_3', title: 'UDF Configuration Step C', isSaved: false),
  ];

  final MockSavedStateRepositoryGen01490 _repository = MockSavedStateRepositoryGen01490();

  /// Toggles the heart state optimistically within <50ms locally,
  /// then attempts to persist to the mock backend.
  Future<void> toggleHeart(int index) async {
    if (index < 0 || index >= items.length) return;

    final item = items[index];
    final previousState = item.isSaved;
    final optimisticNewState = !previousState;

    // 1. Immediate optimistic local state update (< 50ms)
    item.isSaved = optimisticNewState;
    notifyListeners();

    // 2. Background persistence attempt
    try {
      final success = await _repository.toggleSavedState(item.id, optimisticNewState);
      if (!success) {
        // Rollback on failure
        item.isSaved = previousState;
        notifyListeners();
      }
    } catch (e) {
      // Rollback on exception
      item.isSaved = previousState;
      notifyListeners();
    }
  }
}

/// Main widget implementing the M3 responsive layout and optimistic heart toggle.
class OptimisticHeartToggleScreenGen01490 extends StatefulWidget {
  const OptimisticHeartToggleScreenGen01490({super.key});

  @override
  State<OptimisticHeartToggleScreenGen01490> createState() => _OptimisticHeartToggleScreenStateGen01490();
}

class _OptimisticHeartToggleScreenStateGen01490 extends State<OptimisticHeartToggleScreenGen01490> {
  final HeartToggleControllerGen01490 _controller = HeartToggleControllerGen01490();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GEN-01490: Optimistic Heart Toggle'),
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return LayoutBuilder(
            builder: (context, constraints) {
              // M3 responsive layout: single-column on mobile (<600dp), multi-column on desktop (>=840dp)
              final isMobile = constraints.maxWidth < 600;
              final crossAxisCount = isMobile ? 1 : (constraints.maxWidth >= 840 ? 3 : 2);

              return GridView.builder(
                padding: const EdgeInsets.all(16.0),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 16.0,
                  crossAxisSpacing: 16.0,
                  childAspectRatio: isMobile ? 3.0 : 2.5,
                ),
                itemCount: _controller.items.length,
                itemBuilder: (context, index) {
                  final item = _controller.items[index];
                  return _M3ElevatedCardGen01490(
                    item: item,
                    onToggle: () => _controller.toggleHeart(index),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

/// M3 Elevated Card Level 2 (3dp) containing the step completion state and heart toggle.
class _M3ElevatedCardGen01490 extends StatelessWidget {
  final HeartToggleItemGen01490 item;
  final VoidCallback onToggle;

  const _M3ElevatedCardGen01490({
    required this.item,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 3.0, // M3 Elevated Cards Level 2 (3dp)
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item.title,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8.0),
                  // M3 Status Chip for health/completion indicator
                  Chip(
                    label: Text(
                      item.isSaved ? 'Saved' : 'Unsaved',
                      style: TextStyle(
                        fontSize: 12.0,
                        color: item.isSaved ? colorScheme.onPrimaryContainer : colorScheme.onSurfaceVariant,
                      ),
                    ),
                    backgroundColor: item.isSaved
                        ? colorScheme.primaryContainer
                        : colorScheme.surfaceContainerHighest,
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16.0),
            // 48x48dp touch target for accessibility
            SizedBox(
              width: 48.0,
              height: 48.0,
              child: IconButton(
                onPressed: onToggle,
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 50), // Sub-50ms visual toggle
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return ScaleTransition(scale: animation, child: child);
                  },
                  child: Icon(
                    item.isSaved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    key: ValueKey<bool>(item.isSaved),
                    color: item.isSaved ? colorScheme.error : colorScheme.onSurfaceVariant,
                    size: 28.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}