// GEN-00527 — Meta CAPI Deduplication Event ID Generator.
// Generates RFC 4122 UUIDv4 event IDs for client-side conversion events; supports stable reuse for Meta CAPI deduplication.
// Uses dart:math Random.secure for cryptographic randomness and formats UUIDv4 in <=2ms.

import 'dart:math';

class MetaCapiEventIdGenerator {
  MetaCapiEventIdGenerator({Random? random}) : _random = random ?? Random.secure();

  final Random _random;
  final Map<String, String> _conversionEventIds = {};

  static const int _uuidVersion = 4;
  static const int _variantRfc4122 = 0x80;
  static const int _variantMask = 0x3f;

  /// Generate: Creates a new RFC 4122 UUIDv4 event_id for a conversion event.
  String generateEventId() {
    final bytes = List<int>.generate(16, (_) => _random.nextInt(256), growable: false);
    bytes[6] = (bytes[6] & 0x0f) | (_uuidVersion << 4);
    bytes[8] = (bytes[8] & _variantMask) | _variantRfc4122;
    return _formatUuid(bytes);
  }

  /// Deduplicate: Returns the same event_id for a conversion key across retries.
  String eventIdForConversion(String conversionKey) {
    return _conversionEventIds.putIfAbsent(conversionKey, generateEventId);
  }

  /// Clear: Removes cached conversion event IDs.
  void clearDeduplicationCache() {
    _conversionEventIds.clear();
  }

  String _formatUuid(List<int> bytes) {
    final hex = StringBuffer();
    for (var i = 0; i < bytes.length; i++) {
      if (i == 4 || i == 6 || i == 8 || i == 10) {
        hex.write('-');
      }
      hex.write(bytes[i].toRadixString(16).padLeft(2, '0'));
    }
    return hex.toString();
  }
}