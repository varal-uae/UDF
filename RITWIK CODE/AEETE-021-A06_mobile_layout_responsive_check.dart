// =============================================================================
// AEETE-021-A06 — Mobile Layout Responsive Check (E2E Test Config)
// Atomic Step: Write end-to-end tests covering form input and submission flows
// Metric:      Implementation Completeness & Code Quality · Floor=80% · Optimal=95%
// Standard:    ISTQB / Google Testing Blog
// Module:      mobile_layout_responsive_check.dart
// Repo:        github.com/RitwikHC/theme-typography · branch: ritwik
// Author:      Ritwik Sharma — Frontend Integration Specialist | UDF Team
// Date:        25-Aug-2026
// Dependency:  S.No 6021 — Operational frontend repos + pipeline runners live
// Note:        The primary output is MobileLayoutResponsiveCheck.spec.ts (Cypress).
//              This Dart module provides the Flutter integration_test equivalent
//              for mobile-native testing, mirroring all 5 flow types.
// =============================================================================

import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Constants — mirror Cypress VIEWPORTS and flow type ENUM
// ---------------------------------------------------------------------------

/// Viewport sizes under test. Mirrors Cypress VIEWPORTS array.
const List<Size> kTestViewports = [
  Size(360, 780),    // mobile compact — primary mobile target
  Size(768, 1024),   // tablet
  Size(1280, 800),   // desktop
];

/// Touch target minimum — 48dp (MD3 accessibility sizing token).
/// Mirrors TOUCH_TARGET_MIN_PX = 48 in Cypress spec.
const double kTouchTargetMinDp = 48.0;

/// Warning threshold for character counter (80% of limit).
const double kCharLimitWarningRatio = 0.8;

// ---------------------------------------------------------------------------
// Enums — match cypress test_flow_type CHECK constraint
// ---------------------------------------------------------------------------

/// E2E test flow types. Maps to viewport_width_PX + test_flow_type DB columns.
enum E2EFlowType {
  formInput,      // E2E_FORM_INPUT
  submission,     // E2E_SUBMISSION
  focusLoop,      // E2E_FOCUS_LOOP
  touchTarget,    // E2E_TOUCH_TARGET
  modalScroll,    // E2E_MODAL_SCROLL
}

extension E2EFlowTypeExt on E2EFlowType {
  String get dbValue => switch (this) {
    E2EFlowType.formInput   => 'E2E_FORM_INPUT',
    E2EFlowType.submission  => 'E2E_SUBMISSION',
    E2EFlowType.focusLoop   => 'E2E_FOCUS_LOOP',
    E2EFlowType.touchTarget => 'E2E_TOUCH_TARGET',
    E2EFlowType.modalScroll => 'E2E_MODAL_SCROLL',
  };
}

// ---------------------------------------------------------------------------
// Data models
// ---------------------------------------------------------------------------

/// One test case result — maps to cypress_execution_log row.
class E2ETestResult {
  final String testCaseId;
  final E2EFlowType flowType;
  final double viewportWidth;
  final String endpointPath;
  final bool touchTargetCompliant; // touch_target_compliant_IND
  final bool focusLoopCompliant;   // focus_loop_compliant_IND
  final bool passed;               // test_result = PASS/FAIL
  final String timestamp;
  final String logPath;

  const E2ETestResult({
    required this.testCaseId,
    required this.flowType,
    required this.viewportWidth,
    required this.endpointPath,
    required this.touchTargetCompliant,
    required this.focusLoopCompliant,
    required this.passed,
    required this.timestamp,
    required this.logPath,
  });

  String get testResult => passed ? 'PASS' : 'FAIL';
}

/// Layout shift measurement result — CLS equivalent.
class LayoutShiftResult {
  final String componentName;
  final bool dimensionsReserved; // dims_reserved_IND
  final bool clsCompliant;       // cls_score < 0.1 equivalent

  const LayoutShiftResult({
    required this.componentName,
    required this.dimensionsReserved,
    required this.clsCompliant,
  });
}

/// Coverage validation result — maps to cypress_validation_log.
class CoverageResult {
  final double coverageRatePct;
  final String qualityOutput; // Complete / Partial / Not Complete
  final int testsPassed;
  final int totalTests;

  const CoverageResult({
    required this.coverageRatePct,
    required this.qualityOutput,
    required this.testsPassed,
    required this.totalTests,
  });

  bool get gatePass => coverageRatePct >= 80;
}

// ---------------------------------------------------------------------------
// AEETE-021-A06: Mobile Layout Responsive Check Configuration
// ---------------------------------------------------------------------------

/// Flutter integration-test equivalent of MobileLayoutResponsiveCheck.spec.ts.
///
/// Provides helpers for:
/// - Touch target validation (48dp gate)
/// - Focus loop traversal verification
/// - Coverage rate calculation (ISTQB Floor=80%)
/// - Viewport matrix management
///
/// Usage in integration_test:
/// ```dart
/// testWidgets('submit button meets 48dp touch target', (tester) async {
///   await tester.pumpWidget(MyApp());
///   final valid = MobileLayoutTestConfig.validateTouchTarget(
///     await tester.getSize(find.byKey(Key('submit_enrollment_button'))),
///   );
///   expect(valid, isTrue);
/// });
/// ```
class MobileLayoutTestConfig {

  // -------------------------------------------------------------------------
  // EC:3 — Touch target validation (E2E_TOUCH_TARGET flow type)
  // Gate: element height >= 48dp
  // -------------------------------------------------------------------------
  static bool validateTouchTarget(Size elementSize) {
    return elementSize.height >= kTouchTargetMinDp;
  }

  // -------------------------------------------------------------------------
  // EC:3 — Focus loop validation (E2E_FOCUS_LOOP flow type)
  // Checks that focus traversal hits all expected fields in order.
  // -------------------------------------------------------------------------
  static bool validateFocusLoop({
    required List<String> expectedOrder,
    required List<String> actualOrder,
  }) {
    if (expectedOrder.length != actualOrder.length) return false;
    for (int i = 0; i < expectedOrder.length; i++) {
      if (expectedOrder[i] != actualOrder[i]) return false;
    }
    return true;
  }

  // -------------------------------------------------------------------------
  // EC:3 — Modal scroll lock validation (E2E_MODAL_SCROLL flow type)
  // -------------------------------------------------------------------------
  static bool validateModalScrollLock({
    required bool modalVisible,
    required bool bodyScrollLocked, // overflow: hidden equivalent
  }) {
    return modalVisible && bodyScrollLocked;
  }

  // -------------------------------------------------------------------------
  // EC:7 — Coverage rate calculation (ISTQB standard)
  // Floor=0.8 (80%), Optimal=0.95 (95%)
  // -------------------------------------------------------------------------
  static CoverageResult calculateCoverage(int passed, int total) {
    final rate = total > 0 ? passed / total * 100 : 0.0;
    final output = rate >= 95 ? 'Complete'
                 : rate >= 80 ? 'Partial'
                 : 'Not Complete';
    return CoverageResult(
      coverageRatePct: rate,
      qualityOutput:   output,
      testsPassed:     passed,
      totalTests:      total,
    );
  }

  // -------------------------------------------------------------------------
  // Triangular Check: cases_compiled == cases_executed (delta=0)
  // -------------------------------------------------------------------------
  static bool triangularCheck(int casesCompiled, int casesExecuted) {
    return casesCompiled == casesExecuted;
  }

  // -------------------------------------------------------------------------
  // Generate test matrix: 5 flow types × 3 viewports = 15 base cases
  // -------------------------------------------------------------------------
  static List<Map<String, dynamic>> generateTestMatrix() {
    final matrix = <Map<String, dynamic>>[];
    for (final flow in E2EFlowType.values) {
      for (final viewport in kTestViewports) {
        matrix.add({
          'flow_type':      flow.dbValue,
          'viewport_width': viewport.width,
          'viewport_height': viewport.height,
          'endpoint_path':  '/forms/contact',
          'touch_target':   flow == E2EFlowType.touchTarget || flow == E2EFlowType.formInput,
          'focus_loop':     flow == E2EFlowType.focusLoop,
        });
      }
    }
    return matrix;
  }
}

// ---------------------------------------------------------------------------
// Flutter widget: Enrollment form with standardized test IDs
// Ready for integration testing against the above config.
// ---------------------------------------------------------------------------

/// Enrollment contact form widget.
/// All testID values follow snake_case convention (AEETE-033 contract).
class MobileEnrollmentForm extends StatefulWidget {
  final void Function(Map<String, String> values)? onSubmit;

  const MobileEnrollmentForm({super.key, this.onSubmit});

  @override
  State<MobileEnrollmentForm> createState() => _MobileEnrollmentFormState();
}

class _MobileEnrollmentFormState extends State<MobileEnrollmentForm> {
  final _nameCtrl    = TextEditingController();
  final _emailCtrl   = TextEditingController();
  final _messageCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    widget.onSubmit?.call({
      'name':    _nameCtrl.text,
      'email':   _emailCtrl.text,
      'message': _messageCtrl.text,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // E2E_FORM_INPUT: enrollment_name_input
        TextField(
          key: const Key('enrollment_name_input'),
          controller: _nameCtrl,
          decoration: const InputDecoration(labelText: 'Full Name'),
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 12),
        // E2E_FORM_INPUT: enrollment_email_input
        TextField(
          key: const Key('enrollment_email_input'),
          controller: _emailCtrl,
          decoration: const InputDecoration(labelText: 'Email'),
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 12),
        // E2E_FORM_INPUT: enrollment_message_input
        TextField(
          key: const Key('enrollment_message_input'),
          controller: _messageCtrl,
          decoration: const InputDecoration(labelText: 'Message'),
          maxLines: 4,
          textInputAction: TextInputAction.done,
        ),
        const SizedBox(height: 20),
        // E2E_SUBMISSION + E2E_TOUCH_TARGET: submit_enrollment_button (>=48dp)
        SizedBox(
          width: double.infinity,
          height: kTouchTargetMinDp, // enforces 48dp touch target
          child: ElevatedButton(
            key: const Key('submit_enrollment_button'),
            onPressed: _handleSubmit,
            child: const Text('Submit'),
          ),
        ),
      ],
    );
  }
}
