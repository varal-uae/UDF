// FEBFL-002-A05 — Algorithmic Content Selection Filters UI
// Implements single-select and multi-select filter dimensions as horizontal card carousels with 48dp touch targets.

import 'package:flutter/material.dart';

class Febfl002A05FilterOption {
  const Febfl002A05FilterOption({
    required this.id,
    required this.label,
    this.icon,
  });

  final String id;
  final String label;
  final IconData? icon;
}

class Febfl002A05FilterDimension {
  const Febfl002A05FilterDimension({
    required this.id,
    required this.label,
    required this.options,
    this.multiSelect = false,
  });

  final String id;
  final String label;
  final List<Febfl002A05FilterOption> options;
  final bool multiSelect;
}

class Febfl002A05FilterCarousel extends StatefulWidget {
  const Febfl002A05FilterCarousel({
    super.key,
    required this.dimensions,
    this.onSelectionChanged,
  });

  final List<Febfl002A05FilterDimension> dimensions;
  final void Function(Map<String, Set<String>> selections)? onSelectionChanged;

  @override
  State<Febfl002A05FilterCarousel> createState() => _Febfl002A05FilterCarouselState();
}

class _Febfl002A05FilterCarouselState extends State<Febfl002A05FilterCarousel> {
  final Map<String, Set<String>> _selections = {};

  @override
  void initState() {
    super.initState();
    for (final dimension in widget.dimensions) {
      _selections[dimension.id] = <String>{};
      if (!dimension.multiSelect && dimension.options.isNotEmpty) {
        _selections[dimension.id]!.add(dimension.options.first.id);
      }
    }
  }

  void _toggleOption(Febfl002A05FilterDimension dimension, Febfl002A05FilterOption option) {
    setState(() {
      final selected = _selections.putIfAbsent(dimension.id, () => <String>{});
      if (dimension.multiSelect) {
        if (!selected.add(option.id)) {
          selected.remove(option.id);
        }
      } else {
        selected
          ..clear()
          ..add(option.id);
      }
      widget.onSelectionChanged?.call(_selections);
    });
  }

  bool _isSelected(String dimensionId, String optionId) {
    return _selections[dimensionId]?.contains(optionId) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widget.dimensions.map((dimension) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  dimension.label,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 96,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: dimension.options.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final option = dimension.options[index];
                    final selected = _isSelected(dimension.id, option.id);
                    return _Febfl002A05FilterCard(
                      option: option,
                      selected: selected,
                      onTap: () => _toggleOption(dimension, option),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _Febfl002A05FilterCard extends StatelessWidget {
  const _Febfl002A05FilterCard({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final Febfl002A05FilterOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      selected: selected,
      label: option.label,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: 48,
          minHeight: 48,
          maxWidth: 160,
        ),
        child: Material(
          color: selected ? colorScheme.primaryContainer : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (option.icon != null) ...[
                    Icon(
                      option.icon,
                      size: 20,
                      color: selected ? colorScheme.onPrimaryContainer : colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Text(
                      option.label,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: selected ? colorScheme.onPrimaryContainer : colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
