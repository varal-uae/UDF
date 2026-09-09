// BPTR-0237-A14 — Tokenized text input component linked to Figma design tokens and central style packages.
// Enforces an 8dp grid, tokenized text/color treatments, and direct keyboard input listeners for layout consistency.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Central 8dp spacing unit and scale for the BPTR-0237-A14 layout mapper.
class Bptr0237A14Spacing {
  const Bptr0237A14Spacing._();

  static const double unit = 8;
  static const double xs = unit * 0.5; // 4
  static const double sm = unit; // 8
  static const double md = unit * 2; // 16
  static const double lg = unit * 3; // 24
  static const double xl = unit * 4; // 32
}

/// Tokenized color and text references pulled from @habot/design-tokens-mobile.
@immutable
class Bptr0237A14Tokens extends ThemeExtension<Bptr0237A14Tokens> {
  const Bptr0237A14Tokens({
    required this.surface,
    required this.onSurface,
    required this.textPrimary,
    required this.textSecondary,
    required this.textDisabled,
    required this.focusBorder,
    required this.error,
    required this.errorContainer,
    required this.onErrorContainer,
  });

  final Color surface;
  final Color onSurface;
  final Color textPrimary;
  final Color textSecondary;
  final Color textDisabled;
  final Color focusBorder;
  final Color error;
  final Color errorContainer;
  final Color onErrorContainer;

  static const light = Bptr0237A14Tokens(
    surface: Color(0xFFFEF7FF),
    onSurface: Color(0xFF1D1B20),
    textPrimary: Color(0xFF1D1B20),
    textSecondary: Color(0xFF49454F),
    textDisabled: Color(0xFF79747E),
    focusBorder: Color(0xFF6750A4),
    error: Color(0xFFB3261E),
    errorContainer: Color(0xFFF9DEDC),
    onErrorContainer: Color(0xFF410E0B),
  );

  static const dark = Bptr0237A14Tokens(
    surface: Color(0xFF141218),
    onSurface: Color(0xFFE6E0E9),
    textPrimary: Color(0xFFE6E0E9),
    textSecondary: Color(0xFFCAC4D0),
    textDisabled: Color(0xFF938F99),
    focusBorder: Color(0xFFD0BCFF),
    error: Color(0xFFF2B8B5),
    errorContainer: Color(0xFF8C1D18),
    onErrorContainer: Color(0xFFF9DEDC),
  );

  @override
  Bptr0237A14Tokens copyWith({
    Color? surface,
    Color? onSurface,
    Color? textPrimary,
    Color? textSecondary,
    Color? textDisabled,
    Color? focusBorder,
    Color? error,
    Color? errorContainer,
    Color? onErrorContainer,
  }) {
    return Bptr0237A14Tokens(
      surface: surface ?? this.surface,
      onSurface: onSurface ?? this.onSurface,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textDisabled: textDisabled ?? this.textDisabled,
      focusBorder: focusBorder ?? this.focusBorder,
      error: error ?? this.error,
      errorContainer: errorContainer ?? this.errorContainer,
      onErrorContainer: onErrorContainer ?? this.onErrorContainer,
    );
  }

  @override
  Bptr0237A14Tokens lerp(ThemeExtension<Bptr0237A14Tokens>? other, double t) {
    if (other is! Bptr0237A14Tokens) return this;
    return Bptr0237A14Tokens(
      surface: Color.lerp(surface, other.surface, t)!,
      onSurface: Color.lerp(onSurface, other.onSurface, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textDisabled: Color.lerp(textDisabled, other.textDisabled, t)!,
      focusBorder: Color.lerp(focusBorder, other.focusBorder, t)!,
      error: Color.lerp(error, other.error, t)!,
      errorContainer: Color.lerp(errorContainer, other.errorContainer, t)!,
      onErrorContainer: Color.lerp(onErrorContainer, other.onErrorContainer, t)!,
    );
  }
}

/// Tokenized text field with direct keyboard input listeners.
class Bptr0237A14TokenizedTextField extends StatelessWidget {
  const Bptr0237A14TokenizedTextField({
    super.key,
    required this.controller,
    required this.label,
    this.onChanged,
    this.onEditingComplete,
    this.onSubmitted,
    this.focusNode,
    this.keyboardType,
    this.textInputAction,
    this.autofocus = false,
    this.enabled = true,
    this.maxLines = 1,
    this.obscureText = false,
    this.inputFormatters,
    this.validator,
    this.autovalidateMode,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
  });

  final TextEditingController controller;
  final String label;
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool autofocus;
  final bool enabled;
  final int maxLines;
  final bool obscureText;
  final List<TextInputFormatter>? inputFormatters;
  final FormFieldValidator<String>? validator;
  final AutovalidateMode? autovalidateMode;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tokens = isDark ? Bptr0237A14Tokens.dark : Bptr0237A14Tokens.light;

    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      autofocus: autofocus,
      enabled: enabled,
      maxLines: maxLines,
      obscureText: obscureText,
      inputFormatters: inputFormatters,
      validator: validator,
      autovalidateMode: autovalidateMode,
      onChanged: onChanged,
      onEditingComplete: onEditingComplete,
      onFieldSubmitted: onSubmitted,
      style: TextStyle(
        color: tokens.textPrimary,
        fontSize: 16,
        letterSpacing: 0.5,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: tokens.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Bptr0237A14Spacing.md,
          vertical: Bptr0237A14Spacing.sm,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: tokens.textDisabled),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: tokens.focusBorder, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: tokens.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: tokens.error, width: 2),
        ),
        labelStyle: TextStyle(color: tokens.textSecondary),
        hintStyle: TextStyle(color: tokens.textDisabled),
        errorStyle: TextStyle(color: tokens.error),
      ),
    );
  }
}

extension Bptr0237A14TokensX on BuildContext {
  Bptr0237A14Tokens get bptr0237A14Tokens =>
      Theme.of(this).extension<Bptr0237A14Tokens>() ??
      (Theme.of(this).brightness == Brightness.dark
          ? Bptr0237A14Tokens.dark
          : Bptr0237A14Tokens.light);
}
