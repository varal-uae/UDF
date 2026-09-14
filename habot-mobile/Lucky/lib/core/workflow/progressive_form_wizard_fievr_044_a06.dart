// FIEVR-044-A06 — Progressive Form Wizard with Automated Focus & Explicit Guide Hints.
// Implements single-action mobile form workflows with visual card isolation, 3-choice cognitive capacity constraint, automated focus shifting, and strict poka-yoke next-action gates.

import 'dart:async';
import 'package:flutter/material.dart';

/// Model representing an individual step in the progressive form workflow.
class FormStepDefinition {
  final String stepId;
  final String title;
  final String subtitle;
  final String guideHint;
  final String placeholderText;
  final List<String>? choices; // Restricted to max 3 choices per view for cognitive load control
  final TextInputType keyboardType;
  final bool isChoiceStep;

  const FormStepDefinition({
    required this.stepId,
    required this.title,
    required this.subtitle,
    required this.guideHint,
    required this.placeholderText,
    this.choices,
    this.keyboardType = TextInputType.text,
    this.isChoiceStep = false,
  }) : assert(
          choices == null || choices.length <= 3,
          'FIEVR-044-A06 constraint: Restrict primary choices to a maximum of 3 items per view.',
        );
}

/// Telemetry payload emitted upon step execution.
class FormStepTelemetryEvent {
  final String stepExecutionId;
  final String executionStatus;
  final DateTime executionTimestamp;
  final String stepOutcome;
  final String userId;
  final Duration timeTaken;

  const FormStepTelemetryEvent({
    required this.stepExecutionId,
    required this.executionStatus,
    required this.executionTimestamp,
    required this.stepOutcome,
    required this.userId,
    required this.timeTaken,
  });

  Map<String, dynamic> toJson() => {
        'step_execution_id': stepExecutionId,
        'execution_status': executionStatus,
        'execution_timestamp': executionTimestamp.toIso8601String(),
        'step_outcome': stepOutcome,
        'user_id': userId,
        'duration_ms': timeTaken.inMilliseconds,
      };
}

/// Main Progressive Form Wizard implementing Material 3 guidelines and Poka-Yoke completion rules.
class ProgressiveFormWizard extends StatefulWidget {
  final String userId;
  final List<FormStepDefinition> steps;
  final void Function(Map<String, String> formData)? onCompleted;
  final void Function(FormStepTelemetryEvent event)? onTelemetryLogged;
  final VoidCallback? onSessionTimeout;
  final Duration inactivityTimeout;

  const ProgressiveFormWizard({
    super.key,
    required this.userId,
    required this.steps,
    this.onCompleted,
    this.onTelemetryLogged,
    this.onSessionTimeout,
    this.inactivityTimeout = const Duration(minutes: 5),
  });

  @override
  State<ProgressiveFormWizard> createState() => _ProgressiveFormWizardState();
}

class _ProgressiveFormWizardState extends State<ProgressiveFormWizard> {
  int _currentStepIndex = 0;
  final Map<String, String> _stepResponses = {};
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, FocusNode> _focusNodes = {};
  
  Timer? _inactivityTimer;
  DateTime? _stepStartTime;

  @override
  void initState() {
    super.initState();
    for (var step in widget.steps) {
      _controllers[step.stepId] = TextEditingController();
      _focusNodes[step.stepId] = FocusNode();
    }
    _resetInactivityTimer();
    _stepStartTime = DateTime.now();

    // Auto-focus the initial input on mount
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusCurrentField();
    });
  }

  @override
  void dispose() {
    _inactivityTimer?.cancel();
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    for (var node in _focusNodes.values) {
      node.dispose();
    }
    super.dispose();
  }

  void _resetInactivityTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(widget.inactivityTimeout, () {
      if (mounted) {
        widget.onSessionTimeout?.call();
      }
    });
  }

  void _focusCurrentField() {
    if (_currentStepIndex < widget.steps.length) {
      final currentStep = widget.steps[_currentStepIndex];
      if (!currentStep.isChoiceStep) {
        _focusNodes[currentStep.stepId]?.requestFocus();
      }
    }
  }

  bool _isStepComplete(int index) {
    if (index >= widget.steps.length) return false;
    final step = widget.steps[index];
    final value = _stepResponses[step.stepId];
    return value != null && value.trim().isNotEmpty;
  }

  void _onStepSubmitted(String value) {
    _resetInactivityTimer();
    final currentStep = widget.steps[_currentStepIndex];
    setState(() {
      _stepResponses[currentStep.stepId] = value;
    });

    if (_isStepComplete(_currentStepIndex)) {
      _advanceStep();
    }
  }

  void _advanceStep() {
    final now = DateTime.now();
    final currentStep = widget.steps[_currentStepIndex];
    final duration = _stepStartTime != null
        ? now.difference(_stepStartTime!)
        : Duration.zero;

    widget.onTelemetryLogged?.call(
      FormStepTelemetryEvent(
        stepExecutionId: '${currentStep.stepId}_${now.millisecondsSinceEpoch}',
        executionStatus: 'Complete',
        executionTimestamp: now,
        stepOutcome: 'SUCCESS',
        userId: widget.userId,
        timeTaken: duration,
      ),
    );

    if (_currentStepIndex < widget.steps.length - 1) {
      setState(() {
        _currentStepIndex++;
        _stepStartTime = DateTime.now();
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusCurrentField();
      });
    } else {
      widget.onCompleted?.call(_stepResponses);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentStep = widget.steps[_currentStepIndex];
    final isStepValid = _isStepComplete(_currentStepIndex);

    return GestureDetector(
      onTap: _resetInactivityTimer,
      behavior: HitTestBehavior.translucent,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Progress Tracker Header
                LinearProgressIndicator(
                  value: (_currentStepIndex + 1) / widget.steps.length,
                  backgroundColor: theme.colorScheme.surfaceVariant,
                  valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
                const SizedBox(height: 12),
                Text(
                  'Step ${_currentStepIndex + 1} of ${widget.steps.length}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),

                // Visual Card Boundary isolating the active step
                Card(
                  elevation: 2,
                  surfaceTintColor: theme.colorScheme.surfaceTint,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                    side: BorderSide(
                      color: theme.colorScheme.outlineVariant.withOpacity(0.6),
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          currentStep.title,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          currentStep.subtitle,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Guided Input Field or 3-Choice Selector
                        if (currentStep.isChoiceStep && currentStep.choices != null) ...[
                          _buildChoiceList(context, currentStep),
                        ] else ...[
                          _buildGuideInputField(context, currentStep),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Navigation Action (Poka-Yoke: physical disablement until valid)
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 48), // Touch target compliance
                  child: FilledButton(
                    onPressed: isStepValid ? _advanceStep : null,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    child: Text(
                      _currentStepIndex == widget.steps.length - 1 ? 'Submit' : 'Continue',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGuideInputField(BuildContext context, FormStepDefinition step) {
    final theme = Theme.of(context);
    final controller = _controllers[step.stepId]!;
    final focusNode = _focusNodes[step.stepId]!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: step.keyboardType,
          textInputAction: TextInputAction.done,
          style: theme.textTheme.bodyLarge,
          onChanged: (val) {
            _resetInactivityTimer();
            setState(() {
              _stepResponses[step.stepId] = val;
            });
          },
          onFieldSubmitted: _onStepSubmitted,
          decoration: InputDecoration(
            hintText: step.placeholderText,
            helperText: step.guideHint,
            helperMaxLines: 2,
            filled: true,
            fillColor: theme.colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildChoiceList(BuildContext context, FormStepDefinition step) {
    final theme = Theme.of(context);
    final selectedValue = _stepResponses[step.stepId];
    final choices = step.choices ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          step.guideHint,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.secondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        ...choices.map((choice) {
          final isSelected = selectedValue == choice;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: InkWell(
              onTap: () {
                _onStepSubmitted(choice);
              },
              borderRadius: BorderRadius.circular(10.0),
              child: Container(
                constraints: const BoxConstraints(minHeight: 48), // 48dp touch target
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primaryContainer
                      : theme.colorScheme.surfaceVariant.withOpacity(0.3),
                  border: Border.all(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outline.withOpacity(0.3),
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        choice,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: isSelected
                              ? theme.colorScheme.onPrimaryContainer
                              : theme.colorScheme.onSurface,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
