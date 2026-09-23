// RCGLA-030-A11 — Atomic Base Elements Scaffolding.
// Provides reusable, mobile-first Material 3 atomic components (Buttons, Typography, Icons) with strict 48x48dp touch targets, ripple animations, and standardized border radii.

import 'package:flutter/material.dart';

/// Data model representing an atomic component definition.
class AtomicComponentDefinition {
  final String definitionId;
  final String definitionName;
  final String definitionType;
  final Map<String, dynamic> definitionParameters;
  final bool validationStatus;

  const AtomicComponentDefinition({
    required this.definitionId,
    required this.definitionName,
    required this.definitionType,
    required this.definitionParameters,
    required this.validationStatus,
  });

  Map<String, dynamic> toJson() => {
        'definition_id': definitionId,
        'definition_name': definitionName,
        'definition_type': definitionType,
        'definition_parameters': definitionParameters,
        'validation_status': validationStatus,
      };

  factory AtomicComponentDefinition.fromJson(Map<String, dynamic> json) {
    return AtomicComponentDefinition(
      definitionId: json['definition_id'] as String? ?? '',
      definitionName: json['definition_name'] as String? ?? '',
      definitionType: json['definition_type'] as String? ?? '',
      definitionParameters:
          (json['definition_parameters'] as Map<String, dynamic>?) ?? {},
      validationStatus: json['validation_status'] as bool? ?? false,
    );
  }
}

/// Mock data repository for atomic component definitions.
class AtomicMockRepository {
  static const List<Map<String, dynamic>> _mockDefinitions = [
    {
      'definition_id': 'ATM-BTN-001',
      'definition_name': 'Primary Action Button',
      'definition_type': 'Button',
      'definition_parameters': {'min_height': 48.0, 'min_width': 48.0},
      'validation_status': true,
    },
    {
      'definition_id': 'ATM-TYP-001',
      'definition_name': 'Body Medium Text',
      'definition_type': 'Typography',
      'definition_parameters': {'font_size': 14.0, 'line_height': 1.5},
      'validation_status': true,
    },
    {
      'definition_id': 'ATM-ICO-001',
      'definition_name': 'Standard Icon',
      'definition_type': 'Icon',
      'definition_parameters': {'size': 24.0},
      'validation_status': true,
    },
  ];

  static List<AtomicComponentDefinition> getDefinitions() {
    return _mockDefinitions
        .map((json) => AtomicComponentDefinition.fromJson(json))
        .toList();
  }
}

/// Serialization logic converting local rejection objects into JSON structure.
class AtomicSerializationLogic {
  static String serializeRejection({
    required String definitionId,
    required String reason,
    required DateTime timestamp,
  }) {
    final Map<String, dynamic> rejectionObject = {
      'definition_id': definitionId,
      'rejection_reason': reason,
      'timestamp': timestamp.toIso8601String(),
      'status': 'Rejected',
    };
    // Converting to standard JSON string representation
    return rejectionObject.toString();
  }
}

/// Standardized border radii for interactive container surfaces.
class AtomicBorderRadii {
  static const BorderRadius small = BorderRadius.all(Radius.circular(4.0));
  static const BorderRadius medium = BorderRadius.all(Radius.circular(8.0));
  static const BorderRadius large = BorderRadius.all(Radius.circular(16.0));
}

/// Atomic Button enforcing minimum 48x48dp interactive touch target perimeter.
class AtomicButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final AtomicComponentDefinition? definition;

  const AtomicButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.definition,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Enforce Poka-Yoke structural constraints preventing custom dimensions
    // below the 48x48dp mobile minimum touch target.
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 48.0,
        minHeight: 48.0,
      ),
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: AtomicBorderRadii.medium,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          textStyle: theme.textTheme.labelLarge,
          // Responsive ripple animations are handled natively by Material 3 Inkwell
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20.0),
              const SizedBox(width: 8.0),
            ],
            Text(label),
          ],
        ),
      ),
    );
  }
}

/// Atomic Typography matching font alignments with standard baseline rules.
class AtomicText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const AtomicText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style ?? Theme.of(context).textTheme.bodyMedium,
      textAlign: textAlign ?? TextAlign.start,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

/// Atomic Icon wrapped in a standardized touch target for high-speed operation models.
class AtomicIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String tooltip;

  const AtomicIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip = '',
  });

  @override
  Widget build(BuildContext context) {
    // Ensures 48x48dp hit scope
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon),
      tooltip: tooltip,
      iconSize: 24.0,
      padding: const EdgeInsets.all(12.0),
      constraints: const BoxConstraints(
        minWidth: 48.0,
        minHeight: 48.0,
      ),
    );
  }
}

/// Interactive container surface applying proper border radii and ripple states.
class AtomicContainer extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  const AtomicContainer({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = borderRadius ?? AtomicBorderRadii.medium;

    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: effectiveRadius,
      child: InkWell(
        onTap: onTap,
        borderRadius: effectiveRadius,
        splashColor: Theme.of(context).colorScheme.primary.withOpacity(0.12),
        highlightColor: Theme.of(context).colorScheme.primary.withOpacity(0.08),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16.0),
          child: child,
        ),
      ),
    );
  }
}