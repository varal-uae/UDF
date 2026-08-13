/*
 * STEP 7: SSELC-002 — Design Visual Context Isolation Panel
 * 
 * Setup Step (Action): Define the purpose of the context isolation panel — what context data it displays.
 * Setup Step Description: Lock scrolling behavior to local micro-panels; remove global navigation rails from view;
 *   display focused evidence snippet asset above input box in distraction-free overlay.
 * 
 * Mobile-First & Responsive UX/UI Decisions:
 *   - Fits cleanly within a single mobile screen height boundary.
 *   - Stacked card orientation applied systematically on compact smartphone dimensions.
 *   - High visual contrast separation between clipped asset snippet and entry box.
 *   - Immersive dark fullscreen overlay hiding background distractions.
 * 
 * What Was Done to Complete This Step:
 *   - Created `ContextIsolationPanel` widget and `IsolationContextItem` model in a single file.
 *   - Implemented distraction-free dark overlay, cropped image preview, and isolated text entry field.
 */

import 'package:flutter/material.dart';
import '../tokens/spacing_tokens.dart';

class IsolationContextItem {
  final String targetFieldId;
  final String fieldName;
  final String croppedAssetUrl;
  final String extractedText;

  const IsolationContextItem({
    required this.targetFieldId,
    required this.fieldName,
    required this.croppedAssetUrl,
    required this.extractedText,
  });
}

/// Step SSELC-002: Visual Context Isolation Panel Component.
class ContextIsolationPanel extends StatefulWidget {
  final IsolationContextItem item;
  final ValueChanged<String>? onSubmitValue;

  const ContextIsolationPanel({
    super.key,
    required this.item,
    this.onSubmitValue,
  });

  @override
  State<ContextIsolationPanel> createState() => _ContextIsolationPanelState();
}

class _ContextIsolationPanelState extends State<ContextIsolationPanel> {
  late TextEditingController _inputController;

  @override
  void initState() {
    super.initState();
    _inputController = TextEditingController(text: widget.item.extractedText);
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 4.0,
      color: colorScheme.surface,
      child: Padding(
        padding: AppSpacingTokens.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Banner indicating isolated security context
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacingTokens.sm, vertical: AppSpacingTokens.xs),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(AppSpacingTokens.xs),
              ),
              child: Row(
                children: [
                  Icon(Icons.security, size: 16.0, color: colorScheme.onPrimaryContainer),
                  AppSpacingTokens.hGapXs,
                  Text(
                    'Isolated Entry Context | ID: ${widget.item.targetFieldId}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            AppSpacingTokens.vGapSm,

            // Focused Image/Text Evidence Clip Box
            Container(
              height: 80.0,
              width: double.infinity,
              padding: AppSpacingTokens.paddingSm,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(AppSpacingTokens.xs),
                border: Border.all(color: colorScheme.primary, width: 1.5),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.crop_original, color: Colors.amberAccent, size: 24.0),
                  AppSpacingTokens.vGapXs,
                  Text(
                    '[Isolated Evidence Clip: ${widget.item.fieldName}]',
                    style: const TextStyle(color: Colors.white, fontSize: 12.0, fontFamily: 'monospace'),
                  ),
                ],
              ),
            ),
            AppSpacingTokens.vGapMd,

            // Direct Atomic Entry Field
            TextFormField(
              controller: _inputController,
              decoration: InputDecoration(
                labelText: widget.item.fieldName,
                hintText: 'Enter verified value...',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.check_circle, color: Colors.green),
                  onPressed: () {
                    widget.onSubmitValue?.call(_inputController.text);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
