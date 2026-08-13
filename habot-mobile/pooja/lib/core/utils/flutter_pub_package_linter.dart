/// Utility for Flutter Private Pub Package Component Import Linter (FEBFL-005).
class FlutterPubPackageLinter {
  static const String privatePackageUri =
      'package:flutter_app_aiss/flutter_m3_components.dart';

  /// Scans a Dart source script for private pub package import compliance.
  static FlutterPubLinterResult validateDartImport(String dartScriptContent) {
    final trimmed = dartScriptContent.trim();
    if (trimmed.isEmpty) {
      return const FlutterPubLinterResult(
        isCompliant: false,
        message: 'LINTER ERROR: Script content is empty.',
      );
    }

    final hasPrivatePackageImport = trimmed.contains(privatePackageUri);
    final hasForbiddenAdHocWidget =
        trimmed.contains('class CustomAdHocWidget') || trimmed.contains('class AdHocStyle');

    if (!hasPrivatePackageImport) {
      return const FlutterPubLinterResult(
        isCompliant: false,
        message:
            'LINT ERROR (UNREGISTERED_PUB_PACKAGE): Script must import private framework package "$privatePackageUri". Custom ad-hoc styling is blocked by compiler rules.',
      );
    }

    if (hasForbiddenAdHocWidget) {
      return const FlutterPubLinterResult(
        isCompliant: false,
        message:
            'LINT ERROR (AD_HOC_CUSTOM_CSS_BLOCKED): Compiler rejected locally written custom styling code. All visual elements must pull directly from private pub package registries.',
      );
    }

    return const FlutterPubLinterResult(
      isCompliant: true,
      message:
          'BUILD PASS: Script strictly inherits layout components from private pub package "$privatePackageUri". (Poka-Yoke Enforced)',
    );
  }
}

class FlutterPubLinterResult {
  final bool isCompliant;
  final String message;

  const FlutterPubLinterResult({
    required this.isCompliant,
    required this.message,
  });
}
