// FIEVR-028-A02 — Dynamic Form Renderer Engine.
// Ingests clean metadata instruction profiles from parent task state objects, systematically
// validating schemas (self-chasing) and discarding undefined inputs (poka-yoke) to render responsive,
// accessible Material Design 3 form controls with telemetry logging.

import 'dart:convert';
import 'package:flutter/material.dart';

/// Execution and Telemetry model capturing lifecycle events of dynamic form steps.
class FormTelemetryEvent {
  final String stepExecutionId;
  final String executionStatus;
  final DateTime executionTimestamp;
  final String stepOutcome;
  final String userId;
  final String completionStatus; // 'Pass' | 'Fail'
  final DateTime actionTimestamp;
  final String sessionId;
  final Map<String, dynamic>? metadata;

  const FormTelemetryEvent({
    required this.stepExecutionId,
    required this.executionStatus,
    required this.executionTimestamp,
    required this.stepOutcome,
    required this.userId,
    required this.completionStatus,
    required this.actionTimestamp,
    required this.sessionId,
    this.metadata,
  });

  Map<String, dynamic> toJson() => {
    'stepExecutionId': stepExecutionId,
    'executionStatus': executionStatus,
    'executionTimestamp': executionTimestamp.toIso8601String(),
    'stepOutcome': stepOutcome,
    'userId': userId,
    'completionStatus': completionStatus,
    'actionTimestamp': actionTimestamp.toIso8601String(),
    'sessionId': sessionId,
    if (metadata != null) 'metadata': metadata,
  };
}

/// Field configuration metadata ingested from parent task state objects.
class DynamicFieldInstruction {
  final String fieldId;
  final String label;
  final String fieldType; // 'text', 'number', 'select', 'date', 'switch'
  final String? placeholder;
  final String? helperText;
  final bool isRequired;
  final List<String>? options;
  final dynamic defaultValue;

  const DynamicFieldInstruction({
    required this.fieldId,
    required this.label,
    required this.fieldType,
    this.placeholder,
    this.helperText,
    this.isRequired = false,
    this.options,
    this.defaultValue,
  });

  factory DynamicFieldInstruction.fromJson(Map<String, dynamic> json) {
    final id = json['fieldId'] as String?;
    final label = json['label'] as String?;
    final type = json['fieldType'] as String?;

    if (id == null || id.trim().isEmpty) {
      throw const FormatException('DynamicFieldInstruction missing valid fieldId');
    }
    if (label == null || label.trim().isEmpty) {
      throw const FormatException('DynamicFieldInstruction missing valid label');
    }
    if (type == null || type.trim().isEmpty) {
      throw const FormatException('DynamicFieldInstruction missing valid fieldType');
    }

    return DynamicFieldInstruction(
      fieldId: id,
      label: label,
      fieldType: type,
      placeholder: json['placeholder'] as String?,
      helperText: json['helperText'] as String?,
      isRequired: json['isRequired'] as bool? ?? false,
      options: (json['options'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      defaultValue: json['defaultValue'],
    );
  }
}

/// Schema definition for a step sequence profile.
class DynamicStepInstruction {
  final String stepId;
  final String title;
  final String? description;
  final List<DynamicFieldInstruction> fields;

  const DynamicStepInstruction({
    required this.stepId,
    required this.title,
    this.description,
    required this.fields,
  });

  factory DynamicStepInstruction.fromJson(Map<String, dynamic> json) {
    final id = json['stepId'] as String?;
    final title = json['title'] as String?;
    final rawFields = json['fields'] as List<dynamic>?;

    if (id == null || id.trim().isEmpty) {
      throw const FormatException('DynamicStepInstruction missing stepId');
    }
    if (title == null || title.trim().isEmpty) {
      throw const FormatException('DynamicStepInstruction missing title');
    }
    if (rawFields == null) {
      throw const FormatException('DynamicStepInstruction missing field definitions');
    }

    return DynamicStepInstruction(
      stepId: id,
      title: title,
      description: json['description'] as String?,
      fields: rawFields
          .map((f) => DynamicFieldInstruction.fromJson(f as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Orchestrator and renderer engine for dynamic task step forms.
class DynamicFormAssembler extends StatefulWidget {
  final Map<String, dynamic> rawInstructionProfile;
  final Map<String, dynamic> activeDatabasePacket;
  final String userId;
  final String sessionId;
  final void Function(FormTelemetryEvent event)? onTelemetryLogged;
  final void Function(Map<String, dynamic> finalFormValues)? onFormCompleted;

  const DynamicFormAssembler({
    super.key,
    required this.rawInstructionProfile,
    required this.activeDatabasePacket,
    required this.userId,
    required this.sessionId,
    this.onTelemetryLogged,
    this.onFormCompleted,
  });

  @override
  State<DynamicFormAssembler> createState() => _DynamicFormAssemblerState();
}

class _DynamicFormAssemblerState extends State<DynamicFormAssembler> {
  static const double _verticalItemSpacing = 16.0;
  static const double _standardCardPadding = 20.0;

  List<DynamicStepInstruction> _validatedSteps = const [];
  String? _schemaErrorMessage;
  int _currentStepIndex = 0;
  final Map<String, dynamic> _formData = {};
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _executeSelfChasingValidation();
  }

  @override
  void didUpdateWidget(covariant DynamicFormAssembler oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.rawInstructionProfile != widget.rawInstructionProfile ||
        oldWidget.activeDatabasePacket != widget.activeDatabasePacket) {
      _executeSelfChasingValidation();
    }
  }

  /// Self-chasing validation: aborts layout compilation if schema is broken.
  /// Mistake-proofing (Poka-Yoke): strictly filters out fields absent from the database packet
  /// unless initialized or validly mapped.
  void _executeSelfChasingValidation() {
    try {
      final stepsRaw = widget.rawInstructionProfile['steps'] as List<dynamic>?;
      if (stepsRaw == null || stepsRaw.isEmpty) {
        throw const FormatException('Schema violation: instruction profile lacks valid "steps" list.');
      }

      final parsedSteps = <DynamicStepInstruction>[];
      for (final s in stepsRaw) {
        if (s is! Map<String, dynamic>) {
          throw const FormatException('Malformed step object in schema.');
        }
        final step = DynamicStepInstruction.fromJson(s);

        // Poka-Yoke filter: compile only fields that exist in activeDatabasePacket
        // or have explicit default declarations in the validated profile.
        final allowedFields = step.fields.where((f) {
          final existsInDb = widget.activeDatabasePacket.containsKey(f.fieldId);
          final hasDefault = f.defaultValue != null;
          return existsInDb || hasDefault;
        }).toList();

        parsedSteps.add(DynamicStepInstruction(
          stepId: step.stepId,
          title: step.title,
          description: step.description,
          fields: allowedFields,
        ));
      }

      // Populate existing active database values into state
      for (final step in parsedSteps) {
        for (final field in step.fields) {
          if (widget.activeDatabasePacket.containsKey(field.fieldId)) {
            _formData[field.fieldId] = widget.activeDatabasePacket[field.fieldId];
          } else if (field.defaultValue != null) {
            _formData[field.fieldId] = field.defaultValue;
          }
        }
      }

      setState(() {
        _validatedSteps = parsedSteps;
        _schemaErrorMessage = null;
      });

      _logTelemetry(
        stepExecutionId: parsedSteps.isNotEmpty ? parsedSteps.first.stepId : 'INIT',
        executionStatus: 'SCHEMA_VALIDATED',
        stepOutcome: 'Schema successfully compiled',
        completionStatus: 'Pass',
      );
    } catch (e, stack) {
      setState(() {
        _validatedSteps = const [];
        _schemaErrorMessage = 'Dynamic Interface Layout Terminated: ${e.toString()}';
      });

      _logTelemetry(
        stepExecutionId: 'SCHEMA_FAILURE',
        executionStatus: 'SCHEMA_CORRUPTED',
        stepOutcome: e.toString(),
        completionStatus: 'Fail',
        metadata: {'stackTrace': stack.toString()},
      );
    }
  }

  void _logTelemetry({
    required String stepExecutionId,
    required String executionStatus,
    required String stepOutcome,
    required String completionStatus,
    Map<String, dynamic>? metadata,
  }) {
    final now = DateTime.now();
    final event = FormTelemetryEvent(
      stepExecutionId: stepExecutionId,
      executionStatus: executionStatus,
      executionTimestamp: now,
      stepOutcome: stepOutcome,
      userId: widget.userId,
      completionStatus: completionStatus,
      actionTimestamp: now,
      sessionId: widget.sessionId,
      metadata: metadata,
    );
    widget.onTelemetryLogged?.call(event);
  }

  void _handleNextStep() {
    if (!_formKey.currentState!.validate()) {
      _logTelemetry(
        stepExecutionId: _currentStep.stepId,
        executionStatus: 'VALIDATION_FAILED',
        stepOutcome: 'Required fields missing or invalid',
        completionStatus: 'Fail',
      );
      return;
    }

    _formKey.currentState!.save();

    if (_currentStepIndex < _validatedSteps.length - 1) {
      _logTelemetry(
        stepExecutionId: _currentStep.stepId,
        executionStatus: 'STEP_TRANSITION',
        stepOutcome: 'Advanced to next step',
        completionStatus: 'Pass',
      );
      setState(() {
        _currentStepIndex++;
      });
    } else {
      _logTelemetry(
        stepExecutionId: _currentStep.stepId,
        executionStatus: 'WORKFLOW_COMPLETE',
        stepOutcome: 'All form steps finished',
        completionStatus: 'Pass',
        metadata: {'submittedValues': _formData},
      );
      widget.onFormCompleted?.call(Map<String, dynamic>.unmodifiable(_formData));
    }
  }

  void _handlePreviousStep() {
    if (_currentStepIndex > 0) {
      _logTelemetry(
        stepExecutionId: _currentStep.stepId,
        executionStatus: 'STEP_REGRESSION',
        stepOutcome: 'Returned to previous step',
        completionStatus: 'Pass',
      );
      setState(() {
        _currentStepIndex--;
      });
    }
  }

  DynamicStepInstruction get _currentStep => _validatedSteps[_currentStepIndex];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_schemaErrorMessage != null) {
      return _buildBrokenSchemaSurface(theme);
    }

    if (_validatedSteps.isEmpty) {
      return _buildEmptySurface(theme);
    }

    final step = _currentStep;
    final isLastStep = _currentStepIndex == _validatedSteps.length - 1;
    final isFirstStep = _currentStepIndex == 0;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child:
            LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
          final bool isWide = constraints.maxWidth >= 720;
          final horizontalPadding = isWide ? 48.0 : 16.0;

          return Form(
            key: _formKey,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: 24.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStepIndicator(theme),
                        const SizedBox(height: 12),
                        Text(
                          step.title,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (step.description != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            step.description!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  sliver: SliverToBoxAdapter(
                    child: _buildUniformStructuralContainer(
                      theme: theme,
                      child: step.fields.isEmpty
                          ? _buildEmptyFieldsCell(theme)
                          : _buildFieldList(step.fields, theme),
                    ),
                  ),
                ),
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: 24.0,
                    ),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: _buildNavigationControls(
                        theme: theme,
                        isFirstStep: isFirstStep,
                        isLastStep: isLastStep,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStepIndicator(ThemeData theme) {
    return Row(
      children: List.generate(_validatedSteps.length, (index) {
        final isActive = index == _currentStepIndex;
        final isCompleted = index < _currentStepIndex;
        final color = isActive
            ? theme.colorScheme.primary
            : (isCompleted
                ? theme.colorScheme.primaryContainer
                : theme.colorScheme.surfaceContainerHighest);
        return Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.only(right: index == _validatedSteps.length - 1 ? 0 : 6),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildUniformStructuralContainer({
    required ThemeData theme,
    required Widget child,
  }) {
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(_standardCardPadding),
        child: child,
      ),
    );
  }

  Widget _buildFieldList(List<DynamicFieldInstruction> fields, ThemeData theme) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: fields.length,
      separatorBuilder: (_, __) => const SizedBox(height: _verticalItemSpacing),
      itemBuilder: (context, index) {
        final field = fields[index];
        return _renderDynamicComponent(field, theme);
      },
    );
  }

  Widget _renderDynamicComponent(DynamicFieldInstruction field, ThemeData theme) {
    switch (field.fieldType.toLowerCase()) {
      case 'number':
        return _buildTextFormField(
          field,
          keyboardType: TextInputType.number,
        );
      case 'select':
        return _buildDropdownFormField(field, theme);
      case 'switch':
        return _buildSwitchFormField(field, theme);
      case 'text':
      default:
        return _buildTextFormField(
          field,
          keyboardType: TextInputType.text,
        );
    }
  }

  Widget _buildTextFormField(
    DynamicFieldInstruction field,
    {required TextInputType keyboardType}
  ) {
    return TextFormField(
      initialValue: _formData[field.fieldId]?.toString() ?? '',
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: field.label,
        hintText: field.placeholder ?? 'Enter ${field.label.toLowerCase()}',
        helperText: field.helperText,
        border: const OutlineInputBorder(),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
      ),
      validator: (value) {
        if (field.isRequired && (value == null || value.trim().isEmpty)) {
          return '${field.label} is required.';
        }
        return null;
      },
      onSaved: (value) {
        _formData[field.fieldId] = value;
      },
    );
  }

  Widget _buildDropdownFormField(DynamicFieldInstruction field, ThemeData theme) {
    final options = field.options ?? [];
    final currentValue = _formData[field.fieldId]?.toString();
    final validValue = options.contains(currentValue) ? currentValue : null;

    return DropdownButtonFormField<String>(
      value: validValue,
      decoration: InputDecoration(
        labelText: field.label,
        hintText: field.placeholder ?? 'Select an option',
        helperText: field.helperText,
        border: const OutlineInputBorder(),
      ),
      items: options
          .map((opt) => DropdownMenuItem(value: opt, child: Text(opt)))
          .toList(),
      validator: (value) {
        if (field.isRequired && (value == null || value.isEmpty)) {
          return 'Please select ${field.label.toLowerCase()}.';
        }
        return null;
      },
      onChanged: (newValue) {
        setState(() {
          _formData[field.fieldId] = newValue;
        });
      },
    );
  }

  Widget _buildSwitchFormField(DynamicFieldInstruction field, ThemeData theme) {
    final bool isChecked = _formData[field.fieldId] == true;
    return SwitchListTile(
      title: Text(field.label),
      subtitle: field.helperText != null ? Text(field.helperText!) : null,
      value: isChecked,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onChanged: (bool val) {
        setState(() {
          _formData[field.fieldId] = val;
        });
      },
    );
  }

  Widget _buildEmptyFieldsCell(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined, size: 36, color: theme.colorScheme.outline),
            const SizedBox(height: 8),
            Text(
              'No active fields required for this step.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

  Widget _buildNavigationControls({
    required ThemeData theme,
    required bool isFirstStep,
    required bool isLastStep,
  }) {
    return Row(
      children: [
        if (!isFirstStep)
          Expanded(
            child: OutlinedButton(
              onPressed: _handlePreviousStep,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Back'),
            ),
          ),
        if (!isFirstStep) const SizedBox(width: 16),
        Expanded(
          child: FilledButton(
            onPressed: _handleNextStep,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(isLastStep ? 'Submit' : 'Continue'),
          ),
        ),
      ],
    );
  }

  Widget _buildBrokenSchemaSurface(ThemeData theme) {
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              color: theme.colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
                    const SizedBox(height: 16),
                    Text(
                      'Layout Rendering Aborted',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onErrorContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _schemaErrorMessage ?? 'Corrupted metadata definition.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onErrorContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptySurface(ThemeData theme) {
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: Text(
            'No step layout instructions available.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
