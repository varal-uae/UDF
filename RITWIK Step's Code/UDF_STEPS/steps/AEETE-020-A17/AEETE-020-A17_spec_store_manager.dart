// =============================================================================
// AEETE-020-A17 — GMRD Component Library Spec Storage
// Atomic Step: Store finalized specs in shared component library documentation
// Metric:      Implementation Completeness & Code Quality · Output=Complete
// Standard:    Component Governance Engineering
// Module:      spec_store_manager.dart
// Repo:        github.com/RitwikHC/theme-typography · branch: ritwik
// Author:      Ritwik Sharma — Frontend Integration Specialist | UDF Team
// Date:        25-Aug-2026
// Dependency:  S.No 2834 — Baseline layout tokens must be complete
// =============================================================================

/// The 8 required documentation sections per GMRD component.
/// sections_complete must equal 8 before storage permitted (EC:3 gate).
const List<String> kEightSections = [
  'overview',
  'props_api',
  'states_and_variants',
  'accessibility',
  'usage_guidelines',
  'dos_and_donts',
  'related_components',
  'change_log',
];

/// Section display headers for markdown assembly.
const Map<String, String> kSectionHeaders = {
  'overview':           '## 1. Overview',
  'props_api':          '## 2. Props / API',
  'states_and_variants':'## 3. States and Variants',
  'accessibility':      '## 4. Accessibility',
  'usage_guidelines':   '## 5. Usage Guidelines',
  'dos_and_donts':      "## 6. Do's and Don'ts",
  'related_components': '## 7. Related Components',
  'change_log':         '## 8. Change Log',
};

/// Atomic Design component type hierarchy.
enum GMRDComponentType { atom, molecule, organism, template }

/// GMRD component specification model.

/// Mandatory DCDF lineage headers — AEETE-018 standard.
/// These fields make this file's outputs traceable backward
/// through the pipeline to their origin source document.
class DcdfLineage {
  final String traceId;                // end-to-end transaction UUID
  final String originSourceId;         // originating system node UUID
  final String immediatePredecessorId; // direct upstream node UUID
  final String transformationLogicHash; // SHA-256 of executing EC logic
  final bool   complianceStatusInd;    // DCDF gate: true = passed

  const DcdfLineage({
    required this.traceId,
    required this.originSourceId,
    required this.immediatePredecessorId,
    required this.transformationLogicHash,
    this.complianceStatusInd = false,
  });
}

class GMRDComponentSpec {
  final String slug;
  final GMRDComponentType componentType;
  final Map<String, String> sections; // section_name → markdown content

  const GMRDComponentSpec({
    required this.slug,
    required this.componentType,
    required this.sections,
  });

  /// sections_complete — gate must equal 8 (EC:3).
  int get sectionsComplete =>
      kEightSections
          .where((s) => sections.containsKey(s) && sections[s]!.isNotEmpty)
          .length;

  bool get isReady => sectionsComplete == 8;

  /// Artifact path: docs/components/<type>/<slug>.md
  String get artifactPath =>
      'docs/components/${componentType.name}/$slug.md';

  /// EC:5 — Assemble all 8 sections into a single markdown document.  // error: EC-AEETE020A17-001
  String toMarkdown() {
    final buf = StringBuffer();
    buf.writeln('# ${_titleCase(slug)} Component Spec\n');
    for (final key in kEightSections) {
      buf.writeln('${kSectionHeaders[key]}\n');
      buf.writeln('${sections[key] ?? ''}\n');
    }
    return buf.toString();
  }

  String _titleCase(String s) =>
      s.split('-').map((w) => w[0].toUpperCase() + w.substring(1)).join(' ');
}

/// Result of storing and linting one artifact file.
class StorageResult {
  final String componentSlug;
  final String filePath;
  final int lintErrors; // gate: must equal 0

  const StorageResult({
    required this.componentSlug,
    required this.filePath,
    required this.lintErrors,
  });

  bool get lintPass => lintErrors == 0;
  String get syntaxCheckOutput => lintPass ? 'PASS' : 'FAIL';
}

/// Quality validation result — Implementation Completeness metric.
class SpecQualityResult {
  final double qualityRatePct;
  final String qualityOutput; // Complete / Partial / Not Complete
  final int filesClean;
  final int totalFiles;

  const SpecQualityResult({
    required this.qualityRatePct,
    required this.qualityOutput,
    required this.filesClean,
    required this.totalFiles,
  });

  bool get gatePass => qualityRatePct >= 80;
}

/// AEETE-020-A17: Spec storage manager.
///
/// Mirrors spec_store_manager.py — GMRDComponent + StorageResult dataclasses.
/// Manages compile → register → store → lint → quality → publish pipeline.
///
/// Usage:
/// ```dart
/// final manager = SpecStoreManager();
/// final compiled = manager.compileSpecSet(components); // gate: 8 sections each
/// final results  = manager.runLintCheck(compiled);
/// final quality  = manager.calculateQuality(results);
/// ```
class SpecStoreManager {
  static const double _floor   = 0.90;  // metric floor gate
  static const double _optimal = 0.97; // metric optimal target


  // ---------------------------------------------------------------------------
  // EC:3 — Compile spec set.  // error: EC-AEETE020A17-002
  // Gate: sectionsComplete == 8 per component. Throws if incomplete.
  // ---------------------------------------------------------------------------
  List<GMRDComponentSpec> compileSpecSet(List<GMRDComponentSpec> components) {
    final incomplete = components.where((c) => !c.isReady).toList();
    if (incomplete.isNotEmpty) {
      throw StateError(
        'Incomplete sections on: ${incomplete.map((c) => c.slug).join(', ')}. '
        'All 8 sections required before storage.',
      );
    }
    return components;
  }

  // ---------------------------------------------------------------------------
  // EC:5 — Write artifact to library path (simulation).  // error: EC-AEETE020A17-003
  // In production: writes to docs/components/<type>/<slug>.md via repo SDK.
  // ---------------------------------------------------------------------------
  StorageResult storeArtifact(GMRDComponentSpec component) {
    final content   = component.toMarkdown();
    final lintErrors = _runLintCheck(content, component.artifactPath);
    return StorageResult(
      componentSlug: component.slug,
      filePath:      component.artifactPath,
      lintErrors:    lintErrors,
    );
  }

  /// Run lint/syntax check on markdown content. Returns error count.
  /// Gate: lintErrors must equal 0 for lint_pass_IND=TRUE.
  int _runLintCheck(String content, String filePath) {
    int errors = 0;
    // Check 1: must start with h1
    if (!content.trimLeft().startsWith('#')) errors++;
    // Check 2: all 8 section headers must be present
    for (final header in kSectionHeaders.values) {
      if (!content.contains(header)) errors++;
    }
    return errors;
  }

  /// EC:6 — Run lint check on a batch of components.  // error: EC-AEETE020A17-004
  List<StorageResult> runLintCheck(List<GMRDComponentSpec> components) {
    return components.map(storeArtifact).toList();
  }

  // ---------------------------------------------------------------------------
  // EC:7 — Calculate Implementation Completeness & Code Quality rate.  // error: EC-AEETE020A17-005
  // Floor=80% · Optimal=95% · Output=Complete/Partial/Not Complete
  // ---------------------------------------------------------------------------
  SpecQualityResult calculateQuality(List<StorageResult> results) {
    final total = results.length;
    final clean = results.where((r) => r.lintPass).length;
    final rate  = total > 0 ? clean / total * 100 : 0.0;
    final output = rate >= 95 ? 'Complete'
                 : rate >= 80 ? 'Partial'
                 : 'Not Complete';
    return SpecQualityResult(
      qualityRatePct: rate,
      qualityOutput:  output,
      filesClean:     clean,
      totalFiles:     total,
    );
  }

  // ---------------------------------------------------------------------------
  // Triangular Check: components_compiled == files_stored (delta=0)
  // ---------------------------------------------------------------------------
  bool triangularCheck(int componentsCompiled, int filesStored) {
    return componentsCompiled == filesStored;
  }
}
