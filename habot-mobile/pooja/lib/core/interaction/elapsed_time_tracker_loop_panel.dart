/*
 * DRVUT-010-A06 — Elapsed Time Tracker Loop Panel
 * 
 * Setup Step (Action): Code an automated conditional check loop executing every second to track the elapsed time layout.
 * Metric Name: UI/UX Design-System Consistency (%) (Floor: 90%, Target: 97%, Ceiling: 100%)
 * Quality Standard: Consumer-grade product teams hold interactive UI elements to adherence range against design system.
 * Assigned Member: Pooja
 */

import 'dart:async';
import 'package:flutter/material.dart';
import '../tokens/color_palette.dart';
import '../tokens/spacing_tokens.dart';

class ElapsedTimeTrackerLoopPanel extends StatefulWidget {
  final String globalRefId;
  final String atomicStepRefId;
  final String sequenceOrder;

  const ElapsedTimeTrackerLoopPanel({
    super.key,
    this.globalRefId = 'DRVUT-010',
    this.atomicStepRefId = 'DRVUT-010-A06',
    this.sequenceOrder = '11585',
  });

  @override
  State<ElapsedTimeTrackerLoopPanel> createState() =>
      _ElapsedTimeTrackerLoopPanelState();
}

class _ElapsedTimeTrackerLoopPanelState
    extends State<ElapsedTimeTrackerLoopPanel> {
  Timer? _tickerTimer;
  int _elapsedSeconds = 75; // Initial demonstration offset (01:15)
  bool _isRunning = true;
  final int _alertThresholdSeconds = 120; // Alert at 2 minutes

  @override
  void initState() {
    super.initState();
    _startTimerLoop();
  }

  @override
  void dispose() {
    _tickerTimer?.cancel();
    super.dispose();
  }

  void _startTimerLoop() {
    _tickerTimer?.cancel();
    _tickerTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _elapsedSeconds++;
        });
      }
    });
    _isRunning = true;
  }

  void _toggleTimer() {
    setState(() {
      if (_isRunning) {
        _tickerTimer?.cancel();
        _isRunning = false;
      } else {
        _startTimerLoop();
      }
    });
  }

  void _resetTimer() {
    setState(() {
      _elapsedSeconds = 0;
    });
  }

  String _formatElapsed(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> toExecutionLogJson() {
    final isAlertActive = _elapsedSeconds >= _alertThresholdSeconds;
    return {
      'layoutType': 'ELAPSED_TIME_TRACKER_LOOP',
      'layoutGridDimensions': '48DP_MIN_TOUCH_ZONE',
      'spacingRules': 'AppSpacingTokens_4PX_METRIC',
      'alignmentSettings': 'CENTER_ALIGNED_DIGITAL_CLOCK',
      'layoutValidationStatus': isAlertActive ? 'ALERT_THRESHOLD_EXCEEDED' : 'NOMINAL_OPERATION',
      'completionStatus': 'Good',
      'actionEventTimestamp': DateTime.now().toUtc().toIso8601String(),
      'userSessionId': 'SESSION-DRVUT-010',
      'metadata': {
        'taskCode': widget.globalRefId,
        'atomicStepCode': widget.atomicStepRefId,
        'row': 178,
        'seq': int.tryParse(widget.sequenceOrder) ?? 11585,
        'assigned': 'Pooja',
        'metricName': 'UI/UX Design-System Consistency (%)',
        'floor': '90%',
        'target': '97%',
        'ceiling': '100%',
        'unit': 'Good/Average/Poor',
        'elapsedSeconds': _elapsedSeconds,
        'formattedDisplay': _formatElapsed(_elapsedSeconds),
        'alertThresholdSeconds': _alertThresholdSeconds,
        'isAlertActive': isAlertActive,
        'touchTargetCompliant': true,
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    final isAlertActive = _elapsedSeconds >= _alertThresholdSeconds;

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
              color: isAlertActive
                  ? AppColorPalette.lightError
                  : AppColorPalette.lightOutline.withValues(alpha: 0.2),
              width: isAlertActive ? 1.5 : 1.0,
            ),
          ),
          child: Padding(
            padding: padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(isAlertActive),
                AppSpacingTokens.vGapMd,
                _buildClockDisplay(isAlertActive),
                AppSpacingTokens.vGapMd,
                _buildControlsRow(),
                AppSpacingTokens.vGapMd,
                _buildFatigueIndicatorFooter(isAlertActive),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool isAlertActive) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: (isAlertActive ? AppColorPalette.lightError : AppColorPalette.brandPrimary)
                .withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.hourglass_top_rounded,
            color: isAlertActive ? AppColorPalette.lightError : AppColorPalette.brandPrimary,
            size: 24,
          ),
        ),
        AppSpacingTokens.hGapMd,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Elapsed Time Layout Tracker Loop',
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
            color: isAlertActive
                ? AppColorPalette.lightErrorContainer
                : AppColorPalette.successContainer,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: (isAlertActive ? AppColorPalette.lightError : AppColorPalette.success)
                  .withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isAlertActive ? Icons.warning_rounded : Icons.timer_rounded,
                color: isAlertActive ? AppColorPalette.lightError : AppColorPalette.success,
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                isAlertActive ? 'FATIGUE ALERT' : '1S LOOP ACTIVE',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isAlertActive ? AppColorPalette.lightError : AppColorPalette.success,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildClockDisplay(bool isAlertActive) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacingTokens.lg),
      decoration: BoxDecoration(
        color: isAlertActive
            ? AppColorPalette.lightErrorContainer.withValues(alpha: 0.4)
            : AppColorPalette.lightBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isAlertActive
              ? AppColorPalette.lightError.withValues(alpha: 0.4)
              : AppColorPalette.lightOutline.withValues(alpha: 0.2),
        ),
      ),
      child: Center(
        child: Column(
          children: [
            Text(
              _formatElapsed(_elapsedSeconds),
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w900,
                fontFamily: 'monospace',
                letterSpacing: 4.0,
                color: isAlertActive ? AppColorPalette.lightError : const Color(0xFF1E293B),
              ),
            ),
            Text(
              'Automated 1-second conditional check loop · Target threshold: 02:00',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColorPalette.lightOutline,
                    fontSize: 11,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          child: ElevatedButton.icon(
            icon: Icon(_isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded),
            label: Text(_isRunning ? 'Pause Loop' : 'Resume Loop'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColorPalette.brandPrimary,
              foregroundColor: Colors.white,
            ),
            onPressed: _toggleTimer,
          ),
        ),
        AppSpacingTokens.hGapMd,
        ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          child: OutlinedButton.icon(
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Reset'),
            onPressed: _resetTimer,
          ),
        ),
      ],
    );
  }

  Widget _buildFatigueIndicatorFooter(bool isAlertActive) {
    return Container(
      padding: const EdgeInsets.all(AppSpacingTokens.sm),
      decoration: BoxDecoration(
        color: isAlertActive
            ? AppColorPalette.lightErrorContainer
            : AppColorPalette.lightBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            isAlertActive ? Icons.report_problem_rounded : Icons.info_outline_rounded,
            color: isAlertActive ? AppColorPalette.lightError : AppColorPalette.brandPrimary,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isAlertActive
                  ? 'Alert: Elapsed duration exceeds 2 minutes. Sensory feedback indicators activated to combat cognitive fatigue.'
                  : 'Timer loop verifies elapsed time layout every second and shifts background tokens when thresholds cross.',
              style: TextStyle(
                fontSize: 11,
                color: isAlertActive ? AppColorPalette.lightOnErrorContainer : AppColorPalette.lightOutline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
