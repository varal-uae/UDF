/// AISS: IS12-CSIVW-011-AS01-A01 -- "<ValidatedInputField>", the self-formatting
/// smart data entry text input the step's Atomic Reusability column names.
/// AISS: CSIVW-001-A01 -- the StandardTextInputMask element.
/// AISS: IS02-CSIVW-005-AS01-A01 -- inline error layouts bound to blur events.
///
/// Mobile-First rows implemented here:
///   "Display standard clear helper text blocks directly beneath form rows."
///   "Apply clear border colors to distinguish focus states from validation errors."
///   "Position error text boxes directly below typing blocks."
///   "Add quick-clear X icons inside mobile text boxes to wipe inputs in one tap."
///   "Typography configurations enforce crisp line height metrics."
library;

import 'package:flutter/material.dart';

import '../interaction/touch_standards.dart';
import '../telemetry/hesitation_tracker.dart';
import '../tokens/motion_tokens.dart';
import '../tokens/shape_tokens.dart';
import '../tokens/spacing_tokens.dart';
import '../tokens/typography_tokens.dart';
import 'field_validation.dart';
import 'form_gate.dart';
import 'inline_error.dart';

/// The only text input the application is allowed to build.
class ValidatedInputField extends StatefulWidget {
  const ValidatedInputField({
    required this.fieldName,
    required this.label,
    required this.cde,
    this.gate,
    this.controller,
    this.required = true,
    this.helperText,
    this.showClearButton = true,
    this.onChanged,
    super.key,
  });

  /// Stable key used by the [HabotFormGate].
  final String fieldName;
  final String label;
  final HabotCde cde;

  /// When supplied, validation status is published to the gate, which is what
  /// freezes the submit control.
  final HabotFormGate? gate;

  final TextEditingController? controller;
  final bool required;
  final String? helperText;
  final bool showClearButton;
  final ValueChanged<String>? onChanged;

  @override
  State<ValidatedInputField> createState() => _ValidatedInputFieldState();
}

class _ValidatedInputFieldState extends State<ValidatedInputField> {
  late final TextEditingController _controller;
  late final FocusNode _focus;
  late final bool _ownsController;
  late final HabotFieldRule _rule;

  /// UFHT-032: the focus listener the tracker attached, kept so it can be
  /// detached again. Every field carries one -- that is what makes the
  /// Event Listener Coverage Rate structural rather than aspirational.
  VoidCallback? _hesitationListener;

  FieldValidationResult _result = const FieldValidationResult.valid();
  bool _touched = false;
  String _previousValue = '';

  @override
  void initState() {
    super.initState();
    _rule = HabotFieldRules.of(widget.cde);
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? TextEditingController();
    _focus = FocusNode();
    _focus.addListener(_onFocusChange);
    // UFHT-032 Setup Step Description: "Attach focus event listeners to every
    // individual input field within the target form." Done here, once, so no
    // field can exist without one.
    _hesitationListener = HabotHesitationTracker.instance.attach(
      widget.fieldName,
      _focus,
    );
    widget.gate?.register(widget.fieldName, required: widget.required);
    _result = _rule.validate(_controller.text, required: widget.required);
    _previousValue = _controller.text;
    widget.gate?.update(widget.fieldName, _result);
  }

  @override
  void dispose() {
    if (_hesitationListener != null) {
      HabotHesitationTracker.instance.detach(
        widget.fieldName,
        _focus,
        _hesitationListener!,
      );
    }
    _focus.removeListener(_onFocusChange);
    _focus.dispose();
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  /// IS02-CSIVW-005 substep 1: "Bind custom inline error components to the blur
  /// events of core entry inputs."
  void _onFocusChange() {
    if (_focus.hasFocus) {
      return;
    }
    setState(() => _touched = true);
    widget.gate?.touch(widget.fieldName);
  }

  void _onChanged(String value) {
    // GEN-00632: content removed is a correction. Only the lengths are
    // compared -- neither value is recorded anywhere.
    if (value.length < _previousValue.length) {
      HabotHesitationTracker.instance.recordCorrection(widget.fieldName);
    }
    _previousValue = value;
    // Self-Chasing: recheck the second an error is edited, so a warning clears
    // as soon as the value passes rather than waiting for another blur.
    final FieldValidationResult next = _rule.validate(
      value,
      required: widget.required,
    );
    setState(() => _result = next);
    widget.gate?.update(widget.fieldName, next);
    widget.onChanged?.call(value);
  }

  void _clear() {
    _controller.clear();
    _onChanged('');
  }

  bool get _showError => _touched && !_result.isValid;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final bool hasText = _controller.text.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        TextField(
          controller: _controller,
          focusNode: _focus,
          onChanged: _onChanged,
          keyboardType: _rule.keyboardType,
          inputFormatters: _rule.formatters,
          maxLength: _rule.maxLength,
          // BPTR-0160: autocomplete off unless the rule opts in.
          autofillHints: _rule.autocomplete ? null : const <String>[],
          buildCounter:
              (
                BuildContext context, {
                required int currentLength,
                required bool isFocused,
                required int? maxLength,
              }) => null,
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: _rule.placeholder,
            // Error text is rendered by InlineFieldError below, not here, so
            // the layout and typography are ours rather than the framework's.
            errorText: null,
            errorStyle: const TextStyle(height: 0, fontSize: 0),
            suffixIcon: widget.showClearButton && hasText
                ? Semantics(
                    label: 'Clear ${widget.label}',
                    button: true,
                    child: InkResponse(
                      onTap: _clear,
                      radius: TouchStandards.iconStandard,
                      child: SizedBox(
                        width: HabotDensity.minTouchTarget,
                        height: HabotDensity.minTouchTarget,
                        child: Icon(
                          Icons.cancel_outlined,
                          size: TouchStandards.iconStandard,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  )
                : null,
            // "Apply clear border colors to distinguish focus from error."
            focusedBorder: _showError
                ? OutlineInputBorder(
                    borderSide: BorderSide(
                      color: scheme.error,
                      width: HabotShape.focusBorderWidth,
                    ),
                  )
                : null,
            enabledBorder: _showError
                ? OutlineInputBorder(
                    borderSide: BorderSide(
                      color: scheme.error,
                      width: HabotShape.borderWidth,
                    ),
                  )
                : null,
          ),
        ),
        AnimatedSize(
          duration: HabotMotionPolicy.resolve(context, HabotMotion.fast),
          curve: HabotMotionPolicy.resolveCurve(context, HabotEasing.standard),
          alignment: Alignment.topLeft,
          child: _showError
              ? InlineFieldError(message: _result.message!)
              : _HelperText(text: widget.helperText),
        ),
      ],
    );
  }
}

/// "Display standard clear helper text blocks directly beneath form rows."
class _HelperText extends StatelessWidget {
  const _HelperText({required this.text});

  final String? text;

  @override
  Widget build(BuildContext context) {
    if (text == null || text!.isEmpty) {
      return const SizedBox.shrink();
    }
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(
        left: HabotSpacing.md,
        top: HabotSpacing.xxs,
      ),
      child: Text(
        text!,
        style: HabotTypography.bodySmall
            .toTextStyle(HabotTypography.fontName)
            .copyWith(color: theme.colorScheme.onSurfaceVariant),
      ),
    );
  }
}
