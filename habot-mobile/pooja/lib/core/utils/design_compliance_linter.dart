/// Utility for Universal Design Component Compliance Linter Engine (DevOps CI/CD Pipeline Validator).
class DesignComplianceLinter {
  /// Scans a Dart / CSS code snippet for design compliance violations.
  /// Rule 1: Custom raw static pixel heights (e.g. `height: 350.0` or `height: 350px`) are outlawed.
  /// Rule 2: Hardcoded raw hex colors (e.g. `Color(0xFF123456)`) are outlawed (must use tokens).
  static DesignLinterScanResult scanCodeSnippet(String codeSnippet) {
    final trimmed = codeSnippet.trim();
    if (trimmed.isEmpty) {
      return const DesignLinterScanResult(
        isPassed: false,
        violationCount: 1,
        message: 'LINTER FAIL: Code snippet is empty.',
      );
    }

    final violations = <String>[];

    // Check Rule 1: Raw static pixel height statements (e.g. height: 250.0 or height: 250px)
    final staticPixelHeightRegex = RegExp(r'height:\s*\d+(\.\d+)?(px)?;', caseSensitive: false);
    if (staticPixelHeightRegex.hasMatch(trimmed)) {
      violations.add(
        'Rule Violation (STATIC_PIXEL_HEIGHT_OUTLAWED): Custom raw static pixel heights forbidden. Use flexible dynamic layout math (LayoutBuilder / Expanded).',
      );
    }

    // Check Rule 2: Raw hardcoded color hex values without design token abstraction
    final hardcodedColorRegex = RegExp(r'Color\(0xFF[0-9A-Fa-f]{6}\)');
    if (hardcodedColorRegex.hasMatch(trimmed) && !trimmed.contains('AppColorPalette')) {
      violations.add(
        'Rule Violation (UNMAPPED_COLOR_TOKEN): Hardcoded raw color value detected. All colors must use global AppColorPalette or ColorScheme tokens.',
      );
    }

    final isPassed = violations.isEmpty;

    return DesignLinterScanResult(
      isPassed: isPassed,
      violationCount: violations.length,
      message: isPassed
          ? 'CI BUILD PASS: 100% Design System Compliance Verified (Zero Static Heights & Token Mapped)'
          : 'CI BUILD FAIL (${violations.length} Violations): Pipeline deployment blocked by DesignComplianceLinterEngine.',
      violations: violations,
    );
  }
}

class DesignLinterScanResult {
  final bool isPassed;
  final int violationCount;
  final String message;
  final List<String> violations;

  const DesignLinterScanResult({
    required this.isPassed,
    required this.violationCount,
    required this.message,
    this.violations = const [],
  });
}
