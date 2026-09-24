// GEN-02019 — GPS Spoofing Detection Service.
// Implements GPS spoofing detection to flag anomalous jumps in location using velocity and distance thresholds. Provides mock location data for standalone validation.

import 'dart:math';

/// Qualitative output classification for geofence/GPS accuracy.
enum GpsAccuracyLevel { high, medium, low }

/// Represents a single location sample with timestamp.
class LocationSample {
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final double accuracyMeters;

  const LocationSample({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    required this.accuracyMeters,
  });
}

/// Result of the spoofing evaluation for a given location jump.
class SpoofingResult {
  final bool isSpoofed;
  final double distanceMeters;
  final double velocityMps;
  final GpsAccuracyLevel accuracyLevel;
  final String traceId;

  const SpoofingResult({
    required this.isSpoofed,
    required this.distanceMeters,
    required this.velocityMps,
    required this.accuracyLevel,
    required this.traceId,
  });

  Map<String, dynamic> toBigQueryEvent() => {
        'event_date': DateTime.now().toIso8601String().split('T').first,
        'trace_id': traceId,
        'is_spoofed': isSpoofed,
        'distance_meters': distanceMeters,
        'velocity_mps': velocityMps,
        'accuracy_level': accuracyLevel.name,
      };
}

/// Core service to detect GPS spoofing by analyzing anomalous jumps.
class GpsSpoofingDetector {
  /// Maximum plausible human velocity (m/s). ~100 m/s covers fast vehicles.
  static const double kMaxPlausibleVelocityMps = 100.0;

  /// Floor threshold for geofence detection accuracy (meters).
  static const double kFloorThresholdMeters = 100.0;

  /// Optimal target for geofence detection accuracy (meters).
  static const double kOptimalTargetMeters = 50.0;

  /// Ceiling boundary for geofence detection accuracy (meters).
  static const double kCeilingBoundaryMeters = 10.0;

  /// Earth radius in meters for Haversine calculation.
  static const double kEarthRadiusMeters = 6371000.0;

  LocationSample? _previousSample;

  /// Evaluates a new location sample against the previous one.
  /// Returns a [SpoofingResult] indicating if the jump is anomalous.
  SpoofingResult evaluate(LocationSample current) {
    final traceId = _generateTraceId();

    if (_previousSample == null) {
      _previousSample = current;
      return SpoofingResult(
        isSpoofed: false,
        distanceMeters: 0.0,
        velocityMps: 0.0,
        accuracyLevel: _classifyAccuracy(current.accuracyMeters),
        traceId: traceId,
      );
    }

    final previous = _previousSample!;
    final distance = _haversineDistance(
      previous.latitude,
      previous.longitude,
      current.latitude,
      current.longitude,
    );

    final timeDiffSeconds =
        current.timestamp.difference(previous.timestamp).inMilliseconds / 1000.0;

    // Prevent division by zero; treat sub-millisecond jumps as suspicious if distance > 0
    final velocity = timeDiffSeconds > 0 ? distance / timeDiffSeconds : (distance > 0 ? double.infinity : 0.0);

    final isSpoofed = velocity > kMaxPlausibleVelocityMps ||
        current.accuracyMeters > kFloorThresholdMeters;

    _previousSample = current;

    return SpoofingResult(
      isSpoofed: isSpoofed,
      distanceMeters: distance,
      velocityMps: velocity,
      accuracyLevel: _classifyAccuracy(current.accuracyMeters),
      traceId: traceId,
    );
  }

  /// Resets the detector state.
  void reset() {
    _previousSample = null;
  }

  /// Classifies accuracy based on defined boundaries.
  GpsAccuracyLevel _classifyAccuracy(double accuracyMeters) {
    if (accuracyMeters <= kCeilingBoundaryMeters) {
      return GpsAccuracyLevel.high;
    } else if (accuracyMeters <= kOptimalTargetMeters) {
      return GpsAccuracyLevel.medium;
    } else {
      return GpsAccuracyLevel.low;
    }
  }

  /// Calculates the Haversine distance between two coordinates in meters.
  double _haversineDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);

    final a = pow(sin(dLat / 2), 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            pow(sin(dLon / 2), 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return kEarthRadiusMeters * c;
  }

  double _degreesToRadians(double degrees) => degrees * pi / 180.0;

  String _generateTraceId() {
    final now = DateTime.now().microsecondsSinceEpoch;
    final random = Random.secure().nextInt(99999).toString().padLeft(5, '0');
    return 'trace_${now}_$random';
  }
}

/// Mock data generator for testing GPS spoofing detection without backend.
class MockLocationDataProvider {
  static List<LocationSample> generateNormalPath() {
    final baseTime = DateTime(2026, 9, 24, 10, 0, 0);
    return [
      LocationSample(
        latitude: 37.7749,
        longitude: -122.4194,
        timestamp: baseTime,
        accuracyMeters: 8.0,
      ),
      LocationSample(
        latitude: 37.7750,
        longitude: -122.4195,
        timestamp: baseTime.add(const Duration(seconds: 5)),
        accuracyMeters: 12.0,
      ),
      LocationSample(
        latitude: 37.7752,
        longitude: -122.4197,
        timestamp: baseTime.add(const Duration(seconds: 10)),
        accuracyMeters: 9.0,
      ),
    ];
  }

  static List<LocationSample> generateSpoofedPath() {
    final baseTime = DateTime(2026, 9, 24, 10, 0, 0);
    return [
      LocationSample(
        latitude: 37.7749,
        longitude: -122.4194,
        timestamp: baseTime,
        accuracyMeters: 8.0,
      ),
      // Anomalous jump: San Francisco to New York in 2 seconds
      LocationSample(
        latitude: 40.7128,
        longitude: -74.0060,
        timestamp: baseTime.add(const Duration(seconds: 2)),
        accuracyMeters: 150.0,
      ),
    ];
  }
}
