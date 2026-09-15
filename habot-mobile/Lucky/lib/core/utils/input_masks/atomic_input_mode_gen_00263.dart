// GEN-00263 — Atomic Input Mode Binder and Dynamic Form Components.
// Binds HTML/JSON Schema/OpenAPI 3.0 inputMode attributes to Flutter TextInputType configurations,
// enforcing 48dp minimum touch target constraints and M3 engineering console observability.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Enumeration of standard input modes based on WHATWG / JSON Schema Draft 2020-12 / OpenAPI 3.0.
enum UdfInputMode {
  none,
  text,
  decimal,
  numeric,
  tel,
  search,
  email,
  url;

  /// Resolve TextInputType based on current inputMode.
  TextInputType toTextInputType() {
    switch (this) {
      case UdfInputMode.none:
        return TextInputType.none;
      case UdfInputMode.text:
        return TextInputType.text;
      case UdfInputMode.decimal:
        return const TextInputType.numberWithOptions(decimal: true, signed: true);
      case UdfInputMode.numeric:
        return TextInputType.number;
      case UdfInputMode.tel:
        return TextInputType.phone;
      case UdfInputMode.search:
        return TextInputType.text;
      case UdfInputMode.email:
        return TextInputType.emailAddress;
      case UdfInputMode.url:
        return TextInputType.url;
    }
  }

  /// Resolve TextInputAction corresponding to inputMode semantics.
  TextInputAction toTextInputAction() {
    switch (this) {
      case UdfInputMode.search:
        return TextInputAction.search;
      case UdfInputMode.none:
        return TextInputAction.none;
      default:
        return TextInputAction.next;
    }
  }

  /// Parse inputMode from raw JSON Schema or OpenAPI specification map.
  static UdfInputMode fromSchema(Map<String, dynamic>? schema) {
    if (schema == null) return UdfInputMode.text;
    final rawMode = (schema['inputMode'] ?? schema['x-inputMode'])?.toString().toLowerCase().trim();
    if (rawMode != null && rawMode.isNotEmpty) {
      for (final mode in UdfInputMode.values) {
        if (mode.name == rawMode) return mode;
      }
    }

    final format = schema['format']?.toString().toLowerCase().trim();
    final type = schema['type']?.toString().toLowerCase().trim();

    if (format == 'email') return UdfInputMode.email;
    if (format == 'uri' || format == 'url') return UdfInputMode.url;
    if (format == 'tel' || format == 'phone') return UdfInputMode.tel;
    if (type == 'integer') return UdfInputMode.numeric;
    if (type == 'number') return UdfInputMode.decimal;

    return UdfInputMode.text;
  }
}

/// Schema definition evaluation status.
enum SchemaAccuracyStatus {
  complete('Complete'),
  partial('Partial'),
  notComplete('Not Complete');

  final String label;
  const SchemaAccuracyStatus(this.label);
}

/// Schema evaluation result metric.
class SchemaEvaluationResult {
  final String fieldName;
  final UdfInputMode resolvedMode;
  final SchemaAccuracyStatus status;
  final String diagnosticMessage;

  const SchemaEvaluationResult({
    required this.fieldName,
    required this.resolvedMode,
    required this.status,
    required this.diagnosticMessage,
  });
}

/// Atomic input field supporting full inputMode binding with M3 styling and 48dp constraints.
class AtomicInputModeField extends StatelessWidget {
  final String label;
  final UdfInputMode inputMode;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;
  final String? hintText;
  final bool enabled;
  final List<TextInputFormatter>? additionalFormatters;

  const AtomicInputModeField({
    super.key,
    required this.label,
    this.inputMode = UdfInputMode.text,
    this.controller,
    this.onChanged,
    this.validator,
    this.hintText,
    this.enabled = true,
    this.additionalFormatters,
  });

  /// Construct atomic input field bound directly to JSON Schema or OpenAPI field definition.
  factory AtomicInputModeField.fromSchema({
    Key? key,
    required String label,
    required Map<String, dynamic> schema,
    TextEditingController? controller,
    ValueChanged<String>? onChanged,
    String? Function(String?)? validator,
    bool enabled = true,
  }) {
    final mode = UdfInputMode.fromSchema(schema);
    final description = schema['description']?.toString();
    return AtomicInputModeField(
      key: key,
      label: label,
      inputMode: mode,
      controller: controller,
      onChanged: onChanged,
      validator: validator,
      hintText: description,
      enabled: enabled,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 48.0),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        keyboardType: inputMode.toTextInputType(),
        textInputAction: inputMode.toTextInputAction(),
        autocorrect: inputMode == UdfInputMode.text || inputMode == UdfInputMode.search,
        enableSuggestions: inputMode == UdfInputMode.text,
        inputFormatters: _resolveFormatters(),
        onChanged: onChanged,
        validator: validator,
        style: theme.textTheme.bodyLarge,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          filled: true,
          fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: theme.colorScheme.outline),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: theme.colorScheme.primary, width: 2.0),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        ),
      ),
    );
  }

  /// Resolve text input formatters derived from active inputMode.
  List<TextInputFormatter> _resolveFormatters() {
    final formatters = <TextInputFormatter>[];
    if (inputMode == UdfInputMode.numeric) {
      formatters.add(FilteringTextInputFormatter.digitsOnly);
    } else if (inputMode == UdfInputMode.decimal) {
      formatters.add(FilteringTextInputFormatter.allow(RegExp(r'^-?[0-9]*\.?[0-9]*')));
    }
    if (additionalFormatters != null) {
      formatters.addAll(additionalFormatters!);
    }
    return formatters;
  }
}

/// Atomic Checkbox wrapped in guaranteed 48x48dp touch target constraint.
class AtomicCheckbox48dp extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?>? onChanged;
  final Widget? label;

  const AtomicCheckbox48dp({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 48.0, minHeight: 48.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(8.0),
        onTap: onChanged != null ? () => onChanged!(!value) : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 48.0,
                height: 48.0,
                child: Center(
                  child: Checkbox(
                    value: value,
                    onChanged: onChanged,
                    materialTapTargetSize: MaterialTapTargetSize.padded,
                  ),
                ),
              ),
              if (label != null) ...[
                const SizedBox(width: 8.0),
                Flexible(child: label!),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Atomic Radio wrapped in guaranteed 48x48dp touch target constraint.
class AtomicRadio48dp<T> extends StatelessWidget {
  final T value;
  final T? groupValue;
  final ValueChanged<T?>? onChanged;
  final Widget? label;

  const AtomicRadio48dp({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 48.0, minHeight: 48.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(8.0),
        onTap: onChanged != null ? () => onChanged!(value) : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 48.0,
                height: 48.0,
                child: Center(
                  child: Radio<T>(
                    value: value,
                    groupValue: groupValue,
                    onChanged: onChanged,
                    materialTapTargetSize: MaterialTapTargetSize.padded,
                  ),
                ),
              ),
              if (label != null) ...[
                const SizedBox(width: 8.0),
                Flexible(child: label!),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// M3 Engineering Console Step Health Card with KPI metric chip and responsive layout.
class InputModeEngineeringConsoleCard extends StatelessWidget {
  final List<SchemaEvaluationResult> evaluations;
  final VoidCallback? onRefresh;
  final VoidCallback? onDrillDown;

  const InputModeEngineeringConsoleCard({
    super.key,
    required this.evaluations,
    this.onRefresh,
    this.onDrillDown,
  });

  /// Evaluate aggregate health based on individual field accuracy.
  SchemaAccuracyStatus get overallStatus {
    if (evaluations.isEmpty) return SchemaAccuracyStatus.notComplete;
    if (evaluations.any((e) => e.status == SchemaAccuracyStatus.notComplete)) {
      return SchemaAccuracyStatus.partial;
    }
    if (evaluations.every((e) => e.status == SchemaAccuracyStatus.complete)) {
      return SchemaAccuracyStatus.complete;
    }
    return SchemaAccuracyStatus.partial;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 840;
        return Card(
          elevation: 3.0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:
                            [
                          Text(
                            'GEN-00263: Atomic inputMode Binding',
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            'OpenAPI 3.0 & JSON Schema (Draft 2020-12) Compliance',
                            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusChip(theme, overallStatus),
                  ],
                ),
                const Divider(height: 24.0),
                if (isDesktop)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildMetricsSummary(theme)),
                      const SizedBox(width: 16.0),
                      Expanded(child: _buildFieldList(theme)),
                    ],
                  )
                else ...[
                  _buildMetricsSummary(theme),
                  const SizedBox(height: 12.0),
                  _buildFieldList(theme),
                ],
                const SizedBox(height: 12.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (onRefresh != null)
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        tooltip: 'Sync Schema (Pull)',
                        onPressed: onRefresh,
                      ),
                    if (onDrillDown != null)
                      TextButton.icon(
                        icon: const Icon(Icons.open_in_new, size: 18.0),
                        label: const Text('View BigQuery Telemetry'),
                        onPressed: onDrillDown,
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Build summary KPI metric counters.
  Widget _buildMetricsSummary(ThemeData theme) {
    final completedCount = evaluations.where((e) => e.status == SchemaAccuracyStatus.complete).length;
    final totalCount = evaluations.length;

    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Schema Field Accuracy', style: theme.textTheme.labelMedium),
          const SizedBox(height: 4.0),
          Text(
            '$completedCount / $totalCount Fields Configured',
            style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2.0),
          Text(
            'Threshold: Fully documented and typed (Draft 2020-12)',
            style: theme.textTheme.bodySmall?.copyWith(fontSize: 11.0),
          ),
        ],
      ),
    );
  }

  /// Build list of evaluated input fields.
  Widget _buildFieldList(ThemeData theme) {
    if (evaluations.isEmpty) {
      return const Text('No fields currently configured.');
    }
    return Column(
      children: evaluations.take(4).map((eval) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              Icon(
                eval.status == SchemaAccuracyStatus.complete
                    ? Icons.check_circle_outline
                    : Icons.warning_amber_rounded,
                size: 16.0,
                color: eval.status == SchemaAccuracyStatus.complete
                    ? Colors.green
                    : Colors.amber[800],
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: Text(
                  '${eval.fieldName} (${eval.resolvedMode.name})',
                  style: theme.textTheme.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                eval.status.label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: eval.status == SchemaAccuracyStatus.complete ? Colors.green[700] : Colors.amber[900],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// Build Material 3 status chip indicating completion state.
  Widget _buildStatusChip(ThemeData theme, SchemaAccuracyStatus status) {
    Color bg;
    Color fg;
    switch (status) {
      case SchemaAccuracyStatus.complete:
        bg = Colors.green.withOpacity(0.15);
        fg = Colors.green[800]!;
        break;
      case SchemaAccuracyStatus.partial:
        bg = Colors.amber.withOpacity(0.15);
        fg = Colors.amber[900]!;
        break;
      case SchemaAccuracyStatus.notComplete:
        bg = theme.colorScheme.errorContainer;
        fg = theme.colorScheme.onErrorContainer;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16.0)),
      child: Text(
        status.label,
        style: theme.textTheme.labelSmall?.copyWith(color: fg, fontWeight: FontWeight.bold),
      ),
    );
  }
}
