import 'package:flutter/material.dart';

// ARCPE-008-05 + ARCPE-008-09 — Generative Prompt Template Selectors.
// Spec:
//   - Render individual input text boxes for each prompt variable
//   - Standardized input fields mapped to a hidden prompt string
//   - "Preview Prompt" toggle controller widget
//   - React state combining variables into a single API payload string
//   - 48dp touch targets · WCAG 2.1 AA · MD3 Accessibility Guidelines

// ── Prompt variable model ─────────────────────────────────────────────────────

class PromptVariable {
  const PromptVariable({
    required this.key,
    required this.label,
    this.hint,
    this.required = true,
    this.multiline = false,
    this.maxLength,
  });

  /// Placeholder key in the template string e.g. "{{company_name}}"
  final String key;
  final String label;
  final String? hint;
  final bool required;
  final bool multiline;
  final int? maxLength;
}

// ── Prompt template model ─────────────────────────────────────────────────────

class PromptTemplate {
  const PromptTemplate({
    required this.id,
    required this.name,
    required this.template,
    required this.variables,
  });

  final String id;
  final String name;

  /// Template string with {{variable_key}} placeholders
  final String template;
  final List<PromptVariable> variables;

  /// Resolves template by substituting variable values.
  /// Spec: "combining variables into a single API payload string"
  String resolve(Map<String, String> values) {
    var result = template;
    for (final v in variables) {
      result = result.replaceAll('{{${v.key}}}', values[v.key] ?? '');
    }
    return result;
  }

  /// True when all required variables have values.
  bool isComplete(Map<String, String> values) {
    return variables
        .where((v) => v.required)
        .every((v) => (values[v.key] ?? '').isNotEmpty);
  }
}

// ── Prompt Template Builder widget ───────────────────────────────────────────

class PromptTemplateBuilder extends StatefulWidget {
  const PromptTemplateBuilder({
    super.key,
    required this.template,
    this.initialValues,
    this.onResolved,
    this.onChanged,
  });

  final PromptTemplate template;
  final Map<String, String>? initialValues;

  /// Fires with the fully resolved prompt string when all variables are filled.
  final ValueChanged<String>? onResolved;

  /// Fires on every keystroke with current values map.
  final ValueChanged<Map<String, String>>? onChanged;

  @override
  State<PromptTemplateBuilder> createState() => _PromptTemplateBuilderState();
}

class _PromptTemplateBuilderState extends State<PromptTemplateBuilder> {
  late final Map<String, TextEditingController> _controllers;
  late final Map<String, String> _values;
  bool _previewVisible = false;

  @override
  void initState() {
    super.initState();
    _values = Map.from(widget.initialValues ?? {});
    _controllers = {
      for (final v in widget.template.variables)
        v.key: TextEditingController(text: _values[v.key] ?? ''),
    };
    for (final entry in _controllers.entries) {
      entry.value.addListener(() => _onVariableChanged(entry.key));
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) c.dispose();
    super.dispose();
  }

  void _onVariableChanged(String key) {
    _values[key] = _controllers[key]!.text;
    widget.onChanged?.call(Map.unmodifiable(_values));
    if (widget.template.isComplete(_values)) {
      widget.onResolved?.call(widget.template.resolve(_values));
    }
    setState(() {});
  }

  String get _resolvedPreview => widget.template.resolve(_values);
  bool get _isComplete => widget.template.isComplete(_values);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs    = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Template name header
        Text(
          widget.template.name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),

        // Variable input fields — one per variable
        ...widget.template.variables.map((v) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _VariableField(
            variable:   v,
            controller: _controllers[v.key]!,
          ),
        )),

        const SizedBox(height: 8),

        // "Preview Prompt" toggle — ARCPE-008-09
        _PreviewToggle(
          isVisible: _previewVisible,
          isComplete: _isComplete,
          onToggle: (v) => setState(() => _previewVisible = v),
        ),

        // Preview panel — shows resolved prompt string
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve:    Curves.easeOut,
          child: _previewVisible
              ? _PromptPreviewPanel(resolvedText: _resolvedPreview)
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

// ── Variable input field ──────────────────────────────────────────────────────

class _VariableField extends StatelessWidget {
  const _VariableField({
    required this.variable,
    required this.controller,
  });

  final PromptVariable variable;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextFormField(
      controller:  controller,
      maxLines:    variable.multiline ? 4 : 1,
      maxLength:   variable.maxLength,
      // 48dp minimum height
      decoration:  InputDecoration(
        labelText:   variable.required
            ? '${variable.label} *'
            : variable.label,
        hintText:    variable.hint ?? 'Enter ${variable.label.toLowerCase()}',
        counterText: '',
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical:   14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        // Monospace hint for variable key
        helperText:  '{{${variable.key}}}',
        helperStyle: theme.textTheme.labelSmall?.copyWith(
          fontFamily: 'monospace',
          color: theme.colorScheme.tertiary,
        ),
      ),
    );
  }
}

// ── Preview toggle — ARCPE-008-09 ────────────────────────────────────────────

class _PreviewToggle extends StatelessWidget {
  const _PreviewToggle({
    required this.isVisible,
    required this.isComplete,
    required this.onToggle,
  });

  final bool isVisible;
  final bool isComplete;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs    = theme.colorScheme;

    return SizedBox(
      height: 48, // 48dp touch target
      child: Row(
        children: [
          Text(
            'Preview Prompt',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: cs.primary,
            ),
          ),
          const SizedBox(width: 8),
          if (!isComplete)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: cs.tertiaryContainer,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'Fill all fields first',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: cs.onTertiaryContainer,
                ),
              ),
            ),
          const Spacer(),
          Switch.adaptive(
            value:     isVisible,
            onChanged: isComplete ? onToggle : null,
          ),
        ],
      ),
    );
  }
}

// ── Prompt preview panel ──────────────────────────────────────────────────────

class _PromptPreviewPanel extends StatelessWidget {
  const _PromptPreviewPanel({required this.resolvedText});
  final String resolvedText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs    = theme.colorScheme;

    return Container(
      margin:  const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:        cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border:       Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.smart_toy_rounded, size: 16, color: cs.primary),
              const SizedBox(width: 6),
              Text(
                'Resolved prompt',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SelectableText(
            resolvedText,
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
