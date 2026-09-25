// SSELC-008-A09 — Standard Mobile Split-Screen Template for MTO Interfaces.
// Enforces a 40% upper reference pane and 60% lower input pane with keyboard avoidance, distinct background tones, locked viewport height, horizontal swipe gestures, and no scrolling.

import 'package:flutter/material.dart';

/// Reusable split-screen layout module optimized for single-task processing flows.
/// Upper pane occupies exactly 40% of the screen space. Lower pane occupies the remaining 60%.
/// Scrolling is eliminated entirely. Container height is locked to the viewport.
/// Active inputs are automatically moved into view when the mobile keyboard appears.
class SplitScreenTemplate extends StatefulWidget {
  final Widget referenceContent;
  final Widget inputContent;
  final VoidCallback? onSwipeNext;
  final VoidCallback? onSwipePrevious;

  const SplitScreenTemplate({
    super.key,
    required this.referenceContent,
    required this.inputContent,
    this.onSwipeNext,
    this.onSwipePrevious,
  });

  @override
  State<SplitScreenTemplate> createState() => _SplitScreenTemplateState();
}

class _SplitScreenTemplateState extends State<SplitScreenTemplate> {
  late final PageController _swipeController;

  @override
  void initState() {
    super.initState();
    _swipeController = PageController();
  }

  @override
  void dispose() {
    _swipeController.dispose();
    super.dispose();
  }

  void _handleHorizontalDragEnd(DragEndDetails details) {
    if (details.primaryVelocity == null) return;
    if (details.primaryVelocity! < -100) {
      widget.onSwipeNext?.call();
    } else if (details.primaryVelocity! > 100) {
      widget.onSwipePrevious?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    // Lock container height to viewport (100vh equivalent)
    return Scaffold(
      resizeToAvoidBottomInset: true, // Keyboard avoiding behavior
      body: SafeArea(
        child: SizedBox.expand(
          child: GestureDetector(
            // touch-action: pan-x equivalent via horizontal drag detection
            onHorizontalDragEnd: _handleHorizontalDragEnd,
            behavior: HitTestBehavior.translucent,
            child: Column(
              children: [
                // Upper Reference Pane: Exactly 40% of screen space
                Expanded(
                  flex: 40,
                  child: Container(
                    width: double.infinity,
                    // Apply tokenized surface color values (md.sys.color.surfaceVariant)
                    color: colorScheme.surfaceVariant,
                    // Eliminate scrolling entirely for absolute focus
                    child: OverflowBox(
                      maxHeight: double.infinity,
                      child: SingleChildScrollView(
                        physics: const NeverScrollableScrollPhysics(),
                        child: widget.referenceContent,
                      ),
                    ),
                  ),
                ),
                // Lower Input Pane: Remaining 60% of screen space
                Expanded(
                  flex: 60,
                  child: Container(
                    width: double.infinity,
                    // Distinct background tone to separate visually from reference viewer
                    color: colorScheme.surface,
                    // Wrap task views in standard keyboard-avoiding views
                    child: SingleChildScrollView(
                      physics: const NeverScrollableScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: MediaQuery.of(context).size.height * 0.6,
                        ),
                        child: IntrinsicHeight(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: widget.inputContent,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- Mock Data & Example Usage for Local Testing ---

class MockWorkspaceData {
  static const String workspaceName = 'MTO Task Workspace Alpha';
  static const String workspaceId = 'WS-8832-UDF';
  static const String workspaceStatus = 'Active';
  static const List<String> memberList = ['Worker_01', 'Worker_02', 'Supervisor_A'];
  static const Map<String, dynamic> workspaceConfiguration = {
    'splitRatio': 0.4,
    'allowScrolling': false,
    'themeMode': 'system',
  };
}

class SplitScreenTemplateExample extends StatelessWidget {
  const SplitScreenTemplateExample({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      home: SplitScreenTemplate(
        onSwipeNext: () {
          debugPrint('Swiped to next task');
        },
        onSwipePrevious: () {
          debugPrint('Swiped to previous task');
        },
        referenceContent: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reference Context',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text('Workspace: ${MockWorkspaceData.workspaceName}'),
              Text('ID: ${MockWorkspaceData.workspaceId}'),
              Text('Status: ${MockWorkspaceData.workspaceStatus}'),
              const SizedBox(height: 16),
              const Text(
                'Instructions: Review the document above and complete the form below. Swipe left or right to navigate between tasks.',
              ),
            ],
          ),
        ),
        inputContent: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Task Input Area',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Capture Text',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Notes / Exceptions',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
            ),
            const Spacer(),
            FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.check),
              label: const Text('Submit Task'),
            ),
          ],
        ),
      ),
    );
  }
}
