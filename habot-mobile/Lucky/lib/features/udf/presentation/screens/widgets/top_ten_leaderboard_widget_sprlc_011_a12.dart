// SPRLC-011-A12 — Top 10% Leaderboard Anonymity Visuals Widget.
// A vertical scrolling leaderboard widget displaying top performers based on aggregated PA scores with identity-masking logic, high-density borders, and adaptive panel stacking for mobile-first Material 3 UX.

import 'package:flutter/material.dart';

/// Represents a single entry in the leaderboard with anonymized identity.
class _LeaderboardEntry {
  final int rank;
  final String maskedName;
  final double paScore;
  final Color avatarColor;

  const _LeaderboardEntry({
    required this.rank,
    required this.maskedName,
    required this.paScore,
    required this.avatarColor,
  });
}

/// Mock data representing the top 10% of employees by PA score.
/// Identity masking is applied directly here to ensure no PII leaks into the UI layer.
const List<_LeaderboardEntry> _mockTopTenPercentData = [
  _LeaderboardEntry(rank: 1, maskedName: 'Emp #A7F2', paScore: 98.5, avatarColor: Color(0xFFD4AF37)),
  _LeaderboardEntry(rank: 2, maskedName: 'Emp #B3C9', paScore: 96.2, avatarColor: Color(0xFFC0C0C0)),
  _LeaderboardEntry(rank: 3, maskedName: 'Emp #D1E4', paScore: 94.8, avatarColor: Color(0xFFCD7F32)),
  _LeaderboardEntry(rank: 4, maskedName: 'Emp #F8G1', paScore: 93.1, avatarColor: Color(0xFF4CAF50)),
  _LeaderboardEntry(rank: 5, maskedName: 'Emp #H2J5', paScore: 91.7, avatarColor: Color(0xFF2196F3)),
  _LeaderboardEntry(rank: 6, maskedName: 'Emp #K9L3', paScore: 90.4, avatarColor: Color(0xFF9C27B0)),
  _LeaderboardEntry(rank: 7, maskedName: 'Emp #M4N8', paScore: 89.9, avatarColor: Color(0xFFFF9800)),
  _LeaderboardEntry(rank: 8, maskedName: 'Emp #P1Q6', paScore: 88.5, avatarColor: Color(0xFF00BCD4)),
  _LeaderboardEntry(rank: 9, maskedName: 'Emp #R7S2', paScore: 87.1, avatarColor: Color(0xFFE91E63)),
  _LeaderboardEntry(rank: 10, maskedName: 'Emp #T5U9', paScore: 86.3, avatarColor: Color(0xFF607D8B)),
];

/// A high-visibility leaderboard widget optimized for vertical thumb-swiping
/// on mobile devices, with adaptive panel stacking on tablet geometries.
/// 
/// Poka-Yoke: All calculations are system-driven and locked; no manual edits allowed.
class TopTenLeaderboardWidget extends StatelessWidget {
  const TopTenLeaderboardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isTablet = MediaQuery.of(context).size.shortestSide >= 600;

    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.all(16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        // High-density borders separating panels elegantly
        side: BorderSide(
          color: theme.colorScheme.outlineVariant,
          width: 2.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(theme),
          const Divider(height: 1, thickness: 2),
          Flexible(
            child: isTablet ? _buildTabletLayout(theme) : _buildMobileLayout(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          Icon(Icons.leaderboard_rounded, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Top 10% Performers',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'PA Score',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Vertical orientation auto-activating on mobile width devices.
  /// Optimized for thumb-swiping with clear ranked avatars.
  Widget _buildMobileLayout(ThemeData theme) {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      itemCount: _mockTopTenPercentData.length,
      separatorBuilder: (context, index) => Divider(
        height: 1,
        thickness: 1.5,
        indent: 16,
        endIndent: 16,
        color: theme.colorScheme.surfaceContainerHighest,
      ),
      itemBuilder: (context, index) {
        return _LeaderboardTile(entry: _mockTopTenPercentData[index]);
      },
    );
  }

  /// Adaptive panel stacking shifting smoothly on tablet geometries.
  /// Precise 50/50 balance splitting seamlessly.
  Widget _buildTabletLayout(ThemeData theme) {
    final int halfLength = (_mockTopTenPercentData.length / 2).ceil();
    final List<_LeaderboardEntry> leftColumn = _mockTopTenPercentData.sublist(0, halfLength);
    final List<_LeaderboardEntry> rightColumn = _mockTopTenPercentData.sublist(halfLength);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            itemCount: leftColumn.length,
            separatorBuilder: (context, index) => const Divider(height: 1, thickness: 1.5),
            itemBuilder: (context, index) => _LeaderboardTile(entry: leftColumn[index]),
          ),
        ),
        VerticalDivider(
          width: 1,
          thickness: 2.0,
          color: theme.colorScheme.surfaceContainerHighest,
        ),
        Expanded(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            itemCount: rightColumn.length,
            separatorBuilder: (context, index) => const Divider(height: 1, thickness: 1.5),
            itemBuilder: (context, index) => _LeaderboardTile(entry: rightColumn[index]),
          ),
        ),
      ],
    );
  }
}

class _LeaderboardTile extends StatelessWidget {
  final _LeaderboardEntry entry;

  const _LeaderboardTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      leading: CircleAvatar(
        backgroundColor: entry.avatarColor.withOpacity(0.2),
        child: Text(
          '#${entry.rank}',
          style: TextStyle(
            color: entry.avatarColor,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
      title: Text(
        entry.maskedName,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
      subtitle: Text(
        'Aggregated PA Score',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: theme.colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: theme.colorScheme.secondary.withOpacity(0.5),
            width: 1.0,
          ),
        ),
        child: Text(
          '${entry.paScore.toStringAsFixed(1)}%',
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSecondaryContainer,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}