// FIEVR-033-A13 — Multi-Step Guided Carousel Layout Stepper.
// Arranges complex multi-step forms into focused, bite-sized horizontal cards with
// validation gating, automatic keyboard dismissal, and animated progress tracking.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Model representing an individual step in the carousel form stepper.
class CarouselFormStep {
  const CarouselFormStep({
    required this.id,
    required this.title,
    this.subtitle,
    required this.content,
    this.validator,
    this.formKey,
  });

  final String id;
  final String title;
  final String? subtitle;
  final Widget content;

  /// Synchronous or asynchronous validator returning true if inputs are valid.
  final bool Function()? validator;

  /// Optional GlobalKey for FormState validation.
  final GlobalKey<FormState>? formKey;
}

/// Telemetry and test telemetry payload collected on step transition or completion.
class CarouselStepperTelemetryData {
  const CarouselStepperTelemetryData({
    required this.testType,
    required this.testResult,
    required this.testTimestamp,
    required this.currentStepIndex,
    required this.totalSteps,
    this.testLogPath,
    this.sessionId,
  });

  final String testType;
  final String testResult;
  final DateTime testTimestamp;
  final int currentStepIndex;
  final int totalSteps;
  final String? testLogPath;
  final String? sessionId;
}

/// Material Design 3 Guided Carousel Layout Stepper with validation gating,
/// progress indicators, and keyboard dismissal across step transitions.
class CarouselFormStepper extends StatefulWidget {
  const CarouselFormStepper({
    super.key,
    required this.steps,
    required this.onCompleted,
    this.onDraftSave,
    this.onStepChanged,
    this.onTelemetryLogged,
    this.initialStepIndex = 0,
    this.transitionDuration = const Duration(milliseconds: 195),
    this.transitionCurve = Curves.easeInOutCubic,
    this.backButtonLabel = 'Back',
    this.nextButtonLabel = 'Next',
    this.submitButtonLabel = 'Complete',
  }) : assert(steps.length > 0, 'Steps list must not be empty.');

  final List<CarouselFormStep> steps;
  final ValueChanged<Map<String, dynamic>?> onCompleted;
  final void Function(int stepIndex)? onDraftSave;
  final ValueChanged<int>? onStepChanged;
  final ValueChanged<CarouselStepperTelemetryData>? onTelemetryLogged;
  final int initialStepIndex;
  final Duration transitionDuration;
  final Curve transitionCurve;
  final String backButtonLabel;
  final String nextButtonLabel;
  final String submitButtonLabel;

  @override
  State<CarouselFormStepper> createState() => _CarouselFormStepperState();
}

class _CarouselFormStepperState extends State<CarouselFormStepper> {
  late final PageController _pageController;
  late int _currentIndex;
  bool _isTransitioning = false;
  String? _validationError;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialStepIndex.clamp(0, widget.steps.length - 1);
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Validates the current step before allowing forward progression.
  bool _validateCurrentStep() {
    final currentStep = widget.steps[_currentIndex];

    if (currentStep.formKey?.currentState != null) {
      final isValidForm = currentStep.formKey!.currentState!.validate();
      if (!isValidForm) {
        _logTelemetry('Validation Gating', 'Failed - Form invalid');
        setState(() {
          _validationError = 'Please check required fields before proceeding.';
        });
        return false;
      }
    }

    if (currentStep.validator != null) {
      final isStepValid = currentStep.validator!();
      if (!isStepValid) {
        _logTelemetry('Validation Gating', 'Failed - Step validation callback');
        setState(() {
          _validationError = 'Please complete all required fields on this card.';
        });
        return false;
      }
    }

    setState(() {
      _validationError = null;
    });
    return true;
  }

  void _logTelemetry(String testType, String result) {
    widget.onTelemetryLogged?.call(
      CarouselStepperTelemetryData(
        testType: testType,
        testResult: result,
        testTimestamp: DateTime.now().toUtc(),
        currentStepIndex: _currentIndex,
        totalSteps: widget.steps.length,
        testLogPath: 'carousel_form_stepper/fievr_033_a13',
      ),
    );
  }

  /// Closes system keyboards and navigates to the target step.
  Future<void> _goToStep(int targetIndex) async {
    if (_isTransitioning || targetIndex < 0 || targetIndex >= widget.steps.length) {
      return;
    }

    // Poka-Yoke: Unfocus any active keyboard before sliding cards
    FocusScope.of(context).unfocus();
    SystemChannels.textInput.invokeMethod('TextInput.hide');

    setState(() => _isTransitioning = true);

    // Auto-save local draft hook
    widget.onDraftSave?.call(_currentIndex);

    await _pageController.animateToPage(
      targetIndex,
      duration: widget.transitionDuration,
      curve: widget.transitionCurve,
    );

    if (mounted) {
      setState(() {
        _currentIndex = targetIndex;
        _isTransitioning = false;
      });
      widget.onStepChanged?.call(targetIndex);
    }
  }

  Future<void> _handleNext() async {
    if (!_validateCurrentStep()) {
      HapticFeedback.mediumImpact();
      return;
    }

    if (_currentIndex < widget.steps.length - 1) {
      _logTelemetry('Step Transition Forward', 'Pass');
      await _goToStep(_currentIndex + 1);
    } else {
      _logTelemetry('Flow Completion', 'Pass');
      widget.onCompleted(null);
    }
  }

  Future<void> _handleBack() async {
    if (_currentIndex > 0) {
      _logTelemetry('Step Transition Backward', 'Pass');
      await _goToStep(_currentIndex - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final progressRatio = (_currentIndex + 1) / widget.steps.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Progress Indicator Header (Material 3)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Step ${_currentIndex + 1} of ${widget.steps.length}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${(progressRatio * 100).toInt()}%',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
              ClipRRect(
                borderRadius: BorderRadius.circular(4.0),
                child: LinearProgressIndicator(
                  value: progressRatio,
                  minHeight: 6.0,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                ),
              ),
            ],
          ),
        ),

        // Step Header Title and Subtitle
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.steps[_currentIndex].title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              if (widget.steps[_currentIndex].subtitle != null) ...[
                const SizedBox(height: 2.0),
                Text(
                  widget.steps[_currentIndex].subtitle!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),

        // Inline Validation Banner (if blocked)
        if (_validationError != null) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, size: 18.0, color: colorScheme.error),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Text(
                      _validationError!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onErrorContainer,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],

        // Horizontal Carousel Form Cards
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(), // Disallow direct swipe without validation
            itemCount: widget.steps.length,
            itemBuilder: (context, index) {
              final step = widget.steps[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: colorScheme.outlineVariant),
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  color: colorScheme.surface,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: step.content,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Ergonomic Bottom Navigation Bar
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
            child: Row(
              children: [
                // Back Button (disabled on first step)
                Expanded(
                  flex: 1,
                  child: OutlinedButton(
                    onPressed: (_currentIndex > 0 && !_isTransitioning)
                        ? _handleBack
                        : null,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    child: Text(widget.backButtonLabel),
                  ),
                ),
                const SizedBox(width: 12.0),
                // Next / Submit Button
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    onPressed: _isTransitioning ? null : _handleNext,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(48.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    child: _isTransitioning
                        ? const SizedBox(
                            width: 20.0,
                            height: 20.0,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.0,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            _currentIndex == widget.steps.length - 1
                                ? widget.submitButtonLabel
                                : widget.nextButtonLabel,
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
