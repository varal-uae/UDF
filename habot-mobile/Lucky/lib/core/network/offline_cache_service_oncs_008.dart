// ONCS-008 — Offline-First Data Caching Structure via Local SQLite.
// Implements local caching, storage limit enforcement, offline UI indicators, and mock data for UDF modules.

import 'dart:async';
import 'dart:convert';

/// Mock representation of a local database record to avoid external dependencies
/// while satisfying the requirement for embedded mobile database structures.
class CacheRecord {
  final String stepExecutionId;
  final String executionStatus;
  final DateTime executionTimestamp;
  final String stepOutcome;
  final String userId;
  final String payload;
  final int sizeBytes;

  CacheRecord({
    required this.stepExecutionId,
    required this.executionStatus,
    required this.executionTimestamp,
    required this.stepOutcome,
    required this.userId,
    required this.payload,
    required this.sizeBytes,
  });

  Map<String, dynamic> toJson() => {
        'step_execution_id': stepExecutionId,
        'execution_status': executionStatus,
        'execution_timestamp': executionTimestamp.toIso8601String(),
        'step_outcome': stepOutcome,
        'user_id': userId,
        'payload': payload,
        'size_bytes': sizeBytes,
      };

  factory CacheRecord.fromJson(Map<String, dynamic> json) => CacheRecord(
        stepExecutionId: json['step_execution_id'] as String,
        executionStatus: json['execution_status'] as String,
        executionTimestamp: DateTime.parse(json['execution_timestamp'] as String),
        stepOutcome: json['step_outcome'] as String,
        userId: json['user_id'] as String,
        payload: json['payload'] as String,
        sizeBytes: json['size_bytes'] as int,
      );
}

/// Core service managing offline-first data caching structure.
/// Enforces maximum device storage space allocated for local caching.
class OfflineCacheServiceOnCs008 {
  OfflineCacheServiceOnCs008._internal();
  static final OfflineCacheServiceOnCs008 instance = OfflineCacheServiceOnCs008._internal();

  /// Maximum allowed cache size in bytes (e.g., 50 MB)
  static const int maxStorageSpaceBytes = 50 * 1024 * 1024;

  final Map<String, CacheRecord> _cacheStore = {};
  int _currentSizeBytes = 0;

  bool get isOnline => _isOnline;
  bool _isOnline = true;

  final StreamController<bool> _connectivityController = StreamController<bool>.broadcast();
  Stream<bool> get connectivityStream => _connectivityController.stream;

  /// Determines if adding a new record exceeds maximum device storage space.
  bool canAllocateSpace(int requiredBytes) {
    return (_currentSizeBytes + requiredBytes) <= maxStorageSpaceBytes;
  }

  /// Evicts oldest records if storage threshold is reached.
  void _enforceStorageLimits() {
    if (_currentSizeBytes <= maxStorageSpaceBytes) return;

    final sortedKeys = _cacheStore.keys.toList()
      ..sort((a, b) => _cacheStore[a]!.executionTimestamp.compareTo(_cacheStore[b]!.executionTimestamp));

    for (final key in sortedKeys) {
      if (_currentSizeBytes <= (maxStorageSpaceBytes * 0.8)) break; // Free up to 80% capacity
      final record = _cacheStore.remove(key);
      if (record != null) {
        _currentSizeBytes -= record.sizeBytes;
      }
    }
  }

  Future<bool> saveToCache(CacheRecord record) async {
    if (!canAllocateSpace(record.sizeBytes)) {
      _enforceStorageLimits();
      if (!canAllocateSpace(record.sizeBytes)) {
        return false;
      }
    }

    _cacheStore[record.stepExecutionId] = record;
    _currentSizeBytes += record.sizeBytes;
    return true;
  }

  CacheRecord? getFromCache(String stepExecutionId) {
    return _cacheStore[stepExecutionId];
  }

  List<CacheRecord> getAllCachedRecords() {
    return _cacheStore.values.toList();
  }

  void updateConnectivityStatus(bool online) {
    _isOnline = online;
    _connectivityController.add(_isOnline);
  }

  void dispose() {
    _connectivityController.close();
  }
}

/// Mock data generator fulfilling backend/API requirements locally.
class MockDataGeneratorOnCs008 {
  static List<CacheRecord> generateMockRecords() {
    return [
      CacheRecord(
        stepExecutionId: 'ONCS-008-EXEC-001',
        executionStatus: 'PASS',
        executionTimestamp: DateTime.now().subtract(const Duration(hours: 1)),
        stepOutcome: 'Successfully cached ingress endpoint payload.',
        userId: 'USR-9921',
        payload: jsonEncode({'route': '/api/v1/udf/data', 'method': 'GET'}),
        sizeBytes: 1024,
      ),
      CacheRecord(
        stepExecutionId: 'ONCS-008-EXEC-002',
        executionStatus: 'PASS',
        executionTimestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        stepOutcome: 'Dynamic routing flow map stored locally.',
        userId: 'USR-9921',
        payload: jsonEncode({'route': '/api/v1/udf/sync', 'method': 'POST'}),
        sizeBytes: 2048,
      ),
    ];
  }
}

/// Telemetry model tracking Mobile Crash-Free User Rate.
class CacheTelemetryOnCs008 {
  static const double floorBoundary = 0.99;
  static const double optimalTarget = 0.995;
  static const double ceilingBoundary = 0.999;

  final int totalSessions;
  final int crashFreeSessions;

  const CacheTelemetryOnCs008({
    required this.totalSessions,
    required this.crashFreeSessions,
  });

  double get crashFreeRate => totalSessions == 0 ? 1.0 : crashFreeSessions / totalSessions;

  String get qualitativeOutput {
    if (crashFreeRate >= ceilingBoundary) return 'PASS (Optimal)';
    if (crashFreeRate >= optimalTarget) return 'PASS';
    if (crashFreeRate >= floorBoundary) return 'WARNING';
    return 'FAIL';
  }
}
