import 'package:flutter/foundation.dart';
import 'byt_id.dart';

// MCIIM-013-10 — BytState: base state mixin carrying a stable UUID.
// Spec: "bind UI components using IDs derived from UUIDs"
//
// Usage — any model / state object that represents a Byt:
// ```dart
// class DocumentByt with BytState {
//   DocumentByt({String? id, required this.title})
//       : bytId = id ?? BytId.generate();
//
//   @override
//   final String bytId;
//   final String title;
// }
// ```
//
// Then in widget tree:
// ```dart
// BytCard(key: BytId.key(doc.bytId), byt: doc)
// ```

// ── Mixin ─────────────────────────────────────────────────────────────────────

mixin BytState {
  /// Stable UUID — never changes after creation.
  String get bytId;

  /// Flutter ValueKey derived from UUID — use as widget key.
  ValueKey<String> get bytKey => BytId.key(bytId);
}

// ── ChangeNotifier state base ─────────────────────────────────────────────────

/// Base ChangeNotifier for any Byt that needs reactive state.
/// Carries a stable UUID and tracks dirty/clean state.
///
/// Usage:
/// ```dart
/// class DocumentBytNotifier extends BytNotifier {
///   DocumentBytNotifier({required this.title})
///       : super(id: BytId.generate());
///   String title;
///   void updateTitle(String t) { title = t; markDirty(); }
/// }
/// ```
abstract class BytNotifier extends ChangeNotifier {
  BytNotifier({String? id}) : bytId = id ?? BytId.generate();

  /// Stable UUID identifying this Byt instance.
  final String bytId;

  bool _isDirty = false;

  /// True when state has changed since last clean.
  bool get isDirty => _isDirty;

  /// Mark state as changed — triggers notifyListeners().
  void markDirty() {
    _isDirty = true;
    notifyListeners();
  }

  /// Reset dirty flag — call after persisting state.
  void markClean() {
    _isDirty = false;
    notifyListeners();
  }

  /// Flutter ValueKey derived from UUID.
  ValueKey<String> get bytKey => BytId.key(bytId);
}

// ── Byt registry ──────────────────────────────────────────────────────────────

/// Tracks all active BytNotifiers by UUID.
/// Allows any part of the app to look up a Byt by ID.
class BytRegistry {
  BytRegistry._();
  static final BytRegistry instance = BytRegistry._();

  final Map<String, BytNotifier> _registry = {};

  void register(BytNotifier byt) => _registry[byt.bytId] = byt;
  void unregister(String id)      => _registry.remove(id);
  BytNotifier? find(String id)    => _registry[id];
  bool contains(String id)        => _registry.containsKey(id);
  int get count                   => _registry.length;

  /// All registered Byt IDs — useful for analytics.
  List<String> get allIds => List.unmodifiable(_registry.keys);
}
