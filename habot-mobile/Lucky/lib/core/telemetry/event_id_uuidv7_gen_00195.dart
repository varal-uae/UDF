// GEN-00195 — Define event_id as a UUIDv7 field.
// Implements RFC 9562/4122 compliant time-ordered UUIDv7 generation and validation.
// Provides an M3 telemetry console status card with background polling and drill-down inspection.

import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Core utility for generating and validating time-ordered UUIDv7 identifiers.
class UuidV7 {
  UuidV7._();

  static final Random _secureRandom = Random.secure();
  static final RegExp _uuidV7Regex = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-7[0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',
  );

  /// Generates a RFC 9562-compliant time-ordered UUIDv7.
  static String generate([DateTime? customTimestamp]) {
    final int timestampMs = (customTimestamp ?? DateTime.now()).millisecondsSinceEpoch;
    final Uint8List bytes = Uint8List(16);

    // 48-bit timestamp in milliseconds (Big Endian)
    bytes[0] = (timestampMs >> 40) & 0xFF;
    bytes[1] = (timestampMs >> 32) & 0xFF;
    bytes[2] = (timestampMs >> 24) & 0xFF;
    bytes[3] = (timestampMs >> 16) & 0xFF;
    bytes[4] = (timestampMs >> 8) & 0xFF;
    bytes[5] = timestampMs & 0xFF;

    // 10 random bytes for rand_a and rand_b
    final Uint8List randBytes = Uint8List(10);
    for (int i = 0; i < 10; i++) {
      randBytes[i] = _secureRandom.nextInt(256);
    }

    // Byte 6-7: 4-bit version (0x7) + 12-bit rand_a
    bytes[6] = 0x70 | (randBytes[0] & 0x0F);
    bytes[7] = randBytes[1];

    // Byte 8: 2-bit variant (0b10) + 6-bit rand_b
    bytes[8] = 0x80 | (randBytes[2] & 0x3F);

    // Byte 9-15: Remaining 7 bytes of rand_b
    for (int i = 0; i < 7; i++) {
      bytes[9 + i] = randBytes[3 + i];
    }

    return _formatUuid(bytes);
  }

  /// Validates whether the given string conforms strictly to UUIDv7 specifications.
  static bool isValid(String uuid) {
    return _uuidV7Regex.hasMatch(uuid.trim());
  }

  /// Extracts the creation timestamp from a UUIDv7 string.
  static DateTime? extractTimestamp(String uuid) {
    if (!isValid(uuid)) return null;
    final String cleanUuid = uuid.replaceAll('-', '');
    final String timestampHex = cleanUuid.substring(0, 12);
    final int? ms = int.tryParse(timestampHex, radix: 16);
    return ms != null ? DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true) : null;
  }

  static String _formatUuid(Uint8List bytes) {
    final StringBuffer sb = StringBuffer();
    for (int i = 0; i < 16; i++) {
      if (i == 4 || i == 6 || i == 8 || i == 10) {
        sb.write('-');
      }
      sb.write(bytes[i].toRadixString(16).padLeft(2, '0'));
    }
    return sb.toString();
  }
}

/// Telemetry record adhering to BigQuery streaming and collision requirements.
class TelemetryEventRecord {
  final String eventId;
  final DateTime timestamp;
  final String userId;
  final String completionStatus;
  final String traceId;

  TelemetryEventRecord({
    required this.eventId,
    required this.timestamp,
    required this.userId,
    required this.completionStatus,
    required this.traceId,
  });

  factory TelemetryEventRecord.create({
    required String userId,
    String completionStatus = 'Pass',
    String? traceId,
  }) {
    final String id = UuidV7.generate();
    return TelemetryEventRecord(
      eventId: id,
      timestamp: DateTime.now().toUtc(),
      userId: userId,
      completionStatus: completionStatus,
      traceId: traceId ?? 'trc_${Random().nextInt(999999).toString().padLeft(6, '0')}',
    );
  }

  bool get isUuidV7Valid => UuidV7.isValid(eventId);
}

/// M3 Elevated Card Level 2 for engineering console monitoring.
class EventIdTelemetryCard extends StatefulWidget {
  final String userId;
  final VoidCallback? onDrillDown;

  const EventIdTelemetryCard({
    super.key,
    this.userId = 'usr_sys_eng_01',
    this.onDrillDown,
  });

  @override
  State<EventIdTelemetryCard> createState() => _EventIdTelemetryCardState();
}

class _EventIdTelemetryCardState extends State<EventIdTelemetryCard> {
  late TelemetryEventRecord _currentRecord;
  Timer? _pollingTimer;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _generateNewRecord();
    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _generateNewRecord();
    });
  }

  void _generateNewRecord() {
    setState(() {
      _isSyncing = true;
    });
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) {
        setState(() {
          _currentRecord = TelemetryEventRecord.create(
            userId: widget.userId,
            completionStatus: 'Pass',
          );
          _isSyncing = false;
        });
      }
    });
  }

  void _showDrillDownDetails() {
    final DateTime? created = UuidV7.extractTimestamp(_currentRecord.eventId);
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (BuildContext ctx) {
        final ThemeData theme = Theme.of(ctx);
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children:
[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'UUIDv7 Telemetry Drill-down',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(ctx).pop(),
                    constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _detailRow('Event ID', _currentRecord.eventId, theme),
              _detailRow('Collision Bound', '<= 1 collision per 10^15 IDs', theme),
              _detailRow('Format Standard', 'IETF RFC 9562 / RFC 4122', theme),
              _detailRow('Extracted Timestamp', created?.toIso8601String() ?? 'N/A', theme),
              _detailRow('User / Session ID', _currentRecord.userId, theme),
              _detailRow('Trace ID', _currentRecord.traceId, theme),
              _detailRow('Status', _currentRecord.completionStatus, theme),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: _currentRecord.eventId));
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('UUIDv7 copied to clipboard.')),
                    );
                  },
                  icon: const Icon(Icons.copy, size: 20),
                  label: const Text('Copy Event ID'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(String title, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              title,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isPass = _currentRecord.isUuidV7Valid && _currentRecord.completionStatus == 'Pass';

    return Card(
      elevation: 3.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      color: theme.colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.fingerprint, color: theme.colorScheme.primary, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      'GEN-00195: UUIDv7 event_id',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Chip(
                  avatar: Icon(
                    isPass ? Icons.check_circle : Icons.error,
                    size: 16,
                    color: isPass ? Colors.green.shade800 : theme.colorScheme.error,
                  ),
                  label: Text(
                    isPass ? 'Pass' : 'Fail',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isPass ? Colors.green.shade900 : theme.colorScheme.error,
                    ),
                  ),
                  backgroundColor: isPass ? Colors.green.shade50 : theme.colorScheme.errorContainer,
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Active UUIDv7 identifier:',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
            ),
            const SizedBox(height: 4),
            SelectableText(
              _currentRecord.eventId,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontFamily: 'monospace',
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: _isSyncing ? null : _generateNewRecord,
                      icon: _isSyncing
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.sync, size: 18),
                      label: const Text('Sync Now'),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  height: 48,
                  width: 48,
                  child: IconButton.filledTonal(
                    onPressed: _showDrillDownDetails,
                    tooltip: 'Inspect Metric Details',
                    icon: const Icon(Icons.arrow_forward, size: 20),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
