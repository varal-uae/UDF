// FEBFL-002-A17 — Algorithmic Content Selection Filters Carousel.
// Provides WCAG 2.1 AA compliant filter controls and a horizontally scrollable profile recommendation carousel with 48dp touch targets.

import 'package:flutter/material.dart';

class Febfl002A17ContentSelectionFilters extends StatefulWidget {
  const Febfl002A17ContentSelectionFilters({
    super.key,
    required this.filters,
    required this.profiles,
    this.onFilterChanged,
    this.onProfileSelected,
  });

  final List<Febfl002A17FilterOption> filters;
  final List<Febfl002A17ProfileCardData> profiles;
  final ValueChanged<Set<String>>? onFilterChanged;
  final ValueChanged<Febfl002A17ProfileCardData>? onProfileSelected;

  @override
  State<Febfl002A17ContentSelectionFilters> createState() => _Febfl002A17ContentSelectionFiltersState();
}

class _Febfl002A17ContentSelectionFiltersState extends State<Febfl002A17ContentSelectionFilters> {
  late final Set<String> _selectedFilterIds;

  @override
  void initState() {
    super.initState();
    _selectedFilterIds = widget.filters.where((filter) => filter.selected).map((filter) => filter.id).toSet();
  }

  void _toggleFilter(String id, bool selected) {
    setState(() {
      if (selected) {
        _selectedFilterIds.add(id);
      } else {
        _selectedFilterIds.remove(id);
      }
    });
    widget.onFilterChanged?.call(Set.unmodifiable(_selectedFilterIds));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 8),
            child: Text('Recommended profiles', style: theme.textTheme.titleLarge),
          ),
        ),
        SizedBox(
          height: 56,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: widget.filters.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final filter = widget.filters[index];
              final selected = _selectedFilterIds.contains(filter.id);

              return Semantics(
                label: filter.semanticLabel,
                selected: selected,
                button: true,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                  child: FilterChip(
                    label: Text(filter.label),
                    selected: selected,
                    onSelected: (value) => _toggleFilter(filter.id, value),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 220,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: widget.profiles.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final profile = widget.profiles[index];

              return Semantics(
                button: true,
                label: '${profile.title}. ${profile.subtitle}. ${profile.actionLabel}',
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                  child: SizedBox(
                    width: 240,
                    child: Card(
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () => widget.onProfileSelected?.call(profile),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(profile.title, style: theme.textTheme.titleMedium),
                              const SizedBox(height: 8),
                              Text(profile.subtitle, style: theme.textTheme.bodyMedium),
                              const Spacer(),
                              Align(
                                alignment: AlignmentDirectional.centerEnd,
                                child: Text(
                                  profile.actionLabel,
                                  style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.primary),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class Febfl002A17FilterOption {
  const Febfl002A17FilterOption({
    required this.id,
    required this.label,
    required this.semanticLabel,
    this.selected = false,
  });

  final String id;
  final String label;
  final String semanticLabel;
  final bool selected;
}

class Febfl002A17ProfileCardData {
  const Febfl002A17ProfileCardData({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
  });

  final String id;
  final String title;
  final String subtitle;
  final String actionLabel;
}
