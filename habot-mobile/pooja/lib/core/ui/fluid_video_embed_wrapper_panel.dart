/*
 * DPNDL-001-A07 — Fluid Video Embed Aspect-Ratio Wrapper
 * 
 * Setup Step (Action): Implement fluid video embeds using the aspect-ratio wrapper pattern.
 * Metric Name: Build Scope Completeness (Floor: 90%, Target: 98%, Ceiling: 100%)
 * Quality Standard: Sprint build tasks tracked to completion; high-performing teams gate completeness on automated checks.
 * Assigned Member: Pooja
 */

import 'package:flutter/material.dart';

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
            ? FluidVideoEmbedWrapperPanelTokens.paddingSm
            : (isExpanded ? FluidVideoEmbedWrapperPanelTokens.paddingLg : FluidVideoEmbedWrapperPanelTokens.paddingMd);

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: FluidVideoEmbedWrapperPanelTokens.lightOutline.withValues(alpha: 0.2),
            ),
          ),
          child: Padding(
            padding: padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(isCompact),
                FluidVideoEmbedWrapperPanelTokens.vGapMd,
                _buildRatioSelector(isCompact),
                FluidVideoEmbedWrapperPanelTokens.vGapMd,
                _buildVideoWrapper(isCompact, isExpanded),
                FluidVideoEmbedWrapperPanelTokens.vGapMd,
                _buildControlsBar(isCompact),
                FluidVideoEmbedWrapperPanelTokens.vGapMd,
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
            color: FluidVideoEmbedWrapperPanelTokens.brandPrimary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.video_library_rounded,
            color: FluidVideoEmbedWrapperPanelTokens.brandPrimary,
            size: 24,
          ),
        ),
        FluidVideoEmbedWrapperPanelTokens.hGapMd,
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
              FluidVideoEmbedWrapperPanelTokens.vGapXs,
              Text(
                '${widget.globalRefId} · ${widget.atomicStepRefId} · Seq: ${widget.sequenceOrder}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: FluidVideoEmbedWrapperPanelTokens.lightOutline,
                    ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: FluidVideoEmbedWrapperPanelTokens.successContainer,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: FluidVideoEmbedWrapperPanelTokens.success.withValues(alpha: 0.3),
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle_outline_rounded,
                  color: FluidVideoEmbedWrapperPanelTokens.success, size: 14),
              SizedBox(width: 4),
              Text(
                'FLUID WRAPPER ACTIVE',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: FluidVideoEmbedWrapperPanelTokens.success,
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
      spacing: FluidVideoEmbedWrapperPanelTokens.sm,
      runSpacing: FluidVideoEmbedWrapperPanelTokens.sm,
      children: _ratioOptions.entries.map((entry) {
        final isSelected = _aspectRatioLabel == entry.key;
        return ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          child: ChoiceChip(
            label: Text(entry.key),
            selected: isSelected,
            selectedColor: FluidVideoEmbedWrapperPanelTokens.brandPrimary.withValues(alpha: 0.2),
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
        color: FluidVideoEmbedWrapperPanelTokens.lightBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: FluidVideoEmbedWrapperPanelTokens.lightOutline.withValues(alpha: 0.2),
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
                  color: FluidVideoEmbedWrapperPanelTokens.brandPrimary.withValues(alpha: 0.4),
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
                          FluidVideoEmbedWrapperPanelTokens.brandPrimary.withValues(alpha: 0.6),
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
                            FluidVideoEmbedWrapperPanelTokens.brandPrimary,
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
        horizontal: FluidVideoEmbedWrapperPanelTokens.md,
        vertical: FluidVideoEmbedWrapperPanelTokens.sm,
      ),
      decoration: BoxDecoration(
        color: FluidVideoEmbedWrapperPanelTokens.lightBackground,
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
          FluidVideoEmbedWrapperPanelTokens.hGapSm,
          Expanded(
            child: Slider(
              value: _playbackProgress,
              onChanged: (val) {
                setState(() {
                  _playbackProgress = val;
                });
              },
              activeColor: FluidVideoEmbedWrapperPanelTokens.brandPrimary,
            ),
          ),
          FluidVideoEmbedWrapperPanelTokens.hGapSm,
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
      padding: const EdgeInsets.all(FluidVideoEmbedWrapperPanelTokens.sm),
      decoration: BoxDecoration(
        color: FluidVideoEmbedWrapperPanelTokens.lightBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.aspect_ratio_rounded,
            color: FluidVideoEmbedWrapperPanelTokens.brandPrimary,
            size: 16,
          ),
          FluidVideoEmbedWrapperPanelTokens.hGapSm,
          Expanded(
            child: Text(
              'Enforces responsive aspect ratio preservation to eradicate anamorphic stretching across mobile & ultrawide viewports.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                    color: FluidVideoEmbedWrapperPanelTokens.lightOutline,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// File-Local Standalone Design Tokens & Constants
// ============================================================================
abstract final class FluidVideoEmbedWrapperPanelTokens {
  // Brand & Semantic Color Tokens
  static const Color brandPrimary = Color(0xFF2E86C1);
  static const Color onBrandPrimary = Color(0xFFFFFFFF);
  static const Color brandPrimaryContainer = Color(0xFFD6EAF8);
  static const Color onBrandPrimaryContainer = Color(0xFF1B4F72);
  static const Color brandPrimaryHoverOverlay = Color(0x1F2E86C1);
  static const Color brandPrimaryActiveOverlay = Color(0x3D2E86C1);

  static const Color primary = brandPrimary;
  static const Color primarySeed = Color(0xFF6750A4);
  static const Color secondarySeed = Color(0xFF625B71);
  static const Color tertiarySeed = Color(0xFF7D5260);
  static const Color neutralSeed = Color(0xFF605D62);

  static const Color success = Color(0xFF2E7D32);
  static const Color onSuccess = Color(0xFFFFFFFF);
  static const Color successContainer = Color(0xFFD0F8CE);
  static const Color onSuccessContainer = Color(0xFF002204);

  static const Color warning = Color(0xFFED6C02);
  static const Color onWarning = Color(0xFFFFFFFF);
  static const Color warningContainer = Color(0xFFFFDCC6);
  static const Color onWarningContainer = Color(0xFF341100);

  static const Color info = Color(0xFF0288D1);
  static const Color onInfo = Color(0xFFFFFFFF);
  static const Color infoContainer = Color(0xFFCBE6FF);
  static const Color onInfoContainer = Color(0xFF001E30);

  static const Color lightPrimary = Color(0xFF6750A4);
  static const Color lightOnPrimary = Color(0xFFFFFFFF);
  static const Color lightPrimaryContainer = Color(0xFFEADDFF);
  static const Color lightOnPrimaryContainer = Color(0xFF21005D);

  static const Color lightSecondary = Color(0xFF625B71);
  static const Color lightOnSecondary = Color(0xFFFFFFFF);
  static const Color lightSecondaryContainer = Color(0xFFE8DEF8);
  static const Color lightOnSecondaryContainer = Color(0xFF1D192B);

  static const Color lightTertiary = Color(0xFF7D5260);
  static const Color lightOnTertiary = Color(0xFFFFFFFF);
  static const Color lightTertiaryContainer = Color(0xFFFFD8E4);
  static const Color lightOnTertiaryContainer = Color(0xFF31111D);

  static const Color error = Color(0xFFB3261E);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFF9DEDC);
  static const Color onErrorContainer = Color(0xFF410E0B);
  static const Color lightError = Color(0xFFB3261E);
  static const Color lightOnError = Color(0xFFFFFFFF);
  static const Color lightErrorContainer = Color(0xFFF9DEDC);
  static const Color lightOnErrorContainer = Color(0xFF410E0B);

  static const Color lightBackground = Color(0xFFFEF7FF);
  static const Color lightOnBackground = Color(0xFF1D1B20);
  static const Color lightSurface = Color(0xFFFEF7FF);
  static const Color lightOnSurface = Color(0xFF1D1B20);
  static const Color lightSurfaceVariant = Color(0xFFE7E0EC);
  static const Color lightOnSurfaceVariant = Color(0xFF49454F);
  static const Color lightOutline = Color(0xFF79747E);
  static const Color lightOutlineVariant = Color(0xFFCAC4D0);

  static const Color neutralLight = Color(0xFFF5F5F5);
  static const Color neutralDark = Color(0xFF212121);

  // Elevation Tokens
  static const double level0 = 0.0;
  static const double level1 = 1.0;
  static const double level2 = 3.0;
  static const double level3 = 6.0;
  static const double level4 = 8.0;
  static const double level5 = 12.0;

  // Spacing & Layout Tokens (4dp Metric Grid)
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double mdSm = 12.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;

  static const EdgeInsets paddingXs = EdgeInsets.all(xs);
  static const EdgeInsets paddingSm = EdgeInsets.all(sm);
  static const EdgeInsets paddingMd = EdgeInsets.all(md);
  static const EdgeInsets paddingLg = EdgeInsets.all(lg);
  static const EdgeInsets paddingXl = EdgeInsets.all(xl);

  static const EdgeInsets paddingHorizontalSm = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets paddingHorizontalMd = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets paddingHorizontalLg = EdgeInsets.symmetric(horizontal: lg);

  static const EdgeInsets paddingVerticalSm = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets paddingVerticalMd = EdgeInsets.symmetric(vertical: md);

  static const Widget vGapXs = SizedBox(height: xs);
  static const Widget vGapSm = SizedBox(height: sm);
  static const Widget vGapMd = SizedBox(height: md);
  static const Widget vGapLg = SizedBox(height: lg);
  static const Widget vGapXl = SizedBox(height: xl);

  static const Widget hGapXs = SizedBox(width: xs);
  static const Widget hGapSm = SizedBox(width: sm);
  static const Widget hGapMd = SizedBox(width: md);
  static const Widget hGapLg = SizedBox(width: lg);
  static const Widget hGapXl = SizedBox(width: xl);
}

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: FluidVideoEmbedWrapperPanel(),
          ),
        ),
      ),
    ),
  );
}
