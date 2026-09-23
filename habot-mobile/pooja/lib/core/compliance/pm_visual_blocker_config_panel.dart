import 'package:flutter/material.dart';

/// Row 219 - FCSES-022-A11 (Seq 14894)
/// Action: Configure the PM tool to show a clear visual blocker for non-zero scores.
/// Metric: Rule/Threshold Enforcement Consistency | Floor: <95% | Target: 99-100% | Ceiling: 100%
/// Standard: ISO 9001:2015 Quality Management - Process Control Clause 8.5
class PmVisualBlockerConfigPanel extends StatefulWidget {
  const PmVisualBlockerConfigPanel({super.key});

  @override
  State<PmVisualBlockerConfigPanel> createState() =>
      _PmVisualBlockerConfigPanelState();
}

class _PmVisualBlockerConfigPanelState
    extends State<PmVisualBlockerConfigPanel> {
  final String _configParam = 'PM_DEFECT_VISUAL_BLOCKER_RULE';
  final String _completionStatus = 'Pass';
  final String _clauseStandard = 'ISO 9001:2015 Clause 8.5';
  final String _userSessionId = 'POOJA-FCSES-022-A11';

  bool _isVisualBlockerEnabled = true;
  int _currentDefectScore = 3;
  String _previousSetting = 'ENABLED';
  DateTime _lastConfigTime = DateTime.now();
  final List<String> _changeLog = [
    'Initial Rule Config: Zero Tolerance Mode activated',
    'Threshold baseline mapped to Clause 8.5 requirements',
  ];

  void _toggleBlockerRule(bool value) {
    setState(() {
      _previousSetting = _isVisualBlockerEnabled ? 'ENABLED' : 'DISABLED';
      _isVisualBlockerEnabled = value;
      _lastConfigTime = DateTime.now();
      _changeLog.insert(
        0,
        '${_lastConfigTime.toIso8601String().substring(11, 19)}: Blocker setting changed to ${value ? 'ENABLED' : 'DISABLED'}',
      );
    });
  }

  void _updateDefectScore(int score) {
    setState(() {
      _currentDefectScore = score;
      _lastConfigTime = DateTime.now();
      _changeLog.insert(
        0,
        '${_lastConfigTime.toIso8601String().substring(11, 19)}: Defect score adjusted to $score',
      );
    });
  }

  Map<String, dynamic> getTelemetryData() {
    return {
      'Configuration Parameter': _configParam,
      'Current Setting': _isVisualBlockerEnabled ? 'ENABLED' : 'DISABLED',
      'Previous Setting': _previousSetting,
      'Change Log': '${_changeLog.length} audit revisions registered',
      'Configuration Timestamp': _lastConfigTime.toIso8601String(),
      'Completion Status': _completionStatus,
      'Action/Event Timestamp': _lastConfigTime.toIso8601String(),
      'User/Session ID': _userSessionId,
      'Defect Score': _currentDefectScore,
      'Blocker State': (_isVisualBlockerEnabled && _currentDefectScore > 0) ? 'BLOCKER_ACTIVATED' : 'PROCEED_ALLOWED',
      'Compliance Standard': _clauseStandard,
    };
  }

  @override
  Widget build(BuildContext context) {
    final isBlockerActive = _isVisualBlockerEnabled && _currentDefectScore > 0;

    return SingleChildScrollView(
      padding: PmVisualBlockerConfigPanelTokens.paddingMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeaderCard(),
          PmVisualBlockerConfigPanelTokens.vGapMd,
          if (isBlockerActive) _buildVisualBlockerBanner(),
          PmVisualBlockerConfigPanelTokens.vGapMd,
          _buildConfigurationSettingsCard(),
          PmVisualBlockerConfigPanelTokens.vGapMd,
          _buildDefectSimulatorCard(),
          PmVisualBlockerConfigPanelTokens.vGapMd,
          _buildChangeLogCard(),
          PmVisualBlockerConfigPanelTokens.vGapMd,
          _buildTelemetryCard(),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: BorderSide(color: PmVisualBlockerConfigPanelTokens.lightOutline.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: PmVisualBlockerConfigPanelTokens.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.gavel_rounded,
                  color: PmVisualBlockerConfigPanelTokens.brandPrimary,
                  size: 22,
                ),
                PmVisualBlockerConfigPanelTokens.hGapSm,
                const Expanded(
                  child: Text(
                    'PM Visual Blocker Configuration',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: PmVisualBlockerConfigPanelTokens.brandPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: PmVisualBlockerConfigPanelTokens.warningContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Clause 8.5',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: PmVisualBlockerConfigPanelTokens.onWarningContainer,
                    ),
                  ),
                ),
              ],
            ),
            PmVisualBlockerConfigPanelTokens.vGapSm,
            Text(
              'Configures project management workflow to enforce zero rule-bypass tolerance by surfacing prominent visual blockers when defect scores exceed zero.',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisualBlockerBanner() {
    return Container(
      padding: PmVisualBlockerConfigPanelTokens.paddingMd,
      decoration: BoxDecoration(
        color: PmVisualBlockerConfigPanelTokens.lightErrorContainer,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: PmVisualBlockerConfigPanelTokens.lightError, width: 2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: PmVisualBlockerConfigPanelTokens.lightError,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.block, color: Colors.white, size: 24),
          ),
          PmVisualBlockerConfigPanelTokens.hGapMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'PM WORKFLOW BLOCKED',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: PmVisualBlockerConfigPanelTokens.lightOnErrorContainer,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Defect score is $_currentDefectScore (> 0). Release gating prohibits signoff until defect score reaches 0.',
                  style: const TextStyle(
                    fontSize: 12,
                    color: PmVisualBlockerConfigPanelTokens.lightOnErrorContainer,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfigurationSettingsCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: BorderSide(color: PmVisualBlockerConfigPanelTokens.lightOutline.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: PmVisualBlockerConfigPanelTokens.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Threshold Enforcement Rule',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: PmVisualBlockerConfigPanelTokens.brandPrimary,
              ),
            ),
            PmVisualBlockerConfigPanelTokens.vGapSm,
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Show Visual Blocker on Non-Zero Scores'),
              subtitle: Text(
                'Current Status: ${_isVisualBlockerEnabled ? 'Active (Strict Gate)' : 'Disabled'}',
                style: TextStyle(
                  fontSize: 12,
                  color: _isVisualBlockerEnabled
                      ? PmVisualBlockerConfigPanelTokens.success
                      : PmVisualBlockerConfigPanelTokens.warning,
                ),
              ),
              value: _isVisualBlockerEnabled,
              onChanged: _toggleBlockerRule,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefectSimulatorCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: BorderSide(color: PmVisualBlockerConfigPanelTokens.lightOutline.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: PmVisualBlockerConfigPanelTokens.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Defect Score Simulator',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: PmVisualBlockerConfigPanelTokens.brandPrimary,
              ),
            ),
            PmVisualBlockerConfigPanelTokens.vGapSm,
            Row(
              children: [
                _buildDefectButton(0, '0 (Clean)'),
                PmVisualBlockerConfigPanelTokens.hGapSm,
                _buildDefectButton(1, '1 (Minor)'),
                PmVisualBlockerConfigPanelTokens.hGapSm,
                _buildDefectButton(3, '3 (Moderate)'),
                PmVisualBlockerConfigPanelTokens.hGapSm,
                _buildDefectButton(5, '5 (Critical)'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefectButton(int score, String label) {
    final isSelected = _currentDefectScore == score;
    return Expanded(
      child: OutlinedButton(
        onPressed: () => _updateDefectScore(score),
        style: OutlinedButton.styleFrom(
          backgroundColor: isSelected
              ? (score == 0 ? PmVisualBlockerConfigPanelTokens.success : PmVisualBlockerConfigPanelTokens.lightError)
              : null,
          foregroundColor: isSelected ? Colors.white : Colors.black87,
          side: BorderSide(
            color: isSelected
                ? Colors.transparent
                : Colors.grey.shade300,
          ),
          padding: const EdgeInsets.symmetric(vertical: 10),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildChangeLogCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: BorderSide(color: PmVisualBlockerConfigPanelTokens.lightOutline.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: PmVisualBlockerConfigPanelTokens.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Configuration Audit Log',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: PmVisualBlockerConfigPanelTokens.brandPrimary,
              ),
            ),
            PmVisualBlockerConfigPanelTokens.vGapSm,
            ..._changeLog.take(3).map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Text(
                  '• $entry',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTelemetryCard() {
    final telemetry = getTelemetryData();
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: BorderSide(color: PmVisualBlockerConfigPanelTokens.lightOutline.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: PmVisualBlockerConfigPanelTokens.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Audit Telemetry',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: PmVisualBlockerConfigPanelTokens.brandPrimary,
              ),
            ),
            PmVisualBlockerConfigPanelTokens.vGapSm,
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
abstract final class PmVisualBlockerConfigPanelTokens {
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
            child: PmVisualBlockerConfigPanel(),
          ),
        ),
      ),
    ),
  );
}
