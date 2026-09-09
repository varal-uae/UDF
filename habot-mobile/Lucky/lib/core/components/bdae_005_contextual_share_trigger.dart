// BDAE-005 — Native Mobile Contextual Share Trigger Hook.
// Provides a reusable Material 3 share action that validates deep-link and referral parameters, then invokes the platform share sheet as a non-blocking async operation with inline validation feedback and loading state.

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

/// A contextual share trigger that guards invalid deep-link payloads before opening the share sheet.
class ContextualShareTrigger extends StatefulWidget {
  const ContextualShareTrigger({
    super.key,
    required this.shareUri,
    this.referralCode,
    this.label = 'Share',
    this.icon = Icons.share,
    this.tooltip,
    this.inlineError = true,
  });

  /// The deep-link or share URI to pass to the platform share sheet.
  final Uri shareUri;

  /// Optional referral code appended as `ref` query parameter.
  final String? referralCode;

  final String label;
  final IconData icon;
  final String? tooltip;
  final bool inlineError;

  @override
  State<ContextualShareTrigger> createState() => _ContextualShareTriggerState();
}

class _ContextualShareTriggerState extends State<ContextualShareTrigger> {
  bool _isSharing = false;
  String? _errorText;

  Future<void> _handleShare() async {
    final validationError = _validateDeepLink();
    if (validationError != null) {
      setState(() => _errorText = validationError);
      await _showErrorDialog(validationError);
      return;
    }

    setState(() {
      _isSharing = true;
      _errorText = null;
    });

    try {
      final shareUri = widget.referralCode == null
          ? widget.shareUri
          : _appendReferral(widget.shareUri, widget.referralCode!);
      await SharePlus.instance.share(ShareParams(text: shareUri.toString()));
    } on Exception catch (error) {
      if (!mounted) return;
      setState(() => _errorText = 'Unable to open share sheet: $error');
      await _showErrorDialog(_errorText!);
    } finally {
      if (mounted) {
        setState(() => _isSharing = false);
      }
    }
  }

  String? _validateDeepLink() {
    final uri = widget.shareUri;
    if (!uri.hasScheme || (uri.scheme != 'https' && uri.scheme != 'http')) {
      return 'Share deep link must use http or https.';
    }
    if (uri.host.isEmpty) {
      return 'Share deep link must include a valid host.';
    }
    if (widget.referralCode != null && widget.referralCode!.trim().isEmpty) {
      return 'Referral code cannot be empty.';
    }
    if (widget.referralCode != null &&
        !uri.queryParameters.containsKey('ref') &&
        !uri.queryParameters.containsKey('referral')) {
      return 'Deep link is missing a referral parameter.';
    }
    return null;
  }

  Uri _appendReferral(Uri uri, String referralCode) {
    return uri.replace(
      queryParameters: <String, String>{
        ...uri.queryParameters,
        'ref': referralCode,
      },
    );
  }

  Future<void> _showErrorDialog(String message) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unable to share'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      button: true,
      label: widget.tooltip ?? widget.label,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          OutlinedButton.icon(
            onPressed: _isSharing ? null : _handleShare,
            icon: _isSharing
                ? SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorScheme.primary,
                    ),
                  )
                : Icon(widget.icon),
            label: Text(widget.label),
          ),
          if (widget.inlineError && _errorText != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                _errorText!,
                style: textTheme.bodySmall?.copyWith(color: colorScheme.error),
              ),
            ),
        ],
      ),
    );
  }
}
