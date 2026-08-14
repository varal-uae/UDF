// PELCE-019-10 — EC-compliant CTA button wrapper.
// Enforces M3 Filled Button styling per spec:
//   - width: 100% (full-width primary actions)
//   - border-radius: 100px (pill shape)
//   - Clear, predictable machine-action verb labels (validated by lint_ec_verbs.js)

import 'package:flutter/material.dart';

/// Material 3 full-width pill CTA — use EC machine-action verbs only.
///
/// ```dart
/// EcCtaButton(
///   label: 'Submit',
///   onPressed: _submit,
/// )
/// ```
class EcCtaButton extends StatelessWidget {
  const EcCtaButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.loadingLabel = 'Submitting',
  });

  /// Must be an EC machine-action verb — enforced by `lint_ec_verbs.js`.
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final String loadingLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final child = isLoading
        ? SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: theme.colorScheme.onPrimary,
            ),
          )
        : Text(isLoading ? loadingLabel : label);

    final button = icon != null
        ? FilledButton.icon(
            onPressed: isLoading ? null : onPressed,
            icon: Icon(icon, size: 20),
            label: Text(isLoading ? loadingLabel : label),
            style: _style(theme),
          )
        : FilledButton(
            onPressed: isLoading ? null : onPressed,
            style: _style(theme),
            child: child,
          );

    return SizedBox(width: double.infinity, child: button);
  }

  ButtonStyle _style(ThemeData theme) {
    return FilledButton.styleFrom(
      minimumSize: const Size(double.infinity, 48),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(100),
      ),
    );
  }
}

/// Outlined secondary EC CTA — same pill styling, tonal variant.
class EcCtaButtonOutlined extends StatelessWidget {
  const EcCtaButtonOutlined({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final style = OutlinedButton.styleFrom(
      minimumSize: const Size(double.infinity, 48),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(100),
      ),
    );

    final button = icon != null
        ? OutlinedButton.icon(
            onPressed: onPressed,
            icon: Icon(icon, size: 20),
            label: Text(label),
            style: style,
          )
        : OutlinedButton(
            onPressed: onPressed,
            style: style,
            child: Text(label),
          );

    return SizedBox(width: double.infinity, child: button);
  }
}
