import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';

/// Data model representing atomic device metadata fields.
class DeviceMetadataPayload {
  const DeviceMetadataPayload({
    required this.platform,
    required this.osVersion,
    required this.deviceModel,
    required this.screenDimensions,
    required this.screenPixelRatio,
  });

  final String platform;
  final String osVersion;
  final String deviceModel;
  final String screenDimensions;
  final double screenPixelRatio;

  Map<String, dynamic> toJson() => {
        'platform': platform,
        'osVersion': osVersion,
        'deviceModel': deviceModel,
        'screenDimensions': screenDimensions,
        'screenPixelRatio': screenPixelRatio,
      };

  /// Generate HTTP Header map for API Gateway consumption.
  Map<String, String> toHeaders() {
    return {
      'X-Client-OS': '$platform $osVersion',
      'X-Client-Device': deviceModel,
      'X-Client-Screen': '$screenDimensions @ ${screenPixelRatio.toStringAsFixed(1)}x',
      'X-Client-Metadata': jsonEncode(toJson()),
    };
  }
}

/// Service for inspecting and constructing Device Metadata Payloads.
class DeviceMetadataService {
  /// Collects atomic device metadata fields and returns a [DeviceMetadataPayload].
  static DeviceMetadataPayload collectMetadata([BuildContext? context]) {
    String platformName = 'Unknown';
    String osVersionStr = 'Unknown OS';
    String modelStr = 'Generic Device';

    if (kIsWeb) {
      platformName = 'Web';
      osVersionStr = 'Web Browser';
      modelStr = 'HTML5 User Agent';
    } else {
      switch (defaultTargetPlatform) {
        case TargetPlatform.android:
          platformName = 'Android';
          osVersionStr = 'Android ${Platform.operatingSystemVersion}';
          modelStr = 'Android Handset';
          break;
        case TargetPlatform.iOS:
          platformName = 'iOS';
          osVersionStr = 'iOS ${Platform.operatingSystemVersion}';
          modelStr = 'iPhone / iPad';
          break;
        case TargetPlatform.windows:
          platformName = 'Windows';
          osVersionStr = 'Windows ${Platform.operatingSystemVersion}';
          modelStr = 'Desktop Workstation';
          break;
        case TargetPlatform.macOS:
          platformName = 'macOS';
          osVersionStr = 'macOS ${Platform.operatingSystemVersion}';
          modelStr = 'Mac Workstation';
          break;
        case TargetPlatform.linux:
          platformName = 'Linux';
          osVersionStr = 'Linux ${Platform.operatingSystemVersion}';
          modelStr = 'Linux Workstation';
          break;
        default:
          platformName = 'Mobile/Desktop';
          osVersionStr = Platform.operatingSystemVersion;
          modelStr = 'Standard Device';
      }
    }

    // MediaQuery screen dimensions extraction
    String dimensions = 'Unknown Size';
    double pixelRatio = 1.0;

    if (context != null) {
      final mediaQuery = MediaQuery.maybeOf(context);
      if (mediaQuery != null) {
        final size = mediaQuery.size;
        dimensions = '${size.width.toInt()}x${size.height.toInt()}';
        pixelRatio = mediaQuery.devicePixelRatio;
      }
    } else {
      // Fallback screen dimensions when context is null
      dimensions = '393x852';
      pixelRatio = 3.0;
    }

    return DeviceMetadataPayload(
      platform: platformName,
      osVersion: osVersionStr,
      deviceModel: modelStr,
      screenDimensions: dimensions,
      screenPixelRatio: pixelRatio,
    );
  }
}
