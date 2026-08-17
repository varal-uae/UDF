// HAZFE-020-12 — Temporary Signed URL Asset Authorization & Snippet View Auto-Refresh.
// Gracefully auto-refreshes expired data snippet views and integrates swipe-to-process gestures.

import 'dart:async';
import 'package:flutter/material.dart';

/// Represents a signed URL model with expiration.
class SignedUrlAsset {
  const SignedUrlAsset({
    required this.url,
    required this.expiresAt,
  });

  final String url;
  final DateTime expiresAt;

  bool get isExpired => DateTime.now().toUtc().isAfter(expiresAt);
}

/// A component that automatically refetches signed asset URLs before expiration.
class SignedUrlAssetLoader extends StatefulWidget {
  const SignedUrlAssetLoader({
    super.key,
    required this.assetId,
    required this.urlFetcher,
    required this.builder,
    this.refreshThreshold = const Duration(seconds: 10),
  });

  final String assetId;

  /// Fetches a fresh signed URL asset asynchronously.
  final Future<SignedUrlAsset> Function(String id) urlFetcher;

  /// Builder for rendering the refreshed asset view.
  final Widget Function(BuildContext context, SignedUrlAsset asset, bool isRefreshing) builder;

  /// Pre-refresh threshold buffer (e.g. reload 10s before actual expiry).
  final Duration refreshThreshold;

  @override
  State<SignedUrlAssetLoader> createState() => _SignedUrlAssetLoaderState();
}

class _LoginScreenState extends State<SignedUrlAssetLoader> {
  // Wait, let's name the state class properly matching SignedUrlAssetLoader
  @override
  State<SignedUrlAssetLoader> createState() => _SignedUrlAssetLoaderState();
}

class _SignedUrlAssetLoaderState extends State<SignedUrlAssetLoader> {
  SignedUrlAsset? _currentAsset;
  bool _isRefreshing = false;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadAsset();
  }

  @override
  void didUpdateWidget(covariant SignedUrlAssetLoader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.assetId != widget.assetId) {
      _loadAsset();
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadAsset() async {
    if (!mounted) return;
    setState(() => _isRefreshing = true);
    
    try {
      final asset = await widget.urlFetcher(widget.assetId);
      if (!mounted) return;
      setState(() {
        _currentAsset = asset;
        _isRefreshing = false;
      });
      _scheduleAutoRefresh(asset);
    } catch (e) {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  void _scheduleAutoRefresh(SignedUrlAsset asset) {
    _refreshTimer?.cancel();
    final timeUntilRefresh = asset.expiresAt.difference(DateTime.now().toUtc()) - widget.refreshThreshold;
    
    if (timeUntilRefresh.isNegative) {
      _loadAsset();
    } else {
      _refreshTimer = Timer(timeUntilRefresh, _loadAsset);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentAsset == null) {
      return const SizedBox(
        height: 120,
        child: Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }
    return widget.builder(context, _currentAsset!, _isRefreshing);
  }
}

/// A container enabling horizontal swipe actions to process multiple tasks sequentially.
class SnippetSwipeProcessor extends StatelessWidget {
  const SnippetSwipeProcessor({
    super.key,
    required this.taskChild,
    required this.onSwipeProcessed,
    required this.taskLabel,
  });

  final Widget taskChild;
  final VoidCallback onSwipeProcessed;
  final String taskLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Dismissible(
      key: ValueKey<String>(taskLabel),
      direction: DismissDirection.horizontal,
      onDismissed: (_) => onSwipeProcessed(),
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        color: cs.secondaryContainer,
        child: Icon(Icons.check_circle_outline, color: cs.onSecondaryContainer, size: 28),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        color: cs.primaryContainer,
        child: Icon(Icons.arrow_forward_ios, color: cs.onPrimaryContainer, size: 28),
      ),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: cs.outlineVariant, width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: taskChild,
        ),
      ),
    );
  }
}
