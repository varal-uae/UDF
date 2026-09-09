// BCDLD-004-15 — Automated binary choice layout with strict Boolean validation and absolute upload size guard.
// Converts subjective review steps into minimal two-option UI inside accessible thumb comfort boundaries and dynamically shows elements by active rule criteria path.

import 'package:flutter/material.dart';

/// Layout type enum for the mobile application.
enum Bcdld00415LayoutType {
  singleColumn,
  twoColumn,
  adaptive,
}

/// Layout validation status.
enum Bcdld00415LayoutValidationStatus {
  pending,
  valid,
  invalid,
}

/// Immutable layout definition matching the atomic data fields.
@immutable
class Bcdld00415LayoutDefinition {
  const Bcdld00415LayoutDefinition({
    required this.layoutType,
    required this.gridDimensions,
    required this.spacingRules,
    required this.alignmentSettings,
    required this.validationStatus,
  });

  /// Layout type.
  final Bcdld00415LayoutType layoutType;

  /// Layout grid dimensions in logical pixels.
  final Size gridDimensions;

  /// Unified spacing rule value.
  final double spacingRules;

  /// Alignment settings.
  final Alignment alignmentSettings;

  /// Layout validation status.
  final Bcdld00415LayoutValidationStatus validationStatus;

  /// Material 3 minimum touch target size.
  static const double minTouchTarget = 48.0;

  /// Thumb comfort margin from screen edges.
  static const double thumbComfortMargin = 16.0;

  bool get isValidationPassed =>
      validationStatus == Bcdld00415LayoutValidationStatus.valid;
}

/// Guard for the absolute maximum file size threshold.
class Bcdld00415FileSizeGuard {
  /// Absolute maximum file size, set to 10 MiB.
  static const int absoluteMaximumFileBytes = 10 * 1024 * 1024;

  /// Returns true when the upload request is within the allowed limit.
  static bool isUploadAllowed(int fileSizeBytes) {
    if (fileSizeBytes < 0) return false;
    return fileSizeBytes <= absoluteMaximumFileBytes;
  }

  /// Returns an error message when the file must be rejected, otherwise an empty string.
  static String validate(int fileSizeBytes) {
    if (!isUploadAllowed(fileSizeBytes)) {
      return 'Upload rejected: file exceeds absolute maximum size of '
          '${(absoluteMaximumFileBytes / (1024 * 1024)).toStringAsFixed(0)} MB.';
    }
    return '';
  }
}

/// Strict Boolean validation guard for transaction submissions.
class Bcdld00415BooleanGuard {
  /// A null or false value is treated as false under strict validation.
  static bool validate(bool? value) => value ?? false;

  /// Enforces exactly one active selection across two binary choices.
  static bool hasStrictSelection(bool? first, bool? second) {
    return (first ?? false) ^ (second ?? false);
  }
}

/// Dynamically shows a child only when the active rule criteria path matches.
class Bcdld00415DynamicVisibility extends StatelessWidget {
  const Bcdld00415DynamicVisibility({
    super.key,
    required this.ruleCriteriaPath,
    required this.activeRuleCriteriaPath,
    required this.child,
  });

  /// Path identifier for this widget's rule criteria.
  final String ruleCriteriaPath;

  /// Currently selected rule criteria path.
  final String activeRuleCriteriaPath;

  /// Child to display when paths match.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ruleCriteriaPath == activeRuleCriteriaPath
        ? child
        : const SizedBox.shrink();
  }
}

/// Minimal binary choice control placed within accessible thumb comfort boundaries.
class Bcdld00415BinaryChoice extends StatelessWidget {
  const Bcdld00415BinaryChoice({
    super.key,
    required this.firstLabel,
    required this.secondLabel,
    required this.selectedValue,
    required this.onChanged,
    this.enabled = true,
  });

  /// Label for the first option, mapped to false.
  final String firstLabel;

  /// Label for the second option, mapped to true.
  final String secondLabel;

  /// Currently selected value: null = none, false = first, true = second.
  final bool? selectedValue;

  /// Callback with the new Boolean value when a choice is tapped.
  final ValueChanged<bool> onChanged;

  /// Whether the binary choice is interactive.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return SafeArea(
      minimum: const EdgeInsets.all(
        Bcdld00415LayoutDefinition.thumbComfortMargin,
      ),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: _buildChoice(
                  context: context,
                  label: firstLabel,
                  value: false,
                  selected: selectedValue == false,
                  colors: colors,
                ),
              ),
              const SizedBox(
                width: Bcdld00415LayoutDefinition.thumbComfortMargin,
              ),
              Expanded(
                child: _buildChoice(
                  context: context,
                  label: secondLabel,
                  value: true,
                  selected: selectedValue == true,
                  colors: colors,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChoice({
    required BuildContext context,
    required String label,
    required bool value,
    required bool selected,
    required ColorScheme colors,
  }) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: OutlinedButton(
        onPressed: enabled ? () => onChanged(value) : null,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(
            Bcdld00415LayoutDefinition.minTouchTarget,
            Bcdld00415LayoutDefinition.minTouchTarget,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor:
              selected ? colors.primaryContainer : colors.surface,
          foregroundColor:
              selected ? colors.onPrimaryContainer : colors.onSurface,
          side: BorderSide(
            color: selected ? colors.primary : colors.outline,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
