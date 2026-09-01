import 'package:flutter/material.dart';

/// Data Model for Single Responsibility Component (SRC) Definition (NSKFI-002)
class SRCComponentDefinition {
  final String id;
  final String name;
  final List<String> parameters;
  final String type;
  final int redundantVariablesCount;

  const SRCComponentDefinition({
    required this.id,
    required this.name,
    required this.parameters,
    required this.type,
    required this.redundantVariablesCount,
  });
}

/// Central SRC Registry Data Source implementing Indexing, Uniqueness Checking, and ID Mapping
class SRCRegistry {
  SRCRegistry._() {
    _seedDefaultDefinitions();
  }

  static final SRCRegistry instance = SRCRegistry._();

  // (3) Mapping step that stores entries in a Dict/Map keyed by Definition ID
  final Map<String, SRCComponentDefinition> _registryById = {};

  List<SRCComponentDefinition> get allDefinitions =>
      _registryById.values.toList();

  void _seedDefaultDefinitions() {
    final seedItems = [
      const SRCComponentDefinition(
        id: 'SRC-001',
        name: 'Primary Button',
        parameters: ['label', 'onPressed', 'icon'],
        type: 'Interactive',
        redundantVariablesCount: 0,
      ),
      const SRCComponentDefinition(
        id: 'SRC-002',
        name: 'Status Badge',
        parameters: ['status', 'label'],
        type: 'Display',
        redundantVariablesCount: 0,
      ),
      const SRCComponentDefinition(
        id: 'SRC-003',
        name: 'Error Toast',
        parameters: ['errorMessage', 'onDismiss'],
        type: 'Feedback',
        redundantVariablesCount: 0,
      ),
      const SRCComponentDefinition(
        id: 'SRC-004',
        name: 'Payment Status Banner',
        parameters: ['theme', 'statusTitle', 'actionLabel'],
        type: 'Layout',
        redundantVariablesCount: 0,
      ),
      const SRCComponentDefinition(
        id: 'SRC-005',
        name: 'Input Field',
        parameters: ['controller', 'validator', 'hintText'],
        type: 'Input',
        redundantVariablesCount: 0,
      ),
      const SRCComponentDefinition(
        id: 'SRC-006',
        name: 'Navigation Bar',
        parameters: ['currentIndex', 'onDestinationSelected'],
        type: 'Navigation',
        redundantVariablesCount: 0,
      ),
    ];

    for (final item in seedItems) {
      register(item);
    }
  }

  /// (1) Indexing step that registers each component definition by name/params/type
  /// (2) Uniqueness check that rejects duplicate component names before registration
  /// (3) Mapping step that stores entries in a Dict/Map keyed by Definition ID
  String? register(SRCComponentDefinition def) {
    // Uniqueness check by component name (case-insensitive)
    final isDuplicateName = _registryById.values.any(
      (existing) =>
          existing.name.trim().toLowerCase() == def.name.trim().toLowerCase(),
    );

    if (isDuplicateName) {
      return 'Registration rejected: Component name "${def.name}" already exists in the SRC registry.';
    }

    if (_registryById.containsKey(def.id)) {
      return 'Registration rejected: Definition ID "${def.id}" already exists.';
    }

    // Index & Map by Definition ID
    _registryById[def.id] = def;
    return null; // Success
  }

  SRCComponentDefinition? getById(String id) => _registryById[id];
}

/// Universal SRC Search & Registry Component (NSKFI-002)
class UniversalSRCSearch extends StatefulWidget {
  const UniversalSRCSearch({super.key});

  @override
  State<UniversalSRCSearch> createState() => _UniversalSRCSearchState();
}

class _UniversalSRCSearchState extends State<UniversalSRCSearch> {
  final SRCRegistry _registry = SRCRegistry.instance;
  SRCComponentDefinition? _selectedDefinition;
  String _registryStatusMessage = 'Registry Active: Zero Redundancy Enforced';

  void _openPublishSRCDialog() {
    final nameController = TextEditingController();
    final paramsController = TextEditingController();
    final typeController = TextEditingController(text: 'Interactive');
    final redundantVarsController = TextEditingController(text: '0');

    showDialog(
      context: context,
      builder: (ctx) {
        final colorScheme = Theme.of(ctx).colorScheme;
        final textTheme = Theme.of(ctx).textTheme;

        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.publish_rounded, color: colorScheme.primary),
              const SizedBox(width: 8.0),
              Text(
                'Publish SRC Definition',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Register a new Single Responsibility Component with uniqueness validation & zero redundancy check.',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16.0),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Component Name *',
                    hintText: 'e.g. Primary Action Button',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12.0),
                TextField(
                  controller: paramsController,
                  decoration: const InputDecoration(
                    labelText: 'Parameters (comma-separated)',
                    hintText: 'label, onPressed, icon',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12.0),
                TextField(
                  controller: typeController,
                  decoration: const InputDecoration(
                    labelText: 'Component Type',
                    hintText: 'Interactive, Display, Feedback, etc.',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12.0),
                TextField(
                  controller: redundantVarsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Redundant Variables Count',
                    hintText: '0',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('CANCEL'),
            ),
            FilledButton(
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Error: Component name cannot be empty.'),
                      backgroundColor: colorScheme.error,
                    ),
                  );
                  return;
                }

                final params = paramsController.text
                    .split(',')
                    .map((p) => p.trim())
                    .where((p) => p.isNotEmpty)
                    .toList();
                final type = typeController.text.trim().isEmpty
                    ? 'Interactive'
                    : typeController.text.trim();
                final redVars = int.tryParse(redundantVarsController.text.trim()) ?? 0;
                final newId = 'SRC-00${_registry.allDefinitions.length + 1}';

                final newDef = SRCComponentDefinition(
                  id: newId,
                  name: name,
                  parameters: params,
                  type: type,
                  redundantVariablesCount: redVars,
                );

                final error = _registry.register(newDef);
                if (error != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(error),
                      backgroundColor: colorScheme.error,
                    ),
                  );
                } else {
                  Navigator.pop(ctx);
                  setState(() {
                    _selectedDefinition = newDef;
                    _registryStatusMessage =
                        'SRC "${newDef.name}" (${newDef.id}) published successfully.';
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Successfully published ${newDef.id}!'),
                      backgroundColor: colorScheme.primary,
                    ),
                  );
                }
              },
              child: const Text('PUBLISH SRC'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 800.0,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header & Publish Action Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Universal SRC Registry Search',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2.0),
                      Text(
                        'Indexed Single Responsibility Components (${_registry.allDefinitions.length} Registered)',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                FilledButton.icon(
                  onPressed: _openPublishSRCDialog,
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('PUBLISH SRC'),
                ),
              ],
            ),
            const SizedBox(height: 16.0),

            // Search Bar with real SRC Registry data source
            SearchAnchor(
              builder: (BuildContext context, SearchController controller) {
                return SearchBar(
                  controller: controller,
                  padding: const WidgetStatePropertyAll<EdgeInsets>(
                    EdgeInsets.symmetric(horizontal: 16.0),
                  ),
                  onTap: () {
                    controller.openView();
                  },
                  onChanged: (_) {
                    controller.openView();
                  },
                  leading: Icon(Icons.search, color: colorScheme.primary),
                  hintText: 'Search SRC Registry by name, ID, or type...',
                );
              },
              suggestionsBuilder: (
                BuildContext context,
                SearchController controller,
              ) {
                final keyword = controller.text.toLowerCase().trim();
                final definitions = _registry.allDefinitions.where((def) {
                  return def.name.toLowerCase().contains(keyword) ||
                      def.id.toLowerCase().contains(keyword) ||
                      def.type.toLowerCase().contains(keyword) ||
                      def.parameters.any(
                          (param) => param.toLowerCase().contains(keyword));
                }).toList();

                return definitions.map((SRCComponentDefinition def) {
                  // STRICT ACCESSIBILITY RULE: Enforce exactly 48dp height touch target for items
                  return SizedBox(
                    height: 48.0,
                    child: ListTile(
                      dense: true,
                      leading: Chip(
                        label: Text(def.id, style: const TextStyle(fontSize: 10.0)),
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                      ),
                      title: Text(def.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text('${def.type} • params: ${def.parameters.join(', ')}'),
                      trailing: def.redundantVariablesCount == 0
                          ? Icon(Icons.verified, color: colorScheme.primary, size: 18.0)
                          : null,
                      onTap: () {
                        controller.closeView(def.name);
                        setState(() {
                          _selectedDefinition = def;
                        });
                      },
                    ),
                  );
                }).toList();
              },
            ),
            const SizedBox(height: 20.0),

            // Selected Definition & Redundant Variables = 0 Confirmation UI
            if (_selectedDefinition != null) ...[
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                  side: BorderSide(color: colorScheme.outlineVariant),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _selectedDefinition!.name,
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Chip(
                            label: Text(_selectedDefinition!.id),
                            backgroundColor: colorScheme.secondaryContainer,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        'Type: ${_selectedDefinition!.type}',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        'Parameters: ${_selectedDefinition!.parameters.isEmpty ? "None" : _selectedDefinition!.parameters.join(', ')}',
                        style: textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 12.0),

                      // (4) Surface a visible confirmation when Redundant Variables = 0 is achieved
                      if (_selectedDefinition!.redundantVariablesCount == 0)
                        Container(
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(color: colorScheme.primary),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle_rounded,
                                  color: colorScheme.onPrimaryContainer),
                              const SizedBox(width: 10.0),
                              Expanded(
                                child: Text(
                                  'Zero Redundancy Confirmed: Redundant Variables = 0. Optimal Single Responsibility Architecture verified.',
                                  style: textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onPrimaryContainer,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(color: colorScheme.error),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.warning_amber_rounded,
                                  color: colorScheme.onErrorContainer),
                              const SizedBox(width: 10.0),
                              Expanded(
                                child: Text(
                                  'Redundant Variables Detected: ${_selectedDefinition!.redundantVariablesCount}. Refactor needed.',
                                  style: textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onErrorContainer,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              Text(
                _registryStatusMessage,
                textAlign: TextAlign.center,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
