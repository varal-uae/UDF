import 'package:flutter/material.dart';
import '../tokens/color_palette.dart';
import '../tokens/spacing_tokens.dart';

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
      padding: AppSpacingTokens.paddingMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeaderCard(),
          AppSpacingTokens.vGapMd,
          if (isBlockerActive) _buildVisualBlockerBanner(),
          AppSpacingTokens.vGapMd,
          _buildConfigurationSettingsCard(),
          AppSpacingTokens.vGapMd,
          _buildDefectSimulatorCard(),
          AppSpacingTokens.vGapMd,
          _buildChangeLogCard(),
          AppSpacingTokens.vGapMd,
          _buildTelemetryCard(),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
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
                  Icons.gavel_rounded,
                  color: AppColorPalette.brandPrimary,
                  size: 22,
                ),
                AppSpacingTokens.hGapSm,
                const Expanded(
                  child: Text(
                    'PM Visual Blocker Configuration',
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
                    color: AppColorPalette.warningContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Clause 8.5',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColorPalette.onWarningContainer,
                    ),
                  ),
                ),
              ],
            ),
            AppSpacingTokens.vGapSm,
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
      padding: AppSpacingTokens.paddingMd,
      decoration: BoxDecoration(
        color: AppColorPalette.lightErrorContainer,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: AppColorPalette.lightError, width: 2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: AppColorPalette.lightError,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.block, color: Colors.white, size: 24),
          ),
          AppSpacingTokens.hGapMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'PM WORKFLOW BLOCKED',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColorPalette.lightOnErrorContainer,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Defect score is $_currentDefectScore (> 0). Release gating prohibits signoff until defect score reaches 0.',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColorPalette.lightOnErrorContainer,
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
        side: BorderSide(color: AppColorPalette.lightOutline.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: AppSpacingTokens.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Threshold Enforcement Rule',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColorPalette.brandPrimary,
              ),
            ),
            AppSpacingTokens.vGapSm,
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Show Visual Blocker on Non-Zero Scores'),
              subtitle: Text(
                'Current Status: ${_isVisualBlockerEnabled ? 'Active (Strict Gate)' : 'Disabled'}',
                style: TextStyle(
                  fontSize: 12,
                  color: _isVisualBlockerEnabled
                      ? AppColorPalette.success
                      : AppColorPalette.warning,
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
        side: BorderSide(color: AppColorPalette.lightOutline.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: AppSpacingTokens.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Defect Score Simulator',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColorPalette.brandPrimary,
              ),
            ),
            AppSpacingTokens.vGapSm,
            Row(
              children: [
                _buildDefectButton(0, '0 (Clean)'),
                AppSpacingTokens.hGapSm,
                _buildDefectButton(1, '1 (Minor)'),
                AppSpacingTokens.hGapSm,
                _buildDefectButton(3, '3 (Moderate)'),
                AppSpacingTokens.hGapSm,
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
              ? (score == 0 ? AppColorPalette.success : AppColorPalette.lightError)
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
        side: BorderSide(color: AppColorPalette.lightOutline.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: AppSpacingTokens.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Configuration Audit Log',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColorPalette.brandPrimary,
              ),
            ),
            AppSpacingTokens.vGapSm,
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
