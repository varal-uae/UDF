// CSIVW-021 — Anti-Bluster Sentiment Warning Field.
// Provides Material 3 compliant warning colors and asynchronous sentiment validation
// for text input, with dynamic border/text state switching and accessible feedback.

import 'dart:async';

import 'package:flutter/material.dart';

enum SentimentValidationState { idle, validating, safe, warning, blocked }

class SentimentValidationResult {
  final SentimentValidationState state;
  final String? message;

  const SentimentValidationResult({required this.state, this.message});

  const SentimentValidationResult.idle()
      : state = SentimentValidationState.idle,
        message = null;

  const SentimentValidationResult.validating()
      : state = SentimentValidationState.validating,
        message = null;

  const SentimentValidationResult.safe([this.message])
      : state = SentimentValidationState.safe;

  const SentimentValidationResult.warning([this.message])
      : state = SentimentValidationState.warning;

  const SentimentValidationResult.blocked([this.message])
      : state = SentimentValidationState.blocked;
}

class AntiBlusterSentimentColors {
  final Color safeBorder;
  final Color safeText;
  final Color warningBorder;
  final Color warningText;
  final Color blockedBorder;
  final Color blockedText;
  final Color validatingBorder;
  final Color validatingText;

  const AntiBlusterSentimentColors({
    required this.safeBorder,
    required this.safeText,
    required this.warningBorder,
    required this.warningText,
    required this.blockedBorder,
    required this.blockedText,
    required this.validatingBorder,
    required this.validatingText,
  });

  factory AntiBlusterSentimentColors.fromScheme(ColorScheme scheme) {
    return AntiBlusterSentimentColors(
      safeBorder: scheme.outline,
      safeText: scheme.onSurface,
      warningBorder: scheme.tertiary,
      warningText: scheme.onTertiaryContainer,
      blockedBorder: scheme.error,
      blockedText: scheme.onErrorContainer,
      validatingBorder: scheme.primary,
      validatingText: scheme.onPrimaryContainer,
    );
  }
}

class AntiBlusterSentimentWarningField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final Future<SentimentValidationResult> Function(String value)? asyncValidator;
  final ValueChanged<SentimentValidationResult>? onValidationChanged;
  final String labelText;
  final String? hintText;
  final int maxLines;
  final Duration debounce;
  final bool enabled;

  const AntiBlusterSentimentWarningField({
    super.key,
    required this.controller,
    this.focusNode,
    this.asyncValidator,
    this.onValidationChanged,
    this.labelText = 'Message',
    this.hintText,
    this.maxLines = 4,
    this.debounce = const Duration(milliseconds: 350),
    this.enabled = true,
  });

  @override
  State<AntiBlusterSentimentWarningField> createState() =>
      _AntiBlusterSentimentWarningFieldState();
}

class _AntiBlusterSentimentWarningFieldState
    extends State<AntiBlusterSentimentWarningField> {
  Timer? _debounceTimer;
  SentimentValidationState _state = SentimentValidationState.idle;
  String? _message;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(covariant AntiBlusterSentimentWarningField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onTextChanged);
      widget.controller.addListener(_onTextChanged);
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    _debounceTimer?.cancel();
    final value = widget.controller.text.trim();

    if (value.isEmpty) {
      _setResult(const SentimentValidationResult.idle());
      return;
    }

    if (widget.asyncValidator == null) {
      _setResult(const SentimentValidationResult.safe());
      return;
    }

    _setResult(const SentimentValidationResult.validating());
    _debounceTimer = Timer(widget.debounce, () async {
      final result = await (widget.asyncValidator?.call(value) ??
          Future<SentimentValidationResult>.value(
              const SentimentValidationResult.safe()));
      if (!mounted) return;
      _setResult(result);
      widget.onValidationChanged?.call(result);
    });
  }

  void _setResult(SentimentValidationResult result) {
    if (!mounted) return;
    setState(() {
      _state = result.state;
      _message = result.message;
    });
  }

  Color _borderColor(ColorScheme scheme, AntiBlusterSentimentColors colors) {
    switch (_state) {
      case SentimentValidationState.idle:
        return scheme.outlineVariant;
      case SentimentValidationState.validating:
        return colors.validatingBorder;
      case SentimentValidationState.safe:
        return colors.safeBorder;
      case SentimentValidationState.warning:
        return colors.warningBorder;
      case SentimentValidationState.blocked:
        return colors.blockedBorder;
    }
  }

  Color _textColor(ColorScheme scheme, AntiBlusterSentimentColors colors) {
    switch (_state) {
      case SentimentValidationState.idle:
        return scheme.onSurface;
      case SentimentValidationState.validating:
        return colors.validatingText;
      case SentimentValidationState.safe:
        return colors.safeText;
      case SentimentValidationState.warning:
        return colors.warningText;
      case SentimentValidationState.blocked:
        return colors.blockedText;
    }
  }

  Widget? _suffixIcon(ColorScheme scheme, AntiBlusterSentimentColors colors) {
    switch (_state) {
      case SentimentValidationState.idle:
        return null;
      case SentimentValidationState.validating:
        return SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: colors.validatingBorder,
          ),
        );
      case SentimentValidationState.safe:
        return Icon(Icons.check_circle_outline, color: colors.safeBorder);
      case SentimentValidationState.warning:
        return Icon(Icons.warning_amber_rounded, color: colors.warningBorder);
      case SentimentValidationState.blocked:
        return Icon(Icons.block, color: colors.blockedBorder);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final colors = AntiBlusterSentimentColors.fromScheme(scheme);
    final borderColor = _borderColor(scheme, colors);
    final textColor = _textColor(scheme, colors);
    final suffixIcon = _suffixIcon(scheme, colors);

    return Semantics(
      liveRegion: true,
      label: widget.labelText,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            enabled: widget.enabled,
            maxLines: widget.maxLines,
            style: theme.textTheme.bodyLarge?.copyWith(color: textColor),
            decoration: InputDecoration(
              labelText: widget.labelText,
              hintText: widget.hintText,
              filled: true,
              fillColor: scheme.surfaceContainerHighest,
              suffixIcon: suffixIcon,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: borderColor, width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: borderColor, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: borderColor, width: 2),
              ),
            ),
          ),
          if (_message != null)
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 4),
              child: Text(
                _message!,
                style: theme.textTheme.bodySmall?.copyWith(color: textColor),
              ),
            ),
        ],
      ),
    );
  }
}
