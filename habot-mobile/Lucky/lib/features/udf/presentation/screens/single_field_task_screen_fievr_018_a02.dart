// FIEVR-018-A02 — Single-Field Focused Task Screen with Cropped Image Logic.
// Restricts form display strictly to the active field required for the task with an isolated image crop,
// preventing unauthorized data exposure and minimizing user cognitive load.

import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Supported layout types for the focused task screen.
enum LayoutType {
  compactColumn,
  splitHorizontal,
  adaptiveGrid,
}

/// Layout validation status tracking compliance and boundary checks.
enum LayoutValidationStatus {
  valid,
  invalidBoundary,
  unauthorizedField,
  error,
}

/// Alignment configuration for the single active field relative to the crop region.
enum FocusedAlignment {
  center,
  start,
  adjacentToCrop,
}

/// Spacing tokens following Material 3 guidelines.
class SpacingRules {
  final double contentPadding;
  final double elementSpacing;
  final double cropBorderRadius;

  const SpacingRules({
    this.contentPadding = 16.0,
    this.elementSpacing = 16.0,
    this.cropBorderRadius = 12.0,
  });
}

/// Normalized crop coordinates (0.0 to 1.0) defining the task-relevant image region.
class NormalizedCropBounds {
  final double x;
  final double y;
  final double width;
  final double height;

  const NormalizedCropBounds({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  })  : assert(x >= 0.0 && x <= 1.0),
        assert(y >= 0.0 && y <= 1.0),
        assert(width > 0.0 && width <= 1.0),
        assert(height > 0.0 && height <= 1.0);
}

/// Telemetry event emitted for layout and user interaction metrics.
class TaskTelemetryEvent {
  final String eventName;
  final String taskId;
  final String fieldKey;
  final String sessionId;
  final DateTime timestamp;
  final Duration? focusDelay;
  final Map<String, dynamic> metadata;

  const TaskTelemetryEvent({
    required this.eventName,
    required this.taskId,
    required this.fieldKey,
    required this.sessionId,
    required this.timestamp,
    this.focusDelay,
    this.metadata = const {},
  });
}

/// Controller orchestrating layout cropping logic, strict single-field boundary enforcement, and telemetry.
class SingleFieldTaskController extends ChangeNotifier {
  final String taskId;
  final String authorizedFieldKey;
  final String sessionId;
  final NormalizedCropBounds cropBounds;
  final ValueChanged<TaskTelemetryEvent>? onTelemetryLogged;

  String _currentValue = '';
  bool _isFocused = false;
  DateTime? _screenMountedAt;
  DateTime? _firstFocusAt;
  LayoutValidationStatus _validationStatus = LayoutValidationStatus.valid;
  String? _errorMessage;

  SingleFieldTaskController({
    required this.taskId,
    required this.authorizedFieldKey,
    required this.sessionId,
    required this.cropBounds,
    this.onTelemetryLogged,
  }) {
    _screenMountedAt = DateTime.now();
    _emitTelemetry('task_layout_initialized', {
      'layout_type': LayoutType.adaptiveGrid.name,
      'crop_bounds': {
        'x': cropBounds.x,
        'y': cropBounds.y,
        'w': cropBounds.width,
        'h': cropBounds.height,
      },
    });
  }

  String get currentValue => _currentValue;
  bool get isFocused => _isFocused;
  LayoutValidationStatus get validationStatus => _validationStatus;
  String? get errorMessage => _errorMessage;

  void recordFieldFocus() {
    if (_firstFocusAt == null) {
      _firstFocusAt = DateTime.now();
      final delay = _firstFocusAt!.difference(_screenMountedAt!);
      _emitTelemetry('field_focus_delayed', {}, delay);
    }
    _isFocused = true;
    notifyListeners();
  }

  void recordFieldBlur() {
    _isFocused = false;
    notifyListeners();
  }

  void updateFieldValue(String value, String fieldKey) {
    // Poka-Yoke: Fail-safe check against field manipulation
    if (fieldKey != authorizedFieldKey) {
      _validationStatus = LayoutValidationStatus.unauthorizedField;
      _errorMessage = 'Unauthorized field access blocked by security policy.';
      _emitTelemetry('security_violation_blocked', {'attempted_field': fieldKey});
      notifyListeners();
      return;
    }

    _currentValue = value;
    _validationStatus = LayoutValidationStatus.valid;
    _errorMessage = null;
    notifyListeners();
  }

  void submitField(VoidCallback onSuccess) {
    if (_currentValue.trim().isEmpty) {
      _validationStatus = LayoutValidationStatus.invalidBoundary;
      _errorMessage = 'Field value cannot be empty.';
      notifyListeners();
      return;
    }

    _emitTelemetry('field_submitted', {'length': _currentValue.length});
    onSuccess();
  }

  void _emitTelemetry(String eventName, Map<String, dynamic> meta, [Duration? focusDelay]) {
    final event = TaskTelemetryEvent(
      eventName: eventName,
      taskId: taskId,
      fieldKey: authorizedFieldKey,
      sessionId: sessionId,
      timestamp: DateTime.now(),
      focusDelay: focusDelay,
      metadata: meta,
    );
    onTelemetryLogged?.call(event);
  }
}

/// Custom clipper restricting the rendered document strictly to the target cropped coordinates.
class BoundedImageClipper extends CustomClipper<Rect> {
  final NormalizedCropBounds bounds;

  BoundedImageClipper({required this.bounds});

  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(
      size.width * bounds.x,
      size.height * bounds.y,
      size.width * bounds.width,
      size.height * bounds.height,
    );
  }

  @override
  bool shouldReclip(covariant BoundedImageClipper oldClipper) {
    return oldClipper.bounds.x != bounds.x ||
        oldClipper.bounds.y != bounds.y ||
        oldClipper.bounds.width != bounds.width ||
        oldClipper.bounds.height != bounds.height;
  }
}

/// Screen implementing FIEVR-018-A02: Strict single-field task execution with target image crop.
class SingleFieldTaskScreenFievr018A02 extends StatefulWidget {
  final SingleFieldTaskController controller;
  final String fieldLabel;
  final String fieldHint;
  final ImageProvider sourceImageProvider;
  final SpacingRules spacingRules;
  final VoidCallback onTaskCompleted;

  const SingleFieldTaskScreenFievr018A02({
    super.key,
    required this.controller,
    required this.fieldLabel,
    required this.sourceImageProvider,
    required this.onTaskCompleted,
    this.fieldHint = 'Enter active field value',
    this.spacingRules = const SpacingRules(),
  });

  @override
  State<SingleFieldTaskScreenFievr018A02> createState() =>
      _SingleFieldTaskScreenFievr018A02State();
}

class _SingleFieldTaskScreenFievr018A02State
    extends State<SingleFieldTaskScreenFievr018A02> {
  late final TextEditingController _textController;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.controller.currentValue);
    _focusNode = FocusNode();

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        widget.controller.recordFieldFocus();
      } else {
        widget.controller.recordFieldBlur();
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCompact = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: Text('Task ${widget.controller.taskId}'),
        centerTitle: false,
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: widget.controller,
          builder: (context, _) {
            if (widget.controller.validationStatus ==
                LayoutValidationStatus.unauthorizedField) {
              return _buildLockoutView(theme);
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                if (isCompact) {
                  return _buildCompactColumn(theme);
                } else {
                  return _buildSplitLayout(theme);
                }
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildCropViewport(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(widget.spacingRules.cropBorderRadius),
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
          width: 1.0,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: ClipRect(
        clipper: BoundedImageClipper(bounds: widget.controller.cropBounds),
        child: FittedBox(
          fit: BoxFit.contain,
          alignment: Alignment(
            (widget.controller.cropBounds.x * 2) - 1.0,
            (widget.controller.cropBounds.y * 2) - 1.0,
          ),
          child: Image(
            image: widget.sourceImageProvider,
            errorBuilder: (context, error, stackTrace) => Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.broken_image, color: theme.colorScheme.error),
                  const SizedBox(height: 8),
                  Text(
                    'Crop preview unavailable',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldInputBlock(ThemeData theme) {
    final isError = widget.controller.validationStatus ==
        LayoutValidationStatus.invalidBoundary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.fieldLabel,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _textController,
          focusNode: _focusNode,
          autofocus: true,
          decoration: InputDecoration(
            hintText: widget.fieldHint,
            filled: true,
            fillColor: theme.colorScheme.surfaceContainerLow,
            errorText: isError ? widget.controller.errorMessage : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: theme.colorScheme.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 2.0,
              ),
            ),
          ),
          onChanged: (val) => widget.controller.updateFieldValue(
            val,
            widget.controller.authorizedFieldKey,
          ),
          onSubmitted: (_) => widget.controller.submitField(widget.onTaskCompleted),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          icon: const Icon(Icons.check),
          label: const Text('Confirm & Advance'),
          onPressed: () => widget.controller.submitField(widget.onTaskCompleted),
        ),
      ],
    );
  }

  Widget _buildCompactColumn(ThemeData theme) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(widget.spacingRules.contentPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 240),
            child: _buildCropViewport(theme),
          ),
          SizedBox(height: widget.spacingRules.elementSpacing),
          _buildFieldInputBlock(theme),
        ],
      ),
    );
  }

  Widget _buildSplitLayout(ThemeData theme) {
    return Padding(
      padding: EdgeInsets.all(widget.spacingRules.contentPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 6,
            child: _buildCropViewport(theme),
          ),
          SizedBox(width: widget.spacingRules.elementSpacing),
          Expanded(
            flex: 4,
            child: Card(
              elevation: 0,
              color: theme.colorScheme.surfaceContainer,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: _buildFieldInputBlock(theme),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLockoutView(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_person, size: 64, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(
              'Account / Task Session Frozen',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              widget.controller.errorMessage ??
                  'Unauthorized field boundary violation detected.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
