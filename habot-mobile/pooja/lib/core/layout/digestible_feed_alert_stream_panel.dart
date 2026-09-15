import 'package:flutter/material.dart';

/// Row 270: FLADE-012-10 (Seq 15976)
/// Action: Configure the Feed Layout to ensure alert streams are easily digestible on small mobile screens.
/// Quality Gate: Google SRE Handbook — Monitoring Distributed Systems (≥90% floor, 100% target/ceiling).
class DigestibleFeedAlertStreamPanel extends StatefulWidget {
  final String globalRefId;
  final String atomicStepRefId;
  final int sequenceOrder;

  const DigestibleFeedAlertStreamPanel({
    super.key,
    this.globalRefId = 'FLADE-012-10',
    this.atomicStepRefId = 'FLADE-012-10',
    this.sequenceOrder = 15976,
  });

  @override
  State<DigestibleFeedAlertStreamPanel> createState() =>
      _DigestibleFeedAlertStreamPanelState();
}

class _DigestibleFeedAlertStreamPanelState
    extends State<DigestibleFeedAlertStreamPanel> {
  String _activeFilterTier = 'ALL';
  final List<Map<String, dynamic>> _alertFeedItems = [
    {
      'id': 'ALT-104',
      'tier': 'P1',
      'title': 'Ingestion Gateway Saturation',
      'service': 'telemetry-stream-ap',
      'timeAgo': '2m ago',
      'color': Colors.red,
      'isExpanded': false,
      'details': 'Worker pool utilization reached 98.4%. Auto-scaling group spun up 4 auxiliary pods.',
    },
    {
      'id': 'ALT-105',
      'tier': 'P2',
      'title': 'BigQuery Flush Latency Spike',
      'service': 'bq-pipeline-sync',
      'timeAgo': '7m ago',
      'color': Colors.orange,
      'isExpanded': false,
      'details': 'Table partition lock caused 480ms batch delay. Buffer queues currently draining.',
    },
    {
      'id': 'ALT-106',
      'tier': 'WARN',
      'title': 'Memory Cache Eviction Warning',
      'service': 'session-cache-worker',
      'timeAgo': '14m ago',
      'color': Colors.amber,
      'isExpanded': false,
      'details': 'Volatile heap memory exceeded 75% limit. Automatic LRU pruning executed safely.',
    },
    {
      'id': 'ALT-107',
      'tier': 'INFO',
      'title': 'Daily Routine Audit Synced',
      'service': 'compliance-daemon',
      'timeAgo': '32m ago',
      'color': Colors.blue,
      'isExpanded': false,
      'details': 'All 261 components verified against ISO 9001 checklists. Zero non-conformance flags.',
    },
  ];

  void _toggleAlertExpansion(int index) {
    setState(() {
      _alertFeedItems[index]['isExpanded'] = !(_alertFeedItems[index]['isExpanded'] as bool);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredAlerts = _activeFilterTier == 'ALL'
        ? _alertFeedItems
        : _alertFeedItems.where((a) => a['tier'] == _activeFilterTier).toList();

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.feed_rounded,
                    color: theme.colorScheme.onTertiaryContainer,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Digestible Feed Alert Stream',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${widget.globalRefId} | ${widget.atomicStepRefId} (Seq ${widget.sequenceOrder})',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green),
                  ),
                  child: const Text(
                    'MOBILE M3 DIGEST',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Configures a responsive, high-density alert stream feed engineered specifically for small mobile screens (<400dp width).',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['ALL', 'P1', 'P2', 'WARN', 'INFO'].map((tier) {
                  final isSelected = _activeFilterTier == tier;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      label: Text(tier, style: const TextStyle(fontSize: 11)),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _activeFilterTier = tier;
                          });
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredAlerts.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final alert = filteredAlerts[index];
                final isExpanded = alert['isExpanded'] as bool;
                final tierColor = alert['color'] as Color;
                final aId = alert['id'] as String? ?? '';
                final aTitle = alert['title'] as String? ?? '';
                final aSvc = alert['service'] as String? ?? '';
                final aTime = alert['timeAgo'] as String? ?? '';
                final aTier = alert['tier'] as String? ?? '';
                final aDet = alert['details'] as String? ?? '';

                return InkWell(
                  onTap: () => _toggleAlertExpansion(index),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isExpanded ? tierColor : theme.colorScheme.outlineVariant,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: tierColor.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                aTier,
                                style: TextStyle(
                                  color: tierColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                aTitle,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              aTime,
                              style: TextStyle(
                                fontSize: 10,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                              size: 16,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$aId • $aSvc',
                          style: TextStyle(
                            fontSize: 11,
                            fontFamily: 'monospace',
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (isExpanded) ...[
                          const Divider(height: 12),
                          Text(
                            aDet,
                            style: const TextStyle(fontSize: 11),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
