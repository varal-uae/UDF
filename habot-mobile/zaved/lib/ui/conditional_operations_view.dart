/// COMPONENT METADATA BLOCK
/// - Font Name: Roboto / RobotoMono
/// - Font Size: 14.0 px
/// - Line Height: 1.4
/// - Font Weight: FontWeight.w500
/// - Font File Path: assets/fonts/Roboto-Medium.ttf
/// - UI Design-System Adherence Rate: Target: Good - 100%
library;

import 'package:flutter/material.dart';

/// Constant list of machine-action approved verbs strictly enforced by Poka-Yoke assert.
const List<String> kApprovedVerbs = ['APPROVE', 'REJECT', 'EXECUTE', 'VALIDATE'];

/// Custom StrictVerbButton enforcing strict verb validation & unambiguous typography.
class StrictVerbButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color? buttonColor;

  StrictVerbButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.buttonColor,
  }) : assert(
          kApprovedVerbs.contains(label),
          'Poka-Yoke Violation: Verb "$label" is not in approved list: $kApprovedVerbs',
        );

  @override
  Widget build(BuildContext context) {
    // Force exact typography per spec
    const strictStyle = TextStyle(
      fontWeight: FontWeight.w500,
      fontSize: 14.0,
      letterSpacing: 0.1,
    );

    final colorScheme = Theme.of(context).colorScheme;
    final isReject = label == 'REJECT';
    final bgColor = buttonColor ??
        (isReject ? colorScheme.error : colorScheme.primary);
    final fgColor = isReject ? colorScheme.onError : colorScheme.onPrimary;

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        foregroundColor: fgColor,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onPressed: onPressed,
      child: Text(
        label,
        style: strictStyle,
      ),
    );
  }
}

/// Mock operation model item with `isExpanded` boolean and conditional criteria.
class OperationItem {
  final String id;
  final String title;
  final String category;
  final String description;
  final bool requiresApproval;
  final String status;
  bool isExpanded;

  OperationItem({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.requiresApproval,
    required this.status,
    this.isExpanded = false,
  });
}

/// ETMDI-022-17: Conditional Operations View
///
/// Implements M3 Expansion Panels on Mobile/Tablet and Adaptive Master-Detail
/// Pane Logic on Web, with strict Poka-Yoke verb buttons.
class ConditionalOperationsView extends StatefulWidget {
  const ConditionalOperationsView({super.key});

  @override
  State<ConditionalOperationsView> createState() =>
      _ConditionalOperationsViewState();
}

class _ConditionalOperationsViewState
    extends State<ConditionalOperationsView> {
  final List<OperationItem> _items = [
    OperationItem(
      id: 'OP-101',
      title: 'Batch Ledger Reconciliation',
      category: 'Financial Operations',
      description: 'Reconcile 1,420 pending entries against core banking ledger.',
      requiresApproval: true,
      status: 'PENDING_APPROVAL',
    ),
    OperationItem(
      id: 'OP-102',
      title: 'Cache Invalidation Probe',
      category: 'System Maintenance',
      description: 'Purge edge CDN caches for zone us-east-1.',
      requiresApproval: false,
      status: 'AUTOMATED',
    ),
    OperationItem(
      id: 'OP-103',
      title: 'CMEK Key Rotation Request',
      category: 'Security Compliance',
      description: 'Rotate AWS KMS Master Key #49102-SEC.',
      requiresApproval: true,
      status: 'AWAITING_VALIDATION',
    ),
    OperationItem(
      id: 'OP-104',
      title: 'User Privilege Escalation Audit',
      category: 'Access Management',
      description: 'Grant temporary elevated IAM role to Admin USR-8821.',
      requiresApproval: true,
      status: 'PENDING_APPROVAL',
    ),
  ];

  int _selectedWebIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Conditional Operations View'),
        elevation: 0,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWeb = constraints.maxWidth > 800;

          if (!isWeb) {
            // Mobile / Tablet View (maxWidth <= 800): Stacked M3 ExpansionPanelList
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderCard(colorScheme, 'Mobile/Tablet View: Stacked M3 Expansion Panels'),
                  const SizedBox(height: 16),
                  ExpansionPanelList(
                    elevation: 2,
                    expansionCallback: (int index, bool isExpanded) {
                      setState(() {
                        _items[index].isExpanded = !isExpanded;
                      });
                    },
                    children: _items.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final item = entry.value;

                      return ExpansionPanel(
                        headerBuilder: (BuildContext context, bool isExpanded) {
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: colorScheme.primaryContainer,
                              child: Text(
                                '${idx + 1}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ),
                            title: Text(
                              item.title,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text('${item.id} • ${item.category}'),
                          );
                        },
                        body: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.description,
                                style: TextStyle(color: colorScheme.onSurfaceVariant),
                              ),
                              const SizedBox(height: 16),

                              // Conditional IF/ELSE Logic: Only show StrictVerbButtons if requiresApproval is true
                              if (item.requiresApproval) ...[
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: colorScheme.outline.withValues(alpha: 0.3)),
                                    ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Action Required: Verbs Strict Assert Enforced',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: colorScheme.primary,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Wrap(
                                        spacing: 12,
                                        runSpacing: 8,
                                        children: [
                                          StrictVerbButton(
                                            label: 'APPROVE',
                                            onPressed: () => _handleAction(item, 'APPROVE'),
                                          ),
                                          StrictVerbButton(
                                            label: 'VALIDATE',
                                            onPressed: () => _handleAction(item, 'VALIDATE'),
                                          ),
                                          StrictVerbButton(
                                            label: 'REJECT',
                                            onPressed: () => _handleAction(item, 'REJECT'),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ] else ...[
                                  Row(
                                    children: [
                                      Icon(Icons.check_circle, color: colorScheme.primary, size: 20),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Automated Process — No Manual Action Required',
                                        style: TextStyle(
                                          color: colorScheme.primary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const Spacer(),
                                      StrictVerbButton(
                                        label: 'EXECUTE',
                                        onPressed: () => _handleAction(item, 'EXECUTE'),
                                      ),
                                    ],
                                  ),
                              ],
                            ],
                          ),
                        ),
                        isExpanded: item.isExpanded,
                      );
                    }).toList(),
                  ),
                ],
              ),
            );
          } else {
            // Web View (maxWidth > 800): Adaptive Pane Logic (Master ListView on left, Details on right)
            final selectedItem = _items[_selectedWebIndex];

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildHeaderCard(colorScheme, 'Web View: Adaptive Master-Detail Split Pane'),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left Master ListView
                        SizedBox(
                          width: 320,
                          child: Card(
                            elevation: 1,
                            child: ListView.separated(
                              itemCount: _items.length,
                              separatorBuilder: (context, idx) => const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final item = _items[index];
                                final isSelected = index == _selectedWebIndex;
                                return ListTile(
                                  selected: isSelected,
                                  selectedTileColor: colorScheme.primaryContainer.withValues(alpha: 0.4),
                                  leading: Icon(
                                    item.requiresApproval
                                        ? Icons.pending_actions
                                        : Icons.auto_mode,
                                    color: isSelected
                                        ? colorScheme.primary
                                        : colorScheme.onSurfaceVariant,
                                  ),
                                  title: Text(
                                    item.title,
                                    style: TextStyle(
                                      fontWeight:
                                          isSelected ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                  subtitle: Text(item.id),
                                  onTap: () {
                                    setState(() {
                                      _selectedWebIndex = index;
                                    });
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Right Detail Expanded Pane
                        Expanded(
                          child: Card(
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Chip(
                                        label: Text(selectedItem.category),
                                        backgroundColor: colorScheme.secondaryContainer,
                                      ),
                                      const Spacer(),
                                      Text(
                                        'ID: ${selectedItem.id}',
                                        style: TextStyle(
                                          fontFamily: 'RobotoMono',
                                          fontWeight: FontWeight.bold,
                                          color: colorScheme.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    selectedItem.title,
                                    style: theme.textTheme.headlineMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    selectedItem.description,
                                    style: theme.textTheme.bodyLarge,
                                  ),
                                  const Spacer(),
                                  const Divider(),
                                  const SizedBox(height: 16),

                                  // Conditional Strict Verb Buttons in Detail Pane
                                  if (selectedItem.requiresApproval) ...[
                                    Text(
                                      'Mandatory Action Gate (Approved Verbs Only)',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        StrictVerbButton(
                                          label: 'APPROVE',
                                          onPressed: () =>
                                              _handleAction(selectedItem, 'APPROVE'),
                                        ),
                                        const SizedBox(width: 12),
                                        StrictVerbButton(
                                          label: 'VALIDATE',
                                          onPressed: () =>
                                              _handleAction(selectedItem, 'VALIDATE'),
                                        ),
                                        const SizedBox(width: 12),
                                        StrictVerbButton(
                                          label: 'REJECT',
                                          onPressed: () =>
                                              _handleAction(selectedItem, 'REJECT'),
                                        ),
                                      ],
                                    ),
                                  ] else ...[
                                    Row(
                                      children: [
                                        const Text('Automation Rule Active'),
                                        const Spacer(),
                                        StrictVerbButton(
                                          label: 'EXECUTE',
                                          onPressed: () =>
                                              _handleAction(selectedItem, 'EXECUTE'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildHeaderCard(ColorScheme colorScheme, String label) {
    return Card(
      color: colorScheme.primaryContainer,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(Icons.tune, color: colorScheme.onPrimaryContainer),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleAction(OperationItem item, String verb) {
    final colorScheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Verb [$verb] executed successfully on ${item.id}!'),
        backgroundColor: verb == 'REJECT' ? colorScheme.error : colorScheme.primary,
      ),
    );
  }
}
