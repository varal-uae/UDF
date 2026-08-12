import 'package:flutter/material.dart';

/// Secure 'Payload Upload' UI component handling API Gateway perimeter rejections.
/// Fulfills strict atomic state locks, M3 error token styling, progressive loading,
/// and tabular KPI metrics display.
class PayloadUploadWidget extends StatefulWidget {
  const PayloadUploadWidget({super.key});

  @override
  State<PayloadUploadWidget> createState() => _PayloadUploadWidgetState();
}

class _PayloadUploadWidgetState extends State<PayloadUploadWidget> {
  // Requirement 1: Atomic State Lock variable
  bool _isProcessing = false;

  // Simulated payload size in MB (default set above 10MB limit to demonstrate 413 error)
  double _payloadSizeMb = 15.0;
  final double _maxAllowedMb = 10.0;

  // Metrics for Tabular Data Card
  int _droppedPacketsCount = 1429;
  int _totalUploadAttempts = 42;

  /// Simulates an asynchronous API Gateway payload upload request.
  Future<void> _handlePayloadUpload() async {
    // Atomic state lock check to prevent duplicate async pipeline calls
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
      _totalUploadAttempts++;
    });

    try {
      // Simulate network request latency to API Gateway
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      // Simulate API Gateway Perimeter Rejection (HTTP 413 Payload Too Large)
      if (_payloadSizeMb > _maxAllowedMb) {
        setState(() {
          _droppedPacketsCount++;
        });

        _showApiGatewayError();
      } else {
        // Success notification for payloads within limit
        final colorScheme = Theme.of(context).colorScheme;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: colorScheme.primaryContainer,
            content: Row(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  color: colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 8.0),
                Text(
                  'Payload uploaded successfully!',
                  style: TextStyle(color: colorScheme.onPrimaryContainer),
                ),
              ],
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  /// Triggers SnackBar and AlertDialog styled strictly with M3 Error Tokens.
  void _showApiGatewayError() {
    final colorScheme = Theme.of(context).colorScheme;
    const errorMessage = 'Sending failed: payload over limit';

    // 1. Trigger SnackBarToast styled with Material 3 Error Tokens
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: colorScheme.errorContainer,
        behavior: SnackBarBehavior.floating,
        content: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: colorScheme.onErrorContainer,
            ),
            const SizedBox(width: 8.0),
            Expanded(
              child: Text(
                errorMessage,
                style: TextStyle(
                  color: colorScheme.onErrorContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    // 2. Trigger structural AlertDialog styled with Material 3 Error Tokens
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: colorScheme.errorContainer,
          icon: Icon(
            Icons.gpp_bad_outlined,
            size: 36.0,
            color: colorScheme.onErrorContainer,
          ),
          title: Text(
            'API Gateway Perimeter Rejection',
            style: TextStyle(
              color: colorScheme.onErrorContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colorScheme.onErrorContainer,
                  fontSize: 16.0,
                ),
              ),
              const SizedBox(height: 12.0),
              Text(
                'HTTP 413 Payload Too Large: The payload size (${_payloadSizeMb.toStringAsFixed(1)} MB) exceeds the gateway perimeter limit (${_maxAllowedMb.toStringAsFixed(1)} MB).',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colorScheme.onErrorContainer,
                  fontSize: 12.0,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Acknowledge',
                style: TextStyle(
                  color: colorScheme.onErrorContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Control Panel Card for simulation parameters
                Card(
                  elevation: 0,
                  color: colorScheme.surfaceContainerLow,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    side: BorderSide(color: colorScheme.outlineVariant),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'API Gateway Payload Upload Enforcer',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          'Simulated Payload Size: ${_payloadSizeMb.toStringAsFixed(1)} MB (Max Allowed: ${_maxAllowedMb.toStringAsFixed(1)} MB)',
                          style: TextStyle(
                            fontSize: 13.0,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Slider(
                          value: _payloadSizeMb,
                          min: 1.0,
                          max: 25.0,
                          divisions: 24,
                          label: '${_payloadSizeMb.toStringAsFixed(1)} MB',
                          onChanged: _isProcessing
                              ? null
                              : (val) {
                                  setState(() {
                                    _payloadSizeMb = val;
                                  });
                                },
                        ),
                        const SizedBox(height: 12.0),

                        // Requirement 1 & 2: Upload Button with Atomic Lock & Progressive Loader
                        SizedBox(
                          width: double.infinity,
                          height: 48.0,
                          child: FilledButton.icon(
                            onPressed: _isProcessing ? null : _handlePayloadUpload,
                            icon: _isProcessing
                                ? SizedBox(
                                    width: 20.0,
                                    height: 20.0,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: colorScheme.onPrimary,
                                    ),
                                  )
                                : const Icon(Icons.cloud_upload_outlined),
                            label: Text(
                              _isProcessing ? 'Processing Payload...' : 'Upload Payload to Gateway',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),

                        // Requirement 2: Explicit Progressive Loader display while processing
                        if (_isProcessing) ...[
                          const SizedBox(height: 16.0),
                          Container(
                            padding: const EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 16.0,
                                  height: 16.0,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.0,
                                    color: colorScheme.onPrimaryContainer,
                                  ),
                                ),
                                const SizedBox(width: 12.0),
                                Text(
                                  'Inspecting payload perimeter rules...',
                                  style: TextStyle(
                                    fontSize: 13.0,
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),

                // Requirement 5: Tabular Data Card utilizing an 8dp padding grid (16.0dp)
                Card(
                  elevation: 0,
                  color: colorScheme.surfaceContainer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    side: BorderSide(color: colorScheme.outlineVariant),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0), // 8dp grid system (16dp)
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.table_chart_outlined,
                              size: 20.0,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(width: 8.0),
                            Text(
                              'Perimeter Traffic Metrics (KPI Layout)',
                              style: TextStyle(
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12.0),

                        // Requirement 5: Table / DataTable showing 'Dropped Packets'
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columnSpacing: 24.0,
                            headingRowHeight: 40.0,
                            dataRowMinHeight: 44.0,
                            dataRowMaxHeight: 44.0,
                            columns: [
                              DataColumn(
                                label: Text(
                                  'Metric Name',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Metric Value',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Policy Status',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ],
                            rows: [
                              DataRow(
                                cells: [
                                  DataCell(
                                    Text(
                                      'Dropped Packets',
                                      style: TextStyle(
                                        color: colorScheme.error,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      '$_droppedPacketsCount pkts',
                                      style: TextStyle(
                                        color: colorScheme.error,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      'HTTP 413 Payload Too Large',
                                      style: TextStyle(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              DataRow(
                                cells: [
                                  DataCell(
                                    Text(
                                      'Total Upload Attempts',
                                      style: TextStyle(color: colorScheme.onSurface),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      '$_totalUploadAttempts',
                                      style: TextStyle(color: colorScheme.onSurface),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      'Active Ingestion Stream',
                                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                                    ),
                                  ),
                                ],
                              ),
                              DataRow(
                                cells: [
                                  DataCell(
                                    Text(
                                      'Max Payload Threshold',
                                      style: TextStyle(color: colorScheme.onSurface),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      '${_maxAllowedMb.toStringAsFixed(0)} MB',
                                      style: TextStyle(color: colorScheme.onSurface),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      'Strict Guardrail',
                                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
