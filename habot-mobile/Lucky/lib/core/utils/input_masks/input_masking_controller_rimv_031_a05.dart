// RIMV-031-A05 — Input Masking Constraint Infrastructure Controller.
// Provides atomic-level text input masking, validation hooks, and Material 3 visual feedback for Flutter TextField widgets.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Execution status tracking for telemetry and logging pipelines.
enum MaskExecutionStatus { idle, validating, passed, failed }

/// Data object capturing atomic execution metrics per requirement spec.
class MaskExecutionRecord {
  final String stepExecutionId;
  final MaskExecutionStatus status;
  final DateTime timestamp;
  final String outcome;
  final String? userId;

  const MaskExecutionRecord({
    required this.stepExecutionId,
    required this.status,
    required this.timestamp,
    required this.outcome,
    this.userId,
  });

  Map<String, dynamic> toJson() => {
        'step_execution_id': stepExecutionId,
        'execution_status': status.name,
        'execution_timestamp': timestamp.toIso8601String(),
        'step_outcome': outcome,
        'user_id': userId ?? 'anonymous',
      };
}

/// Core controller implementing useInputMasking hook equivalent in Flutter.
/// Intercepts invalid text inputs instantaneously prior to character rendering.
class InputMaskingController extends ChangeNotifier {
  final RegExp _maskPattern;
  final TextInputType _keyboardType;
  final List<TextInputFormatter> _additionalFormatters;

  MaskExecutionStatus _currentStatus = MaskExecutionStatus.idle;
  String? _errorMessage;
  bool _isCtaLocked = false;
  final List<MaskExecutionRecord> _executionLog = [];

  InputMaskingController({
    required RegExp maskPattern,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter> additionalFormatters = const [],
  })  : _maskPattern = maskPattern,
        _keyboardType = keyboardType,
        _additionalFormatters = additionalFormatters;

  MaskExecutionStatus get currentStatus => _currentStatus;
  String? get errorMessage => _errorMessage;
  bool get isCtaLocked => _isCtaLocked;
  TextInputType get keyboardType => _keyboardType;
  List<MaskExecutionRecord> get executionLog => List.unmodifiable(_executionLog);

  /// Generates the complete list of formatters including the core mask constraint.
  List<TextInputFormatter> get formatters {
    return [
      FilteringTextInputFormatter.allow(_maskPattern),
      ..._additionalFormatters,
    ];
  }

  /// Validates current input against the mask pattern.
  /// Updates CTA lock state and logs execution metrics.
  void validate(String input, {String? userId}) {
    _currentStatus = MaskExecutionStatus.validating;
    notifyListeners();

    final bool isValid = _maskPattern.hasMatch(input) || input.isEmpty;
    final String executionId = 'RIMV-031-A05-${DateTime.now().millisecondsSinceEpoch}';

    if (isValid) {
      _currentStatus = MaskExecutionStatus.passed;
      _errorMessage = null;
      _isCtaLocked = input.isEmpty; // Lock CTA if empty, unlock if valid
      _logExecution(
        id: executionId,
        status: MaskExecutionStatus.passed,
        outcome: 'Input conforms to mask formula.',
        userId: userId,
      );
    } else {
      _currentStatus = MaskExecutionStatus.failed;
      _errorMessage = 'Invalid format. Please check your input.';
      _isCtaLocked = true; // Insulate backend from dirty submissions
      _logExecution(
        id: executionId,
        status: MaskExecutionStatus.failed,
        outcome: 'Input rejected by mask constraint.',
        userId: userId,
      );
    }

    notifyListeners();
  }

  void _logExecution({
    required String id,
    required MaskExecutionStatus status,
    required String outcome,
    String? userId,
  }) {
    _executionLog.add(MaskExecutionRecord(
      stepExecutionId: id,
      status: status,
      timestamp: DateTime.now(),
      outcome: outcome,
      userId: userId,
    ));
    // Radical cleanup: prevent unbounded memory growth in logging pipeline
    if (_executionLog.length > 100) {
      _executionLog.removeRange(0, _executionLog.length - 100);
    }
  }

  /// Resets validation states programmatically.
  void reset() {
    _currentStatus = MaskExecutionStatus.idle;
    _errorMessage = null;
    _isCtaLocked = false;
    notifyListeners();
  }
}

/// Material 3 compliant TextField wrapper utilizing the InputMaskingController.
/// Implements distinct visual validation highlights, error presentation tracks,
/// and programmatic focus border tone swapping.
class MaskedTextField extends StatefulWidget {
  final InputMaskingController controller;
  final TextEditingController textEditingController;
  final String label;
  final String? hintText;
  final String? userId;
  final ValueChanged<String>? onChanged;

  const MaskedTextField({
    super.key,
    required this.controller,
    required this.textEditingController,
    required this.label,
    this.hintText,
    this.userId,
    this.onChanged,
  });

  @override
  State<MaskedTextField> createState() => _MaskedTextFieldState();
}

class _MaskedTextFieldState extends State<MaskedTextField> {
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    widget.controller.addListener(_onControllerChanged);
    widget.textEditingController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    widget.textEditingController.removeListener(_onTextChanged);
    _focusNode.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  void _onTextChanged() {
    widget.controller.validate(
      widget.textEditingController.text,
      userId: widget.userId,
    );
    widget.onChanged?.call(widget.textEditingController.text);
  }

  Color _getBorderColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (widget.controller.currentStatus) {
      case MaskExecutionStatus.failed:
        return colorScheme.error;
      case MaskExecutionStatus.passed:
        return colorScheme.primary;
      case MaskExecutionStatus.validating:
        return colorScheme.tertiary;
      case MaskExecutionStatus.idle:
      default:
        return colorScheme.outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: widget.textEditingController,
          focusNode: _focusNode,
          keyboardType: widget.controller.keyboardType,
          inputFormatters: widget.controller.formatters,
          style: theme.textTheme.bodyMedium, // Material 3 bodyMedium typography
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: _getBorderColor(context)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(
                color: _getBorderColor(context),
                width: 2.0,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: theme.colorScheme.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: theme.colorScheme.error, width: 2.0),
            ),
            // Distinct visual validation highlights inside form bounding borders
            suffixIcon: widget.controller.currentStatus == MaskExecutionStatus.passed &&
                    widget.textEditingController.text.isNotEmpty
                ? Icon(Icons.check_circle_outline, color: theme.colorScheme.primary)
                : widget.controller.currentStatus == MaskExecutionStatus.failed
                    ? Icon(Icons.error_outline, color: theme.colorScheme.error)
                    : null,
          ),
        ),
        // Clear error presentation tracks below active text regions
        if (widget.controller.errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 4.0, left: 16.0),
            child: Text(
              widget.controller.errorMessage!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
      ],
    );
  }
}

/// Factory utility to generate common masking controllers based on semantic types.
class InputMaskFactory {
  InputMaskFactory._();

  /// Numeric only mask (e.g., phone numbers, OTPs).
  static InputMaskingController numericOnly() {
    return InputMaskingController(
      maskPattern: RegExp(r'[0-9]'),
      keyboardType: TextInputType.number,
    );
  }

  /// Alpha-numeric mask without special characters.
  static InputMaskingController alphaNumeric() {
    return InputMaskingController(
      maskPattern: RegExp(r'[a-zA-Z0-9]'),
      keyboardType: TextInputType.text,
    );
  }

  /// Email mask allowing standard email characters.
  static InputMaskingController email() {
    return InputMaskingController(
      maskPattern: RegExp(r"[a-zA-Z0-9._%+-@]"),
      keyboardType: TextInputType.emailAddress,
    );
  }

  /// Custom regex mask.
  static InputMaskingController custom({
    required RegExp pattern,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return InputMaskingController(
      maskPattern: pattern,
      keyboardType: keyboardType,
    );
  }
}

/// Mock telemetry repository for local testing and schema validation.
class MockTelemetryRepository {
  static final List<Map<String, dynamic>> _mockQueue = [];

  static void ingest(MaskExecutionRecord record) {
    _mockQueue.add(record.toJson());
    // Prevents downstream schema execution exceptions across message ingestion queues
  }

  static List<Map<String, dynamic>> get queue => List.unmodifiable(_mockQueue);

  static void clear() => _mockQueue.clear();
}
