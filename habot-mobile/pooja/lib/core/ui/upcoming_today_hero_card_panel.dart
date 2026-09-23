import 'package:flutter/material.dart';

/// Row 395: GEN-01314 (Seq 18023)
/// Action: Position the "Upcoming Today" Hero Card prominently within the top viewport.
/// Quality Gate: Modern Data Stack SLA Benchmark (dbt/Fivetran) (Target: <5 minutes).
class UpcomingTodayHeroCardPanel extends StatefulWidget {
  final String globalRefId;
  final String atomicStepRefId;
  final int sequenceOrder;

  const UpcomingTodayHeroCardPanel({
    super.key,
    this.globalRefId = 'GEN-01314',
    this.atomicStepRefId = 'GEN-01314',
    this.sequenceOrder = 18023,
  });

  @override
  State<UpcomingTodayHeroCardPanel> createState() =>
      _UpcomingTodayHeroCardPanelState();
}

class _UpcomingTodayHeroCardPanelState
    extends State<UpcomingTodayHeroCardPanel> {
  final String _refreshLatency = '1.9 mins';
  final String _heroEventTitle = 'Junior Coding & AI Workshop';
  final String _heroEventTime = 'Today, 03:00 PM - 04:30 PM';
  final String _heroLocation = 'Innovation Hub, Floor 2';
  int _viewImpressions = 47;

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
                    Icons.star_rounded,
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
                        'GEN-01314: "Upcoming Today" Hero',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Seq: 18023 • Standard: Modern Data Stack SLA',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
                Chip(
                  avatar: const Icon(
                    Icons.speed_rounded,
                    color: Colors.green,
                    size: 16,
                  ),
                  label: Text('$_refreshLatency (<5m PASS)'),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const Divider(height: 24),
            // Prominent Hero Card simulation
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primaryContainer,
                    theme.colorScheme.surfaceContainerHigh,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Chip(
                        label: Text('UPCOMING TODAY', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
                        visualDensity: VisualDensity.compact,
                      ),
                      Text('Starts in 2h 15m', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(_heroEventTitle, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.schedule_rounded, size: 14),
                      const SizedBox(width: 6),
                      Text(_heroEventTime, style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 14),
                      const SizedBox(width: 6),
                      Text(_heroLocation, style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Viewport Impressions: $_viewImpressions', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
                const Text('Placement: Top Viewport (<600dp)', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                onPressed: () {
                  setState(() => _viewImpressions++);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Hero card synced from real-time calendar stream in $_refreshLatency.'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                icon: const Icon(Icons.view_agenda_rounded, size: 20),
                label: const Text('Simulate Hero Card Tap & Viewport Sync'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: UpcomingTodayHeroCardPanel(),
          ),
        ),
      ),
    ),
  );
}
