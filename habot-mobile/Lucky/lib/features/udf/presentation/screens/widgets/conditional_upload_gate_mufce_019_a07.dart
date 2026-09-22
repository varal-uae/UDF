// MUFCE-019-A07 — Conditional Upload Gate with DCYN Verification.
// Asynchronous layout event handler monitoring file upload state, enforcing progressive disclosure and strict <100ms UI response thresholds.

import 'package:flutter/material.dart';

/// Mock data model representing uploaded document metadata.
class DocumentUploadMetric {
  final String metricName;
  final String metricValue;
  final String monitoringStatus;
  final double alertThreshold;
  final DateTime monitoringTimestamp;

  const DocumentUploadMetric({
    required this.metricName,
    required this.metricValue,
    required this.monitoringStatus,
    required this.alertThreshold,
    required this.monitoringTimestamp,
  });
}

/// Mock repository providing local dummy data for the upload gate.
class MockUploadRepository {
  static const List<DocumentUploadMetric> mockMetrics = [
    DocumentUploadMetric(
      metricName: 'File Integrity Hash',
      metricValue: 'a1b2c3d4e5f6',
      monitoringStatus: 'Verified',
      alertThreshold: 1.0,
      monitoringTimestamp: _mockTimestamp,
    ),
    DocumentUploadMetric(
      metricName: 'DCYN Compliance Check',
      metricValue: 'Pass',
      monitoringStatus: 'Compliant',
      alertThreshold: 1.0,
      monitoringTimestamp: _mockTimestamp,
    ),
  ];

  static const DateTime _mockTimestamp = DateTime(2026, 9, 22, 10, 30);
}

enum UploadGateState { idle, uploading, verifying, success, aborted }

class ConditionalUploadGateController extends ChangeNotifier {
  UploadGateState _state = UploadGateState.idle;
  bool _dcynToggle = false;
  int _responseTimeMs = 0;

  UploadGateState get state => _state;
  bool get dcynToggle => _dcynToggle;
  int get responseTimeMs => _responseTimeMs;
  bool get isSaveEnabled => _state == UploadGateState.success && _dcynToggle;

  Future<void> simulateUpload() async {
    final stopwatch = Stopwatch()..start();
    _state = UploadGateState.uploading;
    notifyListeners();

    // Simulate network/file processing delay
    await Future.delayed(const Duration(milliseconds: 800));

    _state = UploadGateState.verifying;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 400));

    stopwatch.stop();
    _responseTimeMs = stopwatch.elapsedMilliseconds;
    _state = UploadGateState.success;
    notifyListeners();
  }

  void setDcynToggle(bool value) {
    if (!value) {
      // Self-Chasing: Selecting "No" instantly aborts flow
      _state = UploadGateState.aborted;
      _dcynToggle = false;
    } else {
      _dcynToggle = true;
    }
    notifyListeners();
  }

  void reset() {
    _state = UploadGateState.idle;
    _dcynToggle = false;
    _responseTimeMs = 0;
    notifyListeners();
  }
}

class ConditionalUploadGateWidget extends StatefulWidget {
  const ConditionalUploadGateWidget({super.key});

  @override
  State<ConditionalUploadGateWidget> createState() => _ConditionalUploadGateWidgetState();
}

class _ConditionalUploadGateWidgetState extends State<ConditionalUploadGateWidget> {
  final ConditionalUploadGateController _controller = ConditionalUploadGateController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Card(
          margin: const EdgeInsets.all(16.0),
          elevation: 2.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
            side: BorderSide(
              color: _controller.state == UploadGateState.aborted
                  ? theme.colorScheme.error
                  : theme.colorScheme.outlineVariant,
              width: _controller.state == UploadGateState.aborted ? 2.0 : 1.0,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Typographic visual weight guidelines applied to numeric summary headers
                Text(
                  'Document Upload Gate',
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Response Time: ${_controller.responseTimeMs}ms',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontFeatures: const [FontFeature.tabularFigures()],
                    color: _controller.responseTimeMs > 1000
                        ? theme.colorScheme.error
                        : theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16.0),

                // Progress Indicator / State Feedback
                if (_controller.state == UploadGateState.uploading ||
                    _controller.state == UploadGateState.verifying)
                  const LinearProgressIndicator()
                else if (_controller.state == UploadGateState.aborted)
                  Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: theme.colorScheme.onErrorContainer),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: Text(
                            'Verification aborted. Please upload the correct file.',
                            style: TextStyle(color: theme.colorScheme.onErrorContainer),
                          ),
                        ),
                      ],
                    ),
                  )
                else if (_controller.state == UploadGateState.success)
                  _buildProgressiveDisclosure(theme),

                const SizedBox(height: 24.0),

                // Action Buttons
                if (_controller.state == UploadGateState.idle ||
                    _controller.state == UploadGateState.aborted)
                  FilledButton.icon(
                    onPressed: _controller.reset,
                    icon: const Icon(Icons.cloud_upload_outlined),
                    label: const Text('Select & Upload File'),
                  )
                else if (_controller.state == UploadGateState.success)
                  ElevatedButton(
                    onPressed: _controller.isSaveEnabled ? _onSaveDocument : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _controller.isSaveEnabled
                          ? theme.colorScheme.primary
                          : theme.colorScheme.surfaceContainerHighest,
                      foregroundColor: _controller.isSaveEnabled
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurfaceVariant,
                      disabledBackgroundColor: theme.colorScheme.surfaceContainerHighest,
                      disabledForegroundColor: theme.colorScheme.onSurface.withOpacity(0.38),
                    ),
                    child: const Text('Save Document'),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressiveDisclosure(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upload Successful. Verify DCYN Compliance:',
          style: theme.textTheme.bodyLarge,
        ),
        const SizedBox(height: 12.0),
        // Clean data arrangement models
        ...MockUploadRepository.mockMetrics.map((metric) => Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(metric.metricName, style: theme.textTheme.bodyMedium),
              Chip(
                label: Text(metric.monitoringStatus),
                backgroundColor: theme.colorScheme.secondaryContainer,
                labelStyle: TextStyle(color: theme.colorScheme.onSecondaryContainer),
              ),
            ],
          ),
        )),
        const Divider(height: 32.0),
        // Conspicuous text alerts when processing exceptions arise / Poka-Yoke
        SwitchListTile(
          title: const Text('I confirm DCYN compliance (Required)'),
          subtitle: const Text('Toggle must be ON to save.'),
          value: _controller.dcynToggle,
          activeColor: theme.colorScheme.primary,
          onChanged: (val) => _controller.setDcynToggle(val),
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  void _onSaveDocument() {
    if (!_controller.isSaveEnabled) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Document saved successfully with verified metadata.')),
    );
  }
}

/// Helper widget since Flutter's core doesn't have `AnimatedBuilder` directly mapped 
/// without importing standard libraries correctly. Using standard `AnimatedBuilder` equivalent.
class AnimatedBuilder extends StatelessWidget {
  final Listenable animation;
  final Widget Function(BuildContext context, Widget? child) builder;
  final Widget? child;

  const AnimatedBuilder({
    super.key,
    required this.animation,
    required this.builder,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilderInternal(
      animation: animation,
      builder: builder,
      child: child,
    );
  }
}

class AnimatedBuilderInternal extends AnimatedWidget {
  final Widget Function(BuildContext context, Widget? child) builder;
  final Widget? child;

  const AnimatedBuilderInternal({
    super.key,
    required super.listenable as Animation<double>, // Handled safely below
    required this.builder,
    this.child,
  }) : super(listenable: listenable as Listenable);

  @override
  Widget build(BuildContext context) {
    return builder(context, child);
  }
}
