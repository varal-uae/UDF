// SSELC-009-A13 — Split-Screen MTO Contextual Mirror Container (Portrait Lock).
// Provides a fixed split interactive pane enforcing a "Look Top, Type Bottom" zero-scroll data loop with keyboard avoidance and Material 3 surfaces.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Layout configuration data model for the split-screen container.
class SplitScreenLayoutConfig {
  final String layoutType;
  final double topPaneFlex;
  final double bottomPaneFlex;
  final EdgeInsets spacingRules;
  final AlignmentGeometry alignmentSettings;
  final bool isValidationPassed;

  const SplitScreenLayoutConfig({
    required this.layoutType,
    required this.topPaneFlex,
    required this.bottomPaneFlex,
    required this.spacingRules,
    required this.alignmentSettings,
    required this.isValidationPassed,
  });
}

/// Mock data representing the atomic-level data fields required by SSELC-009-A13.
const SplitScreenLayoutConfig kMockSplitScreenConfig = SplitScreenLayoutConfig(
  layoutType: 'Fixed_Split_Zero_Scroll',
  topPaneFlex: 0.55,
  bottomPaneFlex: 0.45,
  spacingRules: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
  alignmentSettings: Alignment.topCenter,
  isValidationPassed: true,
);

/// A stateless widget that enforces portrait orientation and renders a fixed
/// split-screen layout. The top pane displays evidence/contextual data while
/// the bottom pane contains input cells. Scrolling is disabled to ensure
/// biological eye tracking remains within the predefined screen focus area.
class SplitScreenContainer extends StatefulWidget {
  final Widget topPaneContent;
  final Widget bottomPaneContent;
  final SplitScreenLayoutConfig config;
  final VoidCallback? onScrollAttemptEscalation;

  const SplitScreenContainer({
    super.key,
    required this.topPaneContent,
    required this.bottomPaneContent,
    this.config = kMockSplitScreenConfig,
    this.onScrollAttemptEscalation,
  });

  @override
  State<SplitScreenContainer> createState() => _SplitScreenContainerState();
}

class _SplitScreenContainerState extends State<SplitScreenContainer> {
  @override
  void initState() {
    super.initState();
    _lockToPortrait();
  }

  @override
  void dispose() {
    _unlockOrientation();
    super.dispose();
  }

  void _lockToPortrait() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  void _unlockOrientation() {
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
  }

  /// Poka-Yoke: Intercepts any vertical drag/scroll attempts outside the
  /// predefined focus areas and escalates immediately.
  void _handlePointerSignal(PointerSignalEvent event) {
    if (event is PointerScrollEvent && event.scrollDelta.dy != 0) {
      widget.onScrollAttemptEscalation?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Listener(
      onPointerSignal: _handlePointerSignal,
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        body: SafeArea(
          child: KeyboardAvoidingWrapper(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Pane: Evidence / Contextual Data Display
                Expanded(
                  flex: (widget.config.topPaneFlex * 100).round(),
                  child: Padding(
                    padding: widget.config.spacingRules,
                    child: Card(
                      elevation: 2.0,
                      surfaceTintColor: colorScheme.surfaceTint,
                      margin: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.0),
                        // Physics locked: No scrolling allowed in top pane
                        child: OverflowBox(
                          alignment: widget.config.alignmentSettings,
                          maxWidth: double.infinity,
                          maxHeight: double.infinity,
                          child: widget.topPaneContent,
                        ),
                      ),
                    ),
                  ),
                ),

                // Divider / Spacing
                const SizedBox(height: 4.0),

                // Bottom Pane: Input Cells / Action Area
                Expanded(
                  flex: (widget.config.bottomPaneFlex * 100).round(),
                  child: Padding(
                    padding: widget.config.spacingRules.copyWith(top: 0),
                    child: Card(
                      elevation: 4.0,
                      surfaceTintColor: colorScheme.surfaceTint,
                      margin: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        // Physics locked: No scrolling allowed in bottom pane
                        child: OverflowBox(
                          alignment: Alignment.topCenter,
                          maxWidth: double.infinity,
                          maxHeight: double.infinity,
                          child: widget.bottomPaneContent,
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

/// A wrapper widget that handles keyboard visibility to prevent layout bleed
/// while maintaining the fixed pane heights constraint.
class KeyboardAvoidingWrapper extends StatelessWidget {
  final Widget child;

  const KeyboardAvoidingWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // Using a combination of MediaQuery removePadding and a constrained 
    // column to ensure the UI adapts to keyboard without introducing scroll.
    return AnimatedPadding(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: child,
    );
  }
}

/// Example usage and mock implementation for UAT benchmark validation.
class MockMtoSplitScreen extends StatelessWidget {
  const MockMtoSplitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SplitScreenContainer(
      config: kMockSplitScreenConfig,
      onScrollAttemptEscalation: () {
        debugPrint('SSELC-009-A13 Poka-Yoke: Scroll attempt escalated.');
      },
      topPaneContent: const Center(
        child: Text(
          'Evidence Data View\n(Look Top)',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      bottomPaneContent: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Input Cells (Type Bottom)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          TextField(
            decoration: InputDecoration(
              labelText: 'Exception Code',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              filled: true,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () {
              debugPrint('SSELC-009-A13: Submit action triggered.');
            },
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}