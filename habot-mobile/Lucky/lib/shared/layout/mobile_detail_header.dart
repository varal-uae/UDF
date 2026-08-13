import 'package:flutter/material.dart';

/// SSELC-029-A01 — Mobile detail screen header.
/// Provides a clear, large "Back to Table" arrow button as required by spec.
/// Use this as the [appBar] on any mobile detail screen.
class MobileDetailHeader extends StatelessWidget implements PreferredSizeWidget {
  const MobileDetailHeader({
    super.key,
    required this.title,
    this.onBack,
    this.actions,
  });

  final String title;
  final VoidCallback? onBack;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      // Large, clear back-to-table button — 48dp touch target enforced.
      leading: IconButton(
        iconSize: 28,
        tooltip: 'Back to Table',
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: onBack ?? () => Navigator.of(context).pop(),
      ),
      title: Text(title),
      actions: actions,
    );
  }
}
