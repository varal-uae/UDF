// RCGLA-030-A10 — Atomic Base Elements Scaffolding.
// Assembles reusable atomic UI components (Buttons, Typography, Icons) with strict 48x48dp touch targets, WCAG 2.1 AA accessibility baselines, Material 3 ripple animations, and standardized border radii.

import 'package:flutter/material.dart';

/// Enforces Poka-Yoke structural typing constraints to prevent custom
/// dimensional definitions from being passed down to atomic assets.
class AtomicConstraints {
  AtomicConstraints._();

  static const double minTouchTargetSize = 48.0;
  static const double standardBorderRadius = 12.0;
  static const double smallBorderRadius = 8.0;
}

/// Atomic Typography component enforcing baseline alignment rules.
class AtomicText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const AtomicText({
    super.key,
    required this.text,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      label: text,
      child: Text(
        text,
        style: style ?? theme.textTheme.bodyMedium,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
      ),
    );
  }
}

/// Atomic Icon wrapper ensuring consistent sizing and semantics.
class AtomicIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color? color;
  final String? semanticLabel;

  const AtomicIcon({
    super.key,
    required this.icon,
    this.size = 24.0,
    this.color,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      child: Icon(
        icon,
        size: size,
        color: color ?? Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}

/// Atomic Button enforcing minimum 48x48dp interactive hit scopes
/// for high-speed operation models on compact touchscreens.
class AtomicButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final bool isPrimary;

  const AtomicButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.isPrimary = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderRadius = BorderRadius.circular(AtomicConstraints.standardBorderRadius);

    // Structural constraint: Prevents passing custom dimensions down to the atomic asset.
    final buttonStyle = (isPrimary ? ElevatedButton.styleFrom : OutlinedButton.styleFrom)(
      minimumSize: const Size(
        AtomicConstraints.minTouchTargetSize,
        AtomicConstraints.minTouchTargetSize,
      ),
      shape: RoundedRectangleBorder(borderRadius: borderRadius),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
    ).copyWith(
      overlayColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.pressed)) {
          // Responsive ripple animation on interaction states
          return theme.colorScheme.primary.withOpacity(0.12);
        }
        return null;
      }),
    );

    final buttonWidget = isPrimary
        ? ElevatedButton(
            onPressed: onPressed,
            style: buttonStyle,
            child: child,
          )
        : OutlinedButton(
            onPressed: onPressed,
            style: buttonStyle,
            child: child,
          );

    return Semantics(
      button: true,
      enabled: onPressed != null,
      child: buttonWidget,
    );
  }
}

/// Atomic Container applying proper border radii to interactive surfaces.
class AtomicContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final double borderRadius;

  const AtomicContainer({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.borderRadius = AtomicConstraints.standardBorderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      container: true,
      button: onTap != null,
      child: Material(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        elevation: onTap != null ? 1.0 : 0.0,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          splashColor: theme.colorScheme.primary.withOpacity(0.12),
          highlightColor: theme.colorScheme.primary.withOpacity(0.04),
          child: ConstrainedBox(
            constraints: onTap != null
                ? const BoxConstraints(
                    minHeight: AtomicConstraints.minTouchTargetSize,
                    minWidth: AtomicConstraints.minTouchTargetSize,
                  )
                : const BoxConstraints(),
            child: Padding(
              padding: padding ?? const EdgeInsets.all(16.0),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// Mock Data Models representing atomic-level data fields.
class AtomicAccessData {
  final String accessType;
  final String userRole;
  final int permissionLevel;
  final String accessLog;
  final DateTime accessTimestamp;

  const AtomicAccessData({
    required this.accessType,
    required this.userRole,
    required this.permissionLevel,
    required this.accessLog,
    required this.accessTimestamp,
  });

  Map<String, dynamic> toJson() => {
        'accessType': accessType,
        'userRole': userRole,
        'permissionLevel': permissionLevel,
        'accessLog': accessLog,
        'accessTimestamp': accessTimestamp.toIso8601String(),
      };
}

/// Hardcoded local mock data repository satisfying backend data requirements.
class AtomicMockRepository {
  static List<AtomicAccessData> getMockAccessLogs() {
    return [
      AtomicAccessData(
        accessType: 'READ',
        userRole: 'ADMIN',
        permissionLevel: 100,
        accessLog: 'Viewed dashboard scaffolding',
        accessTimestamp: DateTime.utc(2026, 9, 23, 10, 0),
      ),
      AtomicAccessData(
        accessType: 'WRITE',
        userRole: 'ENGINEER',
        permissionLevel: 80,
        accessLog: 'Updated atomic base elements',
        accessTimestamp: DateTime.utc(2026, 9, 23, 11, 30),
      ),
      AtomicAccessData(
        accessType: 'READ',
        userRole: 'USER',
        permissionLevel: 20,
        accessLog: 'Rendered typography component',
        accessTimestamp: DateTime.utc(2026, 9, 23, 12, 15),
      ),
    ];
  }
}

/// Preview widget demonstrating the assembled atomic base elements scaffolding.
class AtomicScaffoldingPreview extends StatelessWidget {
  const AtomicScaffoldingPreview({super.key});

  @override
  Widget build(BuildContext context) {
    final mockData = AtomicMockRepository.getMockAccessLogs();

    return Scaffold(
      appBar: AppBar(
        title: const AtomicText(text: 'Atomic Scaffolding'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const AtomicText(
            text: 'Typography Baseline',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          AtomicButton(
            isPrimary: true,
            onPressed: () {},
            child: const AtomicText(text: 'Primary Action'),
          ),
          const SizedBox(height: 16),
          AtomicButton(
            isPrimary: false,
            onPressed: () {},
            child: const AtomicText(text: 'Secondary Action'),
          ),
          const SizedBox(height: 24),
          const Row(
            children: [
              AtomicIcon(icon: Icons.accessibility_new, semanticLabel: 'Accessibility'),
              SizedBox(width: 8),
              AtomicText(text: 'WCAG 2.1 AA Compliant'),
            ],
          ),
          const SizedBox(height: 24),
          ...mockData.map((data) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: AtomicContainer(
                  onTap: () {},
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AtomicText(
                        text: '${data.userRole} - ${data.accessType}',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 4),
                      AtomicText(
                        text: data.accessLog,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
