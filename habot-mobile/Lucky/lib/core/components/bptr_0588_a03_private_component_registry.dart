// BPTR-0588-A03 — Private UI Component Registry & Anti-Drift Gate.
// Centralizes loading of verified @habot/ui-components assets and rejects non-standard inline styling.

import 'package:flutter/material.dart';

/// Component keys allowed from the private @habot/ui-components registry.
enum HabotComponentKey {
  appBar,
  actionButton,
  dataCard,
  formField,
  verificationBanner,
  collectionGrid,
}

/// Enforces the BPTR-0588-A03 private package channel policy.
class HabotComponentRegistry {
  HabotComponentRegistry._();

  static const Set<String> verifiedKeys = {
    'appBar',
    'actionButton',
    'dataCard',
    'formField',
    'verificationBanner',
    'collectionGrid',
  };

  static bool isVerified(String key) => verifiedKeys.contains(key);

  static void assertVerified(String key) {
    if (!isVerified(key)) {
      throw FlutterError(
        'BPTR-0588-A03 registry violation: "$key" is not a verified private @habot/ui-components asset.',
      );
    }
  }

  /// Rejects custom inline styling overrides to preserve the standard layout structure.
  static void assertNoInlineStyling({Object? styleOverride, String? componentKey}) {
    if (styleOverride != null) {
      throw FlutterError(
        'BPTR-0588-A03 inline styling drift rejected for ${componentKey ?? 'unknown component'}.',
      );
    }
  }
}

/// Loads a verified UI block from the private package repository.
/// Production builds resolve from the private pub hosted channel; this local fallback
/// keeps the deterministic mapping available for offline compilation.
class PrivateComponentLoader extends StatelessWidget {
  const PrivateComponentLoader({
    super.key,
    required this.componentKey,
    this.args = const {},
  });

  final String componentKey;
  final Map<String, Object?> args;

  @override
  Widget build(BuildContext context) {
    HabotComponentRegistry.assertVerified(componentKey);
    HabotComponentRegistry.assertNoInlineStyling(
      styleOverride: args['style'],
      componentKey: componentKey,
    );

    return _fallbackFor(componentKey, args);
  }

  Widget _fallbackFor(String key, Map<String, Object?> args) {
    switch (key) {
      case 'appBar':
        return AppBar(
          title: Text(args['title'] as String? ?? ''),
        );
      case 'actionButton':
        return FilledButton(
          onPressed: args['onPressed'] as VoidCallback?,
          child: Text(args['label'] as String? ?? ''),
        );
      case 'dataCard':
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(args['title'] as String? ?? ''),
          ),
        );
      case 'formField':
        return TextFormField(
          decoration: InputDecoration(
            labelText: args['label'] as String?,
          ),
        );
      case 'verificationBanner':
        return MaterialBanner(
          content: Text(args['message'] as String? ?? ''),
          actions: const [SizedBox.shrink()],
        );
      case 'collectionGrid':
        return GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          children: List<Widget>.from(args['children'] as List? ?? const []),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
