/// AISS Step 96 -- GEN-02621
/// "Step 47: WCAG 2.2 AA Accessibility & Screen Reader Audit"
///
/// The audit instrument. It goes first in this batch for the reason the build
/// order gives: you cannot fix what you have not measured, and Steps 97-110
/// each close entries this produces.
///
/// What this is NOT: a verdict. It is a conformance RATE over a declared,
/// enumerable set of criteria, so that "how accessible is this app?" has an
/// answer that moves when the code moves, rather than an opinion that is
/// re-formed every time someone asks.
///
/// SCOPE, STATED HONESTLY. Three kinds of WCAG criteria exist here:
///
///   1. Statically checkable  -- contrast ratios, type sizes, target sizes,
///      declared alternatives. These are audited and produce a real result.
///   2. Runtime checkable     -- focus order, focus traps, what a screen reader
///      announces. These need a pumped widget tree, so the criterion is
///      declared here and evaluated by the gate that owns it (Steps 99-101).
///   3. Not machine checkable -- whether alt text is *meaningful*, whether an
///      error message is *helpful*. These are declared as `judgement` and are
///      never counted as passes. Counting them as passes is how conformance
///      rates become fiction.
///
/// The rate reported is over categories 1 and 2 only. Category 3 is reported
/// separately, by count, so it cannot quietly inflate the number.
library;

import 'package:flutter/widgets.dart';

import '../tokens/color_tokens.dart';
import '../tokens/typography_tokens.dart';
import '../interaction/touch_standards.dart';
import 'contrast.dart';
import 'contrast_audit.dart';
import 'text_fit.dart';

/// How a criterion can be evaluated at all.
enum WcagEvaluation {
  /// Decidable from source and tokens alone.
  static_,

  /// Decidable only against a rendered widget tree.
  runtime,

  /// Requires a human reading. Never auto-passed.
  judgement,
}

/// The outcome of evaluating one criterion.
enum WcagOutcome { pass, fail, notEvaluated }

/// One WCAG 2.2 success criterion, as this project holds itself to it.
@immutable
class WcagCriterion {
  const WcagCriterion({
    required this.id,
    required this.name,
    required this.level,
    required this.evaluation,
    required this.owner,
  });

  /// e.g. '1.4.3'.
  final String id;
  final String name;

  /// 'A' or 'AA'. Nothing above AA is claimed.
  final String level;

  final WcagEvaluation evaluation;

  /// The implementation step that owns this criterion, so a failure has an
  /// address rather than a shrug.
  final String owner;

  @override
  String toString() => '$id $name (Level $level)';
}

/// One evaluated criterion.
@immutable
class WcagFinding {
  const WcagFinding({
    required this.criterion,
    required this.outcome,
    required this.detail,
    this.subjectsChecked = 0,
    this.subjectsFailing = 0,
  });

  final WcagCriterion criterion;
  final WcagOutcome outcome;

  /// What was measured, in a sentence a person can argue with.
  final String detail;

  final int subjectsChecked;
  final int subjectsFailing;

  bool get counts => criterion.evaluation != WcagEvaluation.judgement;

  Map<String, Object?> toJson() => <String, Object?>{
    'criterion': criterion.id,
    'name': criterion.name,
    'level': criterion.level,
    'evaluation': criterion.evaluation.name,
    'owner': criterion.owner,
    'outcome': outcome.name,
    'detail': detail,
    'subjects_checked': subjectsChecked,
    'subjects_failing': subjectsFailing,
  };
}

/// The criteria this project audits, and who owns each.
class WcagCriteria {
  const WcagCriteria._();

  static const WcagCriterion nonTextContrast = WcagCriterion(
    id: '1.4.11',
    name: 'Non-text Contrast',
    level: 'AA',
    evaluation: WcagEvaluation.static_,
    owner: 'Step 105 GEN-00368',
  );

  static const WcagCriterion textContrast = WcagCriterion(
    id: '1.4.3',
    name: 'Contrast (Minimum)',
    level: 'AA',
    evaluation: WcagEvaluation.static_,
    owner: 'Step 4 TTMCS-005',
  );

  static const WcagCriterion resizeText = WcagCriterion(
    id: '1.4.4',
    name: 'Resize Text',
    level: 'AA',
    evaluation: WcagEvaluation.static_,
    owner: 'Step 102 GEN-04363',
  );

  static const WcagCriterion reflow = WcagCriterion(
    id: '1.4.10',
    name: 'Reflow',
    level: 'AA',
    evaluation: WcagEvaluation.static_,
    owner: 'Step 46 GEN-02060',
  );

  static const WcagCriterion targetSize = WcagCriterion(
    id: '2.5.8',
    name: 'Target Size (Minimum)',
    level: 'AA',
    evaluation: WcagEvaluation.static_,
    owner: 'Step 10 TTMAC-011',
  );

  static const WcagCriterion nonTextContent = WcagCriterion(
    id: '1.1.1',
    name: 'Non-text Content',
    level: 'A',
    evaluation: WcagEvaluation.runtime,
    owner: 'Step 100 GEN-02764',
  );

  static const WcagCriterion nameRoleValue = WcagCriterion(
    id: '4.1.2',
    name: 'Name, Role, Value',
    level: 'A',
    evaluation: WcagEvaluation.runtime,
    owner: 'Step 99 GEN-04572',
  );

  static const WcagCriterion focusOrder = WcagCriterion(
    id: '2.4.3',
    name: 'Focus Order',
    level: 'A',
    evaluation: WcagEvaluation.runtime,
    owner: 'Step 101 GEN-01826',
  );

  static const WcagCriterion noKeyboardTrap = WcagCriterion(
    id: '2.1.2',
    name: 'No Keyboard Trap',
    level: 'A',
    evaluation: WcagEvaluation.runtime,
    owner: 'Step 101 GEN-01826',
  );

  static const WcagCriterion focusNotObscured = WcagCriterion(
    id: '2.4.11',
    name: 'Focus Not Obscured (Minimum)',
    level: 'AA',
    evaluation: WcagEvaluation.runtime,
    owner: 'Step 101 GEN-01826',
  );

  static const WcagCriterion headingsAndLabels = WcagCriterion(
    id: '2.4.6',
    name: 'Headings and Labels',
    level: 'AA',
    evaluation: WcagEvaluation.judgement,
    owner: 'unassigned -- needs a human reading',
  );

  static const WcagCriterion errorSuggestion = WcagCriterion(
    id: '3.3.3',
    name: 'Error Suggestion',
    level: 'AA',
    evaluation: WcagEvaluation.judgement,
    owner: 'Step 19 REF-197 (templates exist; usefulness is a reading)',
  );

  static const List<WcagCriterion> all = <WcagCriterion>[
    textContrast,
    nonTextContrast,
    resizeText,
    reflow,
    targetSize,
    nonTextContent,
    nameRoleValue,
    focusOrder,
    noKeyboardTrap,
    focusNotObscured,
    headingsAndLabels,
    errorSuggestion,
  ];

  static List<WcagCriterion> ofEvaluation(WcagEvaluation e) =>
      all.where((WcagCriterion c) => c.evaluation == e).toList();
}

/// The result of one audit run.
@immutable
class WcagAuditReport {
  const WcagAuditReport(this.findings);

  final List<WcagFinding> findings;

  List<WcagFinding> get counted =>
      findings.where((WcagFinding f) => f.counts).toList();

  List<WcagFinding> get judgement =>
      findings.where((WcagFinding f) => !f.counts).toList();

  List<WcagFinding> get failures => counted
      .where((WcagFinding f) => f.outcome == WcagOutcome.fail)
      .toList();

  List<WcagFinding> get notEvaluated => counted
      .where((WcagFinding f) => f.outcome == WcagOutcome.notEvaluated)
      .toList();

  /// The sheet's metric: WCAG 2.2 AA Compliance Rate. Floor 0.8, optimal 1.0.
  ///
  /// A criterion that was not evaluated counts against the rate. It is not
  /// neutral: an unmeasured criterion is an unknown, and an unknown is not a
  /// pass. This is the whole reason the number is worth reading.
  double get complianceRate {
    if (counted.isEmpty) {
      return 0;
    }
    final int passing = counted
        .where((WcagFinding f) => f.outcome == WcagOutcome.pass)
        .length;
    return passing / counted.length;
  }

  bool get meetsFloor => complianceRate >= WcagAudit.floor;
  bool get meetsOptimal => complianceRate >= WcagAudit.optimal;

  Map<String, Object?> toJson() => <String, Object?>{
    'compliance_rate': complianceRate,
    'criteria_counted': counted.length,
    'criteria_passing':
        counted.where((WcagFinding f) => f.outcome == WcagOutcome.pass).length,
    'criteria_failing': failures.length,
    'criteria_not_evaluated': notEvaluated.length,
    'criteria_requiring_judgement': judgement.length,
    'findings': findings.map((WcagFinding f) => f.toJson()).toList(),
  };
}

/// The audit instrument itself.
class WcagAudit {
  const WcagAudit._();

  /// Metric Name: "WCAG 2.2 AA Compliance Rate", verbatim from the row.
  static const String metricName = 'WCAG 2.2 AA Compliance Rate';
  static const double floor = 0.8;
  static const double optimal = 1.0;
  static const double ceiling = 1.0;

  /// The static half, runnable with no widget tree.
  ///
  /// Every scheme passed in is audited, which is what makes this widen when
  /// Step 105 adds high contrast without any change here.
  static List<WcagFinding> auditStatic({
    required Map<String, HabotColorScheme> schemes,
  }) {
    return <WcagFinding>[
      _contrast(schemes, isText: true),
      _contrast(schemes, isText: false),
      _resizeText(),
      _reflow(),
      _targetSize(),
    ];
  }

  static WcagFinding _contrast(
    Map<String, HabotColorScheme> schemes, {
    required bool isText,
  }) {
    int checked = 0;
    int failing = 0;
    final List<String> worst = <String>[];
    for (final MapEntry<String, HabotColorScheme> e in schemes.entries) {
      final List<AuditPair> pairs = isText
          ? ContrastAudit.textPairs
          : ContrastAudit.nonTextPairs;
      for (final AuditPair p in pairs) {
        final Color? fg = e.value.roles[p.foreground];
        final Color? bg = e.value.roles[p.background];
        if (fg == null || bg == null) {
          continue;
        }
        checked++;
        final ContrastResult r = Contrast.evaluate(
          foregroundName: p.foreground,
          backgroundName: p.background,
          foreground: fg,
          background: bg,
          isText: isText,
        );
        if (!r.passes) {
          failing++;
          worst.add(
            '${e.key}: ${p.foreground} on ${p.background} ${r.ratioLabel}',
          );
        }
      }
    }
    return WcagFinding(
      criterion: isText
          ? WcagCriteria.textContrast
          : WcagCriteria.nonTextContrast,
      outcome: checked == 0
          ? WcagOutcome.notEvaluated
          : (failing == 0 ? WcagOutcome.pass : WcagOutcome.fail),
      detail: failing == 0
          ? '$checked pairs audited across ${schemes.length} scheme(s) at the '
                '${isText ? WcagThresholds.textFloor : WcagThresholds.nonTextFloor}:1 '
                'floor; none below it'
          : '$failing of $checked pairs below the floor: ${worst.join('; ')}',
      subjectsChecked: checked,
      subjectsFailing: failing,
    );
  }

  static WcagFinding _resizeText() {
    // 1.4.4 asks that text scale to 200% without loss of content. The type
    // scale is the subject: every token, at 2.0, must still be a size the
    // fitting instrument accepts.
    int checked = 0;
    int failing = 0;
    for (final HabotTypeToken t in HabotTypography.all) {
      checked++;
      final double scaled = t.sizeSp * 2.0;
      if (scaled < HabotTextFit.minReadableFontSp) {
        failing++;
      }
    }
    return WcagFinding(
      criterion: WcagCriteria.resizeText,
      outcome: failing == 0 ? WcagOutcome.pass : WcagOutcome.fail,
      detail:
          '$checked type tokens evaluated at 200%; $failing fell below the '
          '${HabotTextFit.minReadableFontSp}sp readable floor. NOTE: this is '
          'the token half only. Whether a LAYOUT survives 200% is Step 102 and '
          'is evaluated there, against rendered widgets.',
      subjectsChecked: checked,
      subjectsFailing: failing,
    );
  }

  /// A representative label. Long enough to make a narrow viewport bite,
  /// short enough that a failure means the token is wrong rather than the
  /// sample being absurd.
  static const String reflowSample = 'Outstanding reconciliation batch';

  static WcagFinding _reflow() {
    int checked = 0;
    int failing = 0;
    for (final HabotTypeToken t in HabotTypography.all) {
      checked++;
      final HabotTextFitResult r = HabotTextFit.audit(
        text: reflowSample,
        token: t,
        width: HabotTextFit.auditWidthDp,
      );
      if (!r.fits) {
        failing++;
      }
    }
    return WcagFinding(
      criterion: WcagCriteria.reflow,
      outcome: failing == 0 ? WcagOutcome.pass : WcagOutcome.fail,
      detail:
          '$checked type tokens audited at ${HabotTextFit.auditWidthDp}dp; '
          '$failing did not fit',
      subjectsChecked: checked,
      subjectsFailing: failing,
    );
  }

  static WcagFinding _targetSize() {
    // 2.5.8 sets 24x24 CSS px; TTMAC-011 holds this project to 48dp, which is
    // stricter. The stricter number is the one audited.
    int checked = 0;
    int failing = 0;
    for (final double visual in <double>[
      TouchStandards.iconDense,
      TouchStandards.iconStandard,
      TouchStandards.iconLarge,
    ]) {
      checked++;
      final Size target = TouchStandards.targetFor(visual);
      if (!TouchTargetPolicy.isCompliant(target)) {
        failing++;
      }
    }
    return WcagFinding(
      criterion: WcagCriteria.targetSize,
      outcome: failing == 0 ? WcagOutcome.pass : WcagOutcome.fail,
      detail:
          '$checked icon sizes expanded through TouchStandards.targetFor; '
          '$failing produced a target below '
          '${TouchTargetPolicy.minimumDp}dp. The WCAG minimum is 24dp; this '
          'project holds itself to the stricter TTMAC-011 figure.',
      subjectsChecked: checked,
      subjectsFailing: failing,
    );
  }

  /// The criteria that need a rendered tree, declared as not-yet-evaluated so
  /// a caller that forgets to run them is penalised by the rate rather than
  /// flattered by their absence.
  static List<WcagFinding> pendingRuntime() => WcagCriteria.ofEvaluation(
    WcagEvaluation.runtime,
  ).map((WcagCriterion c) => WcagFinding(
        criterion: c,
        outcome: WcagOutcome.notEvaluated,
        detail: 'Needs a pumped widget tree. Evaluated by ${c.owner}.',
      )).toList();

  /// The criteria no machine decides. Never a pass, never a fail.
  static List<WcagFinding> judgementCriteria() => WcagCriteria.ofEvaluation(
    WcagEvaluation.judgement,
  ).map((WcagCriterion c) => WcagFinding(
        criterion: c,
        outcome: WcagOutcome.notEvaluated,
        detail:
            'Requires a human reading; excluded from the rate rather than '
            'auto-passed. Owner: ${c.owner}.',
      )).toList();

  /// A full report over the schemes given, with runtime findings merged in.
  static WcagAuditReport report({
    required Map<String, HabotColorScheme> schemes,
    List<WcagFinding> runtimeFindings = const <WcagFinding>[],
  }) {
    final Map<String, WcagFinding> byId = <String, WcagFinding>{};
    for (final WcagFinding f in <WcagFinding>[
      ...auditStatic(schemes: schemes),
      ...pendingRuntime(),
      ...judgementCriteria(),
    ]) {
      byId[f.criterion.id] = f;
    }
    for (final WcagFinding f in runtimeFindings) {
      byId[f.criterion.id] = f;
    }
    return WcagAuditReport(byId.values.toList());
  }
}
