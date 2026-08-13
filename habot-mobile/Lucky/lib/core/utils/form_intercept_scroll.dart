import 'package:flutter/material.dart';
import 'form_error_focus_engine.dart';

// FIEVR-032-A01 — Form Intercept Scroll.
// Intercepts form submission — validates all fields first.
// If any field fails: scrolls to first error, blocks submission.
// If all fields pass: allows submission to proceed.
//
// Spec: "Submission triggers stay physically locked until all form elements
// satisfy structural criteria."

class FormInterceptScroll extends StatefulWidget {
  const FormInterceptScroll({
    super.key,
    required this.engine,
    required this.formKey,
    required this.child,
    required this.onValidSubmit,
    this.submitLabel = 'Submit',
    this.isSubmitting = false,
  });

  final FormErrorFocusEngine engine;
  final GlobalKey<FormState> formKey;
  final Widget child;

  /// Called only when all fields pass validation.
  final VoidCallback onValidSubmit;

  final String submitLabel;

  /// When true — submit button shows loading, stays disabled.
  final bool isSubmitting;

  @override
  State<FormInterceptScroll> createState() => _FormInterceptScrollState();
}

class _FormInterceptScrollState extends State<FormInterceptScroll> {

  Future<void> _onSubmitPressed() async {
    // Run Flutter form validation first
    final formValid = widget.formKey.currentState?.validate() ?? false;

    if (!formValid || !widget.engine.isValid) {
      // Scroll to first error — fluid, calm animation
      await widget.engine.scrollToFirstError(context);
      return;
    }

    widget.formKey.currentState?.save();
    widget.onValidSubmit();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        widget.child,
        const SizedBox(height: 24),

        // Submit button — locked until all fields pass
        FilledButton(
          onPressed: widget.isSubmitting ? null : _onSubmitPressed,
          child: widget.isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.submitLabel),
        ),
      ],
    );
  }
}
