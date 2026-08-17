import 'package:uuid/uuid.dart';

// MCIIM-013-10 — BytId: UUID generator for Byt component identifiers.
// Spec: "Configure mobile client state managers to bind UI components
//        using React keys or Compose IDs derived from UUIDs."
//
// In Flutter, this maps to:
//   ValueKey(BytId.generate())  →  stable widget identity across rebuilds
//   ObjectKey(byt)              →  identity via object reference
//
// Rule: every Byt (document, card, list item) gets a UUID on creation.
//       The UUID never changes for the lifetime of that Byt.

const _uuid = Uuid();

abstract class BytId {
  BytId._();

  /// Generate a new v4 UUID string.
  /// Use as the id field when creating any Byt model.
  static String generate() => _uuid.v4();

  /// Create a stable Flutter ValueKey from a UUID string.
  /// Use as key: on any stateful widget that represents a Byt.
  static ValueKey<String> key(String id) => ValueKey<String>(id);

  /// Validate that a string is a well-formed UUID v4.
  static bool isValid(String id) {
    final pattern = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
      caseSensitive: false,
    );
    return pattern.hasMatch(id);
  }
}
