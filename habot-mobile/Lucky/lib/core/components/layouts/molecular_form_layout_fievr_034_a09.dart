// FIEVR-034-A09 — Molecular Form Layout Elements & Responsive Input Field Group.
// Provides responsive Material 3 molecular form components adapting smoothly across mobile/desktop
// breakpoints with keyboard-safe transitions, focus background shade animation, and accessible label linking.

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// Breakpoint classifications based on Material 3 responsive design specs.
enum MolecularBreakpoint {
  compact,
  medium,
  expanded,
}

/// Telemetry metadata capturing input field lifecycle events for upstream analytics.
class MolecularFieldTelemetryData {
  const MolecularFieldTelemetryData({
    required this.stepExecutionId,
    required this.executionStatus,
    required this.executionTimestamp,
    required this.stepOutcome,
    required this.userId,
  });

  final String stepExecutionId;
  final String executionStatus;
  final DateTime executionTimestamp;
  final String stepOutcome;
  final String userId;

  Map<String, dynamic> toMap() => <String, dynamic>{
        'step_execution_id': stepExecutionId,
        'execution_status': executionStatus,
        'execution_timestamp': executionTimestamp.toIso8601String(),
        'step_outcome': stepOutcome,
        'user_id': userId,
      };
}

/// Model describing a single molecular input entry inside an [InputFieldGroup].
class MolecularInputFieldConfig {
  MolecularInputFieldConfig({
    required this.id,
    required this.label,
    this.hintText,
    this.helperText,
    this.errorText,
    this.initialValue,
    this.controller,
    this.focusNode,
    this.isPrimary = false,
    this.autofocus = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.obscureText = false,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
  });

  final String id;
  final String label;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final String? initialValue;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool isPrimary;
  final bool autofocus;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final bool obscureText;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;
}

/// Molecular form layout that renders a collection of form fields across responsive breakpoints.
/// Enforces strict grid spacing, programmatic screen-reader accessibility linking, and focus transitions.
class MolecularFormLayout extends StatelessWidget {
  const MolecularFormLayout({
    super.key,
    required this.fields,
    this.formKey,
    this.verticalSpacing = 16.0,
    this.horizontalSpacing = 16.0,
    this.compactBreakpoint = 600.0,
    this.expandedBreakpoint = 840.0,
    this.autoFocusPrimary = true,
    this.onTelemetryLogged,
    this.padding = const EdgeInsets.all(16.0),
  });

  final List<MolecularInputFieldConfig> fields;
  final GlobalKey<FormState>? formKey;
  final double verticalSpacing;
  final double horizontalSpacing;
  final double compactBreakpoint;
  final double expandedBreakpoint;
  final bool autoFocusPrimary;
  final ValueChanged<MolecularFieldTelemetryData>? onTelemetryLogged;
  final EdgeInsetsGeometry padding;

  MolecularBreakpoint _resolveBreakpoint(double width) {
    if (width < compactBreakpoint) {
      return MolecularBreakpoint.compact;
    } else if (width < expandedBreakpoint) {
      return MolecularBreakpoint.medium;
    }
    return MolecularBreakpoint.expanded;
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final width = mediaQuery.size.width;
    final breakpoint = _resolveBreakpoint(width);

    return Form(
      key: formKey,
      child: Padding(
        padding: padding,
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (breakpoint == MolecularBreakpoint.compact) {
              return _buildCompactVerticalStack();
            } else if (breakpoint == MolecularBreakpoint.medium) {
              return _buildResponsiveGrid(columns: 2, constraints: constraints);
            } else {
              return _buildResponsiveGrid(columns: 3, constraints: constraints);
            }
          },
        ),
      ),
    );
  }

  Widget _buildCompactVerticalStack() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      itemCount: fields.length,
      separatorBuilder: (_, __) => SizedBox(height: verticalSpacing),
      itemBuilder: (context, index) {
        final fieldConfig = fields[index];
        return MolecularInputField(
          config: fieldConfig,
          autoFocus: autoFocusPrimary && fieldConfig.isPrimary,
          onTelemetryLogged: onTelemetryLogged,
        );
      },
    );
  }

  Widget _buildResponsiveGrid({
    required int columns,
    required BoxConstraints constraints,
  }) {
    final totalHorizontalGaps = (columns - 1) * horizontalSpacing;
    final itemWidth = (constraints.maxWidth - totalHorizontalGaps) / columns;

    return Wrap(
      spacing: horizontalSpacing,
      runSpacing: verticalSpacing,
      children: fields.map((fieldConfig) {
        return SizedBox(
          width: itemWidth,
          child: MolecularInputField(
            config: fieldConfig,
            autoFocus: autoFocusPrimary && fieldConfig.isPrimary,
            onTelemetryLogged: onTelemetryLogged,
          ),
        );
      }).toList(),
    );
  }
}

/// Molecular Input Field component honoring Material 3 styling, subtle focus shade transitions,
/// and programmatic link requirements between label descriptors and input controls.
class MolecularInputField extends StatefulWidget {
  const MolecularInputField({
    super.key,
    required this.config,
    this.autoFocus = false,
    this.onTelemetryLogged,
  });

  final MolecularInputFieldConfig config;
  final bool autoFocus;
  final ValueChanged<MolecularFieldTelemetryData>? onTelemetryLogged;

  @override
  State<MolecularInputField> createState() => _MolecularInputFieldState();
}

class _MolecularInputFieldState extends State<MolecularInputField> {
  late final FocusNode _focusNode;
  late final TextEditingController _controller;
  bool _isInternalFocusNode = false;
  bool _isInternalController = false;
  bool _isFocused = false;
  String? _runtimeErrorText;

  @override
  void initState() {
    super.initState();
    if (widget.config.focusNode != null) {
      _focusNode = widget.config.focusNode!;
    } else {
      _focusNode = FocusNode();
      _isInternalFocusNode = true;
    }

    if (widget.config.controller != null) {
      _controller = widget.config.controller!;
    } else {
      _controller = TextEditingController(text: widget.config.initialValue ?? '');
      _isInternalController = true;
    }

    _focusNode.addListener(_handleFocusChange);
    _runtimeErrorText = widget.config.errorText;

    if (widget.autoFocus || widget.config.autofocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && widget.config.enabled) {
          _focusNode.requestFocus();
        }
      });
    }
  }

  @override
  void didUpdateWidget(covariant MolecularInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.config.errorText != oldWidget.config.errorText) {
      setState(() {
        _runtimeErrorText = widget.config.errorText;
      });
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    if (_isInternalFocusNode) {
      _focusNode.dispose();
    }
    if (_isInternalController) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _handleFocusChange() {
    if (mounted) {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });

      if (_isFocused) {
        widget.onTelemetryLogged?.call(
          MolecularFieldTelemetryData(
            stepExecutionId: 'FIEVR-034-A09-${widget.config.id}',
            executionStatus: 'FOCUSED',
            executionTimestamp: DateTime.now().toUtc(),
            stepOutcome: 'INPUT_ACTIVE',
            userId: 'CURRENT_USER',
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final hasError = _runtimeErrorText != null && _runtimeErrorText!.isNotEmpty;
    final labelId = 'molecular_label_${widget.config.id}';

    // Subtle container shade transitions on background focus fields
    final Color containerColor = hasError
        ? colorScheme.errorContainer.withValues(alpha: 0.12)
        : _isFocused
            ? colorScheme.primaryContainer.withValues(alpha: 0.16)
            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.35);

    final Color borderColor = hasError
        ? colorScheme.error
        : _isFocused
            ? colorScheme.primary
            : colorScheme.outlineVariant;

    return Semantics(
      identifier: labelId,
      label: widget.config.label,
      textField: true,
      enabled: widget.config.enabled,
      focused: _isFocused,
      errorMessage: _runtimeErrorText,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Label stacked vertically to maximize horizontal entry area
          Padding(
            padding: const EdgeInsets.only(bottom: 6.0),
            child: Row(
              children:
[
                Text(
                  widget.config.label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: hasError
                        ? colorScheme.error
                        : _isFocused
                            ? colorScheme.primary
                            : colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (widget.config.isPrimary) ...[
                  const SizedBox(width: 4.0),
                  Text(
                    '*',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Animated container providing smooth shade transitions
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              color: containerColor,
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(
                color: borderColor,
                width: _isFocused || hasError ? 2.0 : 1.0,
              ),
            ),
            child: TextFormField(
              controller: _controller,
              focusNode: _focusNode,
              enabled: widget.config.enabled,
              obscureText: widget.config.obscureText,
              keyboardType: widget.config.keyboardType,
              textInputAction: widget.config.textInputAction,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                isDense: true,
                hintText: widget.config.hintText,
                hintStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 14.0,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                prefixIcon: widget.config.prefixIcon,
                suffixIcon: widget.config.suffixIcon,
              ),
              validator: (val) {
                final validation = widget.config.validator?.call(val);
                if (validation != _runtimeErrorText) {
                  setState(() {
                    _runtimeErrorText = validation;
                  });
                }
                return validation;
              },
              onChanged: (val) {
                if (_runtimeErrorText != null) {
                  setState(() {
                    _runtimeErrorText = null;
                  });
                }
                widget.config.onChanged?.call(val);
              },
              onFieldSubmitted: (val) {
                widget.config.onSubmitted?.call(val);
                widget.onTelemetryLogged?.call(
                  MolecularFieldTelemetryData(
                    stepExecutionId: 'FIEVR-034-A09-${widget.config.id}',
                    executionStatus: 'SUBMITTED',
                    executionTimestamp: DateTime.now().toUtc(),
                    stepOutcome: 'INPUT_SUBMITTED',
                    userId: 'CURRENT_USER',
                  ),
                );
              },
            ),
          ),
          // Error or helper text slot
          if (hasError) ...[
            Padding(
              padding: const EdgeInsets.only(top: 4.0, left: 8.0),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 14.0,
                    color: colorScheme.error,
                  ),
                  const SizedBox(width: 4.0),
                  Expanded(
                    child: Text(
                      _runtimeErrorText!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else if (widget.config.helperText != null) ...[
            Padding(
              padding: const EdgeInsets.only(top: 4.0, left: 8.0),
              child: Text(
                widget.config.helperText!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
