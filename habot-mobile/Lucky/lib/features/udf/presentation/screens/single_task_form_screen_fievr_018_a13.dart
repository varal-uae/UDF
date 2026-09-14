// FIEVR-018-A13 — Single-Task Isolated Field Form View & Layout Controller.
// Isolates the active data-entry task by rendering strictly one required field alongside a cropped
// target reference asset, applying silent hit-test expansion and telemetry focus tracking.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Represents the active layout representation mode.
enum LayoutType {
  compactColumn,
  adaptiveSideBySide,
}

/// Layout validation status tracking compliance and boundaries.
enum LayoutValidationStatus {
  unverified,
  validating,
  compliant,
  boundaryViolation,
}

/// Model encapsulating task-isolated boundary data and masked presentation.
class SingleTaskPayload {
  final String taskId;
  final String fieldKey;
  final String fieldLabel;
  final String? helperText;
  final String? cropImageUrl;
  final bool isSensitive;
  final String? initialValue;
  final Map<String, dynamic> metadata;

  const SingleTaskPayload({
    required this.taskId,
    required this.fieldKey,
    required this.fieldLabel,
    this.helperText,
    this.cropImageUrl,
    this.isSensitive = false,
    this.initialValue,
    this.metadata = const <String, dynamic>{},
  });
}

/// Controller managing single-field layout metrics, state, and telemetry logging.
class SingleTaskLayoutController extends ChangeNotifier {
  LayoutType _layoutType = LayoutType.compactColumn;
  LayoutValidationStatus _validationStatus = LayoutValidationStatus.unverified;
  double _spacing = 16.0;
  Alignment _alignment = Alignment.center;
  DateTime? _screenMountedTimestamp;
  DateTime? _firstFocusTimestamp;
  bool _hasLoggedFocusTelemetry = false;

  LayoutType get layoutType => _layoutType;
  LayoutValidationStatus get validationStatus => _validationStatus;
  double get spacing => _spacing;
  Alignment get alignment => _alignment;

  void initialize() {
    _screenMountedTimestamp = DateTime.now();
    _validationStatus = LayoutValidationStatus.compliant;
    notifyListeners();
  }

  void updateLayoutMetrics({
    required BoxConstraints constraints,
    required double spacing,
    required Alignment alignment,
  }) {
    _spacing = spacing;
    _alignment = alignment;
    _layoutType = constraints.maxWidth >= 600
        ? LayoutType.adaptiveSideBySide
        : LayoutType.compactColumn;
    notifyListeners();
  }

  void recordFieldFocus(String fieldKey, String taskId) {
    if (_hasLoggedFocusTelemetry) return;
    _firstFocusTimestamp = DateTime.now();
    _hasLoggedFocusTelemetry = true;

    final int focusDelayMs = _screenMountedTimestamp != null
        ? _firstFocusTimestamp!.difference(_screenMountedTimestamp!).inMilliseconds
        : 0;

    // Telemetry log tracking layout element focus latency.
    debugPrint(
      '[TELEMETRY][FIEVR-018-A13] Field: $fieldKey | Task: $taskId | '
      'Layout: $_layoutType | FocusDelayMs: $focusDelayMs | Status: $_validationStatus',
    );
  }

  void recordSubmissionValidation(bool isValid) {
    _validationStatus = isValid
        ? LayoutValidationStatus.compliant
        : LayoutValidationStatus.boundaryViolation;
    notifyListeners();
  }
}

/// Production-grade screen isolating a single field with target cropped image view.
class SingleTaskFormScreenFievr018A13 extends StatefulWidget {
  final SingleTaskPayload payload;
  final Future<void> Function(String value)? onFieldSubmitted;

  const SingleTaskFormScreenFievr018A13({
    super.key,
    required this.payload,
    this.onFieldSubmitted,
  });

  @override
  State<SingleTaskFormScreenFievr018A13> createState() =>
      _SingleTaskFormScreenFievr018A13State();
}

class _SingleTaskFormScreenFievr018A13State
    extends State<SingleTaskFormScreenFievr018A13> {
  late final SingleTaskLayoutController _controller;
  late final TextEditingController _textController;
  late final FocusNode _focusNode;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controller = SingleTaskLayoutController()..initialize();
    _textController = TextEditingController(text: widget.payload.initialValue);
    _focusNode = FocusNode();

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _controller.recordFieldFocus(
          widget.payload.fieldKey,
          widget.payload.taskId,
        );
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _textController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleConfirm() async {
    final String value = _textController.text.trim();
    if (value.isEmpty) {
      setState(() {
        _errorMessage = 'Field entry cannot be blank.';
      });
      _controller.recordSubmissionValidation(false);
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    _controller.recordSubmissionValidation(true);

    try {
      if (widget.onFieldSubmitted != null) {
        await widget.onFieldSubmitted!(value);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to submit value: ${e.toString()}';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Task: ${widget.payload.taskId}',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
        centerTitle: false,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            _controller.updateLayoutMetrics(
              constraints: constraints,
              spacing: 16.0,
              alignment: Alignment.center,
            );

            return AnimatedBuilder(
              animation: _controller,
              builder: (BuildContext context, _) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 840),
                      child: _controller.layoutType == LayoutType.adaptiveSideBySide
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Expanded(
                                  flex: 1,
                                  child: _buildCroppedAssetCard(colorScheme, theme),
                                ),
                                const SizedBox(width: 24.0),
                                Expanded(
                                  flex: 1,
                                  child: _buildInputSection(colorScheme, theme),
                                ),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                _buildCroppedAssetCard(colorScheme, theme),
                                SizedBox(height: _controller.spacing),
                                _buildInputSection(colorScheme, theme),
                              ],
                            ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildCroppedAssetCard(ColorScheme colorScheme, ThemeData theme) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: Row(
              children: <Widget>[
                Icon(Icons.crop, size: 18.0, color: colorScheme.primary),
                const SizedBox(width: 8.0),
                Text(
                  'Reference Asset Focus',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          AspectRatio(
            aspectRatio: 16 / 9,
            child: widget.payload.cropImageUrl != null
                ? Image.network(
                    widget.payload.cropImageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildAssetPlaceholder(colorScheme, theme, 'Asset Unavailable'),
                  )
                : _buildAssetPlaceholder(colorScheme, theme, 'Active Field Target Preview'),
          ),
        ],
      ),
    );
  }

  Widget _buildAssetPlaceholder(
    ColorScheme colorScheme,
    ThemeData theme,
    String label,
  ) {
    return Container(
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.image_search, size: 40.0, color: colorScheme.outline),
          const SizedBox(height: 8.0),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputSection(ColorScheme colorScheme, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          widget.payload.fieldLabel,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        if (widget.payload.helperText != null) ...<Widget>[
          const SizedBox(height: 4.0),
          Text(
            widget.payload.helperText!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        const SizedBox(height: 12.0),
        _SilentHitExpandedTarget(
          hitSlop: const EdgeInsets.all(12.0),
          child: TextField(
            controller: _textController,
            focusNode: _focusNode,
            obscureText: widget.payload.isSensitive,
            decoration: InputDecoration(
              filled: true,
              fillColor: colorScheme.surfaceContainerLowest,
              hintText: 'Enter ${widget.payload.fieldLabel.toLowerCase()}',
              errorText: _errorMessage,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(color: colorScheme.outline),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(color: colorScheme.primary, width: 2.0),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20.0),
        _SilentHitExpandedTarget(
          hitSlop: const EdgeInsets.all(8.0),
          child: FilledButton.icon(
            onPressed: _isSubmitting ? null : _handleConfirm,
            icon: _isSubmitting
                ? const SizedBox(
                    width: 18.0,
                    height: 18.0,
                    child: CircularProgressIndicator(strokeWidth: 2.0),
                  )
                : const Icon(Icons.check_circle_outline),
            label: Text(_isSubmitting ? 'Verifying...' : 'Save & Confirm Value'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Expands touch boundary via transparent padding while leaving physical child size visually unchanged.
class _SilentHitExpandedTarget extends SingleChildRenderObjectWidget {
  final EdgeInsets hitSlop;

  const _SilentHitExpandedTarget({
    required this.hitSlop,
    required Widget child,
  }) : super(child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderSilentHitExpandedTarget(hitSlop);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _RenderSilentHitExpandedTarget renderObject,
  ) {
    renderObject.hitSlop = hitSlop;
  }
}

class _RenderSilentHitExpandedTarget extends RenderProxyBox {
  EdgeInsets _hitSlop;

  _RenderSilentHitExpandedTarget(this._hitSlop);

  EdgeInsets get hitSlop => _hitSlop;
  set hitSlop(EdgeInsets value) {
    if (_hitSlop != value) {
      _hitSlop = value;
      markNeedsPaint();
    }
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    final Rect expandedBounds = Rect.fromLTRB(
      -hitSlop.left,
      -hitSlop.top,
      size.width + hitSlop.right,
      size.height + hitSlop.bottom,
    );

    if (expandedBounds.contains(position)) {
      final Offset clampedOffset = Offset(
        position.dx.clamp(0.0, size.width),
        position.dy.clamp(0.0, size.height),
      );
      return super.hitTest(result, position: clampedOffset);
    }
    return false;
  }
}
