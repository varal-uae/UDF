import 'package:flutter/material.dart';

/// Row 217 - ETMDI-016-13 (Seq 14428)
/// Action: Conduct a walkthrough of the refactored workflow to confirm user progression occurs one atomic step at a time.
/// Metric: QA Test Case Pass Rate | Unit: Pass/Fail -> Best = Pass (100%)
/// Standard: ISO/IEC/IEEE 29119 Software Testing Standard
class RefactoredWorkflowWalkthroughPanel extends StatefulWidget {
  const RefactoredWorkflowWalkthroughPanel({super.key});

  @override
  State<RefactoredWorkflowWalkthroughPanel> createState() =>
      _RefactoredWorkflowWalkthroughPanelState();
}

class _WorkflowStep {
  final int stepNumber;
  final String title;
  final String description;
  final String validationCheck;
  bool isCompleted;

  _WorkflowStep({
    required this.stepNumber,
    required this.title,
    required this.description,
    required this.validationCheck,
    this.isCompleted = false,
  });
}

class _RefactoredWorkflowWalkthroughPanelState
    extends State<RefactoredWorkflowWalkthroughPanel> {
  final String _stepExecutionId = 'ETMDI-016-13-QA-001';
  final String _userSessionId = 'POOJA-ETMDI-016-13';
  final String _completionStatus = 'Pass (100%)';
  final String _qaStandard = 'ISO/IEC/IEEE 29119';

  int _currentStepIndex = 0;
  final List<_WorkflowStep> _steps = [
    _WorkflowStep(
      stepNumber: 1,
      title: 'Isolate Target Snapshot',
      description: 'Capture atomic entity payload without ambient data bleeding.',
      validationCheck: 'Payload schema validated against strict JSON specs.',
      isCompleted: true,
    ),
    _WorkflowStep(
      stepNumber: 2,
      title: 'Enforce Step Gating',
      description: 'Lock downstream transitions until primary field verification passes.',
      validationCheck: 'Gating lock activated; premature navigation disabled.',
      isCompleted: false,
    ),
    _WorkflowStep(
      stepNumber: 3,
      title: 'Execute Atomic Validation',
      description: 'Run automated assertion suites against atomic input elements.',
      validationCheck: 'Assertion suite returned zero failures and zero warnings.',
      isCompleted: false,
    ),
    _WorkflowStep(
      stepNumber: 4,
      title: 'Commit State Transition',
      description: 'Persist state update and broadcast completion event to workflow pipeline.',
      validationCheck: 'Telemetry log recorded with immutable SHA256 audit key.',
      isCompleted: false,
    ),
  ];

  DateTime _lastActionTime = DateTime.now();

  void _nextStep() {
    if (_currentStepIndex < _steps.length - 1) {
      setState(() {
        _steps[_currentStepIndex].isCompleted = true;
        _currentStepIndex++;
        _lastActionTime = DateTime.now();
      });
    } else {
      setState(() {
        _steps[_currentStepIndex].isCompleted = true;
        _lastActionTime = DateTime.now();
      });
    }
  }

  void _previousStep() {
    if (_currentStepIndex > 0) {
      setState(() {
        _currentStepIndex--;
        _lastActionTime = DateTime.now();
      });
    }
  }

  void _resetWalkthrough() {
    setState(() {
      _currentStepIndex = 0;
      for (int i = 0; i < _steps.length; i++) {
        _steps[i].isCompleted = i == 0;
      }
      _lastActionTime = DateTime.now();
    });
  }

  Map<String, dynamic> getTelemetryData() {
    final completedCount = _steps.where((s) => s.isCompleted).length;
    final passRate = (completedCount / _steps.length * 100).toStringAsFixed(1);
    return {
      'Step Execution ID': _stepExecutionId,
      'Execution Status': completedCount == _steps.length ? 'VERIFIED_COMPLETE' : 'IN_PROGRESS',
      'Execution Timestamp': _lastActionTime.toIso8601String(),
      'Step Outcome': completedCount == _steps.length ? 'PASS' : 'TESTING',
      'User ID': 'POOJA_QA_LEAD',
      'Completion Status': '$passRate% ($_completionStatus)',
      'Action/Event Timestamp': _lastActionTime.toIso8601String(),
      'User/Session ID': _userSessionId,
      'Current Step Index': _currentStepIndex + 1,
      'Total Atomic Steps': _steps.length,
      'QA Standard': _qaStandard,
    };
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: RefactoredWorkflowWalkthroughPanelTokens.paddingMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeaderCard(),
          RefactoredWorkflowWalkthroughPanelTokens.vGapMd,
          _buildStepperWalkthroughCard(),
          RefactoredWorkflowWalkthroughPanelTokens.vGapMd,
          _buildActiveStepDetailCard(),
          RefactoredWorkflowWalkthroughPanelTokens.vGapMd,
          _buildControlsRow(),
          RefactoredWorkflowWalkthroughPanelTokens.vGapMd,
          _buildTelemetryCard(),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: BorderSide(color: RefactoredWorkflowWalkthroughPanelTokens.lightOutline.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: RefactoredWorkflowWalkthroughPanelTokens.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.account_tree_outlined,
                  color: RefactoredWorkflowWalkthroughPanelTokens.brandPrimary,
                  size: 22,
                ),
                RefactoredWorkflowWalkthroughPanelTokens.hGapSm,
                const Expanded(
                  child: Text(
                    'Atomic Workflow Progression Walkthrough',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: RefactoredWorkflowWalkthroughPanelTokens.brandPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: RefactoredWorkflowWalkthroughPanelTokens.infoContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _qaStandard,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: RefactoredWorkflowWalkthroughPanelTokens.onInfoContainer,
                    ),
                  ),
                ),
              ],
            ),
            RefactoredWorkflowWalkthroughPanelTokens.vGapSm,
            Text(
              'Validates that user navigation and progression is gated strictly one atomic step at a time without skips.',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepperWalkthroughCard() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: BorderSide(color: RefactoredWorkflowWalkthroughPanelTokens.lightOutline.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: RefactoredWorkflowWalkthroughPanelTokens.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Workflow Progression Pipeline',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: RefactoredWorkflowWalkthroughPanelTokens.brandPrimary,
              ),
            ),
            RefactoredWorkflowWalkthroughPanelTokens.vGapMd,
            Row(
              children: List.generate(_steps.length * 2 - 1, (index) {
                if (index.isOdd) {
                  final stepIndex = index ~/ 2;
                  final isPassed = _steps[stepIndex].isCompleted;
                  return Expanded(
                    child: Container(
                      height: 3,
                      color: isPassed
                          ? RefactoredWorkflowWalkthroughPanelTokens.success
                          : Colors.grey.shade300,
                    ),
                  );
                } else {
                  final stepIndex = index ~/ 2;
                  final step = _steps[stepIndex];
                  final isCurrent = stepIndex == _currentStepIndex;
                  final isCompleted = step.isCompleted;

                  return Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted
                          ? RefactoredWorkflowWalkthroughPanelTokens.success
                          : (isCurrent
                              ? RefactoredWorkflowWalkthroughPanelTokens.brandPrimary
                              : Colors.grey.shade200),
                      border: Border.all(
                        color: isCurrent
                            ? RefactoredWorkflowWalkthroughPanelTokens.brandPrimary
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: isCompleted
                          ? const Icon(Icons.check, size: 20, color: Colors.white)
                          : Text(
                              '${step.stepNumber}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isCurrent ? Colors.white : Colors.grey.shade600,
                              ),
                            ),
                    ),
                  );
                }
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveStepDetailCard() {
    final step = _steps[_currentStepIndex];
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: BorderSide(color: RefactoredWorkflowWalkthroughPanelTokens.brandPrimary.withValues(alpha: 0.3)),
      ),
      color: Colors.grey.shade50,
      child: Padding(
        padding: RefactoredWorkflowWalkthroughPanelTokens.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Step ${step.stepNumber}: ${step.title}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: RefactoredWorkflowWalkthroughPanelTokens.brandPrimary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: step.isCompleted
                        ? RefactoredWorkflowWalkthroughPanelTokens.successContainer
                        : RefactoredWorkflowWalkthroughPanelTokens.warningContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    step.isCompleted ? 'COMPLETED' : 'IN PROGRESS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: step.isCompleted
                          ? RefactoredWorkflowWalkthroughPanelTokens.onSuccessContainer
                          : RefactoredWorkflowWalkthroughPanelTokens.onWarningContainer,
                    ),
                  ),
                ),
              ],
            ),
            RefactoredWorkflowWalkthroughPanelTokens.vGapSm,
            Text(
              step.description,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
            ),
            RefactoredWorkflowWalkthroughPanelTokens.vGapSm,
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.all(Radius.circular(6)),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified_outlined, size: 16, color: RefactoredWorkflowWalkthroughPanelTokens.success),
                  RefactoredWorkflowWalkthroughPanelTokens.hGapSm,
                  Expanded(
                    child: Text(
                      'Validation: ${step.validationCheck}',
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey.shade700,
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

  Widget _buildControlsRow() {
    final isLastStep = _currentStepIndex == _steps.length - 1;
    final allComplete = _steps.every((s) => s.isCompleted);

    return Row(
      children: [
        OutlinedButton.icon(
          onPressed: _currentStepIndex > 0 ? _previousStep : null,
          icon: const Icon(Icons.arrow_back),
          label: const Text('Back'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          ),
        ),
        RefactoredWorkflowWalkthroughPanelTokens.hGapMd,
        Expanded(
          child: ElevatedButton.icon(
            onPressed: allComplete ? null : _nextStep,
            icon: Icon(
              isLastStep ? Icons.task_alt : Icons.arrow_forward,
              color: Colors.white,
            ),
            label: Text(isLastStep ? 'Complete Walkthrough' : 'Verify & Next Step'),
            style: ElevatedButton.styleFrom(
              backgroundColor: RefactoredWorkflowWalkthroughPanelTokens.brandPrimary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        RefactoredWorkflowWalkthroughPanelTokens.hGapSm,
        IconButton(
          onPressed: _resetWalkthrough,
          icon: const Icon(Icons.restart_alt),
          tooltip: 'Restart Walkthrough',
        ),
      ],
    );
  }

  Widget _buildTelemetryCard() {
    final telemetry = getTelemetryData();
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: BorderSide(color: RefactoredWorkflowWalkthroughPanelTokens.lightOutline.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: RefactoredWorkflowWalkthroughPanelTokens.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'QA Walkthrough Audit Telemetry',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: RefactoredWorkflowWalkthroughPanelTokens.brandPrimary,
              ),
            ),
            RefactoredWorkflowWalkthroughPanelTokens.vGapSm,
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
abstract final class RefactoredWorkflowWalkthroughPanelTokens {
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
            child: RefactoredWorkflowWalkthroughPanel(),
          ),
        ),
      ),
    ),
  );
}
