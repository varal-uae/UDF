import 'package:flutter/material.dart';

import '../education/field_help_content.dart';

// AEETE-012-11 — Tap-activated field help beside advanced inputs.
//
// Mobile:
//   - 48dp info icon beside field labels
//   - Tap opens expandable bottom card (never covers the active input)
//   - Keyboard dismissed before sheet opens
//
// Positioning:
//   - Bottom sheet when keyboard is open or field sits in lower half of screen
//   - Compact anchored bubble above the icon when space allows

/// Tap-activated help icon — 48×48dp minimum hit area.
class FieldHelpIcon extends StatelessWidget {
  const FieldHelpIcon({
    super.key,
    required this.content,
    this.anchorKey,
  });

  final FieldHelpContent content;
  final GlobalKey? anchorKey;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'View ${content.title} details',
      hint: 'Opens field explanation',
      child: IconButton(
        key: anchorKey,
        icon: const Icon(Icons.info_outline_rounded, size: 22),
        tooltip: content.title,
        constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
        padding: EdgeInsets.zero,
        onPressed: () => FieldHelpPopup.show(
          context,
          content: content,
          anchorKey: anchorKey,
        ),
      ),
    );
  }
}

/// Label row for advanced fields — title + optional help icon.
class AdvancedFieldLabel extends StatelessWidget {
  const AdvancedFieldLabel({
    super.key,
    required this.fieldLabel,
    this.required = false,
    this.help,
    this.helpAnchorKey,
  });

  final String fieldLabel;
  final bool required;
  final FieldHelpContent? help;
  final GlobalKey? helpAnchorKey;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = required ? '$fieldLabel *' : fieldLabel;

    if (help == null) {
      return Text(
        text,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        FieldHelpIcon(content: help!, anchorKey: helpAnchorKey),
      ],
    );
  }
}

/// Wraps an advanced field with label + help + input — stand-alone block.
class AdvancedFieldWithHelp extends StatelessWidget {
  const AdvancedFieldWithHelp({
    super.key,
    required this.fieldLabel,
    required this.help,
    required this.child,
    this.required = false,
    this.spacing = 8,
  });

  final String fieldLabel;
  final FieldHelpContent help;
  final Widget child;
  final bool required;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final anchorKey = GlobalKey();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AdvancedFieldLabel(
          fieldLabel: fieldLabel,
          required: required,
          help: help,
          helpAnchorKey: anchorKey,
        ),
        SizedBox(height: spacing),
        child,
      ],
    );
  }
}

abstract class FieldHelpPopup {
  FieldHelpPopup._();

  /// Opens help without covering the active text input.
  static Future<void> show(
    BuildContext context, {
    required FieldHelpContent content,
    GlobalKey? anchorKey,
  }) async {
    FocusManager.instance.primaryFocus?.unfocus();

    final useBottomSheet = _shouldUseBottomSheet(context, anchorKey);

    if (useBottomSheet) {
      await _showBottomCard(context, content);
    } else {
      await _showAnchoredBubble(context, content, anchorKey);
    }
  }

  static bool _shouldUseBottomSheet(BuildContext context, GlobalKey? anchorKey) {
    final media = MediaQuery.of(context);
    if (media.viewInsets.bottom > 0) return true;

    if (anchorKey?.currentContext case final ctx?) {
      final box = ctx.findRenderObject() as RenderBox?;
      if (box != null && box.hasSize) {
        final dy = box.localToGlobal(Offset.zero).dy;
        final threshold = media.size.height * 0.55;
        return dy > threshold;
      }
    }

    return true;
  }

  static Future<void> _showBottomCard(
    BuildContext context,
    FieldHelpContent content,
  ) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (ctx) => _FieldHelpBottomCard(content: content),
    );
  }

  static Future<void> _showAnchoredBubble(
    BuildContext context,
    FieldHelpContent content,
    GlobalKey? anchorKey,
  ) async {
    final overlay = Overlay.of(context);
    final anchorCtx = anchorKey?.currentContext;
    if (anchorCtx == null) {
      await _showBottomCard(context, content);
      return;
    }

    final box = anchorCtx.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) {
      await _showBottomCard(context, content);
      return;
    }

    final offset = box.localToGlobal(Offset.zero);
    final size = box.size;
    final screen = MediaQuery.sizeOf(context);
    final top = (offset.dy + size.height + 8).clamp(16.0, screen.height * 0.45);

    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (ctx) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: () => entry.remove(),
              behavior: HitTestBehavior.opaque,
              child: const ColoredBox(color: Colors.black26),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            top: top,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(12),
              color: Theme.of(ctx).colorScheme.surfaceContainerHighest,
              child: _FieldHelpBody(
                content: content,
                onClose: () => entry.remove(),
                compact: true,
              ),
            ),
          ),
        ],
      ),
    );

    overlay.insert(entry);
  }
}

class _FieldHelpBottomCard extends StatelessWidget {
  const _FieldHelpBottomCard({required this.content});

  final FieldHelpContent content;

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * 0.55;

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: _FieldHelpBody(
            content: content,
            onClose: () => Navigator.of(context).pop(),
          ),
        ),
      ),
    );
  }
}

class _FieldHelpBody extends StatelessWidget {
  const _FieldHelpBody({
    required this.content,
    required this.onClose,
    this.compact = false,
  });

  final FieldHelpContent content;
  final VoidCallback onClose;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!compact) const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              Icons.lightbulb_outline_rounded,
              color: theme.colorScheme.primary,
              size: 22,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                content.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded),
              tooltip: 'Close',
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              onPressed: onClose,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Flexible(
          child: SingleChildScrollView(
            child: Text(
              content.body,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
          ),
        ),
        if (content.example != null) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withOpacity(0.35),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.colorScheme.primary.withOpacity(0.3),
              ),
            ),
            child: Text(
              content.example!,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
        if (!compact) ...[
          const SizedBox(height: 16),
          FilledButton(
            onPressed: onClose,
            child: const Text('Close'),
          ),
        ],
      ],
    );
  }
}
