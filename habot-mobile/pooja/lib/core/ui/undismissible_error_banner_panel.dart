import 'package:flutter/material.dart';

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
      padding: UndismissibleErrorBannerPanelTokens.paddingMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeaderCard(),
          UndismissibleErrorBannerPanelTokens.vGapMd,
          if (_isErrorActive) _buildFullWidthUndismissibleBanner(),
          UndismissibleErrorBannerPanelTokens.vGapMd,
          _buildSimulatedWorkspaceCard(),
          UndismissibleErrorBannerPanelTokens.vGapMd,
          _buildSimulationControls(),
          UndismissibleErrorBannerPanelTokens.vGapMd,
          _buildTelemetryCard(),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: BorderSide(color: UndismissibleErrorBannerPanelTokens.lightOutline.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: UndismissibleErrorBannerPanelTokens.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.report_problem_rounded,
                  color: UndismissibleErrorBannerPanelTokens.lightError,
                  size: 22,
                ),
                UndismissibleErrorBannerPanelTokens.hGapSm,
                const Expanded(
                  child: Text(
                    'Un-dismissible Full-Width Error Banner',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: UndismissibleErrorBannerPanelTokens.brandPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: UndismissibleErrorBannerPanelTokens.lightErrorContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Poka-Yoke Lock',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: UndismissibleErrorBannerPanelTokens.lightOnErrorContainer,
                    ),
                  ),
                ),
              ],
            ),
            UndismissibleErrorBannerPanelTokens.vGapSm,
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
        color: UndismissibleErrorBannerPanelTokens.lightErrorContainer,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: UndismissibleErrorBannerPanelTokens.lightError, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: UndismissibleErrorBannerPanelTokens.lightError.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: UndismissibleErrorBannerPanelTokens.paddingMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: UndismissibleErrorBannerPanelTokens.lightError,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              UndismissibleErrorBannerPanelTokens.hGapSm,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'CRITICAL ERROR - WORKFLOW LOCKED',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: UndismissibleErrorBannerPanelTokens.lightOnErrorContainer,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Code: $_errorCode',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: UndismissibleErrorBannerPanelTokens.lightError,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: UndismissibleErrorBannerPanelTokens.lightError.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'NO CLOSE (x)',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: UndismissibleErrorBannerPanelTokens.lightOnErrorContainer,
                  ),
                ),
              ),
            ],
          ),
          UndismissibleErrorBannerPanelTokens.vGapSm,
          Text(
            _errorMessage,
            style: const TextStyle(
              fontSize: 12,
              color: UndismissibleErrorBannerPanelTokens.lightOnErrorContainer,
              height: 1.3,
            ),
          ),
          UndismissibleErrorBannerPanelTokens.vGapMd,
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton.icon(
                onPressed: _resolveError,
                icon: const Icon(Icons.build_circle_outlined, size: 16),
                label: const Text('Execute Remediation'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: UndismissibleErrorBannerPanelTokens.lightError,
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
        side: BorderSide(color: UndismissibleErrorBannerPanelTokens.lightOutline.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: UndismissibleErrorBannerPanelTokens.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _isErrorActive ? Icons.lock_clock : Icons.check_circle,
                  color: _isErrorActive
                      ? UndismissibleErrorBannerPanelTokens.warning
                      : UndismissibleErrorBannerPanelTokens.success,
                  size: 20,
                ),
                UndismissibleErrorBannerPanelTokens.hGapSm,
                Text(
                  _isErrorActive ? 'Workspace Suspended' : 'Workspace Operational',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _isErrorActive
                        ? UndismissibleErrorBannerPanelTokens.warning
                        : UndismissibleErrorBannerPanelTokens.success,
                  ),
                ),
              ],
            ),
            UndismissibleErrorBannerPanelTokens.vGapSm,
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
            ? UndismissibleErrorBannerPanelTokens.success
            : UndismissibleErrorBannerPanelTokens.lightError,
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
        side: BorderSide(color: UndismissibleErrorBannerPanelTokens.lightOutline.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: UndismissibleErrorBannerPanelTokens.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Banner Quality & Compliance Telemetry',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: UndismissibleErrorBannerPanelTokens.brandPrimary,
              ),
            ),
            UndismissibleErrorBannerPanelTokens.vGapSm,
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

// ============================================================================
// File-Local Standalone Design Tokens & Constants
// ============================================================================
abstract final class UndismissibleErrorBannerPanelTokens {
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
            child: UndismissibleErrorBannerPanel(),
          ),
        ),
      ),
    ),
  );
}
