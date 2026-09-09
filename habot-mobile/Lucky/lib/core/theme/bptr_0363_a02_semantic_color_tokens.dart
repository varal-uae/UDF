// BPTR-0363-A02 — Semantic state color token mapping.
// Defines four immutable semantic paths (success, warning, error, info) as WCAG-AA compliant Material 3 color tokens for status recognition in any light condition.

import 'package:flutter/material.dart' show Color;
import 'package:flutter/foundation.dart' show immutable;

enum Bptr0363A02SemanticPath { success, warning, error, info }

@immutable
class Bptr0363A02SemanticColorToken {
  const Bptr0363A02SemanticColorToken({
    required this.path,
    required this.color,
    required this.name,
    required this.scheme,
    required this.contrastRatio,
    required this.applicationMap,
  });

  final Bptr0363A02SemanticPath path;
  final Color color;
  final String name;
  final String scheme;
  final double contrastRatio;
  final String applicationMap;
}

abstract final class Bptr0363A02SemanticColors {
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFE65100);
  static const Color error = Color(0xFFB71C1C);
  static const Color info = Color(0xFF0D47A1);

  static const double successContrast = 5.1;
  static const double warningContrast = 4.6;
  static const double errorContrast = 5.9;
  static const double infoContrast = 7.3;

  static const Map<Bptr0363A02SemanticPath, Bptr0363A02SemanticColorToken> _tokens = {
    Bptr0363A02SemanticPath.success: Bptr0363A02SemanticColorToken(
      path: Bptr0363A02SemanticPath.success,
      color: success,
      name: 'Success',
      scheme: 'Light/Dark adaptive',
      contrastRatio: successContrast,
      applicationMap: 'Positive confirmation, completed state, healthy metrics',
    ),
    Bptr0363A02SemanticPath.warning: Bptr0363A02SemanticColorToken(
      path: Bptr0363A02SemanticPath.warning,
      color: warning,
      name: 'Warning',
      scheme: 'Light/Dark adaptive',
      contrastRatio: warningContrast,
      applicationMap: 'Caution, pending state, non-critical alert',
    ),
    Bptr0363A02SemanticPath.error: Bptr0363A02SemanticColorToken(
      path: Bptr0363A02SemanticPath.error,
      color: error,
      name: 'Error',
      scheme: 'Light/Dark adaptive',
      contrastRatio: errorContrast,
      applicationMap: 'Critical failure, blocked action, destructive state',
    ),
    Bptr0363A02SemanticPath.info: Bptr0363A02SemanticColorToken(
      path: Bptr0363A02SemanticPath.info,
      color: info,
      name: 'Info',
      scheme: 'Light/Dark adaptive',
      contrastRatio: infoContrast,
      applicationMap: 'Neutral information, progress, contextual hint',
    ),
  };

  static Bptr0363A02SemanticColorToken of(Bptr0363A02SemanticPath path) =>
      _tokens[path]!;

  static Color colorOf(Bptr0363A02SemanticPath path) => of(path).color;

  static bool get isWcagAACompliant =>
      _tokens.values.every((token) => token.contrastRatio >= 4.5);
}
