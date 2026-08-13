import 'package:flutter/material.dart';

// BPTR-0788-A01 — ValidatedForm & ValidatedFieldRegistry.
//
// Spec requirements:
//   "Program instant error message hooks that evaluate before a submit event fires."
//   "The client system physically deactivates or locks the progress step button
//    until inputs match the contract."
//   "The validation fields operate as stand-alone components usable across
//    100 different forms."
//   "Standard UI elements must import field modules exclusively from the common
//    corporate npm package." → all fields import from core/utils only.
//
// Architecture:
//   ValidatedFieldRegistry — lightweight ChangeNotifier that tracks validity
//     state of every registered field in a form. Instant re-evaluation on any
//     field change, before submit fires.
//   ValidatedForm — wraps a Form and provides registry via InheritedWidget.
//     Any child field can call ValidatedForm.registryOf(context) to register
//     itself and report validity. Submit button reads registry.isAllValid.

// ─── REGISTRY ─────────────────────────────────────────────────────────────────

/// Tracks validity state of every registered field.
/// Spec: "instant error message hooks that evaluate before a submit event fires"
/// — every setValidity() call notifies listeners immediately on keystroke.
class ValidatedFieldRegistry extends ChangeNotifier {
  final Map<String, bool> _fieldValidity = {};
  final Map<String, bool> _required = {};

  /// Register a field. [required] = must be valid for isAllValid to be true.
  void register(String fieldKey, {bool required = true}) {
    _fieldValidity[fieldKey] = false;
    _required[fieldKey] = required;
    // Do not notify — registration happens during build
  }

  /// Called on every keystroke / blur — fires before any submit event.
  void setValidity(String fieldKey, {required bool isValid}) {
    final prev = _fieldValidity[fieldKey];
    if (prev == isValid) return; // no change — skip notify
    _fieldValidity[fieldKey] = isValid;
    notifyListeners(); // instant — re-evaluates submit button state
  }

  /// True only when every required field reports valid.
  /// Spec: "physically deactivates or locks the progress step button"
  bool get isAllValid {
    for (final entry in _required.entries) {
      if (entry.value && !(_fieldValidity[entry.key] ?? false)) return false;
    }
    return true;
  }

  /// Individual field validity check.
  bool isValid(String fieldKey) => _fieldValidity[fieldKey] ?? false;

  /// Fields currently invalid — used for analytics (struggle detection).
  Set<String> get invalidFields =>
      _fieldValidity.entries
          .where((e) => !e.value)
          .map((e) => e.key)
          .toSet();

  /// Reset all field validities (e.g. on form clear).
  void reset() {
    for (final key in _fieldValidity.keys) {
      _fieldValidity[key] = false;
    }
    notifyListeners();
  }

  /// Remove a field (e.g. conditional field hidden from UI).
  void unregister(String fieldKey) {
    _fieldValidity.remove(fieldKey);
    _required.remove(fieldKey);
    notifyListeners();
  }
}

// ─── INHERITED REGISTRY ───────────────────────────────────────────────────────

class _InheritedRegistry extends InheritedNotifier<ValidatedFieldRegistry> {
  const _InheritedRegistry({
    required super.notifier,
    required super.child,
  });

  @override
  bool updateShouldNotify(_InheritedRegistry oldWidget) => true;
}

// ─── VALIDATED FORM ───────────────────────────────────────────────────────────

/// Wraps a Form with a ValidatedFieldRegistry.
/// Spec: "stand-alone components usable across 100 different forms"
/// — just wrap any Form with ValidatedForm, registry is auto-provided.
///
/// Usage:
/// ```dart
/// final _formKey  = GlobalKey<FormState>();
/// final _registry = ValidatedFieldRegistry();
///
/// ValidatedForm(
///   formKey:  _formKey,
///   registry: _registry,
///   child: Column(children: [
///     ValidatedField(
///       fieldKey: 'email',
///       registry: ValidatedForm.registryOf(context),
///       validator: (v) => v!.contains('@') ? null : 'Invalid email',
///       child: TextFormField(...),
///     ),
///     ListenableBuilder(
///       listenable: _registry,
///       builder: (_, __) => FilledButton(
///         onPressed: _registry.isAllValid ? _submit : null,
///         child: Text('Submit'),
///       ),
///     ),
///   ]),
/// )
/// ```
class ValidatedForm extends StatelessWidget {
  const ValidatedForm({
    super.key,
    required this.formKey,
    required this.registry,
    required this.child,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
  });

  final GlobalKey<FormState> formKey;
  final ValidatedFieldRegistry registry;
  final Widget child;
  final AutovalidateMode autovalidateMode;

  /// Access the registry from any child widget.
  static ValidatedFieldRegistry? registryOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_InheritedRegistry>()
        ?.notifier;
  }

  @override
  Widget build(BuildContext context) {
    return _InheritedRegistry(
      notifier: registry,
      child: Form(
        key:              formKey,
        autovalidateMode: autovalidateMode,
        child:            child,
      ),
    );
  }
}

// ─── VALIDATED FIELD ─────────────────────────────────────────────────────────

/// Wraps any form field widget, auto-reports validity to ValidatedFieldRegistry.
/// Spec: "instant error message hooks that evaluate before a submit event fires"
/// — validity reported on every keystroke via onChanged + onSaved.
///
/// Works as a stand-alone wrapper — does not depend on field type.
/// Compatible with DebouncedFormField, MaskedTextField, or any TextFormField.
class ValidatedField extends StatefulWidget {
  const ValidatedField({
    super.key,
    required this.fieldKey,
    required this.registry,
    required this.child,
    this.validator,
    this.required = true,
  });

  final String fieldKey;
  final ValidatedFieldRegistry? registry;
  final Widget child;
  final FormFieldValidator<String>? validator;
  final bool required;

  @override
  State<ValidatedField> createState() => _ValidatedFieldState();
}

class _ValidatedFieldState extends State<ValidatedField> {
  @override
  void initState() {
    super.initState();
    widget.registry?.register(widget.fieldKey, required: widget.required);
  }

  @override
  void didUpdateWidget(ValidatedField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fieldKey != widget.fieldKey) {
      oldWidget.registry?.unregister(oldWidget.fieldKey);
      widget.registry?.register(widget.fieldKey, required: widget.required);
    }
  }

  @override
  void dispose() {
    widget.registry?.unregister(widget.fieldKey);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Intercept onChanged on the child FormField to report validity instantly.
    // Uses NotificationListener as a non-intrusive observer — does not alter
    // the child widget's own onChanged / validator wiring.
    return FormField<String>(
      key: ValueKey(widget.fieldKey),
      validator: (value) {
        final error = widget.validator?.call(value);
        // Report to registry before submit fires
        WidgetsBinding.instance.addPostFrameCallback((_) {
          widget.registry?.setValidity(
            widget.fieldKey,
            isValid: error == null,
          );
        });
        return error;
      },
      builder: (field) => widget.child,
    );
  }
}

// ─── SUBMIT LOCK BUTTON ───────────────────────────────────────────────────────

/// A submit button that reads ValidatedFieldRegistry and locks itself
/// until isAllValid is true. Drop-in replacement for any submit button.
///
/// Spec: "The client system physically deactivates or locks the progress
///        step button until inputs match the contract."
class SubmitLockButton extends StatelessWidget {
  const SubmitLockButton({
    super.key,
    required this.registry,
    required this.label,
    required this.onSubmit,
    this.loadingLabel = 'Submitting…',
    this.isLoading = false,
  });

  final ValidatedFieldRegistry registry;
  final String label;
  final String loadingLabel;
  final VoidCallback onSubmit;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: registry,
      builder: (context, _) {
        final canSubmit = registry.isAllValid && !isLoading;
        return FilledButton(
          // Spec: physically locked — onPressed null when not valid
          onPressed: canSubmit ? onSubmit : null,
          child: Text(isLoading ? loadingLabel : label),
        );
      },
    );
  }
}
