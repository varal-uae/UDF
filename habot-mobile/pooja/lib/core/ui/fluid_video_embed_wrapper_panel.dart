/*
 * DPNDL-001-A07 — Fluid Video Embed Aspect-Ratio Wrapper
 * 
 * Setup Step (Action): Implement fluid video embeds using the aspect-ratio wrapper pattern.
 * Metric Name: Build Scope Completeness (Floor: 90%, Target: 98%, Ceiling: 100%)
 * Quality Standard: Sprint build tasks tracked to completion; high-performing teams gate completeness on automated checks.
 * Assigned Member: Pooja
 */

import 'package:flutter/material.dart';
import '../tokens/color_palette.dart';
import '../tokens/spacing_tokens.dart';

class FluidVideoEmbedWrapperPanel extends StatefulWidget {
  final String globalRefId;
  final String atomicStepRefId;
  final String sequenceOrder;

  const FluidVideoEmbedWrapperPanel({
    super.key,
    this.globalRefId = 'DPNDL-001',
    this.atomicStepRefId = 'DPNDL-001-A07',
    this.sequenceOrder = '11053',
  });

  @override
  State<FluidVideoEmbedWrapperPanel> createState() =>
      _FluidVideoEmbedWrapperPanelState();
}

class _FluidVideoEmbedWrapperPanelState
    extends State<FluidVideoEmbedWrapperPanel> {
  double _selectedAspectRatio = 16 / 9;
  String _aspectRatioLabel = '16:9 Widescreen';
  bool _isPlaying = false;
  bool _isMuted = false;
  double _playbackProgress = 0.35;

  final Map<String, double> _ratioOptions = {
    '16:9 Widescreen': 16 / 9,
    '4:3 Standard': 4 / 3,
    '21:9 Ultrawide': 21 / 9,
    '1:1 Square': 1.0,
  };

  Map<String, dynamic> toExecutionLogJson() {
    return {
      'stepExecutionId': 'EXEC-DPNDL-001-2026',
      'executionStatus': 'FLUID_EMBED_ACTIVE',
      'executionTimestamp': DateTime.now().toUtc().toIso8601String(),
      'stepOutcome': 'ASPECT_RATIO_PRESERVED',
      'userId': 'USER-AUTO-B17',
      'completionStatus': 'Complete',
      'actionEventTimestamp': DateTime.now().toUtc().toIso8601String(),
      'userSessionId': 'SESSION-DPNDL-001',
      'metadata': {
        'taskCode': widget.globalRefId,
        'atomicStepCode': widget.atomicStepRefId,
        'row': 163,
        'seq': int.tryParse(widget.sequenceOrder) ?? 11053,
        'assigned': 'Pooja',
        'metricName': 'Build Scope Completeness',
        'floor': '90%',
        'target': '98%',
        'ceiling': '100%',
        'unit': 'Complete (Scale: Complete/Partial/Not Complete)',
        'aspectRatioLabel': _aspectRatioLabel,
        'aspectRatioValue': _selectedAspectRatio,
        'distortionPrevented': true,
        'isAspectPreserved': true,
        'touchTargetCompliant': true,
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 600;
        final isExpanded = constraints.maxWidth >= 840;
        final padding = isCompact
            ? AppSpacingTokens.paddingSm
            : (isExpanded ? AppSpacingTokens.paddingLg : AppSpacingTokens.paddingMd);

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: AppColorPalette.lightOutline.withValues(alpha: 0.2),
            ),
          ),
          child: Padding(
            padding: padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(isCompact),
                AppSpacingTokens.vGapMd,
                _buildRatioSelector(isCompact),
                AppSpacingTokens.vGapMd,
                _buildVideoWrapper(isCompact, isExpanded),
                AppSpacingTokens.vGapMd,
                _buildControlsBar(isCompact),
                AppSpacingTokens.vGapMd,
                _buildComplianceFooter(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool isCompact) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColorPalette.brandPrimary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.video_library_rounded,
            color: AppColorPalette.brandPrimary,
            size: 24,
          ),
        ),
        AppSpacingTokens.hGapMd,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Fluid Video Embed Aspect-Ratio Wrapper',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              AppSpacingTokens.vGapXs,
              Text(
                '${widget.globalRefId} · ${widget.atomicStepRefId} · Seq: ${widget.sequenceOrder}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColorPalette.lightOutline,
                    ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColorPalette.successContainer,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppColorPalette.success.withValues(alpha: 0.3),
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle_outline_rounded,
                  color: AppColorPalette.success, size: 14),
              SizedBox(width: 4),
              Text(
                'FLUID WRAPPER ACTIVE',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColorPalette.success,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRatioSelector(bool isCompact) {
    return Wrap(
      spacing: AppSpacingTokens.sm,
      runSpacing: AppSpacingTokens.sm,
      children: _ratioOptions.entries.map((entry) {
        final isSelected = _aspectRatioLabel == entry.key;
        return ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          child: ChoiceChip(
            label: Text(entry.key),
            selected: isSelected,
            selectedColor: AppColorPalette.brandPrimary.withValues(alpha: 0.2),
            onSelected: (selected) {
              if (selected) {
                setState(() {
                  _aspectRatioLabel = entry.key;
                  _selectedAspectRatio = entry.value;
                });
              }
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildVideoWrapper(bool isCompact, bool isExpanded) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColorPalette.lightBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColorPalette.lightOutline.withValues(alpha: 0.2),
        ),
      ),
      padding: const EdgeInsets.all(8),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: isCompact ? 220 : 340,
          ),
          child: AspectRatio(
            aspectRatio: _selectedAspectRatio,
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColorPalette.brandPrimary.withValues(alpha: 0.4),
                  width: 1.5,
                ),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColorPalette.brandPrimary.withValues(alpha: 0.6),
                          Colors.black.withValues(alpha: 0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isPlaying
                                ? Icons.motion_photos_on_rounded
                                : Icons.smart_display_rounded,
                            size: 48,
                            color: Colors.white70,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Fluid Player · $_aspectRatioLabel',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Ratio: ${_selectedAspectRatio.toStringAsFixed(2)} : 1 · Zero Distortion',
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Center(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _isPlaying = !_isPlaying;
                          });
                        },
                        borderRadius: BorderRadius.circular(32),
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black.withValues(alpha: 0.5),
                            border: Border.all(
                              color: Colors.white54,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            _isPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        LinearProgressIndicator(
                          value: _playbackProgress,
                          backgroundColor: Colors.white24,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColorPalette.brandPrimary,
                          ),
                          minHeight: 4,
                        ),
                      ],
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

  Widget _buildControlsBar(bool isCompact) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacingTokens.md,
        vertical: AppSpacingTokens.sm,
      ),
      decoration: BoxDecoration(
        color: AppColorPalette.lightBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            child: IconButton(
              icon: Icon(
                _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              ),
              onPressed: () {
                setState(() {
                  _isPlaying = !_isPlaying;
                });
              },
            ),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            child: IconButton(
              icon: Icon(
                _isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
              ),
              onPressed: () {
                setState(() {
                  _isMuted = !_isMuted;
                });
              },
            ),
          ),
          AppSpacingTokens.hGapSm,
          Expanded(
            child: Slider(
              value: _playbackProgress,
              onChanged: (val) {
                setState(() {
                  _playbackProgress = val;
                });
              },
              activeColor: AppColorPalette.brandPrimary,
            ),
          ),
          AppSpacingTokens.hGapSm,
          const Text(
            '01:45 / 05:00',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComplianceFooter() {
    return Container(
      padding: const EdgeInsets.all(AppSpacingTokens.sm),
      decoration: BoxDecoration(
        color: AppColorPalette.lightBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.aspect_ratio_rounded,
            color: AppColorPalette.brandPrimary,
            size: 16,
          ),
          AppSpacingTokens.hGapSm,
          Expanded(
            child: Text(
              'Enforces responsive aspect ratio preservation to eradicate anamorphic stretching across mobile & ultrawide viewports.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                    color: AppColorPalette.lightOutline,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
