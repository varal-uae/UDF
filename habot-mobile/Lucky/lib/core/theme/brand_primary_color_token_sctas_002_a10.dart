// SCTAS-002-A10 — Primary Brand Color Token Configuration.
// Hardcodes the primary brand color #2E86C1 across call-to-action component styling frameworks using Material 3 design tokens.

import 'package:flutter/material.dart';

/// Global primary brand color token as specified by Brand Identity Constraints.
const Color kBrandPrimaryColor = Color(0xFF2E86C1);

/// Derived on-primary text color ensuring accessibility contrast limits are preserved.
const Color kBrandOnPrimaryColor = Colors.white;

/// Rapid color transition duration for active touch components to emphasize responsiveness.
const Duration kBrandTouchTransitionDuration = Duration(milliseconds: 150);

/// Consistent layout padding rule based on 8px baseline grid.
const double kBrandBaselineGridUnit = 8.0;

/// Standardized layout padding derived from the 8px baseline grid.
const EdgeInsets kBrandComponentPadding = EdgeInsets.all(kBrandBaselineGridUnit * 2); // 16px

/// Generates a standardized [ThemeData] enforcing the primary brand color token
/// across all primary user selection actions and interactive control choices.
ThemeData buildBrandPrimaryTheme({Brightness brightness = Brightness.light}) {
  final ColorScheme colorScheme = ColorScheme.fromSeed(
    seedColor: kBrandPrimaryColor,
    brightness: brightness,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme.copyWith(
      primary: kBrandPrimaryColor,
      onPrimary: kBrandOnPrimaryColor,
    ),
    // Ensures critical transaction triggers match prominent contrast rules
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: kBrandPrimaryColor,
        foregroundColor: kBrandOnPrimaryColor,
        padding: kBrandComponentPadding,
        minimumSize: const Size(double.infinity, 48), // Expands to fill full layout column bounds on small devices
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kBrandBaselineGridUnit),
        ),
        animationDuration: kBrandTouchTransitionDuration,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: kBrandPrimaryColor,
        foregroundColor: kBrandOnPrimaryColor,
        padding: kBrandComponentPadding,
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kBrandBaselineGridUnit),
        ),
        animationDuration: kBrandTouchTransitionDuration,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: kBrandPrimaryColor,
        padding: kBrandComponentPadding,
        animationDuration: kBrandTouchTransitionDuration,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: kBrandPrimaryColor,
        side: const BorderSide(color: kBrandPrimaryColor, width: 1.5),
        padding: kBrandComponentPadding,
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kBrandBaselineGridUnit),
        ),
        animationDuration: kBrandTouchTransitionDuration,
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: kBrandPrimaryColor,
      foregroundColor: kBrandOnPrimaryColor,
      elevation: 4.0,
    ),
  );
}

/// A standardized primary action button micro-block acting as an adaptive component
/// across the entire interface landscape.
class BrandPrimaryActionButton extends StatelessWidget {
  const BrandPrimaryActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.expandToFillWidth = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool expandToFillWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: expandToFillWidth ? double.infinity : null,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: kBrandPrimaryColor,
          foregroundColor: kBrandOnPrimaryColor,
          padding: kBrandComponentPadding,
          animationDuration: kBrandTouchTransitionDuration,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kBrandBaselineGridUnit),
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: kBrandOnPrimaryColor,
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
    );
  }
}