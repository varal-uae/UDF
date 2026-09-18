// GEN-01523 — Sticky Top Cart Banner using M3 Surface Banner components.
// Implements a responsive sticky top banner for cart status with Material 3 design tokens, dynamic color, and mock data.

import 'package:flutter/material.dart';

/// Mock data model representing the cart session state.
class CartSessionMock {
  final String sessionId;
  final int itemCount;
  final double totalAmount;
  final DateTime expiresAt;
  final bool isActive;

  const CartSessionMock({
    required this.sessionId,
    required this.itemCount,
    required this.totalAmount,
    required this.expiresAt,
    required this.isActive,
  });
}

/// Provides realistic local mock data for the cart banner.
class CartBannerMockRepository {
  static CartSessionMock getCurrentSession() {
    return CartSessionMock(
      sessionId: 'sess_8a7b6c5d4e3f',
      itemCount: 3,
      totalAmount: 450.75,
      expiresAt: DateTime.now().add(const Duration(minutes: 14, seconds: 32)),
      isActive: true,
    );
  }
}

/// A sticky top cart banner widget adhering to M3 Surface specifications.
/// Responsive: single-column on mobile (<600dp), multi-column on desktop (>=840dp).
/// Touch targets are minimum 48x48dp.
class StickyCartBanner extends StatefulWidget {
  const StickyCartBanner({super.key});

  @override
  State<StickyCartBanner> createState() => _StickyCartBannerState();
}

class _StickyCartBannerState extends State<StickyCartBanner> {
  late CartSessionMock _session;
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    _session = CartBannerMockRepository.getCurrentSession();
  }

  void _dismissBanner() {
    setState(() {
      _isVisible = false;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Cart banner dismissed'),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              setState(() {
                _isVisible = true;
              });
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible || !_session.isActive) {
      return const SizedBox.shrink();
    }

    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;

    return Material(
      color: colorScheme.surfaceContainerHighest,
      elevation: 3.0, // M3 Elevated Cards Level 2 (3dp)
      shadowColor: colorScheme.shadow.withOpacity(0.2),
      surfaceTintColor: colorScheme.surfaceTint,
      child: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final bool isDesktop = constraints.maxWidth >= 840;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: isDesktop ? _buildDesktopLayout(colorScheme, textTheme) : _buildMobileLayout(colorScheme, textTheme),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMobileLayout(ColorScheme colorScheme, TextTheme textTheme) {
    // Single-column mobile layout
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Your Cart (${_session.itemCount} items)',
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            _buildDismissButton(colorScheme),
          ],
        ),
        const SizedBox(height: 4.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total: AED ${_session.totalAmount.toStringAsFixed(2)}',
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            _buildStatusChip(colorScheme, textTheme),
          ],
        ),
        const SizedBox(height: 8.0),
        SizedBox(
          width: double.infinity,
          height: 48.0, // 48x48dp touch target
          child: FilledButton.tonal(
            onPressed: () {},
            child: const Text('View Cart & Checkout'),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(ColorScheme colorScheme, TextTheme textTheme) {
    // Multi-column desktop layout
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.shopping_cart_outlined, color: colorScheme.primary, size: 24.0),
            const SizedBox(width: 12.0),
            Text(
              'Active Cart: ${_session.itemCount} items | Total: AED ${_session.totalAmount.toStringAsFixed(2)}',
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 16.0),
            _buildStatusChip(colorScheme, textTheme),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 48.0, // 48x48dp touch target
              child: FilledButton(
                onPressed: () {},
                child: const Text('Checkout'),
              ),
            ),
            const SizedBox(width: 8.0),
            _buildDismissButton(colorScheme),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusChip(ColorScheme colorScheme, TextTheme textTheme) {
    return Chip(
      avatar: Icon(
        Icons.timer_outlined,
        size: 16.0,
        color: colorScheme.onSecondaryContainer,
      ),
      label: Text(
        'Expires in 14m 32s',
        style: textTheme.labelSmall?.copyWith(
          color: colorScheme.onSecondaryContainer,
        ),
      ),
      backgroundColor: colorScheme.secondaryContainer,
      side: BorderSide.none,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildDismissButton(ColorScheme colorScheme) {
    return SizedBox(
      width: 48.0, // 48x48dp touch target
      height: 48.0,
      child: IconButton(
        icon: Icon(Icons.close, color: colorScheme.onSurfaceVariant),
        onPressed: _dismissBanner,
        tooltip: 'Dismiss cart banner',
      ),
    );
  }
}
