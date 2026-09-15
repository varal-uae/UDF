import 'package:flutter/material.dart';
import '../tokens/color_palette.dart';
import '../tokens/spacing_tokens.dart';

/// Row 218 - ETMDI-020-06 (Seq 14502)
/// Action: Overlay un-dismissible full-width error banner across panel.
/// Metric: Process Execution Quality Score | Unit: Good/Average/Poor -> Best = Good (100%)
/// Standard: ISO 9001:2015 Quality Management Standard
class UndismissibleErrorBannerPanel extends StatefulWidget {
  const UndismissibleErrorBannerPanel({super.key});

  @override
  State<UndismissibleErrorBannerPanel> createState() =>
      _UndismissibleErrorBannerPanelState();
}

class _UndismissibleErrorBannerPanelState
    extends State<UndismissibleErrorBannerPanel> {
  final String _stepExecutionId = 'ETMDI-020-06-BANNER-001';
  final String _userSessionId = 'POOJA-ETMDI-020-06';
  final String _completionStatus = 'Good (100%)';
  final String _standard = 'ISO 9001:2015 Quality Management Standard';
  final String _errorCode = 'ERR_CRITICAL_PAYLOAD_LOCK';
  final String _errorMessage =
      'Fatal Schema Violation: Atomic validation gate failed due to corrupted cryptographic manifest signature.';

  bool _isErrorActive = true;
  DateTime _eventTimestamp = DateTime.now();

  void _toggleErrorSimulation() {
    setState(() {
      _isErrorActive = !_isErrorActive;
      _eventTimestamp = DateTime.now();
    });
  }

  void _resolveError() {
    setState(() {
      _isErrorActive = false;
      _eventTimestamp = DateTime.now();
    });
  }

  Map<String, dynamic> getTelemetryData() {
    return {
      'Step Execution ID': _stepExecutionId,
      'Execution Status': _isErrorActive ? 'BLOCKING_ACTIVE' : 'RESOLVED',
      'Execution Timestamp': _eventTimestamp.toIso8601String(),
      'Step Outcome': _isErrorActive ? 'UN_DISMISSIBLE_ACTIVE' : 'CLEARED',
      'User ID': 'POOJA_SYSTEM',
      'Completion Status': _completionStatus,
      'Action/Event Timestamp': _eventTimestamp.toIso8601String(),
      'User/Session ID': _userSessionId,
      'Error Code': _errorCode,
      'Quality Standard': _standard,
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
          if (_isErrorActive) _buildFullWidthUndismissibleBanner(),
          AppSpacingTokens.vGapMd,
          _buildSimulatedWorkspaceCard(),
          AppSpacingTokens.vGapMd,
          _buildSimulationControls(),
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
                  Icons.report_problem_rounded,
                  color: AppColorPalette.lightError,
                  size: 22,
                ),
                AppSpacingTokens.hGapSm,
                const Expanded(
                  child: Text(
                    'Un-dismissible Full-Width Error Banner',
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
                    color: AppColorPalette.lightErrorContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Poka-Yoke Lock',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColorPalette.lightOnErrorContainer,
                    ),
                  ),
                ),
              ],
            ),
            AppSpacingTokens.vGapSm,
            Text(
              'Enforces continuous error banner overlay across the viewport until required corrective action is confirmed.',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFullWidthUndismissibleBanner() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColorPalette.lightErrorContainer,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: AppColorPalette.lightError, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColorPalette.lightError.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: AppSpacingTokens.paddingMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColorPalette.lightError,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              AppSpacingTokens.hGapSm,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'CRITICAL ERROR - WORKFLOW LOCKED',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColorPalette.lightOnErrorContainer,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Code: $_errorCode',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColorPalette.lightError,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColorPalette.lightError.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'NO CLOSE (x)',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: AppColorPalette.lightOnErrorContainer,
                  ),
                ),
              ),
            ],
          ),
          AppSpacingTokens.vGapSm,
          Text(
            _errorMessage,
            style: const TextStyle(
              fontSize: 12,
              color: AppColorPalette.lightOnErrorContainer,
              height: 1.3,
            ),
          ),
          AppSpacingTokens.vGapMd,
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton.icon(
                onPressed: _resolveError,
                icon: const Icon(Icons.build_circle_outlined, size: 16),
                label: const Text('Execute Remediation'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColorPalette.lightError,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSimulatedWorkspaceCard() {
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
                Icon(
                  _isErrorActive ? Icons.lock_clock : Icons.check_circle,
                  color: _isErrorActive
                      ? AppColorPalette.warning
                      : AppColorPalette.success,
                  size: 20,
                ),
                AppSpacingTokens.hGapSm,
                Text(
                  _isErrorActive ? 'Workspace Suspended' : 'Workspace Operational',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _isErrorActive
                        ? AppColorPalette.warning
                        : AppColorPalette.success,
                  ),
                ),
              ],
            ),
            AppSpacingTokens.vGapSm,
            Text(
              _isErrorActive
                  ? 'All modification pipelines are halted while the error banner remains un-dismissible.'
                  : 'All systems operating within acceptable ISO 9001:2015 process tolerances.',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimulationControls() {
    return ElevatedButton.icon(
      onPressed: _toggleErrorSimulation,
      icon: Icon(_isErrorActive ? Icons.lock_open : Icons.lock),
      label: Text(_isErrorActive ? 'Dismiss via Remediation Bypass' : 'Trigger Error Banner Simulation'),
      style: ElevatedButton.styleFrom(
        backgroundColor: _isErrorActive
            ? AppColorPalette.success
            : AppColorPalette.lightError,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
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
              'Banner Quality & Compliance Telemetry',
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
                      width: 160,
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
