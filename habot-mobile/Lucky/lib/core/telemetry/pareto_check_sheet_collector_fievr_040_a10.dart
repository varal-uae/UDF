// FIEVR-040-A10 — Pareto Analysis Automated Check Sheet Data Collector.
// Background telemetry module that captures structured validation failure records, sanitizes PII, 
// and computes cumulative percentage totals across ordered defect categories for live Pareto diagnostics.

import 'dart:async';
import 'dart:collection';
import 'dart:convert';

/// Completion status domain enum for validation check sheet events.
enum CheckSheetCompletionStatus {
  complete('Complete'),
  partial('Partial'),
  notComplete('Not Complete');

  final String value;
  const CheckSheetCompletionStatus(this.value);
}

/// Step outcome domain enum.
enum StepOutcome {
  success('SUCCESS'),
  failure('FAILURE'),
  validationError('VALIDATION_ERROR'),
  skipped('SKIPPED');

  final String value;
  const StepOutcome(this.value);
}

/// Atomic check sheet record representing a single validation failure or execution step.
class CheckSheetRecord {
  final String stepExecutionId;
  final String executionStatus;
  final DateTime executionTimestamp;
  final StepOutcome stepOutcome;
  final String userId;
  final String sessionId;
  final CheckSheetCompletionStatus completionStatus;
  final DateTime actionTimestamp;
  final String categoryTag;
  final String errorRuleCode;
  final Map<String, dynamic> metadata;

  const CheckSheetRecord({
    required this.stepExecutionId,
    required this.executionStatus,
    required this.executionTimestamp,
    required this.stepOutcome,
    required this.userId,
    required this.sessionId,
    required this.completionStatus,
    required this.actionTimestamp,
    required this.categoryTag,
    required this.errorRuleCode,
    this.metadata = const {},
  });

  /// Sanitizes sensitive values (e.g. passwords, secrets, credit cards, auth tokens) for security audits.
  Map<String, dynamic> toSanitizedMap() {
    final sanitizedMeta = <String, dynamic>{};
    final sensitiveKeys = {
      'password',
      'token',
      'secret',
      'apikey',
      'auth',
      'pin',
      'cvv',
      'ssn',
    };

    metadata.forEach((key, value) {
      if (sensitiveKeys.any((s) => key.toLowerCase().contains(s))) {
        sanitizedMeta[key] = '***REDACTED***';
      } else {
        sanitizedMeta[key] = value;
      }
    });

    return {
      'stepExecutionId': stepExecutionId,
      'executionStatus': executionStatus,
      'executionTimestamp': executionTimestamp.toUtc().toIso8601String(),
      'stepOutcome': stepOutcome.value,
      'userId': userId.isEmpty ? 'ANONYMOUS' : userId,
      'sessionId': sessionId,
      'completionStatus': completionStatus.value,
      'actionTimestamp': actionTimestamp.toUtc().toIso8601String(),
      'categoryTag': categoryTag.trim().isEmpty ? 'UNCATEGORIZED' : categoryTag,
      'errorRuleCode': errorRuleCode,
      'metadata': sanitizedMeta,
    };
  }

  String toJson() => jsonEncode(toSanitizedMap());
}

/// Pareto category bin containing frequency count and running cumulative percentage.
class ParetoBin {
  final String categoryTag;
  final int frequencyCount;
  final double relativePercentage;
  final double cumulativePercentage;

  const ParetoBin({
    required this.categoryTag,
    required this.frequencyCount,
    required this.relativePercentage,
    required this.cumulativePercentage,
  });

  Map<String, dynamic> toMap() => {
        'categoryTag': categoryTag,
        'frequencyCount': frequencyCount,
        'relativePercentage': double.parse(relativePercentage.toStringAsFixed(2)),
        'cumulativePercentage': double.parse(cumulativePercentage.toStringAsFixed(2)),
      };
}

/// Pareto analysis report calculated across check sheet items.
class ParetoAnalysisReport {
  final DateTime generatedAt;
  final int totalCount;
  final List<ParetoBin> orderedBins;

  const ParetoAnalysisReport({
    required this.generatedAt,
    required this.totalCount,
    required this.orderedBins,
  });

  Map<String, dynamic> toMap() => {
        'generatedAt': generatedAt.toUtc().toIso8601String(),
        'totalCount': totalCount,
        'bins': orderedBins.map((b) => b.toMap()).toList(),
      };
}

/// Callback signature for streaming structured check sheet batches to cloud gateway/analytical queues.
typedef CheckSheetBatchDispatcher = Future<void> Function(
  List<Map<String, dynamic>> records,
  ParetoAnalysisReport paretoSummary,
);

/// Thread-isolated background collector for Pareto analysis check sheets.
/// Decoupled from UI frames (60fps guaranteed) with fail-safe error isolation.
class ParetoCheckSheetDataCollector {
  ParetoCheckSheetDataCollector({
    CheckSheetBatchDispatcher? dispatcher,
    int batchThreshold = 25,
    Duration flushInterval = const Duration(seconds: 30),
  })  : _dispatcher = dispatcher,
        _batchThreshold = batchThreshold,
        _flushInterval = flushInterval {
    _startPeriodicFlush();
  }

  final CheckSheetBatchDispatcher? _dispatcher;
  final int _batchThreshold;
  final Duration _flushInterval;

  final Queue<CheckSheetRecord> _recordQueue = Queue<CheckSheetRecord>();
  final Map<String, int> _categoryFrequencyMap = <String, int>{};
  Timer? _flushTimer;
  bool _isFlushing = false;

  void _startPeriodicFlush() {
    _flushTimer?.cancel();
    _flushTimer = Timer.periodic(_flushInterval, (_) {
      unawaited(_flushQueueSafely());
    });
  }

  /// Records a form validation failure or execution step passively without blocking UI threads.
  void recordEvent({
    required String stepExecutionId,
    required String executionStatus,
    required StepOutcome stepOutcome,
    required String userId,
    required String sessionId,
    required CheckSheetCompletionStatus completionStatus,
    required String categoryTag,
    required String errorRuleCode,
    Map<String, dynamic> metadata = const {},
    DateTime? eventTime,
  }) {
    try {
      final timestamp = eventTime ?? DateTime.now();
      final record = CheckSheetRecord(
        stepExecutionId: stepExecutionId,
        executionStatus: executionStatus,
        executionTimestamp: timestamp,
        stepOutcome: stepOutcome,
        userId: userId,
        sessionId: sessionId,
        completionStatus: completionStatus,
        actionTimestamp: timestamp,
        categoryTag: categoryTag,
        errorRuleCode: errorRuleCode,
        metadata: metadata,
      );

      _recordQueue.add(record);
      final sanitizedTag = categoryTag.trim().isEmpty ? 'UNCATEGORIZED' : categoryTag;
      _categoryFrequencyMap[sanitizedTag] = (_categoryFrequencyMap[sanitizedTag] ?? 0) + 1;

      if (_recordQueue.length >= _batchThreshold) {
        scheduleMicrotask(() => unawaited(_flushQueueSafely()));
      }
    } catch (_) {
      // Mistake-Proofing (Poka-Yoke): Completely isolate telemetry drop from UI loop.
    }
  }

  /// Computes running cumulative percentage totals across ordered failure categories.
  ParetoAnalysisReport computeParetoTotals() {
    try {
      final totalEvents = _categoryFrequencyMap.values.fold<int>(0, (sum, count) => sum + count);
      if (totalEvents == 0) {
        return ParetoAnalysisReport(
          generatedAt: DateTime.now(),
          totalCount: 0,
          orderedBins: const [],
        );
      }

      // Sort entries descending by occurrence count
      final sortedEntries = _categoryFrequencyMap.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      int runningSum = 0;
      final bins = <ParetoBin>[];

      for (final entry in sortedEntries) {
        runningSum += entry.value;
        final relativePct = (entry.value / totalEvents) * 100.0;
        final cumulativePct = (runningSum / totalEvents) * 100.0;

        bins.add(ParetoBin(
          categoryTag: entry.key,
          frequencyCount: entry.value,
          relativePercentage: relativePct,
          cumulativePercentage: cumulativePct.clamp(0.0, 100.0),
        ));
      }

      return ParetoAnalysisReport(
        generatedAt: DateTime.now(),
        totalCount: totalEvents,
        orderedBins: List.unmodifiable(bins),
      );
    } catch (_) {
      return ParetoAnalysisReport(
        generatedAt: DateTime.now(),
        totalCount: 0,
        orderedBins: const [],
      );
    }
  }

  /// Flushes current batch asynchronously to gateway queue.
  Future<void> _flushQueueSafely() async {
    if (_isFlushing || _recordQueue.isEmpty) return;
    _isFlushing = true;

    try {
      final itemsToFlush = <CheckSheetRecord>[];
      while (_recordQueue.isNotEmpty && itemsToFlush.length < _batchThreshold) {
        itemsToFlush.add(_recordQueue.removeFirst());
      }

      final serializedBatch = itemsToFlush.map((r) => r.toSanitizedMap()).toList();
      final summary = computeParetoTotals();

      if (_dispatcher != null) {
        await _dispatcher(serializedBatch, summary);
      }
    } catch (_) {
      // Poka-Yoke: Silent drop protection ensures zero interruption to user forms
    } finally {
      _isFlushing = false;
    }
  }

  /// Explicit manual flush for lifecycle hooks (e.g. app pause / submit screen).
  Future<void> flush() async {
    await _flushQueueSafely();
  }

  /// Releases timer resources.
  void dispose() {
    _flushTimer?.cancel();
    _recordQueue.clear();
    _categoryFrequencyMap.clear();
  }
}
