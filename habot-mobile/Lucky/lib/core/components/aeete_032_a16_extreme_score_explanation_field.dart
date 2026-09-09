// AEETE-032-A16 — Extreme Score Explanation Field with Placeholder Guidance.
// Displays a multi-line text input prompting users to explain extreme score selections, ensuring layout updates and data mappings remain validated before submission.

import 'package:flutter/material.dart';

/// A reusable form field that guides users to explain extreme score selections.
class ExtremeScoreExplanationField extends StatelessWidget {
  const ExtremeScoreExplanationField({
    super.key,
    this.controller,
    this.onChanged,
    this.validator,
    this.enabled = true,
    this.maxLines = 3,
  });

  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final bool enabled;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      validator: validator,
      enabled: enabled,
      maxLines: maxLines,
      minLines: 2,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        labelText: 'Extreme score explanation',
        hintText: 'Please explain why you selected an extreme score...',
        helperText: 'Provide context to help reviewers understand your rating.',
        alignLabelWithHint: true,
        border: const OutlineInputBorder(),
        filled: true,
      ),
    );
  }
}
