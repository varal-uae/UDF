/// AISS GATE -- Step 195 of 195
/// Global Reference ID:       GEN-02885
/// Atomic Steps Reference ID: GEN-02885
/// Setup Step (Action): (EMPTY on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Display compliance failure alerts via Material 3 Alert Dialog
///               on mobile screens."
/// Metric: Task Completion Status -- Floor 0.8, Optimal 1, Ceiling 1.
///         Complete / Partial / Not Complete.
///
/// THE USEFUL HALF OF THIS ROW IS NOT "BUILD A DIALOG", IT IS DECIDING WHAT
/// EARNS ONE. A codebase where any failure can raise a modal trains people to
/// dismiss modals without reading them, and then the one that mattered goes the
/// same way.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/feedback/compliance_alert.dart';
import 'package:udf_setup/design_system/resilience/error_templates.dart';
import 'package:udf_setup/design_system/tokens/button_role_map.dart';
import 'package:udf_setup/design_system/tokens/motion_tokens.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  double completion = 0;

  void gate(String id, String source, String description, bool Function() run) {
    test('[$id] $description', () {
      bool passed = false;
      try {
        passed = run();
        expect(passed, isTrue, reason: '$id failed: $description');
      } finally {
        gates.add(
          AissGate(
            id: id,
            requirementSource: source,
            description: description,
            passed: passed,
          ),
        );
      }
    });
  }

  final DateTime t0 = DateTime.utc(2026, 9, 14, 9);

  /// A blocking failure the user can resolve here.
  HabotComplianceFailure blockingA() => HabotComplianceFailure(
        code: 'CMP-001',
        severity: HabotComplianceSeverity.blocking,
        category: HabotErrorCategory.forbidden,
        resolution: 'Request access',
        raisedAt: t0,
      );

  /// A blocking failure whose resolution is not in the app.
  HabotComplianceFailure blockingB() => HabotComplianceFailure(
        code: 'CMP-002',
        severity: HabotComplianceSeverity.blocking,
        category: HabotErrorCategory.unauthenticated,
        resolution: null,
        raisedAt: t0.add(const Duration(seconds: 1)),
      );

  /// A failure that must not raise a modal.
  HabotComplianceFailure correctable() => HabotComplianceFailure(
        code: 'CMP-003',
        severity: HabotComplianceSeverity.correctable,
        category: HabotErrorCategory.validation,
        resolution: 'Fix the highlighted fields',
        raisedAt: t0,
      );

  group('GEN-02885 :: what earns a modal', () {
    gate(
      'GEN-02885-G1',
      'Atomic Step: "Display COMPLIANCE FAILURE alerts via Material 3 Alert '
          'Dialog." An alert dialog takes the screen and cannot be ignored.',
      'Only a blocking failure earns a modal; a correctable one goes inline '
          'and an advisory one is recorded rather than shown -- and the '
          'mapping is total, so a new severity cannot be added without someone '
          'deciding how loud it is',
      () =>
          HabotComplianceAlert.qualifies(blockingA()) &&
          !HabotComplianceAlert.qualifies(correctable()) &&
          HabotComplianceAlert.surfaceFor(
                HabotComplianceSeverity.blocking,
              ) ==
              HabotAlertSurface.alertDialog &&
          HabotComplianceAlert.surfaceFor(
                HabotComplianceSeverity.correctable,
              ) ==
              HabotAlertSurface.inline &&
          HabotComplianceAlert.surfaceFor(
                HabotComplianceSeverity.advisory,
              ) ==
              HabotAlertSurface.logOnly &&
          HabotComplianceSeverity.values.length == 3 &&
          HabotAlertSurface.values.length == 4 &&
          HabotComplianceAlert.whatEarnsAModalNote
              .contains('the one that mattered goes the same way'),
    );

    gate(
      'GEN-02885-G2',
      '"Compliance checks do not fail politely one at a time. Stacking dialogs '
          'produces a user tapping through three of them."',
      'Two blocking failures raised together produce one dialog and a queue, '
          'not two dialogs, and a correctable failure raised alongside them '
          'does not join that queue',
      () {
        final HabotComplianceAlert alert = HabotComplianceAlert()
          ..raise(blockingA())
          ..raise(blockingB())
          ..raise(correctable());
        return alert.hasModal &&
            alert.showing!.code == 'CMP-001' &&
            alert.queuedCount == 1 &&
            HabotComplianceAlert.oneAtATimeNote
                .contains('same reflex as the first');
      },
    );

    gate(
      'GEN-02885-G3',
      'A queue that loses what it queued is worse than no queue.',
      'Dismissing the visible dialog promotes the next one in the order they '
          'were raised, and dismissing that one leaves no modal behind',
      () {
        final HabotComplianceAlert alert = HabotComplianceAlert()
          ..raise(blockingA())
          ..raise(blockingB());
        alert.dismissCurrent();
        final bool promoted =
            alert.showing?.code == 'CMP-002' && alert.queuedCount == 0;
        alert.dismissCurrent();
        return promoted && !alert.hasModal && alert.showing == null;
      },
    );
  });

  group('GEN-02885 :: what the dialog says', () {
    gate(
      'GEN-02885-G4',
      '"A dialog whose only button is OK is a notification wearing a '
          'decision\'s clothes."',
      'A resolvable failure offers the action that resolves it; one whose '
          'resolution is not in the app SAYS so and carries the code to quote, '
          'rather than a bare acknowledgement that leads nowhere',
      () {
        final HabotComplianceFailure a = blockingA();
        final HabotComplianceFailure b = blockingB();
        return a.resolvableInApp &&
            !b.resolvableInApp &&
            HabotComplianceAlert.actionsFor(a).length == 2 &&
            HabotComplianceAlert.actionsFor(a).first == 'Request access' &&
            HabotComplianceAlert.actionsFor(a).last == a.template.retryLabel &&
            HabotComplianceAlert.actionsFor(b).single == 'Close' &&
            HabotComplianceAlert.bodyFor(b)
                .contains('cannot be resolved in the app') &&
            HabotComplianceAlert.bodyFor(b).contains('CMP-002') &&
            HabotComplianceAlert.bodyFor(a) == a.template.body &&
            HabotComplianceAlert.noBareOkNote
                .contains('notification wearing');
      },
    );

    gate(
      'GEN-02885-G5',
      'Step 68 owns the copy. A string written at the call site is a string '
          'nobody translated.',
      'The title and body come from the declared error template for the '
          'failure\'s category rather than from text typed into the alert, and '
          'the two failures used here resolve to different templates',
      () {
        final HabotComplianceFailure a = blockingA();
        final HabotComplianceFailure b = blockingB();
        return a.template.category == HabotErrorCategory.forbidden &&
            b.template.category == HabotErrorCategory.unauthenticated &&
            a.template.title != b.template.title &&
            a.template.title ==
                HabotErrorTemplates.of(HabotErrorCategory.forbidden).title &&
            a.template.body.isNotEmpty;
      },
    );

    gate(
      'GEN-02885-G6',
      'Step 97 A11Y_RAW_SEMANTIC_MODAL: "a modal without a focus trap is, to a '
          'screen reader, a page with some extra text on it."',
      'The alert routes through the sanctioned focus-trap site rather than '
          'building its own barrier, names the rule that enforces it, and its '
          'primary action takes the confirm colour rather than the destructive '
          'one -- complying should not look dangerous',
      () =>
          HabotComplianceAlert.focusTrapSite ==
              'lib/design_system/a11y/focus_trap.dart' &&
          HabotComplianceAlert.semanticRule == 'A11Y_RAW_SEMANTIC_MODAL' &&
          HabotComplianceAlert.primaryActionToken ==
              HabotButtonRoleMap.containerTokenFor(HabotButtonRole.confirm) &&
          HabotComplianceAlert.primaryActionToken !=
              HabotButtonRoleMap.containerTokenFor(
                HabotButtonRole.destructive,
              ) &&
          HabotComplianceAlert.enterDuration == HabotMotion.sheetEnter &&
          HabotComplianceAlert.modalIsAccessibilityNote
              .contains('keeps swiping into the controls'),
    );

    gate(
      'GEN-02885-G7',
      'Metric: Task Completion Status -- floor 0.8, optimal 1.',
      'Every declared check holds, giving 1.0, and the fixtures are supplied '
          'by this gate rather than constructed inside the library -- a raw '
          'Duration in lib/ is a poka-yoke violation and the guard cannot tell '
          'a fixture\'s one second from an animation\'s',
      () {
        completion = HabotComplianceAlert.completionStatus(
          blockingA: blockingA(),
          blockingB: blockingB(),
          correctable: correctable(),
        );
        final Map<String, bool> checks = HabotComplianceAlert.completionChecks(
          blockingA: blockingA(),
          blockingB: blockingB(),
          correctable: correctable(),
        );
        return checks.length == 11 &&
            checks.values.every((bool b) => b) &&
            completion == 1.0 &&
            completion >= HabotComplianceAlert.optimal &&
            HabotComplianceAlert.qualitativeOutput(
                  blockingA: blockingA(),
                  blockingB: blockingB(),
                  correctable: correctable(),
                ) ==
                'Complete' &&
            HabotComplianceAlert.columnNote.contains('EMPTY');
      },
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-02885',
        atomicStepReferenceId: 'GEN-02885',
        setupStepAction:
            'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic '
            'Step: "Display compliance failure alerts via Material 3 Alert '
            'Dialog on mobile screens."',
        implementationOrder: 195,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotComplianceAlert / HabotComplianceFailure',
          'Component Properties':
              '${HabotComplianceSeverity.values.length} severities mapped '
              'totally onto ${HabotAlertSurface.values.length} surfaces; one '
              'modal at a time with the rest queued in the order raised; copy '
              'from the Step 68 template set; routed through the Step 97 '
              'focus-trap site',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'READING RECORDED: the useful half of this row is not "build a '
              'dialog" but deciding what earns one. An alert dialog takes the '
              'screen, blocks every other control and cannot be ignored -- '
              'right for a compliance failure, wrong for nearly everything '
              'else. A codebase where any failure can raise a modal trains '
              'people to dismiss modals without reading them, and then the one '
              'that mattered goes the same way. ADDED BEYOND THE ROW: one '
              'dialog at a time with a queue (compliance checks do not fail '
              'one at a time), no bare acknowledgement (a failure that cannot '
              'be resolved in the app says so and carries its code), and the '
              'Step 97 focus trap, because a modal without a semantic boundary '
              'is a page with extra text on it to a screen reader.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Task Completion Status',
            observed:
                '${completion.toStringAsFixed(2)} over 11 declared checks: '
                'severity routing, queueing, promotion on dismissal, template '
                'copy, resolution actions, colour role and the focus-trap '
                'route.',
            floor: '0.8',
            optimal: '1',
            ceiling: '1',
          ),
          AissMeasurement(
            metricName: 'Modals on screen at once',
            observed:
                '1, enforced. Two blocking failures raised together produce '
                'one dialog and a queue of one; dismissing the visible one '
                'promotes the next rather than losing it. A correctable '
                'failure raised alongside them is routed inline and never '
                'joins the modal queue.',
            floor: '1',
            optimal: '1',
            ceiling: '1',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/feedback/compliance_alert.dart',
        ],
      ),
    );
  });
}
