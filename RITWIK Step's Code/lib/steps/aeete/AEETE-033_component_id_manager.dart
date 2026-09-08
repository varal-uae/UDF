// =============================================================================
// AEETE-033 — Cucumber Component ID Standardization
// Atomic Step: Standardize component IDs (testID="submit_button") for targeting
// Metric:      Automated Test Coverage · Floor=0.8 · Optimal=0.95
// Standard:    ISTQB / Google Testing Blog
// Domain:      Benefits Configurator — Insurance Module
// Module:      component_id_manager.dart
// Repo:        github.com/RitwikHC/theme-typography · branch: ritwik
// Author:      Ritwik Sharma — Frontend Integration Specialist | UDF Team
// Date:        25-Aug-2026
// Convention:  snake_case — {scope}_{element_descriptor}
//              Enforced: application layer + DB CHECK regex ^[a-z][a-z0-9_]*$
// =============================================================================

import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Enums — match DB CHECK constraints
// ---------------------------------------------------------------------------

/// Component categories — matches component_category CHECK constraint.
enum ComponentCategory {
  formInput,     // form_input    · DB_TRUNCATE
  buttonCta,     // button_cta    · DB_CACHE_TRUNCATE
  navigation,    // navigation    · CACHE_INVALIDATE
  modalTrigger,  // modal_trigger · DB_CACHE_TRUNCATE
  dataDisplay,   // data_display  · CACHE_INVALIDATE
}

extension ComponentCategoryExt on ComponentCategory {
  String get dbValue => switch (this) {
    ComponentCategory.formInput    => 'form_input',
    ComponentCategory.buttonCta    => 'button_cta',
    ComponentCategory.navigation   => 'navigation',
    ComponentCategory.modalTrigger => 'modal_trigger',
    ComponentCategory.dataDisplay  => 'data_display',
  };
}

/// Cucumber @After hook cleanup mode per category.
enum HookAfterMode {
  dbTruncate,      // DB_TRUNCATE
  cacheInvalidate, // CACHE_INVALIDATE
  dbCacheTruncate, // DB_CACHE_TRUNCATE
}

extension HookAfterModeExt on HookAfterMode {
  String get dbValue => switch (this) {
    HookAfterMode.dbTruncate      => 'DB_TRUNCATE',
    HookAfterMode.cacheInvalidate => 'CACHE_INVALIDATE',
    HookAfterMode.dbCacheTruncate => 'DB_CACHE_TRUNCATE',
  };
}

// ---------------------------------------------------------------------------
// Data models
// ---------------------------------------------------------------------------

/// Naming rule for one component category.
/// Maps to component_rule_registry row. immutable_IND=TRUE once registered.
class ComponentIDRule {
  final ComponentCategory category;
  final String testidPattern;
  final String contentDescTemplate;
  final String elementScope;
  final HookAfterMode hookAfterMode;
  final bool immutable; // immutable_IND

  const ComponentIDRule({
    required this.category,
    required this.testidPattern,
    required this.contentDescTemplate,
    required this.elementScope,
    required this.hookAfterMode,
    this.immutable = true,
  });
}

/// Selector resolution check result for one component.
/// Maps to component_application_log row.
class SelectorResult {
  final String componentName;
  final String testIdValue;
  final String contentDescription;
  final bool selectorResolved;  // selector_resolved_IND
  final bool testidFormatOk;    // testid_format_IND

  const SelectorResult({
    required this.componentName,
    required this.testIdValue,
    required this.contentDescription,
    required this.selectorResolved,
    required this.testidFormatOk,
  });

  bool get isPass => selectorResolved && testidFormatOk;
  String get applicationResult => isPass ? 'PASS' : 'FAIL';
}

/// Coverage validation result — maps to component_validation_log.
class ComponentCoverageResult {
  final double testCoveragePct; // 0.0–1.0 ratio
  final String coverageOutput;  // Pass / Fail (ISTQB binary)
  final int componentsResolved;
  final bool gatePass; // >= 0.8

  const ComponentCoverageResult({
    required this.testCoveragePct,
    required this.coverageOutput,
    required this.componentsResolved,
    required this.gatePass,
  });
}

// ---------------------------------------------------------------------------
// Constants — COMPONENT_RULES (mirrors component_id_manager.py)
// ---------------------------------------------------------------------------

/// Immutable naming rule registry — immutable_IND=TRUE for all entries.
const Map<ComponentCategory, ComponentIDRule> kComponentRules = {
  ComponentCategory.formInput: ComponentIDRule(
    category:            ComponentCategory.formInput,
    testidPattern:       '{form_name}_{field_name}_input',
    contentDescTemplate: '{label} text field',
    elementScope:        'form',
    hookAfterMode:       HookAfterMode.dbTruncate,
  ),
  ComponentCategory.buttonCta: ComponentIDRule(
    category:            ComponentCategory.buttonCta,
    testidPattern:       '{action}_{target}_button',
    contentDescTemplate: 'Tap to {action}',
    elementScope:        'action',
    hookAfterMode:       HookAfterMode.dbCacheTruncate,
  ),
  ComponentCategory.navigation: ComponentIDRule(
    category:            ComponentCategory.navigation,
    testidPattern:       '{nav_type}_{destination}_nav',
    contentDescTemplate: 'Navigate to {destination}',
    elementScope:        'nav',
    hookAfterMode:       HookAfterMode.cacheInvalidate,
  ),
  ComponentCategory.modalTrigger: ComponentIDRule(
    category:            ComponentCategory.modalTrigger,
    testidPattern:       '{modal_name}_modal_{action}',
    contentDescTemplate: 'Open {modal_name} dialog',
    elementScope:        'modal',
    hookAfterMode:       HookAfterMode.dbCacheTruncate,
  ),
  ComponentCategory.dataDisplay: ComponentIDRule(
    category:            ComponentCategory.dataDisplay,
    testidPattern:       '{entity}_{data_field}_display',
    contentDescTemplate: 'Shows {data_field}',
    elementScope:        'display',
    hookAfterMode:       HookAfterMode.cacheInvalidate,
  ),
};

/// snake_case validation regex — matches DB CHECK constraint.
/// Pattern: ^[a-z][a-z0-9_]*$
final RegExp kSnakeCasePattern = RegExp(r'^[a-z][a-z0-9_]*$');

// ---------------------------------------------------------------------------
// AEETE-033: Component ID Registry / Manager
// ---------------------------------------------------------------------------

/// Cucumber component ID standardization manager.
///
/// Mirrors ComponentIDManager class from component_id_manager.py.
///
/// Usage:
/// ```dart
/// final registry = ComponentIDRegistry();
///
/// // Build a testID for a form input
/// final testId = registry.buildTestId(
///   ComponentCategory.formInput,
///   {'form_name': 'enrollment', 'field_name': 'name'},
/// );
/// print(testId); // "enrollment_name_input"
///
/// // Validate format
/// print(registry.validateTestId(testId)); // true
/// ```
class ComponentIDRegistry {

  // -------------------------------------------------------------------------
  // EC:3 — Build concrete testID from pattern + substitution map.
  // Returns snake_case testID. Throws if format violated.
  // -------------------------------------------------------------------------
  String buildTestId(
    ComponentCategory category,
    Map<String, String> substitutions,
  ) {
    final rule = kComponentRules[category]!;
    String testId = rule.testidPattern;
    substitutions.forEach((key, value) {
      testId = testId.replaceAll(
        '{$key}',
        value.toLowerCase().replaceAll(' ', '_').replaceAll('-', '_'),
      );
    });
    if (!validateTestId(testId)) {
      throw ArgumentError(
        'testID "$testId" violates snake_case constraint. '
        r'Required pattern: ^[a-z][a-z0-9_]*$',
      );
    }
    return testId;
  }

  // -------------------------------------------------------------------------
  // EC:3 — Build contentDescription from template + substitution map.
  // -------------------------------------------------------------------------
  String buildContentDescription(
    ComponentCategory category,
    Map<String, String> substitutions,
  ) {
    final rule = kComponentRules[category]!;
    String desc = rule.contentDescTemplate;
    substitutions.forEach((key, value) {
      desc = desc.replaceAll('{$key}', value);
    });
    return desc;
  }

  // -------------------------------------------------------------------------
  // EC:6 — Validate snake_case format.
  // Mirrors SNAKE_CASE_PATTERN = RegExp(r"^[a-z][a-z0-9_]*$")
  // Also enforced at DB layer via CHECK constraint.
  // -------------------------------------------------------------------------
  bool validateTestId(String testId) {
    return kSnakeCasePattern.hasMatch(testId);
  }

  // -------------------------------------------------------------------------
  // EC:7 — Automated Test Coverage (ISTQB standard).
  // Floor=0.8 (80%) · Optimal=0.95 (95%) · Output=Pass/Fail
  // -------------------------------------------------------------------------
  ComponentCoverageResult calculateCoverage(
    int componentsResolved,
    int total,
  ) {
    final coverage = total > 0 ? componentsResolved / total : 0.0;
    final output   = coverage >= 0.8 ? 'Pass' : 'Fail';
    return ComponentCoverageResult(
      testCoveragePct:     coverage,
      coverageOutput:      output,
      componentsResolved:  componentsResolved,
      gatePass:            coverage >= 0.8,
    );
  }

  // -------------------------------------------------------------------------
  // Triangular Check: components_bound == selectors_checked (delta=0)
  // -------------------------------------------------------------------------
  bool triangularCheck(int bound, int checked) => bound == checked;

  /// Compile all 5 category rules. Gate: 5 rules required.
  List<ComponentIDRule> compileRules() => kComponentRules.values.toList();
}

// ---------------------------------------------------------------------------
// Flutter widgets — Benefits Configurator Insurance Module
// All testIDs use standardized snake_case — Cucumber @After hook ready
// ---------------------------------------------------------------------------

/// Enrollment name text field.
/// Category: form_input · testID: enrollment_name_input · @After: DB_TRUNCATE
class EnrollmentNameInput extends StatelessWidget {
  final TextEditingController? controller;

  const EnrollmentNameInput({super.key, this.controller});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Name text field', // contentDescription
      textField: true,
      child: TextField(
        key: const Key('enrollment_name_input'), // testID
        controller: controller,
        decoration: const InputDecoration(
          labelText: 'Full Name',
          border: OutlineInputBorder(),
        ),
        textInputAction: TextInputAction.next,
      ),
    );
  }
}

/// Enrollment DOB text field.
/// Category: form_input · testID: enrollment_dob_input · @After: DB_TRUNCATE
class EnrollmentDOBInput extends StatelessWidget {
  final TextEditingController? controller;

  const EnrollmentDOBInput({super.key, this.controller});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Date of birth text field',
      textField: true,
      child: TextField(
        key: const Key('enrollment_dob_input'), // testID
        controller: controller,
        decoration: const InputDecoration(
          labelText: 'Date of Birth',
          border: OutlineInputBorder(),
        ),
        keyboardType: TextInputType.datetime,
      ),
    );
  }
}

/// Submit enrollment button.
/// Category: button_cta · testID: submit_enrollment_button · @After: DB_CACHE_TRUNCATE
class SubmitEnrollmentButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const SubmitEnrollmentButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Tap to submit', // contentDescription
      child: SizedBox(
        width: double.infinity,
        height: 48, // MD3 touch target minimum
        child: ElevatedButton(
          key: const Key('submit_enrollment_button'), // testID
          onPressed: onPressed,
          child: const Text('Submit Enrollment'),
        ),
      ),
    );
  }
}

/// Cancel enrollment button.
/// Category: button_cta · testID: cancel_enrollment_button · @After: DB_CACHE_TRUNCATE
class CancelEnrollmentButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const CancelEnrollmentButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Tap to cancel',
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: OutlinedButton(
          key: const Key('cancel_enrollment_button'), // testID
          onPressed: onPressed,
          child: const Text('Cancel'),
        ),
      ),
    );
  }
}

/// Premium amount display.
/// Category: data_display · testID: premium_amount_display · @After: CACHE_INVALIDATE
/// "Your Cost Per Pay Period" widget.
class PremiumAmountDisplay extends StatelessWidget {
  final String amount;
  final String period;

  const PremiumAmountDisplay({
    super.key,
    required this.amount,
    required this.period,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Shows premium_amount', // contentDescription
      liveRegion: true,              // aria-live equivalent
      child: Container(
        key: const Key('premium_amount_display'), // testID
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFE3F2FD),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Your Cost Per Pay Period',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: const Color(0xFF1B2A4A),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              amount,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: const Color(0xFF1B2A4A),
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'per $period',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFF555555),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dependent count display.
/// Category: data_display · testID: dependent_count_display · @After: CACHE_INVALIDATE
class DependentCountDisplay extends StatelessWidget {
  final int count;

  const DependentCountDisplay({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Shows dependent_count',
      liveRegion: true,
      child: Text(
        key: const Key('dependent_count_display'), // testID
        'Dependents: $count',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}
