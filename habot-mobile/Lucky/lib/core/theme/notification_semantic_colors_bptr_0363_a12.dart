// BPTR-0363-A12 — Semantic State Color Mapping for Notification Components.
// Provides ThemeExtension with WCAG AA compliant color tokens for notification states, mapping 1:1 to backend data states and supporting light/dark modes.
import 'package:flutter/material.dart';

enum NotificationState { success, warning, error, info, disabled }

@immutable
class NotificationStateColors {
  final Color background;
  final Color foreground;
  final Color border;

  const NotificationStateColors({
    required this.background,
    required this.foreground,
    required this.border,
  });
}

@immutable
class NotificationSemanticColors extends ThemeExtension<NotificationSemanticColors> {
  final Map<NotificationState, NotificationStateColors> stateColors;

  const NotificationSemanticColors({required this.stateColors});

  static const light = NotificationSemanticColors(
    stateColors: {
      NotificationState.success: NotificationStateColors(
        background: Color(0xFFE6F4EA),
        foreground: Color(0xFF1E4620),
        border: Color(0xFF34A853),
      ),
      NotificationState.warning: NotificationStateColors(
        background: Color(0xFFFEF7E0),
        foreground: Color(0xFF5C4400),
        border: Color(0xFFF9AB00),
      ),
      NotificationState.error: NotificationStateColors(
        background: Color(0xFFFCE8E6),
        foreground: Color(0xFF5C1A1A),
        border: Color(0xFFEA4335),
      ),
      NotificationState.info: NotificationStateColors(
        background: Color(0xFFE8F0FE),
        foreground: Color(0xFF1A3C6E),
        border: Color(0xFF4285F4),
      ),
      NotificationState.disabled: NotificationStateColors(
        background: Color(0xFFF1F3F4),
        foreground: Color(0xFF5F6368),
        border: Color(0xFFBDC1C6),
      ),
    },
  );

  static const dark = NotificationSemanticColors(
    stateColors: {
      NotificationState.success: NotificationStateColors(
        background: Color(0xFF0D2818),
        foreground: Color(0xFF81C995),
        border: Color(0xFF34A853),
      ),
      NotificationState.warning: NotificationStateColors(
        background: Color(0xFF3E2E04),
        foreground: Color(0xFFFDD663),
        border: Color(0xFFF9AB00),
      ),
      NotificationState.error: NotificationStateColors(
        background: Color(0xFF3C1512),
        foreground: Color(0xFFF28B82),
        border: Color(0xFFEA4335),
      ),
      NotificationState.info: NotificationStateColors(
        background: Color(0xFF0D2137),
        foreground: Color(0xFF8AB4F8),
        border: Color(0xFF4285F4),
      ),
      NotificationState.disabled: NotificationStateColors(
        background: Color(0xFF202124),
        foreground: Color(0xFF9AA0A6),
        border: Color(0xFF5F6368),
      ),
    },
  );

  NotificationStateColors colorsFor(NotificationState state) => stateColors[state]!;

  @override
  NotificationSemanticColors copyWith({Map<NotificationState, NotificationStateColors>? stateColors}) {
    return NotificationSemanticColors(stateColors: stateColors ?? this.stateColors);
  }

  @override
  NotificationSemanticColors lerp(ThemeExtension<NotificationSemanticColors>? other, double t) {
    if (other is! NotificationSemanticColors) return this;
    final merged = <NotificationState, NotificationStateColors>{};
    for (final state in NotificationState.values) {
      final a = stateColors[state]!;
      final b = other.stateColors[state]!;
      merged[state] = NotificationStateColors(
        background: Color.lerp(a.background, b.background, t)!,
        foreground: Color.lerp(a.foreground, b.foreground, t)!,
        border: Color.lerp(a.border, b.border, t)!,
      );
    }
    return NotificationSemanticColors(stateColors: merged);
  }
}

extension NotificationSemanticColorsContext on BuildContext {
  NotificationSemanticColors get notificationSemanticColors =>
      Theme.of(this).extension<NotificationSemanticColors>() ?? NotificationSemanticColors.light;
}