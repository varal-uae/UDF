// FLADE-021 — Document Access & Candidate Drop-Off Monitoring Dashboard.
// Governs responsive two-column document isolation cards with visual lock banners, classification tags,
// automated access-request pathway, Poka-Yoke permission validation, and W3C load-time telemetry.

import 'dart:async';
import 'package:flutter/material.dart';

/// Classification levels for document security and drop-off tracking.
enum SecurityClassification {
  public,
  internalRole,
  confidential,
  restrictedHpStage,
}

/// Evaluation score aligned with W3C Performance Working Group targets.
enum PerformanceRating {
  good,
  average,
  poor,
}

/// Model representing document attachment and HPF stage drop-off telemetry data.
class DocumentAccessRecord {
  final String stepExecutionId;
  final String documentTitle;
  final String executionStatus;
  final DateTime executionTimestamp;
  final String stepOutcome;
  final String userId;
  final double dropOffRatePercent;
  final SecurityClassification classification;
  final List<String> requiredClassificationKeys;
  final bool isRestricted;

  const DocumentAccessRecord({
    required this.stepExecutionId,
    required this.documentTitle,
    required this.executionStatus,
    required this.executionTimestamp,
    required this.stepOutcome,
    required this.userId,
    required this.dropOffRatePercent,
    required this.classification,
    required this.requiredClassificationKeys,
    required this.isRestricted,
  });
}

/// Dashboard screen monitoring Candidate Drop-Off Rates and Document Access Controls.
class DocumentAccessDashboardFlade021 extends StatefulWidget {
  final String currentUserId;
  final Set<String> currentUserClassificationKeys;

  const DocumentAccessDashboardFlade021({
    super.key,
    this.currentUserId = 'USR-OPERATIONS-021',
    this.currentUserClassificationKeys = const {'KEY-PUBLIC', 'KEY-INTERNAL'},
  });

  @override
  State<DocumentAccessDashboardFlade021> createState() =>
      _DocumentAccessDashboardFlade021State();
}

class _DocumentAccessDashboardFlade021State
    extends State<DocumentAccessDashboardFlade021> {
  late final Stopwatch _loadStopwatch;
  double _dashboardLoadTimeSeconds = 0.0;
  PerformanceRating _loadPerformanceRating = PerformanceRating.good;
  bool _isLoading = true;

  late List<DocumentAccessRecord> _records;

  @override
  void initState()
  {
    super.initState();
    _loadStopwatch = Stopwatch()..start();
    _initializeData();
  }

  void _initializeData() {
    // Simulate optimized data fetching
    Future.delayed(const Duration(milliseconds: 380), () {
      if (!mounted) return;
      _loadStopwatch.stop();
      final loadTime = _loadStopwatch.elapsedMilliseconds / 1000.0;

      PerformanceRating rating;
      if (loadTime <= 1.5) {
        rating = PerformanceRating.good;
      } else if (loadTime <= 3.0) {
        rating = PerformanceRating.average;
      } else {
        rating = PerformanceRating.poor;
      }

      setState(() {
        _dashboardLoadTimeSeconds = loadTime;
        _loadPerformanceRating = rating;
        _records = _generateSampleRecords();
        _isLoading = false;
      });
    });
  }

  List<DocumentAccessRecord> _generateSampleRecords() {
    return [
      DocumentAccessRecord(
        stepExecutionId: 'EXEC-HPF-8101',
        documentTitle: 'Candidate HPF KYC Verification Ledger',
        executionStatus: 'Complete',
        executionTimestamp: DateTime.now().subtract(const Duration(minutes: 12)),
        stepOutcome: 'Drop-Off Tracked',
        userId: 'USR-8921',
        dropOffRatePercent: 14.2,
        classification: SecurityClassification.restrictedHpStage,
        requiredClassificationKeys: const ['KEY-HPF-VERIFIED', 'KEY-COMPLIANCE'],
        isRestricted: true,
      ),
      DocumentAccessRecord(
        stepExecutionId: 'EXEC-HPF-8102',
        documentTitle: 'Identity Onboarding Attachment Registry',
        executionStatus: 'Active',
        executionTimestamp: DateTime.now().subtract(const Duration(minutes: 25)),
        stepOutcome: 'Passing Stage',
        userId: 'USR-7730',
        dropOffRatePercent: 6.8,
        classification: SecurityClassification.internalRole,
        requiredClassificationKeys: const ['KEY-INTERNAL'],
        isRestricted: false,
      ),
      DocumentAccessRecord(
        stepExecutionId: 'EXEC-HPF-8103',
        documentTitle: 'Biometric Telemetry & Compliance Dossier',
        executionStatus: 'Pending Review',
        executionTimestamp: DateTime.now().subtract(const Duration(hours: 1)),
        stepOutcome: 'Audit Pending',
        userId: 'USR-9014',
        dropOffRatePercent: 22.5,
        classification: SecurityClassification.confidential,
        requiredClassificationKeys: const ['KEY-CONFIDENTIAL'],
        isRestricted: true,
      ),
      DocumentAccessRecord(
        stepExecutionId: 'EXEC-HPF-8104',
        documentTitle: 'Candidate Flow Drop-off Analytics Sheet',
        executionStatus: 'Aggregated',
        executionTimestamp: DateTime.now().subtract(const Duration(hours: 2)),
        stepOutcome: 'Baseline Recorded',
        userId: 'USR-5512',
        dropOffRatePercent: 8.1,
        classification: SecurityClassification.public,
        requiredClassificationKeys: const ['KEY-PUBLIC'],
        isRestricted: false,
      ),
    ];
  }

  bool _hasAccessPermission(DocumentAccessRecord record) {
    if (!record.isRestricted) return true;
    return record.requiredClassificationKeys.any(
      (key) => widget.currentUserClassificationKeys.contains(key),
    );
  }

  void _showAccessRequestModal(BuildContext context, DocumentAccessRecord record) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.shield_outlined, color: Theme.of(ctx).colorScheme.error),
                  const SizedBox(width: 8),
                  Text(
                    'Access Restriction (Poka-Yoke)',
                    style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Document ID: ${record.stepExecutionId}\nSession classification profile is missing: ${record.requiredClassificationKeys.join(', ')}.',
                style: Theme.of(ctx).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Viewing sensitive customer records without classification keys violates embedded compliance (DCYN) protocols.',
                style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                      color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      icon: const Icon(Icons.send, size: 16),
                      label: const Text('Request Access'),
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Access request dispatched to SecOps for ${record.stepExecutionId}.',
                            ),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('HPF Candidate Drop-Off & Security'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reload Telemetry',
            onPressed: () {
              setState(() {
                _isLoading = true;
              });
              _initializeData();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWideScreen = constraints.maxWidth >= 600;
                  final crossAxisCount = isWideScreen ? 2 : 1;

                  return CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: _buildTelemetryBanner(theme),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.all(16.0),
                        sliver: SliverGrid(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            mainAxisExtent: 220,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final record = _records[index];
                              final hasAccess = _hasAccessPermission(record);
                              return _buildAccessCard(theme, record, hasAccess);
                            },
                            childCount: _records.length,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
    );
  }

  Widget _buildTelemetryBanner(ThemeData theme) {
    Color badgeColor;
    switch (_loadPerformanceRating) {
      case PerformanceRating.good:
        badgeColor = Colors.teal;
        break;
      case PerformanceRating.average:
        badgeColor = Colors.orange;
        break;
      case PerformanceRating.poor:
        badgeColor = Colors.redAccent;
        break;
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        children:
        [
          Icon(Icons.speed, color: badgeColor, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dashboard Load Target: 1.5s (W3C Standard)',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Measured: ${_dashboardLoadTimeSeconds.toStringAsFixed(2)}s | Status: ${_loadPerformanceRating.name.toUpperCase()}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: badgeColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _loadPerformanceRating.name.toUpperCase(),
              style: theme.textTheme.labelSmall?.copyWith(
                color: badgeColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccessCard(
    ThemeData theme,
    DocumentAccessRecord record,
    bool hasAccess,
  ) {
    final isRestrictedBanner = !hasAccess;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isRestrictedBanner
              ? theme.colorScheme.error.withOpacity(0.4)
              : theme.colorScheme.outlineVariant,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          if (!hasAccess) {
            _showAccessRequestModal(context, record);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Opening document "${record.documentTitle}" securely.'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (isRestrictedBanner)
              Container(
                color: theme.colorScheme.errorContainer,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(
                  children: [
                    Icon(Icons.lock, size: 14, color: theme.colorScheme.onErrorContainer),
                    const SizedBox(width: 6),
                    Text(
                      'RESTRICTED — AUTHENTICATED ACCESS ONLY',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onErrorContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSecurityTag(theme, record.classification),
                        Text(
                          'Drop-Off: ${record.dropOffRatePercent}%',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: record.dropOffRatePercent > 10
                                ? theme.colorScheme.error
                                : theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      record.documentTitle,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Text(
                      'Execution ID: ${record.stepExecutionId}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Status: ${record.executionStatus}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Icon(
                          hasAccess ? Icons.arrow_forward_ios : Icons.lock_outline,
                          size: 14,
                          color: theme.colorScheme.outline,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityTag(ThemeData theme, SecurityClassification classification) {
    String label;
    Color tagColor;

    switch (classification) {
      case SecurityClassification.public:
        label = 'PUBLIC';
        tagColor = Colors.green;
        break;
      case SecurityClassification.internalRole:
        label = 'INTERNAL';
        tagColor = Colors.blue;
        break;
      case SecurityClassification.confidential:
        label = 'CONFIDENTIAL';
        tagColor = Colors.amber.shade800;
        break;
      case SecurityClassification.restrictedHpStage:
        label = 'HPF-RESTRICTED';
        tagColor = Colors.deepOrange;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: tagColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: tagColor.withOpacity(0.4), width: 0.8),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: tagColor,
          fontWeight: FontWeight.bold,
          fontSize: 9,
        ),
      ),
    );
  }
}
