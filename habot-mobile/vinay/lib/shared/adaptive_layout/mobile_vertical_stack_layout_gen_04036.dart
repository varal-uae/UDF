// GEN-04036 — Mobile Vertical Stack Layout Configuration.
// Implements a single-column vertical stack layout (Evidence on Top, Form on Bottom) following Material Design 3 responsive rules with M3 Elevated Cards and Status Chips.

import 'package:flutter/material.dart';

/// Mock data representing evidence items for the top section of the stack.
class _MockEvidenceItem {
  final String id;
  final String title;
  final String description;
  final bool isCompleted;

  const _MockEvidenceItem({
    required this.id,
    required this.title,
    required this.description,
    required this.isCompleted,
  });
}

const List<_MockEvidenceItem> _mockEvidenceData = [
  _MockEvidenceItem(
    id: 'EVD-001',
    title: 'Identity Verification',
    description: 'Government issued ID uploaded and verified.',
    isCompleted: true,
  ),
  _MockEvidenceItem(
    id: 'EVD-002',
    title: 'Address Proof',
    description: 'Utility bill matching registered address.',
    isCompleted: false,
  ),
  _MockEvidenceItem(
    id: 'EVD-003',
    title: 'Biometric Scan',
    description: 'Liveness check passed successfully.',
    isCompleted: true,
  ),
];

/// Main layout widget enforcing the single-column vertical stack configuration.
/// Evidence section is placed on top, followed by the Form section on the bottom.
/// Responsive behavior: single-column on mobile (<600dp), multi-column on desktop (>=840dp).
class MobileVerticalStackLayout extends StatelessWidget {
  const MobileVerticalStackLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UDF Configuration'),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          // M3 responsive layout: single-column on mobile (<600dp), multi-column on desktop (>=840dp)
          if (constraints.maxWidth >= 840.0) {
            return _buildDesktopMultiColumnLayout(context);
          }
          return _buildMobileSingleColumnLayout(context);
        },
      ),
    );
  }

  Widget _buildMobileSingleColumnLayout(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        // Pull-to-refresh triggers manual sync
        await Future<void>.delayed(const Duration(milliseconds: 500));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: const [
            // Evidence on Top
            _EvidenceSection(),
            SizedBox(height: 24.0),
            // Form on Bottom
            _FormSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopMultiColumnLayout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Expanded(
            flex: 1,
            child: _EvidenceSection(),
          ),
          SizedBox(width: 24.0),
          Expanded(
            flex: 1,
            child: _FormSection(),
          ),
        ],
      ),
    );
  }
}

/// Evidence Section displayed at the top of the vertical stack on mobile.
class _EvidenceSection extends StatelessWidget {
  const _EvidenceSection();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Evidence',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12.0),
        ..._mockEvidenceData.map((item) => _EvidenceCard(item: item)).toList(),
      ],
    );
  }
}

/// M3 Elevated Card Level 2 (3dp) displaying individual evidence status.
class _EvidenceCard extends StatelessWidget {
  final _MockEvidenceItem item;

  const _EvidenceCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Card(
        elevation: 3.0, // M3 Elevated Cards Level 2 (3dp)
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      item.description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12.0),
              // M3 Status Chips for health indicators
              _StatusChip(isCompleted: item.isCompleted),
            ],
          ),
        ),
      ),
    );
  }
}

/// M3 Status Chip indicating completion state.
class _StatusChip extends StatelessWidget {
  final bool isCompleted;

  const _StatusChip({required this.isCompleted});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        isCompleted ? 'Pass' : 'Fail',
        style: TextStyle(
          color: isCompleted
              ? Theme.of(context).colorScheme.onPrimaryContainer
              : Theme.of(context).colorScheme.onErrorContainer,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: isCompleted
          ? Theme.of(context).colorScheme.primaryContainer
          : Theme.of(context).colorScheme.errorContainer,
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
    );
  }
}

/// Form Section displayed at the bottom of the vertical stack on mobile.
class _FormSection extends StatelessWidget {
  const _FormSection();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Configuration Form',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12.0),
        Card(
          elevation: 3.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Layout Stack Order Compliance',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                  ),
                ),
                const SizedBox(height: 24.0),
                // 48x48dp touch targets
                SizedBox(
                  height: 48.0,
                  width: 48.0,
                  child: FilledButton(
                    onPressed: () {
                      // M3 Snackbar for confirmations
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Configuration saved successfully.'),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          action: SnackBarAction(
                            label: 'DISMISS',
                            onPressed: () {},
                          ),
                        ),
                      );
                    },
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}