/// AISS Step 98 -- GEN-02775
/// "Document all WCAG 2.2 AA audit findings, remediation actions, and pipeline
///  configuration."
/// The sheet calls the output an "engineering accessibility runbook".
///
/// WHAT MAKES THIS A RUNBOOK RATHER THAN A DOCUMENT. It is GENERATED from the
/// Step 96 audit and the Step 97 rule set, every run, and written to
/// `build/aiss/a11y_runbook.md`. Nobody maintains it by hand, so it cannot
/// drift away from the code the way a hand-written accessibility statement
/// always does. If a criterion starts failing, the runbook says so on the next
/// run without anyone remembering to update it.
///
/// THE THREE SECTIONS ARE THE THREE THINGS THE ROW ASKS FOR:
///   1. FINDINGS   -- what the audit measured, per criterion, with the number.
///   2. REMEDIATION -- which implementation step closes each open finding, and
///                     which are knowingly open with a reason.
///   3. CONFIGURATION -- the rules that fail the build, what each protects,
///                     and every exemption with its rationale.
///
/// WHY REMEDIATION IS DATA AND NOT PROSE. A finding whose remediation is a
/// sentence someone wrote is a finding nobody can track. Each entry below
/// names an owning step, so "is this fixed?" is answered by whether that step
/// is implemented, not by re-reading the document.
library;

import '../tokens/color_tokens.dart';
import 'a11y_rules.dart';
import 'wcag_audit.dart';

/// What is being done about one finding.
enum HabotRemediationState {
  /// Closed by an implemented step.
  remediated,

  /// An implementation step exists and is scheduled.
  scheduled,

  /// Knowingly open, with a reason recorded. Not the same as ignored.
  accepted,

  /// Needs a decision from a person before anything can be built.
  awaitingDecision,
}

/// One row of the remediation register.
class HabotRemediation {
  const HabotRemediation({
    required this.criterionId,
    required this.state,
    required this.owningStep,
    required this.action,
    this.rationale,
  });

  final String criterionId;
  final HabotRemediationState state;

  /// The step that closes it, e.g. 'Step 101 GEN-01826'.
  final String owningStep;

  /// What was, or will be, done.
  final String action;

  /// Required when [state] is accepted or awaitingDecision -- an open item
  /// without a reason is an item that was forgotten, not one that was decided.
  final String? rationale;

  bool get isWellFormed =>
      state == HabotRemediationState.remediated ||
      state == HabotRemediationState.scheduled ||
      (rationale != null && rationale!.isNotEmpty);
}

/// The register.
class HabotA11yRegister {
  const HabotA11yRegister._();

  static const List<HabotRemediation> remediations = <HabotRemediation>[
    HabotRemediation(
      criterionId: '1.4.3',
      state: HabotRemediationState.remediated,
      owningStep: 'Step 4 TTMCS-005, widened by Step 105 GEN-00368',
      action:
          'Every text pair in every scheme is measured by the Step 4 contrast '
          'engine. Step 105 added a third scheme through the same engine.',
    ),
    HabotRemediation(
      criterionId: '1.4.11',
      state: HabotRemediationState.remediated,
      owningStep: 'Step 105 GEN-00368',
      action:
          'Non-text pairs audited at the 3:1 floor across light, dark and both '
          'high-contrast schemes.',
    ),
    HabotRemediation(
      criterionId: '1.4.4',
      state: HabotRemediationState.remediated,
      owningStep: 'Step 102 GEN-04363',
      action:
          'HabotTextScaleScope applies the OS scale, clamped to an audited '
          'range, and the type scale is verified at every scale in that range.',
    ),
    HabotRemediation(
      criterionId: '1.4.10',
      state: HabotRemediationState.remediated,
      owningStep: 'Step 46 GEN-02060',
      action: 'Text fitting gated at 320dp with an 11sp readable floor.',
    ),
    HabotRemediation(
      criterionId: '2.5.8',
      state: HabotRemediationState.remediated,
      owningStep: 'Step 10 TTMAC-011, extended by Step 108 GEN-00090',
      action:
          'Targets held to 48dp, stricter than the 24dp criterion. Step 108 '
          'adds the accuracy axis the size check does not cover.',
    ),
    HabotRemediation(
      criterionId: '1.1.1',
      state: HabotRemediationState.remediated,
      owningStep: 'Step 100 GEN-02764',
      action:
          'Two image widgets, one requiring alt text and one declaring it has '
          'none; a raw Image is a build failure under A11Y_RAW_IMAGE.',
    ),
    HabotRemediation(
      criterionId: '4.1.2',
      state: HabotRemediationState.remediated,
      owningStep: 'Step 99 GEN-04572',
      action:
          'Consequence hints declared per action kind and announced after the '
          'label. Two icon buttons whose names were removed by the Step 24 '
          'tooltip strip are fixed in this batch.',
    ),
    HabotRemediation(
      criterionId: '2.1.2',
      state: HabotRemediationState.remediated,
      owningStep: 'Step 101 GEN-01826',
      action:
          'HabotFocusTrap requires onDismiss, so a trap with no documented '
          'exit cannot be constructed.',
    ),
    HabotRemediation(
      criterionId: '2.4.3',
      state: HabotRemediationState.remediated,
      owningStep: 'Step 101 GEN-01826',
      action:
          'A trapped surface scopes the route and blocks the semantics behind '
          'it, so traversal order is the dialog order.',
    ),
    HabotRemediation(
      criterionId: '2.4.11',
      state: HabotRemediationState.remediated,
      owningStep: 'Step 101 GEN-01826',
      action:
          'The barrier is painted below the trapped content, so the focused '
          'element is never behind it.',
    ),
    HabotRemediation(
      criterionId: '2.4.6',
      state: HabotRemediationState.accepted,
      owningStep: 'unassigned',
      action: 'No automated check.',
      rationale:
          'Whether a heading DESCRIBES its section is a reading, not a '
          'measurement. Counting it as a pass would inflate the conformance '
          'rate with something no test verified, so it is excluded from the '
          'rate entirely and listed here instead.',
    ),
    HabotRemediation(
      criterionId: '3.3.3',
      state: HabotRemediationState.accepted,
      owningStep: 'Step 19 REF-197',
      action:
          'Nine error templates exist and are complete; a jargon list blocks '
          'the worst phrasing.',
      rationale:
          'Whether a suggestion is USEFUL is a judgement. The mechanism is '
          'built and gated; the quality of the sentences is not machine '
          'checkable and is not claimed to be.',
    ),
  ];

  static HabotRemediation? forCriterion(String id) {
    for (final HabotRemediation r in remediations) {
      if (r.criterionId == id) {
        return r;
      }
    }
    return null;
  }

  /// Every criterion the audit knows about has a remediation row, and every
  /// open row has a reason. Both are checked rather than assumed.
  static bool get isComplete =>
      WcagCriteria.all.every(
        (WcagCriterion c) => forCriterion(c.id) != null,
      ) &&
      remediations.every((HabotRemediation r) => r.isWellFormed);

  static List<String> get criteriaWithoutRemediation => WcagCriteria.all
      .where((WcagCriterion c) => forCriterion(c.id) == null)
      .map((WcagCriterion c) => c.id)
      .toList();

  /// The runbook. Markdown, because it is read by people and diffed by git.
  static String runbook({
    required Map<String, HabotColorScheme> schemes,
    List<WcagFinding> runtimeFindings = const <WcagFinding>[],
  }) {
    final WcagAuditReport report = WcagAudit.report(
      schemes: schemes,
      runtimeFindings: runtimeFindings,
    );
    final StringBuffer b = StringBuffer()
      ..writeln('# Engineering accessibility runbook')
      ..writeln()
      ..writeln(
        'Generated by `HabotA11yRegister.runbook`. Do not edit by hand -- '
        'the next run overwrites it.',
      )
      ..writeln()
      ..writeln('Source: AISS Step 98 (GEN-02775).')
      ..writeln()
      ..writeln('## 1. Findings')
      ..writeln()
      ..writeln(
        '${WcagAudit.metricName}: '
        '**${(report.complianceRate * 100).toStringAsFixed(1)}%** '
        '(floor ${(WcagAudit.floor * 100).toStringAsFixed(0)}%, '
        'optimal ${(WcagAudit.optimal * 100).toStringAsFixed(0)}%) '
        'over ${report.counted.length} machine-checkable criteria. '
        '${report.judgement.length} further criteria require a human reading '
        'and are excluded from the rate rather than auto-passed.',
      )
      ..writeln()
      ..writeln('| Criterion | Level | How checked | Outcome | Measured |')
      ..writeln('|---|---|---|---|---|');
    for (final WcagFinding f in report.findings) {
      b.writeln(
        '| ${f.criterion.id} ${f.criterion.name} | ${f.criterion.level} '
        '| ${f.criterion.evaluation.name} | ${f.outcome.name} '
        '| ${f.detail} |',
      );
    }

    b
      ..writeln()
      ..writeln('## 2. Remediation')
      ..writeln()
      ..writeln('| Criterion | State | Owning step | Action / reason |')
      ..writeln('|---|---|---|---|');
    for (final HabotRemediation r in remediations) {
      final String tail = r.rationale == null
          ? r.action
          : '${r.action} **Open because:** ${r.rationale}';
      b.writeln(
        '| ${r.criterionId} | ${r.state.name} | ${r.owningStep} | $tail |',
      );
    }

    b
      ..writeln()
      ..writeln('## 3. Pipeline configuration')
      ..writeln()
      ..writeln(
        'The row names Cloud Build. This project has no Cloud Build pipeline; '
        'it has `tool/verify_aiss.sh` and the guards under `test/guards/`, '
        'which is the same mechanism. The accessibility rules below FAIL THE '
        'BUILD.',
      )
      ..writeln()
      ..writeln('| Rule | Protects | Exempt files | Why exempt |')
      ..writeln('|---|---|---|---|');
    for (final HabotA11yRule r in HabotA11yRules.all) {
      b.writeln(
        '| `${r.id}` | ${r.owner} '
        '| ${r.exemptPaths.isEmpty ? "none" : r.exemptPaths.join("<br>")} '
        '| ${r.exemptionRationale ?? "-- (absolute rule)"} |',
      );
    }

    return b.toString();
  }
}
