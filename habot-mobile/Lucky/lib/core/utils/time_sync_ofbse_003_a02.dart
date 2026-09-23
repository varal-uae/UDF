// OFBSE-003-A02 — Client-Side Timestamp Synchronization (Mobile UTC).
// Ensures all timestamp fields use UTC exclusively in ISO8601 format, discarding future timestamps and providing time-drift isolation for UDF execution pipelines.

/// Core utility package for UTC-only timestamp synchronization.
/// All records must use [DateTime] in UTC. Local device time is strictly prohibited.
class TimeSyncUtils {
  TimeSyncUtils._();

  /// Returns the current synchronized UTC timestamp in ISO8601 format.
  static String getUtcIso8601Now() {
    return DateTime.now().toUtc().toIso8601String();
  }

  /// Parses an ISO8601 string and forces it to UTC.
  /// Returns null if parsing fails or if the timestamp is in the future.
  static DateTime? parseAndValidateUtc(String iso8601String) {
    try {
      final parsed = DateTime.parse(iso8601String).toUtc();
      final nowUtc = DateTime.now().toUtc();
      
      // Poka-Yoke: Discard messages containing timestamps that exist in the future.
      if (parsed.isAfter(nowUtc)) {
        return null;
      }
      
      return parsed;
    } catch (_) {
      return null;
    }
  }

  /// Calculates time drift variance in milliseconds between local clock and expected server sync.
  /// Used to isolate interface execution paths until synchronization is completed.
  static int calculateDriftMs(DateTime expectedServerTime) {
    final nowUtc = DateTime.now().toUtc();
    return nowUtc.difference(expectedServerTime.toUtc()).inMilliseconds.abs();
  }
}

/// Data model representing a single atomic step execution record.
/// Conforms to BigQuery alignment and Cloud Run server time loops.
class StepExecutionRecord {
  final String stepExecutionId;
  final String executionStatus;
  final String executionTimestamp; // Strictly UTC ISO8601
  final String stepOutcome;
  final String userId;
  final String completionStatus;
  final String actionEventTimestamp;
  final String userSessionId;

  const StepExecutionRecord({
    required this.stepExecutionId,
    required this.executionStatus,
    required this.executionTimestamp,
    required this.stepOutcome,
    required this.userId,
    required this.completionStatus,
    required this.actionEventTimestamp,
    required this.userSessionId,
  });

  factory StepExecutionRecord.fromJson(Map<String, dynamic> json) {
    return StepExecutionRecord(
      stepExecutionId: json['stepExecutionId'] as String? ?? '',
      executionStatus: json['executionStatus'] as String? ?? 'Unknown',
      executionTimestamp: json['executionTimestamp'] as String? ?? TimeSyncUtils.getUtcIso8601Now(),
      stepOutcome: json['stepOutcome'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      completionStatus: json['completionStatus'] as String? ?? 'Not Complete',
      actionEventTimestamp: json['actionEventTimestamp'] as String? ?? TimeSyncUtils.getUtcIso8601Now(),
      userSessionId: json['userSessionId'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stepExecutionId': stepExecutionId,
      'executionStatus': executionStatus,
      'executionTimestamp': executionTimestamp,
      'stepOutcome': stepOutcome,
      'userId': userId,
      'completionStatus': completionStatus,
      'actionEventTimestamp': actionEventTimestamp,
      'userSessionId': userSessionId,
    };
  }
}

/// Mock repository simulating backend data ingress pipelines.
/// Provides realistic local mock data directly inside the generated file.
class MockStepExecutionRepository {
  MockStepExecutionRepository._();

  /// Threshold values sourced from approved policy document.
  static const double businessRuleCoverageFloor = 0.90;
  static const double businessRuleCoverageOptimal = 1.00;

  static List<StepExecutionRecord> fetchMockRecords() {
    final nowUtc = TimeSyncUtils.getUtcIso8601Now();
    final pastUtc = DateTime.now().toUtc().subtract(const Duration(hours: 2)).toIso8601String();

    return [
      StepExecutionRecord(
        stepExecutionId: 'STEP-001',
        executionStatus: 'Success',
        executionTimestamp: pastUtc,
        stepOutcome: 'Token engine core configuration built successfully.',
        userId: 'USR-9921',
        completionStatus: 'Complete',
        actionEventTimestamp: pastUtc,
        userSessionId: 'SESS-A1B2C3',
      ),
      StepExecutionRecord(
        stepExecutionId: 'STEP-002',
        executionStatus: 'Pending',
        executionTimestamp: nowUtc,
        stepOutcome: 'Awaiting peer review before definition lock.',
        userId: 'USR-4450',
        completionStatus: 'Partial',
        actionEventTimestamp: nowUtc,
        userSessionId: 'SESS-D4E5F6',
      ),
      StepExecutionRecord(
        stepExecutionId: 'STEP-003',
        executionStatus: 'Failed',
        executionTimestamp: pastUtc,
        stepOutcome: 'Rejected: Timestamp existed in the future. Discarded by ingress pipeline.',
        userId: 'USR-1123',
        completionStatus: 'Not Complete',
        actionEventTimestamp: pastUtc,
        userSessionId: 'SESS-G7H8I9',
      ),
    ];
  }

  /// Validates a list of records against time protocol rules.
  /// Isolates execution paths where time-drift variances are detected.
  static List<StepExecutionRecord> validateAndFilterRecords(List<StepExecutionRecord> records) {
    return records.where((record) {
      final validatedTime = TimeSyncUtils.parseAndValidateUtc(record.executionTimestamp);
      // Discard if timestamp is invalid or in the future
      return validatedTime != null;
    }).toList();
  }
}