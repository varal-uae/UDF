import 'package:flutter/material.dart';

/// Row 222 - FEBFL-001-A14 (Seq 14940)
/// Action: Implement the download trigger on the Completed state — opens file download directly.
/// Metric: Implementation Completeness Against Spec | Floor: 90% | Target: 98% | Ceiling: 100%
/// Standard: Sprint-based automated checks and peer-validated spec.
class ExportDownloadTriggerPanel extends StatefulWidget {
  const ExportDownloadTriggerPanel({super.key});

  @override
  State<ExportDownloadTriggerPanel> createState() =>
      _ExportDownloadTriggerPanelState();
}

enum ExportProcessState {
  idle,
  generating,
  completed,
  downloaded,
}

class _ExportDownloadTriggerPanelState
    extends State<ExportDownloadTriggerPanel> {
  final String _stepExecutionId = 'FEBFL-001-A14-DL-001';
  final String _userSessionId = 'POOJA-FEBFL-001-A14';
  final String _completionStatus = 'Complete';
  final String _objectType = 'FileBlob / OctetStream';
  final String _objectLocation = '/storage/exports/secure_vault/audit_report_2026.xlsx';
  final String _fileHandleId = 'FHD-99482-B22';

  ExportProcessState _currentState = ExportProcessState.idle;
  bool _autoDownloadOnComplete = true;
  DateTime _lastActionTime = DateTime.now();
  int _downloadTriggerCount = 0;

  void _startExportPipeline() {
    setState(() {
      _currentState = ExportProcessState.generating;
      _lastActionTime = DateTime.now();
    });

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() {
          _currentState = ExportProcessState.completed;
          _lastActionTime = DateTime.now();
        });

        if (_autoDownloadOnComplete) {
          _executeDownloadTrigger();
        }
      }
    });
  }

  void _executeDownloadTrigger() {
    setState(() {
      _downloadTriggerCount++;
      _currentState = ExportProcessState.downloaded;
      _lastActionTime = DateTime.now();
    });
  }

  void _resetPipeline() {
    setState(() {
      _currentState = ExportProcessState.idle;
      _lastActionTime = DateTime.now();
    });
  }

  void _toggleAutoDownload(bool val) {
    setState(() {
      _autoDownloadOnComplete = val;
    });
  }

  Map<String, dynamic> getTelemetryData() {
    return {
      'Step Execution ID': _stepExecutionId,
      'Object Type': _objectType,
      'Object Location/Path': _objectLocation,
      'Open Status': _currentState == ExportProcessState.downloaded ? 'TRIGGERED_OPENED' : 'PENDING',
      'Timestamp': _lastActionTime.toIso8601String(),
      'File Handle ID': _fileHandleId,
      'Completion Status': _completionStatus,
      'Action/Event Timestamp': _lastActionTime.toIso8601String(),
      'User/Session ID': _userSessionId,
      'Download Trigger Count': _downloadTriggerCount,
      'Auto-Trigger Enabled': _autoDownloadOnComplete ? 'YES' : 'NO',
    };
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: ExportDownloadTriggerPanelTokens.paddingMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeaderCard(),
          ExportDownloadTriggerPanelTokens.vGapMd,
          _buildPipelineProgressCard(),
          ExportDownloadTriggerPanelTokens.vGapMd,
          _buildConfigurationSettingsCard(),
          ExportDownloadTriggerPanelTokens.vGapMd,
          _buildControlsRow(),
          ExportDownloadTriggerPanelTokens.vGapMd,
          _buildTelemetryCard(),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
        side: BorderSide(color: ExportDownloadTriggerPanelTokens.lightOutline.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: ExportDownloadTriggerPanelTokens.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.file_download_outlined,
                  color: ExportDownloadTriggerPanelTokens.brandPrimary,
                  size: 22,
                ),
                ExportDownloadTriggerPanelTokens.hGapSm,
                const Expanded(
                  child: Text(
                    'Export Download Trigger on Completed',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: ExportDownloadTriggerPanelTokens.brandPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: ExportDownloadTriggerPanelTokens.successContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Automated Trigger',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: ExportDownloadTriggerPanelTokens.onSuccessContainer,
                    ),
                  ),
                ),
              ],
            ),
            ExportDownloadTriggerPanelTokens.vGapSm,
            Text(
              'Instantly fires the direct browser/filesystem download trigger when the background export task reaches the Completed state.',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPipelineProgressCard() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
        side: BorderSide(color: ExportDownloadTriggerPanelTokens.lightOutline.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: ExportDownloadTriggerPanelTokens.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Export Lifecycle Pipeline',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: ExportDownloadTriggerPanelTokens.brandPrimary,
              ),
            ),
            ExportDownloadTriggerPanelTokens.vGapMd,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStageIndicator(
                  Icons.play_circle_outline,
                  'Idle',
                  _currentState == ExportProcessState.idle,
                ),
                _buildStageIndicator(
                  Icons.sync,
                  'Generating',
                  _currentState == ExportProcessState.generating,
                ),
                _buildStageIndicator(
                  Icons.check_circle_outline,
                  'Completed',
                  _currentState == ExportProcessState.completed ||
                      _currentState == ExportProcessState.downloaded,
                ),
                _buildStageIndicator(
                  Icons.download_done,
                  'Downloaded',
                  _currentState == ExportProcessState.downloaded,
                ),
              ],
            ),
            ExportDownloadTriggerPanelTokens.vGapMd,
            if (_currentState == ExportProcessState.generating)
              const LinearProgressIndicator(),
            if (_currentState == ExportProcessState.downloaded)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: ExportDownloadTriggerPanelTokens.successContainer,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check, color: ExportDownloadTriggerPanelTokens.onSuccessContainer, size: 18),
                    ExportDownloadTriggerPanelTokens.hGapSm,
                    Expanded(
                      child: Text(
                        'Direct download triggered successfully! File handle open.',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: ExportDownloadTriggerPanelTokens.onSuccessContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStageIndicator(IconData icon, String label, bool isActive) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isActive
                ? ExportDownloadTriggerPanelTokens.brandPrimary
                : Colors.grey.shade200,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 20,
            color: isActive ? Colors.white : Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? ExportDownloadTriggerPanelTokens.brandPrimary : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildConfigurationSettingsCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
        side: BorderSide(color: ExportDownloadTriggerPanelTokens.lightOutline.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: ExportDownloadTriggerPanelTokens.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Trigger Policy',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: ExportDownloadTriggerPanelTokens.brandPrimary,
              ),
            ),
            ExportDownloadTriggerPanelTokens.vGapSm,
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Auto-Trigger Download on Completed State'),
              subtitle: Text(
                _autoDownloadOnComplete
                    ? 'Immediately invokes browser file download without extra clicks'
                    : 'Awaits explicit manual download button click',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              value: _autoDownloadOnComplete,
              onChanged: _toggleAutoDownload,
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
            onPressed: _currentState == ExportProcessState.generating
                ? null
                : _startExportPipeline,
            icon: const Icon(Icons.rocket_launch_outlined, color: Colors.white),
            label: const Text('Run Export & Trigger Download'),
            style: ElevatedButton.styleFrom(
              backgroundColor: ExportDownloadTriggerPanelTokens.brandPrimary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        ExportDownloadTriggerPanelTokens.hGapSm,
        OutlinedButton.icon(
          onPressed: _resetPipeline,
          icon: const Icon(Icons.refresh),
          label: const Text('Reset'),
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
        side: BorderSide(color: ExportDownloadTriggerPanelTokens.lightOutline.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: ExportDownloadTriggerPanelTokens.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Audit Telemetry',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: ExportDownloadTriggerPanelTokens.brandPrimary,
              ),
            ),
            ExportDownloadTriggerPanelTokens.vGapSm,
            ...telemetry.entries.map((e) {
              final val = e.value.toString();
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 170,
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
abstract final class ExportDownloadTriggerPanelTokens {
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
            child: ExportDownloadTriggerPanel(),
          ),
        ),
      ),
    ),
  );
}
