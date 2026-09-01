/// PROCESS EXECUTION METADATA BLOCK
/// - Step Execution ID: MCIIM-010-12-ISOLATE-2026
/// - Execution Status: Executed
/// - Execution Timestamp: 2026-08-18T10:10:00Z
/// - Step Outcome: Document Snippet Frozen and Isolated
/// - User ID: DOC-PROC-4410
/// - Completion Status: Target: Complete - ISO 9001 Process Approach
library;

import 'package:flutter/material.dart';

/// MCIIM-010-12: Smart Bounding-Box Document Isolator
///
/// Implements a gesture-blocked document snippet view for pure cognitive focus,
/// alongside an accessible text input field with strict touch target padding.
class SmartBoundingBoxDocumentIsolator extends StatefulWidget {
  const SmartBoundingBoxDocumentIsolator({super.key});

  @override
  State<SmartBoundingBoxDocumentIsolator> createState() =>
      _SmartBoundingBoxDocumentIsolatorState();
}

class _SmartBoundingBoxDocumentIsolatorState
    extends State<SmartBoundingBoxDocumentIsolator> {
  final TextEditingController _extractedTextController = TextEditingController(
    text: 'EXTRACTED TAX ID: TX-99201-884A',
  );

  @override
  void dispose() {
    _extractedTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Document Isolator'),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header description block
              Card(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(Icons.crop_free, color: colorScheme.primary, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Frozen Document Snippet (Gesture Blocker Active). Panning & Pinch-to-zoom disabled for compliance focus.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Responsive layout area
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = constraints.maxWidth <= 600;

                    final imageWidget = _buildFrozenImageContainer(colorScheme);
                    final formWidget = _buildPaddedInputField(colorScheme);

                    if (isMobile) {
                      // Mobile View: Column stacking frozen image on top of padded text field
                      return SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            imageWidget,
                            const SizedBox(height: 16),
                            formWidget,
                          ],
                        ),
                      );
                    } else {
                      // Tablet/Web View: Row placing image in Expanded on left, text input on right
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 1,
                            child: SingleChildScrollView(child: imageWidget),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 1,
                            child: SingleChildScrollView(child: formWidget),
                          ),
                        ],
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Widget requirement 1: Frozen Image Snippet with AbsorbPointer gesture blocking
  Widget _buildFrozenImageContainer(ColorScheme colorScheme) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: colorScheme.primaryContainer,
            child: Row(
              children: [
                Icon(Icons.lock_outline, size: 16, color: colorScheme.onPrimaryContainer),
                const SizedBox(width: 6),
                Text(
                  'FROZEN SNIPPET (TOUCH-ACTION: NONE)',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
          // Wrap the image container in AbsorbPointer to physically disable touch gestures
          AbsorbPointer(
            absorbing: true, // Physical gesture blocker (pinch, zoom, scroll, pan disabled)
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                color: colorScheme.surfaceContainerHighest,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Mock Document Snippet Image
                    Image.network(
                      'https://picsum.photos/800/450',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: colorScheme.surfaceContainerHighest,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.document_scanner, size: 48, color: colorScheme.outline),
                                const SizedBox(height: 8),
                                const Text(
                                  '[ Cropped Document Bounding Box ]',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    // Visual Bounding Box Overlay
                    Center(
                      child: Container(
                        margin: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: colorScheme.tertiary,
                            width: 3,
                          ),
                          color: colorScheme.tertiary.withValues(alpha: 0.15),
                        ),
                        child: Align(
                          alignment: Alignment.topRight,
                          child: Container(
                            color: colorScheme.tertiary,
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            child: Text(
                              'ROI #1',
                              style: TextStyle(
                                color: colorScheme.onTertiary,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
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
        ],
      ),
    );
  }

  /// Widget requirement 2: Strict Touch Element Padding around TextFormField
  Widget _buildPaddedInputField(ColorScheme colorScheme) {
    return Card(
      elevation: 2,
      child: Padding(
        // MUST wrap input in Padding with at least EdgeInsets.all(24.0)
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Document OCR Verification',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please verify or correct the text snippet extracted from the frozen bounding box above.',
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            // Input field enforcing minHeight: 48.0 via BoxConstraints and contentPadding
            ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48.0),
              child: TextFormField(
                controller: _extractedTextController,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                decoration: InputDecoration(
                  labelText: 'Verified Text Field',
                  hintText: 'Enter text...',
                  prefixIcon: const Icon(Icons.edit_note),
                  // Enforce minimum touch target height inside the decoration
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: colorScheme.primary, width: 2),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48.0, // Strict touch accessibility target
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Document Snippet Data Verified & Saved!'),
                    ),
                  );
                },
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('CONFIRM OCR SNIPPET'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
