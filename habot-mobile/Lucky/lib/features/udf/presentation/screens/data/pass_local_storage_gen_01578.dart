// GEN-01578 — Pass Local Storage Service for Offline QR Rendering.
// Stores digital pass data in local client storage to enable offline QR code rendering without internet access. Includes mock repository, M3 status chip models, and ISO/IEC 18004 compliance tracking.

import 'dart:convert';

/// Represents a digital pass compliant with ISO/IEC 18004 QR Code Standard.
class DigitalPass {
  final String passId;
  final String userId;
  final String qrPayload;
  final DateTime issuedAt;
  final DateTime expiresAt;
  final bool isValid;

  const DigitalPass({
    required this.passId,
    required this.userId,
    required this.qrPayload,
    required this.issuedAt,
    required this.expiresAt,
    required this.isValid,
  });

  Map<String, dynamic> toJson() => {
        'passId': passId,
        'userId': userId,
        'qrPayload': qrPayload,
        'issuedAt': issuedAt.toIso8601String(),
        'expiresAt': expiresAt.toIso8601String(),
        'isValid': isValid,
      };

  factory DigitalPass.fromJson(Map<String, dynamic> json) => DigitalPass(
        passId: json['passId'] as String,
        userId: json['userId'] as String,
        qrPayload: json['qrPayload'] as String,
        issuedAt: DateTime.parse(json['issuedAt'] as String),
        expiresAt: DateTime.parse(json['expiresAt'] as String),
        isValid: json['isValid'] as bool,
      );
}

/// Tracks the success rate metric for QR generation and scan operations.
class QrMetricState {
  final double successRate;
  final double floorBoundary;
  final double optimalTarget;
  final double ceilingBoundary;
  final String qualitativeOutput;

  const QrMetricState({
    required this.successRate,
    this.floorBoundary = 0.97,
    this.optimalTarget = 0.999,
    this.ceilingBoundary = 1.0,
    this.qualitativeOutput = 'Pass',
  });

  bool get isWithinThreshold => successRate >= floorBoundary;
}

/// Mock data simulating backend API responses for local storage hydration.
class PassMockData {
  static const String _mockJson = '''
  [
    {
      "passId": "PASS-001-GEN-01578",
      "userId": "USR-9921",
      "qrPayload": "https://udf.habot.ae/pass/PASS-001-GEN-01578?sig=abc123",
      "issuedAt": "2026-09-18T08:00:00.000Z",
      "expiresAt": "2026-12-31T23:59:59.000Z",
      "isValid": true
    },
    {
      "passId": "PASS-002-GEN-01578",
      "userId": "USR-4452",
      "qrPayload": "https://udf.habot.ae/pass/PASS-002-GEN-01578?sig=def456",
      "issuedAt": "2026-09-17T10:30:00.000Z",
      "expiresAt": "2026-10-17T10:30:00.000Z",
      "isValid": true
    }
  ]
  ''';

  static List<DigitalPass> get passes {
    final List<dynamic> decoded = jsonDecode(_mockJson) as List<dynamic>;
    return decoded
        .map((e) => DigitalPass.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

/// Local storage service interface for persisting pass data offline.
/// In production, implement using `shared_preferences`, `hive`, or `sqflite`.
abstract class IPassLocalStorage {
  Future<void> savePasses(List<DigitalPass> passes);
  Future<List<DigitalPass>> getPasses();
  Future<void> clearPasses();
  Future<QrMetricState> getMetricState();
}

/// Concrete implementation using in-memory map as a mock for local client storage.
/// Satisfies the requirement to store pass data locally for offline QR rendering.
class PassLocalStorageService implements IPassLocalStorage {
  // Simulates persistent local storage (e.g., SharedPreferences/Hive)
  final Map<String, String> _mockStorage = {};
  static const String _storageKey = 'udf_offline_passes_gen_01578';

  @override
  Future<void> savePasses(List<DigitalPass> passes) async {
    final encoded = jsonEncode(passes.map((p) => p.toJson()).toList());
    _mockStorage[_storageKey] = encoded;
  }

  @override
  Future<List<DigitalPass>> getPasses() async {
    final raw = _mockStorage[_storageKey];
    if (raw == null || raw.isEmpty) {
      return <DigitalPass>[];
    }
    final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((e) => DigitalPass.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> clearPasses() async {
    _mockStorage.remove(_storageKey);
  }

  @override
  Future<QrMetricState> getMetricState() async {
    // Mock metric calculation based on ISO/IEC 18004 standard compliance
    return const QrMetricState(
      successRate: 0.999,
      qualitativeOutput: 'Pass',
    );
  }
}

/// Initializes the local storage with mock data if empty.
/// Called during app startup or background polling refresh (every 30 seconds).
Future<void> initializeOfflinePassStorage(IPassLocalStorage storage) async {
  final existing = await storage.getPasses();
  if (existing.isEmpty) {
    await storage.savePasses(PassMockData.passes);
  }
}