// DLQDP-009-08 — Searchable variable-definition autocomplete field for analyst interfaces.
// Provides approved variable lookup, empty-state retry, service-unavailable fallback, and MD3 queued feedback.

import 'package:flutter/material.dart';

class VariableDefinition {
  const VariableDefinition({
    required this.id,
    required this.label,
    required this.description,
  });

  final String id;
  final String label;
  final String description;
}

class Dlqdp00908VariableAutocompleteField extends StatelessWidget {
  const Dlqdp00908VariableAutocompleteField({
    super.key,
    required this.definitions,
    required this.onSelected,
    this.isServiceUnavailable = false,
    this.isLoading = false,
    this.onRetry,
  });

  final List<VariableDefinition> definitions;
  final ValueChanged<VariableDefinition> onSelected;
  final bool isServiceUnavailable;
  final bool isLoading;
  final VoidCallback? onRetry;

  void _showQueuedSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Request queued. Your data is safe; processing may be delayed.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isServiceUnavailable) {
      return _ServiceUnavailableFallback(onRetry: onRetry);
    }

    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (definitions.isEmpty) {
      return _EmptyDefinitionsState(onRetry: onRetry);
    }

    return Autocomplete<VariableDefinition>(
      optionsBuilder: (TextEditingValue value) {
        final query = value.text.trim().toLowerCase();
        if (query.isEmpty) {
          return definitions;
        }
        return definitions.where((definition) {
          return definition.label.toLowerCase().contains(query) ||
              definition.id.toLowerCase().contains(query) ||
              definition.description.toLowerCase().contains(query);
        });
      },
      displayStringForOption: (definition) => definition.label,
      onSelected: (definition) {
        onSelected(definition);
        _showQueuedSnackBar(context);
      },
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          decoration: const InputDecoration(
            labelText: 'Variable definition',
            hintText: 'Search approved variables',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
          ),
          onSubmitted: (_) => onFieldSubmitted(),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(12),
            color: theme.colorScheme.surface,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 260, minWidth: 280),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final definition = options.elementAt(index);
                  return ListTile(
                    title: Text(definition.label),
                    subtitle: Text(definition.description),
                    onTap: () => onSelected(definition),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ServiceUnavailableFallback extends StatelessWidget {
  const _ServiceUnavailableFallback({this.onRetry});

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off, size: 48, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 12),
            Text('Variable service unavailable', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            const Text('Your data is safe. Processing is delayed until the service is reachable.'),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyDefinitionsState extends StatelessWidget {
  const _EmptyDefinitionsState({this.onRetry});

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined, size: 48, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 12),
            Text('No approved variables found', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            const Text('Retry the lookup or contact support if definitions are missing.'),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
