import 'package:flutter/material.dart';

/// Row 216 - ETMDI-014-12 (Seq 14380)
/// Action: Trigger Material Check icon animations confirming success.
/// Metric: Process Execution Quality Score | Unit: Good/Average/Poor -> Best = Good (100%)
/// Standard: ISO 9001:2015 Quality Management Standard
class MaterialCheckAnimationPanel extends StatefulWidget {
  const MaterialCheckAnimationPanel({super.key});

  @override
  State<MaterialCheckAnimationPanel> createState() =>
      _MaterialCheckAnimationPanelState();
}

class _MaterialCheckAnimationPanelState
    extends State<MaterialCheckAnimationPanel>
    with SingleTickerProviderStateMixin {
  final String _stepExecutionId = 'ETMDI-014-12-ANIM-001';
  final String _userSessionId = 'POOJA-ETMDI-014-12';
  final String _completionStatus = 'Good (100%)';
  final String _executionStatus = 'COMPLETED_VERIFIED';

  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _isSuccessTriggered = false;
  int _triggerCount = 0;
  DateTime _lastTriggered = DateTime.now();

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.elasticOut,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _triggerSuccessAnimation() {
    setState(() {
      _isSuccessTriggered = true;
      _triggerCount++;
      _lastTriggered = DateTime.now();
    });
    _animController.reset();
    _animController.forward();
  }

  void _resetAnimation() {
    setState(() {
      _isSuccessTriggered = false;
    });
    _animController.reset();
  }

  Map<String, dynamic> getTelemetryData() {
    return {
      'Step Execution ID': _stepExecutionId,
      'Execution Status': _executionStatus,
      'Execution Timestamp': _lastTriggered.toIso8601String(),
      'Step Outcome': _isSuccessTriggered ? 'SUCCESS_CONFIRMED' : 'AWAITING_TRIGGER',
      'User ID': 'POOJA_LEAD',
      'Completion Status': _completionStatus,
      'Action/Event Timestamp': _lastTriggered.toIso8601String(),
      'User/Session ID': _userSessionId,
      'Trigger Count': _triggerCount,
    };
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: MaterialCheckAnimationPanelTokens.paddingMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeaderCard(),
          MaterialCheckAnimationPanelTokens.vGapMd,
          _buildAnimationStageCard(),
          MaterialCheckAnimationPanelTokens.vGapMd,
          _buildControlsCard(),
          MaterialCheckAnimationPanelTokens.vGapMd,
          _buildTelemetryCard(),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
        side: BorderSide(color: MaterialCheckAnimationPanelTokens.lightOutline.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: MaterialCheckAnimationPanelTokens.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: MaterialCheckAnimationPanelTokens.successContainer,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_outline,
                    color: MaterialCheckAnimationPanelTokens.onSuccessContainer,
                    size: 20,
                  ),
                ),
                MaterialCheckAnimationPanelTokens.hGapSm,
                const Expanded(
                  child: Text(
                    'Material Check Icon Animation',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: MaterialCheckAnimationPanelTokens.brandPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: MaterialCheckAnimationPanelTokens.successContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'ISO 9001:2015',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: MaterialCheckAnimationPanelTokens.onSuccessContainer,
                    ),
                  ),
                ),
              ],
            ),
            MaterialCheckAnimationPanelTokens.vGapSm,
            Text(
              'Triggers reactive Material checkmark animations confirming successful operation with spring dynamics.',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimationStageCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(
          color: _isSuccessTriggered
              ? MaterialCheckAnimationPanelTokens.success
              : MaterialCheckAnimationPanelTokens.lightOutline.withValues(alpha: 0.3),
          width: _isSuccessTriggered ? 2 : 1,
        ),
      ),
      child: Container(
        height: 220,
        padding: MaterialCheckAnimationPanelTokens.paddingLg,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _isSuccessTriggered
                  ? MaterialCheckAnimationPanelTokens.successContainer.withValues(alpha: 0.25)
                  : Colors.grey.shade50,
              Colors.white,
            ],
          ),
        ),
        child: Center(
          child: _isSuccessTriggered
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: MaterialCheckAnimationPanelTokens.success,
                            boxShadow: [
                              BoxShadow(
                                color: MaterialCheckAnimationPanelTokens.success.withValues(alpha: 0.35),
                                blurRadius: 18,
                                spreadRadius: 4,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 52,
                          ),
                        ),
                      ),
                    ),
                    MaterialCheckAnimationPanelTokens.vGapMd,
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: const Text(
                        'Operation Confirmed Successfully!',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: MaterialCheckAnimationPanelTokens.onSuccessContainer,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Text(
                        'Quality Metric: 100% Pass Rate',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.touch_app_outlined,
                      size: 48,
                      color: Colors.grey.shade400,
                    ),
                    MaterialCheckAnimationPanelTokens.vGapSm,
                    Text(
                      'Ready to trigger confirmation',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Press button below to simulate successful action',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildControlsCard() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _triggerSuccessAnimation,
            icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
            label: const Text('Trigger Success'),
            style: ElevatedButton.styleFrom(
              backgroundColor: MaterialCheckAnimationPanelTokens.brandPrimary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
        ),
        MaterialCheckAnimationPanelTokens.hGapMd,
        OutlinedButton.icon(
          onPressed: _resetAnimation,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Reset'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTelemetryCard() {
    final telemetry = getTelemetryData();
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: BorderSide(color: MaterialCheckAnimationPanelTokens.lightOutline.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: MaterialCheckAnimationPanelTokens.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Audit Telemetry',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: MaterialCheckAnimationPanelTokens.brandPrimary,
              ),
            ),
            MaterialCheckAnimationPanelTokens.vGapSm,
            ...telemetry.entries.map((e) {
              final val = e.value.toString();
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 150,
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
abstract final class MaterialCheckAnimationPanelTokens {
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
            child: MaterialCheckAnimationPanel(),
          ),
        ),
      ),
    ),
  );
}
