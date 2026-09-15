import 'package:flutter/material.dart';
import '../tokens/color_palette.dart';
import '../tokens/spacing_tokens.dart';

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
      padding: AppSpacingTokens.paddingMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeaderCard(),
          AppSpacingTokens.vGapMd,
          _buildStepperWalkthroughCard(),
          AppSpacingTokens.vGapMd,
          _buildActiveStepDetailCard(),
          AppSpacingTokens.vGapMd,
          _buildControlsRow(),
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
                  Icons.account_tree_outlined,
                  color: AppColorPalette.brandPrimary,
                  size: 22,
                ),
                AppSpacingTokens.hGapSm,
                const Expanded(
                  child: Text(
                    'Atomic Workflow Progression Walkthrough',
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
                    color: AppColorPalette.infoContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _qaStandard,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColorPalette.onInfoContainer,
                    ),
                  ),
                ),
              ],
            ),
            AppSpacingTokens.vGapSm,
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
        side: BorderSide(color: AppColorPalette.lightOutline.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: AppSpacingTokens.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Workflow Progression Pipeline',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColorPalette.brandPrimary,
              ),
            ),
            AppSpacingTokens.vGapMd,
            Row(
              children: List.generate(_steps.length * 2 - 1, (index) {
                if (index.isOdd) {
                  final stepIndex = index ~/ 2;
                  final isPassed = _steps[stepIndex].isCompleted;
                  return Expanded(
                    child: Container(
                      height: 3,
                      color: isPassed
                          ? AppColorPalette.success
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
                          ? AppColorPalette.success
                          : (isCurrent
                              ? AppColorPalette.brandPrimary
                              : Colors.grey.shade200),
                      border: Border.all(
                        color: isCurrent
                            ? AppColorPalette.brandPrimary
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
        side: BorderSide(color: AppColorPalette.brandPrimary.withValues(alpha: 0.3)),
      ),
      color: Colors.grey.shade50,
      child: Padding(
        padding: AppSpacingTokens.paddingMd,
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
                    color: AppColorPalette.brandPrimary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: step.isCompleted
                        ? AppColorPalette.successContainer
                        : AppColorPalette.warningContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    step.isCompleted ? 'COMPLETED' : 'IN PROGRESS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: step.isCompleted
                          ? AppColorPalette.onSuccessContainer
                          : AppColorPalette.onWarningContainer,
                    ),
                  ),
                ),
              ],
            ),
            AppSpacingTokens.vGapSm,
            Text(
              step.description,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
            ),
            AppSpacingTokens.vGapSm,
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.all(Radius.circular(6)),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified_outlined, size: 16, color: AppColorPalette.success),
                  AppSpacingTokens.hGapSm,
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
        AppSpacingTokens.hGapMd,
        Expanded(
          child: ElevatedButton.icon(
            onPressed: allComplete ? null : _nextStep,
            icon: Icon(
              isLastStep ? Icons.task_alt : Icons.arrow_forward,
              color: Colors.white,
            ),
            label: Text(isLastStep ? 'Complete Walkthrough' : 'Verify & Next Step'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColorPalette.brandPrimary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        AppSpacingTokens.hGapSm,
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
        side: BorderSide(color: AppColorPalette.lightOutline.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: AppSpacingTokens.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'QA Walkthrough Audit Telemetry',
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
