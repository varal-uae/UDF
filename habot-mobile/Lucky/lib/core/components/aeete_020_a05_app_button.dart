// AEETE-020-A05 — Button component Props/API specification and implementation blueprint.
// Defines the reusable AppButton with explicit named parameters (props), accessibility hit target, and responsive scaling behavior per Material 3.
import 'package:flutter/material.dart';

/// Button variants available in the design system.
enum AppButtonVariant { filled, outlined, text }

/// Button sizes mapped to Material 3 component density and responsive scaling rules.
enum AppButtonSize { small, medium, large }

/// Reusable AppButton component with a fixed props/API contract.
///
/// Props:
/// - [label] (required): visible button text.
/// - [onPressed] (nullable): callback; when null, button renders disabled.
/// - [variant]: visual style (filled, outlined, text).
/// - [size]: density class controlling padding/min-height.
/// - [leadingIcon], [trailingIcon]: optional icons.
/// - [semanticLabel]: optional accessibility label overriding [label].
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.filled,
    this.size = AppButtonSize.medium,
    this.leadingIcon,
    this.trailingIcon,
    this.semanticLabel,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final Widget? leadingIcon;
  final Widget? trailingIcon;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null;

    final EdgeInsetsGeometry padding = switch (size) {
      AppButtonSize.small => const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      AppButtonSize.medium => const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      AppButtonSize.large => const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    };

    final double minHeight = switch (size) {
      AppButtonSize.small => 40.0,
      AppButtonSize.medium => 48.0,
      AppButtonSize.large => 56.0,
    };

    final ButtonStyle style = ButtonStyle(
      padding: WidgetStatePropertyAll(padding),
      minimumSize: WidgetStatePropertyAll(Size(48, minHeight)),
      tapTargetSize: MaterialTapTargetSize.padded,
    );

    final Widget child = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (leadingIcon != null) ...[
          leadingIcon!,
          const SizedBox(width: 8),
        ],
        Text(label),
        if (trailingIcon != null) ...[
          const SizedBox(width: 8),
          trailingIcon!,
        ],
      ],
    );

    final Widget button = switch (variant) {
      AppButtonVariant.filled => FilledButton(
        onPressed: onPressed,
        style: style,
        child: child,
      ),
      AppButtonVariant.outlined => OutlinedButton(
        onPressed: onPressed,
        style: style,
        child: child,
      ),
      AppButtonVariant.text => TextButton(
        onPressed: onPressed,
        style: style,
        child: child,
      ),
    };

    return Semantics(
      button: true,
      enabled: !isDisabled,
      label: semanticLabel ?? label,
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: 48, minHeight: minHeight),
        child: button,
      ),
    );
  }
}