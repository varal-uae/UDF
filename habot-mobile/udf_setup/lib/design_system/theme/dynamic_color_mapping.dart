/// AISS Step 107 -- GEN-01352
/// "Map system OS dynamic color variables to client-side theme tokens."
///
/// COLUMN NOTE, RECORDED: Setup Step (Action) and Setup Step Description are
/// the identical string on this row.
///
/// METRIC MISMATCH, RECORDED. The sheet gives this row "OS Theming
/// Compatibility Rate". Whether an operating system supplies a dynamic palette
/// at all, and what is in it, is a platform property; a client cannot move
/// that rate and no client-side suite can observe it. No number is invented.
///
/// WHAT THE CLIENT DOES OWN, and therefore what is gated:
///   1. Every OS-supplied colour lands on a DECLARED role, or is refused.
///   2. No unmapped colour reaches a widget.
///   3. The resulting scheme is RE-AUDITED for contrast -- because a palette
///      chosen from a user's wallpaper can break every ratio Step 105 just
///      measured, and a Material You palette that fails 4.5:1 is a Material
///      You palette this app must not use.
///
/// THE DECISION THIS ENCODES, stated so it can be argued with: when the OS
/// palette fails the audit, this app KEEPS ITS OWN TOKENS. Material You is a
/// preference; legible text is not. The fallback is recorded in
/// [HabotDynamicColorResult.rejectedPairs] rather than happening silently, so
/// "why didn't my phone's colours apply?" has an answer.
///
/// NO PACKAGE IS ADDED. `dynamic_color` cannot be resolved in this
/// environment, and more to the point it is not needed: the platform delivers
/// a `ColorScheme`, and mapping one onto `HabotColorScheme` is the whole job.
/// The caller supplies the scheme; where it came from is not this file's
/// business, which also makes it testable without a device.
library;

import 'package:flutter/material.dart';

import '../a11y/contrast.dart';
import '../a11y/contrast_audit.dart';
import '../tokens/color_tokens.dart';

/// Why an OS-supplied palette was not adopted.
enum HabotDynamicColorRejection {
  /// The platform gave no palette at all -- the common case on iOS and on
  /// Android below 12.
  notOffered,

  /// The palette omitted a role this design system declares.
  roleMissing,

  /// A pair fell below its WCAG floor.
  contrastFailure,

  /// A supplied colour is translucent, which would make its measured ratio
  /// depend on whatever happens to sit behind it.
  translucentToken,
}

/// The outcome of trying to adopt an OS palette.
@immutable
class HabotDynamicColorResult {
  const HabotDynamicColorResult({
    required this.adopted,
    required this.scheme,
    required this.rejections,
    required this.rejectedPairs,
    required this.mappedRoles,
  });

  /// True only when the palette was complete, opaque and audit-clean.
  final bool adopted;

  /// What to actually render with: the OS palette when [adopted], this
  /// project's own tokens otherwise. Never a half-applied mixture -- a scheme
  /// where some roles come from the OS and some do not is a scheme whose
  /// contrast nobody has measured.
  final HabotColorScheme scheme;

  final List<HabotDynamicColorRejection> rejections;

  /// Human-readable, e.g. 'onSurface on surface 3.11:1 (floor 4.5:1)'.
  final List<String> rejectedPairs;

  /// How many declared roles the OS palette actually supplied.
  final int mappedRoles;

  String get explanation {
    if (adopted) {
      return 'Adopted the OS palette: $mappedRoles roles mapped, every '
          'audited pair above its floor.';
    }
    if (rejections.contains(HabotDynamicColorRejection.notOffered)) {
      return 'The platform offered no dynamic palette; the design system '
          'tokens are in use.';
    }
    return 'Kept the design system tokens. '
        '${rejectedPairs.length} problem(s): ${rejectedPairs.join('; ')}';
  }

  Map<String, Object?> toJson() => <String, Object?>{
    'adopted': adopted,
    'mapped_roles': mappedRoles,
    'rejections': rejections
        .map((HabotDynamicColorRejection r) => r.name)
        .toList(),
    'rejected_pairs': rejectedPairs,
    'explanation': explanation,
  };
}

/// Maps a platform `ColorScheme` onto this project's declared roles.
class HabotDynamicColorMapping {
  const HabotDynamicColorMapping._();

  /// The one place the OS role names are tied to this project's role names.
  ///
  /// Every entry is a deliberate pairing. A role NOT in this map is a role the
  /// OS cannot set, which is why `outlineVariant` and the page-frame colours
  /// are absent: they are decorative tints this design system owns.
  static HabotColorScheme? map(ColorScheme? os) {
    if (os == null) {
      return null;
    }
    return HabotColorScheme(
      primary: os.primary,
      onPrimary: os.onPrimary,
      primaryContainer: os.primaryContainer,
      onPrimaryContainer: os.onPrimaryContainer,
      secondary: os.secondary,
      onSecondary: os.onSecondary,
      secondaryContainer: os.secondaryContainer,
      onSecondaryContainer: os.onSecondaryContainer,
      tertiary: os.tertiary,
      onTertiary: os.onTertiary,
      tertiaryContainer: os.tertiaryContainer,
      onTertiaryContainer: os.onTertiaryContainer,
      error: os.error,
      onError: os.onError,
      errorContainer: os.errorContainer,
      onErrorContainer: os.onErrorContainer,
      surface: os.surface,
      onSurface: os.onSurface,
      onSurfaceVariant: os.onSurfaceVariant,
      surfaceContainerLowest: os.surfaceContainerLowest,
      surfaceContainerLow: os.surfaceContainerLow,
      surfaceContainer: os.surfaceContainer,
      surfaceContainerHigh: os.surfaceContainerHigh,
      surfaceContainerHighest: os.surfaceContainerHighest,
      outline: os.outline,
      outlineVariant: os.outlineVariant,
      inverseSurface: os.inverseSurface,
      onInverseSurface: os.onInverseSurface,
    );
  }

  /// Map, audit, and decide.
  ///
  /// [fallback] is what this app renders with when the OS palette is not
  /// usable -- normally `HabotColors.light` or `HabotColors.dark`.
  static HabotDynamicColorResult resolve({
    required ColorScheme? osScheme,
    required HabotColorScheme fallback,
  }) {
    final HabotColorScheme? mapped = map(osScheme);
    if (mapped == null) {
      return HabotDynamicColorResult(
        adopted: false,
        scheme: fallback,
        rejections: const <HabotDynamicColorRejection>[
          HabotDynamicColorRejection.notOffered,
        ],
        rejectedPairs: const <String>[],
        mappedRoles: 0,
      );
    }

    final List<HabotDynamicColorRejection> rejections =
        <HabotDynamicColorRejection>[];
    final List<String> failed = <String>[];

    // 1. Completeness. A missing role is a widget falling back to a Material
    //    default nobody audited.
    final Set<String> declared = fallback.roles.keys.toSet();
    final Set<String> supplied = mapped.roles.keys.toSet();
    if (!supplied.containsAll(declared)) {
      rejections.add(HabotDynamicColorRejection.roleMissing);
      failed.addAll(
        declared
            .where((String r) => !supplied.contains(r))
            .map((String r) => 'role "$r" not supplied'),
      );
    }

    // 2. Opacity. Contrast is undefined against an unknown backdrop.
    for (final MapEntry<String, Color> e in mapped.roles.entries) {
      if (!Contrast.isOpaque(e.value)) {
        if (!rejections.contains(
          HabotDynamicColorRejection.translucentToken,
        )) {
          rejections.add(HabotDynamicColorRejection.translucentToken);
        }
        failed.add('role "${e.key}" is translucent');
      }
    }

    // 3. The re-audit. This is the reason this step exists at all.
    final List<String> contrastFailures = <String>[];
    for (final AuditPair p in <AuditPair>[
      ...ContrastAudit.textPairs,
      ...ContrastAudit.nonTextPairs,
    ]) {
      final Color? fg = mapped.roles[p.foreground];
      final Color? bg = mapped.roles[p.background];
      if (fg == null || bg == null) {
        continue;
      }
      final ContrastResult r = Contrast.evaluate(
        foregroundName: p.foreground,
        backgroundName: p.background,
        foreground: fg,
        background: bg,
        isText: p.isText,
      );
      if (!r.passes) {
        contrastFailures.add(
          '${p.foreground} on ${p.background} ${r.ratioLabel} '
          '(floor ${r.floor.toStringAsFixed(1)}:1)',
        );
      }
    }
    if (contrastFailures.isNotEmpty) {
      rejections.add(HabotDynamicColorRejection.contrastFailure);
      failed.addAll(contrastFailures);
    }

    final bool adopted = rejections.isEmpty;
    return HabotDynamicColorResult(
      adopted: adopted,
      scheme: adopted ? mapped : fallback,
      rejections: rejections,
      rejectedPairs: failed,
      mappedRoles: supplied.length,
    );
  }
}
