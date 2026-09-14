// FIEVR-034-A01 — Molecular Form Layout Elements & Input Field Group.
// Provides accessible, responsive molecular form layout structures following Material 3 specifications,
// supporting vertical label stacking, dynamic focus container transitions, strict grid spacing, and screen-reader accessibility.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Metadata event emitted for telemetry/BigQuery audit pipelines.
class FormStepTelemetry {
  final String stepExecutionId;
  final String executionStatus;
  final DateTime executionTimestamp;
  final String stepOutcome;
  final String? userId;

  const FormStepTelemetry({
    required this.stepExecutionId,
    required this.executionStatus,
    required this.executionTimestamp,
    required this.stepOutcome,
    this.userId,
  });

  Map<String, dynamic> toMap() => {
        'stepExecutionId': stepExecutionId,
        'executionStatus': executionStatus,
        'executionTimestamp': executionTimestamp.toIso8601String(),
        'stepOutcome': stepOutcome,
        'userId': userId,
      };
}

/// Standardized Material 3 spacing constants adhering to 8dp grid increments.
class FormLayoutTokens {
  static const double gridUnit = 8.0;
  static const double rowSpacing = 2.0 * gridUnit; // 16.0 dp
  static const double groupSpacing = 3.0 * gridUnit; // 24.0 dp
  static const double labelBottomSpacing = 1.0 * gridUnit; // 8.0 dp
  static const double standardFieldHeight = 56.0;
  static const double borderRadius = 12.0;
  static const Duration focusAnimationDuration = Duration(milliseconds: 200);
}

/// Molecular Input Field Group linking label descriptors, interactive inputs, and validation feedback.
class MolecularInputFieldGroup extends StatefulWidget {
  final String atomicStepId;
  final String label;
  final String? helperText;
  final String? errorText;
  final String? hintText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final bool obscureText;
  final bool isRequired;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<FormStepTelemetry>? onTelemetryLogged;
  final String? userId;

  const MolecularInputFieldGroup({
    super.key,
    this.atomicStepId = 'FIEVR-034-A01',
    required this.label,
    this.helperText,
    this.errorText,
    this.hintText,
    this.controller,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.obscureText = false,
    this.isRequired = false,
    this.prefixIcon,
    this.suffixIcon,
    this.onTelemetryLogged,
    this.userId,
  });

  @override
  State<MolecularInputFieldGroup> createState() => _MolecularInputFieldGroupState();
}

class _MolecularInputFieldGroupState extends State<MolecularInputFieldGroup> {
  late FocusNode _focusNode;
  bool _isInternalFocusNode = false;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    if (widget.focusNode == null) {
      _focusNode = FocusNode();
      _isInternalFocusNode = true;
    } else {
      _focusNode = widget.focusNode!;
    }
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    if (_isInternalFocusNode) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _handleFocusChange() {
    if (mounted) {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
      if (_focusNode.hasFocus) {
        _emitTelemetry('FOCUSED');
      }
    }
  }

  void _emitTelemetry(String status) {
    if (widget.onTelemetryLogged != null) {
      widget.onTelemetryLogged!(
        FormStepTelemetry(
          stepExecutionId: '${widget.atomicStepId}-${DateTime.now().millisecondsSinceEpoch}',
          executionStatus: status,
          executionTimestamp: DateTime.now().toUtc(),
          stepOutcome: widget.errorText == null ? 'VALID' : 'INVALID',
          userId: widget.userId,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;

    final Color containerColor = _isFocused
        ? colorScheme.surfaceVariant.withOpacity(0.45)
        : colorScheme.surfaceVariant.withOpacity(0.20);

    final String semanticLabel = widget.isRequired
        ? '${widget.label}, required'
        : widget.label;

    return Semantics(
      container: true,
      label: semanticLabel,
      hint: widget.hintText,
      error: hasError ? widget.errorText : null,
      textField: true,
      focused: _isFocused,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Vertically stacked label descriptor for mobile-first scanning
          Row(
            children: [
              Text(
                widget.label,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: hasError
                      ? colorScheme.error
                      : (_isFocused ? colorScheme.primary : colorScheme.onSurface),
                ),
              ),
              if (widget.isRequired) ...[
                const SizedBox(width: 4),
                Text(
                  '*',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colorScheme.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: FormLayoutTokens.labelBottomSpacing),
          // Animated container supporting subtle focus background transition
          AnimatedContainer(
            duration: FormLayoutTokens.focusAnimationDuration,
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              color: containerColor,
              borderRadius: BorderRadius.circular(FormLayoutTokens.borderRadius),
              border: Border.all(
                color: hasError
                    ? colorScheme.error
                    : (_isFocused ? colorScheme.primary : colorScheme.outlineVariant),
                width: _isFocused || hasError ? 2.0 : 1.0,
              ),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: FormLayoutTokens.standardFieldHeight,
              ),
              child: TextFormField(
                controller: widget.controller,
                focusNode: _focusNode,
                keyboardType: widget.keyboardType,
                textInputAction: widget.textInputAction,
                obscureText: widget.obscureText,
                onChanged: (val) {
                  widget.onChanged?.call(val);
                  _emitTelemetry('INPUT_MODIFIED');
                },
                onFieldSubmitted: widget.onSubmitted,
                validator: widget.validator,
                decoration: InputDecoration(
                  isDense: false,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 14.0,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  hintText: widget.hintText,
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                  ),
                  prefixIcon: widget.prefixIcon,
                  suffixIcon: widget.suffixIcon,
                ),
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ),
          // Validation error or helper indicators
          if (hasError) ...[
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 16,
                  color: colorScheme.error,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    widget.errorText!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ] else if (widget.helperText != null && widget.helperText!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              widget.helperText!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Molecular Form Layout container maintaining strict grid increments between parallel input rows
/// and managing soft-keyboard inset adjustments cleanly.
class MolecularFormLayout extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry padding;
  final CrossAxisAlignment crossAxisAlignment;
  final ScrollPhysics? physics;

  const MolecularFormLayout({
    super.key,
    required this.children,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
    this.crossAxisAlignment = CrossAxisAlignment.stretch,
    this.physics = const BouncingScrollPhysics(),
  });

  @override
  Widget build(BuildContext context) {
    final List<Widget> spacedChildren = [];
    for (int i = 0; i < children.length; i++) {
      spacedChildren.add(children[i]);
      if (i < children.length - 1) {
        spacedChildren.add(const SizedBox(height: FormLayoutTokens.rowSpacing));
      }
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: physics,
          padding: padding,
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: crossAxisAlignment,
              children: spacedChildren,
            ),
          ),
        );
      },
    );
  }
}
