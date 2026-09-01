/// TELEMETRY METADATA BLOCK
/// Library Name: Universal MD3 Standard Atomic Widgets
/// Component Standards: UniversalPrimaryButton & UniversalTextField
/// Token Binding: Strict Theme.of(context).colorScheme & textTheme Consumers
/// Accessibility Compliance: WCAG 2.1 AA 48dp Minimum Touch Target
/// Completion Status: Target: Complete - 100% Component Reuse Rate
library;

import 'package:flutter/material.dart';
import '../theme/app_design_tokens.dart';

/// Atomic Standard Primary Button consuming strict MD3 Theme tokens (RCGLA-014-A02)
class UniversalPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final double? width;

  const UniversalPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isDisabled = onPressed == null || isLoading;

    final labelStyle = textTheme.labelLarge?.copyWith(
          color: isDisabled
              ? colorScheme.onSurface.withAlpha(97) // 38% opacity disabled
              : colorScheme.onPrimary,
          fontWeight: FontWeight.bold,
        ) ??
        TextStyle(
          color: isDisabled
              ? colorScheme.onSurface.withAlpha(97)
              : colorScheme.onPrimary,
          fontWeight: FontWeight.bold,
        );

    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 20.0,
            height: 20.0,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(
                colorScheme.onPrimary,
              ),
            ),
          ),
          const SizedBox(width: AppDesignTokens.spaceS),
        ] else if (icon != null) ...[
          Icon(icon, size: 20.0, color: labelStyle.color),
          const SizedBox(width: AppDesignTokens.spaceS),
        ],
        Flexible(
          child: Text(
            label,
            style: labelStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );

    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: 48.0, // Strict 48dp minimum touch target
        minWidth: width ?? 88.0,
      ),
      child: SizedBox(
        width: width,
        height: 48.0,
        child: FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            disabledBackgroundColor: colorScheme.onSurface.withAlpha(30), // 12% disabled
            disabledForegroundColor: colorScheme.onSurface.withAlpha(97), // 38% disabled
            padding: const EdgeInsets.symmetric(
              horizontal: AppDesignTokens.spaceL,
              vertical: AppDesignTokens.spaceM,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDesignTokens.radiusSmall),
            ),
          ),
          onPressed: isDisabled ? null : onPressed,
          child: content,
        ),
      ),
    );
  }
}

/// Atomic Standard Text Form Field consuming strict MD3 Theme tokens (RCGLA-014-A02)
class UniversalTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final String? errorText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final bool obscureText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final FormFieldValidator<String>? validator;

  const UniversalTextField({
    super.key,
    required this.label,
    this.hint,
    this.errorText,
    this.controller,
    this.onChanged,
    this.keyboardType,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: AppDesignTokens.spaceXs),
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48.0),
          child: TextFormField(
            controller: controller,
            onChanged: onChanged,
            keyboardType: keyboardType,
            obscureText: obscureText,
            validator: validator,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
            ),
            decoration: InputDecoration(
              hintText: hint,
              errorText: errorText,
              hintStyle: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              prefixIcon: prefixIcon != null
                  ? Icon(prefixIcon, color: colorScheme.onSurfaceVariant)
                  : null,
              suffixIcon: suffixIcon,
              filled: true,
              fillColor: colorScheme.surfaceContainerHigh,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppDesignTokens.spaceM,
                vertical: 14.0,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDesignTokens.radiusSmall),
                borderSide: BorderSide(color: colorScheme.outline),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDesignTokens.radiusSmall),
                borderSide: BorderSide(color: colorScheme.outlineVariant),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDesignTokens.radiusSmall),
                borderSide: BorderSide(color: colorScheme.primary, width: 2.0),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDesignTokens.radiusSmall),
                borderSide: BorderSide(color: colorScheme.error, width: 1.5),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDesignTokens.radiusSmall),
                borderSide: BorderSide(color: colorScheme.error, width: 2.0),
              ),
              errorStyle: textTheme.bodySmall?.copyWith(
                color: colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
