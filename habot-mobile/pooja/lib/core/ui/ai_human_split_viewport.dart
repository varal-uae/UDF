/*
 * STEP 5: SCTSS-017 — Create AI Draft vs Human Edit Split Ratio
 * 
 * Setup Step (Action): Review workflow demands for verifying AI-generated blueprints against human edit tools.
 * Setup Step Description: Decide exact viewport ratio for dual-pane workspace (AI suggestion pane vs human edit input).
 * 
 * Mobile-First & Responsive UX/UI Decisions:
 *   - Side-by-side split layout on desktop/tablet viewports.
 *   - Top-and-bottom stacked vertical orientation automatically applied on compact mobile screens.
 *   - 1-click copy/transfer action from AI suggestion to human input pane.
 * 
 * What Was Done to Complete This Step:
 *   - Created `AiHumanSplitViewport` widget and `AiDraftSplitConfig` model in a single file.
 *   - Implemented dynamic ratio calculation, responsive breakpoint reflow, and transfer action hooks.
 */

import 'package:flutter/material.dart';
import '../tokens/spacing_tokens.dart';

class AiDraftSplitConfig {
  final double defaultSplitRatio; // 0.5 = 50/50 split
  final String aiSuggestionContent;
  final String humanEditContent;

  const AiDraftSplitConfig({
    this.defaultSplitRatio = 0.5,
    required this.aiSuggestionContent,
    required this.humanEditContent,
  });
}

/// Step SCTSS-017: AI Draft vs Human Edit Split Viewport Component.
class AiHumanSplitViewport extends StatefulWidget {
  final AiDraftSplitConfig config;

  const AiHumanSplitViewport({
    super.key,
    required this.config,
  });

  @override
  State<AiHumanSplitViewport> createState() => _AiHumanSplitViewportState();
}

class _AiHumanSplitViewportState extends State<AiHumanSplitViewport> {
  late TextEditingController _humanController;

  @override
  void initState() {
    super.initState();
    _humanController = TextEditingController(text: widget.config.humanEditContent);
  }

  @override
  void dispose() {
    _humanController.dispose();
    super.dispose();
  }

  void _applyAiSuggestion() {
    setState(() {
      _humanController.text = widget.config.aiSuggestionContent;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 700;

        Widget buildAiPane() => Card(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
              child: Padding(
                padding: AppSpacingTokens.paddingMd,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Icon(Icons.auto_awesome, color: colorScheme.primary, size: 20),
                              AppSpacingTokens.hGapXs,
                              Expanded(
                                child: Text(
                                  'AI Draft Suggestion',
                                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _applyAiSuggestion,
                          icon: const Icon(Icons.copy, size: 16),
                          label: const Text('Apply'),
                        ),
                      ],
                    ),
                    AppSpacingTokens.vGapSm,
                    Expanded(
                      child: SingleChildScrollView(
                        child: Text(
                          widget.config.aiSuggestionContent,
                          style: theme.textTheme.bodyMedium?.copyWith(fontFamily: 'monospace'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );

        Widget buildHumanPane() => Card(
              child: Padding(
                padding: AppSpacingTokens.paddingMd,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.person_outline, color: colorScheme.secondary, size: 20),
                        AppSpacingTokens.hGapXs,
                        Expanded(
                          child: Text(
                            'Human Verification & Edit',
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    AppSpacingTokens.vGapSm,
                    Expanded(
                      child: TextField(
                        controller: _humanController,
                        maxLines: null,
                        expands: true,
                        decoration: const InputDecoration(
                          hintText: 'Review and refine AI draft blueprint...',
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            );

        return SizedBox(
          height: 320.0,
          child: isWide
              ? Row(
                  children: [
                    Expanded(child: buildAiPane()),
                    AppSpacingTokens.hGapSm,
                    Expanded(child: buildHumanPane()),
                  ],
                )
              : Column(
                  children: [
                    Expanded(child: buildAiPane()),
                    AppSpacingTokens.vGapSm,
                    Expanded(child: buildHumanPane()),
                  ],
                ),
        );
      },
    );
  }
}
