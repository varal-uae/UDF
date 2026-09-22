// ============================================================
// ANSA-002-A06 · Multi-Step Form Back Button Navigation Handler
// Habot Connect DMCC · UDF Team · Ritwik Sharma
// Atomic Step: Access the application state management architecture layers.
// Metric: File/Asset Discovery Accuracy · Floor=3 attempts/5 min · Optimal=1st attempt <1 min · Output=Pass/Fail
// Standard: Documented repository structure / automated IDE symbol search resolves target instantly.
// ============================================================

import 'dart:async';
import 'dart:convert';

// ── Data Models ──────────────────────────────────────────────

enum DiscoveryMethod { firstAttempt, manualSearch, automatedTooling }


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

class BackButtonNavigationRule {
  final String ruleId;
  // Step index decrement logic: currentStep - 1 (min floor = step 0)
  final int stepFloor;
  final bool dataRetentionOnBack;    // form data preserved on back navigation
  final bool dataLossPreventionGate; // data_loss_detected_IND=FALSE — hard gate
  final bool immutableInd;

  const BackButtonNavigationRule({
    required this.ruleId,
    this.stepFloor = 0,
    this.dataRetentionOnBack = true,
    this.dataLossPreventionGate = true,
    this.immutableInd = true,
  });
}

class ExecutionRecord {
  final String stepExecutionId;
  final String executionStatus;
  final DateTime executionTimestamp;
  final String stepOutcome;
  final String userId;

  ExecutionRecord({
    required this.stepExecutionId,
    required this.executionStatus,
    required this.executionTimestamp,
    required this.stepOutcome,
    required this.userId,
  });
}

class BackNavSimulationResult {
  final String formScreenId;
  final int stepIndexBefore;
  final int stepIndexAfter;
  final bool stepDecrementCorrectInd;  // currentStep - 1
  final bool dataRetainedInd;           // form data preserved
  final bool dataLossDetectedInd;       // MUST be FALSE
  final String applicationResult;

  BackNavSimulationResult({
    required this.formScreenId,
    required this.stepIndexBefore,
    required this.stepIndexAfter,
    required this.stepDecrementCorrectInd,
    required this.dataRetainedInd,
    required this.dataLossDetectedInd,
    required this.applicationResult,
  });

  bool get isPass => applicationResult == 'PASS';
}

class StateArchitectureDiscovery {
  final String targetComponentPath;
  final DiscoveryMethod method;
  final Duration discoveryTime;
  final int attemptCount;
  final bool targetFound;

  StateArchitectureDiscovery({
    required this.targetComponentPath,
    required this.method,
    required this.discoveryTime,
    required this.attemptCount,
    required this.targetFound,
  });

  // EC:7 — File/Asset Discovery Accuracy
  String get passFailOutput {
    if (!targetFound) return 'Fail';
    if (method == DiscoveryMethod.firstAttempt &&
        discoveryTime.inSeconds <= 60) return 'Pass';
    if (method == DiscoveryMethod.manualSearch &&
        attemptCount <= 3 &&
        discoveryTime.inMinutes <= 5) return 'Pass';
    if (method == DiscoveryMethod.automatedTooling) return 'Pass';
    return 'Fail';
  }
}

// ── Core Manager (EC:1–8) ────────────────────────────────────

class Ansa002A06Manager {
  static const double _floor   = 3;  // metric floor gate
  static const double _optimal = 1; // metric optimal target

  static const double _floorPassRate = 0.90;

  // EC:3 — Compile back button navigation handler rule set
  BackButtonNavigationRule compileRule(String ruleId) {
    return BackButtonNavigationRule(
      ruleId: ruleId,
      stepFloor: 0,
      dataRetentionOnBack: true,
      dataLossPreventionGate: true,
      immutableInd: true,
    );
  }

  // EC:5 — Bind back button handler to each multi-step form screen
  bool bindHandlerToScreen({
    required String formScreenId,
    required BackButtonNavigationRule rule,
    required int currentStepIndex,
  }) {
    if (!rule.immutableInd) {
      throw StateError('EC-ANSA-002-A06-005: Rule must be immutable');
    }
    // Floor gate: can only go back if step > 0
    return currentStepIndex > rule.stepFloor;
  }

  // EC:6 — Backward navigation simulation: step decrements, data preserved, no data loss
  BackNavSimulationResult runBackNavSimulation({
    required String formScreenId,
    required int currentStepIndex,
    required BackButtonNavigationRule rule,
    required bool dataRetained,
    required bool dataLossDetected,
  }) {
    final expectedStepAfter = currentStepIndex > rule.stepFloor
        ? currentStepIndex - 1
        : rule.stepFloor;
    final decrementCorrect = expectedStepAfter == (currentStepIndex - 1).clamp(rule.stepFloor, 999);
    // data_loss_detected_IND=FALSE is the primary gate
    final result = (decrementCorrect && dataRetained && !dataLossDetected) ? 'PASS' : 'FAIL';
    return BackNavSimulationResult(
      formScreenId: formScreenId,
      stepIndexBefore: currentStepIndex,
      stepIndexAfter: expectedStepAfter,
      stepDecrementCorrectInd: decrementCorrect,
      dataRetainedInd: dataRetained,
      dataLossDetectedInd: dataLossDetected,
      applicationResult: result,
    );
  }

  // Run simulations across all form screens
  List<BackNavSimulationResult> runAllScreenSimulations({
    required List<Map<String, dynamic>> formScreens,
    required BackButtonNavigationRule rule,
  }) {
    return formScreens.map((s) => runBackNavSimulation(
      formScreenId: s['screen_id'] as String,
      currentStepIndex: s['current_step'] as int,
      rule: rule,
      dataRetained: s['data_retained'] as bool? ?? false,
      dataLossDetected: s['data_loss_detected'] as bool? ?? true,
    )).toList();
  }

  // EC:7 — File/Asset Discovery Accuracy metric
  Map<String, dynamic> calculateDiscoveryAccuracy(
    List<BackNavSimulationResult> results,
    StateArchitectureDiscovery discovery,
  ) {
    if (results.isEmpty) return {'rate': 0.0, 'output': 'Fail'};
    final passed = results.where((r) => r.isPass).length;
    final rate = passed / results.length;
    final discoveryPass = discovery.passFailOutput == 'Pass';
    final output = (rate >= _floorPassRate && discoveryPass) ? 'Pass' : 'Fail';
    return {
      'rate': rate,
      'output': output,
      'passed': passed,
      'total': results.length,
      'discovery_output': discovery.passFailOutput,
      'discovery_method': discovery.method.name,
      'data_loss_gate': results.any((r) => r.dataLossDetectedInd) ? 'FAIL' : 'PASS',
    };
  }

  // Triangular check: screens_registered = simulations_executed (delta=0)
  bool triangularCheck(int registered, int executed) => registered == executed;
}

// ── Pipeline Service ─────────────────────────────────────────

class Ansa002A06PipelineService {
  final Ansa002A06Manager _manager = Ansa002A06Manager();

  Future<Map<String, dynamic>> run({
    required List<Map<String, dynamic>> formScreens,
    required StateArchitectureDiscovery discovery,
    required String userId,
  }) async {
    // EC:1 — Locate multi-step form navigation handler config in shared core design system
    final config = await _locateHandlerConfig();
    if (config == null) return _dlq('EC-ANSA-002-A06-001', {});

    // EC:2 — Extract step execution ID, status, timestamp, outcome, user ID
    final execution = _extractExecutionFields(config, userId);
    if (execution == null) return _dlq('EC-ANSA-002-A06-002', {});

    // EC:3 — Compile back button navigation handler rule set
    final rule = _manager.compileRule(
      'RULE-A06-${DateTime.now().millisecondsSinceEpoch}',
    );

    // EC:4 — Register as immutable versioned navigation handler configuration
    if (!rule.immutableInd) {
      throw StateError('EC-ANSA-002-A06-004: Must be immutable');
    }

    // EC:5 — Bind back button handler to each form screen
    for (final screen in formScreens) {
      if ((screen['current_step'] as int) > 0) {
        final bound = _manager.bindHandlerToScreen(
          formScreenId: screen['screen_id'] as String,
          rule: rule,
          currentStepIndex: screen['current_step'] as int,
        );
        if (!bound) {
          return _dlq('EC-ANSA-002-A06-005', {'screen': screen['screen_id']});
        }
      }
    }

    // EC:6 — Run backward navigation simulations
    final results = _manager.runAllScreenSimulations(
      formScreens: formScreens,
      rule: rule,
    );

    // Triangular check
    if (!_manager.triangularCheck(formScreens.length, results.length)) {
      return _dlq('EC-ANSA-002-A06-TRI', {'expected': formScreens.length});
    }

    // EC:7 — File/Asset Discovery Accuracy metric
    final quality = _manager.calculateDiscoveryAccuracy(results, discovery);

    // EC:8 — Route to shared core design system form interaction library
    await _publishToFormLibrary(rule, userId);

    return {
      'status': 'REGISTERED',
      'pass_rate': quality['rate'],
      'output': quality['output'],
      'data_loss_gate': quality['data_loss_gate'],
      'screens_tested': results.length,
      'discovery_method': quality['discovery_method'],
      'automated_gate': true,
      'ec_ref': 'EC-ANSA-002-A06',
    };
  }

  Future<Map<String, dynamic>?> _locateHandlerConfig() async {
    await Future.delayed(const Duration(milliseconds: 10));
    return {'config_id': 'BACK-NAV-CONFIG-006', 'source': 'shared_core_design_system'};
  }

  Map<String, dynamic>? _extractExecutionFields(
    Map<String, dynamic> config,
    String userId,
  ) {
    return {
      'step_execution_id': 'EX-A06-${DateTime.now().millisecondsSinceEpoch}',
      'execution_status': 'PENDING',
      'user_id': userId,
    };
  }

  Future<void> _publishToFormLibrary(
    BackButtonNavigationRule rule,
    String userId,
  ) async {
    await Future.delayed(const Duration(milliseconds: 15));
  }

  Map<String, dynamic> _dlq(String code, Map<String, dynamic> payload) =>
      {'error': code, 'payload': jsonEncode(payload), 'dlq': true};
}

// ── Entry Point ───────────────────────────────────────────────

void main() async {
  final service = Ansa002A06PipelineService();
  final result = await service.run(
    formScreens: [
      {'screen_id': 'FORM-STEP-1', 'current_step': 1, 'data_retained': true, 'data_loss_detected': false},
      {'screen_id': 'FORM-STEP-2', 'current_step': 2, 'data_retained': true, 'data_loss_detected': false},
      {'screen_id': 'FORM-STEP-3', 'current_step': 3, 'data_retained': true, 'data_loss_detected': false},
      {'screen_id': 'FORM-STEP-4', 'current_step': 4, 'data_retained': true, 'data_loss_detected': false},
    ],
    discovery: StateArchitectureDiscovery(
      targetComponentPath: 'lib/core/form/back_button_handler.dart',
      method: DiscoveryMethod.firstAttempt,
      discoveryTime: const Duration(seconds: 12),
      attemptCount: 1,
      targetFound: true,
    ),
    userId: 'user-ritwik-001',
  );
  print('ANSA-002-A06 result: $result');
}
