// FLADE-006-04 — Rapid Backtracking Tracking on Mobile Forms + Date Slash Injection.
// Detects rapid deletions (>5 chars within 1s) with throttled telemetry dispatch and auto MM/DD/YYYY slash injection.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Config for FLADE-006-04 rapid-deletion threshold.
class RapidBacktrackingConfig {
  const RapidBacktrackingConfig({
    this.definitionName = 'rapid_backtracking',
    this.definitionType = 'mobile_form_telemetry',
    this.definitionId = 'FLADE-006-04',
    this.thresholdChars = 5,
    this.window = const Duration(seconds: 1),
    this.throttleInterval = const Duration(seconds: 2),
    this.definitionParameters = const <String, Object>{'windowMs': 1000, 'thresholdChars': 5},
  });
  final String definitionName;
  final String definitionType;
  final String definitionId;
  final int thresholdChars;
  final Duration window;
  final Duration throttleInterval;
  final Map<String, Object> definitionParameters;
}

enum ValidationStatus { pending, valid, invalid }
enum CompletionQuality { good, average, poor }

/// Atomic-level telemetry event for FLADE-006-04.
class BacktrackingTelemetryEvent {
  const BacktrackingTelemetryEvent({
    required this.definitionName,
    required this.definitionParameters,
    required this.definitionType,
    required this.validationStatus,
    required this.definitionId,
    required this.completionStatus,
    required this.timestamp,
    required this.sessionId,
    required this.fieldId,
    required this.deletedChars,
    required this.windowMs,
    this.routeName,
  });
  final String definitionName;
  final Map<String, Object> definitionParameters;
  final String definitionType;
  final String validationStatus;
  final String definitionId;
  final String completionStatus;
  final DateTime timestamp;
  final String sessionId;
  final String fieldId;
  final int deletedChars;
  final int windowMs;
  final String? routeName;
  Map<String, Object?> toJson() => <String, Object?>{
    'definitionName': definitionName,
    'definitionParameters': definitionParameters,
    'definitionType': definitionType,
    'validationStatus': validationStatus,
    'definitionId': definitionId,
    'completionStatus': completionStatus,
    'timestamp': timestamp.toIso8601String(),
    'sessionId': sessionId,
    'fieldId': fieldId,
    'deletedChars': deletedChars,
    'windowMs': windowMs,
    'routeName': routeName,
  };
}

/// Sink to forward events to analytics / data engineering pipeline.
typedef BacktrackingTelemetrySink = void Function(BacktrackingTelemetryEvent event);

/// Throttled dispatcher to avoid mobile network flooding.
class ThrottledTelemetryDispatcher {
  ThrottledTelemetryDispatcher({required this.sink, this.minInterval = const Duration(seconds: 2)});
  final BacktrackingTelemetrySink sink;
  final Duration minInterval;
  final Map<String, DateTime> _lastSentByField = {};
  bool shouldSend(String fieldId, DateTime now) {
    final DateTime? last = _lastSentByField[fieldId];
    if (last == null || now.difference(last) >= minInterval) return true;
    return false;
  }
  void dispatch(BacktrackingTelemetryEvent event) {
    if (!shouldSend(event.fieldId, event.timestamp)) return;
    _lastSentByField[event.fieldId] = event.timestamp;
    sink(event);
  }
  void reset() => _lastSentByField.clear();
}

/// Tracks a single [TextEditingController] for rapid backtracking.
/// Flutter equivalent of onKeyDown synthetic tracking + React-hooks input state.
class RapidBacktrackingTracker {
  RapidBacktrackingTracker({
    required this.controller,
    required this.fieldId,
    required this.config,
    required this.dispatcher,
    required this.sessionId,
    this.routeName,
    this.onRapidDeletion,
  });
  final TextEditingController controller;
  final String fieldId;
  final RapidBacktrackingConfig config;
  final ThrottledTelemetryDispatcher dispatcher;
  final String sessionId;
  final String? routeName;
  final ValueChanged<BacktrackingTelemetryEvent>? onRapidDeletion;
  String _prevText = '';
  final List<DateTime> _deletionStamps = <DateTime>[];
  final List<int> _deletionSizes = <int>[];
  bool _attached = false;
  void attach() {
    if (_attached) return;
    _prevText = controller.text;
    controller.addListener(_onChanged);
    _attached = true;
  }
  void detach() {
    if (!_attached) return;
    controller.removeListener(_onChanged);
    _attached = false;
  }
  void _onChanged() {
    final String next = controller.text;
    final DateTime now = DateTime.now();
    if (next.length < _prevText.length) {
      final int deleted = _prevText.length - next.length;
      _deletionStamps.add(now);
      _deletionSizes.add(deleted);
      _prune(now);
      final int sum = _deletionSizes.fold<int>(0, (a, b) => a + b);
      if (sum > config.thresholdChars) {
        final BacktrackingTelemetryEvent event = BacktrackingTelemetryEvent(
          definitionName: config.definitionName,
          definitionParameters: <String, Object>{...config.definitionParameters, 'fieldId': fieldId},
          definitionType: config.definitionType,
          validationStatus: ValidationStatus.pending.name,
          definitionId: config.definitionId,
          completionStatus: CompletionQuality.good.name,
          timestamp: now,
          sessionId: sessionId,
          fieldId: fieldId,
          deletedChars: sum,
          windowMs: config.window.inMilliseconds,
          routeName: routeName,
        );
        dispatcher.dispatch(event);
        onRapidDeletion?.call(event);
        _deletionStamps.clear();
        _deletionSizes.clear();
      }
    } else if (next.length > _prevText.length) {
      _prune(now);
    }
    _prevText = next;
  }
  void _prune(DateTime now) {
    while (_deletionStamps.isNotEmpty && now.difference(_deletionStamps.first) > config.window) {
      _deletionStamps.removeAt(0);
      _deletionSizes.removeAt(0);
    }
  }
}

/// Automatic date slash injection: digits `12012026` -> `12/01/2026`.
/// Handles MM/DD/YYYY with smart slash insert, delete, and paste.
class DateSlashInjectionFormatter extends TextInputFormatter {
  const DateSlashInjectionFormatter({this.maxLength = 10});
  final int maxLength;
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final String digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    final String clipped = digits.length > 8 ? digits.substring(0, 8) : digits;
    final StringBuffer buf = StringBuffer();
    for (int i = 0; i < clipped.length; i++) {
      buf.write(clipped[i]);
      if ((i == 1 || i == 3) && i != clipped.length - 1) buf.write('/');
    }
    final String formatted = buf.toString();
    return TextEditingValue(text: formatted, selection: TextSelection.collapsed(offset: formatted.length));
  }
  static String? validate(String? value) {
    if (value == null || value.isEmpty) return 'Date is required';
    if (!RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(value)) return 'Use MM/DD/YYYY';
    final List<String> p = value.split('/');
    final int m = int.tryParse(p[0]) ?? 0;
    final int d = int.tryParse(p[1]) ?? 0;
    if (m < 1 || m > 12) return 'Invalid month';
    if (d < 1 || d > 31) return 'Invalid day';
    return null;
  }
}

/// Invisible telemetry overlay — provides session + dispatcher without affecting layout.
class BacktrackingTelemetryScope extends InheritedWidget {
  const BacktrackingTelemetryScope({super.key, required this.sessionId, required this.dispatcher, required this.config, required super.child});
  final String sessionId;
  final ThrottledTelemetryDispatcher dispatcher;
  final RapidBacktrackingConfig config;
  static BacktrackingTelemetryScope? of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<BacktrackingTelemetryScope>();
  @override
  bool updateShouldNotify(BacktrackingTelemetryScope oldWidget) => sessionId != oldWidget.sessionId;
}

class RapidBacktrackingTelemetryOverlay extends StatelessWidget {
  const RapidBacktrackingTelemetryOverlay({super.key, required this.sessionId, required this.child, this.config = const RapidBacktrackingConfig(), BacktrackingTelemetrySink? sink, this.throttleInterval = const Duration(seconds: 2)});
  final String sessionId;
  final Widget child;
  final RapidBacktrackingConfig config;
  final BacktrackingTelemetrySink? sink;
  final Duration throttleInterval;
  @override
  Widget build(BuildContext context) {
    return BacktrackingTelemetryScope(
      sessionId: sessionId,
      config: config,
      dispatcher: ThrottledTelemetryDispatcher(sink: sink ?? (_) {}, minInterval: throttleInterval),
      child: child,
    );
  }
}

/// Drop-in Material 3 field with rapid-backtracking tracking + optional date mask.
class TrackedTextFormField extends StatefulWidget {
  const TrackedTextFormField({super.key, required this.fieldId, this.controller, this.labelText, this.hintText, this.enableDateMask = false, this.keyboardType, this.validator, this.onRapidDeletion});
  final String fieldId;
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final bool enableDateMask;
  final TextInputType? keyboardType;
  final FormFieldValidator<String>? validator;
  final ValueChanged<BacktrackingTelemetryEvent>? onRapidDeletion;
  @override
  State<TrackedTextFormField> createState() => _TrackedTextFormFieldState();
}

class _TrackedTextFormFieldState extends State<TrackedTextFormField> {
  TextEditingController? _internal;
  RapidBacktrackingTracker? _tracker;
  TextEditingController get _effective => widget.controller ?? _internal!;
  @override
  void initState() {
    super.initState();
    if (widget.controller == null) _internal = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bind());
  }
  void _bind() {
    final BacktrackingTelemetryScope? scope = BacktrackingTelemetryScope.of(context);
    final RapidBacktrackingConfig cfg = scope?.config ?? const RapidBacktrackingConfig();
    final ThrottledTelemetryDispatcher disp = scope?.dispatcher ?? ThrottledTelemetryDispatcher(sink: (_) {});
    final String sid = scope?.sessionId ?? 'anonymous';
    _tracker?.detach();
    _tracker = RapidBacktrackingTracker(controller: _effective, fieldId: widget.fieldId, config: cfg, dispatcher: disp, sessionId: sid, routeName: ModalRoute.of(context)?.settings.name, onRapidDeletion: widget.onRapidDeletion);
    _tracker!.attach();
  }
  @override
  void didUpdateWidget(TrackedTextFormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _tracker?.detach();
      _tracker = null;
      if (oldWidget.controller == null) _internal?.dispose();
      if (widget.controller == null) _internal = TextEditingController();
      _bind();
    }
  }
  @override
  void dispose() {
    _tracker?.detach();
    _internal?.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _effective,
      keyboardType: widget.enableDateMask ? TextInputType.datetime : widget.keyboardType,
      inputFormatters: <TextInputFormatter>[if (widget.enableDateMask) const DateSlashInjectionFormatter()],
      validator: widget.enableDateMask ? (v) => DateSlashInjectionFormatter.validate(v) : widget.validator,
      decoration: InputDecoration(labelText: widget.labelText, hintText: widget.enableDateMask ? 'MM/DD/YYYY' : widget.hintText, border: const OutlineInputBorder()),
    );
  }
}
