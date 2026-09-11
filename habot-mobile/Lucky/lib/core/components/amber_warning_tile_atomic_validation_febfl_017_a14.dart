// FEBFL-017-A14 — Amber Warning Tile & Atomic Card Selection Component.
// Implements Material Design 3 amber warning tiles with card-based selection,
// 8dp uniform spacing, and input validation with character limits.

import 'package:flutter/material';
import 'package:flutter/services.dart';

/// Represents a single atomic validation model for one-line-one-action.
class AtomicValidationModel {
  final String id;
  final String label;
  final String? value;
  final int maxLength;
  final List<TextInputFormatter> formatters;
  final bool isSelected;

  const AtomicValidationModel({
    required this.id,
    required this.label,
    this.value,
    this.maxLength = 200,
    this.formatters = const [],
    this.isSelected = false,
  });
}

/// Card selection component for tap-driven choices.
class AtomicCardSelection extends StatelessWidget {
  final AtomicValidationModel model;
  final VoidCallback onTap;

  const AtomicCardSelection({
    super.key,
    required this.model,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: model.isSelected ? 4 : 1,
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: model.isSelected ? colorScheme.primary : colorScheme.outlineVariant,
          width: model.isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    model.isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: model.isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      model.label,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: model.isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
              if (model.value != null && model.value!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  model.value!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Amber warning tile component using Material Design 3 contextual style.
class AmberWarningTile extends StatelessWidget {
  final String title;
  final String message;
  final IconData? icon;
  final VoidCallback? onDismiss;

  const AmberWarningTile({
    super.key,
    required this.title,
    required this.message,
    this.icon,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.amber.shade300,
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon ?? Icons.warning_amber_rounded,
            color: Colors.amber.shade800,
            size: 24,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: Colors.amber.shade900,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.amber.shade900,
                  ),
                ),
              ],
            ),
          ),
          if (onDismiss != null) ...[
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.close, size: 16),
              onPressed: onDismiss,
              visualDensity: VisualDensity.compact,
            ),
          ],
        ],
      ),
    );
  }
}

/// Atomic input field with character limits and formatting patterns.
class AtomicInputField extends StatelessWidget {
  final AtomicValidationModel model;
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  const AtomicInputField({
    super.key,
    required this.model,
    required this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                model.label,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              '${controller.text.length}/${model.maxLength}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: controller.text.length >= model.maxLength
                    ? colorScheme.error
                    : colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          onChanged: onChanged,
          maxLength: model.maxLength,
          inputFormatters: [
            LengthLimitingTextInputFormatter(model.maxLength),
            ...model.formatters,
          ],
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.all(8),
            isDense: true,
          ),
        ),
      ],
    );
  }
}

/// Main atomic validation screen with card selection and warning tiles.
class AtomicValidationScreen extends StatefulWidget {
  final List<AtomicValidationModel> models;
  final VoidCallback? onSubmit;

  const AtomicValidationScreen({
    super.key,
    required this.models,
    this.onSubmit,
  });

  @override
  State<AtomicValidationScreen> createState() => _AtomicValidationScreenState();
}

class _AtomicValidationScreenState extends State<AtomicValidationScreen> {
  late List<AtomicValidationModel> _models;
  late List<TextEditingController> _controllers;
  bool _showWarning = false;

  @override
  void initState() {
    super.initState();
    _models = widget.models.map((m) => AtomicValidationModel(
      id: m.id,
      label: m.label,
      value: m.value,
      maxLength: m.maxLength,
      formatters: m.formatters,
      isSelected: m.isSelected,
    )).toList();
    _controllers = _models.map((_) => TextEditingController()).toList();
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _toggleSelection(int index) {
    setState(() {
      for (int i = 0; i < _models.length; i++) {
        _models[i] = AtomicValidationModel(
          id: _models[i].id,
          label: _models[i].label,
          value: _models[i].value,
          maxLength: _models[i].maxLength,
          formatters: _models[i].formatters,
          isSelected: i == index,
        );
      }
    });
  }

  void _handleSubmit() {
    for (int i = 0; i < _models.length; i++) {
      if (_models[i].isSelected && _controllers[i].text.isEmpty) {
        setState(() => _showWarning = true);
        return;
      }
    }
    widget.onSubmit?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Posting Setup'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_showWarning) ...[
                AmberWarningTile(
                  title: 'Validation Required',
                  message: 'Please complete all required fields before submitting.',
                  onDismiss: () => setState(() => _showWarning = false),
                ),
                const SizedBox(height: 8),
              ],
              Text(
                'Select an option:',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 2.5,
                ),
                itemCount: _models.length,
                itemBuilder: (context, index) {
                  return AtomicCardSelection(
                    model: _models[index],
                    onTap: () => _toggleSelection(index),
                  );
                },
              ),
              const SizedBox(height: 8),
              if (_models.any((m) => m.isSelected)) ...[
                for (int i = 0; i < _models.length; i++)
                  if (_models[i].isSelected) ...[
                    AtomicInputField(
                      model: _models[i],
                      controller: _controllers[i],
                      onChanged: (value) {
                        setState(() {
                          _models[i] = AtomicValidationModel(
                            id: _models[i].id,
                            label: _models[i].label,
                            value: value,
                            maxLength: _models[i].maxLength,
                            formatters: _models[i].formatters,
                            isSelected: _models[i].isSelected,
                          );
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                  ],
              ],
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _handleSubmit,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}