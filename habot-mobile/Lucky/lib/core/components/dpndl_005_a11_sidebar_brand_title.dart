// DPNDL-005-A11 — Permanent Sidebar Brand Title.
// Fixed-layout brand anchor for large desktop sidebars. Hidden on mobile, uses SVG logo with fallback text and buffer padding to prevent menu item shifts.

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PermanentSidebarBrandTitle extends StatelessWidget {
  const PermanentSidebarBrandTitle({
    super.key,
    this.logoAsset = 'assets/images/brand_logo.svg',
    this.fallbackText = 'Habot',
    this.height = 72.0,
    this.horizontalPadding = 16.0,
    this.verticalPadding = 12.0,
    this.mobileBreakpoint = 600.0,
  });

  final String logoAsset;
  final String fallbackText;
  final double height;
  final double horizontalPadding;
  final double verticalPadding;
  final double mobileBreakpoint;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    if (screenWidth < mobileBreakpoint) {
      return const SizedBox.shrink();
    }

    return Container(
      height: height,
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      alignment: Alignment.centerLeft,
      child: SvgPicture.asset(
        logoAsset,
        height: height - (verticalPadding * 2),
        fit: BoxFit.contain,
        placeholderBuilder: (context) => Text(
          fallbackText,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
