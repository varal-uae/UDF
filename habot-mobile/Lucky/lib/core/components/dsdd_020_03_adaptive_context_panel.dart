// DSDD-020-03 — Adaptive context isolation panel with inline expanding cards.
// Implements Material 3 adaptive panels, AnimatedSize/AnimatedSwitcher inline disclosure, and token-verified task resume callback; database bounding-box schema is backend-owned.

import 'package:flutter/material.dart';

class Dsdd02003AdaptiveContextPanel extends StatefulWidget {
  const Dsdd02003AdaptiveContextPanel({
    super.key,
    required this.title,
    required this.summary,
    required this.details,
    this.isTokenVerified = false,
    this.onResumeTask,
  });

  final String title;
  final String summary;
  final List<Dsdd02003DetailItem> details;
  final bool isTokenVerified;
  final VoidCallback? onResumeTask;

  @override
  State<Dsdd02003AdaptiveContextPanel> createState() => _Dsdd02003AdaptiveContextPanelState();
}

class _Dsdd02003AdaptiveContextPanelState extends State<Dsdd02003AdaptiveContextPanel> {
  final Set<int> _expandedIndices = <int>{};

  void _toggleDetail(int index) {
    setState(() {
      if (_expandedIndices.contains(index)) {
        _expandedIndices.remove(index);
      } else {
        _expandedIndices.add(index);
      }
    });
  }

  void _handleResume() {
    if (!widget.isTokenVerified) return;
    widget.onResumeTask?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 720;
        final content = _buildContent(context, theme);
        return isWide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: _buildSummaryCard(context, theme)),
                  const SizedBox(width: 16),
                  Expanded(flex: 3, child: content),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSummaryCard(context, theme),
                  const SizedBox(height: 12),
                  content,
                ],
              );
      },
    );
  }

  Widget _buildSummaryCard(BuildContext context, ThemeData theme) {
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title, style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(widget.summary, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 16),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: widget.isTokenVerified
                  ? FilledButton.icon(
                      key: const ValueKey('resume-verified'),
                      onPressed: _handleResume,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Resume task'),
                    )
                  : OutlinedButton.icon(
                      key: const ValueKey('resume-unverified'),
                      onPressed: null,
                      icon: const Icon(Icons.lock_outline),
                      label: const Text('Token verification required'),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ThemeData theme) {
    return Card(
      elevation: 0,
      color: theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Context details', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            for (var i = 0; i < widget.details.length; i++)
              _buildExpandingDetail(context, theme, i),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandingDetail(BuildContext context, ThemeData theme, int index) {
    final item = widget.details[index];
    final isExpanded = _expandedIndices.contains(index);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _toggleDetail(index),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(item.label, style: theme.textTheme.titleSmall),
                    ),
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: const Icon(Icons.expand_more),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: isExpanded
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                      child: Text(item.value, style: theme.textTheme.bodyMedium),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class Dsdd02003DetailItem {
  const Dsdd02003DetailItem({required this.label, required this.value});

  final String label;
  final String value;
}
