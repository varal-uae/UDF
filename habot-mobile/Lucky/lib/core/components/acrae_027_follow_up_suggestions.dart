// ACRAE-027 — Follow-Up Question Suggestions Widget with Asked Tracking.
// Displays AI-generated follow-up questions during live interviews and logs
// usage via one-tap 'Mark as Asked' or dismiss actions, using Material 3 tooltips.

import 'package:flutter/material.dart';

/// A reusable Material 3 widget that surfaces follow-up question suggestions
/// during live interviews and tracks interviewer usage via tap actions.
class FollowUpSuggestions extends StatefulWidget {
  const FollowUpSuggestions({
    super.key,
    required this.suggestions,
    required this.onSuggestionAsked,
    this.onSuggestionDismissed,
    this.showTooltips = true,
  });

  /// The initial list of follow-up questions to display.
  final List<String> suggestions;

  /// Called when the interviewer marks a suggestion as asked.
  final ValueChanged<String> onSuggestionAsked;

  /// Called when the interviewer dismisses a suggestion.
  final ValueChanged<String>? onSuggestionDismissed;

  /// Whether to show Material 3 tooltips on action buttons.
  final bool showTooltips;

  @override
  State<FollowUpSuggestions> createState() => _FollowUpSuggestionsState();
}

class _FollowUpSuggestionsState extends State<FollowUpSuggestions> {
  late final List<_SuggestionItem> _items;

  @override
  void initState() {
    super.initState();
    _items = widget.suggestions
        .map((text) => _SuggestionItem(text: text, asked: false))
        .toList();
  }

  @override
  void didUpdateWidget(FollowUpSuggestions oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.suggestions != widget.suggestions) {
      _items
        ..clear()
        ..addAll(widget.suggestions
            .map((text) => _SuggestionItem(text: text, asked: false)));
    }
  }

  void _markAsked(int index) {
    final item = _items[index];
    if (item.asked) return;
    setState(() => item.asked = true);
    widget.onSuggestionAsked(item.text);
  }

  void _dismiss(int index) {
    final item = _items[index];
    setState(() => _items.removeAt(index));
    widget.onSuggestionDismissed?.call(item.text);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (_items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Suggested follow-ups',
              style: textTheme.titleSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            ...List.generate(_items.length, (index) {
              final item = _items[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.text,
                        style: textTheme.bodyMedium?.copyWith(
                          color: item.asked
                              ? colorScheme.outline
                              : colorScheme.onSurface,
                          decoration: item.asked
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: item.asked ? null : () => _markAsked(index),
                      tooltip: widget.showTooltips ? 'Mark as Asked' : null,
                      icon: const Icon(Icons.check_circle_outline),
                      color: colorScheme.primary,
                    ),
                    IconButton(
                      onPressed: () => _dismiss(index),
                      tooltip: widget.showTooltips ? 'Dismiss' : null,
                      icon: const Icon(Icons.close),
                      color: colorScheme.outline,
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _SuggestionItem {
  _SuggestionItem({required this.text, required this.asked});
  final String text;
  bool asked;
}
