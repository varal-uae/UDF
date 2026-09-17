// GEN-00848 — Standardized Material Design 3 (MD3) App Buttons with Mobile Touch Targets & Haptics.
// Provides a reusable button library enforcing 48x48dp minimum touch targets, M3 styling,
// and consistent haptic feedback across the app. All variants support loading and disabled states.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Minimum MD3-compliant touch target size (48x48dp).
const double kMinTouchTarget = 48.0;

/// Standardized button height for primary actions.
const double kButtonHeight = 48.0;

/// Standardized corner radius for app buttons (M3 full-round for buttons).
const double kButtonRadius = 24.0;

/// Triggers light-impact haptic feedback for standard taps.
void triggerLightHaptic() {
  HapticFeedback.lightImpact();
}

/// Triggers medium-impact haptic feedback for primary/confirm actions.
void triggerMediumHaptic() {
  HapticFeedback.mediumImpact();
}

/// Triggers selection-click haptic feedback for subtle interactions.
void triggerSelectionHaptic() {
  HapticFeedback.selectionClick();
}

/// Builds the base [ButtonStyle] enforcing MD3 touch targets and shape.
ButtonStyle buildBaseButtonStyle({
  Color? backgroundColor,
  Color? foregroundColor,
  EdgeInsetsGeometry? padding,
}) {
  return ButtonStyle(
    minimumSize: WidgetStateProperty.all(
      const Size(kMinTouchTarget, kButtonHeight),
    ),
    padding: WidgetStateProperty.all(
      padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    ),
    shape: WidgetStateProperty.all(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kButtonRadius),
      ),
    ),
    backgroundColor:
        backgroundColor != null ? WidgetStateProperty.all(backgroundColor) : null,
    foregroundColor:
        foregroundColor != null ? WidgetStateProperty.all(foregroundColor) : null,
    tapTargetSize: MaterialTapTargetSize.padded,
  );
}

/// Wraps a label with an optional loading indicator for button content.
Widget buildButtonContent({
  required String label,
  required bool isLoading,
  Widget? leadingIcon,
  TextStyle? textStyle,
}) {
  if (isLoading) {
    return const SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(strokeWidth: 2.5),
    );
  }
  if (leadingIcon != null) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        leadingIcon,
        const SizedBox(width: 8),
        Flexible(child: Text(label, style: textStyle, overflow: TextOverflow.ellipsis)),
      ],
    );
  }
  return Text(label, style: textStyle, overflow: TextOverflow.ellipsis);
}

/// Primary M3 FilledButton with enforced 48dp touch target and medium haptics.
class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.leadingIcon,
    this.semanticLabel,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;
  final Widget? leadingIcon;
  final String? semanticLabel;

  /// Handles press with medium haptic feedback and loading guard.
  void handlePress() {
    if (isLoading || !isEnabled || onPressed == null) return;
    triggerMediumHaptic();
    onPressed!();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: isEnabled && !isLoading,
      label: semanticLabel ?? label,
      child: FilledButton(
        onPressed: (isEnabled && !isLoading) ? handlePress : null,
        style: buildBaseButtonStyle(),
        child: buildButtonContent(
          label: label,
          isLoading: isLoading,
          leadingIcon: leadingIcon,
        ),
      ),
    );
  }
}

/// Secondary M3 OutlinedButton with enforced 48dp touch target and light haptics.
class AppSecondaryButton extends StatelessWidget {
  const AppSecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.leadingIcon,
    this.semanticLabel,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;
  final Widget? leadingIcon;
  final String? semanticLabel;

  /// Handles press with light haptic feedback and loading guard.
  void handlePress() {
    if (isLoading || !isEnabled || onPressed == null) return;
    triggerLightHaptic();
    onPressed!();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: isEnabled && !isLoading,
      label: semanticLabel ?? label,
      child: OutlinedButton(
        onPressed: (isEnabled && !isLoading) ? handlePress : null,
        style: buildBaseButtonStyle(),
        child: buildButtonContent(
          label: label,
          isLoading: isLoading,
          leadingIcon: leadingIcon,
        ),
      ),
    );
  }
}

/// Tertiary M3 TextButton with enforced 48dp touch target and selection haptics.
class AppTertiaryButton extends StatelessWidget {
  const AppTertiaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isEnabled = true,
    this.leadingIcon,
    this.semanticLabel,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isEnabled;
  final Widget? leadingIcon;
  final String? semanticLabel;

  /// Handles press with selection haptic feedback.
  void handlePress() {
    if (!isEnabled || onPressed == null) return;
    triggerSelectionHaptic();
    onPressed!();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: isEnabled,
      label: semanticLabel ?? label,
      child: TextButton(
        onPressed: isEnabled ? handlePress : null,
        style: buildBaseButtonStyle(),
        child: buildButtonContent(
          label: label,
          isLoading: false,
          leadingIcon: leadingIcon,
        ),
      ),
    );
  }
}

/// Destructive M3 FilledButton.tonal styled with error colors and medium haptics.
class AppDestructiveButton extends StatelessWidget {
  const AppDestructiveButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.leadingIcon,
    this.semanticLabel,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;
  final Widget? leadingIcon;
  final String? semanticLabel;

  /// Handles press with medium haptic feedback and loading guard.
  void handlePress() {
    if (isLoading || !isEnabled || onPressed == null) return;
    triggerMediumHaptic();
    onPressed!();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      enabled: isEnabled && !isLoading,
      label: semanticLabel ?? label,
      child: FilledButton(
        onPressed: (isEnabled && !isLoading) ? handlePress : null,
        style: buildBaseButtonStyle(
          backgroundColor: colorScheme.error,
          foregroundColor: colorScheme.onError,
        ),
        child: buildButtonContent(
          label: label,
          isLoading: isLoading,
          leadingIcon: leadingIcon,
        ),
      ),
    );
  }
}

/// M3 IconButton with guaranteed 48x48dp touch target and selection haptics.
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.isEnabled = true,
    this.tooltip,
    this.semanticLabel,
  });

  final Widget icon;
  final VoidCallback? onPressed;
  final bool isEnabled;
  final String? tooltip;
  final String? semanticLabel;

  /// Handles press with selection haptic feedback.
  void handlePress() {
    if (!isEnabled || onPressed == null) return;
    triggerSelectionHaptic();
    onPressed!();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: isEnabled,
      label: semanticLabel ?? tooltip,
      child: IconButton(
        onPressed: isEnabled ? handlePress : null,
        icon: icon,
        tooltip: tooltip,
        constraints: const BoxConstraints(
          minWidth: kMinTouchTarget,
          minHeight: kMinTouchTarget,
        ),
        style: IconButton.styleFrom(
          tapTargetSize: MaterialTapTargetSize.padded,
        ),
      ),
    );
  }
}
