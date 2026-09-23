// OFBSE-003-A06 — Client-Side Timestamp Synchronization (Mobile UTC).
// Stores the server-client time delta, validates timestamps against future drift,
// and provides ISO8601 formatting for accurate history tracking arrays.

import 'package:flutter/material.dart';

/// Brand success color token confirmed per requirement.
const Color kSuccessColorToken = Color(0xFF2ECC71);

/// Represents the lock state associated with a synchronized event.
class LockRecord {
  final String lockType;
  final String lockStatus;
  final String lockedBy;
  final DateTime lockTimestamp;
  final String lockReason;
  final String completionStatus;
  final String sessionId;

  const LockRecord({
    required this.lockType,
    required this.lockStatus,
    required this.lockedBy,
    required this.lockTimestamp,
    required this.lockReason,
    required this.completionStatus,
    required this.sessionId,
  });

  Map<String, dynamic> toJson() => {
        'lockType': lockType,
        'lockStatus': lockStatus,
        'lockedBy': lockedBy,
        'lockTimestamp': lockTimestamp.toIso8601String(),
        'lockReason': lockReason,
        'completionStatus': completionStatus,
        'sessionId': sessionId,
      };
}

/// Core utility maintaining the server-client time delta.
/// Discards messages containing timestamps that exist in the future (Poka-Yoke).
class TimeSyncService {
  TimeSyncService._();
  static final TimeSyncService instance = TimeSyncService._();

  Duration _serverClientDelta = Duration.zero;
  bool _isSynchronized = false;

  bool get isSynchronized => _isSynchronized;
  Duration get delta => _serverClientDelta;

  /// Simulates fetching server UTC and calculating delta against device clock.
  Future<void> synchronizeWithServer() async {
    // Mock: In production, this would call Cloud Run server time loops.
    await Future.delayed(const Duration(milliseconds: 300));
    final DateTime mockServerUtc = DateTime.now().toUtc();
    final DateTime deviceUtc = DateTime.now().toUtc();
    _serverClientDelta = mockServerUtc.difference(deviceUtc);
    _isSynchronized = true;
  }

  /// Returns the current synchronized UTC time.
  DateTime getSynchronizedUtcNow() {
    if (!_isSynchronized) {
      throw StateError('Time synchronization not completed. Isolate execution paths until sync completes.');
    }
    return DateTime.now().toUtc().add(_serverClientDelta);
  }

  /// Poka-Yoke: Validates that a timestamp is not in the future relative to synchronized time.
  bool isTimestampValid(DateTime timestamp) {
    if (!_isSynchronized) return false;
    final DateTime syncNow = getSynchronizedUtcNow();
    // Discard messages containing timestamps that exist in the future.
    return !timestamp.toUtc().isAfter(syncNow);
  }

  /// Formats to ISO8601 for BigQuery compilation.
  String formatIso8601(DateTime timestamp) {
    return timestamp.toUtc().toIso8601String();
  }
}

/// Mock data repository providing realistic local data for UDF history tracking.
class MockTimeSyncRepository {
  static List<LockRecord> fetchMockHistoryRecords() {
    final TimeSyncService syncService = TimeSyncService.instance;
    final DateTime baseTime = syncService.isSynchronized
        ? syncService.getSynchronizedUtcNow()
        : DateTime.now().toUtc();

    return [
      LockRecord(
        lockType: 'EDIT_LOCK',
        lockStatus: 'ACTIVE',
        lockedBy: 'user_admin_01',
        lockTimestamp: baseTime.subtract(const Duration(hours: 2)),
        lockReason: 'Corporate account update',
        completionStatus: 'Complete',
        sessionId: 'sess_8839201',
      ),
      LockRecord(
        lockType: 'VIEW_LOCK',
        lockStatus: 'RELEASED',
        lockedBy: 'user_analyst_04',
        lockTimestamp: baseTime.subtract(const Duration(hours: 5)),
        lockReason: 'Audit trail verification',
        completionStatus: 'Complete',
        sessionId: 'sess_1120394',
      ),
    ];
  }
}

/// Visual graph widget scaling to varying device dimensions (Mobile-First UX).
/// Transforms deep trace metrics into visual representations.
class TimeDriftVisualGraph extends StatelessWidget {
  final double driftMilliseconds;

  const TimeDriftVisualGraph({super.key, required this.driftMilliseconds});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double barWidth = constraints.maxWidth * 0.8;
        final double fillRatio = (driftMilliseconds.abs() / 1000).clamp(0.0, 1.0);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Time Drift Metric',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: barWidth,
                height: 12,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: fillRatio,
                    child: Container(
                      decoration: BoxDecoration(
                        color: kSuccessColorToken,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${driftMilliseconds.toStringAsFixed(2)} ms variance',
                style: textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Data table widget ensuring smooth horizontal sliding motions on mobile screens.
/// Uses uniform type weighting schemes and comfortable tap zones for tablets.
class SynchronizedHistoryDataTable extends StatelessWidget {
  final List<LockRecord> records;

  const SynchronizedHistoryDataTable({super.key, required this.records});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: DataTable(
        headingTextStyle: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: theme.colorScheme.primary,
        ),
        dataTextStyle: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w400,
        ),
        // Comfortable sizing metrics to ease configuration tracking on tablets.
        dataRowMinHeight: 56.0,
        dataRowMaxHeight: 72.0,
        headingRowHeight: 56.0,
        horizontalMargin: 24.0,
        columnSpacing: 32.0,
        columns: const [
          DataColumn(label: Text('Lock Type')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Locked By')),
          DataColumn(label: Text('Timestamp (UTC)')),
          DataColumn(label: Text('Reason')),
          DataColumn(label: Text('Completion')),
        ],
        rows: records.map((LockRecord record) {
          return DataRow(
            cells: [
              DataCell(Text(record.lockType)),
              DataCell(Text(record.lockStatus)),
              DataCell(Text(record.lockedBy)),
              DataCell(Text(TimeSyncService.instance.formatIso8601(record.lockTimestamp))),
              DataCell(Text(record.lockReason)),
              DataCell(
                Row(
                  children: [
                    Icon(
                      record.completionStatus == 'Complete' ? Icons.check_circle : Icons.pending,
                      size: 16,
                      color: record.completionStatus == 'Complete' ? kSuccessColorToken : theme.colorScheme.error,
                    ),
                    const SizedBox(width: 8),
                    Text(record.completionStatus),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

/// Screen implementation combining time sync logic, visual graphs, and data tables.
class TimeSyncProtocolScreen extends StatefulWidget {
  const TimeSyncProtocolScreen({super.key});

  @override
  State<TimeSyncProtocolScreen> createState() => _TimeSyncProtocolScreenState();
}

class _TimeSyncProtocolScreenState extends State<TimeSyncProtocolScreen> {
  bool _isLoading = true;
  List<LockRecord> _records = [];
  double _driftMs = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeTimeProtocol();
  }

  Future<void> _initializeTimeProtocol() async {
    setState(() => _isLoading = true);

    final TimeSyncService syncService = TimeSyncService.instance;
    await syncService.synchronizeWithServer();

    // Calculate mock drift metric for visualization.
    _driftMs = syncService.delta.inMilliseconds.toDouble();

    // Filter out invalid future timestamps (Poka-Yoke).
    final List<LockRecord> rawRecords = MockTimeSyncRepository.fetchMockHistoryRecords();
    _records = rawRecords.where((LockRecord r) => syncService.isTimestampValid(r.lockTimestamp)).toList();

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Time Protocol'),
        centerTitle: false,
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    'Synchronized Execution Loops',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TimeDriftVisualGraph(driftMilliseconds: _driftMs),
                const Divider(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    'Event History Tracking Arrays',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SynchronizedHistoryDataTable(records: _records),
                ),
              ],
            ),
    );
  }
}
