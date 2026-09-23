// OFBSE-003-A14 — Client-Side Timestamp Synchronization (Mobile UTC).
// Provides a universal clock utility that synchronizes device time with server UTC time, detects future timestamps, and formats records using ISO8601 for BigQuery alignment.

import 'package:flutter/material.dart';

/// Mock data representing the atomic-level data fields required by OFBSE-003-A14.
class TimeSyncMockData {
  static const Map<String, dynamic> lockRecord = {
    'lock_type': 'session_lock',
    'lock_status': 'active',
    'locked_by': 'user_session_88291',
    'lock_timestamp': '2026-09-23T12:00:00.000Z',
    'lock_reason': 'prevent_concurrent_edits',
    'completion_status': 'Pass',
    'action_event_timestamp': '2026-09-23T12:00:05.000Z',
    'user_session_id': 'sess_abc123xyz',
  };
}

/// Core utility for maintaining synchronized execution loops and time-drift correction.
class TimeSyncUtils {
  TimeSyncUtils._();

  static DateTime? _serverTimeOffset;

  /// Simulates fetching server time and calculating the delta against device clock.
  /// In production, this would call a Cloud Run endpoint.
  static Future<void> synchronizeWithServer() async {
    // Mock server time response
    final DateTime mockServerUtc = DateTime.utc(2026, 9, 23, 14, 30, 0);
    final DateTime deviceNow = DateTime.now().toUtc();
    _serverTimeOffset = mockServerUtc.difference(deviceNow);
  }

  /// Returns the corrected UTC timestamp based on server synchronization.
  static DateTime getCorrectedUtcNow() {
    final DateTime deviceNow = DateTime.now().toUtc();
    if (_serverTimeOffset != null) {
      return deviceNow.add(_serverTimeOffset!);
    }
    return deviceNow;
  }

  /// Poka-Yoke: Discards messages containing timestamps that exist in the future.
  static bool isTimestampValid(DateTime eventTime) {
    final DateTime correctedNow = getCorrectedUtcNow();
    return !eventTime.isAfter(correctedNow);
  }

  /// Formats the timestamp to ISO8601 for BigQuery ingestion.
  static String formatToIso8601(DateTime time) {
    return time.toIso8601String();
  }
}

/// UI Widget demonstrating relative time visual layouts and strict contrast attributes.
class TimeSyncStatusIndicator extends StatelessWidget {
  const TimeSyncStatusIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final DateTime correctedTime = TimeSyncUtils.getCorrectedUtcNow();
    final bool isValid = TimeSyncUtils.isTimestampValid(correctedTime);

    return Card(
      elevation: 2,
      color: theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Time Protocol Status',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Tooltip(
                  message: 'Interactive tooltip block explaining security rule changes and time-drift isolation.',
                  child: Icon(
                    Icons.info_outline,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Synchronized UTC: ${TimeSyncUtils.formatToIso8601(correctedTime)}',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isValid ? theme.colorScheme.primaryContainer : theme.colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                isValid ? 'PASS' : 'FAIL - FUTURE TIMESTAMP DETECTED',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: isValid ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onErrorContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Lock Type: ${TimeSyncMockData.lockRecord['lock_type']}',
              style: theme.textTheme.bodyMedium,
            ),
            Text(
              'Lock Status: ${TimeSyncMockData.lockRecord['lock_status']}',
              style: theme.textTheme.bodyMedium,
            ),
            Text(
              'Locked By: ${TimeSyncMockData.lockRecord['locked_by']}',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}