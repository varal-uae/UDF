// SSELC-002-A09 — Visual Context Isolation Panel with Close Triggers.
// Implements a distraction-free, immersive fullscreen split-screen data entry overlay with tap-outside, close button, and swipe-to-dismiss gestures. Enforces strict PII isolation and mobile-first responsive layout.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Mock data representing the clipped document asset and atomic input fields.
/// In production, this would be populated dynamically from Pub/Sub exception pools via GCP/BigQuery alignment.
class _MockIsolationData {
  static const String executionId = 'EXEC-992834-SSELC-002-A09';
  static const String userId = 'WORKER-042';
  static const String documentSnippetAsset = 'assets/mock_clipped_document.png';
  static const String targetFieldLabel = 'Extracted Entity Value';
  static const String contextHint = 'Enter the exact value visible in the clipped region above.';
}

/// A stateless configuration widget that triggers the [VisualContextIsolationPanel].
/// Use this to launch the panel from any screen requiring isolated data entry.
class VisualContextIsolationTrigger extends StatelessWidget {
  const VisualContextIsolationTrigger({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FilledButton.icon(
        onPressed: () => _launchPanel(context),
        icon: const Icon(Icons.center_focus_strong),
        label: const Text('Open Isolation Panel'),
      ),
    );
  }

  Future<void> _launchPanel(BuildContext context) async {
    // Enable immersive fullscreen mode to hide system distractions
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    
    if (context.mounted) {
      await showDialog(
        context: context,
        barrierDismissible: true, // Tap outside to close trigger
        barrierColor: Colors.black.withOpacity(0.85), // High contrast separation
        builder: (BuildContext dialogContext) {
          return const VisualContextIsolationPanel();
        },
      );
    }
    
    // Restore system UI upon dismissal
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }
}

/// The core Visual Context Isolation Panel.
/// Enforces a 50/50 split-screen layout on desktop/tablet and vertical stacking on mobile.
/// Conceals all surrounding document details, displaying only the focused clipped snippet.
class VisualContextIsolationPanel extends StatefulWidget {
  const VisualContextIsolationPanel({super.key});

  @override
  State<VisualContextIsolationPanel> createState() => _VisualContextIsolationPanelState();
}

class _VisualContextIsolationPanelState extends State<VisualContextIsolationPanel> {
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _inputFocusNode = FocusNode();

  @override
  void dispose() {
    _inputController.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }

  void _closePanel() {
    Navigator.of(context).pop();
  }

  void _submitEntry() {
    // Implementation for atomic step execution tracking
    debugPrint('[SSELC-002-A09] Submission triggered for Execution ID: ${_MockIsolationData.executionId}');
    debugPrint('[SSELC-002-A09] Input Value: ${_inputController.text}');
    _closePanel();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    // Swipe gesture recognizer for dismissal
    return GestureDetector(
      onVerticalDragEnd: (DragEndDetails details) {
        // Swipe down to dismiss on mobile
        if (details.primaryVelocity != null && details.primaryVelocity! > 300) {
          _closePanel();
        }
      },
      child: Dialog(
        insetPadding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: theme.colorScheme.surface,
          child: SafeArea(
            child: isMobile ? _buildMobileLayout(theme) : _buildDesktopTabletLayout(theme),
          ),
        ),
      ),
    );
  }

  /// Vertical orientation auto-activating on mobile width devices.
  /// Stacked card orientation applied instantly on compact breakpoints.
  Widget _buildMobileLayout(ThemeData theme) {
    return Column(
      children: [
        _buildTopBar(theme),
        Expanded(
          flex: 1,
          child: _buildClippedAssetView(theme),
        ),
        const Divider(height: 1, thickness: 4, color: Colors.black), // High-density borders separating panels
        Expanded(
          flex: 1,
          child: _buildInputView(theme),
        ),
      ],
    );
  }

  /// Precise 50/50 balance splitting seamlessly on larger geometries.
  Widget _buildDesktopTabletLayout(ThemeData theme) {
    return Column(
      children: [
        _buildTopBar(theme),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 1,
                child: _buildClippedAssetView(theme),
              ),
              const VerticalDivider(width: 1, thickness: 4, color: Colors.black), // High-density borders
              Expanded(
                flex: 1,
                child: _buildInputView(theme),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      color: theme.colorScheme.surfaceContainerHighest,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Isolated Entry Task',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.15, // Typography token: letter-spacing
                  height: 1.5, // Typography token: line-height
                ),
              ),
              Text(
                'ID: ${_MockIsolationData.executionId}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  letterSpacing: 0.4,
                  height: 1.4,
                ),
              ),
            ],
          ),
          // Close button trigger
          IconButton(
            onPressed: _closePanel,
            icon: const Icon(Icons.close),
            tooltip: 'Close Panel',
            color: theme.colorScheme.error,
          ),
        ],
      ),
    );
  }

  /// Displays only the focused, clipped image snippet directly above/beside the input box.
  /// Physically conceals surrounding document details.
  Widget _buildClippedAssetView(ThemeData theme) {
    return Container(
      color: theme.colorScheme.surfaceDim,
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Card(
          elevation: 8.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
            side: BorderSide(color: theme.colorScheme.outlineVariant, width: 2),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.crop_free,
                  size: 64,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  '[ Clipped Document Snippet ]',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.15,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Strictly isolated view. No unassigned PII parameters are visible.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    letterSpacing: 0.25,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Distraction-free data entry area bounded inside a single scrollless viewport.
  Widget _buildInputView(ThemeData theme) {
    return Container(
      color: theme.colorScheme.surface,
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _MockIsolationData.targetFieldLabel,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.15,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _MockIsolationData.contextHint,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              letterSpacing: 0.25,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _inputController,
            focusNode: _inputFocusNode,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Type extracted value here...',
              hintStyle: TextStyle(
                letterSpacing: 0.25,
                height: 1.5,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(color: theme.colorScheme.outline, width: 2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(color: theme.colorScheme.outline, width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(color: theme.colorScheme.primary, width: 3),
              ),
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerLow,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            ),
            style: theme.textTheme.bodyLarge?.copyWith(
              letterSpacing: 0.5,
              height: 1.5,
            ),
            onSubmitted: (_) => _submitEntry(),
          ),
          const SizedBox(height: 32),
          FilledButton.tonalIcon(
            onPressed: _submitEntry,
            icon: const Icon(Icons.check_circle_outline),
            label: const Text(
              'Submit & Proceed',
              style: TextStyle(
                letterSpacing: 0.5,
                height: 1.2,
              ),
            ),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }
}
