import 'dart:async';
import 'dart:developer' as developer;
import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Exception thrown when mandatory non-nullable schema fields are missing.
class SchemaValidationException implements Exception {
  final String message;
  final String missingField;

  SchemaValidationException(this.message, {required this.missingField});

  @override
  String toString() =>
      'SchemaValidationException: $message (Missing Field: $missingField)';
}

/// BigQuery Streaming Event Schema Model
class BigQueryStreamingEvent {
  final String eventName;
  final DateTime timestamp;
  final String serviceHash;
  final int latencyMetricMs;
  final String? errorCode;

  const BigQueryStreamingEvent({
    required this.eventName,
    required this.timestamp,
    required this.serviceHash,
    required this.latencyMetricMs,
    this.errorCode,
  });

  /// 100% Strict Schema Validation (Poka-Yoke) Factory
  /// If ANY of the non-nullable fields are missing, throws [SchemaValidationException].
  factory BigQueryStreamingEvent.fromJson(Map<String, dynamic> json) {
    if (json['eventName'] == null ||
        (json['eventName'] as String).trim().isEmpty) {
      throw SchemaValidationException(
        'Payload missing mandatory field [eventName]',
        missingField: 'eventName',
      );
    }
    if (json['timestamp'] == null) {
      throw SchemaValidationException(
        'Payload missing mandatory field [timestamp]',
        missingField: 'timestamp',
      );
    }
    if (json['serviceHash'] == null ||
        (json['serviceHash'] as String).trim().isEmpty) {
      throw SchemaValidationException(
        'Payload missing mandatory field [serviceHash]',
        missingField: 'serviceHash',
      );
    }
    if (json['latencyMetricMs'] == null) {
      throw SchemaValidationException(
        'Payload missing mandatory field [latencyMetricMs]',
        missingField: 'latencyMetricMs',
      );
    }

    final parsedTime =
        DateTime.tryParse(json['timestamp'].toString()) ?? DateTime.now();
    final latency = int.tryParse(json['latencyMetricMs'].toString()) ?? 0;

    return BigQueryStreamingEvent(
      eventName: json['eventName'] as String,
      timestamp: parsedTime,
      serviceHash: json['serviceHash'] as String,
      latencyMetricMs: latency,
      errorCode: json['errorCode'] as String?,
    );
  }
}

/// Responsive 'Streaming Pipeline & Schema Validation' Monitoring Dashboard
/// Ref ID: BQSV-001
class BigQueryStreamingValidationDashboard extends StatefulWidget {
  const BigQueryStreamingValidationDashboard({super.key});

  @override
  State<BigQueryStreamingValidationDashboard> createState() =>
      _BigQueryStreamingValidationDashboardState();
}

class _BigQueryStreamingValidationDashboardState
    extends State<BigQueryStreamingValidationDashboard> {
  late final StreamController<List<BigQueryStreamingEvent>> _streamController;
  Timer? _ingestionTimer;

  final List<BigQueryStreamingEvent> _validEventsBuffer = [];
  bool _isPipelineHealthy = true; // Health Status: PASS (true) / FAIL (false)
  String? _lastValidationErrorMessage;
  int _failedValidationCount = 0;
  bool _simulateCorruptPayload = false;

  @override
  void initState() {
    super.initState();
    _streamController =
        StreamController<List<BigQueryStreamingEvent>>.broadcast();
    _seedInitialValidData();
    _startMockStreamIngestion();
  }

  void _seedInitialValidData() {
    final now = DateTime.now();
    final initialPayloads = [
      {
        'eventName': 'user_signup_completed',
        'timestamp': now.subtract(const Duration(minutes: 10)).toIso8601String(),
        'serviceHash': 'srv-auth-8849a',
        'latencyMetricMs': 142,
        'errorCode': null,
      },
      {
        'eventName': 'checkout_payment_processed',
        'timestamp': now.subtract(const Duration(minutes: 8)).toIso8601String(),
        'serviceHash': 'srv-billing-2041b',
        'latencyMetricMs': 285,
        'errorCode': null,
      },
      {
        'eventName': 'token_refresh_attempt',
        'timestamp': now.subtract(const Duration(minutes: 5)).toIso8601String(),
        'serviceHash': 'srv-auth-8849a',
        'latencyMetricMs': 94,
        'errorCode': null,
      },
      {
        'eventName': 'warehouse_sync_failed',
        'timestamp': now.subtract(const Duration(minutes: 2)).toIso8601String(),
        'serviceHash': 'srv-data-9912c',
        'latencyMetricMs': 840,
        'errorCode': 'ERR_TIMEOUT_504',
      },
    ];

    for (final json in initialPayloads) {
      _ingestPayload(json);
    }
  }

  void _startMockStreamIngestion() {
    _ingestionTimer?.cancel();
    _ingestionTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      final now = DateTime.now();
      final isCorrupt = _simulateCorruptPayload && (timer.tick % 2 == 0);

      final mockJson = <String, dynamic>{
        // Poka-Yoke Test: Null eventName or missing serviceHash triggers FAIL
        'eventName': isCorrupt ? null : 'stream_metric_event_${timer.tick}',
        'timestamp': now.toIso8601String(),
        'serviceHash': isCorrupt ? '' : 'srv-node-${100 + timer.tick}',
        'latencyMetricMs': 50 + math.Random().nextInt(400),
        'errorCode': (timer.tick % 5 == 0) ? 'ERR_BUFFER_OVERFLOW' : null,
      };

      _ingestPayload(mockJson);
    });
  }

  /// 100% Poka-Yoke Ingestion Pipeline
  void _ingestPayload(Map<String, dynamic> payload) {
    try {
      final event = BigQueryStreamingEvent.fromJson(payload);
      _validEventsBuffer.insert(0, event);
      if (_validEventsBuffer.length > 25) {
        _validEventsBuffer.removeLast();
      }
      _streamController.add(List.from(_validEventsBuffer));
    } on SchemaValidationException catch (e) {
      developer.log(
        'Schema Validation Failed: ${e.message}',
        name: 'StreamingPipeline',
        level: 1000,
        error: e,
      );

      setState(() {
        _isPipelineHealthy = false; // Immediately set health status to FAIL
        _failedValidationCount++;
        _lastValidationErrorMessage = e.toString();
      });

      _streamController.add(List.from(_validEventsBuffer));
    } catch (e) {
      setState(() {
        _isPipelineHealthy = false;
        _failedValidationCount++;
        _lastValidationErrorMessage = 'Unexpected parsing failure: $e';
      });
    }
  }

  void _resetPipelineHealth() {
    setState(() {
      _isPipelineHealthy = true;
      _failedValidationCount = 0;
      _lastValidationErrorMessage = null;
      _simulateCorruptPayload = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pipeline health status reset to PASS.'),
      ),
    );
  }

  @override
  void dispose() {
    _ingestionTimer?.cancel();
    _streamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('BigQuery Streaming Schema Validation'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              _simulateCorruptPayload
                  ? Icons.warning_amber_rounded
                  : Icons.shield_outlined,
              color: _simulateCorruptPayload ? theme.colorScheme.error : null,
            ),
            tooltip: 'Toggle Corrupt Schema Simulation (Missing Fields)',
            onPressed: () {
              setState(() {
                _simulateCorruptPayload = !_simulateCorruptPayload;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _simulateCorruptPayload
                        ? 'Simulating corrupt payloads (Triggers FAIL status).'
                        : 'Simulating valid BigQuery streaming schema.',
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Health Status Banner (Dataset and Table Creation Rate)
              _buildHealthStatusBanner(theme),
              const SizedBox(height: 20.0),

              // Real-Time Events Stream Section
              StreamBuilder<List<BigQueryStreamingEvent>>(
                stream: _streamController.stream,
                initialData: _validEventsBuffer,
                builder: (context, snapshot) {
                  final events = snapshot.data ?? [];

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final isDesktopWebTablet = constraints.maxWidth > 600;

                      if (isDesktopWebTablet) {
                        return _buildDataTableLayout(theme, events);
                      } else {
                        return _buildMobileCardListViewLayout(theme, events);
                      }
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Persistent Health Status Banner utilizing M3 Semantic Colors
  Widget _buildHealthStatusBanner(ThemeData theme) {
    final isPass = _isPipelineHealthy;
    final bannerBg = isPass
        ? theme.colorScheme.primaryContainer
        : theme.colorScheme.errorContainer;
    final textColor = isPass
        ? theme.colorScheme.onPrimaryContainer
        : theme.colorScheme.onErrorContainer;
    final iconData = isPass ? Icons.check_circle : Icons.gpp_bad;

    return Card(
      elevation: 2,
      color: bannerBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: BorderSide(
          color: isPass ? theme.colorScheme.primary : theme.colorScheme.error,
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Icon(iconData, size: 32.0, color: textColor),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dataset and Table Creation Rate Compliance',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: textColor.withValues(alpha: 0.8),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2.0),
                      Row(
                        children: [
                          Text(
                            'Pipeline Health: ',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: textColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10.0,
                              vertical: 4.0,
                            ),
                            decoration: BoxDecoration(
                              color: isPass
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.error,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Text(
                              isPass ? 'PASS' : 'FAIL',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (!isPass)
                  ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 48.0),
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: textColor,
                        side: BorderSide(color: textColor),
                      ),
                      onPressed: _resetPipelineHealth,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reset Status'),
                    ),
                  ),
              ],
            ),
            if (!isPass && _lastValidationErrorMessage != null) ...[
              const Divider(height: 20.0),
              Row(
                children: [
                  Icon(Icons.warning_amber_rounded,
                      size: 18.0, color: textColor),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Text(
                      'Validation Failure: $_lastValidationErrorMessage (Total Rejections: $_failedValidationCount)',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Web/Tablet View Layout (maxWidth > 600): Native DataTable displaying all 5 schema fields
  Widget _buildDataTableLayout(
      ThemeData theme, List<BigQueryStreamingEvent> events) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 750.0),
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(
                theme.colorScheme.surfaceContainerHigh,
              ),
              dataRowMinHeight: 52.0,
              columns: const [
                DataColumn(
                  label: Text('Event Name',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                DataColumn(
                  label: Text('Timestamp',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                DataColumn(
                  label: Text('Service Hash',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                DataColumn(
                  label: Text('Latency (ms)',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                DataColumn(
                  label: Text('Error Code',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
              rows: events.map((event) {
                final hasError = event.errorCode != null;

                return DataRow(
                  cells: [
                    DataCell(
                      Row(
                        children: [
                          Icon(
                            hasError
                                ? Icons.error_outline
                                : Icons.check_circle_outline,
                            size: 18.0,
                            color: hasError
                                ? theme.colorScheme.error
                                : theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8.0),
                          Text(
                            event.eventName,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    DataCell(
                      Text(
                        _formatTimestamp(event.timestamp),
                        style: const TextStyle(fontFamily: 'monospace'),
                      ),
                    ),
                    DataCell(
                      Chip(
                        label: Text(
                          event.serviceHash,
                          style: const TextStyle(
                              fontSize: 11.0, fontFamily: 'monospace'),
                        ),
                        visualDensity: VisualDensity.compact,
                        backgroundColor:
                            theme.colorScheme.surfaceContainerHighest,
                      ),
                    ),
                    DataCell(
                      Text(
                        '${event.latencyMetricMs} ms',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: event.latencyMetricMs > 500
                              ? theme.colorScheme.error
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    DataCell(
                      hasError
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                                vertical: 4.0,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.errorContainer,
                                borderRadius: BorderRadius.circular(6.0),
                              ),
                              child: Text(
                                event.errorCode!,
                                style: TextStyle(
                                  fontSize: 11.0,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onErrorContainer,
                                ),
                              ),
                            )
                          : Text(
                              'None',
                              style: TextStyle(
                                color: theme.colorScheme.outline,
                              ),
                            ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  /// Mobile View Layout (maxWidth <= 600): ListView.builder returning Material Cards
  Widget _buildMobileCardListViewLayout(
      ThemeData theme, List<BigQueryStreamingEvent> events) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        final hasError = event.errorCode != null;

        return Card(
          margin: const EdgeInsets.only(bottom: 12.0),
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
            side: BorderSide(
              color: hasError
                  ? theme.colorScheme.error.withValues(alpha: 0.5)
                  : theme.colorScheme.outlineVariant,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        event.eventName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    // Trailing Latency Metric & Error Code
                    Row(
                      children: [
                        Text(
                          '${event.latencyMetricMs} ms',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: event.latencyMetricMs > 500
                                ? theme.colorScheme.error
                                : theme.colorScheme.primary,
                          ),
                        ),
                        if (hasError) ...[
                          const SizedBox(width: 6.0),
                          Icon(
                            Icons.error,
                            size: 18.0,
                            color: theme.colorScheme.error,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 6.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Hash: ${event.serviceHash}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      _formatTimestamp(event.timestamp),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
                if (hasError) ...[
                  const SizedBox(height: 8.0),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text(
                      'Error: ${event.errorCode}',
                      style: TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatTimestamp(DateTime time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    final s = time.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }
}
