// CPNCA-004 — FrictionLog input telemetry listeners for hesitation and backspace frequency.
// Wraps TextField with lightweight focus, pointer hold, and deletion tracking; emits batched events without coupling to MD3 rendering.

import 'dart:async';
import 'package:flutter/material.dart';

class Cpnca004FrictionEvent {
  final String fieldId;
  final String type;
  final int timestampMs;
  final Map<String, Object?> payload;
  const Cpnca004FrictionEvent({required this.fieldId, required this.type, required this.timestampMs, this.payload = const {}});
  Map<String, Object?> toJson() => {'fieldId': fieldId, 'type': type, 'timestampMs': timestampMs, 'payload': payload};
}

typedef Cpnca004FrictionBatchCallback = void Function(List<Cpnca004FrictionEvent> events);

class Cpnca004FrictionLogInput extends StatefulWidget {
  final String fieldId;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String? labelText;
  final String? hintText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Cpnca004FrictionBatchCallback? onBatch;
  final Duration batchInterval;
  final int hesitationThresholdMs;
  const Cpnca004FrictionLogInput({super.key, required this.fieldId, required this.controller, this.focusNode, this.labelText, this.hintText, this.obscureText = false, this.keyboardType, this.onBatch, this.batchInterval = const Duration(seconds: 5), this.hesitationThresholdMs = 1500});
  @override State<Cpnca004FrictionLogInput> createState() => _Cpnca004FrictionLogInputState();
}

class _Cpnca004FrictionLogInputState extends State<Cpnca004FrictionLogInput> {
  late FocusNode _focusNode;
  bool _ownsFocus = false;
  int _previousLength = 0;
  int _backspaceCount = 0;
  int? _focusStartMs;
  int? _lastChangeMs;
  int? _pointerDownMs;
  Timer? _timer;
  final List<Cpnca004FrictionEvent> _batch = [];

  @override void initState() { super.initState(); _focusNode = widget.focusNode ?? FocusNode(); _ownsFocus = widget.focusNode == null; _previousLength = widget.controller.text.length; _focusNode.addListener(_onFocusChanged); widget.controller.addListener(_onTextChanged); _timer = Timer.periodic(widget.batchInterval, (_) => _flush()); }

  @override void dispose() { _timer?.cancel(); _focusNode.removeListener(_onFocusChanged); widget.controller.removeListener(_onTextChanged); if (_ownsFocus) _focusNode.dispose(); _flush(); super.dispose(); }

  void _onFocusChanged() { final now = DateTime.now().millisecondsSinceEpoch; if (_focusNode.hasFocus) { _focusStartMs = now; _lastChangeMs = now; _enqueue('focus', {'holdStartMs': now}); } else { if (_focusStartMs != null) { _enqueue('blur', {'focusDurationMs': now - _focusStartMs!}); } _focusStartMs = null; _flush(); } }

  void _onTextChanged() { final now = DateTime.now().millisecondsSinceEpoch; final currentLength = widget.controller.text.length; if (currentLength < _previousLength) { final removed = _previousLength - currentLength; _backspaceCount += removed; _enqueue('backspace', {'removed': removed, 'totalBackspaces': _backspaceCount}); } if (_lastChangeMs != null && now - _lastChangeMs! >= widget.hesitationThresholdMs) { _enqueue('hesitation', {'pauseMs': now - _lastChangeMs!}); } _lastChangeMs = now; _previousLength = currentLength; }

  void _onPointerDown(PointerDownEvent event) { _pointerDownMs = DateTime.now().millisecondsSinceEpoch; }

  void _onPointerUp(PointerUpEvent event) { final now = DateTime.now().millisecondsSinceEpoch; if (_pointerDownMs != null) { _enqueue('touchHold', {'holdMs': now - _pointerDownMs!, 'pointer': event.kind.name}); } _pointerDownMs = null; }

  void _enqueue(String type, Map<String, Object?> payload) { _batch.add(Cpnca004FrictionEvent(fieldId: widget.fieldId, type: type, timestampMs: DateTime.now().millisecondsSinceEpoch, payload: payload)); if (_batch.length >= 20) { _flush(); } }

  void _flush() { if (_batch.isEmpty) { return; } final events = List<Cpnca004FrictionEvent>.unmodifiable(_batch); _batch.clear(); widget.onBatch?.call(events); }

  @override Widget build(BuildContext context) { return Listener(onPointerDown: _onPointerDown, onPointerUp: _onPointerUp, child: TextField(controller: widget.controller, focusNode: _focusNode, obscureText: widget.obscureText, keyboardType: widget.keyboardType, decoration: InputDecoration(labelText: widget.labelText, hintText: widget.hintText, border: const OutlineInputBorder()))); }
}
