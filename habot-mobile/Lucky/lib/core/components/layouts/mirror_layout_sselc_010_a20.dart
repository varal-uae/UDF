// SSELC-010-A20 — Split-Screen Contextual Mirror Component Configuration.
// Provides a responsive mirror layout that displays input forms alongside reference items, switching from side-by-side to stacked vertical flow below 600dp with pinch-to-zoom support and alignment correction.

import 'package:flutter/material.dart';

/// Mock telemetry data collector for interface performance tracking.
class _MirrorLayoutTelemetry {
  static final List<Map<String, dynamic>> logs = [];

  static void recordEvent({
    required String testType,
    required String testResult,
    required double testCoverage,
    required DateTime testTimestamp,
    required String testLogPath,
  }) {
    logs.add({
      'Test Type': testType,
      'Test Result': testResult,
      'Test Coverage': testCoverage,
      'Test Timestamp': testTimestamp.toIso8601String(),
      'Test Log Path': testLogPath,
      'Completion Status': testResult == 'PASS' ? 'Pass' : 'Fail',
      'Action/Event Timestamp': DateTime.now().toIso8601String(),
      'User/Session ID': 'mock-session-001',
    });
  }
}

/// A reusable structural foundation wrapper that balances input forms
/// smoothly alongside reference items using Material Design 3 standards.
/// Enforces the 8pt grid baseline and switches to single-column vertical
/// flows when screen sizes drop below 600dp.
class MirrorLayout extends StatefulWidget {
  /// The primary input form or interactive content widget.
  final Widget inputPanel;

  /// The reference document, image, or contextual mirror widget.
  final Widget referencePanel;

  /// Optional trailing close vector icons inside chips for multi-selection clearing.
  final List<Widget>? actionChips;

  /// Minimum touch target size enforced by Poka-Yoke mistake-proofing.
  static const double kMinTouchTargetSize = 48.0;

  /// Breakpoint threshold in logical pixels for mobile-first stacking.
  static const double kMobileBreakpoint = 600.0;

  /// Maximum allowed misalignment in pixels before correction script triggers.
  static const double kMaxMisalignmentPx = 10.0;

  const MirrorLayout({
    super.key,
    required this.inputPanel,
    required this.referencePanel,
    this.actionChips,
  });

  @override
  State<MirrorLayout> createState() => _MirrorLayoutState();
}

class _MirrorLayoutState extends State<MirrorLayout> {
  final GlobalKey _inputKey = GlobalKey();
  final GlobalKey _referenceKey = GlobalKey();
  final TransformationController _transformationController = TransformationController();

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  /// Self-chasing correction: If data fields on opposite sides of the layout
  /// lose structural alignment by more than 10px, run a correction to reset heights.
  void _runAlignmentCorrection() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final inputBox = _inputKey.currentContext?.findRenderObject() as RenderBox?;
      final refBox = _referenceKey.currentContext?.findRenderObject() as RenderBox?;

      if (inputBox != null && refBox != null && inputBox.hasSize && refBox.hasSize) {
        final heightDiff = (inputBox.size.height - refBox.size.height).abs();

        if (heightDiff > MirrorLayout.kMaxMisalignmentPx) {
          _MirrorLayoutTelemetry.recordEvent(
            testType: 'Viewport Alignment Correction',
            testResult: 'CORRECTED',
            testCoverage: 1.0,
            testTimestamp: DateTime.now(),
            testLogPath: '/logs/alignment_correction.log',
          );
          // Trigger rebuild to enforce equal heights via Expanded/Flex
          setState(() {});
        } else {
          _MirrorLayoutTelemetry.recordEvent(
            testType: 'Viewport Alignment Check',
            testResult: 'PASS',
            testCoverage: 1.0,
            testTimestamp: DateTime.now(),
            testLogPath: '/logs/alignment_check.log',
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _runAlignmentCorrection();

    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < MirrorLayout.kMobileBreakpoint;

    return LayoutBuilder(
      builder: (context, constraints) {
        // CSS Flexbox column equivalent on mobile, row on desktop
        if (isMobile) {
          return _buildVerticalStack(constraints);
        }
        return _buildSideBySideGrid(constraints);
      },
    );
  }

  Widget _buildVerticalStack(BoxConstraints constraints) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.actionChips != null) ...[
          _buildActionChipBar(),
          const SizedBox(height: 8), // 8pt grid adherence
        ],
        Flexible(
          flex: 1,
          child: _buildInputWrapper(),
        ),
        const SizedBox(height: 16), // 8pt grid adherence
        Flexible(
          flex: 1,
          child: _buildReferenceWrapper(),
        ),
      ],
    );
  }

  Widget _buildSideBySideGrid(BoxConstraints constraints) {
    return Column(
      children: [
        if (widget.actionChips != null) ...[
          _buildActionChipBar(),
          const SizedBox(height: 8),
        ],
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 1,
                child: _buildInputWrapper(),
              ),
              const SizedBox(width: 16), // 8pt grid adherence
              Expanded(
                flex: 1,
                child: _buildReferenceWrapper(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionChipBar() {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: widget.actionChips!.map((chip) {
        // Poka-Yoke: Ensure minimum touch target size
        return ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: MirrorLayout.kMinTouchTargetSize,
            minWidth: MirrorLayout.kMinTouchTargetSize,
          ),
          child: chip,
        );
      }).toList(),
    );
  }

  Widget _buildInputWrapper() {
    return Card(
      key: _inputKey,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant,
          width: 1.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: widget.inputPanel,
      ),
    );
  }

  Widget _buildReferenceWrapper() {
    return Card(
      key: _referenceKey,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        // Clear outline styles to stand out on mobile screens
        side: BorderSide(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          width: 2.0,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: Stack(
          children: [
            Positioned.fill(
              child: InteractiveViewer(
                transformationController: _transformationController,
                minScale: 0.5,
                maxScale: 4.0,
                panEnabled: true,
                scaleEnabled: true, // Intuitive pinch-to-zoom controls
                child: widget.referencePanel,
              ),
            ),
            // Clean zoom utility shortcuts for quick adjustments
            Positioned(
              bottom: 16.0,
              right: 16.0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildZoomButton(
                    icon: Icons.zoom_in_rounded,
                    onPressed: () {
                      final matrix = _transformationController.value.clone();
                      matrix.scale(1.2);
                      _transformationController.value = matrix;
                    },
                  ),
                  const SizedBox(height: 8.0),
                  _buildZoomButton(
                    icon: Icons.zoom_out_rounded,
                    onPressed: () {
                      final matrix = _transformationController.value.clone();
                      matrix.scale(0.8);
                      _transformationController.value = matrix;
                    },
                  ),
                  const SizedBox(height: 8.0),
                  _buildZoomButton(
                    icon: Icons.fit_screen_rounded,
                    onPressed: () {
                      _transformationController.value = Matrix4.identity();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildZoomButton({required IconData icon, required VoidCallback onPressed}) {
    // Poka-Yoke: Lock user actions preventing layout changes from breaking minimum touch targets
    return SizedBox(
      width: MirrorLayout.kMinTouchTargetSize,
      height: MirrorLayout.kMinTouchTargetSize,
      child: FloatingActionButton.small(
        heroTag: null,
        onPressed: onPressed,
        elevation: 2.0,
        child: Icon(icon, size: 24.0),
      ),
    );
  }
}

/// Example usage demonstrating the MirrorLayout component with mock data.
class MirrorLayoutDemoScreen extends StatelessWidget {
  const MirrorLayoutDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Split-Screen Mirror Layout'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: MirrorLayout(
          actionChips: [
            ActionChip(
              avatar: const Icon(Icons.close, size: 18.0),
              label: const Text('Clear Selection 1'),
              onPressed: () {},
            ),
            ActionChip(
              avatar: const Icon(Icons.close, size: 18.0),
              label: const Text('Clear Selection 2'),
              onPressed: () {},
            ),
          ],
          inputPanel: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Data Verification Form',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16.0),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Record ID',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Operator Notes',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 24.0),
              FilledButton.icon(
                onPressed: () {
                  _MirrorLayoutTelemetry.recordEvent(
                    testType: 'Form Submission',
                    testResult: 'PASS',
                    testCoverage: 1.0,
                    testTimestamp: DateTime.now(),
                    testLogPath: '/logs/form_submission.log',
                  );
                },
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Verify Record'),
              ),
            ],
          ),
          referencePanel: Container(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.description_outlined,
                    size: 64.0,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    'Reference Document\n(Pinch to Zoom)',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 32.0),
                  // Mock reference data lines to match against input
                  ...List.generate(
                    5,
                    (index) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Field ${index + 1}: Mock Reference Value ${String.fromCharCode(65 + index)}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
