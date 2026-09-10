// CBSV-001-A09 — Rigid Layout Schema & Validation Mask Widget.
// Provides user-facing layout fields with pre-calculated validation masks, support pane splits,
// and strict design-token typography/layout bindings for central data dictionary constraints.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum Cbsv001A09LayoutType { fixed, fluid, adaptive }

enum Cbsv001A09Alignment { start, center, end, stretch }

enum Cbsv001A09ValidationStatus { fail, conditionalPass, pass }

class Cbsv001A09LayoutSchemaWidget extends StatefulWidget {
  const Cbsv001A09LayoutSchemaWidget({super.key});

  @override
  State<Cbsv001A09LayoutSchemaWidget> createState() => _Cbsv001A09LayoutSchemaWidgetState();
}

class _Cbsv001A09LayoutSchemaWidgetState extends State<Cbsv001A09LayoutSchemaWidget> {
  final _formKey = GlobalKey<FormState>();
  final _gridController = TextEditingController(text: '12x12');
  final _spacingController = TextEditingController(text: '8');
  final _layoutType = ValueNotifier<Cbsv001A09LayoutType>(Cbsv001A09LayoutType.fixed);
  final _alignment = ValueNotifier<Cbsv001A09Alignment>(Cbsv001A09Alignment.stretch);
  final _validationStatus = ValueNotifier<Cbsv001A09ValidationStatus>(Cbsv001A09ValidationStatus.conditionalPass);

  @override
  void dispose() {
    _gridController.dispose();
    _spacingController.dispose();
    _layoutType.dispose();
    _alignment.dispose();
    _validationStatus.dispose();
    super.dispose();
  }

  Cbsv001A09ValidationStatus _computeStatus() {
    final gridOk = RegExp(r'^\d{1,2}[xX]\d{1,2}$').hasMatch(_gridController.text.trim());
    final spacingOk = RegExp(r'^\d{1,3}(\.\d{1,2})?$').hasMatch(_spacingController.text.trim());
    if (!gridOk || !spacingOk) return Cbsv001A09ValidationStatus.fail;
    return Cbsv001A09ValidationStatus.pass;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Layout Schema Constraints')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 720;
          final form = _buildForm(context);
          final preview = _buildPreview(context);
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: wide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: form),
                        const SizedBox(width: 16),
                        Expanded(child: preview),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        form,
                        const SizedBox(height: 16),
                        preview,
                      ],
                    ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Support Pane', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        ValueListenableBuilder<Cbsv001A09LayoutType>(
          valueListenable: _layoutType,
          builder: (context, value, _) => DropdownButtonFormField<Cbsv001A09LayoutType>(
            value: value,
            decoration: const InputDecoration(labelText: 'Layout Type'),
            items: Cbsv001A09LayoutType.values
                .map((e) => DropdownMenuItem(value: e, child: Text(e.name)))
                .toList(),
            onChanged: (v) {
              if (v != null) _layoutType.value = v;
            },
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _gridController,
          decoration: const InputDecoration(labelText: 'Layout Grid Dimensions'),
          inputFormatters: [
            TextInputFormatter.withFunction((oldValue, newValue) {
              final text = newValue.text;
              if (text.isEmpty) return newValue;
              return RegExp(r'^\d{0,2}[xX]?\d{0,2}$').hasMatch(text) ? newValue : oldValue;
            }),
          ],
          validator: (v) => RegExp(r'^\d{1,2}[xX]\d{1,2}$').hasMatch(v?.trim() ?? '') ? null : 'Use format 12x12',
          onChanged: (_) => _validationStatus.value = _computeStatus(),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _spacingController,
          decoration: const InputDecoration(labelText: 'Spacing Rules (dp)'),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d{0,3}(\.\d{0,2})?')),
          ],
          validator: (v) => RegExp(r'^\d{1,3}(\.\d{1,2})?$').hasMatch(v?.trim() ?? '') ? null : 'Enter spacing in dp',
          onChanged: (_) => _validationStatus.value = _computeStatus(),
        ),
        const SizedBox(height: 12),
        ValueListenableBuilder<Cbsv001A09Alignment>(
          valueListenable: _alignment,
          builder: (context, value, _) => DropdownButtonFormField<Cbsv001A09Alignment>(
            value: value,
            decoration: const InputDecoration(labelText: 'Alignment Settings'),
            items: Cbsv001A09Alignment.values
                .map((e) => DropdownMenuItem(value: e, child: Text(e.name)))
                .toList(),
            onChanged: (v) {
              if (v != null) _alignment.value = v;
            },
          ),
        ),
        const SizedBox(height: 16),
        ValueListenableBuilder<Cbsv001A09ValidationStatus>(
          valueListenable: _validationStatus,
          builder: (context, value, _) => _StatusBadge(status: value),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: () {
            final valid = _formKey.currentState?.validate() ?? false;
            _validationStatus.value = valid ? _computeStatus() : Cbsv001A09ValidationStatus.fail;
          },
          child: const Text('Validate Layout Schema'),
        ),
      ],
    );
  }

  Widget _buildPreview(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Pre-calculated Validation Mask Preview', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            ValueListenableBuilder<Cbsv001A09LayoutType>(
              valueListenable: _layoutType,
              builder: (context, layoutType, _) => ValueListenableBuilder<Cbsv001A09Alignment>(
                valueListenable: _alignment,
                builder: (context, alignment, _) => Container(
                  height: 160,
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).colorScheme.outline),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: switch (alignment) {
                    Cbsv001A09Alignment.start => Alignment.centerLeft,
                    Cbsv001A09Alignment.center => Alignment.center,
                    Cbsv001A09Alignment.end => Alignment.centerRight,
                    Cbsv001A09Alignment.stretch => Alignment.center,
                  },
                  child: Text(
                    '${layoutType.name.toUpperCase()} · ${_gridController.text} · ${_spacingController.text}dp',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final Cbsv001A09ValidationStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      Cbsv001A09ValidationStatus.fail => ('Fail', Theme.of(context).colorScheme.error),
      Cbsv001A09ValidationStatus.conditionalPass => ('Conditional Pass', Colors.orange),
      Cbsv001A09ValidationStatus.pass => ('Pass', Colors.green),
    };
    return Chip(label: Text(label), backgroundColor: color.withOpacity(0.12), side: BorderSide(color: color));
  }
}
