// AEETE-013-08 — Loyalty Coin Container: persistent mobile interface bar element that displays a loyalty coin balance, announces balance changes for screen readers, and shows a floating completion alert. Constrained to >=48px touch targets.
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// A compact persistent loyalty coin container for the main app bar.
class LoyaltyCoinContainer extends StatefulWidget {
  const LoyaltyCoinContainer({
    super.key,
    required this.balance,
    this.onTap,
    this.currencySymbol = '🪙',
  });

  final int balance;
  final VoidCallback? onTap;
  final String currencySymbol;

  @override
  State<LoyaltyCoinContainer> createState() => _LoyaltyCoinContainerState();
}

class _LoyaltyCoinContainerState extends State<LoyaltyCoinContainer> {
  @override
  void didUpdateWidget(covariant LoyaltyCoinContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.balance != widget.balance) {
      final delta = widget.balance - oldWidget.balance;
      final changeText = delta >= 0 ? 'Added $delta coins.' : 'Removed ${-delta} coins.';
      final message = 'Loyalty balance updated to ${widget.balance}. $changeText';
      SemanticsService.announce(message, TextDirection.ltr);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final messenger = ScaffoldMessenger.of(context);
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(message),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      label: 'Loyalty coin balance ${widget.balance}',
      value: widget.balance.toString(),
      liveRegion: true,
      button: widget.onTap != null,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
        child: Material(
          color: colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(24),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(widget.currencySymbol, style: textTheme.titleMedium),
                  const SizedBox(width: 6),
                  Text(
                    '${widget.balance}',
                    style: textTheme.titleSmall?.copyWith(
                      color: colorScheme.onSecondaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
