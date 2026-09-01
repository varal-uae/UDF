// ============================================================================
// ARCHITECTURAL TRACKING METADATA BLOCK
// Architecture Pattern: Empty State Boilerplate Showcase with Dynamic Data Swap
// Component Hierarchy: EmptyStateBoilerplateShowcase -> DataListWrapper -> EmptyStateBoilerplate -> PulsingCTA
// UX Enhancements: Looping Chaser Pulse Animation (1.0x to 1.05x over 2 seconds)
// Completion Status: Complete (Ref: USMBL-014-A01)
// ============================================================================

import 'package:flutter/material.dart';
import '../widgets/empty_state_boilerplate.dart';
import '../widgets/data_list_wrapper.dart';

/// USMBL-014-A01: Empty State Boilerplate Interactive Showcase
/// Demonstrates conditional rendering and pulsing CTA when datasets are empty.
class EmptyStateBoilerplateShowcase extends StatefulWidget {
  const EmptyStateBoilerplateShowcase({super.key});

  @override
  State<EmptyStateBoilerplateShowcase> createState() =>
      _EmptyStateBoilerplateShowcaseState();
}

class _EmptyStateBoilerplateShowcaseState
    extends State<EmptyStateBoilerplateShowcase> {
  final List<String> _items = [];

  void _addItem() {
    setState(() {
      _items.add('Operational Record #${_items.length + 1}');
    });
  }

  void _clearItems() {
    setState(() {
      _items.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Interactive Dataset Toggle Controls
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Current Items: ${_items.length}',
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: _items.isNotEmpty ? _clearItems : null,
                  icon: const Icon(Icons.delete_outline, size: 16),
                  label: const Text('Simulate Empty Array'),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: _addItem,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Record'),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Live DataListWrapper Container
        Container(
          constraints: const BoxConstraints(minHeight: 320),
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.outlineVariant),
            borderRadius: BorderRadius.circular(16),
            color: theme.colorScheme.surface,
          ),
          child: DataListWrapper<String>(
            data: _items,
            emptyState: EmptyStateBoilerplate(
              title: 'No Active Workloads Detected',
              description:
                  'Your workload queue is currently empty. Click the pulsing button below to initiate data processing.',
              illustration: Icon(
                Icons.folder_open_outlined,
                size: 72,
                color: theme.colorScheme.primary,
              ),
              ctaLabel: 'Create First Workload',
              onCtaPressed: _addItem,
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: _items.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Text('${index + 1}'),
                  ),
                  title: Text(_items[index]),
                  subtitle: const Text('Status: Online & Telemetry Active'),
                  trailing: IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () {
                      setState(() => _items.removeAt(index));
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
