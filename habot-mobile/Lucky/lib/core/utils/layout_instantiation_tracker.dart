// IRBCA-031 — Layout Instantiation and Interaction Duration Tracker.
// Captures absolute system timestamps silently using universal ISO 8601 strings.
// Calculates transaction/interaction duration metrics for backend performance tracking.

import 'package:flutter/widgets.dart';

/// Lightweight data frame for timing variables
class InstantiationTimeFrame {
  const InstantiationTimeFrame({
    required this.instantiationTime,
    required this.deviceInfo,
  });

  /// Absolute ISO 8601 UTC timestamp of instantiation
  final String instantiationTime;

  /// System/device dimensions and metadata payload
  final Map<String, String> deviceInfo;
}

/// A mixin to silently track mount/layout instantiation timestamps and interaction durations.
mixin LayoutInstantiationTracker<T extends StatefulWidget> on State<T> {
  late DateTime _instantiationTime;
  late String _instantiationIsoString;

  @override
  void initState() {
    super.initState();
    _instantiationTime = DateTime.now().toUtc();
    _instantiationIsoString = _instantiationTime.toIso8601String();
  }

  /// Retrieves the initial instantiation details including universal timestamp.
  InstantiationTimeFrame get instantiationFrame {
    final mediaQuery = MediaQuery.of(context);
    return InstantiationTimeFrame(
      instantiationTime: _instantiationIsoString,
      deviceInfo: {
        'platform': DefaultAssetBundle.of(context).toString(), // Platform fallback check
        'screenSize': '${mediaQuery.size.width}x${mediaQuery.size.height}',
        'orientation': mediaQuery.orientation.toString(),
      },
    );
  }

  /// Calculates elapsed duration since mount in milliseconds.
  int get elapsedMs => DateTime.now().toUtc().difference(_instantiationTime).inMilliseconds;

  /// Returns the complete interaction payload envelope.
  Map<String, dynamic> buildTelemetryEnvelope({
    required String stepExecutionId,
    required String userId,
    required String stepOutcome,
    String? currentServiceState,
  }) {
    return {
      'step_execution_id': stepExecutionId,
      'execution_status': 'Completed',
      'execution_timestamp': DateTime.now().toUtc().toIso8601String(),
      'instantiation_timestamp': _instantiationIsoString,
      'interaction_duration_ms': elapsedMs,
      'step_outcome': stepOutcome,
      'user_id': userId,
      'device_meta': {
        'screen_dims': instantiationFrame.deviceInfo['screenSize'],
        'orientation': instantiationFrame.deviceInfo['orientation'],
      },
    };
  }
}
