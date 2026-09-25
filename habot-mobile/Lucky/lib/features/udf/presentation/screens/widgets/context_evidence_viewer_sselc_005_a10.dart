// SSELC-005-A10 — ContextEvidenceViewer SVG Bounding Box Cropping Layer.
// Implements a reusable vector visual isolating container that crops peripheral areas outside a bounding box geometry, supports multi-touch gestures, and enforces mobile-first Material 3 layout constraints.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Mock data representing server-side pre-cropped bounding box coordinates.
class _MockBoundingBoxData {
  static const double x = 120.0;
  static const double y = 80.0;
  static const double width = 360.0;
  static const double height = 140.0;
  static const String svgAssetPath = 'assets/mock_document.svg';
}

/// Reusable component for isolating and displaying specific evidence context
/// within an SVG or image document using coordinate geometry mapping.
class ContextEvidenceViewer extends StatefulWidget {
  final String stepExecutionId;
  final String userId;
  final Rect? boundingBox;
  final VoidCallback? onValidationComplete;

  const ContextEvidenceViewer({
    super.key,
    required this.stepExecutionId,
    required this.userId,
    this.boundingBox,
    this.onValidationComplete,
  });

  @override
  State<ContextEvidenceViewer> createState() => _ContextEvidenceViewerState();
}

class _ContextEvidenceViewerState extends State<ContextEvidenceViewer> {
  final TransformationController _transformationController = TransformationController();
  String _executionStatus = 'Pending';
  DateTime? _executionTimestamp;

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _resetGestures() {
    _transformationController.value = Matrix4.identity();
  }

  void _handleDoubleTap() {
    _resetGestures();
  }

  void _submitValidation(String value) {
    setState(() {
      _executionStatus = 'Complete';
      _executionTimestamp = DateTime.now();
    });

    // Log telemetry mock data
    debugPrint('Step Execution ID: ${widget.stepExecutionId}');
    debugPrint('User ID: ${widget.userId}');
    debugPrint('Execution Status: $_executionStatus');
    debugPrint('Execution Timestamp: $_executionTimestamp');
    debugPrint('Step Outcome: $value');

    widget.onValidationComplete?.call();
  }

  @override
  Widget build(BuildContext context) {
    final Rect effectiveBox = widget.boundingBox ??
        Rect.fromLTWH(
          _MockBoundingBoxData.x,
          _MockBoundingBoxData.y,
          _MockBoundingBoxData.width,
          _MockBoundingBoxData.height,
        );

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Stripped extraneous navigation, focused header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              color: Theme.of(context).colorScheme.surface,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Evidence Verification',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],n              ),
            ),
            // Thin, high-contrast divider element
            const Divider(height: 1, thickness: 1, color: Colors.white24),
            
            // Expanded isolated scroll/gesture area
            Expanded(
              child: Center(
                child: Padding(
                  // Clear element margins to prevent touch controls from running into screen edges
                  padding: const EdgeInsets.all(16.0),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return GestureDetector(
                        onDoubleTap: _handleDoubleTap,
                        child: InteractiveViewer(
                          transformationController: _transformationController,
                          panEnabled: true,
                          scaleEnabled: true,
                          minScale: 1.0,
                          maxScale: 5.0,
                          boundaryMargin: EdgeInsets.zero,
                          clipBehavior: Clip.hardEdge,
                          child: _buildCroppedView(effectiveBox, constraints),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            // Bold contrast styling to separate proof zones from action forms
            const Divider(height: 1, thickness: 2, color: Colors.white),

            // Pinned main form actions into a fixed, sticky tray for immediate thumb access
            _buildActionTray(),
          ],
        ),
      ),
    );
  }

  Widget _buildCroppedView(Rect box, BoxConstraints constraints) {
    // Simulates SVG Bounding Box Cropping by clipping the canvas entirely
    // to the specified coordinate geometry, hiding peripheral areas.
    return ClipRect(
      clipper: _BoundingBoxClipper(box),
      child: SizedBox(
        width: constraints.maxWidth,
        height: constraints.maxHeight,
        child: CustomPaint(
          // Mocking an SVG render layer with a placeholder drawing
          painter: _MockDocumentPainter(box),
        ),
      ),
    );
  }

  Widget _buildActionTray() {
    final TextEditingController textController = TextEditingController();

    return Container(
      padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 24.0),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: TextField(
              controller: textController,
              decoration: InputDecoration(
                hintText: 'Enter extracted text...',
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
              ),
              inputFormatters: [
                FilteringTextInputFormatter.deny(RegExp(r'\s{2,}')),
              ],
            ),
          ),
          const SizedBox(width: 12.0),
          FilledButton.icon(
            onPressed: () {
              if (textController.text.isNotEmpty) {
                _submitValidation(textController.text);
                textController.clear();
              }
            },
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Validate'),
          ),
        ],
      ),
    );
  }
}

/// Custom Clipper that strictly isolates the view to the bounding box geometry.
class _BoundingBoxClipper extends CustomClipper<Rect> {
  final Rect boundingBox;

  _BoundingBoxClipper(this.boundingBox);

  @override
  Rect getClip(Size size) {
    // Maps the absolute coordinates to the local widget space
    // For this implementation, we assume the underlying canvas matches the coordinate system
    return Rect.fromLTWH(
      boundingBox.left,
      boundingBox.top,
      boundingBox.width,
      boundingBox.height,
    );
  }

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) => true;
}

/// Mock Painter simulating a full document where only the bounding box is visible due to clipping.
class _MockDocumentPainter extends CustomPainter {
  final Rect boundingBox;

  _MockDocumentPainter(this.boundingBox);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint bgPaint = Paint()..color = Colors.white;
    final Paint textPaint = Paint()..color = Colors.black87;
    final Paint borderPaint = Paint()
      ..color = Colors.blueAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Draw entire "document" background (will be clipped by parent)
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Draw mock sensitive PII arrays (peripheral data that will be hidden)
    for (int i = 0; i < 20; i++) {
      canvas.drawRect(
        Rect.fromLTWH(40, 40 + (i * 30.0), 200, 10),
        textPaint,
      );
    }

    // Draw the target micro-text segment inside the bounding box
    canvas.drawRect(boundingBox, borderPaint);
    
    // Simulate text lines inside the bounding box
    for (int i = 0; i < 3; i++) {
      canvas.drawRect(
        Rect.fromLTWH(
          boundingBox.left + 10,
          boundingBox.top + 15 + (i * 35.0),
          boundingBox.width - 20,
          12,
        ),
        textPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Desktop Popover Modal wrapper as defined in Setup Step Action.1
class ContextEvidenceDesktopModal extends StatelessWidget {
  final String stepExecutionId;
  final String userId;

  const ContextEvidenceDesktopModal({
    super.key,
    required this.stepExecutionId,
    required this.userId,
  });

  static Future<void> show(BuildContext context, String executionId, String userId) async {
    await showDialog(
      context: context,
      barrierDismissible: true, // click-outside-dismiss
      builder: (context) => ContextEvidenceDesktopModal(
        stepExecutionId: executionId,
        userId: userId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800, maxHeight: 600),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black54,
                  blurRadius: 24.0,
                  spreadRadius: 4.0,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: ContextEvidenceViewer(
                stepExecutionId: stepExecutionId,
                userId: userId,
              ),
            ),
          ),
        ),
      ),
    );
  }
}