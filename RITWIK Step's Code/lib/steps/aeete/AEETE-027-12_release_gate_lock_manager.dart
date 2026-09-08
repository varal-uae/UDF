// =============================================================================
// AEETE-027-12 — Release to Tech Lock Gate
// Atomic Step: Gray out and lock 'Release to Tech' button if score is not zero
// Metric:      Process Execution Quality Score · Floor=>=90% · Optimal=>=98%
// Standard:    ISO 9001:2015 Quality Management Standard
// Module:      release_gate_lock_manager.dart
// Repo:        github.com/RitwikHC/theme-typography · branch: ritwik
// Author:      Ritwik Sharma — Frontend Integration Specialist | UDF Team
// Date:        25-Aug-2026
// Gate Rule:   pipeline_score == 0 → UNLOCKED | pipeline_score != 0 → LOCKED
// =============================================================================

import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Enums — match DB CHECK constraints
// ---------------------------------------------------------------------------

/// Lock type — mirrors lock_type ENUM in DB schema.
enum LockType { scoreGate, manual, system }

extension LockTypeExt on LockType {
  String get dbValue => switch (this) {
    LockType.scoreGate => 'SCORE_GATE',
    LockType.manual    => 'MANUAL',
    LockType.system    => 'SYSTEM',
  };
}

/// Lock state — binary, no partial states.
enum LockState { locked, unlocked }

extension LockStateExt on LockState {
  String get dbValue => name.toUpperCase();
}

// ---------------------------------------------------------------------------
// Data models
// ---------------------------------------------------------------------------

/// Input pipeline score record.
/// Maps to lock_pipeline_registry row.
class PipelineScoreRecord {
  final String pipelineRunId;
  final int pipelineScore; // Aggregate failed trace loop count. 0=all passed.
  final LockType lockType;
  final String lockedBy;  // Pipeline runner service ID or user ID
  final String lockReason;

  const PipelineScoreRecord({
    required this.pipelineRunId,
    required this.pipelineScore,
    this.lockType = LockType.scoreGate,
    required this.lockedBy,
    required this.lockReason,
  });
}

/// EC:3 — Result of binary zero-score gate evaluation.
/// Maps to lock_enforcement_registry row.
class LockEvaluation {
  final String pipelineRunId;
  final int pipelineScore;
  final LockState lockState;
  final bool immutable; // immutable_IND — TRUE once registered

  const LockEvaluation({
    required this.pipelineRunId,
    required this.pipelineScore,
    required this.lockState,
    this.immutable = true,
  });

  bool get isLocked => lockState == LockState.locked;

  String lockReason(String lockedBy) => isLocked
      ? 'Pipeline score=$pipelineScore; E2E trace loop failures detected. '
        'Release to Tech blocked until score=0. Locked by: $lockedBy'
      : 'Pipeline score=0; all E2E trace loops passed. Release to Tech permitted.';
}

/// EC:5 — Result of applying button lock attributes.
/// Maps to lock_application_log row.
class ButtonLockApplication {
  final bool buttonDisabled;  // button_disabled_IND
  final bool ariaDisabled;    // aria_disabled_IND
  final bool isGreyedOut;     // button_style = GREYED_OUT

  const ButtonLockApplication({
    required this.buttonDisabled,
    required this.ariaDisabled,
    required this.isGreyedOut,
  });

  /// All 3 attributes must align for 4-check to pass (EC:6).
  bool get applicationResult =>
      buttonDisabled && ariaDisabled && isGreyedOut;

  String get buttonStyle => isGreyedOut ? 'GREYED_OUT' : 'ACTIVE';
}

/// EC:7 — Process Execution Quality Score result.
class ProcessQualityResult {
  final double qualityRatePct;
  final String qualityOutput; // Good / Average / Poor (ISO 9001:2015)
  final int lockedCorrectly;
  final int totalEvaluations;
  final bool gatePass; // >= 90%

  const ProcessQualityResult({
    required this.qualityRatePct,
    required this.qualityOutput,
    required this.lockedCorrectly,
    required this.totalEvaluations,
    required this.gatePass,
  });
}

// ---------------------------------------------------------------------------
// AEETE-027-12: Release Gate Lock Manager
// ---------------------------------------------------------------------------

/// Manages the Release to Tech button lock gate.
///
/// Mirrors ReleaseGateLockManager class from release_gate_lock_manager.py.
///
/// Usage:
/// ```dart
/// final manager = ReleaseGateLockManager();
/// final eval = manager.evaluateScoreGate(PipelineScoreRecord(
///   pipelineRunId: 'run-001',
///   pipelineScore: 3, // 3 trace loop failures → LOCKED
///   lockedBy: 'github-actions',
///   lockReason: 'E2E failures detected',
/// ));
/// print(eval.isLocked); // true
/// ```
class ReleaseGateLockManager {

  // -------------------------------------------------------------------------
  // EC:3 — Binary zero-score gate evaluation. No exceptions.
  // score==0 → UNLOCKED | score!=0 → LOCKED
  // -------------------------------------------------------------------------
  LockEvaluation evaluateScoreGate(PipelineScoreRecord record) {
    final lockState = record.pipelineScore != 0
        ? LockState.locked
        : LockState.unlocked;
    return LockEvaluation(
      pipelineRunId: record.pipelineRunId,
      pipelineScore: record.pipelineScore,
      lockState:     lockState,
      immutable:     true,
    );
  }

  // -------------------------------------------------------------------------
  // EC:5 — Derive button attributes from evaluation.
  // -------------------------------------------------------------------------
  ButtonLockApplication buildButtonApplication(LockEvaluation evaluation) {
    final locked = evaluation.isLocked;
    return ButtonLockApplication(
      buttonDisabled: locked,
      ariaDisabled:   locked,
      isGreyedOut:    locked,
    );
  }

  // -------------------------------------------------------------------------
  // EC:6 — Execute 4-check button lock validation.
  // All 4 must pass: disabled / aria / style / registry status
  // -------------------------------------------------------------------------
  bool validateButtonLock({
    required ButtonLockApplication application,
    required LockState registryLockState,
  }) {
    return application.buttonDisabled &&
           application.ariaDisabled &&
           application.isGreyedOut &&
           registryLockState == LockState.locked;
  }

  // -------------------------------------------------------------------------
  // EC:7 — Process Execution Quality Score (ISO 9001:2015).
  // Floor=90% · Optimal=98%
  // -------------------------------------------------------------------------
  ProcessQualityResult calculateQuality({
    required int lockedCorrectly,
    required int totalEvaluations,
  }) {
    final rate = totalEvaluations > 0
        ? lockedCorrectly / totalEvaluations * 100
        : 0.0;
    final output = rate >= 98 ? 'Good' : rate >= 90 ? 'Average' : 'Poor';
    return ProcessQualityResult(
      qualityRatePct:   rate,
      qualityOutput:    output,
      lockedCorrectly:  lockedCorrectly,
      totalEvaluations: totalEvaluations,
      gatePass:         rate >= 90,
    );
  }

  // -------------------------------------------------------------------------
  // Triangular Check: evaluations_registered == applications_confirmed (delta=0)
  // -------------------------------------------------------------------------
  bool triangularCheck(int registered, int confirmed) => registered == confirmed;
}

// ---------------------------------------------------------------------------
// Flutter widget: Release to Tech Button
// Mirrors ReleaseToTechButton.jsx — disabled + greyed + aria when LOCKED
// ---------------------------------------------------------------------------

/// Release to Tech button with binary lock gate enforcement.
///
/// When [evaluation.isLocked]:
/// - Button is visually greyed-out (MD3 disabled token)
/// - AbsorbPointer prevents all tap events (pointer-events:none equivalent)
/// - Semantics.enabled=false (aria-disabled equivalent)
/// - Lock reason tooltip shown below button
///
/// Usage:
/// ```dart
/// ReleaseToTechButton(
///   evaluation: manager.evaluateScoreGate(scoreRecord),
///   lockedBy: 'github-actions-runner',
///   onRelease: () => triggerRelease(),
/// )
/// ```
class ReleaseToTechButton extends StatelessWidget {
  final LockEvaluation evaluation;
  final String lockedBy;
  final VoidCallback? onRelease;

  const ReleaseToTechButton({
    super.key,
    required this.evaluation,
    required this.lockedBy,
    this.onRelease,
  });

  @override
  Widget build(BuildContext context) {
    final locked = evaluation.isLocked;
    final reason = evaluation.lockReason(lockedBy);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // EC:5 — Semantics: aria-disabled equivalent
        Semantics(
          button:  true,
          enabled: !locked,
          label:   locked
              ? 'Release to Tech — locked. $reason'
              : 'Release to Tech',
          child: AbsorbPointer(
            // EC:5 — pointer-events: none equivalent (belt-and-braces)
            absorbing: locked,
            child: ElevatedButton.icon(
              onPressed: locked ? null : onRelease,
              icon: Icon(locked ? Icons.lock_outline : Icons.rocket_launch),
              label: Text(
                locked
                    ? 'Locked — Score: ${evaluation.pipelineScore}'
                    : 'Release to Tech',
              ),
              style: locked
                  ? ElevatedButton.styleFrom(
                      // MD3 disabled surface tokens
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .surfaceVariant,
                      foregroundColor: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.38),
                      disabledBackgroundColor: Theme.of(context)
                          .colorScheme
                          .surfaceVariant,
                    )
                  : null,
            ),
          ),
        ),
        // EC:5 — Lock reason tooltip (shown when LOCKED)
        if (locked) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFB00020).withOpacity(0.08),
              border: const Border(
                left: BorderSide(color: Color(0xFFB00020), width: 3),
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Deployment blocked. $reason',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFFB00020),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
