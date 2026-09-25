// SCTSS-011-A09 — MTO Viewport Crop Viewer with Bounding Box Padding.
// Implements a restricted image viewer that applies dynamic padding bounds, disables pan/zoom interactions, and shows a warning on drag attempts.

import 'package:flutter/material.dart';

/// Configuration model for viewport crop padding.
class MtoViewportPaddingConfig {
  final String configurationParameter;
  final double currentSettingPercent;
  final double previousSettingPercent;
  final DateTime configurationTimestamp;
  final List<String> changeLog;

  const MtoViewportPaddingConfig({
    required this.configurationParameter,
    required this.currentSettingPercent,
    required this.previousSettingPercent,
    required this.configurationTimestamp,
    required this.changeLog,
  });
}

/// Mock data provider for local testing without backend dependencies.
class MtoMockDataProvider {
  static const MtoViewportPaddingConfig defaultConfig = MtoViewportPaddingConfig(
    configurationParameter: 'MTO_VIEWPORT_CROP_PADDING',
    currentSettingPercent: 0.05, // 5% padding
    previousSettingPercent: 0.02,
    configurationTimestamp: null,
    changeLog: ['Initial setup', 'Adjusted to 5% for PII safety'],
  );

  static const List<Map<String, dynamic>> mockExceptionPayloads = [
    {'id': 'EXC-001', 'status': 'pending', 'documentType': 'invoice'},
    {'id': 'EXC-002', 'status': 'review', 'documentType': 'receipt'},
  ];
}

/// Restricted image viewer component for MTO workers.
/// Applies bounding box padding and disables pan/zoom/view-full interactions.
class MtoViewportCropViewer extends StatefulWidget {
  final ImageProvider imageProvider;
  final MtoViewportPaddingConfig config;
  final double aspectRatio;

  const MtoViewportCropViewer({
    super.key,
    required this.imageProvider,
    this.config = MtoMockDataProvider.defaultConfig,
    this.aspectRatio = 4 / 3,
  });

  @override
  State<MtoViewportCropViewer> createState() => _MtoViewportCropViewerState();
}

class _MtoViewportCropViewerState extends State<MtoViewportCropViewer> {
  bool _isShowingWarning = false;

  void _handleRestrictedInteraction(PointerEvent event) {
    if (!_isShowingWarning) {
      setState(() => _isShowingWarning = true);
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          setState(() => _isShowingWarning = false);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final paddingFraction = widget.config.currentSettingPercent;

    return Listener(
      onPointerDown: _handleRestrictedInteraction,
      onPointerMove: _handleRestrictedInteraction,
      child: GestureDetector(
        // Disable all gestures explicitly
        onScaleStart: (_) => _handleRestrictedInteraction(_),
        onScaleUpdate: (_) => _handleRestrictedInteraction(_),
        onDoubleTap: () => _handleRestrictedInteraction(null as PointerEvent),
        onLongPress: () {},
        child: Stack(
          alignment: Alignment.center,
          children: [
            AspectRatio(
              aspectRatio: widget.aspectRatio,
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant,
                    width: 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: EdgeInsets.all(
                      MediaQuery.of(context).size.width * paddingFraction,
                    ),
                    child: Image(
                      image: widget.imageProvider,
                      fit: BoxFit.contain,
                      // Prevent any internal scrolling or interaction
                      excludeFromSemantics: false,
                    ),
                  ),
                ),
              ),
            ),
            // Status pill badge (High-contrast)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.colorScheme.primary, width: 1),
                ),
                child: Text(
                  'MTO CROP',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            // Restricted View Warning Overlay
            if (_isShowingWarning)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.pan_tool_alt_outlined,
                        color: theme.colorScheme.error,
                        size: 48,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Restricted View',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Pan, zoom, and full view are disabled.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Example usage screen demonstrating the component within an organism layout.
class MtoExecutionScreen extends StatelessWidget {
  const MtoExecutionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('MTO Execution'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Document Extraction Task',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Review the cropped document below. Interactions are restricted to protect PII.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            // Using a placeholder network image for demonstration
            MtoViewportCropViewer(
              imageProvider: const NetworkImage(
                'https://via.placeholder.com/800x600.png?text=MTO+Document+Crop',
              ),
              config: MtoMockDataProvider.defaultConfig,
            ),
            const SizedBox(height: 24),
            // Exception Queue Indicator
            Card(
              child: ListTile(
                leading: Icon(
                  Icons.warning_amber_rounded,
                  color: theme.colorScheme.tertiary,
                ),
                title: const Text('Pub/Sub Exception Queue'),
                subtitle: Text(
                  '${MtoMockDataProvider.mockExceptionPayloads.length} items pending triage',
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${MtoMockDataProvider.mockExceptionPayloads.length}',
                    style: TextStyle(
                      color: theme.colorScheme.onErrorContainer,
                      fontWeight: FontWeight.bold,
                    ),
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
