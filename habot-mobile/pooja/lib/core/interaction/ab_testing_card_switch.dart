/*
 * STEP 14: AEETE-001 — Byte-Level A/B Testing Execution on Mobile Components
 * 
 * Setup Step (Action): Review & execute A/B testing card switcher using adaptive Material cards.
 * Setup Step Description: Interactive variant toggle card displaying conversion rates and variant metrics.
 * 
 * Mobile-First & Responsive UX/UI Decisions:
 *   - Use Adaptive Material Cards for test variants with CSS Flexbox for seamless reflow.
 *   - Touch targets scale to 48dp minimum for mobile compliance.
 *   - Dynamic rendering with instant variant switching feedback.
 * 
 * What Was Done to Complete This Step:
 *   - Created `AbTestingCardSwitch` widget and `AbTestVariant` model in a single file.
 *   - Implemented variant toggle switches, conversion percentage indicators, and active selection states.
 */

import 'package:flutter/material.dart';
import '../tokens/spacing_tokens.dart';

class AbTestVariant {
  final String variantId;
  final String variantName;
  final String description;
  final double conversionRate;

  const AbTestVariant({
    required this.variantId,
    required this.variantName,
    required this.description,
    required this.conversionRate,
  });
}

/// Step AEETE-001: Byte-Level A/B Testing Component Card Switcher.
class AbTestingCardSwitch extends StatefulWidget {
  final List<AbTestVariant> variants;
  final ValueChanged<AbTestVariant>? onVariantSelected;

  const AbTestingCardSwitch({
    super.key,
    required this.variants,
    this.onVariantSelected,
  });

  @override
  State<AbTestingCardSwitch> createState() => _AbTestingCardSwitchState();
}

class _AbTestingCardSwitchState extends State<AbTestingCardSwitch> {
  late int _selectedIdx;

  @override
  void initState() {
    super.initState();
    _selectedIdx = 0;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final selectedVariant = widget.variants[_selectedIdx];

    return Card(
      child: Padding(
        padding: AppSpacingTokens.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Byte-Level A/B Test Variants',
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SegmentedButton<int>(
                  segments: widget.variants.asMap().entries.map((e) {
                    return ButtonSegment<int>(
                      value: e.key,
                      label: Text(e.value.variantName),
                    );
                  }).toList(),
                  selected: {_selectedIdx},
                  onSelectionChanged: (setVal) {
                    setState(() {
                      _selectedIdx = setVal.first;
                    });
                    widget.onVariantSelected?.call(widget.variants[_selectedIdx]);
                  },
                ),
              ],
            ),
            AppSpacingTokens.vGapMd,
            Container(
              padding: AppSpacingTokens.paddingSm,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppSpacingTokens.xs),
              ),
              child: Row(
                children: [
                  Icon(Icons.science, color: colorScheme.primary),
                  AppSpacingTokens.hGapSm,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Active Variant: ${selectedVariant.variantName} (${selectedVariant.variantId})', style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold)),
                        Text(selectedVariant.description, style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ),
                  Text(
                    '${(selectedVariant.conversionRate * 100).toStringAsFixed(1)}% Conv',
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.primary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
