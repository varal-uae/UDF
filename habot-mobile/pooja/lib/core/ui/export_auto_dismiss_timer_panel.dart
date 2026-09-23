import 'dart:async';
import 'package:flutter/material.dart';

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
      padding: ExportAutoDismissTimerPanelTokens.paddingMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeaderCard(),
          ExportAutoDismissTimerPanelTokens.vGapMd,
          _buildExportNotificationBanner(),
          ExportAutoDismissTimerPanelTokens.vGapMd,
          _buildTimerConfigurationCard(),
          ExportAutoDismissTimerPanelTokens.vGapMd,
          _buildControlsRow(),
          ExportAutoDismissTimerPanelTokens.vGapMd,
          _buildTelemetryCard(),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
        side: BorderSide(color: ExportAutoDismissTimerPanelTokens.lightOutline.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: ExportAutoDismissTimerPanelTokens.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.timer_outlined,
                  color: ExportAutoDismissTimerPanelTokens.brandPrimary,
                  size: 22,
                ),
                ExportAutoDismissTimerPanelTokens.hGapSm,
                const Expanded(
                  child: Text(
                    'Export Auto-Dismiss Timer',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: ExportAutoDismissTimerPanelTokens.brandPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: ExportAutoDismissTimerPanelTokens.infoContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$_configuredDelaySeconds s Delay',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: ExportAutoDismissTimerPanelTokens.onInfoContainer,
                    ),
                  ),
                ),
              ],
            ),
            ExportAutoDismissTimerPanelTokens.vGapSm,
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
          padding: ExportAutoDismissTimerPanelTokens.paddingLg,
          child: Column(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.grey.shade500, size: 36),
              ExportAutoDismissTimerPanelTokens.vGapSm,
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
              ExportAutoDismissTimerPanelTokens.vGapMd,
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
        side: BorderSide(color: ExportAutoDismissTimerPanelTokens.success, width: 1.5),
      ),
      child: Padding(
        padding: ExportAutoDismissTimerPanelTokens.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: ExportAutoDismissTimerPanelTokens.successContainer,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.file_download_done_rounded,
                    color: ExportAutoDismissTimerPanelTokens.onSuccessContainer,
                    size: 20,
                  ),
                ),
                ExportAutoDismissTimerPanelTokens.hGapSm,
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
            ExportAutoDismissTimerPanelTokens.vGapSm,
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _isTimerPaused ? ExportAutoDismissTimerPanelTokens.warning : ExportAutoDismissTimerPanelTokens.success,
                      ),
                      minHeight: 6,
                    ),
                  ),
                ),
                ExportAutoDismissTimerPanelTokens.hGapSm,
                Text(
                  _isTimerPaused ? 'PAUSED' : '${_remainingSeconds}s',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: _isTimerPaused ? ExportAutoDismissTimerPanelTokens.warning : ExportAutoDismissTimerPanelTokens.success,
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
        side: BorderSide(color: ExportAutoDismissTimerPanelTokens.lightOutline.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: ExportAutoDismissTimerPanelTokens.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Configurable Delay Options',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: ExportAutoDismissTimerPanelTokens.brandPrimary,
              ),
            ),
            ExportAutoDismissTimerPanelTokens.vGapSm,
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
                            ? ExportAutoDismissTimerPanelTokens.brandPrimary
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
                  ? ExportAutoDismissTimerPanelTokens.brandPrimary
                  : ExportAutoDismissTimerPanelTokens.warning,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        ExportAutoDismissTimerPanelTokens.hGapSm,
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
        side: BorderSide(color: ExportAutoDismissTimerPanelTokens.lightOutline.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: ExportAutoDismissTimerPanelTokens.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Audit Telemetry',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: ExportAutoDismissTimerPanelTokens.brandPrimary,
              ),
            ),
            ExportAutoDismissTimerPanelTokens.vGapSm,
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

// ============================================================================
// File-Local Standalone Design Tokens & Constants
// ============================================================================
abstract final class ExportAutoDismissTimerPanelTokens {
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
            child: ExportAutoDismissTimerPanel(),
          ),
        ),
      ),
    ),
  );
}
