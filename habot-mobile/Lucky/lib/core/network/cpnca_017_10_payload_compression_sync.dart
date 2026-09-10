// CPNCA-017-10 — Mobile API Payload Compression Standards.
// Deterministic client-side gzip compression loops for data sync payloads with conformance metrics and device context capture.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

class CompressionStandardConfig {
  final int minBytesForCompression;
  final int chunkSizeBytes;
  final int maxCompressionLoops;
  final double floorBoundary;
  final double optimalTarget;
  final double ceilingBoundary;

  const CompressionStandardConfig({
    this.minBytesForCompression = 1024,
    this.chunkSizeBytes = 64 * 1024,
    this.maxCompressionLoops = 3,
    this.floorBoundary = 0.9,
    this.optimalTarget = 0.97,
    this.ceilingBoundary = 1.0,
  });
}

class DeviceCompressionContext {
  final String mobilePlatform;
  final String osVersion;
  final String deviceType;
  final String screenDimensions;
  final String mobileConfiguration;

  const DeviceCompressionContext({
    required this.mobilePlatform,
    required this.osVersion,
    required this.deviceType,
    required this.screenDimensions,
    required this.mobileConfiguration,
  });

  Map<String, dynamic> toJson() => {
        'Mobile Platform': mobilePlatform,
        'OS Version': osVersion,
        'Device Type': deviceType,
        'Screen Dimensions': screenDimensions,
        'Mobile Configuration': mobileConfiguration,
      };
}

class CompressedPayload {
  final String atomicId;
  final String encoding;
  final List<int> bytes;
  final int originalSize;
  final int compressedSize;
  final int compressionLoops;
  final DateTime timestamp;
  final String? sessionId;
  final DeviceCompressionContext? deviceContext;

  const CompressedPayload({
    required this.atomicId,
    required this.encoding,
    required this.bytes,
    required this.originalSize,
    required this.compressedSize,
    required this.compressionLoops,
    required this.timestamp,
    this.sessionId,
    this.deviceContext,
  });

  double get compressionRatio =>
      originalSize == 0 ? 1.0 : compressedSize / originalSize;

  double get conformanceScore =>
      (1.0 - compressionRatio).clamp(0.0, 1.0).toDouble();

  bool get meetsFloorBoundary => conformanceScore >= 0.9;
  bool get meetsOptimalTarget => conformanceScore >= 0.97;
  bool get isComplete => conformanceScore <= 1.0;

  Map<String, dynamic> toAuditJson() => {
        'Atomic ID': atomicId,
        'Encoding': encoding,
        'Original Size': originalSize,
        'Compressed Size': compressedSize,
        'Compression Ratio': compressionRatio,
        'Conformance Score': conformanceScore,
        'Compression Loops': compressionLoops,
        'Action/Event Timestamp': timestamp.toIso8601String(),
        'User/Session ID': sessionId,
        'Mobile Platform': deviceContext?.mobilePlatform,
        'OS Version': deviceContext?.osVersion,
        'Device Type': deviceContext?.deviceType,
        'Screen Dimensions': deviceContext?.screenDimensions,
        'Mobile Configuration': deviceContext?.mobileConfiguration,
        'Completion Status': isComplete ? 'Complete' : 'Partial',
      };
}

class PayloadCompressionSync {
  static const String atomicId = 'CPNCA-017-10';

  final CompressionStandardConfig config;

  const PayloadCompressionSync({
    this.config = const CompressionStandardConfig(),
  });

  Future<CompressedPayload> compressJsonPayload(
    Map<String, dynamic> payload, {
    String? sessionId,
    DeviceCompressionContext? deviceContext,
  }) async {
    final rawBytes = utf8.encode(jsonEncode(payload));
    final originalSize = rawBytes.length;

    if (originalSize < config.minBytesForCompression) {
      return CompressedPayload(
        atomicId: atomicId,
        encoding: 'identity',
        bytes: rawBytes,
        originalSize: originalSize,
        compressedSize: originalSize,
        compressionLoops: 0,
        timestamp: DateTime.now().toUtc(),
        sessionId: sessionId,
        deviceContext: deviceContext,
      );
    }

    var currentBytes = rawBytes;
    var loops = 0;

    for (var i = 0; i < config.maxCompressionLoops; i++) {
      final candidate = gzip.encode(currentBytes);
      loops += 1;

      if (candidate.length >= currentBytes.length) {
        break;
      }

      currentBytes = candidate;

      final score = 1.0 - (currentBytes.length / originalSize);
      if (score >= config.optimalTarget) {
        break;
      }
    }

    return CompressedPayload(
      atomicId: atomicId,
      encoding: 'gzip',
      bytes: currentBytes,
      originalSize: originalSize,
      compressedSize: currentBytes.length,
      compressionLoops: loops,
      timestamp: DateTime.now().toUtc(),
      sessionId: sessionId,
      deviceContext: deviceContext,
    );
  }

  Future<void> runCompressionLoop({
    required List<Map<String, dynamic>> payloads,
    required Future<void> Function(CompressedPayload payload) onCompressed,
    String? sessionId,
    DeviceCompressionContext? deviceContext,
  }) async {
    for (final payload in payloads) {
      final compressed = await compressJsonPayload(
        payload,
        sessionId: sessionId,
        deviceContext: deviceContext,
      );
      await onCompressed(compressed);
    }
  }

  bool validateConformance(CompressedPayload payload) {
    return payload.conformanceScore >= config.floorBoundary &&
        payload.conformanceScore <= config.ceilingBoundary;
  }
}
