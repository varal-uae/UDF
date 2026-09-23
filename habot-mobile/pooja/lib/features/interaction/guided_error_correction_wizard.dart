import 'package:flutter/material.dart';

/// Unique styling tokens for Guided Error Correction Wizard.
abstract final class GuidedErrorTokens {
  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);

  static const Color errorRed = Color(0xFFDC2626);
  static const Color errorRedBg = Color(0xFFFEE2E2);
  static const Color fixedGreen = Color(0xFF16A34A);
  static const Color fixedGreenBg = Color(0xFFDCFCE7);
  static const Color primaryBlue = Color(0xFF2563EB);
}

/// Representation of an error step in the correction wizard.
class ErrorCorrectionStep {
  final int stepNumber;
  final String title;
  final String instruction;
  final String codeSnippet;
  bool isCompleted;

  ErrorCorrectionStep({
    required this.stepNumber,
    required this.title,
    required this.instruction,
    required this.codeSnippet,
    this.isCompleted = false,
  });
}

/// Interactive wizard guiding users step-by-step through error correction under CI/CD standards.
class GuidedErrorCorrectionWizard extends StatefulWidget {
  final void Function(bool allResolved)? onResolutionCompleted;

  const GuidedErrorCorrectionWizard({
    super.key,
    this.onResolutionCompleted,
  });

  @override
  State<GuidedErrorCorrectionWizard> createState() =>
      _GuidedErrorCorrectionWizardState();
}

class _GuidedErrorCorrectionWizardState
    extends State<GuidedErrorCorrectionWizard> {
  int _activeStepIndex = 0;

  late List<ErrorCorrectionStep> _steps;

  @override
  void initState() {
    super.initState();
    _steps = [
      ErrorCorrectionStep(
        stepNumber: 1,
        title: 'Missing Required Attribute: tenant_id',
        instruction:
            'The ingestion gateway rejected the payload because mandatory key "tenant_id" was omitted.',
        codeSnippet: 'payload["tenant_id"] = session.activeTenant;',
      ),
      ErrorCorrectionStep(
        stepNumber: 2,
        title: 'Clock Skew Anomaly: timestamp > now() + 60s',
        instruction:
            'Device system clock drifted ahead of server NTP by 84 seconds. Sync system epoch time.',
        codeSnippet: 'final ntpCorrected = DateTime.now().toUtc();',
      ),
      ErrorCorrectionStep(
        stepNumber: 3,
        title: 'Unverified SHA-256 HMAC Signature',
        instruction:
            'The signed payload header does not match the computed digest. Re-sign using secret vault token.',
        codeSnippet: 'headers["X-Habot-Signature"] = computeHmacSha256(payload);',
      ),
    ];
  }

  bool get _allResolved => _steps.every((s) => s.isCompleted);

  void _applyFix(int index) {
    setState(() {
      _steps[index].isCompleted = true;
      if (_activeStepIndex < _steps.length - 1) {
        _activeStepIndex++;
      }
    });

    widget.onResolutionCompleted?.call(_allResolved);
  }

  void _resetWizard() {
    setState(() {
      for (final s in _steps) {
        s.isCompleted = false;
      }
      _activeStepIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final allFixed = _allResolved;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: GuidedErrorTokens.surfaceCard,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: GuidedErrorTokens.borderLight),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: (allFixed
                          ? GuidedErrorTokens.fixedGreen
                          : GuidedErrorTokens.errorRed)
                      .withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  allFixed
                      ? Icons.task_alt_rounded
                      : Icons.support_agent_rounded,
                  color: allFixed
                      ? GuidedErrorTokens.fixedGreen
                      : GuidedErrorTokens.errorRed,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Guided Error Remediation',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: GuidedErrorTokens.textDark,
                      ),
                    ),
                    Text(
                      'Interactive Troubleshooting & CI/CD Instruction Guide',
                      style: TextStyle(
                        fontSize: 12,
                        color: GuidedErrorTokens.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: allFixed
                      ? GuidedErrorTokens.fixedGreenBg
                      : GuidedErrorTokens.errorRedBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  allFixed ? 'ALL FIXED' : 'ACTION REQUIRED',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: allFixed
                        ? GuidedErrorTokens.fixedGreen
                        : GuidedErrorTokens.errorRed,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Stepper Progress Indicators
          Row(
            children: List.generate(_steps.length, (idx) {
              final step = _steps[idx];
              final isActive = _activeStepIndex == idx;

              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _activeStepIndex = idx),
                  child: Container(
                    margin: EdgeInsets.only(right: idx < _steps.length - 1 ? 6 : 0),
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: step.isCompleted
                          ? GuidedErrorTokens.fixedGreenBg
                          : (isActive
                              ? const Color(0xFFEFF6FF)
                              : GuidedErrorTokens.backgroundLight),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: step.isCompleted
                            ? GuidedErrorTokens.fixedGreen
                            : (isActive
                                ? GuidedErrorTokens.primaryBlue
                                : GuidedErrorTokens.borderLight),
                        width: isActive ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          step.isCompleted
                              ? Icons.check_circle_rounded
                              : (isActive
                                  ? Icons.radio_button_checked_rounded
                                  : Icons.radio_button_unchecked_rounded),
                          size: 14,
                          color: step.isCompleted
                              ? GuidedErrorTokens.fixedGreen
                              : (isActive
                                  ? GuidedErrorTokens.primaryBlue
                                  : GuidedErrorTokens.textMuted),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Step ${step.stepNumber}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: step.isCompleted
                                ? GuidedErrorTokens.fixedGreen
                                : (isActive
                                    ? GuidedErrorTokens.primaryBlue
                                    : GuidedErrorTokens.textDark),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 14),
          // Active Step Detailed Card
          Builder(
            builder: (context) {
              final activeStep = _steps[_activeStepIndex];

              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: GuidedErrorTokens.backgroundLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: GuidedErrorTokens.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          activeStep.isCompleted
                              ? Icons.check_circle_rounded
                              : Icons.error_outline_rounded,
                          size: 16,
                          color: activeStep.isCompleted
                              ? GuidedErrorTokens.fixedGreen
                              : GuidedErrorTokens.errorRed,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            activeStep.title,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: GuidedErrorTokens.textDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      activeStep.instruction,
                      style: const TextStyle(
                        fontSize: 11,
                        color: GuidedErrorTokens.textMuted,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Suggested Code Correction Block
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        activeStep.codeSnippet,
                        style: const TextStyle(
                          fontSize: 10,
                          fontFamily: 'monospace',
                          color: Color(0xFF38BDF8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (allFixed)
                          TextButton(
                            onPressed: _resetWizard,
                            child: const Text('Reset Simulation',
                                style: TextStyle(fontSize: 11)),
                          ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: activeStep.isCompleted
                              ? null
                              : () => _applyFix(_activeStepIndex),
                          icon: Icon(
                            activeStep.isCompleted
                                ? Icons.done_all_rounded
                                : Icons.build_rounded,
                            size: 14,
                          ),
                          label: Text(
                            activeStep.isCompleted
                                ? 'Resolved'
                                : 'Apply Guided Fix',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: GuidedErrorTokens.primaryBlue,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: const Color(0xFFDCFCE7),
                            disabledForegroundColor: const Color(0xFF166534),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            textStyle: const TextStyle(
                                fontSize: 11, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: GuidedErrorCorrectionWizard(),
          ),
        ),
      ),
    ),
  );
}
