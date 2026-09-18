// GEN-01269 — Add to Apple Wallet and Add to Google Wallet CTA Buttons.
// Embeds "Add to Apple Wallet" and "Add to Google Wallet" CTA buttons below the QR code pass using M3 Elevated Cards, 48x48dp touch targets, and responsive single/multi-column layout.

import 'package:flutter/material.dart';

/// Mock data representing wallet pass availability and configuration.
class _MockWalletPassData {
  static const String appleWalletDeepLink = 'https://wallet.apple.com/mock-pass-id';
  static const String googleWalletDeepLink = 'https://pay.google.com/gp/v/save/mock-pass-id';
  static const double qrScanSuccessRate = 0.99;
  static const double floorThreshold = 0.97;
}

enum _WalletType { apple, google }

class WalletPassCtaButtonsGen01269 extends StatefulWidget {
  final String? qrCodeData;

  const WalletPassCtaButtonsGen01269({
    super.key,
    this.qrCodeData,
  });

  @override
  State<WalletPassCtaButtonsGen01269> createState() => _WalletPassCtaButtonsGen01269State();
}

class _WalletPassCtaButtonsGen01269State extends State<WalletPassCtaButtonsGen01269> {
  bool _isAppleLoading = false;
  bool _isGoogleLoading = false;

  Future<void> _handleWalletTap(_WalletType type) async {
    setState(() {
      if (type == _WalletType.apple) {
        _isAppleLoading = true;
      } else {
        _isGoogleLoading = true;
      }
    });

    // Simulate network call / deep link resolution
    await Future.delayed(const Duration(milliseconds: 80));

    if (!mounted) return;

    setState(() {
      if (type == _WalletType.apple) {
        _isAppleLoading = false;
      } else {
        _isGoogleLoading = false;
      }
    });

    final success = _MockWalletPassData.qrScanSuccessRate >= _MockWalletPassData.floorThreshold;

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? '${type == _WalletType.apple ? 'Apple' : 'Google'} Wallet pass added successfully.'
              : 'Failed to add wallet pass. Success rate below threshold.',
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isDesktop = screenWidth >= 840;

    final appleButton = _buildWalletButton(
      type: _WalletType.apple,
      isLoading: _isAppleLoading,
    );

    final googleButton = _buildWalletButton(
      type: _WalletType.google,
      isLoading: _isGoogleLoading,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      child: isDesktop
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(child: appleButton),
                const SizedBox(width: 16),
                Expanded(child: googleButton),
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                appleButton,
                const SizedBox(height: 16),
                googleButton,
              ],
            ),
    );
  }

  Widget _buildWalletButton({
    required _WalletType type,
    required bool isLoading,
  }) {
    final isApple = type == _WalletType.apple;
    final label = isApple ? 'Add to Apple Wallet' : 'Add to Google Wallet';
    final icon = isApple ? Icons.apple : Icons.g_mobiledata;

    return Card(
      elevation: 3.0, // M3 Elevated Card Level 2 (3dp)
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: isLoading ? null : () => _handleWalletTap(type),
        child: SizedBox(
          height: 48.0, // 48x48dp touch target compliance
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 24.0),
                      const SizedBox(width: 8.0),
                      Text(
                        label,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
