// PFLE-011-13 — RTL Localization Configuration and Auto-Mirror Setup.
// Defines localization API with automatic RTL mirroring, flexible container widths, font scaling, and Material 3 touch targets (48dp).

import 'package:flutter/material.dart';

/// Mock data representing the Localization API response including RTL metadata.
class LocalizationApiMock {
  static const Map<String, dynamic> rtlMetadata = {
    'locale': 'ar',
    'isRtl': true,
    'languageName': 'Arabic',
    'fontScaleFactor': 1.1,
    'directionality': 'rtl',
  };

  static const Map<String, dynamic> ltrMetadata = {
    'locale': 'en',
    'isRtl': false,
    'languageName': 'English',
    'fontScaleFactor': 1.0,
    'directionality': 'ltr',
  };
}

/// Configuration model for localization settings derived from API.
class LocalizationConfig {
  final String locale;
  final bool isRtl;
  final String languageName;
  final double fontScaleFactor;
  final TextDirection directionality;

  const LocalizationConfig({
    required this.locale,
    required this.isRtl,
    required this.languageName,
    required this.fontScaleFactor,
    required this.directionality,
  });

  factory LocalizationConfig.fromMap(Map<String, dynamic> map) {
    return LocalizationConfig(
      locale: map['locale'] as String? ?? 'en',
      isRtl: map['isRtl'] as bool? ?? false,
      languageName: map['languageName'] as String? ?? 'English',
      fontScaleFactor: (map['fontScaleFactor'] as num?)?.toDouble() ?? 1.0,
      directionality: map['directionality'] == 'rtl'
          ? TextDirection.rtl
          : TextDirection.ltr,
    );
  }
}

/// InheritedWidget to propagate localization and RTL configuration down the tree.
class LocalizationScope extends InheritedWidget {
  final LocalizationConfig config;

  const LocalizationScope({
    super.key,
    required this.config,
    required super.child,
  });

  static LocalizationScope of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<LocalizationScope>();
    assert(scope != null, 'No LocalizationScope found in context');
    return scope!;
  }

  @override
  bool updateShouldNotify(LocalizationScope oldWidget) {
    return config.locale != oldWidget.config.locale ||
        config.isRtl != oldWidget.config.isRtl ||
        config.fontScaleFactor != oldWidget.config.fontScaleFactor;
  }
}

/// A wrapper widget that automatically mirrors its child based on RTL metadata.
/// Implements the requirement: "Components auto-mirror for RTL".
class RtlAutoMirror extends StatelessWidget {
  final Widget child;

  const RtlAutoMirror({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final config = LocalizationScope.of(context).config;
    return Directionality(
      textDirection: config.directionality,
      child: child,
    );
  }
}

/// A flexible container that adapts width constraints for longer words in different languages.
/// Implements the requirement: "Flexible container widths for longer words".
class FlexibleTextContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const FlexibleTextContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minWidth: 120),
      padding: padding,
      child: child,
    );
  }
}

/// Applies font scaling based on the current language configuration.
/// Implements the requirement: "Font scaling based on language".
class ScaledText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final int? maxLines;
  final TextAlign? textAlign;

  const ScaledText(
    this.text, {
    super.key,
    this.style,
    this.maxLines,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    final config = LocalizationScope.of(context).config;
    final baseStyle = style ?? Theme.of(context).textTheme.bodyMedium;
    final scaledStyle = baseStyle?.copyWith(
      fontSize: (baseStyle.fontSize ?? 14.0) * config.fontScaleFactor,
    );

    return Text(
      text,
      style: scaledStyle,
      maxLines: maxLines,
      textAlign: textAlign,
    );
  }
}

/// Notification close target adhering to minimum touch area parameters (48dp×48dp).
/// Implements the requirement: "Minimum touch area parameters on notification closing targets (48dp×48dp)".
class NotificationCloseTarget extends StatelessWidget {
  final VoidCallback onClose;

  const NotificationCloseTarget({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Close notification',
      button: true,
      child: SizedBox(
        width: 48.0,
        height: 48.0,
        child: InkWell(
          onTap: onClose,
          borderRadius: BorderRadius.circular(24.0),
          child: const Center(
            child: Icon(
              Icons.close_rounded,
              size: 24.0,
            ),
          ),
        ),
      ),
    );
  }
}

/// Contextual visual layer anchoring update notices cleanly to related screen items.
/// Implements the requirement: "Use contextual visual layers to anchor update notices cleanly to related screen items".
class UpdateNoticeAnchor extends StatelessWidget {
  final String message;
  final VoidCallback onDismiss;

  const UpdateNoticeAnchor({
    super.key,
    required this.message,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2.0,
      borderRadius: BorderRadius.circular(8.0),
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: ScaledText(
                message,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
              ),
            ),
            const SizedBox(width: 8.0),
            NotificationCloseTarget(onClose: onDismiss),
          ],
        ),
      ),
    );
  }
}

/// Process Execution Quality Score evaluator mapping qualitative output to quantitative metrics.
/// Floor Boundary: ≥90%, Optimal Target: ≥98%, Ceiling Boundary: 1 (100%).
class ProcessExecutionQualityEvaluator {
  static const double floorBoundary = 0.90;
  static const double optimalTarget = 0.98;
  static const double ceilingBoundary = 1.0;

  /// Evaluates the score and returns the ISO 9001:2015 qualitative rating.
  static String evaluate(double score) {
    if (score >= ceilingBoundary) return 'Good (100%)';
    if (score >= optimalTarget) return 'Good';
    if (score >= floorBoundary) return 'Average';
    return 'Poor';
  }

  /// Validates completeness at 100% with no orphaned values (1:1 mapping).
  static bool validateMappingCompleteness(
      Map<String, String> expected, Map<String, String> actual) {
    if (expected.length != actual.length) return false;
    for (final key in expected.keys) {
      if (!actual.containsKey(key)) return false;
    }
    return true;
  }
}
