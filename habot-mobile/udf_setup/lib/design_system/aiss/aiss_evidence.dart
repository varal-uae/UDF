/// AISS evidence records.
///
/// Every atomic step in the step sheet carries a "Data Collected by System"
/// column listing the exact fields that step must emit on completion, plus a
/// metric row (Floor / Optimal / Ceiling) and a "Best Qualitative Output" scale.
/// This file turns those columns into typed records, so "did the step meet its
/// requirement?" is answered by data the build produces rather than by opinion.
///
/// The gate in `test/aiss/` builds one [AissEvidence] per step and writes the
/// set to `build/aiss/evidence.json`.
library;

/// The "Best Qualitative Output" scales the step sheet uses.
enum AissOutcome {
  /// Scale: Complete / Partial / Not Complete -- and Pass / Fail.
  complete,
  partial,
  notComplete,
  pass,
  fail,
  good,
  average,
  poor;

  bool get isAcceptable =>
      this == AissOutcome.complete ||
      this == AissOutcome.pass ||
      this == AissOutcome.good;

  String get label {
    switch (this) {
      case AissOutcome.complete:
        return 'Complete';
      case AissOutcome.partial:
        return 'Partial';
      case AissOutcome.notComplete:
        return 'Not Complete';
      case AissOutcome.pass:
        return 'Pass';
      case AissOutcome.fail:
        return 'Fail';
      case AissOutcome.good:
        return 'Good';
      case AissOutcome.average:
        return 'Average';
      case AissOutcome.poor:
        return 'Poor';
    }
  }
}

/// One measurement against the step's Floor / Optimal / Ceiling boundaries.
class AissMeasurement {
  const AissMeasurement({
    required this.metricName,
    required this.observed,
    required this.floor,
    required this.optimal,
    required this.ceiling,
    this.higherIsBetter = true,
  });

  final String metricName;
  final String observed;

  /// Verbatim from the step sheet's Floor / Optimal Target / Ceiling columns.
  final String floor;
  final String optimal;
  final String ceiling;

  final bool higherIsBetter;

  Map<String, Object?> toJson() => <String, Object?>{
    'metric_name': metricName,
    'observed': observed,
    'floor_boundary': floor,
    'optimal_target': optimal,
    'ceiling_boundary': ceiling,
    'higher_is_better': higherIsBetter,
  };
}

/// One gate that ran, and what it concluded.
class AissGate {
  const AissGate({
    required this.id,
    required this.requirementSource,
    required this.description,
    required this.passed,
    this.detail,
    this.deferred = false,
  });

  /// Stable id, e.g. 'TTMCS-004-G3'.
  final String id;

  /// Where the requirement came from -- the exact spreadsheet column, quoted.
  final String requirementSource;

  final String description;
  final bool passed;
  final String? detail;

  /// A requirement that is knowingly not met yet, for a reason recorded in
  /// [detail] -- an open decision, or something outside this suite's reach.
  ///
  /// A deferral is NOT a pass. The step still reports Partial. What it changes
  /// is that the gate runner stays green, so a genuine regression is still
  /// visible instead of being buried under a permanently red build.
  ///
  /// Deferring a gate is a deliberate, reviewable act: it puts the reason in
  /// `evidence.json` where someone can argue with it.
  final bool deferred;

  /// True when this gate represents real, unexplained breakage.
  bool get isFailure => !passed && !deferred;

  Map<String, Object?> toJson() => <String, Object?>{
    'gate_id': id,
    'requirement_source': requirementSource,
    'description': description,
    'passed': passed,
    'deferred': deferred,
    if (detail != null) 'detail': detail,
  };
}

/// The complete evidence record for one atomic implementation step.
class AissEvidence {
  const AissEvidence({
    required this.globalReferenceId,
    required this.atomicStepReferenceId,
    required this.setupStepAction,
    required this.implementationOrder,
    required this.assignedTeamMember,
    required this.dataCollected,
    required this.measurements,
    required this.gates,
    required this.artefacts,
  });

  final String globalReferenceId;
  final String atomicStepReferenceId;
  final String setupStepAction;
  final int implementationOrder;
  final String assignedTeamMember;

  /// The step sheet's "Data Collected by System" fields, populated.
  final Map<String, String> dataCollected;

  final List<AissMeasurement> measurements;
  final List<AissGate> gates;

  /// Files this step produced, relative to the Flutter project root.
  final List<String> artefacts;

  /// Every gate that did not pass, deferred or not.
  List<AissGate> get failedGates =>
      gates.where((AissGate g) => !g.passed).toList();

  /// Gates that are knowingly open, with a recorded reason.
  List<AissGate> get deferredGates =>
      gates.where((AissGate g) => g.deferred).toList();

  /// Gates that are broken with no explanation. These are the ones that must
  /// fail the build.
  List<AissGate> get brokenGates =>
      gates.where((AissGate g) => g.isFailure).toList();

  /// Completion status is derived, never asserted by hand.
  ///
  /// A deferral does not round up to Complete. If a requirement is not met,
  /// the step is Partial no matter how good the reason.
  AissOutcome get outcome {
    if (gates.isEmpty) {
      return AissOutcome.notComplete;
    }
    if (failedGates.isEmpty) {
      return AissOutcome.complete;
    }
    if (failedGates.length == gates.length) {
      return AissOutcome.notComplete;
    }
    return AissOutcome.partial;
  }

  double get gatePassRate =>
      gates.isEmpty ? 0 : (gates.length - failedGates.length) / gates.length;

  Map<String, Object?> toJson() => <String, Object?>{
    'global_reference_id': globalReferenceId,
    'atomic_step_reference_id': atomicStepReferenceId,
    'setup_step_action': setupStepAction,
    'implementation_order': implementationOrder,
    'assigned_team_member': assignedTeamMember,
    'completion_status': outcome.label,
    'gate_pass_rate': gatePassRate,
    'gates_total': gates.length,
    'gates_failed': failedGates.length,
    'gates_deferred': deferredGates.length,
    'gates_broken': brokenGates.length,
    'data_collected_by_system': dataCollected,
    'measurements': measurements
        .map((AissMeasurement m) => m.toJson())
        .toList(),
    'gates': gates.map((AissGate g) => g.toJson()).toList(),
    'artefacts': artefacts,
  };
}
