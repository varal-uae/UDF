// SGTIM-003-A13 — SwipeToDismissInteractionWrapper with Haptic Feedback & Undo.
// Implements horizontal swipe-to-dismiss logic, medium haptic feedback on confirmation, transient undo warning bar, and adaptive layout switching for mobile vs desktop viewports.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Mock data model representing a list item managed by the swipe-to-dismiss wrapper.
class SwipeableRecord {
  final String stepExecutionId;
  final String title;
  final String status;
  final DateTime timestamp;
  final String userId;

  const SwipeableRecord({
    required this.stepExecutionId,
    required this.title,
    required this.status,
    required this.timestamp,
    required this.userId,
  });
}

/// Hardcoded mock repository to supply local data without backend dependency.
class MockSwipeableRepository {
  static List<SwipeableRecord> getInitialRecords() {
    return [
      const SwipeableRecord(
        stepExecutionId: 'EXEC-001',
        title: 'Initialize UDF Schema',
        status: 'Pending',
        timestamp: null,
        userId: 'USR-992',
      ),
      const SwipeableRecord(
        stepExecutionId: 'EXEC-002',
        title: 'Validate Input Masks',
        status: 'In Progress',
        timestamp: null,
        userId: 'USR-104',
      ),
      const SwipeableRecord(
        stepExecutionId: 'EXEC-003',
        title: 'Dispatch Pub/Sub Event',
        status: 'Complete',
        timestamp: null,
        userId: 'USR-088',
      ),
    ];
  }
}

/// A reusable wrapper component that provides swipe-to-dismiss functionality
/// optimized for mobile touch gestures, falling back to delete icons on desktop widths.
/// Includes Poka-Yoke mistake-proofing via an explicit transient undo snackbar.
class SwipeToDismissInteractionWrapper extends StatefulWidget {
  final List<SwipeableRecord> initialItems;
  final double mobileBreakpoint;

  const SwipeToDismissInteractionWrapper({
    super.key,
    required this.initialItems,
    this.mobileBreakpoint = 600.0,
  });

  @override
  State<SwipeToDismissInteractionWrapper> createState() =>
      _SwipeToDismissInteractionWrapperState();
}

class _SwipeToDismissInteractionWrapperState
    extends State<SwipeToDismissInteractionWrapper> {
  late List<SwipeableRecord> _items;

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.initialItems);
  }

  bool _isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < widget.mobileBreakpoint;
  }

  void _handleDismiss(int index, BuildContext context) {
    final removedItem = _items[index];

    // AISS: Implement haptic feedback on dismiss confirmation — medium haptic pattern.
    HapticFeedback.mediumImpact();

    setState(() {
      _items.removeAt(index);
    });

    // Poka-Yoke: Surfaces an explicit transient warning bar letting users reverse
    // card deletions instantly with a single touch action.
    if (context.mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${removedItem.title} removed'),
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'UNDO',
            textColor: Theme.of(context).colorScheme.onErrorContainer,
            onPressed: () {
              setState(() {
                _items.insert(index, removedItem);
              });
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobileViewport = _isMobile(context);

    return ListView.builder(
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final item = _items[index];

        // Core components animate their scale properties fluidly to maintain visual balance across rows.
        // Maintain clear 48px heights across menu options to ensure high click accuracy.
        final Widget rowContent = AnimatedScale(
          scale: 1.0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          child: Container(
            constraints: const BoxConstraints(minHeight: 48.0),
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            color: Theme.of(context).colorScheme.surface,
            child: Row(
              children: [
                // Use crisp icons alongside menu text to clarify choices instantly.
                Icon(
                  Icons.task_alt_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.title,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        'ID: ${item.stepExecutionId} • Status: ${item.status}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                // Switch to delete icons on desktop widths.
                if (!isMobileViewport)
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded),
                    color: Theme.of(context).colorScheme.error,
                    tooltip: 'Delete Item',
                    onPressed: () => _handleDismiss(index, context),
                  ),
              ],
            ),
          ),
        );

        // Limit swipe behaviors to mobile viewports exclusively.
        if (isMobileViewport) {
          // Targeted list cards glide horizontally off-canvas, exposing semantic
          // background warning sheets beneath. Match hidden underlay color containers
          // directly to high-visibility alert token codes.
          return Dismissible(
            key: ValueKey(item.stepExecutionId),
            direction: DismissDirection.endToStart,
            onDismissed: (_) => _handleDismiss(index, context),
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 24.0),
              color: Theme.of(context).colorScheme.errorContainer,
              child: Icon(
                Icons.warning_amber_rounded,
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
            ),
            child: rowContent,
          );
        }

        return rowContent;
      },
    );
  }
}

/// Example usage / Preview Screen for testing the SwipeToDismissInteractionWrapper.
class SwipeToDismissPreviewScreen extends StatelessWidget {
  const SwipeToDismissPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SGTIM-003-A13 Swipe Dismiss'),
      ),
      body: SwipeToDismissInteractionWrapper(
        initialItems: MockSwipeableRepository.getInitialRecords(),
      ),
    );
  }
}
