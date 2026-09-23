// GEN-01831 — Fallback UI Error Handler & Display Widget.
// Prompts the user with a generated Material 3 fallback UI rather than crashing the app. Implements single-column mobile layout (<600dp) and multi-column desktop (>=840dp) with M3 Elevated Cards, Status Chips, and 48x48dp touch targets.

import 'package:flutter/material.dart';

/// Mock telemetry event for crash-free session tracking.
class _MockTelemetryEvent {
  final String traceId;
  final DateTime timestamp;
  final String status;

  const _MockTelemetryEvent({
    required this.traceId,
    required this.timestamp,
    required this.status,
  });
}

/// Mock repository simulating backend data stream to BigQuery.
class _MockFallbackTelemetryRepository {
  static const List<_MockTelemetryEvent> events = [
    _MockTelemetryEvent(
      traceId: 'trace-001-gen-01831',
      timestamp: _kMockNow,
      status: 'High',
    ),
    _MockTelemetryEvent(
      traceId: 'trace-002-gen-01831',
      timestamp: _kMockNow,
      status: 'Medium',
    ),
  ];

  static const DateTime _kMockNow = DateTime(2026, 9, 23, 12, 0, 0);

  static Future<List<_MockTelemetryEvent>> fetchEvents() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return events;
  }
}

/// Evaluates Crash-Free Session Rate against defined thresholds.
/// Floor: 98%, Optimal: 99.5%, Ceiling: 99.99%
String _evaluateQualitativeOutput(double crashFreeRate) {
  if (crashFreeRate >= 99.99) return 'High';
  if (crashFreeRate >= 98.0) return 'Medium';
  return 'Low';
}

/// Wraps a child widget in an [ErrorBoundary] that catches Flutter framework
/// errors and presents [FallbackUiScreen] instead of crashing the app.
class ErrorBoundary extends StatefulWidget {
  final Widget child;

  const ErrorBoundary({super.key, required this.child});

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  FlutterErrorDetails? _errorDetails;

  @override
  void initState() {
    super.initState();
    FlutterError.onError = (FlutterErrorDetails details) {
      setState(() {
        _errorDetails = details;
      });
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_errorDetails != null) {
      return FallbackUiScreen(errorDetails: _errorDetails!);
    }
    return widget.child;
  }
}

/// The generated fallback UI screen presented when an error occurs.
/// Follows M3 responsive layout: single-column on mobile (<600dp),
/// multi-column on desktop (>=840dp).
class FallbackUiScreen extends StatefulWidget {
  final FlutterErrorDetails errorDetails;

  const FallbackUiScreen({super.key, required this.errorDetails});

  @override
  State<FallbackUiScreen> createState() => _FallbackUiScreenState();
}

class _FallbackUiScreenState extends State<FallbackUiScreen> {
  late Future<List<_MockTelemetryEvent>> _eventsFuture;

  @override
  void initState() {
    super.initState();
    _eventsFuture = _MockFallbackTelemetryRepository.fetchEvents();
  }

  void _refreshData() {
    setState(() {
      _eventsFuture = _MockFallbackTelemetryRepository.fetchEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final bool isDesktop = screenWidth >= 840;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    // M3 Status Chip color based on qualitative output
    final String qualitativeStatus = _evaluateQualitativeOutput(99.5); // Mock optimal rate
    final Color chipColor = qualitativeStatus == 'High'
        ? Colors.green
        : qualitativeStatus == 'Medium'
            ? Colors.orange
            : Colors.red;

    final Widget headerCard = _buildHeaderCard(colorScheme, chipColor, qualitativeStatus);
    final Widget errorDetailsCard = _buildErrorDetailsCard(colorScheme);
    final Widget telemetryCard = _buildTelemetryCard(colorScheme);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('System Recovery'),
        centerTitle: true,
        backgroundColor: colorScheme.surfaceContainerHighest,
      ),
      body: RefreshIndicator(
        onRefresh: () async => _refreshData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: isDesktop
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: Column(children: [headerCard, const SizedBox(height: 16), errorDetailsCard])),
                    const SizedBox(width: 16),
                    Expanded(flex: 1, child: telemetryCard),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    headerCard,
                    const SizedBox(height: 16),
                    errorDetailsCard,
                    const SizedBox(height: 16),
                    telemetryCard,
                  ],
                ),
        ),
      ),
    );
  }

  /// M3 Elevated Card Level 2 (3dp elevation) displaying step completion state.
  Widget _buildHeaderCard(ColorScheme colorScheme, Color chipColor, String status) {
    return Card(
      elevation: 3.0,
      surfaceTintColor: colorScheme.surfaceTint,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fallback UI Active',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: colorScheme.onSurface,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'We encountered an unexpected issue. The application has safely recovered without crashing.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Crash-Free Session Rate: '),
                // M3 Status Chip for health indicator
                Chip(
                  avatar: Icon(Icons.check_circle, color: chipColor, size: 18),
                  label: Text(status),
                  backgroundColor: chipColor.withOpacity(0.1),
                  labelStyle: TextStyle(color: chipColor, fontWeight: FontWeight.bold),
                  side: BorderSide.none,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorDetailsCard(ColorScheme colorScheme) {
    return Card(
      elevation: 3.0,
      surfaceTintColor: colorScheme.surfaceTint,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Diagnostic Information',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                widget.errorDetails.exceptionAsString(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                      color: colorScheme.error,
                    ),
              ),
            ),
            const SizedBox(height: 24),
            // 48x48dp touch target for primary action
            SizedBox(
              height: 48,
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) => _buildConfigBottomSheet(colorScheme),
                  );
                },
                icon: const Icon(Icons.settings_backup_restore),
                label: const Text('Open Configuration & Recovery'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTelemetryCard(ColorScheme colorScheme) {
    return Card(
      elevation: 3.0,
      surfaceTintColor: colorScheme.surfaceTint,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Engineering Console KPIs',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            FutureBuilder<List<_MockTelemetryEvent>>(
              future: _eventsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text('No telemetry data available.');
                }
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final event = snapshot.data![index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text('Trace: ${event.traceId}', style: Theme.of(context).textTheme.bodyMedium),
                      subtitle: Text(event.timestamp.toIso8601String(), style: Theme.of(context).textTheme.bodySmall),
                      trailing: Chip(
                        label: Text(event.status),
                        backgroundColor: event.status == 'High' ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// M3 Bottom Sheet for configuration inputs.
  Widget _buildConfigBottomSheet(ColorScheme colorScheme) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recovery Configuration',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Session ID Override',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest,
              ),
            ),
            const SizedBox(height: 24),
            // 48x48dp touch target
            SizedBox(
              height: 48,
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                  // M3 Snackbar for confirmation
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Configuration saved successfully.'),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      action: SnackBarAction(
                        label: 'Dismiss',
                        onPressed: () {},
                      ),
                    ),
                  );
                },
                child: const Text('Apply & Restart'),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}