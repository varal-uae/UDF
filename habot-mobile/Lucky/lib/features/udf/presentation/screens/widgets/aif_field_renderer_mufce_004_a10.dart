// MUFCE-004-A10 — Additional Information Required (AIF) Field Renderer & Onboarding Form.
// Implements dynamic form rendering, precise typographical label weights, high-contrast borders,
// keyboard-aware layout transitions, and Poka-Yoke submission locking for mobile onboarding.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Mock data representing atomic-level AIF fields required during onboarding.
class _MockAifField {
  final String id;
  final String label;
  final String hint;
  final String explanation;
  final TextInputType keyboardType;
  final bool isRequired;

  const _MockAifField({
    required this.id,
    required this.label,
    required this.hint,
    required this.explanation,
    required this.keyboardType,
    this.isRequired = true,
  });
}

const List<_MockAifField> _mockFields = [
  _MockAifField(
    id: 'full_name',
    label: 'Full Legal Name',
    hint: 'Enter your full name as per ID',
    explanation: 'Required to verify your identity against government records.',
    keyboardType: TextInputType.name,
  ),
  _MockAifField(
    id: 'emirates_id',
    label: 'Emirates ID Number',
    hint: '784-XXXX-XXXXXXX-X',
    explanation: 'Mandatory for UAE residency validation and compliance checks.',
    keyboardType: TextInputType.number,
  ),
  _MockAifField(
    id: 'mobile_number',
    label: 'Mobile Number',
    hint: '+971 5X XXX XXXX',
    explanation: 'Used for OTP verification and account recovery.',
    keyboardType: TextInputType.phone,
  ),
  _MockAifField(
    id: 'email_address',
    label: 'Email Address',
    hint: 'name@example.com',
    explanation: 'Primary channel for transactional receipts and alerts.',
    keyboardType: TextInputType.emailAddress,
  ),
];

/// Core AIF field renderer widget adhering to TKI 11d specifications.
class AifFieldRenderer extends StatefulWidget {
  final VoidCallback? onComplete;

  const AifFieldRenderer({super.key, this.onComplete});

  @override
  State<AifFieldRenderer> createState() => _AifFieldRendererState();
}

class _AifFieldRendererState extends State<AifFieldRenderer>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  late final AnimationController _animController;
  late final Animation<double> _progressAnimation;

  int _currentStep = 0;
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    for (final field in _mockFields) {
      _controllers[field.id] = TextEditingController();
      _controllers[field.id]!.addListener(_validateForm);
    }

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  void _validateForm() {
    bool allFilled = true;
    for (final field in _mockFields) {
      if (field.isRequired && (_controllers[field.id]?.text.trim().isEmpty ?? true)) {
        allFilled = false;
        break;
      }
    }
    if (mounted && _isFormValid != allFilled) {
      setState(() {
        _isFormValid = allFilled;
      });
      if (allFilled) {
        _animController.forward();
      } else {
        _animController.reverse();
      }
    }
  }

  void _nextStep() {
    if (_currentStep < _mockFields.length - 1) {
      setState(() => _currentStep++);
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      // Mock telemetry data collection
      final mockTelemetry = {
        'step_execution_id': 'EXEC-${DateTime.now().millisecondsSinceEpoch}',
        'execution_status': 'SUCCESS',
        'execution_timestamp': DateTime.now().toIso8601String(),
        'step_outcome': 'FORM_SUBMITTED',
        'user_id': 'MOCK_USER_001',
        'completion_status': 'Complete',
      };
      debugPrint('MUFCE-004-A10 Telemetry: $mockTelemetry');
      widget.onComplete?.call();
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Client Onboarding'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: KeyboardAvoidingWrapper(
          child: Column(
            children: [
              // Clean interactive progress wheel tracking profile readiness
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 64,
                      height: 64,
                      child: AnimatedBuilder(
                        animation: _progressAnimation,
                        builder: (context, child) {
                          return CircularProgressIndicator(
                            value: (_currentStep + 1) / _mockFields.length,
                            strokeWidth: 6.0,
                            backgroundColor: colorScheme.surfaceContainerHighest,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              colorScheme.primary,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Profile Readiness: ${(((_currentStep + 1) / _mockFields.length) * 100).toInt()}%',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: PageView.builder(
                    itemCount: _mockFields.length,
                    controller: PageController(initialPage: _currentStep),
                    onPageChanged: (index) => setState(() => _currentStep = index),
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      final field = _mockFields[index];
                      return _buildFieldCard(field, theme, textTheme, colorScheme);
                    },
                  ),
                ),
              ),
              // Navigation controls with Poka-Yoke submittal lock
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_currentStep > 0)
                      OutlinedButton.icon(
                        onPressed: _prevStep,
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Previous'),
                      )
                    else
                      const SizedBox.shrink(),
                    if (_currentStep < _mockFields.length - 1)
                      FilledButton.icon(
                        onPressed: _nextStep,
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text('Next'),
                      )
                    else
                      FilledButton.icon(
                        onPressed: _isFormValid ? _submitForm : null,
                        icon: _isFormValid
                            ? const Icon(Icons.check_circle_outline)
                            : const Icon(Icons.lock_outline),
                        label: Text(_isFormValid ? 'Submit' : 'Complete All Fields'),
                        style: FilledButton.styleFrom(
                          backgroundColor: _isFormValid
                              ? colorScheme.primary
                              : colorScheme.surfaceContainerHighest,
                          foregroundColor: _isFormValid
                              ? colorScheme.onPrimary
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldCard(
    _MockAifField field,
    ThemeData theme,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Precise typographical weight guidelines for labels
          Text(
            field.label,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          // Contextual guidelines detailing exactly why each input is required
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: colorScheme.secondaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: colorScheme.secondary.withOpacity(0.5),
                width: 1.0,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, size: 20, color: colorScheme.secondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    field.explanation,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Style entry blocks using high-contrast outer borders
          TextFormField(
            controller: _controllers[field.id],
            keyboardType: field.keyboardType,
            textInputAction: TextInputAction.next,
            style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w400),
            decoration: InputDecoration(
              hintText: field.hint,
              hintStyle: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant.withOpacity(0.6),
                fontWeight: FontWeight.w300,
              ),
              filled: true,
              fillColor: colorScheme.surfaceContainerLowest,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 18.0,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(
                  color: colorScheme.outline,
                  width: 2.0, // High-contrast outer border
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(
                  color: colorScheme.primary,
                  width: 2.5,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(
                  color: colorScheme.error,
                  width: 2.0,
                ),
              ),
            ),
            validator: (value) {
              if (field.isRequired && (value == null || value.trim().isEmpty)) {
                return '${field.label} is mandatory.';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}

/// Wrapper to transition input field box margins dynamically to fit software soft keyboard displays.
class KeyboardAvoidingWrapper extends StatelessWidget {
  final Widget child;

  const KeyboardAvoidingWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedPadding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      child: child,
    );
  }
}

/// Helper class mimicking AnimatedBuilder for environments where it might be aliased.
class AnimatedBuilder extends AnimatedWidget {
  final Widget Function(BuildContext context, Widget? child) builder;
  final Widget? child;

  const AnimatedBuilder({
    super.key,
    required super.listenable,
    required this.builder,
    this.child,
  }) : super();

  Animation<double> get animation => listenable as Animation<double>;

  @override
  Widget build(BuildContext context) {
    return builder(context, child);
  }
}