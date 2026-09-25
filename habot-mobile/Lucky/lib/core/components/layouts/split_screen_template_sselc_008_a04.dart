// SSELC-008-A04 — Standard Mobile Split-Screen Template for MTO Interfaces.
// Provides a reusable layout with a fixed 40% upper reference pane and a 60% lower input pane, wrapped in a keyboard-avoiding view. Eliminates scrolling and applies Material 3 surface tokens.

import 'package:flutter/material.dart';

/// A reusable split-screen layout module optimized for single-task processing flows.
///
/// The upper pane occupies exactly 40% of the viewport height and is intended
/// for reference material (documents, context). The lower pane occupies the
/// remaining 60% and is intended for form inputs.
///
/// Scrolling is eliminated entirely to maintain absolute focus on the current task.
/// Swipe gestures are supported for horizontal progression between tasks.
class SplitScreenTemplate extends StatelessWidget {
  const SplitScreenTemplate({
    super.key,
    required this.referencePane,
    required this.inputPane,
    this.onSwipeNext,
    this.onSwipePrevious,
  });

  /// The widget displayed in the upper 40% reference area.
  final Widget referencePane;

  /// The widget displayed in the lower 60% input area.
  final Widget inputPane;

  /// Callback triggered when the user swipes left (next task).
  final VoidCallback? onSwipeNext;

  /// Callback triggered when the user swipes right (previous task).
  final VoidCallback? onSwipePrevious;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      // Lock container height to viewport by removing default padding/scrolling behaviors
      body: GestureDetector(
        // touch-action: pan-x equivalent in Flutter
        onHorizontalDragEnd: (DragEndDetails details) {
          if (details.primaryVelocity == null) return;
          if (details.primaryVelocity! < -100) {
            // Swiped left -> next
            onSwipeNext?.call();
          } else if (details.primaryVelocity! > 100) {
            // Swiped right -> previous
            onSwipePrevious?.call();
          }
        },
        child: SafeArea(
          child: _KeyboardAvoidingSplitView(
            referenceBackground: theme.colorScheme.surfaceVariant,
            inputBackground: theme.colorScheme.surface,
            referencePane: referencePane,
            inputPane: inputPane,
          ),
        ),
      ),
    );
  }
}

class _KeyboardAvoidingSplitView extends StatelessWidget {
  const _KeyboardAvoidingSplitView({
    required this.referenceBackground,
    required this.inputBackground,
    required this.referencePane,
    required this.inputPane,
  });

  final Color referenceBackground;
  final Color inputBackground;
  final Widget referencePane;
  final Widget inputPane;

  @override
  Widget build(BuildContext context) {
    // Wrap task views in standard keyboard-avoiding views to prevent input overlays from blocking input blocks.
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double totalHeight = constraints.maxHeight;
        final double totalWidth = constraints.maxWidth;

        // Fix the height of the reference window to exactly 40% of the screen space
        final double referenceHeight = totalHeight * 0.40;
        // Allocating the remaining space to form input fields
        final double inputHeight = totalHeight * 0.60;

        return SingleChildScrollView(
          // Eliminate scrolling entirely for absolute focus
          physics: const NeverScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: totalHeight,
              maxHeight: totalHeight,
              minWidth: totalWidth,
              maxWidth: totalWidth,
            ),
            child: Column(
              children: <Widget>[
                // Upper Reference Pane
                Container(
                  height: referenceHeight,
                  width: totalWidth,
                  color: referenceBackground,
                  // Apply distinct background tones to separate the reference viewer area
                  child: ClipRect(
                    // overflow: hidden equivalent
                    child: referencePane,
                  ),
                ),
                // Lower Input Pane
                Container(
                  height: inputHeight,
                  width: totalWidth,
                  color: inputBackground,
                  child: ClipRect(
                    child: inputPane,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Example usage demonstrating how the template hosts any combination of 
/// document viewer or form components.
class SplitScreenTemplateExample extends StatelessWidget {
  const SplitScreenTemplateExample({super.key});

  @override
  Widget build(BuildContext context) {
    return SplitScreenTemplate(
      onSwipeNext: () {
        // Handle progression to next task
      },
      onSwipePrevious: () {
        // Handle regression to previous task
      },
      referencePane: const Center(
        child: Text(
          'Reference Document Viewer Area',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
      inputPane: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextField(
              decoration: InputDecoration(
                labelText: 'Task Input Field',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {},
              child: const Text('Submit Task'),
            ),
          ],
        ),
      ),
    );
  }
}
