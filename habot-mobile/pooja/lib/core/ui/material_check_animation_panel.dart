import 'package:flutter/material.dart';
import '../tokens/color_palette.dart';
import '../tokens/spacing_tokens.dart';

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
      padding: AppSpacingTokens.paddingMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeaderCard(),
          AppSpacingTokens.vGapMd,
          _buildAnimationStageCard(),
          AppSpacingTokens.vGapMd,
          _buildControlsCard(),
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
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: AppColorPalette.successContainer,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_outline,
                    color: AppColorPalette.onSuccessContainer,
                    size: 20,
                  ),
                ),
                AppSpacingTokens.hGapSm,
                const Expanded(
                  child: Text(
                    'Material Check Icon Animation',
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
                    color: AppColorPalette.successContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'ISO 9001:2015',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColorPalette.onSuccessContainer,
                    ),
                  ),
                ),
              ],
            ),
            AppSpacingTokens.vGapSm,
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
              ? AppColorPalette.success
              : AppColorPalette.lightOutline.withValues(alpha: 0.3),
          width: _isSuccessTriggered ? 2 : 1,
        ),
      ),
      child: Container(
        height: 220,
        padding: AppSpacingTokens.paddingLg,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _isSuccessTriggered
                  ? AppColorPalette.successContainer.withValues(alpha: 0.25)
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
                            color: AppColorPalette.success,
                            boxShadow: [
                              BoxShadow(
                                color: AppColorPalette.success.withValues(alpha: 0.35),
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
                    AppSpacingTokens.vGapMd,
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: const Text(
                        'Operation Confirmed Successfully!',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColorPalette.onSuccessContainer,
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
                    AppSpacingTokens.vGapSm,
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
              backgroundColor: AppColorPalette.brandPrimary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
        ),
        AppSpacingTokens.hGapMd,
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
