// SCTAS-002-A08 — Primary Brand Color Token Configuration.
// Hardcodes the primary brand color #2E86C1 across call-to-action component styling frameworks using Material 3 ThemeData.

import 'package:flutter/material.dart';

/// Global brand color token as mandated by requirement SCTAS-002-A08.
/// Do not override or define local absolute color values for primary actions.
const Color kPrimaryBrandColor = Color(0xFF2E86C1);

/// Universal design system interaction utility package for brand identity constraints.
class BrandColorTokensSctas002A08 {
  BrandColorTokensSctas002A08._();

  /// Returns a fully configured [ThemeData] applying the primary brand color
  /// to all interactive components, adhering to an 8px baseline grid layout
  /// and seamless single-column scaling for mobile-first UX.
  static ThemeData get themeData {
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: kPrimaryBrandColor,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,

      // 8px baseline grid layout spacing rules
      visualDensity: VisualDensity.standard,

      // Primary action button configurations
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimaryBrandColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 48),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          textStyle: const TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: kPrimaryBrandColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 48),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: kPrimaryBrandColor,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: kPrimaryBrandColor,
          side: const BorderSide(color: kPrimaryBrandColor, width: 1.5),
          minimumSize: const Size(double.infinity, 48),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: kPrimaryBrandColor,
        foregroundColor: Colors.white,
        elevation: 4.0,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0.0,
        centerTitle: false,
      ),

      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: kPrimaryBrandColor, width: 2.0),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return kPrimaryBrandColor;
          return null;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return kPrimaryBrandColor.withOpacity(0.5);
          return null;
        }),
      ),

      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return kPrimaryBrandColor;
          return null;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
      ),

      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return kPrimaryBrandColor;
          return null;
        }),
      ),
    );
  }
}

/// Adaptive micro-block widget acting as a standardized primary call-to-action button.
/// Expands to fill full layout column bounds on small devices.
class PrimaryCallToAction extends StatelessWidget {
  const PrimaryCallToAction({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    // Enforces consistent layout padding rules (8px baseline)
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SizedBox(
        width: double.infinity, // Expands to fill full layout column bounds
        height: 48.0, // 6 * 8px baseline grid
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          child: isLoading
              ? const SizedBox(
                  width: 24.0,
                  height: 24.0,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.0,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(label),
        ),
      ),
    );
  }
}
