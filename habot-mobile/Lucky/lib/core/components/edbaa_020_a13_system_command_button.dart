// EDBAA-020-A13 — System Command Lexicon Button & UI Copy Purge Gate.
// Material 3 command button with explicit system verbs, banned human narrative verb validation, responsive padding, progress overlay, and outline emphasis.

import 'package:flutter/material.dart';

class SystemLexicon {
  SystemLexicon._();

  static const List<String> bannedHumanActionVerbs = <String>[
    'discover',
    'explore',
    'journey',
    'unlock',
    'embark',
    'story',
    'adventure',
    'learn more',
    'get started',
  ];

  static bool isCompliant(String text) {
    final String normalized = text.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), ' ').trim();
    final Set<String> tokens = normalized.isEmpty ? <String>{} : normalized.split(' ').toSet();
    return bannedHumanActionVerbs.every((String verb) => !tokens.contains(verb));
  }

  static String? validationMessage(String text) {
    if (text.trim().isEmpty) return 'System command text is required.';
    if (!isCompliant(text)) return 'Banned human-action vocabulary detected: $text';
    return null;
  }
}

class SystemCommandButton extends StatelessWidget {
  const SystemCommandButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.outlined = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    assert(
      SystemLexicon.isCompliant(label),
      'SystemCommandButton label contains banned human-action vocabulary: $label',
    );

    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final RoundedRectangleBorder shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    );
    final EdgeInsetsGeometry padding = const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 14,
    );

    final Widget labelContent = AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      child: isLoading
          ? SizedBox(
              key: const ValueKey<String>('loading'),
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: scheme.onPrimary,
              ),
            )
          : Text(
              label,
              key: ValueKey<String>(label),
              textAlign: TextAlign.center,
              style: textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
    );

    final Widget button = outlined
        ? OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: scheme.primary,
              padding: padding,
              shape: shape,
              side: BorderSide(color: scheme.outline, width: 1.25),
              textStyle: textTheme.labelLarge,
            ),
            child: labelContent,
          )
        : FilledButton(
            onPressed: isLoading ? null : onPressed,
            style: FilledButton.styleFrom(
              foregroundColor: scheme.onPrimary,
              backgroundColor: scheme.primary,
              padding: padding,
              shape: shape,
              textStyle: textTheme.labelLarge,
            ),
            child: labelContent,
          );

    return Semantics(
      button: true,
      label: label,
      enabled: onPressed != null && !isLoading,
      child: Stack(
        children: <Widget>[
          button,
          if (isLoading)
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: scheme.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
