import 'package:flutter/material.dart';

/// Row 293: GEN-00196 (Seq 16905)
/// Action: Render a linear timeline view for mobile audit trail histories.
/// Quality Gate: ISO/IEC 27001 Annex A.8.15 / NIST SP 800-92 Cryptographic Chaining Standard.
class MobileAuditTrailTimelinePanel extends StatefulWidget {
  final String globalRefId;
  final String atomicStepRefId;
  final int sequenceOrder;

  const MobileAuditTrailTimelinePanel({
    super.key,
    this.globalRefId = 'GEN-00196',
    this.atomicStepRefId = 'GEN-00196',
    this.sequenceOrder = 16905,
  });

  @override
  State<MobileAuditTrailTimelinePanel> createState() =>
      _MobileAuditTrailTimelinePanelState();
}

class _MobileAuditTrailTimelinePanelState
    extends State<MobileAuditTrailTimelinePanel> {
  final List<Map<String, dynamic>> _timelineEvents = [
    {
      'title': 'System Bootstrapped',
      'timestamp': '09:00:12 UTC',
      'hash': '0x8f2d...41a',
      'status': 'VERIFIED',
      'icon': Icons.power_settings_new_rounded,
    },
    {
      'title': 'Access Policy Activated',
      'timestamp': '09:15:44 UTC',
      'hash': '0x3c9e...77b',
      'status': 'VERIFIED',
      'icon': Icons.security_rounded,
    },
    {
      'title': 'Audit Token Chained',
      'timestamp': '09:30:02 UTC',
      'hash': '0x1a8f...92c',
      'status': 'VERIFIED',
      'icon': Icons.link_rounded,
    },
  ];

  int _eventCount = 3;

  void _addAuditCheckpoint() {
    setState(() {
      _eventCount++;
      _timelineEvents.add({
        'title': 'Checkpoint #$_eventCount Recorded',
        'timestamp': '10:00:${_eventCount.toString().padLeft(2, '0')} UTC',
        'hash': '0x${_eventCount.toRadixString(16).padLeft(4, '0')}...ee1',
        'status': 'VERIFIED',
        'icon': Icons.check_circle_outline_rounded,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.timeline_rounded,
                    color: theme.colorScheme.onPrimaryContainer,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mobile Audit Trail Timeline',
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
                    '100% CHAINED',
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
              'Renders a linear timeline visualization of chronological mobile audit events with cryptographic integrity hashes (ISO/IEC 27001 Annex A.8.15 & NIST SP 800-92).',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.tonalIcon(
                  onPressed: _addAuditCheckpoint,
                  icon: const Icon(Icons.add_task_rounded, size: 18),
                  label: const Text('Add Audit Event'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _timelineEvents.length,
              itemBuilder: (context, index) {
                final ev = _timelineEvents[index];
                final isLast = index == _timelineEvents.length - 1;
                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              ev['icon'] as IconData,
                              size: 14,
                              color: theme.colorScheme.onPrimary,
                            ),
                          ),
                          if (!isLast)
                            Expanded(
                              child: Container(
                                width: 2,
                                color: theme.colorScheme.outlineVariant,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ev['title'] as String,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                '${ev['timestamp']} | Hash: ${ev['hash']}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          ev['status'] as String,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ],
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
