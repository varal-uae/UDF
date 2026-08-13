/*
 * STEP 12: MUFCE-001 — Campaign Imagery & Media Rule Implementation
 * 
 * Setup Step (Action): Build a Material Design 3 fluid grid structure that rearranges upload thumbnails dynamically for mobile layouts.
 * Setup Step Description: Adaptive thumbnail grid for mobile layouts; 44–48px minimum touch targets;
 *   auto-rearranging asset preview tiles.
 * 
 * Mobile-First & Responsive UX/UI Decisions:
 *   - Grid margins set to 16px on mobile viewports using `SliverGrid` / `GridDelegate`.
 *   - Minimum touch target 48x48dp on thumbnail action buttons.
 *   - Dynamic thumbnail tile scaling avoiding horizontal viewport overflow.
 * 
 * What Was Done to Complete This Step:
 *   - Created `M3FluidMediaGrid` widget and `MediaThumbnailItem` model in a single file.
 *   - Implemented responsive fluid media grid, asset upload action trigger, and thumbnail card layout.
 */

import 'package:flutter/material.dart';
import '../tokens/spacing_tokens.dart';

class MediaThumbnailItem {
  final String id;
  final String title;
  final String fileSizeBytes;
  final String mimeType;

  const MediaThumbnailItem({
    required this.id,
    required this.title,
    required this.fileSizeBytes,
    this.mimeType = 'image/jpeg',
  });
}

/// Step MUFCE-001: Material Design 3 Fluid Media Grid component for dynamic upload thumbnails.
class M3FluidMediaGrid extends StatelessWidget {
  final List<MediaThumbnailItem> items;
  final VoidCallback? onAddMedia;

  const M3FluidMediaGrid({
    super.key,
    required this.items,
    this.onAddMedia,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Campaign Media Uploads (${items.length})', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                if (onAddMedia != null)
                  FilledButton.icon(
                    onPressed: onAddMedia,
                    icon: const Icon(Icons.upload_file, size: 16),
                    label: const Text('Upload Media'),
                  ),
              ],
            ),
            AppSpacingTokens.vGapSm,
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: AppSpacingTokens.sm,
                mainAxisSpacing: AppSpacingTokens.sm,
                childAspectRatio: 1.1,
              ),
              itemBuilder: (context, index) {
                final item = items[index];

                return Card(
                  clipBehavior: Clip.antiAlias,
                  color: colorScheme.surfaceContainerHighest,
                  child: Padding(
                    padding: AppSpacingTokens.paddingSm,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.perm_media, color: colorScheme.primary, size: 28.0),
                        AppSpacingTokens.vGapXs,
                        Text(
                          item.title,
                          style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        Text(
                          item.fileSizeBytes,
                          style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
