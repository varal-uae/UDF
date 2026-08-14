import 'package:flutter/material.dart';
// Fail-closed: "Release to Tech" stays disabled until every gate passes.
// Portal Architect defines gate keys; mobile tracks met/unmet state.

/// A single fail-closed gate blocking release until [isMet] is true.
class ReleaseGate {
  const ReleaseGate({
    required this.key,
    required this.label,
    required this.isMet,
    this.blockMessage,
  });

  final String key;
  final String label;
  final bool isMet;

  /// Shown in tooltip when this gate blocks release.
  final String? blockMessage;

  String get reason => blockMessage ?? 'Complete: $label';
}

/// Tracks all release prerequisites. Notifies listeners on any gate change.
class ReleaseGateRegistry extends ChangeNotifier {
  final Map<String, ReleaseGate> _gates = {};

  /// Register or replace a gate.
  void setGate(ReleaseGate gate) {
    _gates[gate.key] = gate;
    notifyListeners();
  }

  void setMet(String key, {required bool isMet}) {
    final existing = _gates[key];
    if (existing == null) return;
    if (existing.isMet == isMet) return;
    _gates[key] = ReleaseGate(
      key:          key,
      label:        existing.label,
      isMet:        isMet,
      blockMessage: existing.blockMessage,
    );
    notifyListeners();
  }

  /// Fail-closed: true only when every registered gate is met.
  bool get isReleaseReady {
    if (_gates.isEmpty) return false;
    return _gates.values.every((g) => g.isMet);
  }

  List<ReleaseGate> get unmetGates =>
      _gates.values.where((g) => !g.isMet).toList();

  /// Primary reason shown in disabled tooltip (first unmet gate).
  String? get primaryBlockReason {
    final unmet = unmetGates;
    if (unmet.isEmpty) return null;
    return unmet.first.reason;
  }

  /// All unmet reasons — for accessibility / detailed tooltip.
  String get allBlockReasons {
    final unmet = unmetGates;
    if (unmet.isEmpty) return '';
    return unmet.map((g) => g.reason).join('\n');
  }

  void reset() {
    _gates.clear();
    notifyListeners();
  }
}

/// BCDLD-style execution log for release step outcomes.
class ReleaseExecutionLog {
  ReleaseExecutionLog({
    required this.executionStatus,
    required this.stepOutcome,
    required this.userId,
  }) : stepExecutionId = _newId(),
       executionTimestamp = DateTime.now().toUtc();

  final String stepExecutionId;
  final String executionStatus;
  final DateTime executionTimestamp;
  final String stepOutcome;
  final String userId;

  static int _counter = 0;

  static String _newId() {
    _counter++;
    return 'rel-${DateTime.now().millisecondsSinceEpoch}-$_counter';
  }

  Map<String, dynamic> toMap() => {
        'step_execution_id':   stepExecutionId,
        'execution_status':  executionStatus,
        'execution_timestamp': executionTimestamp.toIso8601String(),
        'step_outcome':      stepOutcome,
        'user_id':           userId,
      };
}
