import 'dart:async';
import 'package:flutter/material.dart';
import '../tokens/color_palette.dart';
import '../tokens/spacing_tokens.dart';

/// Row 221 - FEBFL-001-A10 (Seq 14936)
/// Action: Implement auto-dismiss for completed exports after a configurable delay (e.g. 5 seconds).
/// Metric: Implementation Completeness Against Spec | Floor: 90% | Target: 98% | Ceiling: 100%
/// Standard: Sprint-based automated checks and peer-validated spec.
class ExportAutoDismissTimerPanel extends StatefulWidget {
  const ExportAutoDismissTimerPanel({super.key});

  @override
  State<ExportAutoDismissTimerPanel> createState() =>
      _ExportAutoDismissTimerPanelState();
}

class _ExportAutoDismissTimerPanelState
    extends State<ExportAutoDismissTimerPanel> {
  final String _stepExecutionId = 'FEBFL-001-A10-DISMISS-001';
  final String _userSessionId = 'POOJA-FEBFL-001-A10';
  final String _completionStatus = 'Complete';
  final String _exportFormat = 'PDF / XLSX (Consolidated Report)';
  final String _exportPath = '/downloads/exports/2026/q3_executive_summary.pdf';

  int _configuredDelaySeconds = 5;
  int _remainingSeconds = 5;
  bool _isToastVisible = true;
  bool _isTimerPaused = false;
  Timer? _countdownTimer;
  DateTime _lastEventTimestamp = DateTime.now();

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    setState(() {
      _remainingSeconds = _configuredDelaySeconds;
      _isToastVisible = true;
      _isTimerPaused = false;
      _lastEventTimestamp = DateTime.now();
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isTimerPaused) {
        if (_remainingSeconds > 1) {
          setState(() {
            _remainingSeconds--;
          });
        } else {
          timer.cancel();
          setState(() {
            _remainingSeconds = 0;
            _isToastVisible = false;
            _lastEventTimestamp = DateTime.now();
          });
        }
      }
    });
  }

  void _togglePauseTimer() {
    setState(() {
      _isTimerPaused = !_isTimerPaused;
      _lastEventTimestamp = DateTime.now();
    });
  }

  void _dismissToastImmediately() {
    _countdownTimer?.cancel();
    setState(() {
      _isToastVisible = false;
      _remainingSeconds = 0;
      _lastEventTimestamp = DateTime.now();
    });
  }

  void _setDelay(int seconds) {
    setState(() {
      _configuredDelaySeconds = seconds;
    });
    _startCountdown();
  }

  Map<String, dynamic> getTelemetryData() {
    return {
      'Step Execution ID': _stepExecutionId,
      'Export Format': _exportFormat,
      'Export Status': _isToastVisible ? 'DISPLAYED_COUNTING_DOWN' : 'AUTO_DISMISSED',
      'Export Path': _exportPath,
      'Export Timestamp': _lastEventTimestamp.toIso8601String(),
      'File Size': '3.2 MB',
      'Completion Status': _completionStatus,
      'Action/Event Timestamp': _lastEventTimestamp.toIso8601String(),
      'User/Session ID': _userSessionId,
      'Configured Auto-Dismiss Delay': '$_configuredDelaySeconds seconds',
      'Remaining Countdown': '$_remainingSeconds seconds',
      'Timer Status': _isTimerPaused ? 'PAUSED_ON_HOVER' : 'ACTIVE',
    };
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppSpacingTokens.paddingMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeaderCard(),
          AppSpacingTokens.vGapMd,
          _buildExportNotificationBanner(),
          AppSpacingTokens.vGapMd,
          _buildTimerConfigurationCard(),
          AppSpacingTokens.vGapMd,
          _buildControlsRow(),
          AppSpacingTokens.vGapMd,
          _buildTelemetryCard(),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
        side: BorderSide(color: AppColorPalette.lightOutline.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: AppSpacingTokens.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.timer_outlined,
                  color: AppColorPalette.brandPrimary,
                  size: 22,
                ),
                AppSpacingTokens.hGapSm,
                const Expanded(
                  child: Text(
                    'Export Auto-Dismiss Timer',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColorPalette.brandPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColorPalette.infoContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$_configuredDelaySeconds s Delay',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColorPalette.onInfoContainer,
                    ),
                  ),
                ),
              ],
            ),
            AppSpacingTokens.vGapSm,
            Text(
              'Automatically dismisses completed export notification cards after a configurable countdown, with pause-on-hover support.',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportNotificationBanner() {
    if (!_isToastVisible) {
      return Card(
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(8.0)),
          side: BorderSide(color: Colors.grey.shade300),
        ),
        color: Colors.grey.shade100,
        child: Padding(
          padding: AppSpacingTokens.paddingLg,
          child: Column(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.grey.shade500, size: 36),
              AppSpacingTokens.vGapSm,
              Text(
                'Notification Auto-Dismissed',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Export completed and successfully filed to storage.',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
              AppSpacingTokens.vGapMd,
              OutlinedButton.icon(
                onPressed: _startCountdown,
                icon: const Icon(Icons.replay),
                label: const Text('Simulate New Export Completion'),
              ),
            ],
          ),
        ),
      );
    }

    final progress = _remainingSeconds / _configuredDelaySeconds;

    return Card(
      elevation: 2,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
        side: BorderSide(color: AppColorPalette.success, width: 1.5),
      ),
      child: Padding(
        padding: AppSpacingTokens.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: AppColorPalette.successContainer,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.file_download_done_rounded,
                    color: AppColorPalette.onSuccessContainer,
                    size: 20,
                  ),
                ),
                AppSpacingTokens.hGapSm,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Report Export Ready',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'q3_executive_summary.pdf (3.2 MB)',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  tooltip: 'Dismiss Now',
                  onPressed: _dismissToastImmediately,
                ),
              ],
            ),
            AppSpacingTokens.vGapSm,
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _isTimerPaused ? AppColorPalette.warning : AppColorPalette.success,
                      ),
                      minHeight: 6,
                    ),
                  ),
                ),
                AppSpacingTokens.hGapSm,
                Text(
                  _isTimerPaused ? 'PAUSED' : '${_remainingSeconds}s',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: _isTimerPaused ? AppColorPalette.warning : AppColorPalette.success,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimerConfigurationCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
        side: BorderSide(color: AppColorPalette.lightOutline.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: AppSpacingTokens.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Configurable Delay Options',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColorPalette.brandPrimary,
              ),
            ),
            AppSpacingTokens.vGapSm,
            Row(
              children: [3, 5, 8, 10].map((delay) {
                final isSelected = _configuredDelaySeconds == delay;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: OutlinedButton(
                      onPressed: () => _setDelay(delay),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: isSelected
                            ? AppColorPalette.brandPrimary
                            : null,
                        foregroundColor: isSelected ? Colors.white : Colors.black87,
                        side: BorderSide(
                          color: isSelected
                              ? Colors.transparent
                              : Colors.grey.shade300,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      child: Text(
                        '${delay}s',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlsRow() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isToastVisible ? _togglePauseTimer : null,
            icon: Icon(_isTimerPaused ? Icons.play_arrow : Icons.pause),
            label: Text(_isTimerPaused ? 'Resume Auto-Dismiss' : 'Pause (Simulate Hover)'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _isTimerPaused
                  ? AppColorPalette.brandPrimary
                  : AppColorPalette.warning,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        AppSpacingTokens.hGapSm,
        OutlinedButton.icon(
          onPressed: _startCountdown,
          icon: const Icon(Icons.replay),
          label: const Text('Restart'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildTelemetryCard() {
    final telemetry = getTelemetryData();
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
        side: BorderSide(color: AppColorPalette.lightOutline.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: AppSpacingTokens.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Audit Telemetry',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColorPalette.brandPrimary,
              ),
            ),
            AppSpacingTokens.vGapSm,
            ...telemetry.entries.map((e) {
              final val = e.value.toString();
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 190,
                      child: Text(
                        '${e.key}:',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        val,
                        style: const TextStyle(
                          fontSize: 11,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
