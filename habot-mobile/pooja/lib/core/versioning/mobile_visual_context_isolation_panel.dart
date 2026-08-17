/*
 * STEP 34: MCIIM-014-07 — Isolate Mobile Visual Context
 * 
 * Setup Step (Action): Isolate Mobile Visual Context.
 * Setup Step Description: Display only the cropped focus region inside the primary viewport container.
 * 
 * Mobile-First & Responsive UX/UI Decisions:
 *   - Implement strict margin and gutter constraints to force a single focal point (16dp left/right margins).
 *   - Use surface elevation to make the isolated Byt "pop" off the screen.
 *   - Use an M3 Surface component with distinct tonalElevation.
 *   - Enforce 16dp margins from the left and right edges.
 *   - Accuracy Metric: Google Document AI accuracy benchmarks & ISO/IEC TR 29794 image quality standards (0.9 to 0.995).
 * 
 * What Was Done to Complete This Step:
 *   - Created `MobileVisualContextIsolationPanel` widget, `VisualContextIsolationRecord`, and `CroppedFocusRegion` models in a single file.
 *   - Implemented M3 Surface tonal elevation container, strict 16dp gutter constraints, Document AI confidence meter, and single focal point lock.
 */

import 'package:flutter/material.dart';
import '../tokens/color_palette.dart';
import '../tokens/elevation_tokens.dart';
import '../tokens/spacing_tokens.dart';

/// Step MCIIM-014-07: Visual Context Isolation Audit Record Model.
class VisualContextIsolationRecord {
  final String stepExecutionId;
  final String executionStatus;
  final String executionTimestamp;
  final String stepOutcome;
  final String userId;
  final double extractionAccuracy; // Floor: 0.9, Optimal: 0.97, Ceiling: 0.995
  final String completionStatus;   // Pass / Fail

  const VisualContextIsolationRecord({
    required this.stepExecutionId,
    required this.executionStatus,
    required this.executionTimestamp,
    required this.stepOutcome,
    required this.userId,
    this.extractionAccuracy = 0.97,
    this.completionStatus = 'Pass',
  });
}

/// Step MCIIM-014-07: Cropped Focus Region Data Model.
class CroppedFocusRegion {
  final String regionId;
  final String sourceDocumentName;
  final String cropCoordinates;
  final double extractionConfidenceScore;
  final String extractedDataSnippet;

  const CroppedFocusRegion({
    required this.regionId,
    required this.sourceDocumentName,
    required this.cropCoordinates,
    required this.extractionConfidenceScore,
    required this.extractedDataSnippet,
  });
}

/// Step MCIIM-014-07: Mobile Visual Context Isolation Panel Component.
class MobileVisualContextIsolationPanel extends StatefulWidget {
  final VisualContextIsolationRecord record;

  const MobileVisualContextIsolationPanel({
    super.key,
    required this.record,
  });

  @override
  State<MobileVisualContextIsolationPanel> createState() => _MobileVisualContextIsolationPanelState();
}

class _MobileVisualContextIsolationPanelState extends State<MobileVisualContextIsolationPanel> {
  bool _isFocusLocked = true;

  final _sampleRegion = const CroppedFocusRegion(
    regionId: 'CROP-DOC-8891',
    sourceDocumentName: 'Q3_Invoice_Audit_Master.pdf',
    cropCoordinates: 'X: 140, Y: 320, W: 480, H: 220',
    extractionConfidenceScore: 0.975,
    extractedDataSnippet: 'TAX-ID: TX-998822-EXP | AMOUNT: \$14,250.00 USD',
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isAccuracyPass = widget.record.extractionAccuracy >= 0.90;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0), // Enforce 16dp left/right margins
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Step Header Card
              Card(
                elevation: 2,
                color: colorScheme.surfaceContainerHigh,
                child: Padding(
                  padding: AppSpacingTokens.paddingLg,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.crop_free, color: colorScheme.primary, size: 28),
                          AppSpacingTokens.hGapSm,
                          Expanded(
                            child: Text(
                              'Step 34: Isolate Mobile Visual Context',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'MCIIM-014-07',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      AppSpacingTokens.vGapSm,
                      Text(
                        'Isolates the cropped focus region inside the primary viewport container using strict 16dp gutter constraints, Level 3 tonal elevation, and Document AI extraction validation.',
                        style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ),

              AppSpacingTokens.vGapMd,

              // Primary Focal Point Container (M3 Surface with Tonal Elevation & 16dp Margins)
              Surface(
                tonalElevation: 3.0,
                shadowColor: colorScheme.shadow.withAlpha(80),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                  side: BorderSide(
                    color: _isFocusLocked ? colorScheme.primary : colorScheme.outlineVariant,
                    width: _isFocusLocked ? 2.0 : 1.0,
                  ),
                ),
                child: Container(
                  padding: AppSpacingTokens.paddingLg,
                  decoration: BoxDecoration(
                    color: _isFocusLocked
                        ? colorScheme.surfaceContainerLow
                        : colorScheme.surface,
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _isFocusLocked ? Icons.filter_center_focus : Icons.center_focus_weak,
                                color: colorScheme.primary,
                              ),
                              AppSpacingTokens.hGapSm,
                              Text(
                                'Isolated Focal Region',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                          Switch(
                            value: _isFocusLocked,
                            onChanged: (val) => setState(() => _isFocusLocked = val),
                            activeTrackColor: colorScheme.primary,
                          ),
                        ],
                      ),

                      AppSpacingTokens.vGapSm,

                      Text(
                        'Source Document: ${_sampleRegion.sourceDocumentName}',
                        style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),

                      AppSpacingTokens.vGapMd,

                      // Cropped Focal Region Visual Byt Box
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: double.infinity,
                        padding: AppSpacingTokens.paddingLg,
                        decoration: BoxDecoration(
                          color: _isFocusLocked ? Colors.black87 : colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(60),
                              blurRadius: AppElevationTokens.level3,
                              offset: const Offset(0, 3),
                            ),
                          ],
                          border: Border.all(
                            color: _isFocusLocked ? colorScheme.primary : colorScheme.outline,
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Chip(
                                  avatar: Icon(Icons.crop, size: 14, color: Colors.white),
                                  label: Text('Cropped Focus Region', style: TextStyle(color: Colors.white, fontSize: 11)),
                                  backgroundColor: Colors.black54,
                                  visualDensity: VisualDensity.compact,
                                ),
                                Text(
                                  _sampleRegion.cropCoordinates,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 10,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ],
                            ),
                            AppSpacingTokens.vGapMd,
                            Container(
                              width: double.infinity,
                              padding: AppSpacingTokens.paddingMd,
                              decoration: BoxDecoration(
                                color: colorScheme.primaryContainer.withAlpha(220),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _sampleRegion.extractedDataSnippet,
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              AppSpacingTokens.vGapMd,

              // Google Document AI Accuracy Meter Card
              Card(
                elevation: 1,
                child: Padding(
                  padding: AppSpacingTokens.paddingLg,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Google Document AI Extraction Accuracy',
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Chip(
                            avatar: Icon(
                              isAccuracyPass ? Icons.verified : Icons.error,
                              size: 16,
                              color: isAccuracyPass ? AppColorPalette.success : colorScheme.error,
                            ),
                            label: Text('${(widget.record.extractionAccuracy * 100).toStringAsFixed(1)}% (${widget.record.completionStatus})'),
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ),
                      AppSpacingTokens.vGapSm,
                      Text(
                        'Benchmark: Google Document AI & ISO/IEC TR 29794 image quality standards (Floor: 90.0%, Optimal: 97.0%, Ceiling: 99.5%).',
                        style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                      AppSpacingTokens.vGapMd,
                      LinearProgressIndicator(
                        value: widget.record.extractionAccuracy,
                        minHeight: 10,
                        borderRadius: BorderRadius.circular(5),
                        backgroundColor: colorScheme.surfaceContainerHighest,
                        color: isAccuracyPass ? AppColorPalette.success : colorScheme.error,
                      ),
                    ],
                  ),
                ),
              ),

              AppSpacingTokens.vGapMd,

              // Step Execution Audit Footer Card
              Card(
                elevation: 0,
                color: colorScheme.surfaceContainerLow,
                child: Padding(
                  padding: AppSpacingTokens.paddingMd,
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, size: 20),
                      AppSpacingTokens.hGapSm,
                      Expanded(
                        child: Text(
                          'Execution ID: ${widget.record.stepExecutionId} | User: ${widget.record.userId} | Outcome: ${widget.record.stepOutcome}',
                          style: theme.textTheme.labelMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Helper Surface Widget matching M3 Surface specification with tonal elevation.
class Surface extends StatelessWidget {
  final Widget child;
  final double tonalElevation;
  final Color shadowColor;
  final ShapeBorder shape;

  const Surface({
    super.key,
    required this.child,
    this.tonalElevation = 0.0,
    required this.shadowColor,
    required this.shape,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: tonalElevation,
      shadowColor: shadowColor,
      shape: shape,
      child: child,
    );
  }
}
