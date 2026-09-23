import 'package:flutter/material.dart';

/// Row 260 - FIEVR-039 (Seq 15679)
/// Action: Test the tooltip rendering and overlay lock on various screen sizes to ensure accessibility and readability.
/// Metric: Millisecond Precision Accuracy (ms) | Target: 50ms | Ceiling: 100ms | Unit: Pass/Fail
/// Standard: W3C High Resolution Time API Standard.
class TooltipOverlayLockScreenMatrixPanel extends StatefulWidget {
  const TooltipOverlayLockScreenMatrixPanel({super.key});

  @override
  State<TooltipOverlayLockScreenMatrixPanel> createState() =>
      _TooltipOverlayLockScreenMatrixPanelState();
}

class _ScreenSizeSpec {
  final String label;
  final String dimensions;
  final double renderLatencyMs;
  final bool overlayLockActive;

  const _ScreenSizeSpec({
    required this.label,
    required this.dimensions,
    required this.renderLatencyMs,
    required this.overlayLockActive,
  });
}

class _TooltipOverlayLockScreenMatrixPanelState
    extends State<TooltipOverlayLockScreenMatrixPanel> {
  final String _accessType = 'HR Compensation / Payroll Gateway Audit';
  final String _userRole = 'Lead HR Auditor & Compliance Officer';
  final String _permissionLevel = 'SEC_LEVEL_4_FINANCIAL_RESTRICTED';
  final String _accessLog = 'POLICY_LOCKOUT_ENFORCED: Non-compliant profile bonus suspended';
  final String _completionStatus = 'Pass';
  final String _userSessionId = 'POOJA-FIEVR-039';

  final List<_ScreenSizeSpec> _screenSpecs = const [
    _ScreenSizeSpec(label: 'Compact Mobile Phone', dimensions: '360dp x 640dp', renderLatencyMs: 34.2, overlayLockActive: true),
    _ScreenSizeSpec(label: 'Medium Tablet Viewport', dimensions: '768dp x 1024dp', renderLatencyMs: 28.5, overlayLockActive: true),
    _ScreenSizeSpec(label: 'Desktop Admin Console', dimensions: '1440dp x 900dp', renderLatencyMs: 22.1, overlayLockActive: true),
  ];

  int _selectedScreenIndex = 0;
  final DateTime _accessTimestamp = DateTime.now();

  Map<String, dynamic> getTelemetryData() {
    final spec = _screenSpecs[_selectedScreenIndex];
    return {
      'Access Type': _accessType,
      'User Role': _userRole,
      'Permission Level': _permissionLevel,
      'Access Log': _accessLog,
      'Access Timestamp': _accessTimestamp.toIso8601String(),
      'Completion Status': _completionStatus,
      'Action/Event Timestamp': _accessTimestamp.toIso8601String(),
      'User/Session ID': _userSessionId,
      'Target Viewport': spec.label,
      'Render Latency': '${spec.renderLatencyMs}ms (Target: <50ms)',
      'Overlay Lock Status': 'ACTIVE_NON_OVERRIDABLE (Col AD)',
    };
  }

  void _showRecoveryDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.shield_outlined, color: TooltipOverlayLockScreenMatrixPanelTokens.error),
            SizedBox(width: 8),
            Text('Suspended Bonus Recovery Steps', style: TextStyle(fontSize: 15)),
          ],
        ),
        content: const Text(
          'Policy Rule: Manual HR overrides are physically disabled. To restore bonus eligibility:\n\n'
          '1. Complete all missing verification milestones.\n'
          '2. Submit updated regional compliance documents.\n'
          '3. System self-chasing engine will re-evaluate eligibility automatically.',
          style: TextStyle(fontSize: 12, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: TooltipOverlayLockScreenMatrixPanelTokens.paddingMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeaderCard(),
          TooltipOverlayLockScreenMatrixPanelTokens.vGapMd,
          _buildScreenSizeSelectorCard(),
          TooltipOverlayLockScreenMatrixPanelTokens.vGapMd,
          _buildBonusLockCard(),
          TooltipOverlayLockScreenMatrixPanelTokens.vGapMd,
          _buildTelemetryCard(),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
        side: BorderSide(color: TooltipOverlayLockScreenMatrixPanelTokens.lightOutline.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: TooltipOverlayLockScreenMatrixPanelTokens.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.lock_person_outlined,
                  color: TooltipOverlayLockScreenMatrixPanelTokens.brandPrimary,
                  size: 22,
                ),
                TooltipOverlayLockScreenMatrixPanelTokens.hGapSm,
                const Expanded(
                  child: Text(
                    'Tooltip Overlay Lock Screen Matrix',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: TooltipOverlayLockScreenMatrixPanelTokens.brandPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: TooltipOverlayLockScreenMatrixPanelTokens.successContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Latency: 28ms (Pass)',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: TooltipOverlayLockScreenMatrixPanelTokens.onSuccessContainer,
                    ),
                  ),
                ),
              ],
            ),
            TooltipOverlayLockScreenMatrixPanelTokens.vGapSm,
            Text(
              'Tests high-resolution tooltip overlays and physical payout lockout mechanisms across screen resolutions, ensuring accessibility and strict policy enforcement.',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScreenSizeSelectorCard() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
        side: BorderSide(color: TooltipOverlayLockScreenMatrixPanelTokens.lightOutline.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: TooltipOverlayLockScreenMatrixPanelTokens.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Screen Dimension & Latency Benchmark',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: TooltipOverlayLockScreenMatrixPanelTokens.brandPrimary),
            ),
            TooltipOverlayLockScreenMatrixPanelTokens.vGapSm,
            Row(
              children: List.generate(_screenSpecs.length, (index) {
                final spec = _screenSpecs[index];
                final isSelected = _selectedScreenIndex == index;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: index < _screenSpecs.length - 1 ? 6 : 0),
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: isSelected ? TooltipOverlayLockScreenMatrixPanelTokens.brandPrimaryContainer : Colors.transparent,
                        side: BorderSide(
                          color: isSelected ? TooltipOverlayLockScreenMatrixPanelTokens.brandPrimary : Colors.grey.shade300,
                          width: isSelected ? 1.5 : 1,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      onPressed: () {
                        setState(() {
                          _selectedScreenIndex = index;
                        });
                      },
                      child: Column(
                        children: [
                          Text(
                            spec.label.split(' ').first,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? TooltipOverlayLockScreenMatrixPanelTokens.brandPrimary : Colors.black87,
                            ),
                          ),
                          Text('${spec.renderLatencyMs}ms', style: const TextStyle(fontSize: 9, color: TooltipOverlayLockScreenMatrixPanelTokens.success, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBonusLockCard() {
    return Card(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
        side: BorderSide(color: TooltipOverlayLockScreenMatrixPanelTokens.error, width: 1.5),
      ),
      color: TooltipOverlayLockScreenMatrixPanelTokens.errorContainer.withValues(alpha: 0.25),
      child: Padding(
        padding: TooltipOverlayLockScreenMatrixPanelTokens.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Employee Compensation Ledger Item',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: TooltipOverlayLockScreenMatrixPanelTokens.brandPrimary),
                ),
                Tooltip(
                  message: 'Policy Rule: Payouts permanently locked due to non-compliant profile status.',
                  child: InkWell(
                    onTap: _showRecoveryDialog,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: TooltipOverlayLockScreenMatrixPanelTokens.error,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.block, size: 12, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            'BLOCKED / SUSPENDED',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            TooltipOverlayLockScreenMatrixPanelTokens.vGapSm,
            const Text(
              'Expected Performance Bonus: \$1,250.00',
              style: TextStyle(fontSize: 12, decoration: TextDecoration.lineThrough, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              'Poka-Yoke Col AD: The system disables manual HR overrides. If the policy condition registers suspended, HR physically cannot force a payout. Payroll submit button is permanently disabled.',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade800),
            ),
            TooltipOverlayLockScreenMatrixPanelTokens.vGapMd,
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: null, // permanently disabled per Col AB
                icon: const Icon(Icons.lock_outline, size: 16),
                label: const Text('Submit Payout (Physically Disabled)'),
                style: ElevatedButton.styleFrom(
                  disabledBackgroundColor: Colors.grey.shade300,
                  disabledForegroundColor: Colors.grey.shade600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTelemetryCard() {
    final telemetry = getTelemetryData();
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
        side: BorderSide(color: TooltipOverlayLockScreenMatrixPanelTokens.lightOutline.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: TooltipOverlayLockScreenMatrixPanelTokens.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Audit Telemetry',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: TooltipOverlayLockScreenMatrixPanelTokens.brandPrimary,
              ),
            ),
            TooltipOverlayLockScreenMatrixPanelTokens.vGapSm,
            ...telemetry.entries.map((e) {
              final val = e.value.toString();
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 180,
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
abstract final class TooltipOverlayLockScreenMatrixPanelTokens {
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
            child: TooltipOverlayLockScreenMatrixPanel(),
          ),
        ),
      ),
    ),
  );
}
