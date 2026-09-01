import 'package:flutter/material.dart';

/// Data Model for Operational Transaction Records.
class OperationalTransaction {
  final String? transactionId; // Can be null in raw incoming feed
  final String serviceName;
  final DateTime timestamp;
  final double payloadSizeBytes;
  final String status;
  final int latencyMs;

  const OperationalTransaction({
    required this.transactionId,
    required this.serviceName,
    required this.timestamp,
    required this.payloadSizeBytes,
    required this.status,
    required this.latencyMs,
  });
}

/// RCGLA-043: Responsive High-Density Operational Data Table
class HighDensityOperationalDataTable extends StatefulWidget {
  const HighDensityOperationalDataTable({super.key});

  @override
  State<HighDensityOperationalDataTable> createState() =>
      _HighDensityOperationalDataTableState();
}

class _HighDensityOperationalDataTableState
    extends State<HighDensityOperationalDataTable> {
  // Raw incoming transaction records (includes bad/corrupted data with null/empty IDs)
  final List<OperationalTransaction> _rawTransactions = [
    OperationalTransaction(
      transactionId: 'TXN-90210',
      serviceName: 'AuthServer.OAuth2Ingestion',
      timestamp: DateTime.now().subtract(const Duration(seconds: 45)),
      payloadSizeBytes: 1024.5,
      status: 'SUCCESS',
      latencyMs: 12,
    ),
    OperationalTransaction(
      transactionId: '', // Poka-Yoke target: empty transaction ID (MUST BE DROPPED)
      serviceName: 'Corrupted.NullService',
      timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
      payloadSizeBytes: 0.0,
      status: 'MALFORMED',
      latencyMs: 0,
    ),
    OperationalTransaction(
      transactionId: 'TXN-90211',
      serviceName: 'PaymentGateway.StripeWebhookProcessor',
      timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
      payloadSizeBytes: 4096.0,
      status: 'SUCCESS',
      latencyMs: 84,
    ),
    OperationalTransaction(
      transactionId: null, // Poka-Yoke target: null transaction ID (MUST BE DROPPED)
      serviceName: 'Ghost.RecordConsumer',
      timestamp: DateTime.now(),
      payloadSizeBytes: 512.0,
      status: 'ORPHAN',
      latencyMs: 999,
    ),
    OperationalTransaction(
      transactionId: 'TXN-90212',
      serviceName: 'PubSubTelemetry.MetricsExporterService',
      timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
      payloadSizeBytes: 16384.2,
      status: 'SUCCESS',
      latencyMs: 45,
    ),
    OperationalTransaction(
      transactionId: 'TXN-90213',
      serviceName: 'DatabaseCluster.ReadReplicaSyncEngine',
      timestamp: DateTime.now().subtract(const Duration(minutes: 4)),
      payloadSizeBytes: 8192.0,
      status: 'DEGRADED',
      latencyMs: 310,
    ),
    OperationalTransaction(
      transactionId: 'TXN-90214',
      serviceName: 'KmsSecurityKey.RotationAttestationLog',
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      payloadSizeBytes: 2048.0,
      status: 'SUCCESS',
      latencyMs: 18,
    ),
  ];

  late List<OperationalTransaction> _cleanTransactions;
  int _sortColumnIndex = 0;
  bool _sortAscending = true;
  int _droppedRecordsCount = 0;

  @override
  void initState() {
    super.initState();
    _sanitizeAndFilterRecords();
  }

  /// Poka-Yoke (Bad Data Dropping):
  /// Programmatically drops records where transactionId is null or empty before rendering.
  void _sanitizeAndFilterRecords() {
    final originalCount = _rawTransactions.length;
    _cleanTransactions = _rawTransactions.where((record) {
      return record.transactionId != null && record.transactionId!.trim().isNotEmpty;
    }).toList();

    _droppedRecordsCount = originalCount - _cleanTransactions.length;
  }

  /// Interactive Header Sorting:
  /// Note: The actual heavy sorting logic on large operational tables should run on an
  /// Isolate (using Flutter's compute() function) to preserve scrolling fluidity on local background processing threads.
  void _sortData(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;

      _cleanTransactions.sort((a, b) {
        int result;
        switch (columnIndex) {
          case 0: // Transaction ID
            result = (a.transactionId ?? '').compareTo(b.transactionId ?? '');
            break;
          case 1: // Service Name
            result = a.serviceName.compareTo(b.serviceName);
            break;
          case 2: // Timestamp
            result = a.timestamp.compareTo(b.timestamp);
            break;
          case 3: // Payload Size
            result = a.payloadSizeBytes.compareTo(b.payloadSizeBytes);
            break;
          case 4: // Status
            result = a.status.compareTo(b.status);
            break;
          case 5: // Latency
            result = a.latencyMs.compareTo(b.latencyMs);
            break;
          default:
            result = 0;
        }
        return ascending ? result : -result;
      });
    });
  }

  /// Creates a cell wrapper enforcing explicit padding and text truncation.
  DataCell _buildTruncatedCell(String content, {TextStyle? style}) {
    return DataCell(
      Padding(
        padding: const EdgeInsets.only(top: 6, bottom: 6, left: 8),
        child: Text(
          content,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: style,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('High-Density Operational Data Table'),
        elevation: 2,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth <= 600;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Poka-Yoke Data Dropping Banner
                Card(
                  elevation: 1,
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.verified,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Poka-Yoke Bad Data Filter Active',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Dropped $_droppedRecordsCount malformed/null transactionId records before mapping rows to UI.',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${_cleanTransactions.length} Valid Records',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Responsive Layout Mode Indicator
                Text(
                  isMobile
                      ? 'Mobile View (maxWidth <= 600): Column Minification Active (Showing 3 Critical Columns)'
                      : 'Web/Tablet View (maxWidth > 600): Full High-Density Column Set Active (Showing All Columns)',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),

                // High-Density DataTable Card Container
                Card(
                  elevation: 2,
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: theme.colorScheme.outlineVariant),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        sortColumnIndex: _sortColumnIndex,
                        sortAscending: _sortAscending,
                        dataRowMinHeight: 48.0, // Enforce 48dp minimum height
                        dataRowMaxHeight: 48.0, // Enforce strict row constraint
                        headingRowHeight: 52.0,
                        columnSpacing: isMobile ? 16.0 : 28.0,
                        columns: isMobile
                            ? [
                                // Mobile: First 3 most critical columns
                                DataColumn(
                                  label: const Text('TXN ID', style: TextStyle(fontWeight: FontWeight.bold)),
                                  onSort: (index, ascending) => _sortData(index, ascending),
                                ),
                                DataColumn(
                                  label: const Text('Status', style: TextStyle(fontWeight: FontWeight.bold)),
                                  onSort: (index, ascending) => _sortData(4, ascending),
                                ),
                                DataColumn(
                                  label: const Text('Latency', style: TextStyle(fontWeight: FontWeight.bold)),
                                  numeric: true,
                                  onSort: (index, ascending) => _sortData(5, ascending),
                                ),
                              ]
                            : [
                                // Web/Tablet: Entire Column Set
                                DataColumn(
                                  label: const Text('Transaction ID', style: TextStyle(fontWeight: FontWeight.bold)),
                                  onSort: (index, ascending) => _sortData(0, ascending),
                                ),
                                DataColumn(
                                  label: const Text('Service Name', style: TextStyle(fontWeight: FontWeight.bold)),
                                  onSort: (index, ascending) => _sortData(1, ascending),
                                ),
                                DataColumn(
                                  label: const Text('Timestamp', style: TextStyle(fontWeight: FontWeight.bold)),
                                  onSort: (index, ascending) => _sortData(2, ascending),
                                ),
                                DataColumn(
                                  label: const Text('Payload Size', style: TextStyle(fontWeight: FontWeight.bold)),
                                  numeric: true,
                                  onSort: (index, ascending) => _sortData(3, ascending),
                                ),
                                DataColumn(
                                  label: const Text('Status', style: TextStyle(fontWeight: FontWeight.bold)),
                                  onSort: (index, ascending) => _sortData(4, ascending),
                                ),
                                DataColumn(
                                  label: const Text('Latency (ms)', style: TextStyle(fontWeight: FontWeight.bold)),
                                  numeric: true,
                                  onSort: (index, ascending) => _sortData(5, ascending),
                                ),
                              ],
                        rows: _cleanTransactions.map((txn) {
                          final isSuccess = txn.status == 'SUCCESS';

                          if (isMobile) {
                            return DataRow(
                              cells: [
                                _buildTruncatedCell(
                                  txn.transactionId!,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                DataCell(
                                  Padding(
                                    padding: const EdgeInsets.only(top: 6, bottom: 6, left: 8),
                                    child: Chip(
                                      label: Text(
                                        txn.status,
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: isSuccess ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onErrorContainer,
                                        ),
                                      ),
                                      backgroundColor: isSuccess
                                          ? theme.colorScheme.primaryContainer
                                          : theme.colorScheme.errorContainer,
                                      visualDensity: VisualDensity.compact,
                                    ),
                                  ),
                                ),
                                _buildTruncatedCell('${txn.latencyMs}ms'),
                              ],
                            );
                          } else {
                            return DataRow(
                              cells: [
                                _buildTruncatedCell(
                                  txn.transactionId!,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                _buildTruncatedCell(txn.serviceName),
                                _buildTruncatedCell(
                                  txn.timestamp.toIso8601String().substring(11, 19),
                                ),
                                _buildTruncatedCell(
                                  '${(txn.payloadSizeBytes / 1024).toStringAsFixed(1)} KB',
                                ),
                                DataCell(
                                  Padding(
                                    padding: const EdgeInsets.only(top: 6, bottom: 6, left: 8),
                                    child: Chip(
                                      label: Text(
                                        txn.status,
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: isSuccess ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onErrorContainer,
                                        ),
                                      ),
                                      backgroundColor: isSuccess
                                          ? theme.colorScheme.primaryContainer
                                          : theme.colorScheme.errorContainer,
                                      visualDensity: VisualDensity.compact,
                                    ),
                                  ),
                                ),
                                _buildTruncatedCell('${txn.latencyMs} ms'),
                              ],
                            );
                          }
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
