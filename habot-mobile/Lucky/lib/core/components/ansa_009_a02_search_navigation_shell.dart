// ANSA-009-A02 — Marketplace Search Console Center-Aligned Navigation UI.
// A sticky Material 3 top app bar encapsulates a wide, center-aligned search input with auto-suggest (max 5 rows) and responsive filter panel switching between a right rail and bottom sheet.

import 'package:flutter/material.dart';

/// Responsive marketplace search navigation shell.
class Ansa009A02SearchNavigationShell extends StatefulWidget {
  const Ansa009A02SearchNavigationShell({super.key});

  @override
  State<Ansa009A02SearchNavigationShell> createState() =>
      _Ansa009A02SearchNavigationShellState();
}

class _Ansa009A02SearchNavigationShellState
    extends State<Ansa009A02SearchNavigationShell> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _suggestions = <String>[];
  bool _hasActiveFilters = false;

  static const List<String> _expertAttributes = <String>[
    'Speech Therapist',
    'Occupational Therapist',
    'Behavioral Analyst',
    'Special Education Tutor',
    'Child Psychologist',
    'Feeding Specialist',
    'Physical Therapist',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    final trimmed = query.trim().toLowerCase();
    setState(() {
      _suggestions
        ..clear()
        ..addAll(
          trimmed.isEmpty
              ? const <String>[]
              : _expertAttributes
                    .where((attr) => attr.toLowerCase().contains(trimmed))
                    .take(5),
        );
    });
  }

  void _clearAllFilters() {
    setState(() {
      _hasActiveFilters = false;
      _searchController.clear();
      _suggestions.clear();
    });
  }

  void _openFilterPanel(BuildContext context, bool isCompact) {
    if (isCompact) {
      showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        isScrollControlled: true,
        builder: (context) => const _FilterPanelContent(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 600;
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            elevation: 1.0,
            shadowColor: colorScheme.shadow,
            surfaceTintColor: Colors.transparent,
            titleSpacing: 0,
            title: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720.0),
                child: _SearchField(
                  controller: _searchController,
                  suggestions: _suggestions,
                  onChanged: _onSearchChanged,
                  onSuggestionTap: (value) {
                    _searchController.text = value;
                    _onSearchChanged(value);
                  },
                ),
              ),
            ),
            actions: <Widget>[
              if (_hasActiveFilters)
                IconButton(
                  tooltip: 'Clear all filters',
                  onPressed: _clearAllFilters,
                  icon: const Icon(Icons.filter_alt_off_outlined),
                ),
              IconButton(
                tooltip: 'Open filters',
                onPressed: () => _openFilterPanel(context, isCompact),
                icon: Badge(
                  isLabelVisible: _hasActiveFilters,
                  child: const Icon(Icons.tune),
                ),
              ),
              const SizedBox(width: 8.0),
            ],
          ),
          body: Row(
            children: <Widget>[
              Expanded(
                child: _SearchResultsArea(
                  hasActiveFilters: _hasActiveFilters,
                ),
              ),
              if (!isCompact)
                const SizedBox(
                  width: 320.0,
                  child: _FilterPanelContent(),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.suggestions,
    required this.onChanged,
    required this.onSuggestionTap,
  });

  final TextEditingController controller;
  final List<String> suggestions;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSuggestionTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        TextField(
          controller: controller,
          onChanged: onChanged,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Search for expert support',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: controller.text.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Clear search',
                    onPressed: () {
                      controller.clear();
                      onChanged('');
                    },
                    icon: const Icon(Icons.close),
                  ),
            filled: true,
            fillColor: colorScheme.surfaceContainerHighest,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.0),
              borderSide: BorderSide(
                color: colorScheme.outlineVariant,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.0),
              borderSide: BorderSide(
                color: colorScheme.primary,
                width: 2.0,
              ),
            ),
          ),
        ),
        if (suggestions.isNotEmpty)
          Material(
            elevation: 1.0,
            borderRadius: BorderRadius.circular(16.0),
            clipBehavior: Clip.antiAlias,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 240.0),
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: suggestions.length,
                itemBuilder: (context, index) {
                  final suggestion = suggestions[index];
                  return ListTile(
                    dense: true,
                    leading: const Icon(Icons.person_search_outlined),
                    title: Text(suggestion),
                    onTap: () => onSuggestionTap(suggestion),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}

class _FilterPanelContent extends StatelessWidget {
  const _FilterPanelContent();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Filters', style: textTheme.titleLarge),
            const SizedBox(height: 16.0),
            const _FilterChipGroup(label: 'Expertise', options: ['Speech', 'OT', 'ABA']),
            const SizedBox(height: 16.0),
            const _FilterChipGroup(label: 'Availability', options: ['Today', 'This week', 'Weekend']),
            const SizedBox(height: 16.0),
            const _FilterChipGroup(label: 'Age group', options: ['0-3', '4-7', '8-12']),
            const SizedBox(height: 24.0),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  // Clear all filter state. Parent will sync via callback in production.
                },
                icon: const Icon(Icons.filter_alt_off_outlined),
                label: const Text('Clear all filters'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChipGroup extends StatelessWidget {
  const _FilterChipGroup({required this.label, required this.options});

  final String label;
  final List<String> options;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8.0),
        Wrap(
          spacing: 8.0,
          children: options
              .map((option) => FilterChip(
                    label: Text(option),
                    onSelected: (value) {},
                  ))
              .toList(),
        ),
      ],
    );
  }
}

class _SearchResultsArea extends StatelessWidget {
  const _SearchResultsArea({required this.hasActiveFilters});

  final bool hasActiveFilters;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: hasActiveFilters
          ? const Text('No results match the active filters.')
          : const Text('Start typing to discover matching experts.'),
    );
  }
}