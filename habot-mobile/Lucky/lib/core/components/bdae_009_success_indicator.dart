// BDAE-009 — Material 3 Success State Indicator & App Update Blocking Dialog.
// Maps the locked Material 3 primary color token to the Success state indicator and renders a full-screen blocking dialog for outdated clients.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Bdae009SuccessIndicator extends StatelessWidget {
  const Bdae009SuccessIndicator({super.key, this.size = 24});
  final double size;

  @override
  Widget build(BuildContext context) {
    final Color successColor = Theme.of(context).colorScheme.primary;
    return Icon(Icons.verified_user_outlined, color: successColor, size: size);
  }
}

class Bdae009AppUpdateDialog extends StatelessWidget {
  const Bdae009AppUpdateDialog({super.key, required this.storeUrl});
  final String storeUrl;

  Future<void> _copyStoreLink(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: storeUrl));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Store link copied to clipboard')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog.fullscreen(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(Icons.lock_outline, size: 64, color: theme.colorScheme.primary),
              const SizedBox(height: 24),
              Text(
                'Update Required',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Text(
                'This version is no longer secure. Please update to continue using trusted connections.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: () => _copyStoreLink(context),
                icon: const Icon(Icons.open_in_new),
                label: const Text('Get the latest version'),
              ),
              const SizedBox(height: 8),
              const Bdae009SuccessIndicator(size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> showBdae009AppUpdateDialog(BuildContext context, {required String storeUrl}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => Bdae009AppUpdateDialog(storeUrl: storeUrl),
  );
}
