// SCTSS-010-A16 — Empty State Boilerplate Component for Dashboards.
// Provides a universal, centered empty state layout with illustration placeholder, descriptive text, and thumb-reachable CTA for dashboards returning 0 rows. Enforces prop-driven usage to prevent blank screens.

import 'package:flutter/material.dart';

/// A reusable empty state component designed for dashboard views.
/// Developers must provide required props; this component is intended
/// to be hard-coded into base table/list wrappers as a Poka-Yoke measure.
class EmptyStateBoilerplate extends StatelessWidget {
  /// The primary message displayed when no data is available.
  final String title;

  /// Optional secondary descriptive text providing context or guidance.
  final String? subtitle;

  /// The label for the primary call-to-action button.
  final String ctaLabel;

  /// Callback triggered when the user taps the primary CTA.
  final VoidCallback onCtaPressed;

  /// Optional icon displayed above the title. Defaults to a standardized inbox icon.
  final IconData? icon;

  /// Whether the primary CTA should pulse gently to visually chase the user to initiate action.
  final bool pulseCta;

  const EmptyStateBoilerplate({
    super.key,
    required this.title,
    this.subtitle,
    required this.ctaLabel,
    required this.onCtaPressed,
    this.icon,
    this.pulseCta = true,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // Illustration / Icon Placeholder
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon ?? Icons.inbox_outlined,
                size: 64,
                color: colorScheme.primary.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              title,
              textAlign: TextAlign.center,
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),

            // Subtitle (Optional)
            if (subtitle != null && subtitle!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],

            const SizedBox(height: 32),

            // Primary CTA (Thumb-reachable, Material 3 FilledButton)
            pulseCta
                ? _PulsingCtaButton(
                    label: ctaLabel,
                    onPressed: onCtaPressed,
                    colorScheme: colorScheme,
                  )
                : FilledButton(
                    onPressed: onCtaPressed,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                      textStyle: textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: Text(ctaLabel),
                  ),
          ],
        ),
      ),
    );
  }
}

/// Internal widget that applies a gentle pulsing animation to the CTA
/// to visually guide the user toward data entry initiation.
class _PulsingCtaButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final ColorScheme colorScheme;

  const _PulsingCtaButton({
    required this.label,
    required this.onPressed,
    required this.colorScheme,
  });

  @override
  State<_PulsingCtaButton> createState() => _PulsingCtaButtonState();
}

class _PulsingCtaButtonState extends State<_PulsingCtaButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.04).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: child,
          ),
        );
      },
      child: FilledButton(
        onPressed: widget.onPressed,
        style: FilledButton.styleFrom(
          minimumSize: const Size(double.infinity, 48),
          backgroundColor: widget.colorScheme.primary,
          foregroundColor: widget.colorScheme.onPrimary,
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        child: Text(widget.label),
      ),
    );
  }
}

/// Mock deployment data structure for validating empty state triggers
/// in local development environments without backend connectivity.
class MockDeploymentRecord {
  final String deploymentStatus;
  final String deploymentEnvironment;
  final DateTime deploymentDate;
  final String deploymentVersion;
  final String rollbackStatus;

  const MockDeploymentRecord({
    required this.deploymentStatus,
    required this.deploymentEnvironment,
    required this.deploymentDate,
    required this.deploymentVersion,
    required this.rollbackStatus,
  });

  Map<String, dynamic> toJson() => {
        'deployment_status': deploymentStatus,
        'deployment_environment': deploymentEnvironment,
        'deployment_date': deploymentDate.toIso8601String(),
        'deployment_version': deploymentVersion,
        'rollback_status': rollbackStatus,
      };
}

/// Returns an intentionally empty list to simulate a 0-row dashboard response
/// for testing the [EmptyStateBoilerplate] component locally.
List<MockDeploymentRecord> getMockEmptyDeployments() {
  return const <MockDeploymentRecord>[];
}