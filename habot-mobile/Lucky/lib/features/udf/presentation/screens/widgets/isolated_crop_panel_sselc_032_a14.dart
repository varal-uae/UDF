// SSELC-032-A14 — Isolated Visual Crop Panel for coordinate-based image cropping.
// Implements a mobile-first, responsive split-screen layout that stacks vertically below 600dp,
// enforces high-contrast Material 3 design tokens, hides ambient navigation during active tasks,
// and provides tooltip guidance for structural form requirements.

import 'package:flutter/material.dart';

/// Mock execution data representing backend crop parameters and telemetry.
class _MockCropExecutionData {
  final String stepExecutionId;
  final String executionStatus;
  final DateTime executionTimestamp;
  final String stepOutcome;
  final String userId;
  final Rect cropCoordinates;

  const _MockCropExecutionData({
    required this.stepExecutionId,
    required this.executionStatus,
    required this.executionTimestamp,
    required this.stepOutcome,
    required this.userId,
    required this.cropCoordinates,
  });
}

final List<_MockCropExecutionData> _mockExecutions = [
  _MockCropExecutionData(
    stepExecutionId: 'EXEC-001',
    executionStatus: 'Pass',
    executionTimestamp: DateTime(2026, 9, 28, 10, 15),
    stepOutcome: 'Cropped successfully',
    userId: 'USR-992',
    cropCoordinates: const Rect.fromLTWH(50, 100, 400, 300),
  ),
  _MockCropExecutionData(
    stepExecutionId: 'EXEC-002',
    executionStatus: 'Fail',
    executionTimestamp: DateTime(2026, 9, 28, 10, 18),
    stepOutcome: 'Raw un-cropped file detected',
    userId: 'USR-992',
    cropCoordinates: Rect.zero,
  ),
];

/// Master Isolated Visual Crop Panel.
/// Limits active workspaces to single, explicit focus nodes.
/// Stacks panels vertically on screen widths below 600dp.
/// Uses contrasting fills to clearly define workspace panes.
class IsolatedCropPanelSSELC032A14 extends StatefulWidget {
  const IsolatedCropPanelSSELC032A14({super.key});

  @override
  State<IsolatedCropPanelSSELC032A14> createState() => _IsolatedCropPanelSSELC032A14State();
}

class _IsolatedCropPanelSSELC032A14State extends State<IsolatedCropPanelSSELC032A14> {
  bool _isTaskActive = false;

  // Metric Boundaries: Split-Panel Width Ratio (Evidence vs. Action Pane)
  static const double _floorBoundary = 4.0;
  static const double _optimalTarget = 8.0;
  static const double _ceilingBoundary = 16.0;

  void _toggleTaskActive() {
    setState(() {
      _isTaskActive = !_isTaskActive;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isCompact = screenWidth < 600;

    // Icon size scale per breakpoint
    final double iconSize = isCompact ? 20.0 : 24.0;

    // Calculate ratio band validation
    final double currentRatio = _optimalTarget; // Simulated optimal state
    final bool isWithinBand = currentRatio >= _floorBoundary && currentRatio <= _ceilingBoundary;

    return Scaffold(
      // Hide ambient app navigation when tasks are active
      bottomNavigationBar: _isTaskActive
          ? null
          : BottomNavigationBar(
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
              ],
            ),
      appBar: AppBar(
        title: const Text('Visual Isolation Crop Blueprint'),
        actions: [
          IconButton(
            iconSize: iconSize,
            icon: Icon(_isTaskActive ? Icons.play_arrow : Icons.pause),
            onPressed: _toggleTaskActive,
            tooltip: _isTaskActive ? 'Resume Navigation' : 'Focus Task Mode',
          ),
        ],
      ),
      body: isCompact
          ? _buildVerticalLayout(theme, iconSize, isWithinBand)
          : _buildSplitScreenLayout(theme, iconSize, isWithinBand),
    );
  }

  /// Mobile-First & Responsive UI: Stack panels vertically on screen widths below 600dp.
  Widget _buildVerticalLayout(ThemeData theme, double iconSize, bool isWithinBand) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildEvidencePane(theme, iconSize),
          const SizedBox(height: 16.0),
          _buildActionPane(theme, iconSize, isWithinBand),
        ],
      ),
    );
  }

  /// Follow Material Design guidelines for side-by-side split screen containers.
  Widget _buildSplitScreenLayout(ThemeData theme, double iconSize, bool isWithinBand) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 1,
          child: _buildEvidencePane(theme, iconSize),
        ),
        // Use contrasting fills to clearly define workspace panes
        VerticalDivider(
          width: 1,
          thickness: 1,
          color: theme.colorScheme.outlineVariant,
        ),
        Expanded(
          flex: 1,
          child: _buildActionPane(theme, iconSize, isWithinBand),
        ),
      ],
    );
  }

  /// Evidence Pane: Displays cropped snippet sections, masking out extra page text.
  Widget _buildEvidencePane(ThemeData theme, double iconSize) {
    // Apply accessible high-contrast palettes across text elements
    return Container(
      color: theme.colorScheme.surfaceContainerHighest,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.image_search, size: iconSize, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: 8.0),
              Text(
                'Cropped Evidence',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          // Coordinate-Based Image Cropping Engine mock representation
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return CustomPaint(
                  size: Size(constraints.maxWidth, constraints.maxHeight),
                  painter: _CropOverlayPainter(
                    cropRect: _mockExecutions.first.cropCoordinates,
                    overlayColor: Colors.black.withOpacity(0.6),
                    borderColor: theme.colorScheme.primary,
                  ),
                  child: Container(
                    color: theme.colorScheme.surfaceDim,
                    alignment: Alignment.center,
                    child: Text(
                      'Masked Document Area\nOnly cropped snippet visible',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Action Pane: Input rows stacked directly below document crop on compact screens.
  Widget _buildActionPane(ThemeData theme, double iconSize, bool isWithinBand) {
    return Container(
      color: theme.colorScheme.surface,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.edit_note, size: iconSize, color: theme.colorScheme.primary),
              const SizedBox(width: 8.0),
              Text(
                'Action Input',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              // Provide prominent tooltip boxes detailing structural form requirements
              Tooltip(
                message: 'Structural Form Requirement: Enter verified translation data matching the isolated crop boundaries. Unverified background data is rejected.',
                preferBelow: false,
                child: Icon(Icons.info_outline, size: iconSize, color: theme.colorScheme.secondary),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          // Build entry forms using standard user flow design patterns
          TextField(
            decoration: InputDecoration(
              labelText: 'Translation Input',
              hintText: 'Enter translated text...',
              border: OutlineInputBorder(
                // Match border characteristics to standard system design specifications
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(color: theme.colorScheme.outline),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(color: theme.colorScheme.primary, width: 2.0),
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          // Validation status indicator based on metric boundaries
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: isWithinBand ? theme.colorScheme.primaryContainer : theme.colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Row(
              children: [
                Icon(
                  isWithinBand ? Icons.check_circle : Icons.error,
                  color: isWithinBand ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onErrorContainer,
                  size: iconSize,
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Text(
                    isWithinBand
                        ? 'Validation Pass: Panes within ratio band (Floor: ${_floorBoundary}dp, Optimal: ${_optimalTarget}dp, Ceiling: ${_ceilingBoundary}dp).'
                        : 'Validation Fail: Pane narrower than floor boundary breaks readability.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isWithinBand ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onErrorContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24.0),
          // Execution History Log (Mock Data)
          Text(
            'Execution Telemetry',
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: ListView.separated(
              itemCount: _mockExecutions.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final exec = _mockExecutions[index];
                return ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    exec.executionStatus == 'Pass' ? Icons.task_alt : Icons.cancel,
                    color: exec.executionStatus == 'Pass' ? Colors.green : Colors.red,
                    size: iconSize,
                  ),
                  title: Text(
                    exec.stepExecutionId,
                    style: theme.textTheme.bodyMedium,
                  ),
                  subtitle: Text(
                    '${exec.stepOutcome} | ${exec.executionTimestamp.toString().substring(0, 16)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter simulating the coordinate-based image cropping engine.
/// Masks out extra page text by drawing a dark overlay with a clear cutout.
class _CropOverlayPainter extends CustomPainter {
  final Rect cropRect;
  final Color overlayColor;
  final Color borderColor;

  _CropOverlayPainter({
    required this.cropRect,
    required this.overlayColor,
    required this.borderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = overlayColor;
    final path = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    if (cropRect != Rect.zero) {
      // Scale crop rect to fit available space for demonstration
      final scaledRect = Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2),
        width: size.width * 0.7,
        height: size.height * 0.5,
      );
      path.addRect(scaledRect);
      path.fillType = PathFillType.evenOdd;

      canvas.drawPath(path, paint);

      // Draw border around the isolated crop
      final borderPaint = Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawRect(scaledRect, borderPaint);
    } else {
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _CropOverlayPainter oldDelegate) {
    return oldDelegate.cropRect != cropRect ||
        oldDelegate.overlayColor != overlayColor ||
        oldDelegate.borderColor != borderColor;
  }
}