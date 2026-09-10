// DPNDL-005-A12 - Permanent Sidebar Brand Title.
// Responsive branding anchor pinned to large-screen sidebars; hidden on mobile and fixed footprint prevents layout shifts when badge counts change.
import 'package:flutter/material.dart';

class Dpndl005A12SidebarBrandTitle extends StatelessWidget {
  const Dpndl005A12SidebarBrandTitle({
    super.key,
    this.title = 'Habot',
    this.logoAsset,
    this.badgeCount,
    this.sidebarWidth = 280.0,
    this.breakpoint = 1024.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
  });

  final String title;
  final String? logoAsset;
  final int? badgeCount;
  final double sidebarWidth;
  final double breakpoint;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isLargeScreen = screenWidth >= breakpoint;

    if (!isLargeScreen) {
      return const SizedBox.shrink();
    }

    return Semantics(
      header: true,
      label: 'Brand title: $title',
      child: Container(
        width: sidebarWidth,
        padding: padding,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(
            bottom: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
        ),
        child: Row(
          children: [
            _Dpndl005A12BrandLogo(assetPath: logoAsset),
            const SizedBox(width: 12.0),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
              ),
            ),
            const SizedBox(width: 8.0),
            _Dpndl005A12BadgeSlot(count: badgeCount),
          ],
        ),
      ),
    );
  }
}

class _Dpndl005A12BrandLogo extends StatelessWidget {
  const _Dpndl005A12BrandLogo({this.assetPath});

  final String? assetPath;

  @override
  Widget build(BuildContext context) {
    if (assetPath != null && assetPath!.isNotEmpty) {
      return Image.asset(
        assetPath!,
        width: 32.0,
        height: 32.0,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        errorBuilder: (context, error, stackTrace) => _fallback(context),
      );
    }
    return _fallback(context);
  }

  Widget _fallback(BuildContext context) {
    return Icon(
      Icons.business,
      size: 32.0,
      color: Theme.of(context).colorScheme.primary,
      semanticLabel: 'Brand logo',
    );
  }
}

class _Dpndl005A12BadgeSlot extends StatelessWidget {
  const _Dpndl005A12BadgeSlot({this.count});

  final int? count;

  @override
  Widget build(BuildContext context) {
    final hasBadge = count != null && count! > 0;
    final label = hasBadge ? (count! > 99 ? '99+' : '${count!}') : '';
    return SizedBox(
      width: 32.0,
      child: hasBadge
          ? Container(
              constraints: const BoxConstraints(minWidth: 24.0, minHeight: 24.0),
              padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.error,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onError,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}