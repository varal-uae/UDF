import 'package:flutter/material.dart';

// FIEVR-032-A01 — Form Error Focus Engine.
// Auto-scrolls the viewport to the first invalid field on form submission.
// Binds error warning flags to matching field container instances.
// Locks horizontal/vertical viewport offsets relative to display rim.
//
// Spec requirements:
//   - Map exact coordinate metrics for all required input fields
//   - Set fluid scroll velocity (calm, no rapid jumps)
//   - Bind error flags to matching container instances
//   - Lock viewport offsets to keep top header rows clear
//   - Submission stays locked until all fields satisfy structural criteria

// ─── FIELD REGISTRATION ───────────────────────────────────────────────────────

/// Registered field entry — holds key + validation state.
class _FieldEntry {
  _FieldEntry({required this.key, required this.fieldKey});
  final GlobalKey key;
  final String fieldKey;
  bool hasError = false;
  String? errorText;
}

// ─── FORM ERROR FOCUS ENGINE ─────────────────────────────────────────────────

class FormErrorFocusEngine {
  FormErrorFocusEngine({
    required this.scrollController,
    /// Offset from top of viewport — keeps header rows clear of text lines.
    this.topHeaderOffset = 80.0,
    /// Scroll duration — calm, restricted to prevent rapid layout jumps.
    this.scrollDuration = const Duration(milliseconds: 450),
    /// Scroll curve — ease in/out for fluid motion, no disorientation.
    this.scrollCurve = Curves.easeInOutCubic,
  });

  final ScrollController scrollController;
  final double topHeaderOffset;
  final Duration scrollDuration;
  final Curve scrollCurve;

  final List<_FieldEntry> _fields = [];

  /// Register a field with the engine.
  /// Call once per field in the form — order determines scroll priority.
  GlobalKey register(String fieldKey) {
    final key = GlobalKey();
    _fields.add(_FieldEntry(key: key, fieldKey: fieldKey));
    return key;
  }

  /// Mark a field as having an error.
  void setError(String fieldKey, String? errorText) {
    final entry = _entryFor(fieldKey);
    if (entry == null) return;
    entry.hasError   = errorText != null;
    entry.errorText  = errorText;
  }

  /// Clear error for a field.
  void clearError(String fieldKey) => setError(fieldKey, null);

  /// Clear all errors.
  void clearAll() {
    for (final f in _fields) {
      f.hasError  = false;
      f.errorText = null;
    }
  }

  /// Returns true if all fields are valid — submission gate.
  /// Spec: submission triggers stay physically locked until all fields pass.
  bool get isValid => _fields.every((f) => !f.hasError);

  /// Returns list of field keys that currently have errors.
  List<String> get errorFields =>
      _fields.where((f) => f.hasError).map((f) => f.fieldKey).toList();

  /// Scrolls to the first invalid field.
  /// Returns true if scroll was triggered, false if all fields are valid.
  Future<bool> scrollToFirstError(BuildContext context) async {
    final first = _fields.firstWhere(
      (f) => f.hasError,
      orElse: () => _FieldEntry(key: GlobalKey(), fieldKey: ''),
    );

    if (!first.hasError) return false;

    await _scrollToKey(first.key, context);
    return true;
  }

  /// Scrolls to a specific field by key.
  Future<void> scrollToField(String fieldKey, BuildContext context) async {
    final entry = _entryFor(fieldKey);
    if (entry == null) return;
    await _scrollToKey(entry.key, context);
  }

  Future<void> _scrollToKey(GlobalKey key, BuildContext context) async {
    final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    // Map exact coordinate metrics for the field.
    final position   = renderBox.localToGlobal(Offset.zero);
    final fieldTop   = position.dy;
    final scrollOffset = scrollController.offset +
        fieldTop -
        topHeaderOffset; // lock offset to keep header clear

    // Fluid scroll — calm velocity, no rapid jumps.
    await scrollController.animateTo(
      scrollOffset.clamp(0.0, scrollController.position.maxScrollExtent),
      duration: scrollDuration,
      curve:    scrollCurve,
    );
  }

  _FieldEntry? _entryFor(String fieldKey) {
    try {
      return _fields.firstWhere((f) => f.fieldKey == fieldKey);
    } catch (_) {
      return null;
    }
  }

  void dispose() => _fields.clear();
}
