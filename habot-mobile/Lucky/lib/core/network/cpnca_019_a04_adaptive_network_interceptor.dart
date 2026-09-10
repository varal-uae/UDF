// CPNCA-019-A04 — Adaptive Network Connection Listener & Interface Optimization Interceptor.
// Listens to device connectivity changes, exposes throttling/offline state, and renders MD3
// warning banners while preventing un-routable primary actions.

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

enum NetworkQuality { excellent, good, poor, offline }

class NetworkProfile {
  const NetworkProfile({
    required this.quality,
    required this.isMetered,
    required this.downlinkMbps,
  });

  final NetworkQuality quality;
  final bool isMetered;
  final double? downlinkMbps;

  bool get isOffline => quality == NetworkQuality.offline;
  bool get isSlow => quality == NetworkQuality.poor;
  bool get canSubmitPrimaryAction => !isOffline;
}

class AdaptiveNetworkInterceptor extends ChangeNotifier {
  AdaptiveNetworkInterceptor({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity() {
    _subscription = _connectivity.onConnectivityChanged.listen(_onConnectivityChanged);
    unawaited(_refresh());
  }

  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  NetworkProfile _profile = const NetworkProfile(
    quality: NetworkQuality.good,
    isMetered: false,
    downlinkMbps: null,
  );

  NetworkProfile get profile => _profile;
  bool get isOffline => _profile.isOffline;
  bool get isSlowConnection => _profile.isSlow;

  Future<void> _refresh() async {
    final results = await _connectivity.checkConnectivity();
    _applyResults(results);
  }

  void _onConnectivityChanged(List<ConnectivityResult> results) {
    _applyResults(results);
  }

  void _applyResults(List<ConnectivityResult> results) {
    final quality = _qualityFromResults(results);
    final next = NetworkProfile(
      quality: quality,
      isMetered: quality == NetworkQuality.poor,
      downlinkMbps: null,
    );
    if (_profile.quality != next.quality || _profile.isMetered != next.isMetered) {
      _profile = next;
      notifyListeners();
    }
  }

  NetworkQuality _qualityFromResults(List<ConnectivityResult> results) {
    if (results.isEmpty || results.contains(ConnectivityResult.none)) {
      return NetworkQuality.offline;
    }
    if (results.contains(ConnectivityResult.mobile)) {
      return NetworkQuality.poor;
    }
    return NetworkQuality.good;
  }

  bool canExecutePrimaryAction() => !_profile.isOffline;

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

class NetworkStatusBanner extends StatelessWidget {
  const NetworkStatusBanner({
    super.key,
    required this.interceptor,
    this.onRetry,
  });

  final AdaptiveNetworkInterceptor interceptor;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: interceptor,
      builder: (context, _) {
        final profile = interceptor.profile;
        if (profile.quality == NetworkQuality.good ||
            profile.quality == NetworkQuality.excellent) {
          return const SizedBox.shrink();
        }

        final isOffline = profile.isOffline;
        final colorScheme = Theme.of(context).colorScheme;
        final backgroundColor = isOffline
            ? colorScheme.errorContainer
            : colorScheme.tertiaryContainer;
        final foregroundColor = isOffline
            ? colorScheme.onErrorContainer
            : colorScheme.onTertiaryContainer;
        final icon = isOffline ? Icons.wifi_off_rounded : Icons.network_check_rounded;
        final message = isOffline
            ? 'No connection. Primary actions are disabled to protect your work.'
            : 'Weak connection. Optional assets are reduced for reliability.';

        return Material(
          color: backgroundColor,
          elevation: 0,
          child: SafeArea(
            top: false,
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Icon(icon, color: foregroundColor, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      message,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: foregroundColor,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  if (onRetry != null)
                    TextButton(
                      onPressed: onRetry,
                      style: TextButton.styleFrom(foregroundColor: foregroundColor),
                      child: const Text('Retry'),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
