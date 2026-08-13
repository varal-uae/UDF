import 'package:flutter/material.dart';
import 'debouncer.dart';
import 'form_auto_save_service.dart';

// VPVMP-021-02 — Debounced Form Field.
// Reusable TextField wrapper that enforces:
//   1. Uniform debounce (300ms) on every onChanged handler
//   2. Automatic background save (800ms) to local cache — no button needed
//   3. Restores saved value on mount (persists across navigation/restart)
//   4. Discards input if length mismatches validation rules (Poka-Yoke)
//
// UX config per spec:
//   - Single-row vertical flow layout
//   - 48dp touch target
//   - Micro-scale animation on clear

class DebouncedFormField extends StatefulWidget {
  const DebouncedFormField({
    super.key,
    required this.formId,
    required this.fieldKey,
    this.label,
    this.hint,
    this.initialValue,
    this.onDebounced,
    this.onAutoSaved,
    this.validator,
    this.minLength,
    this.maxLength,
    this.keyboardType,
    this.obscureText = false,
    this.enabled = true,
    this.controller,
    this.restoreOnMount = true,
  });

  /// Identifies the parent form — used as cache namespace.
  final String formId;

  /// Identifies this field within the form — used as cache key.
  final String fieldKey;

  final String? label;
  final String? hint;
  final String? initialValue;

  /// Fires 300ms after user stops typing.
  final ValueChanged<String>? onDebounced;

  /// Fires after every successful auto-save (800ms interval).
  final ValueChanged<String>? onAutoSaved;

  final FormFieldValidator<String>? validator;

  /// Poka-Yoke: input discarded if length < minLength or > maxLength.
  final int? minLength;
  final int? maxLength;

  final TextInputType? keyboardType;
  final bool obscureText;
  final bool enabled;
  final TextEditingController? controller;

  /// If true, restores last saved value from cache on widget mount.
  final bool restoreOnMount;

  @override
  State<DebouncedFormField> createState() => _DebouncedFormFieldState();
}

class _DebouncedFormFieldState extends State<DebouncedFormField>
    with SingleTickerProviderStateMixin {

  late final TextEditingController _controller;
  late final Debouncer _inputDebouncer;
  late final Debouncer _autoSaveDebouncer;
  late final AnimationController _clearAnim;
  late final Animation<double> _clearScale;

  bool _hasText = false;

  @override
  void initState() {
    super.initState();

    _controller = widget.controller ??
        TextEditingController(text: widget.initialValue ?? '');

    _inputDebouncer    = Debouncer(delay: DebounceDuration.input);
    _autoSaveDebouncer = Debouncer(delay: DebounceDuration.autoSave);

    // Micro-scale animation on clear button — spec: "immediate micro-scale
    // adjustments when items clear touch boundaries"
    _clearAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _clearScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _clearAnim, curve: Curves.easeOutBack),
    );

    _hasText = _controller.text.isNotEmpty;
    _controller.addListener(_onControllerChange);

    if (widget.restoreOnMount) _restoreFromCache();
  }

  @override
  void dispose() {
    _inputDebouncer.dispose();
    _autoSaveDebouncer.dispose();
    _clearAnim.dispose();
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  Future<void> _restoreFromCache() async {
    final saved = await FormAutoSaveService.instance.restore(
      formId:   widget.formId,
      fieldKey: widget.fieldKey,
    );
    if (saved != null && saved.isNotEmpty && mounted) {
      _controller.text = saved;
      _controller.selection = TextSelection.collapsed(offset: saved.length);
    }
  }

  void _onControllerChange() {
    final text = _controller.text;
    final hasText = text.isNotEmpty;

    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
      hasText ? _clearAnim.forward() : _clearAnim.reverse();
    }

    // Debounced input callback — 300ms
    _inputDebouncer.run(() => widget.onDebounced?.call(text));

    // Auto-save to local cache — 800ms
    _autoSaveDebouncer.run(() async {
      await FormAutoSaveService.instance.save(
        formId:    widget.formId,
        fieldKey:  widget.fieldKey,
        value:     text,
        minLength: widget.minLength,
        maxLength: widget.maxLength,
      );
      widget.onAutoSaved?.call(text);
    });
  }

  void _onClear() {
    _controller.clear();
    FormAutoSaveService.instance.clear(formId: widget.formId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextFormField(
      controller:   _controller,
      enabled:      widget.enabled,
      obscureText:  widget.obscureText,
      keyboardType: widget.keyboardType,
      maxLength:    widget.maxLength,
      validator:    widget.validator,

      // Spec: single-row vertical flow, 48dp touch target
      decoration: InputDecoration(
        labelText:   widget.label,
        hintText:    widget.hint,
        counterText: '',

        // Spec: sharp dark neutral label tones against clean light surface
        labelStyle: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w500,
        ),

        // Clear button with micro-scale animation
        suffixIcon: ScaleTransition(
          scale: _clearScale,
          child: IconButton(
            icon: const Icon(Icons.cancel_rounded, size: 18),
            tooltip: 'Clear',
            // Spec: 48dp touch target centered inside touch layout box
            constraints: const BoxConstraints(
              minWidth: 48,
              minHeight: 48,
            ),
            onPressed: _onClear,
          ),
        ),
      ),
    );
  }
}
