// DLQDP-003-16 — High-contrast type variants and clean item dividers.
// Provides WCAG 2.2 SC 1.4.3 (AA) / SC 1.4.6 (AAA)-aligned text styles and divider list for UIUX contrast requirements.

import 'package:flutter/material.dart';

class Dlqdp00316Contrast {
  const Dlqdp00316Contrast._();

  static double ratio(Color foreground, Color background) {
    final l1 = foreground.computeLuminance();
    final l2 = background.computeLuminance();
    final lighter = l1 > l2 ? l1 : l2;
    final darker = l1 > l2 ? l2 : l1;
    return (lighter + 0.05) / (darker + 0.05);
  }

  static bool meetsAa(double ratio) => ratio >= 4.5;
  static bool meetsAaa(double ratio) => ratio >= 7.0;
}

class Dlqdp00316HighContrastItem {
  const Dlqdp00316HighContrastItem({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;
}

class Dlqdp00316HighContrastTypeDividerList extends StatelessWidget {
  const Dlqdp00316HighContrastTypeDividerList({
    super.key,
    required this.items,
    this.dividerThickness = 1.0,
    this.dividerIndent = 16.0,
    this.dividerEndIndent = 16.0,
  });

  final List<Dlqdp00316HighContrastItem> items;
  final double dividerThickness;
  final double dividerIndent;
  final double dividerEndIndent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      itemCount: items.length,
      separatorBuilder: (context, index) => Divider(
        height: 1.0,
        thickness: dividerThickness,
        indent: dividerIndent,
        endIndent: dividerEndIndent,
        color: colorScheme.outlineVariant,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                item.subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}