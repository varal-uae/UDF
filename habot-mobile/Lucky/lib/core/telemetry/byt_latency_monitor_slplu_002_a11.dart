// SLPLU-002-A11 — Byt Latency Monitor & Warning Alert System.
// Implements real-time latency tracking for Byt executions, enforces strict UTC standardization, logs console warnings when render times exceed thresholds, and provides mock data for dashboard charting.

import 'dart:developer' as developer;

/// Atomic-level data model representing a single Byt execution step.
class BytExecutionRecord {
  final String stepExecutionId;
  final String userId;
  final String sessionId;
  final String executionStatus;
  final DateTime userTapTimestampUtc;
  final DateTime backendCommitTimestampUtc;
  final String stepOutcome;
  final int latencyMs;

  const BytExecutionRecord({
    required this.stepExecutionId,
    required this.userId,
    required this.sessionId,
    required this.executionStatus,
    required this.userTapTimestampUtc,
    required this.backendCommitTimestampUtc,
    required this.stepOutcome,
    required this.latencyMs,
  });

  Map<String, dynamic> toJson() => {
        'stepExecutionId': stepExecutionId,
        'userId': userId,
        'sessionId': sessionId,
        'executionStatus': executionStatus,
        'userTapTimestampUtc': userTapTimestampUtc.toIso8601String(),
        'backendCommitTimestampUtc': backendCommitTimestampUtc.toIso8601String(),
        'stepOutcome': stepOutcome,
        'latencyMs': latencyMs,
      };
}

/// Poka-Yoke (Mistake-Proofing): Enforces strict UTC standardization before
/// calculation to prevent device timezone differences from creating false latency spikes.
class UtcLatencyCalculator {
  /// Calculates the millisecond difference between the user's tap and the backend storage commit.
  /// Both timestamps are forced to UTC to ensure architectural accountability.
  static int calculateLatencyMs(DateTime tapTime, DateTime commitTime) {
    final utcTap = tapTime.toUtc();
    final utcCommit = commitTime.toUtc();
    return utcCommit.difference(utcTap).inMilliseconds;
  }
}

/// Core Analytics Engine responsible for monitoring Byt clocks / latency metrics.
/// Applied to all Byt executions. Triggers auto-alerts on latency spikes.
class BytLatencyMonitor {
  /// Warning threshold in milliseconds. Standard mobile UI timeout is ~10000ms,
  /// but we warn much earlier to ensure snappy responses.
  final int warningThresholdMs;

  /// Stores records locally as mock for BigQuery streaming alignment.
  final List<BytExecutionRecord> _records = [];

  BytLatencyMonitor({this.warningThresholdMs = 300});

  List<BytExecutionRecord> get records => List.unmodifiable(_records);

  /// Tracks a Byt execution and logs a console warning if it exceeds the threshold.
  void trackExecution({
    required String stepExecutionId,
    required String userId,
    required String sessionId,
    required String executionStatus,
    required DateTime userTapTimestamp,
    required DateTime backendCommitTimestamp,
    required String stepOutcome,
  }) {
    // Poka-Yoke: Strict UTC enforcement
    final latencyMs = UtcLatencyCalculator.calculateLatencyMs(
      userTapTimestamp,
      backendCommitTimestamp,
    );

    final record = BytExecutionRecord(
      stepExecutionId: stepExecutionId,
      userId: userId,
      sessionId: sessionId,
      executionStatus: executionStatus,
      userTapTimestampUtc: userTapTimestamp.toUtc(),
      backendCommitTimestampUtc: backendCommitTimestamp.toUtc(),
      stepOutcome: stepOutcome,
      latencyMs: latencyMs,
    );

    _records.add(record);

    // Implement the warning alert — log a console warning when a Byt render
    // exceeds the warning threshold.
    if (latencyMs > warningThresholdMs) {
      developer.log(
        '[WARNING] Byt Latency Spike Detected! Execution ID: $stepExecutionId | '
        'Latency: ${latencyMs}ms (Threshold: ${warningThresholdMs}ms) | '
        'User: $userId',
        name: 'SLPLU-002-A11-AnalyticsEngine',
        level: 900, // Warning level
      );
    } else {
      developer.log(
        '[INFO] Byt Execution Tracked. ID: $stepExecutionId | Latency: ${latencyMs}ms',
        name: 'SLPLU-002-A11-AnalyticsEngine',
        level: 800,
      );
    }
  }

  /// Returns average latency across all tracked executions.
  double getAverageLatencyMs() {
    if (_records.isEmpty) return 0.0;
    final total = _records.fold<int>(0, (sum, r) => sum + r.latencyMs);
    return total / _records.length;
  }

  /// Clears local store (useful for testing or memory management).
  void clearRecords() => _records.clear();
}

/// Mock Data Repository simulating real-time BigQuery metrics stream.
/// Used to populate Canvas/SVG line charts on the dashboard while keeping
/// thresholds fixed and responsive on smaller screens.
class MockBytMetricsRepository {
  static final BytLatencyMonitor monitor = BytLatencyMonitor(warningThresholdMs: 300);

  /// Generates realistic local mock data directly inside the generated file.
  static void seedMockData() {
    final now = DateTime.now().toUtc();

    final mockExecutions = [
      {
        'stepExecutionId': 'STEP-001',
        'userId': 'USR-8821',
        'sessionId': 'SESS-A1',
        'status': 'SUCCESS',
        'tapOffsetMs': -5000,
        'commitOffsetMs': -4850, // 150ms latency (Good)
        'outcome': 'COMMITTED',
      },
      {
        'stepExecutionId': 'STEP-002',
        'userId': 'USR-8821',
        'sessionId': 'SESS-A1',
        'status': 'SUCCESS',
        'tapOffsetMs': -4000,
        'commitOffsetMs': -3550, // 450ms latency (Warning Spike)
        'outcome': 'COMMITTED',
      },
      {
        'stepExecutionId': 'STEP-003',
        'userId': 'USR-9932',
        'sessionId': 'SESS-B2',
        'status': 'SUCCESS',
        'tapOffsetMs': -3000,
        'commitOffsetMs': -2910, // 90ms latency (Excellent)
        'outcome': 'COMMITTED',
      },
      {
        'stepExecutionId': 'STEP-004',
        'userId': 'USR-1104',
        'sessionId': 'SESS-C3',
        'status': 'TIMEOUT',
        'tapOffsetMs': -2000,
        'commitOffsetMs': -1100, // 900ms latency (Major Spike)
        'outcome': 'FAILED_TIMEOUT',
      },
      {
        'stepExecutionId': 'STEP-005',
        'userId': 'USR-8821',
        'sessionId': 'SESS-A1',
        'status': 'SUCCESS',
        'tapOffsetMs': -1000,
        'commitOffsetMs': -780, // 220ms latency (Good)
        'outcome': 'COMMITTED',
      },
    ];

    for (final exec in mockExecutions) {
      monitor.trackExecution(
        stepExecutionId: exec['stepExecutionId'] as String,
        userId: exec['userId'] as String,
        sessionId: exec['sessionId'] as String,
        executionStatus: exec['status'] as String,
        userTapTimestamp: now.add(Duration(milliseconds: exec['tapOffsetMs'] as int)),
        backendCommitTimestamp: now.add(Duration(milliseconds: exec['commitOffsetMs'] as int)),
        stepOutcome: exec['outcome'] as String,
      );
    }
  }

  /// Retrieves data formatted for Canvas/SVG line charts.
  /// Prevents hiding latency spikes on smaller screens by returning raw ms values.
  static List<Map<String, dynamic>> getChartDataPoints() {
    return monitor.records.map((r) {
      return {
        'timestamp': r.backendCommitTimestampUtc.millisecondsSinceEpoch.toDouble(),
        'latencyMs': r.latencyMs.toDouble(),
        'isSpike': r.latencyMs > monitor.warningThresholdMs,
        'stepId': r.stepExecutionId,
      };
    }).toList();
  }
}
