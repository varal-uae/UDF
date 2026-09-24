// GEN-02204 — Critical ED Fields Mobile Form.
// Renders only fields critical to the ED on mobile forms to maximize load speeds using M3 Elevated Cards, single-column layout, and 48x48dp touch targets.

import 'package:flutter/material.dart';

enum _FieldCriticality { critical, optional }

class _MockFormField {
  final String id;
  final String label;
  final String value;
  final _FieldCriticality criticality;

  const _MockFormField({
    required this.id,
    required this.label,
    required this.value,
    required this.criticality,
  });
}

const List<_MockFormField> _kMockEdFields = [
  _MockFormField(
    id: 'ed_field_001',
    label: 'Patient ID',
    value: 'ED-99281-A',
    criticality: _FieldCriticality.critical,
  ),
  _MockFormField(
    id: 'ed_field_002',
    label: 'Triage Level',
    value: 'Level 2 - Emergent',
    criticality: _FieldCriticality.critical,
  ),
  _MockFormField(
    id: 'ed_field_003',
    label: 'Chief Complaint',
    value: 'Acute Chest Pain',
    criticality: _FieldCriticality.critical,
  ),
  _MockFormField(
    id: 'ed_field_004',
    label: 'Attending Physician Notes',
    value: 'Pending detailed assessment.',
    criticality: _FieldCriticality.optional,
  ),
  _MockFormField(
    id: 'ed_field_005',
    label: 'Insurance Pre-Auth Code',
    value: 'N/A',
    criticality: _FieldCriticality.optional,
  ),
];

class CriticalEdFieldsFormGen02204 extends StatefulWidget {
  const CriticalEdFieldsFormGen02204({super.key});

  @override
  State<CriticalEdFieldsFormGen02204> createState() =>
      _CriticalEdFieldsFormGen02204State();
}

class _CriticalEdFieldsFormGen02204State
    extends State<CriticalEdFieldsFormGen02204> {
  bool _isLoading = false;

  Future<void> _handleRefresh() async {
    setState(() => _isLoading = true);
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('ED critical fields synchronized.'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        );
      }
    }
  }

  void _openConfigurationSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ED Field Configuration',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16.0),
              SwitchListTile(
                title: const Text('Show Non-Critical Fields'),
                value: false,
                onChanged: (_) {},
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 24.0),
              SizedBox(
                width: double.infinity,
                height: 48.0,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Apply Configuration'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<_MockFormField> criticalFields = _kMockEdFields
        .where((f) => f.criticality == _FieldCriticality.critical)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('ED Critical Fields'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            tooltip: 'Configure Fields',
            onPressed: () => _openConfigurationSheet(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        edgeOffset: 0.0,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final bool isMobile = constraints.maxWidth < 600;

            if (_isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 16.0,
              ),
              child: isMobile
                  ? Column(
                      children: criticalFields
                          .map(_buildM3ElevatedCard)
                          .toList(),
                    )
                  : Wrap(
                      spacing: 16.0,
                      runSpacing: 16.0,
                      children: criticalFields.map((field) {
                        return SizedBox(
                          width: (constraints.maxWidth / 2) - 24,
                          child: _buildM3ElevatedCard(field),
                        );
                      }).toList(),
                    ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildM3ElevatedCard(_MockFormField field) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Card(
        elevation: 3.0,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: InkWell(
          onTap: () {},
          customBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        field.label,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        field.value,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12.0),
                Chip(
                  avatar: const Icon(
                    Icons.check_circle_outline_rounded,
                    size: 18.0,
                  ),
                  label: const Text('Pass'),
                  backgroundColor: Theme.of(context)
                      .colorScheme
                      .primaryContainer
                      .withOpacity(0.3),
                  labelStyle: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                  side: BorderSide.none,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
