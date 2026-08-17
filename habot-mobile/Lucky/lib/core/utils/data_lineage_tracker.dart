// BLGTA-054-12 — Hidden Data Lineage and Metadata Tracking.
// Isolates tracking data completely from the UI layer to maintain visual layout integrity.
// Schedulers run metadata collation asynchronously outside the primary UI refresh pipeline.

import 'dart:async';

/// Manages hidden metadata tracking and updates upload envelopes asynchronously.
class DataLineageTracker {
  DataLineageTracker._();

  /// Singleton access
  static final DataLineageTracker instance = DataLineageTracker._();

  // Internal memory footprint kept nominal (just stores tracking ID maps)
  final Map<String, String> _hiddenTrackingMap = {};

  /// Associates an asset/envelope ID with an incoming identification string.
  /// Runs asynchronously to avoid blocking the main build/layout cycle.
  void registerTrackingId(String targetKey, String sourceId) {
    scheduleMicrotask(() {
      _hiddenTrackingMap[targetKey] = sourceId;
    });
  }

  /// Copies tracking strings directly into final upload envelopes.
  /// Runs inside a Future to execute outside primary interface refreshes.
  Future<Map<String, dynamic>> sealEnvelope({
    required String targetKey,
    required Map<String, dynamic> uploadPayload,
  }) async {
    return Future(() {
      final finalEnvelope = Map<String, dynamic>.from(uploadPayload);
      
      // Inject lineage metadata silently
      finalEnvelope['predecessor_id'] = _hiddenTrackingMap[targetKey];
      finalEnvelope['data_lineage_metadata'] = {
        'tracking_index': _hiddenTrackingMap[targetKey]?.hashCode.toString(),
        'sealed_at': DateTime.now().toUtc().toIso8601String(),
        'lineage_isolated': true,
      };

      return finalEnvelope;
    });
  }

  /// Removes tracking mapping once upload is complete, freeing memory.
  void clearTracking(String targetKey) {
    scheduleMicrotask(() {
      _hiddenTrackingMap.remove(targetKey);
    });
  }
}
