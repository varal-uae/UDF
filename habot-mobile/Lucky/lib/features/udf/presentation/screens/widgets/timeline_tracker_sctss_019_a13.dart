// SCTSS-019-A13 — Expiry Timeline Tracker Widget.
// Scalable horizontal timeline UI component for visualizing legal restriction expiries with read-only dates, skeleton loading states, and self-chasing padlock overlays.

import 'package:flutter/material.dart';

/// Atomic-level data model for timeline validation.
class TimelineValidationData {
  final String validationType;
  final String validationResult;
  final String? errorMessage;
  final DateTime validationTimestamp;
  final String validationLog;

  const TimelineValidationData({
    required this.validationType,
    required this.validationResult,
    this.errorMessage,
    required this.validationTimestamp,
    required this.validationLog,
  });
}

/// Domain model representing a separated employee's non-compete expiry.
class NonCompeteExpiry {
  final String employeeId;
  final String employeeName;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final TimelineValidationData validation;

  const NonCompeteExpiry({
    required this.employeeId,
    required this.employeeName,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    required this.validation,
  });
}

/// Mock data repository simulating BigQuery daily progression updates.
class MockTimelineRepository {
  static List<NonCompeteExpiry> fetchMockExpiries() {
    final now = DateTime.now();
    return [
      NonCompeteExpiry(
        employeeId: 'EMP-001',
        employeeName: 'John Doe',
        startDate: now.subtract(const Duration(days: 60)),
        endDate: now.add(const Duration(days: 30)),
        isActive: true,
        validation: TimelineValidationData(
          validationType: 'NON_COMPETE_CHECK',
          validationResult: 'PASS',
          validationTimestamp: now.subtract(const Duration(hours: 2)),
          validationLog: 'Validated against UAE Labor Law Art. 127',
        ),
      ),
      NonCompeteExpiry(
        employeeId: 'EMP-002',
        employeeName: 'Jane Smith',
        startDate: now.subtract(const Duration(days: 180)),
        endDate: now.subtract(const Duration(days: 10)),
        isActive: false,
        validation: TimelineValidationData(
          validationType: 'NON_COMPETE_CHECK',
          validationResult: 'PASS',
          validationTimestamp: now.subtract(const Duration(days: 1)),
          validationLog: 'Restriction period expired successfully.',
        ),
      ),
      NonCompeteExpiry(
        employeeId: 'EMP-003',
        employeeName: 'Ahmed Hassan',
        startDate: now.subtract(const Duration(days: 15)),
        endDate: now.add(const Duration(days: 350)),
        isActive: true,
        validation: TimelineValidationData(
          validationType: 'NON_COMPETE_CHECK',
          validationResult: 'PENDING_REVIEW',
          errorMessage: 'Requires manual HR verification for extended term.',
          validationTimestamp: now.subtract(const Duration(minutes: 45)),
          validationLog: 'Flagged for Legal Documentation & Contract Governance review.',
        ),
      ),
    ];
  }
}

/// Poka-Yoke (Mistake-Proofing) wrapper to enforce read-only date rendering.
class ReadOnlyDateText extends StatelessWidget {
  final DateTime date;
  final TextStyle? style;

  const ReadOnlyDateText({
    super.key,
    required this.date,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    // AbsorbPointer physically prevents any click-to-edit interaction
    return AbsorbPointer(
      absorbing: true,
      child: Text(
        '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}',
        style: style ?? Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

/// Skeleton card displayed during active database history fetches.
class TimelineSkeletonCard extends StatelessWidget {
  const TimelineSkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 16, width: 120, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Container(height: 8, width: double.infinity, color: Colors.grey[200]),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(height: 14, width: 80, color: Colors.grey[300]),
                Container(height: 14, width: 80, color: Colors.grey[300]),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Self-Chasing Rehire Button that visually overlays a padlock if non-compete is active.
class RehireActionButton extends StatelessWidget {
  final bool isRestricted;
  final VoidCallback? onRehire;

  const RehireActionButton({
    super.key,
    required this.isRestricted,
    this.onRehire,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: isRestricted ? null : onRehire,
          icon: const Icon(Icons.person_add_alt_1),
          label: const Text('Rehire'),
          style: ElevatedButton.styleFrom(
            backgroundColor: isRestricted 
                ? Theme.of(context).colorScheme.surfaceContainerHighest
                : Theme.of(context).colorScheme.primary,
            foregroundColor: isRestricted
                ? Theme.of(context).colorScheme.onSurfaceVariant
                : Theme.of(context).colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          ),
        ),
        if (isRestricted)
          Positioned(
            top: -4,
            right: -4,
            child: Container(
              padding: const EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                shape: BoxShape.circle,
                border: Border.all(color: Theme.of(context).colorScheme.error, width: 1.5),
              ),
              child: Icon(
                Icons.lock,
                size: 14.0,
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
            ),
          ),
      ],
    );
  }
}

/// Main scalable horizontal timeline UI component.
class TimelineTrackerSctss019A13 extends StatefulWidget {
  const TimelineTrackerSctss019A13({super.key});

  @override
  State<TimelineTrackerSctss019A13> createState() => _TimelineTrackerSctss019A13State();
}

class _TimelineTrackerSctss019A13State extends State<TimelineTrackerSctss019A13> {
  late Future<List<NonCompeteExpiry>> _expiriesFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _expiriesFuture = Future.delayed(
      const Duration(milliseconds: 1500), // Simulate network delay for skeleton visibility
      () => MockTimelineRepository.fetchMockExpiries(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post-Exit Compliance Dashboards'),
        centerTitle: false,
      ),
      body: FutureBuilder<List<NonCompeteExpiry>>(
        future: _expiriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ListView.builder(
              itemCount: 3,
              itemBuilder: (_, __) => const TimelineSkeletonCard(),
            );
          }

          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No timeline data available.'));
          }

          final expiries = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            itemCount: expiries.length,
            itemBuilder: (context, index) {
              final item = expiries[index];
              return _buildTimelineCard(context, item);
            },
          );
        },
      ),
    );
  }

  /// Frame listing components inside explicit layout margins (8dp baseline grid).
  Widget _buildTimelineCard(BuildContext context, NonCompeteExpiry item) {
    final totalDays = item.endDate.difference(item.startDate).inDays;
    final elapsedDays = DateTime.now().difference(item.startDate).inDays;
    final progress = totalDays > 0 ? (elapsedDays / totalDays).clamp(0.0, 1.0) : 0.0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), // 8dp grid alignment
      elevation: 1.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Employee Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    item.employeeName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (item.isActive)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Text(
                      'Active Restriction',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Text(
                      'Expired',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16.0),

            // Horizontal Timeline Component optimized for mobile side-scrolling gestures
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width * 0.8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dynamic TimelineTracker UI scaling visually from start date to end date
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4.0),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8.0,
                        backgroundColor: item.isActive 
                            ? Theme.of(context).colorScheme.surfaceContainerHighest
                            : Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          item.isActive 
                              ? Theme.of(context).colorScheme.error
                              : Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8.0),

                    // Read-only Date Markers (Poka-Yoke)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ReadOnlyDateText(date: item.startDate),
                        ReadOnlyDateText(date: item.endDate),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16.0),

            // Organize complex change parameters into vertical responsive detail rows
            _buildDetailRow(context, 'Employee ID', item.employeeId),
            _buildDetailRow(context, 'Validation Type', item.validation.validationType),
            _buildDetailRow(context, 'Validation Result', item.validation.validationResult),
            if (item.validation.errorMessage != null)
              _buildDetailRow(context, 'Error Message', item.validation.errorMessage!, isError: true),
            _buildDetailRow(context, 'Last Checked', 
              '${item.validation.validationTimestamp.hour}:${item.validation.validationTimestamp.minute.toString().padLeft(2, '0')}'),
            
            const Divider(height: 32.0),

            // Self-Chasing Action Area
            Align(
              alignment: Alignment.centerRight,
              child: RehireActionButton(
                isRestricted: item.isActive,
                onRehire: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Initiating rehire flow for ${item.employeeName}')),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Highlight execution change indicators with high-contrast text styling profiles.
  Widget _buildDetailRow(BuildContext context, String label, String value, {bool isError = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120.0,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: isError 
                    ? Theme.of(context).colorScheme.error 
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
