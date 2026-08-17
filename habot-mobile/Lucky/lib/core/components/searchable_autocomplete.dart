import 'package:flutter/material.dart';

// DLQDP-009-08 — Searchable Autocomplete Field.
// Spec: "Build searchable autocomplete text fields pre-loaded with
//        approved variable definitions for analyst interfaces."
//       Fallback UI for service unavailability · Empty state + retry · MD3 Snackbar

class AutocompleteOption {
  const AutocompleteOption({
    required this.value,
    required this.label,
    this.description,
    this.category,
  });

  final String value;
  final String label;
  final String? description;
  final String? category;
}

enum AutocompleteLoadState { loading, loaded, error, empty }

class SearchableAutocomplete extends StatefulWidget {
  const SearchableAutocomplete({
    super.key,
    required this.fieldKey,
    required this.label,
    this.hint,
    this.options = const [],
    this.loadState = AutocompleteLoadState.loaded,
    this.onSelected,
    this.onRetry,
    this.required = false,
  });

  final String fieldKey;
  final String label;
  final String? hint;
  final List<AutocompleteOption> options;
  final AutocompleteLoadState loadState;
  final ValueChanged<AutocompleteOption>? onSelected;
  final VoidCallback? onRetry;
  final bool required;

  @override
  State<SearchableAutocomplete> createState() =>
      _SearchableAutocompleteState();
}

class _SearchableAutocompleteState extends State<SearchableAutocomplete> {
  final _controller = TextEditingController();
  AutocompleteOption? _selected;

  List<AutocompleteOption> get _filtered {
    final q = _controller.text.toLowerCase();
    if (q.isEmpty) return widget.options;
    return widget.options.where((o) =>
      o.label.toLowerCase().contains(q) ||
      (o.description?.toLowerCase().contains(q) ?? false)
    ).toList();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Loading state
    if (widget.loadState == AutocompleteLoadState.loading) {
      return _LoadingField(label: widget.label);
    }

    // Error state — fallback UI per spec
    if (widget.loadState == AutocompleteLoadState.error) {
      return _ErrorField(
        label:   widget.label,
        onRetry: widget.onRetry,
      );
    }

    return Autocomplete<AutocompleteOption>(
      optionsBuilder: (textEditingValue) {
        if (textEditingValue.text.isEmpty) return widget.options;
        final q = textEditingValue.text.toLowerCase();
        return widget.options.where((o) =>
          o.label.toLowerCase().contains(q) ||
          (o.description?.toLowerCase().contains(q) ?? false));
      },
      displayStringForOption: (o) => o.label,
      onSelected: (o) {
        setState(() => _selected = o);
        widget.onSelected?.call(o);
      },
      fieldViewBuilder: (ctx, ctrl, focusNode, onSubmit) {
        return TextFormField(
          controller:  ctrl,
          focusNode:   focusNode,
          onFieldSubmitted: (_) => onSubmit(),
          decoration: InputDecoration(
            labelText: widget.required
                ? '${widget.label} *'
                : widget.label,
            hintText: widget.hint ?? 'Search…',
            prefixIcon: const Icon(Icons.search_rounded, size: 20),
            suffixIcon: ctrl.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded, size: 18),
                    tooltip: 'Clear',
                    constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                    onPressed: () { ctrl.clear(); setState(() => _selected = null); },
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      },
      optionsViewBuilder: (ctx, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 240),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount:  options.length,
                itemBuilder: (_, i) {
                  final opt = options.elementAt(i);
                  return InkWell(
                    onTap: () => onSelected(opt),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 48),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(opt.label,
                                style: Theme.of(ctx).textTheme.bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w500)),
                            if (opt.description != null)
                              Text(opt.description!,
                                  style: Theme.of(ctx).textTheme.bodySmall
                                      ?.copyWith(color: Theme.of(ctx)
                                          .colorScheme.onSurfaceVariant)),
                          ],
                        ),
                      ),
                    ),
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

class _LoadingField extends StatelessWidget {
  const _LoadingField({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      child: const SizedBox(
        height: 20,
        child: LinearProgressIndicator(),
      ),
    );
  }
}

class _ErrorField extends StatelessWidget {
  const _ErrorField({required this.label, this.onRetry});
  final String label;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs    = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color:        cs.errorContainer,
        borderRadius: BorderRadius.circular(8),
        border:       Border.all(color: cs.error),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, size: 18, color: cs.onErrorContainer),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Could not load $label options',
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onErrorContainer,
              ),
            ),
          ),
          if (onRetry != null)
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                foregroundColor: cs.onErrorContainer,
                minimumSize: const Size(0, 48),
              ),
              child: const Text('Retry'),
            ),
        ],
      ),
    );
  }
}
