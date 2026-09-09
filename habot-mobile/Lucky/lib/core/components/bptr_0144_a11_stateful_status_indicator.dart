// BPTR-0144-A11 — StatefulStatusIndicator for lead conversion micro-UX.
// Lightweight Material 3 status component that swaps borders and backgrounds on state events without spawning modal dialogs or multi-page redirects.
import 'package:flutter/material.dart';

enum LeadConversionStatus { idle, processing, success, failure, offline }

extension LeadConversionStatusDetails on LeadConversionStatus {
  String get label => switch (this) {
    LeadConversionStatus.idle => 'Idle',
    LeadConversionStatus.processing => 'Processing',
    LeadConversionStatus.success => 'Success',
    LeadConversionStatus.failure => 'Failure',
    LeadConversionStatus.offline => 'Offline',
  };

  IconData get icon => switch (this) {
    LeadConversionStatus.idle => Icons.circle_outlined,
    LeadConversionStatus.processing => Icons.sync,
    LeadConversionStatus.success => Icons.check_circle_outline,
    LeadConversionStatus.failure => Icons.error_outline,
    LeadConversionStatus.offline => Icons.cloud_off_outlined,
  };
}

class StatefulStatusIndicator extends StatelessWidget {
  const StatefulStatusIndicator({
    super.key,
    required this.status,
    this.label,
    this.size = 48,
  });

  final LeadConversionStatus status;
  final String? label;
  final double size;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final StatusStyle style = _styleFor(status, colors);
    return Semantics(
      label: label ?? status.label,
      value: status.name,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOutCubic,
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: style.background,
          border: Border.all(color: style.border, width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(status.icon, color: style.foreground, size: size * 0.5),
      ),
    );
  }

  StatusStyle _styleFor(LeadConversionStatus status, ColorScheme colors) {
    return switch (status) {
      LeadConversionStatus.idle => StatusStyle(
        background: colors.surfaceContainerHighest,
        border: colors.outlineVariant,
        foreground: colors.onSurfaceVariant,
      ),
      LeadConversionStatus.processing => StatusStyle(
        background: colors.tertiaryContainer,
        border: colors.tertiary,
        foreground: colors.onTertiaryContainer,
      ),
      LeadConversionStatus.success => StatusStyle(
        background: colors.primaryContainer,
        border: colors.primary,
        foreground: colors.onPrimaryContainer,
      ),
      LeadConversionStatus.failure => StatusStyle(
        background: colors.errorContainer,
        border: colors.error,
        foreground: colors.onErrorContainer,
      ),
      LeadConversionStatus.offline => StatusStyle(
        background: colors.surfaceContainerHighest,
        border: colors.outline,
        foreground: colors.onSurface,
      ),
    };
  }
}

class StatusStyle {
  const StatusStyle({
    required this.background,
    required this.border,
    required this.foreground,
  });

  final Color background;
  final Color border;
  final Color foreground;
}
