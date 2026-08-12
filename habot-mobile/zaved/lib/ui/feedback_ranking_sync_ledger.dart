import 'dart:async';
import 'dart:developer' as developer;
import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Enum representing the ranking tiers
enum RankingTier {
  gold('Gold', Icons.military_tech),
  silver('Silver', Icons.workspace_premium),
  bronze('Bronze', Icons.stars);

  const RankingTier(this.displayName, this.icon);
  final String displayName;
  final IconData icon;
}

/// Mock Data Model for Points Ledger User
class LedgerUser {
  final String id;
  final String name;
  final int points;
  final RankingTier tier;

  const LedgerUser({
    required this.id,
    required this.name,
    required this.points,
    required this.tier,
  });

  /// Calculates dynamic tier based on current points balance
  static RankingTier calculateTier(int points) {
    if (points >= 1000) return RankingTier.gold;
    if (points >= 500) return RankingTier.silver;
    return RankingTier.bronze;
  }

  LedgerUser copyWith({int? points}) {
    final updatedPoints = points ?? this.points;
    return LedgerUser(
      id: id,
      name: name,
      points: updatedPoints,
      tier: calculateTier(updatedPoints),
    );
  }
}

/// A responsive 'Feedback-Driven Ranking Sync' Points Ledger Widget (Global Ref ID: OPMV-002).
/// Features:
/// 1. LayoutBuilder switching between DataTable (Web/Tablet > 600) and Card ListView (Mobile <= 600).
/// 2. Dynamic, subtle color coding based on tier with high transparency (.withValues(alpha: ...)).
/// 3. StreamBuilder WebSocket real-time simulation (< 1s update) updating points and tier colors.
/// 4. Poka-Yoke error handling with Material 3 AlertDialog errorContainer styling on payload limit exceed.
class FeedbackRankingSyncLedger extends StatefulWidget {
  const FeedbackRankingSyncLedger({super.key});

  @override
  State<FeedbackRankingSyncLedger> createState() =>
      _FeedbackRankingSyncLedgerState();
}

class _FeedbackRankingSyncLedgerState
    extends State<FeedbackRankingSyncLedger> {
  late final StreamController<List<LedgerUser>> _webSocketStreamController;
  Timer? _webSocketTimer;
  bool _simulatePayloadError = false;

  final List<LedgerUser> _usersBuffer = [
    const LedgerUser(
        id: 'USR-101', name: 'Alex Rivera', points: 1250, tier: RankingTier.gold),
    const LedgerUser(
        id: 'USR-102', name: 'Sophia Chen', points: 840, tier: RankingTier.silver),
    const LedgerUser(
        id: 'USR-103', name: 'Marcus Vance', points: 420, tier: RankingTier.bronze),
    const LedgerUser(
        id: 'USR-104', name: 'Elena Rostova', points: 1100, tier: RankingTier.gold),
    const LedgerUser(
        id: 'USR-105', name: 'David Miller', points: 610, tier: RankingTier.silver),
  ];

  @override
  void initState() {
    super.initState();
    _webSocketStreamController =
        StreamController<List<LedgerUser>>.broadcast();
    _startRealTimeWebSocketSimulation();
  }

  /// Real-Time WebSocket simulation (< 1s updates)
  void _startRealTimeWebSocketSimulation() {
    _webSocketTimer?.cancel();
    _webSocketTimer =
        Timer.periodic(const Duration(milliseconds: 900), (timer) {
      if (_usersBuffer.isEmpty) return;

      // Select random user and simulate incoming feedback points
      final randomIdx = math.Random().nextInt(_usersBuffer.length);
      final currentUser = _usersBuffer[randomIdx];
      final delta = math.Random().nextBool() ? 40 : -30;
      final newPoints = math.max(100, currentUser.points + delta);

      _usersBuffer[randomIdx] = currentUser.copyWith(points: newPoints);
      _webSocketStreamController.add(List.from(_usersBuffer));
    });
  }

  @override
  void dispose() {
    _webSocketTimer?.cancel();
    _webSocketStreamController.close();
    super.dispose();
  }

  /// Helper function returning subtle background color based on tier
  Color _getTierSubtleColor(BuildContext context, RankingTier tier) {
    final theme = Theme.of(context);
    switch (tier) {
      case RankingTier.gold:
        return theme.colorScheme.tertiary.withValues(alpha: 0.15);
      case RankingTier.silver:
        return theme.colorScheme.secondary.withValues(alpha: 0.12);
      case RankingTier.bronze:
        return theme.colorScheme.error.withValues(alpha: 0.10);
    }
  }

  Color _getTierBadgeColor(BuildContext context, RankingTier tier) {
    final theme = Theme.of(context);
    switch (tier) {
      case RankingTier.gold:
        return theme.colorScheme.tertiary;
      case RankingTier.silver:
        return theme.colorScheme.secondary;
      case RankingTier.bronze:
        return theme.colorScheme.error;
    }
  }

  /// Poka-Yoke 'Redeem Points' logic with Payload Limit check
  void _redeemPoints(LedgerUser user, int amount) {
    // Simulated payload size check (Limit: 1024 bytes)
    final payloadSize = _simulatePayloadError ? 2048 : 512;

    if (payloadSize > 1024) {
      developer.log(
        'Poka-Yoke Error: Payload size ($payloadSize bytes) exceeded 1024 byte limit.',
        name: 'LedgerPipeline',
        level: 1000,
      );

      _showMaterial3PayloadErrorDialog(context, payloadSize);
      return; // Stop execution physically
    }

    final newPoints = math.max(0, user.points - amount);
    final idx = _usersBuffer.indexWhere((u) => u.id == user.id);
    if (idx != -1) {
      setState(() {
        _usersBuffer[idx] = user.copyWith(points: newPoints);
      });
      _webSocketStreamController.add(List.from(_usersBuffer));
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Redeemed $amount points for ${user.name}. New total: $newPoints points.',
        ),
      ),
    );
  }

  /// Material 3 AlertDialog styled with errorContainer tonal palette
  void _showMaterial3PayloadErrorDialog(
      BuildContext context, int payloadSize) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: theme.colorScheme.errorContainer,
          surfaceTintColor: theme.colorScheme.errorContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.0),
            side: BorderSide(color: theme.colorScheme.error, width: 1.5),
          ),
          icon: Icon(
            Icons.gpp_bad_rounded,
            size: 40.0,
            color: theme.colorScheme.onErrorContainer,
          ),
          title: Text(
            'Poka-Yoke Security Gate',
            style: TextStyle(
              color: theme.colorScheme.onErrorContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Sending failed: payload over limit',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onErrorContainer,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8.0),
              Text(
                'Payload size of $payloadSize bytes exceeds the maximum allowable limit of 1024 bytes.',
                style: TextStyle(
                  fontSize: 13.0,
                  color: theme.colorScheme.onErrorContainer.withValues(alpha: 0.85),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.onErrorContainer,
              ),
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Dismiss'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Real-Time Control & Poka-Yoke Simulation Toolbar
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Wrap(
            spacing: 16.0,
            runSpacing: 12.0,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.sync_rounded,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Real-Time WebSocket Sync Active',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      Text(
                        'Updates streaming every 900ms',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Simulate Payload Error:',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Switch(
                    value: _simulatePayloadError,
                    onChanged: (val) {
                      setState(() {
                        _simulatePayloadError = val;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20.0),

        // StreamBuilder listening to WebSocket updates
        StreamBuilder<List<LedgerUser>>(
          stream: _webSocketStreamController.stream,
          initialData: _usersBuffer,
          builder: (context, snapshot) {
            final users = snapshot.data ?? [];

            return LayoutBuilder(
              builder: (context, constraints) {
                final isDesktopWebTablet = constraints.maxWidth > 600;

                if (isDesktopWebTablet) {
                  return _buildDataTableLayout(theme, users);
                } else {
                  return _buildMobileCardListViewLayout(theme, users);
                }
              },
            );
          },
        ),
      ],
    );
  }

  /// Web / Tablet Layout (maxWidth > 600): Standard Flutter DataTable with subtle row backgrounds
  Widget _buildDataTableLayout(ThemeData theme, List<LedgerUser> users) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 650),
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(
                theme.colorScheme.surfaceContainerHigh,
              ),
              dataRowMinHeight: 56.0,
              dataRowMaxHeight: 64.0,
              columns: const [
                DataColumn(
                  label: Text(
                    'User Name',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Points Balance',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Current Tier',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Action (Redeem)',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
              rows: users.map((user) {
                final subtleColor = _getTierSubtleColor(context, user.tier);
                final badgeColor = _getTierBadgeColor(context, user.tier);

                return DataRow(
                  // Dynamic, subtle color coding per row using WidgetStateProperty.resolveWith
                  color: WidgetStateProperty.resolveWith((states) => subtleColor),
                  cells: [
                    DataCell(
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 16.0,
                            backgroundColor: badgeColor.withValues(alpha: 0.2),
                            child: Text(
                              user.name.substring(0, 1),
                              style: TextStyle(
                                color: badgeColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10.0),
                          Text(
                            user.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    DataCell(
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          '${user.points} pts',
                          key: ValueKey(user.points),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      Chip(
                        avatar: Icon(user.tier.icon, size: 16.0, color: badgeColor),
                        label: Text(
                          user.tier.displayName,
                          style: TextStyle(
                            color: badgeColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        backgroundColor: badgeColor.withValues(alpha: 0.15),
                        side: BorderSide(color: badgeColor.withValues(alpha: 0.3)),
                      ),
                    ),
                    DataCell(
                      ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 48.0),
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(120.0, 40.0),
                            backgroundColor: theme.colorScheme.primary,
                          ),
                          onPressed: () => _redeemPoints(user, 150),
                          icon: const Icon(Icons.shopping_bag_outlined, size: 16.0),
                          label: const Text('Redeem 150'),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  /// Mobile View Layout (maxWidth <= 600): ListView.builder returning Material Cards
  Widget _buildMobileCardListViewLayout(ThemeData theme, List<LedgerUser> users) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        final subtleColor = _getTierSubtleColor(context, user.tier);
        final badgeColor = _getTierBadgeColor(context, user.tier);

        return Card(
          margin: const EdgeInsets.only(bottom: 12.0),
          elevation: 1,
          color: subtleColor, // Subtle background color based on tier
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
            side: BorderSide(color: badgeColor.withValues(alpha: 0.3)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: badgeColor.withValues(alpha: 0.2),
                          child: Text(
                            user.name.substring(0, 1),
                            style: TextStyle(
                              color: badgeColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12.0),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'ID: ${user.id}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Chip(
                      avatar: Icon(user.tier.icon, size: 16.0, color: badgeColor),
                      label: Text(
                        user.tier.displayName,
                        style: TextStyle(
                          color: badgeColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      backgroundColor: badgeColor.withValues(alpha: 0.2),
                      side: BorderSide.none,
                    ),
                  ],
                ),
                const Divider(height: 24.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Points Balance',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Text(
                            '${user.points} pts',
                            key: ValueKey(user.points),
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 48.0),
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(130.0, 48.0),
                          backgroundColor: theme.colorScheme.primary,
                        ),
                        onPressed: () => _redeemPoints(user, 150),
                        icon: const Icon(Icons.shopping_bag_outlined),
                        label: const Text('Redeem 150'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
