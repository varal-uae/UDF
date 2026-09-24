// REF-332-A10 — OrientationLockedContainer with hard-coded submission lockout.
// Enforces vertical orientation on mobile, adapts on tablets, and keeps the submit button programmatically disabled until input mask validation passes.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A wrapper widget that locks screen orientation to portrait on phones
/// and allows rotation on tablets, while managing a hard-coded submit lockout.
class OrientationLockedSubmitContainer extends StatefulWidget {
  final Widget child;
  final bool isTablet;
  final bool Function() isFormValid;
  final VoidCallback onSubmit;

  const OrientationLockedSubmitContainer({
    super.key,
    required this.child,
    required this.isFormValid,
    required this.onSubmit,
    this.isTablet = false,
  });

  @override
  State<OrientationLockedSubmitContainer> createState() => _OrientationLockedSubmitContainerState();
}

class _OrientationLockedSubmitContainerState extends State<OrientationLockedSubmitContainer> {
  @override
  void initState() {
    super.initState();
    _lockOrientation();
  }

  void _lockOrientation() {
    if (!widget.isTablet) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    } else {
      SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    }
  }

  @override
  void didUpdateWidget(covariant OrientationLockedSubmitContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isTablet != widget.isTablet) {
      _lockOrientation();
    }
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isSmallScreen = constraints.maxWidth < 600;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 16.0 : 24.0,
                  vertical: 16.0,
                ),
                child: widget.child,
              ),
            ),
            _buildSubmitSection(isSmallScreen),
          ],
        );
      },
    );
  }

  Widget _buildSubmitSection(bool isSmallScreen) {
    final bool isValid = widget.isFormValid();

    return Padding(
      padding: EdgeInsets.all(isSmallScreen ? 16.0 : 24.0),
      child: SizedBox(
        width: double.infinity,
        height: 48.0,
        child: FilledButton(
          onPressed: isValid ? widget.onSubmit : null,
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          child: const Text('Submit'),
        ),
      ),
    );
  }
}

/// A specialized text field that enforces input masks, displays assist strings,
/// highlights error states with prominent color tokens, and launches specific keyboards.
class MaskedInputField extends StatefulWidget {
  final String label;
  final String assistText;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String> onChanged;
  final String? Function(String?)? validator;
  final TextEditingController? controller;

  const MaskedInputField({
    super.key,
    required this.label,
    required this.assistText,
    required this.keyboardType,
    required this.onChanged,
    this.inputFormatters,
    this.validator,
    this.controller,
  });

  @override
  State<MaskedInputField> createState() => _MaskedInputFieldState();
}

class _MaskedInputFieldState extends State<MaskedInputField> {
  late final FocusNode _focusNode;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            keyboardType: widget.keyboardType,
            inputFormatters: widget.inputFormatters,
            onChanged: (value) {
              widget.onChanged(value);
              setState(() {
                _hasError = widget.validator?.call(value) != null;
              });
            },
            validator: widget.validator,
            decoration: InputDecoration(
              labelText: widget.label,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(
                  color: colorScheme.error,
                  width: 2.0,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(
                  color: colorScheme.error,
                  width: 2.0,
                ),
              ),
              filled: _hasError,
              fillColor: _hasError ? colorScheme.errorContainer.withOpacity(0.3) : null,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            widget.assistText,
            style: theme.textTheme.bodySmall?.copyWith(
              color: _hasError ? colorScheme.error : colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
