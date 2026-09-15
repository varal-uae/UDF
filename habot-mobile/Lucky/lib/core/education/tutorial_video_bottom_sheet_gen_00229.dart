// GEN-00229 — Collapsible MD3 Tutorial Video Bottom Sheet.
// Displays microlearning instructional videos inside a collapsible, draggable Material 3 bottom sheet.
// Validates video duration against Nielsen Norman Group microlearning thresholds (<= 5 minutes max, <= 30s optimal).

import 'package:flutter/material.dart';

/// EC Blueprint:
/// 1. Initialize modal bottom sheet with DraggableScrollableSheet for collapsible mobile UX.
/// 2. Validate instructional media duration against hard ceiling (300 seconds) and microlearning target (30 seconds).
/// 3. Render video player container with Material 3 styling, status badges, and 48x48dp interactive controls.
/// 4. Report playback completion status ('Pass' or 'Fail') to telemetry.

/// Model representing tutorial video metadata.
class TutorialVideoMetadata {
  final String title;
  final String videoUrl;
  final Duration duration;
  final String? stepReferenceId;

  const TutorialVideoMetadata({
    required this.title,
    required this.videoUrl,
    required this.duration,
    this.stepReferenceId,
  });

  // VALIDATE: Check if instructional video duration satisfies microlearning standards
  bool isValidDuration() {
    const Duration hardCeiling = Duration(minutes: 5);
    return duration <= hardCeiling;
  }

  // EVALUATE: Check if duration meets optimal microlearning standard (<= 30s)
  bool isOptimalMicrolearning() {
    const Duration optimalCeiling = Duration(seconds: 30);
    return duration <= optimalCeiling;
  }
}

/// A collapsible Material 3 bottom sheet for rendering tutorial videos.
class TutorialVideoBottomSheetGen00229 extends StatefulWidget {
  final TutorialVideoMetadata metadata;
  final VoidCallback? onCompleted;
  final ValueChanged<String>? onTelemetryLog;

  const TutorialVideoBottomSheetGen00229({
    super.key,
    required this.metadata,
    this.onCompleted,
    this.onTelemetryLog,
  });

  // SHOW: Helper method to launch the bottom sheet on mobile devices
  static Future<void> show({
    required BuildContext context,
    required TutorialVideoMetadata metadata,
    VoidCallback? onCompleted,
    ValueChanged<String>? onTelemetryLog,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext ctx) => TutorialVideoBottomSheetGen00229(
        metadata: metadata,
        onCompleted: onCompleted,
        onTelemetryLog: onTelemetryLog,
      ),
    );
  }

  @override
  State<TutorialVideoBottomSheetGen00229> createState() =>
      _TutorialVideoBottomSheetGen00229State();
}

class _TutorialVideoBottomSheetGen00229State
    extends State<TutorialVideoBottomSheetGen00229> {
  bool _isPlaying = false;
  double _progress = 0.0;
  bool _hasPassed = false;

  @override
  void initState() {
    super.initState();
    _evaluateDuration();
  }

  // EVALUATE: Verify media duration thresholds on initialization
  void _evaluateDuration() {
    if (!widget.metadata.isValidDuration()) {
      widget.onTelemetryLog?.call('FAIL: Media exceeds 5-minute hard ceiling');
    } else {
      widget.onTelemetryLog?.call('PASS: Media satisfies duration policy');
    }
  }

  // TOGGLE: Alternate play and pause states for the tutorial video
  void _togglePlayback() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying && _progress == 0.0) {
        _progress = 0.1;
      }
    });
  }

  // COMPLETE: Mark instructional step as complete and trigger callbacks
  void _completePlayback() {
    setState(() {
      _progress = 1.0;
      _isPlaying = false;
      _hasPassed = true;
    });
    widget.onTelemetryLog?.call('Pass');
    widget.onCompleted?.call();
  }

  // DISMISS: Close the collapsible bottom sheet
  void _dismissSheet() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.35,
      maxChildSize: 0.90,
      expand: false,
      builder: (context, scrollController) {
        return Material(
          elevation: 3,
          color: colorScheme.surface,
          surfaceTintColor: colorScheme.surfaceTint,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children:
              _buildSheetContent(context, colorScheme, scrollController),
          ),
        );
      },
    );
  }

  // BUILD: Construct content list inside draggable sheet
  List<Widget> _buildSheetContent(
    BuildContext context,
    ColorScheme colorScheme,
    ScrollController scrollController,
  ) {
    return [
      // MD3 Drag Handle
      Center(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 12),
          width: 32,
          height: 4,
          decoration: BoxDecoration(
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),

      // Top Header with Title and Close Action
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          children: [
            Expanded(
              child: Text(
                widget.metadata.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Status Chip indicator for microlearning compliance
            _buildStatusChip(colorScheme),
            const SizedBox(width: 8),
            IconButton(
              iconSize: 24,
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              icon: const Icon(Icons.close),
              tooltip: 'Close',
              onPressed: _dismissSheet,
            ),
          ],
        ),
      ),

      const Divider(height: 1),

      // Scrollable Video & Controls Container
      Expanded(
        child: ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(16),
          children: [
            // Video Player Container (16:9 Aspect Ratio)
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Card(
                elevation: 2,
                color: colorScheme.surfaceContainerHighest,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Center(
                      child: Icon(
                        Icons.movie_outlined,
                        size: 64,
                        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                      ),
                    ),
                    if (_isPlaying)
                      LinearProgressIndicator(
                        value: _progress > 0 ? _progress : null,
                        backgroundColor: Colors.transparent,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(colorScheme.primary),
                      ),
                    // Play / Pause Overlay Button with 48x48dp minimum target
                    InkWell(
                      onTap: _togglePlayback,
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colorScheme.primaryContainer,
                        ),
                        child: Icon(
                          _isPlaying ? Icons.pause : Icons.play_arrow,
                          size: 32,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Instructional Media Specs Card
            Card(
              elevation: 1,
              color: colorScheme.surfaceContainerLow,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Instructional Duration',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        Text(
                          '${widget.metadata.duration.inSeconds}s (Max: 300s)',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: (widget.metadata.duration.inSeconds / 300).clamp(0.0, 1.0),
                      color: widget.metadata.duration.inSeconds > 300
                          ? colorScheme.error
                          : colorScheme.primary,
                      backgroundColor:
                          colorScheme.surfaceContainerHighest,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Action Control: Mark as Completed
            FilledButton.icon(
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: Icon(_hasPassed ? Icons.check_circle : Icons.done),
              label: Text(_hasPassed ? 'Tutorial Completed' : 'Mark Completed'),
              onPressed: _hasPassed ? null : _completePlayback,
            ),
          ],
        ),
      ),
    ];
  }

  // BUILD: Construct microlearning status chip
  Widget _buildStatusChip(ColorScheme colorScheme) {
    final isOptimal = widget.metadata.isOptimalMicrolearning();
    final isValid = widget.metadata.isValidDuration();

    final String label = !isValid
        ? 'Over Max Limit'
        : isOptimal
            ? 'Micro-optimal'
            : 'Standard Duration';

    final Color containerColor = !isValid
        ? colorScheme.errorContainer
        : isOptimal
            ? colorScheme.tertiaryContainer
            : colorScheme.secondaryContainer;

    final Color onColor = !isValid
        ? colorScheme.onErrorContainer
        : isOptimal
            ? colorScheme.onTertiaryContainer
            : colorScheme.onSecondaryContainer;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: onColor,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
