// RCGLA-014-A04 — Standardized Material 3 Button Component Library.
// Provides atomic, reusable M3 button widgets (Filled, Outlined, Text, Tonal, Elevated) enforcing design tokens, dynamic color roles, and light/dark mode transitions.

import 'package:flutter/material.dart';

/// Standardized Filled Button following Material 3 design tokens.
class UdfFilledButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final double? width;

  const UdfFilledButton({
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
    final buttonStyle = FilledButton.styleFrom(
      minimumSize: Size(width ?? double.infinity, 48.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.0),
      ),
      textStyle: theme.textTheme.labelLarge,
    );

    if (isLoading) {
      return SizedBox(
        width: width ?? double.infinity,
        height: 48.0,
        child: FilledButton(
          onPressed: null,
          style: buttonStyle,
          child: SizedBox(
            width: 24.0,
            height: 24.0,
            child: CircularProgressIndicator(
              strokeWidth: 2.0,
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.onPrimary,
              ),
            ),
          ),
        ),
      );
    }

    if (icon != null) {
      return SizedBox(
        width: width,
        child: FilledButton.icon(
          onPressed: onPressed,
          style: buttonStyle,
          icon: Icon(icon),
          label: Text(label),
        ),
      );
    }

    return SizedBox(
      width: width,
      child: FilledButton(
        onPressed: onPressed,
        style: buttonStyle,
        child: Text(label),
      ),
    );
  }
}

/// Standardized Outlined Button following Material 3 design tokens.
class UdfOutlinedButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double? width;

  const UdfOutlinedButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonStyle = OutlinedButton.styleFrom(
      minimumSize: Size(width ?? double.infinity, 48.0),
      side: BorderSide(color: theme.colorScheme.outline),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.0),
      ),
      textStyle: theme.textTheme.labelLarge,
    );

    if (icon != null) {
      return SizedBox(
        width: width,
        child: OutlinedButton.icon(
          onPressed: onPressed,
          style: buttonStyle,
          icon: Icon(icon),
          label: Text(label),
        ),
      );
    }

    return SizedBox(
      width: width,
      child: OutlinedButton(
        onPressed: onPressed,
        style: buttonStyle,
        child: Text(label),
      ),
    );
  }
}

/// Standardized Text Button following Material 3 design tokens.
class UdfTextButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  const UdfTextButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonStyle = TextButton.styleFrom(
      minimumSize: const Size(64.0, 40.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      textStyle: theme.textTheme.labelLarge,
    );

    if (icon != null) {
      return TextButton.icon(
        onPressed: onPressed,
        style: buttonStyle,
        icon: Icon(icon),
        label: Text(label),
      );
    }

    return TextButton(
      onPressed: onPressed,
      style: buttonStyle,
      child: Text(label),
    );
  }
}

/// Standardized Tonal (Filled Tonal) Button following Material 3 design tokens.
class UdfTonalButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double? width;

  const UdfTonalButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonStyle = FilledButton.styleFrom(
      backgroundColor: theme.colorScheme.secondaryContainer,
      foregroundColor: theme.colorScheme.onSecondaryContainer,
      minimumSize: Size(width ?? double.infinity, 48.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.0),
      ),
      textStyle: theme.textTheme.labelLarge,
    );

    if (icon != null) {
      return SizedBox(
        width: width,
        child: FilledButton.icon(
          onPressed: onPressed,
          style: buttonStyle,
          icon: Icon(icon),
          label: Text(label),
        ),
      );
    }

    return SizedBox(
      width: width,
      child: FilledButton(
        onPressed: onPressed,
        style: buttonStyle,
        child: Text(label),
      ),
    );
  }
}

/// Standardized Elevated Button following Material 3 design tokens.
class UdfElevatedButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double? width;

  const UdfElevatedButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonStyle = ElevatedButton.styleFrom(
      minimumSize: Size(width ?? double.infinity, 48.0),
      elevation: 1.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.0),
      ),
      textStyle: theme.textTheme.labelLarge,
    );

    if (icon != null) {
      return SizedBox(
        width: width,
        child: ElevatedButton.icon(
          onPressed: onPressed,
          style: buttonStyle,
          icon: Icon(icon),
          label: Text(label),
        ),
      );
    }

    return SizedBox(
      width: width,
      child: ElevatedButton(
        onPressed: onPressed,
        style: buttonStyle,
        child: Text(label),
      ),
    );
  }
}