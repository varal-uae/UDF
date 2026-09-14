// FIEVR-028-A09 — Dynamic Form Renderer Engine (DynamicFormAssembler).
// Orchestrates dynamic schema-driven form layouts by mapping interface background surfaces to uniform structural design system containers, enforcing Poka-Yoke schema validation and strict vertical padding increments.

import 'package:flutter/material.dart';

/// Schema definition for individual dynamic form field descriptors.
@immutable
class FormFieldDescriptor {
  const FormFieldDescriptor({
    required this.fieldId,
    required this.fieldType,
    required this.label,
    this.placeholder,
    this.initialValue,
    this.options = const [],
    this.isRequired = false,
    this.validationPattern,
    this.tokenValues = const {},
  });

  final String fieldId;
  final String fieldType; // 'text', 'number', 'dropdown', 'switch', 'placeholder'
  final String label;
  final String? placeholder;
  final dynamic initialValue;
  final List<String> options;
  final bool isRequired;
  final String? validationPattern;
  final Map<String, dynamic> tokenValues;

  factory FormFieldDescriptor.fromJson(Map<String, dynamic> json) {
    if (!json.containsKey('fieldId') || !json.containsKey('fieldType')) {
      throw FormatException('Corrupted field schema: missing fieldId or fieldType', json);
    }
    return FormFieldDescriptor(
      fieldId: json['fieldId'] as String,
      fieldType: json['fieldType'] as String,
      label: (json['label'] as String?) ?? 'Unnamed Field',
      placeholder: json['placeholder'] as String?,
      initialValue: json['initialValue'],
      options: (json['options'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      isRequired: json['isRequired'] as bool? ?? false,
      validationPattern: json['validationPattern'] as String?,
      tokenValues: (json['tokenValues'] as Map<String, dynamic>?) ?? const {},
    );
  }

  Map<String, dynamic> toJson() => {
        'fieldId': fieldId,
        'fieldType': fieldType,
        'label': label,
        if (placeholder != null) 'placeholder': placeholder,
        if (initialValue != null) 'initialValue': initialValue,
        'options': options,
        'isRequired': isRequired,
        if (validationPattern != null) 'validationPattern': validationPattern,
        'tokenValues': tokenValues,
      };
}

/// System configuration packet required for Dynamic Form Assembly.
@immutable
class DynamicFormConfiguration {
  const DynamicFormConfiguration({
    required this.systemName,
    required this.systemVersion,
    required this.componentList,
    this.tokenValues = const {},
    this.documentationLinks = const [],
    this.systemConfigurationDetails = const {},
    this.userSessionId = 'anon-session',
  });

  final String systemName;
  final String systemVersion;
  final List<FormFieldDescriptor> componentList;
  final Map<String, dynamic> tokenValues;
  final List<String> documentationLinks;
  final Map<String, dynamic> systemConfigurationDetails;
  final String userSessionId;

  /// Self-Chasing & Poka-Yoke parser: rejects broken payloads outright.
  factory DynamicFormConfiguration.fromRawJson(Map<String, dynamic> json) {
    if (json.isEmpty) {
      throw const FormatException('Empty payload violates Poka-Yoke validation rules.');
    }
    final sysName = json['systemName'] as String?;
    final sysVersion = json['systemVersion'] as String?;
    final rawList = json['componentList'] as List<dynamic>?;

    if (sysName == null || sysVersion == null || rawList == null) {
      throw const FormatException(
        'Broken schema detected: systemName, systemVersion, and componentList are mandatory.',
      );
    }

    final List<FormFieldDescriptor> components = [];
    for (final item in rawList) {
      if (item is! Map<String, dynamic>) {
        throw const FormatException('Child layout element violates schema: non-map element found.');
      }
      components.add(FormFieldDescriptor.fromJson(item));
    }

    return DynamicFormConfiguration(
      systemName: sysName,
      systemVersion: sysVersion,
      componentList: components,
      tokenValues: (json['tokenValues'] as Map<String, dynamic>?) ?? const {},
      documentationLinks: (json['documentationLinks'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      systemConfigurationDetails: (json['systemConfigurationDetails'] as Map<String, dynamic>?) ?? const {},
      userSessionId: (json['userSessionId'] as String?) ?? 'session-${DateTime.now().millisecondsSinceEpoch}',
    );
  }
}

/// Telemetry summary emitted upon layout operations.
@immutable
class FormTelemetryEvent {
  const FormTelemetryEvent({
    required this.systemName,
    required this.systemVersion,
    required this.componentCount,
    required this.completionStatus,
    required this.timestamp,
    required this.userSessionId,
    required this.mappingAccuracyPercentage,
  });

  final String systemName;
  final String systemVersion;
  final int componentCount;
  final String completionStatus; // 'Complete', 'Partial', 'Not Complete'
  final DateTime timestamp;
  final String userSessionId;
  final double mappingAccuracyPercentage;
}

/// DynamicFormAssembler renders form views cleanly from schema definitions.
class DynamicFormAssembler extends StatefulWidget {
  const DynamicFormAssembler({
    super.key,
    required this.configuration,
    this.onFormSubmit,
    this.onTelemetryEmitted,
    this.verticalSpacing = 16.0,
    this.pressedStateColor = const Color(0x1F6200EE),
    this.pressedAnimationDuration = const Duration(milliseconds: 150),
  });

  final DynamicFormConfiguration configuration;
  final void Function(Map<String, dynamic> values)? onFormSubmit;
  final void Function(FormTelemetryEvent telemetry)? onTelemetryEmitted;
  final double verticalSpacing;
  final Color pressedStateColor;
  final Duration pressedAnimationDuration;

  @override
  State<DynamicFormAssembler> createState() => _DynamicFormAssemblerState();
}

class _DynamicFormAssemblerState extends State<DynamicFormAssembler> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formValues = {};
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initializeValues();
    _emitInitialTelemetry();
  }

  void _initializeValues() {
    for (final field in widget.configuration.componentList) {
      if (field.initialValue != null) {
        _formValues[field.fieldId] = field.initialValue;
      }
    }
  }

  void _emitInitialTelemetry() {
    final total = widget.configuration.componentList.length;
    final mapped = widget.configuration.componentList.where((c) => c.fieldId.isNotEmpty).length;
    final accuracy = total == 0 ? 100.0 : (mapped / total) * 100.0;

    final event = FormTelemetryEvent(
      systemName: widget.configuration.systemName,
      systemVersion: widget.configuration.systemVersion,
      componentCount: total,
      completionStatus: total > 0 ? 'Complete' : 'Not Complete',
      timestamp: DateTime.now(),
      userSessionId: widget.configuration.userSessionId,
      mappingAccuracyPercentage: accuracy,
    );

    widget.onTelemetryEmitted?.call(event);
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      widget.onFormSubmit?.call(Map<String, dynamic>.unmodifiable(_formValues));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Poka-Yoke & Self-Chasing: completely absent elements produce an empty or graceful surface
    if (widget.configuration.componentList.isEmpty) {
      return _buildEmptyContainer(context, 'No active schema fields configured for this layout.');
    }

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 1.0,
        ),
      ),
      padding: const EdgeInsets.all(20.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context),
            SizedBox(height: widget.verticalSpacing),
            ...widget.configuration.componentList.map((field) {
              return Padding(
                padding: EdgeInsets.only(bottom: widget.verticalSpacing),
                child: _buildFieldComponent(context, field),
              );
            }),
            const SizedBox(height: 8.0),
            _buildSubmitButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.configuration.systemName,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 2.0),
        Text(
          'Engine v${widget.configuration.systemVersion}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildFieldComponent(BuildContext context, FormFieldDescriptor field) {
    switch (field.fieldType) {
      case 'text':
        return _buildTextField(context, field);
      case 'number':
        return _buildTextField(context, field, isNumeric: true);
      case 'dropdown':
        return _buildDropdownField(context, field);
      case 'switch':
        return _buildSwitchField(context, field);
      case 'placeholder':
      default:
        return _buildPlaceholderCell(context, field);
    }
  }

  Widget _buildTextField(BuildContext context, FormFieldDescriptor field, {bool isNumeric = false}) {
    return TextFormField(
      initialValue: _formValues[field.fieldId]?.toString() ?? '',
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: field.label,
        hintText: field.placeholder ?? 'Enter ${field.label.toLowerCase()}',
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      validator: (value) {
        if (field.isRequired && (value == null || value.trim().isEmpty)) {
          return '${field.label} is required';
        }
        if (field.validationPattern != null && value != null && value.isNotEmpty) {
          final regex = RegExp(field.validationPattern!);
          if (!regex.hasMatch(value)) {
            return 'Invalid value for ${field.label}';
          }
        }
        return null;
      },
      onSaved: (val) {
        _formValues[field.fieldId] = isNumeric ? num.tryParse(val ?? '') : val;
      },
    );
  }

  Widget _buildDropdownField(BuildContext context, FormFieldDescriptor field) {
    final currentValue = _formValues[field.fieldId] as String?;
    final hasMatch = field.options.contains(currentValue);

    return DropdownButtonFormField<String>(
      value: hasMatch ? currentValue : null,
      decoration: InputDecoration(
        labelText: field.label,
        hintText: field.placeholder ?? 'Select ${field.label.toLowerCase()}',
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      items: field.options.map((opt) {
        return DropdownMenuItem<String>(
          value: opt,
          child: Text(opt),
        );
      }).toList(),
      validator: (value) {
        if (field.isRequired && (value == null || value.isEmpty)) {
          return 'Please select ${field.label}';
        }
        return null;
      },
      onChanged: (val) {
        setState(() {
          _formValues[field.fieldId] = val;
        });
      },
    );
  }

  Widget _buildSwitchField(BuildContext context, FormFieldDescriptor field) {
    final bool isChecked = _formValues[field.fieldId] as bool? ?? false;
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      borderRadius: BorderRadius.circular(8.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(8.0),
        splashColor: widget.pressedStateColor,
        onTap: () {
          setState(() {
            _formValues[field.fieldId] = !isChecked;
          });
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                field.label,
                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              Switch(
                value: isChecked,
                onChanged: (val) {
                  setState(() {
                    _formValues[field.fieldId] = val;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Render explicit placeholder details inside empty data cells
  Widget _buildPlaceholderCell(BuildContext context, FormFieldDescriptor field) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
          style: BorderStyle.solid,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 20.0, color: theme.colorScheme.outline),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              field.placeholder ?? '[Empty cell: ${field.label}]',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyContainer(BuildContext context, String message) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Center(
        child: Text(
          message,
          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return AnimatedContainer(
      duration: widget.pressedAnimationDuration,
      child: ElevatedButton(
        onPressed: _isProcessing ? null : _submit,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        child: _isProcessing
            ? const SizedBox(
                height: 20.0,
                width: 20.0,
                child: CircularProgressIndicator(strokeWidth: 2.0),
              )
            : const Text('Submit Form'),
      ),
    );
  }
}
