// GEN-01103 — M3 Callout Card Banner Component for Pending Account Verification.
// A Material 3 Elevated Card banner that informs users of pending account verification status. Supports responsive single-column mobile layout (<600dp) and multi-column desktop (>=840dp), 48x48dp touch targets, dynamic color, and background polling every 30 seconds with pull-to-refresh.

import 'dart:async';
import 'package:flutter/material.dart';

/// Mock data model representing the onboarding/verification state.
class VerificationStateModel {
  final String userId;
  final String sessionId;
  final bool isVerified;
  final String message;
  final DateTime timestamp;

  const VerificationStateModel({
    required this.userId,
    required this.sessionId,
    required this.isVerified,
    required this.message,
    required this.timestamp,
  });
}

/// Mock repository providing local dummy data for verification status.
class MockVerificationRepository {
  static Future<VerificationStateModel> fetchVerificationStatus() async {
    // Simulate network latency
    await Future.delayed(const Duration(milliseconds: 80));
    return VerificationStateModel(
      userId: 'USR-99281-X',
      sessionId: 'SESS-GEN-01103-20260918',
      isVerified: false,
      message: 'Your account verification is pending. Please complete the required steps to unlock full platform access.',
      timestamp: DateTime.now(),
    );
  }
}

/// M3 Callout Card Banner Widget.
/// Displays a prominent callout for pending account verification.
class M3CalloutCardBanner extends StatefulWidget {
  const M3CalloutCardBanner({super.key});

  @override
  State<M3CalloutCardBanner> createState() => _M3CalloutCardBannerState();
}

class _M3CalloutCardBannerState extends State<M3CalloutCardBanner> {
  VerificationStateModel? _state;
  bool _isLoading = true;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _loadData();
    // Background polling refreshes data every 30 seconds
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final data = await MockVerificationRepository.fetchVerificationStatus();
      if (mounted) {
        setState(() {
          _state = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _onRefresh() async {
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Pull-to-refresh triggers manual sync
    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: colorScheme.primary,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // M3 responsive layout: single-column on mobile (<600dp), multi-column on desktop (>=840dp)
          final bool isDesktop = constraints.maxWidth >= 840;

          if (_isLoading && _state == null) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: CircularProgressIndicator(
                  color: colorScheme.primary,
                ),
              ),
            );
          }

          if (_state == null) {
            return const SizedBox.shrink();
          }

          final verificationState = _state!;

          // Do not show banner if already verified
          if (verificationState.isVerified) {
            return const SizedBox.shrink();
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: isDesktop ? _buildDesktopLayout(theme, verificationState) : _buildMobileLayout(theme, verificationState),
          );
        },
      ),
    );
  }

  Widget _buildMobileLayout(ThemeData theme, VerificationStateModel state) {
    // Single-column mobile layout
    return _buildElevatedCard(
      theme,
      state,
      isVertical: true,
    );
  }

  Widget _buildDesktopLayout(ThemeData theme, VerificationStateModel state) {
    // Multi-column desktop layout
    return _buildElevatedCard(
      theme,
      state,
      isVertical: false,
    );
  }

  Widget _buildElevatedCard(ThemeData theme, VerificationStateModel state, {required bool isVertical}) {
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    // M3 Elevated Cards Level 2 (3dp)
    return Card(
      elevation: 3.0,
      color: colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isVertical
            ? Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _buildCardContent(theme, state),
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _buildCardContent(theme, state),
                    ),
                  ),
                  const SizedBox(width: 24.0),
                  _buildActionButtons(theme),
                ],
              ),
      ),
    );
  }

  List<Widget> _buildCardContent(ThemeData theme, VerificationStateModel state) {
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return [
      Row(
        children: [
          Icon(
            Icons.verified_user_outlined,
            color: colorScheme.error,
            size: 24.0,
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Text(
              'Pending Account Verification',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          // M3 Status Chips for health indicators
          _buildStatusChip(theme, 'Pending'),
        ],
      ),
      const SizedBox(height: 12.0),
      Text(
        state.message,
        style: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      const SizedBox(height: 8.0),
      Text(
        'Session ID: ${state.sessionId}',
        style: textTheme.bodySmall?.copyWith(
          color: colorScheme.outline,
        ),
      ),
      const SizedBox(height: 16.0),
      if (MediaQuery.of(context).size.width < 840) _buildActionButtons(theme),
    ];
  }

  Widget _buildStatusChip(ThemeData theme, String label) {
    final colorScheme = theme.colorScheme;
    return Chip(
      label: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: colorScheme.onErrorContainer,
        ),
      ),
      backgroundColor: colorScheme.errorContainer,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    final colorScheme = theme.colorScheme;

    return Wrap(
      spacing: 12.0,
      runSpacing: 8.0,
      children: [
        // 48x48dp touch targets enforced via minimumSize
        FilledButton.tonal(
          onPressed: () {
            // M3 Snackbar for confirmations
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Navigating to verification flow...'),
                behavior: SnackBarBehavior.floating,
                backgroundColor: colorScheme.inverseSurface,
              ),
            );
          },
          style: FilledButton.styleFrom(
            minimumSize: const Size(48.0, 48.0),
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
          ),
          child: const Text('Verify Now'),
        ),
        OutlinedButton(
          onPressed: () {
            // M3 Bottom Sheet for configuration inputs / details
            showModalBottomSheet(
              context: context,
              builder: (context) => SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Verification Details',
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16.0),
                      Text(
                        'Please upload your government-issued ID and complete the facial recognition step to verify your account.',
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 24.0),
                      SizedBox(
                        width: double.infinity,
                        height: 48.0,
                        child: FilledButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Understood'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(48.0, 48.0),
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
          ),
          child: const Text('Learn More'),
        ),
      ],
    );
  }
}
