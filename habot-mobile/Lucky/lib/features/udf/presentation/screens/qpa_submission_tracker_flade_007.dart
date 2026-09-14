// FLADE-007 — Real-Time QPA Submission Status Tracker.
// Displays Boss, Self, and Colleague QPA submission statuses using Material lists,
// semantic state badges, pull-to-refresh capability, >=48dp touch targets, and resilient rate-limiting feedback.

import 'dart:async';
import 'package:flutter/material.dart';

/// Submission lifecycle status for QPA entries.
enum QpaSubmissionStatus {
  submitted,
  overdue,
  pending;

  String get label {
    switch (this) {
      case QpaSubmissionStatus.submitted:
        return 'Submitted';
      case QpaSubmissionStatus.overdue:
        return 'Overdue';
      case QpaSubmissionStatus.pending:
        return 'Pending';
    }
  }

  Color color(ColorScheme colors) {
    switch (this) {
      case QpaSubmissionStatus.submitted:
        return const Color(0xFF2E7D32); // Semantic green
      case QpaSubmissionStatus.overdue:
        return const Color(0xFFD32F2F); // Semantic red
      case QpaSubmissionStatus.pending:
        return const Color(0xFFED6C02); // Semantic amber
    }
  }

  IconData get icon {
    switch (this) {
      case QpaSubmissionStatus.submitted:
        return Icons.check_circle_rounded;
      case QpaSubmissionStatus.overdue:
        return Icons.error_rounded;
      case QpaSubmissionStatus.pending:
        return Icons.schedule_rounded;
    }
  }
}

/// QPA Submission entity containing participant information and verification state.
class QpaParticipant {
  final String id;
  final String name;
  final String category; // 'Boss', 'Self', 'Colleague'
  final String designation;
  final QpaSubmissionStatus status;
  final DateTime? updatedAt;

  const QpaParticipant({
    required this.id,
    required this.name,
    required this.category,
    required this.designation,
    required this.status,
    this.updatedAt,
  });
}

/// Main Screen for tracking real-time QPA submissions.
class QpaSubmissionTrackerScreen extends StatefulWidget {
  const QpaSubmissionTrackerScreen({super.key});

  @override
  State<QpaSubmissionTrackerScreen> createState() =>
      _QpaSubmissionTrackerScreenState();
}

class _QpaSubmissionTrackerScreenState
    extends State<QpaSubmissionTrackerScreen> {
  bool _isLoading = false;
  int _rateLimitSecondsRemaining = 0;
  Timer? _rateLimitTimer;

  List<QpaParticipant> _participants = const [
    QpaParticipant(
      id: 'qpa-001',
      name: 'Eleanor Vance (Reporting Lead)',
      category: 'Boss',
      designation: 'VP of Operations',
      status: QpaSubmissionStatus.submitted,
    ),
    QpaParticipant(
      id: 'qpa-002',
      name: 'Alexander Cross',
      category: 'Self',
      designation: 'Senior Systems Architect',
      status: QpaSubmissionStatus.pending,
    ),
    QpaParticipant(
      id: 'qpa-003',
      name: 'Maya Lin',
      category: 'Colleague',
      designation: 'Staff Product Designer',
      status: QpaSubmissionStatus.submitted,
    ),
    QpaParticipant(
      id: 'qpa-004',
      name: 'David Miller',
      category: 'Colleague',
      designation: 'Principal Security Analyst',
      status: QpaSubmissionStatus.overdue,
    ),
    QpaParticipant(
      id: 'qpa-005',
      name: 'Sophia Sterling',
      category: 'Colleague',
      designation: 'Engineering Manager',
      status: QpaSubmissionStatus.submitted,
    ),
  ];

  @override
  void dispose() {
    _rateLimitTimer?.cancel();
    super.dispose();
  }

  void _startRateLimitCooldown(int seconds) {
    setState(() {
      _rateLimitSecondsRemaining = seconds;
    });
    _rateLimitTimer?.cancel();
    _rateLimitTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_rateLimitSecondsRemaining <= 1) {
        timer.cancel();
        if (mounted) {
          setState(() {
            _rateLimitSecondsRemaining = 0;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _rateLimitSecondsRemaining--;
          });
        }
      }
    });
  }

  Future<void> _handleRefresh() async {
    if (_rateLimitSecondsRemaining > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Too Many Requests. Retrying available in $_rateLimitSecondsRemaining s.',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 750));

    if (mounted) {
      setState(() {
        _isLoading = false;
        _participants = _participants.map((p) {
          return QpaParticipant(
            id: p.id,
            name: p.name,
            category: p.category,
            designation: p.designation,
            status: p.status,
            updatedAt: DateTime.now(),
          );
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categories = ['Boss', 'Self', 'Colleague'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('QPA Submission Tracker'),
        centerTitle: false,
        actions: [
          if (_rateLimitSecondsRemaining > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(
                child: Text(
                  'Retry in ${_rateLimitSecondsRemaining}s',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            if (_rateLimitSecondsRemaining > 0)
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.all(16.0),
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: theme.colorScheme.error),
                  ),
                  child: Row(
                    children:
                        [
                      Icon(Icons.shield_outlined, color: theme.colorScheme.error),
                      const SizedBox(width: 12.0),
                      Expanded(
                        child: Text(
                          'Too Many Requests, Retrying in $_rateLimitSecondsRemaining Seconds',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onErrorContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final category = categories[index];
                    final members = _participants
                        .where((p) => p.category == category)
                        .toList();

                    if (members.isEmpty) return const SizedBox.shrink();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8.0,
                            horizontal: 4.0,
                          ),
                          child: Text(
                            category.toUpperCase(),
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ),
                        Card(
                          margin: const EdgeInsets.only(bottom: 16.0),
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            children: members
                                .map(
                                  (participant) => _QpaListTile(
                                    participant: participant,
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ],
                    );
                  },
                  childCount: categories.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// List tile complying with Material 3 and min 48dp touch accessibility boundary.
class _QpaListTile extends StatelessWidget {
  final QpaParticipant participant;

  const _QpaListTile({required this.participant});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = participant.status.color(theme.colorScheme);

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 48.0),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 4.0,
        ),
        leading: CircleAvatar(
          radius: 20,
          backgroundColor: theme.colorScheme.surfaceVariant,
          child: Text(
            participant.name.isNotEmpty
                ? participant.name.substring(0, 1).toUpperCase()
                : '?',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          participant.name,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          participant.designation,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Semantics(
          label: 'Status: ${participant.status.label}',
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: statusColor.withOpacity(0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(participant.status.icon, size: 16.0, color: statusColor),
                const SizedBox(width: 4.0),
                Text(
                  participant.status.label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
        onTap: () {
          // Accessibility tap handler meeting WCAG touch target standards
        },
      ),
    );
  }
}
