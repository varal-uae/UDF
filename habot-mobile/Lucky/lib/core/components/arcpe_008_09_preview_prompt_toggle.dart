// ARCPE-008-09 — Preview Prompt Toggle Controller Widget.
// Material 3 SwitchListTile providing a labeled toggle with WCAG AA compliant touch target (>=44x44dp).
import 'package:flutter/material.dart';

/// A reusable toggle controller for the "Preview Prompt" feature.
/// Uses SwitchListTile to ensure accessibility and touch target compliance.
class PreviewPromptToggle extends StatelessWidget {
  const PreviewPromptToggle({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: const Text('Preview Prompt'),
      value: value,
      onChanged: onChanged,
      // The ListTile automatically handles semantics and min touch target size.
    );
  }
}
