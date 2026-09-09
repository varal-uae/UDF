// ANSA-009-A06 — Marketplace Search Console Center-Aligned Navigation UI Setup.
// Sticky Material 3 top app bar with outlined search field, max 5 autocomplete rows, level 1 elevation, 16px radius, and bottom-sheet filter overlay on compact screens.

import 'package:flutter/material.dart';

class Ansa009A06MarketplaceSearchBar extends StatelessWidget implements PreferredSizeWidget {
  const Ansa009A06MarketplaceSearchBar({super.key, this.controller, this.onSubmitted, this.suggestions = const [], this.filterPanel});

  final TextEditingController? controller;
  final ValueChanged<String>? onSubmitted;
  final List<String> suggestions;
  final Widget? filterPanel;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 8);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final outlinedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: colorScheme.outline),
    );
    final focusedBorder = outlinedBorder.copyWith(borderSide: BorderSide(color: colorScheme.primary, width: 2));

    return Material(
      elevation: 1,
      color: colorScheme.surface,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
          child: Row(
            children: [
              Expanded(
                child: Autocomplete<String>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text.isEmpty) return const Iterable<String>.empty();
                    return suggestions.where((s) => s.toLowerCase().contains(textEditingValue.text.toLowerCase())).take(5);
                  },
                  onSelected: (value) {
                    controller?.text = value;
                    onSubmitted?.call(value);
                  },
                  fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                    return TextField(
                      controller: textEditingController,
                      focusNode: focusNode,
                      onSubmitted: onFieldSubmitted,
                      decoration: InputDecoration(
                        hintText: 'Search marketplace',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: IconButton(
                          tooltip: 'Clear all filters',
                          onPressed: () {
                            textEditingController.clear();
                            onSubmitted?.call('');
                          },
                          icon: const Icon(Icons.clear_all),
                        ),
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest,
                        border: outlinedBorder,
                        enabledBorder: outlinedBorder,
                        focusedBorder: focusedBorder,
                      ),
                    );
                  },
                ),
              ),
              if (filterPanel != null)
                IconButton(
                  tooltip: 'Filters',
                  onPressed: () => _showFilterBottomSheet(context),
                  icon: const Icon(Icons.tune),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(child: filterPanel ?? const SizedBox.shrink()),
    );
  }
}
