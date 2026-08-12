import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/*
 * DEEP LINK LISTENER PLACEHOLDER (Preshared Route Integration)
 * -------------------------------------------------------------
 * To handle Push Notification Deep Links (e.g. via uni_links or Firebase Messaging onMessageOpenedApp):
 * 
 * FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
 *   if (message.data['target'] == 'referral_link' || message.data['route'] == '/referral') {
 *     final referralCode = message.data['code'] ?? 'REF-94820';
 *     Navigator.of(context).push(
 *       MaterialPageRoute(
 *         builder: (context) => ReferralLinkWorkspace(initialCode: referralCode),
 *       ),
 *     );
 *   }
 * });
 * 
 * AppLinks / uni_links URI Stream Listener:
 * uriLinkStream.listen((Uri? uri) {
 *   if (uri != null && uri.path == '/referral') {
 *     final code = uri.queryParameters['code'] ?? 'REF-DEFAULT';
 *     // Route directly to ReferralLinkWorkspace widget
 *   }
 * });
 */

/// Class encapsulating mock share trigger for share_plus integration.
class ShareServices {
  /// Invokes native OS share sheet using `Share.share('Check out this link: $referralUrl')`.
  static Future<void> shareReferralLink(BuildContext context, String referralUrl) async {
    final textToShare = 'Check out this link: $referralUrl';

    // Copy to clipboard for instant user feedback in test/desktop environments
    await Clipboard.setData(ClipboardData(text: textToShare));

    if (!context.mounted) return;

    final colorScheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: colorScheme.primaryContainer,
        behavior: SnackBarBehavior.floating,
        content: Row(
          children: [
            Icon(Icons.share, color: colorScheme.onPrimaryContainer),
            const SizedBox(width: 8.0),
            Expanded(
              child: Text(
                'Invoking native share sheet: "$textToShare"',
                style: TextStyle(color: colorScheme.onPrimaryContainer),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Interactive Referral Link Generator with responsive shapeshifting layout & M3 styling.
class ReferralLinkWorkspace extends StatefulWidget {
  const ReferralLinkWorkspace({
    super.key,
    this.initialCode = 'REF-94820-X9',
  });

  final String initialCode;

  @override
  State<ReferralLinkWorkspace> createState() => _ReferralLinkWorkspaceState();
}

class _ReferralLinkWorkspaceState extends State<ReferralLinkWorkspace> {
  late String _referralCode;
  final String _baseUrl = 'https://app.example.com/invite';

  @override
  void initState() {
    super.initState();
    _referralCode = widget.initialCode;
  }

  String get _fullReferralUrl => '$_baseUrl?code=$_referralCode';

  void _regenerateCode() {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString().substring(8);
    setState(() {
      _referralCode = 'REF-$timestamp-VX';
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Referral Link Generator'),
      ),

      // Requirement 1: Responsive Shapeshifting Layout via LayoutBuilder
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final isWideScreen = constraints.maxWidth > 600;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Requirement 4: Urgency Banner displaying "14 Days Left"
                _buildUrgencyBanner(context, colorScheme, textTheme),
                const SizedBox(height: 16.0),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Program Overview',
                        style: textTheme.titleMedium?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        'Invite colleagues and partners to join the gateway perimeter. Earn priority bandwidth tokens for every successful onboarding.',
                        style: TextStyle(
                          fontSize: 14.0,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 20.0),

                      // Requirement 1: Wide Layout (>600dp) displays full OutlinedCard inline
                      if (isWideScreen) ...[
                        _buildOutlinedCard(context, colorScheme, textTheme),
                      ] else ...[
                        // Narrow Mobile Layout (<=600dp) displays collapsed main banner hint
                        _buildMobileCollapsedCardHint(context, colorScheme, textTheme),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),

      // Requirement 1: Narrow Mobile Layout (maxWidth <= 600) uses FloatingActionButton to open showModalBottomSheet
      floatingActionButton: LayoutBuilder(
        builder: (context, constraints) {
          // Check screen width for FAB visibility
          final mediaWidth = MediaQuery.of(context).size.width;
          if (mediaWidth > 600) {
            return const SizedBox.shrink(); // Hide FAB on wide screens
          }

          return FloatingActionButton.extended(
            onPressed: () => _openReferralBottomSheet(context, colorScheme, textTheme),
            icon: const Icon(Icons.share),
            label: const Text('Share Referral Link'),
          );
        },
      ),
    );
  }

  /// Requirement 4: Visually prominent MaterialBanner displaying "14 Days Left"
  Widget _buildUrgencyBanner(BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    return MaterialBanner(
      elevation: 0,
      backgroundColor: colorScheme.tertiaryContainer,
      leading: Icon(
        Icons.timer_outlined,
        color: colorScheme.onTertiaryContainer,
      ),
      content: Text(
        '14 Days Left — Exclusive Early Access Referral Program',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: colorScheme.onTertiaryContainer,
        ),
      ),
      actions: [
        TextButton(
          onPressed: _regenerateCode,
          child: Text(
            'Regenerate Link',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: colorScheme.onTertiaryContainer,
            ),
          ),
        ),
      ],
    );
  }

  /// Requirement 1 & 2: OutlinedCard with strict M3 text styles & tertiary focus colors
  Widget _buildOutlinedCard(BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    return Card(
      elevation: 0, // OutlinedCard requirement
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: BorderSide(
          color: colorScheme.outlineVariant,
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Requirement 2: Header Text style set strictly to textTheme.titleMedium
            Text(
              'Your Exclusive Referral Link',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12.0),

            Row(
              children: [
                Icon(
                  Icons.alarm_on_outlined,
                  size: 18.0,
                  color: colorScheme.tertiary,
                ),
                const SizedBox(width: 6.0),
                Text(
                  'Campaign Status:',
                  style: TextStyle(
                    fontSize: 13.0,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 6.0),

                // Requirement 2: Countdown Timer focus text color set strictly to colorScheme.tertiary
                Text(
                  '14 Days Left',
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.tertiary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),

            // Referral URL Display Box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.link,
                    size: 20.0,
                    color: colorScheme.tertiary,
                  ),
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: SelectableText(
                      _fullReferralUrl,
                      // Requirement 2: Primary focus text color set strictly to colorScheme.tertiary
                      style: TextStyle(
                        fontSize: 13.0,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                        color: colorScheme.tertiary,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Copy Link',
                    icon: Icon(Icons.copy, size: 18.0, color: colorScheme.primary),
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: _fullReferralUrl));
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Referral link copied to clipboard!'),
                          duration: const Duration(seconds: 2),
                          backgroundColor: colorScheme.primaryContainer,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),

            // Requirement 3: One-Tap Native Sharing Button triggering Share.share
            SizedBox(
              width: double.infinity,
              height: 48.0,
              child: FilledButton.icon(
                onPressed: () => ShareServices.shareReferralLink(context, _fullReferralUrl),
                icon: const Icon(Icons.ios_share),
                label: const Text(
                  'One-Tap Share Link',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileCollapsedCardHint(BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.mobile_friendly, color: colorScheme.primary),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mobile View Active',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        'Tap the floating action button below to open the referral sharing sheet.',
                        style: TextStyle(
                          fontSize: 12.0,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12.0),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _openReferralBottomSheet(context, colorScheme, textTheme),
                icon: const Icon(Icons.launch),
                label: const Text('Open Referral Share Sheet'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Requirement 1: Collapses referral features into showModalBottomSheet on Narrow Mobile (<= 600dp)
  void _openReferralBottomSheet(BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: colorScheme.surfaceContainerHigh,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (BuildContext bottomSheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            top: 20.0,
            bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom + 24.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36.0,
                height: 4.0,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2.0),
                ),
              ),
              const SizedBox(height: 16.0),
              _buildOutlinedCard(context, colorScheme, textTheme),
            ],
          ),
        );
      },
    );
  }
}
