// EDEBS-006-20 — Adaptive Configuration Modal Sheet with edge-swipe dismiss and 48dp touch targets.
// Provides desktop dialog sheets that become full-screen mobile sub-views; enforces single-column M3 body-medium layout.

import 'package:flutter/material.dart';

class ConfigurationModalSheet extends StatefulWidget {
  const ConfigurationModalSheet({
    super.key,
    required this.title,
    required this.fields,
  });

  final String title;
  final List<ConfigurationField> fields;

  static Future<void> show(
    BuildContext context, {
    required String title,
    required List<ConfigurationField> fields,
  }) async {
    final isDesktop = MediaQuery.sizeOf(context).width >= 720;
    if (isDesktop) {
      await showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (_) => Dialog(
          insetPadding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ConfigurationModalSheet(title: title, fields: fields),
          ),
        ),
      );
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => Scaffold(
          appBar: AppBar(title: Text(title)),
          body: SafeArea(
            child: ConfigurationModalSheet(title: title, fields: fields),
          ),
        ),
      ),
    );
  }

  @override
  State<ConfigurationModalSheet> createState() =>
      _ConfigurationModalSheetState();
}

class _ConfigurationModalSheetState extends State<ConfigurationModalSheet> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return EdgeSwipeDismissible(
      onDismiss: () {
        Navigator.of(context).maybePop();
      },
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(widget.title, style: textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(
                  'Configuration fields',
                  style: textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                for (final field in widget.fields) ...[
                  _ConfigurationFieldInput(field: field),
                  const SizedBox(height: 12),
                ],
                const SizedBox(height: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 48),
                  child: FilledButton(
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        Navigator.of(context).maybePop();
                      }
                    },
                    child: const Text('Save configuration'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ConfigurationField {
  const ConfigurationField({
    required this.keyName,
    required this.label,
    this.initialValue,
    this.keyboardType,
  });

  final String keyName;
  final String label;
  final String? initialValue;
  final TextInputType? keyboardType;
}

class _ConfigurationFieldInput extends StatelessWidget {
  const _ConfigurationFieldInput({required this.field});

  final ConfigurationField field;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 48),
      child: TextFormField(
        initialValue: field.initialValue,
        keyboardType: field.keyboardType,
        decoration: InputDecoration(
          labelText: field.label,
          border: const OutlineInputBorder(),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
        style: Theme.of(context).textTheme.bodyMedium,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return '${field.label} is required';
          }
          return null;
        },
      ),
    );
  }
}

class EdgeSwipeDismissible extends StatefulWidget {
  const EdgeSwipeDismissible({
    super.key,
    required this.child,
    required this.onDismiss,
    this.edgeWidth = 24,
    this.velocityThreshold = 500,
  });

  final Widget child;
  final VoidCallback onDismiss;
  final double edgeWidth;
  final double velocityThreshold;

  @override
  State<EdgeSwipeDismissible> createState() => _EdgeSwipeDismissibleState();
}

class _EdgeSwipeDismissibleState extends State<EdgeSwipeDismissible> {
  bool _startedAtEdge = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onHorizontalDragStart: (details) {
            final dx = details.localPosition.dx;
            _startedAtEdge = dx <= widget.edgeWidth ||
                dx >= constraints.maxWidth - widget.edgeWidth;
          },
          onHorizontalDragEnd: (details) {
            final velocity = details.primaryVelocity ?? 0;
            if (_startedAtEdge && velocity.abs() >= widget.velocityThreshold) {
              widget.onDismiss();
            }
            _startedAtEdge = false;
          },
          child: widget.child,
        );
      },
    );
  }
}
