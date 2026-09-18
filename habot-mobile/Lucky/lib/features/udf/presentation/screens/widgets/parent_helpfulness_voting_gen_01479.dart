// GEN-01479 — M3 Icon buttons for parent helpfulness voting.
// Implements Material 3 icon buttons with 48x48dp touch targets, dynamic color,
// single-column mobile layout (<600dp), multi-column desktop (>=840dp),
// and local mock data for qualitative output (Good/Average/Poor).

import 'package:flutter/material.dart';

/// Mock data model representing a parent helpfulness vote record.
class HelpfulnessVoteRecord {
  final String id;
  final String parentId;
  final String status; // Good, Average, Poor
  final double recognitionAccuracy;
  final DateTime timestamp;

  const HelpfulnessVoteRecord({
    required this.id,
    required this.parentId,
    required this.status,
    required this.recognitionAccuracy,
    required this.timestamp,
  });
}

/// Local mock repository providing realistic dummy data per requirement rule.
class MockHelpfulnessRepository {
  static List<HelpfulnessVoteRecord> getMockVotes() {
    return [
      HelpfulnessVoteRecord(
        id: 'vote_001',
        parentId: 'parent_101',
        status: 'Good',
        recognitionAccuracy: 0.96,
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      HelpfulnessVoteRecord(
        id: 'vote_002',
        parentId: 'parent_102',
        status: 'Average',
        recognitionAccuracy: 0.85,
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      HelpfulnessVoteRecord(
        id: 'vote_003',
        parentId: 'parent_103',
        status: 'Poor',
        recognitionAccuracy: 0.72,
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      ),
    ];
  }
}

/// M3 Status Chip displaying the qualitative health indicator.
class _M3StatusChip extends StatelessWidget {
  final String status;

  const _M3StatusChip({required this.status});

  Color _getStatusColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (status) {
      case 'Good':
        return colorScheme.primary;
      case 'Average':
        return colorScheme.tertiary;
      case 'Poor':
        return colorScheme.error;
      default:
        return colorScheme.outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        status,
        style: TextStyle(
          color: _getStatusColor(context),
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
      backgroundColor: _getStatusColor(context).withOpacity(0.12),
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
    );
  }
}

/// Core widget implementing M3 Icon Buttons for parent helpfulness voting.
/// Enforces 48x48dp touch targets, Material You dynamic color, and responsive layout.
class ParentHelpfulnessVotingWidget extends StatefulWidget {
  const ParentHelpfulnessVotingWidget({super.key});

  @override
  State<ParentHelpfulnessVotingWidget> createState() => _ParentHelpfulnessVotingWidgetState();
}

class _ParentHelpfulnessVotingWidgetState extends State<ParentHelpfulnessVotingWidget> {
  late List<HelpfulnessVoteRecord> _votes;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _loadMockData();
  }

  void _loadMockData() {
    setState(() {
      _votes = MockHelpfulnessRepository.getMockVotes();
    });
  }

  Future<void> _handleRefresh() async {
    setState(() => _isRefreshing = true);
    // Simulate API latency < 100ms as per requirement
    await Future.delayed(const Duration(milliseconds: 80));
    _loadMockData();
    if (mounted) {
      setState(() => _isRefreshing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Sync complete'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  void _onVote(HelpfulnessVoteRecord record, String newStatus) {
    setState(() {
      final index = _votes.indexWhere((v) => v.id == record.id);
      if (index != -1) {
        _votes[index] = HelpfulnessVoteRecord(
          id: record.id,
          parentId: record.parentId,
          status: newStatus,
          recognitionAccuracy: record.recognitionAccuracy,
          timestamp: DateTime.now(),
        );
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Voted $newStatus for ${record.parentId}'),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(label: 'Undo', onPressed: () {}),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // M3 responsive layout: single-column on mobile (<600dp), multi-column on desktop (>=840dp)
        final isDesktop = constraints.maxWidth >= 840;
        final crossAxisCount = isDesktop ? 2 : 1;

        return RefreshIndicator(
          onRefresh: _handleRefresh,
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: isDesktop ? 3.5 : 3.0,
            ),
            itemCount: _votes.length,
            itemBuilder: (context, index) {
              final vote = _votes[index];
              return _buildElevatedCard(context, vote);
            },
          ),
        );
      },
    );
  }

  /// M3 Elevated Card Level 2 (3dp elevation) with inline status chip.
  Widget _buildElevatedCard(BuildContext context, HelpfulnessVoteRecord vote) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 3, // M3 Elevated Cards Level 2 (3dp)
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Parent ID: ${vote.parentId}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Accuracy: ${(vote.recognitionAccuracy * 100).toStringAsFixed(1)}%',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 8),
                  _M3StatusChip(status: vote.status),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // M3 Icon buttons with 48x48dp touch targets
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildIconButton(
                  context,
                  icon: Icons.thumb_up_outlined,
                  selectedIcon: Icons.thumb_up,
                  isSelected: vote.status == 'Good',
                  color: colorScheme.primary,
                  tooltip: 'Mark Good',
                  onPressed: () => _onVote(vote, 'Good'),
                ),
                const SizedBox(height: 4),
                _buildIconButton(
                  context,
                  icon: Icons.thumbs_up_down_outlined,
                  selectedIcon: Icons.thumbs_up_down,
                  isSelected: vote.status == 'Average',
                  color: colorScheme.tertiary,
                  tooltip: 'Mark Average',
                  onPressed: () => _onVote(vote, 'Average'),
                ),
                const SizedBox(height: 4),
                _buildIconButton(
                  context,
                  icon: Icons.thumb_down_outlined,
                  selectedIcon: Icons.thumb_down,
                  isSelected: vote.status == 'Poor',
                  color: colorScheme.error,
                  tooltip: 'Mark Poor',
                  onPressed: () => _onVote(vote, 'Poor'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Ensures strict 48x48dp touch target constraint via SizedBox wrapper.
  Widget _buildIconButton(
    BuildContext context, {
    required IconData icon,
    required IconData selectedIcon,
    required bool isSelected,
    required Color color,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 48,
      height: 48, // 48x48dp touch targets
      child: IconButton(
        icon: Icon(isSelected ? selectedIcon : icon),
        color: isSelected ? color : Theme.of(context).colorScheme.onSurfaceVariant,
        tooltip: tooltip,
        onPressed: onPressed,
        style: IconButton.styleFrom(
          backgroundColor: isSelected ? color.withOpacity(0.12) : Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
