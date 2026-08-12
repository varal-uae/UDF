import 'dart:async';
import 'package:flutter/material.dart';
import '../services/device_metadata_service.dart';
import '../services/rate_limit_interceptor.dart';

/// Workspace component showcasing Device Metadata Tracking & API Gateway HTTP 429 Rate Limit Interceptor.
class RateLimitThrottleWorkspace extends StatefulWidget {
  const RateLimitThrottleWorkspace({super.key});

  @override
  State<RateLimitThrottleWorkspace> createState() =>
      _RateLimitThrottleWorkspaceState();
}

class _RateLimitThrottleWorkspaceState
    extends State<RateLimitThrottleWorkspace> {
  late final RateLimitInterceptor _interceptor;
  late DeviceMetadataPayload _deviceMetadata;

  bool _isRequesting = false;
  int _successCallCount = 0;
  int _throttled429Count = 0;
  String _apiLogMessage = 'Ready to send API Gateway requests.';

  // Simulated gateway configuration parameters
  int _simulatedCooldownHeaderSeconds = 4;
  bool _forceNextRequestToFail429 = true;

  @override
  void initState() {
    super.initState();

    // Initialize Rate Limit Interceptor
    _interceptor = RateLimitInterceptor(
      onRateLimitTriggered: _handleRateLimitCaught,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Collect device metadata with BuildContext for screen dimensions
    _deviceMetadata = DeviceMetadataService.collectMetadata(context);
  }

  /// Requirement 3: Poka-Yoke Fallback UI triggered when HTTP 429 is intercepted globally.
  void _handleRateLimitCaught(
    int cooldownSeconds,
    Future<void> Function() retryAction,
  ) {
    if (!mounted) return;

    // Trigger non-dismissible global Poka-Yoke modal bottom sheet
    showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (BuildContext modalContext) {
        return _RateLimitCooldownModal(
          cooldownSeconds: cooldownSeconds,
          onCooldownComplete: () async {
            Navigator.of(modalContext).pop();
            setState(() {
              _apiLogMessage =
                  'Cooldown expired! Automated retry pipeline executing...';
            });
            await retryAction();
          },
        );
      },
    );
  }

  /// Simulates an API Gateway HTTP request cycle with Device Metadata headers.
  Future<void> _executeApiRequest() async {
    if (_isRequesting) return;

    setState(() {
      _isRequesting = true;
      _apiLogMessage = 'Sending payload with X-Client Metadata Headers...';
    });

    try {
      Future<ApiResponse> performRequest() async {
        await Future.delayed(const Duration(milliseconds: 800));

        if (_forceNextRequestToFail429) {
          _forceNextRequestToFail429 = false; // Reset toggle after 429 test
          return ApiResponse(
            statusCode: 429,
            body:
                '{"error": "Too Many Requests", "message": "Rate limit exceeded"}',
            headers: {'Retry-After': '$_simulatedCooldownHeaderSeconds'},
          );
        }

        return const ApiResponse(
          statusCode: 200,
          body:
              '{"status": "SUCCESS", "message": "Payload processed cleanly"}',
          headers: {},
        );
      }

      final initialResponse = await performRequest();
      final response = await _interceptor.interceptResponse(
        initialResponse,
        requestCall: performRequest,
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() {
          _successCallCount++;
          _apiLogMessage =
              '200 OK: Payload accepted cleanly by API Gateway.';
        });
      }
    } on RateLimitException catch (e) {
      if (mounted) {
        setState(() {
          _throttled429Count++;
          _apiLogMessage = e.message;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRequesting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final headers = _deviceMetadata.toHeaders();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rate Limits & Metadata Tracking'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section 1: Device Metadata Payload Card
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
                            Row(
                              children: [
                                Icon(
                                  Icons.perm_device_information_outlined,
                                  color: colorScheme.primary,
                                ),
                                const SizedBox(width: 8.0),
                                Text(
                                  'Device Metadata Payload (Header Injection)',
                                  style: TextStyle(
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12.0),
                            _buildMetadataRow('Platform:',
                                _deviceMetadata.platform, colorScheme),
                            _buildMetadataRow('OS Version:',
                                _deviceMetadata.osVersion, colorScheme),
                            _buildMetadataRow('Device Model:',
                                _deviceMetadata.deviceModel, colorScheme),
                            _buildMetadataRow(
                              'Screen Dimensions:',
                              '${_deviceMetadata.screenDimensions} @ ${_deviceMetadata.screenPixelRatio}x',
                              colorScheme,
                            ),
                            const Divider(height: 24.0),
                            Text(
                              'Generated HTTP Headers:',
                              style: TextStyle(
                                fontSize: 12.0,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 6.0),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(10.0),
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: headers.entries.map((entry) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 4.0),
                                    child: SelectableText(
                                      '${entry.key}: ${entry.value}',
                                      style: TextStyle(
                                        fontSize: 11.0,
                                        fontFamily: 'monospace',
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16.0),

                    // Section 2: Rate Limit Interceptor Simulation Panel
                    Card(
                      elevation: 0,
                      color: colorScheme.surfaceContainer,
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
                              'API Gateway Rate Limit Interceptor (HTTP 429)',
                              style: TextStyle(
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              'Simulates client-side interceptor detection of API Gateway HTTP 429 status codes with automated retry pipeline.',
                              style: TextStyle(
                                fontSize: 13.0,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 12.0),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(12.0),
                                    decoration: BoxDecoration(
                                      color: colorScheme.primaryContainer,
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          'Successful (200)',
                                          style: TextStyle(
                                            fontSize: 11.0,
                                            color:
                                                colorScheme.onPrimaryContainer,
                                          ),
                                        ),
                                        Text(
                                          '$_successCallCount',
                                          style: TextStyle(
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.bold,
                                            color:
                                                colorScheme.onPrimaryContainer,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12.0),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(12.0),
                                    decoration: BoxDecoration(
                                      color: colorScheme.errorContainer,
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          'Throttled (429)',
                                          style: TextStyle(
                                            fontSize: 11.0,
                                            color: colorScheme.onErrorContainer,
                                          ),
                                        ),
                                        Text(
                                          '$_throttled429Count',
                                          style: TextStyle(
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.bold,
                                            color: colorScheme.onErrorContainer,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16.0),
                            Row(
                              children: [
                                Text(
                                  'Simulated Cooldown (Retry-After):',
                                  style: TextStyle(
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w500,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                const Spacer(),
                                DropdownButton<int>(
                                  value: _simulatedCooldownHeaderSeconds,
                                  items: const [3, 4, 5, 8].map((s) {
                                    return DropdownMenuItem(
                                      value: s,
                                      child: Text('${s}s'),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() {
                                        _simulatedCooldownHeaderSeconds = val;
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 12.0),

                            // Action Buttons
                            SizedBox(
                              width: double.infinity,
                              height: 46.0,
                              child: FilledButton.icon(
                                onPressed: _isRequesting
                                    ? null
                                    : () {
                                        _forceNextRequestToFail429 = true;
                                        _executeApiRequest();
                                      },
                                icon: const Icon(Icons.speed),
                                label: const Text(
                                  'Trigger HTTP 429 Rate Limit (Poka-Yoke Modal)',
                                ),
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            SizedBox(
                              width: double.infinity,
                              height: 42.0,
                              child: OutlinedButton.icon(
                                onPressed: _isRequesting
                                    ? null
                                    : () {
                                        _forceNextRequestToFail429 = false;
                                        _executeApiRequest();
                                      },
                                icon: const Icon(Icons.check_circle_outline),
                                label: const Text(
                                  'Send Normal Request (HTTP 200)',
                                ),
                              ),
                            ),
                            const SizedBox(height: 12.0),
                            Container(
                              padding: const EdgeInsets.all(10.0),
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerHigh,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Text(
                                'Status Log: $_apiLogMessage',
                                style: TextStyle(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.w500,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMetadataRow(
      String label, String value, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13.0,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13.0,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Requirement 3: Non-dismissible Poka-Yoke Bottom Sheet Modal during cooldown.
class _RateLimitCooldownModal extends StatefulWidget {
  const _RateLimitCooldownModal({
    required this.cooldownSeconds,
    required this.onCooldownComplete,
  });

  final int cooldownSeconds;
  final Future<void> Function() onCooldownComplete;

  @override
  State<_RateLimitCooldownModal> createState() =>
      __RateLimitCooldownModalState();
}

class __RateLimitCooldownModalState extends State<_RateLimitCooldownModal> {
  late int _secondsRemaining;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _secondsRemaining = widget.cooldownSeconds;
    _startCountdown();
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 1) {
        if (mounted) {
          setState(() {
            _secondsRemaining--;
          });
        }
      } else {
        _countdownTimer?.cancel();
        widget.onCooldownComplete();
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40.0,
            height: 4.0,
            decoration: BoxDecoration(
              color: colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2.0),
            ),
          ),
          const SizedBox(height: 16.0),
          Icon(
            Icons.lock_clock_outlined,
            size: 48.0,
            color: colorScheme.error,
          ),
          const SizedBox(height: 12.0),
          Text(
            'Poka-Yoke Rate Limit Active',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            'HTTP 429 Intercepted: API Gateway cooldown in progress. User interactions locked to preserve server perimeter.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.0,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20.0),

          // Countdown Badge Display
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: colorScheme.error),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 18.0,
                  height: 18.0,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: colorScheme.onErrorContainer,
                  ),
                ),
                const SizedBox(width: 12.0),
                Text(
                  'Cooldown Remaining: ${_secondsRemaining}s',
                  style: TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onErrorContainer,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16.0),
        ],
      ),
    );
  }
}
