import 'package:flutter/material.dart';

/// Row 377: GEN-01116 (Seq 17825)
/// Action: Measure carousel completion rates against the 90% target threshold.
/// Quality Gate: Mobile Growth Association FRE/Onboarding Benchmark (Target: 0.9).
class CarouselCompletionRatePanel extends StatefulWidget {
  final String globalRefId;
  final String atomicStepRefId;
  final int sequenceOrder;

  const CarouselCompletionRatePanel({
    super.key,
    this.globalRefId = 'GEN-01116',
    this.atomicStepRefId = 'GEN-01116',
    this.sequenceOrder = 17825,
  });

  @override
  State<CarouselCompletionRatePanel> createState() =>
      _CarouselCompletionRatePanelState();
}

class _CarouselCompletionRatePanelState
    extends State<CarouselCompletionRatePanel> {
  final double _targetThreshold = 0.90;
  double _currentCompletionRate = 0.924;
  final int _totalSlideCount = 5;
  int _activeSlideIndex = 4;
  int _completionsLogged = 1380;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPassing = _currentCompletionRate >= _targetThreshold;

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
                    Icons.view_carousel_rounded,
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
                        'GEN-01116: Carousel Completion Rate',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Seq: 17825 • Standard: MGA FRE Benchmark',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
                Chip(
                  avatar: Icon(
                    isPassing ? Icons.check_circle_outline : Icons.warning_amber_rounded,
                    color: isPassing ? Colors.green : Colors.orange,
                    size: 16,
                  ),
                  label: Text('${(_currentCompletionRate * 100).toStringAsFixed(1)}% PASS'),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Target Benchmark:', style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold)),
                    Text('${(_targetThreshold * 100).toInt()}% Completion', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Completed Journeys:', style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold)),
                    Text('$_completionsLogged users', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Carousel Step Progression: Slide ${_activeSlideIndex + 1} of $_totalSlideCount',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
            ),
            const SizedBox(height: 6),
            LinearProgressIndicator(
              value: (_activeSlideIndex + 1) / _totalSlideCount,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                onPressed: () {
                  setState(() {
                    _completionsLogged += 12;
                    _currentCompletionRate = 0.931;
                    _activeSlideIndex = (_activeSlideIndex + 1) % _totalSlideCount;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Logged carousel progress: Completion rate at ${(_currentCompletionRate * 100).toStringAsFixed(1)}% (Threshold: 90%).'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                icon: const Icon(Icons.play_circle_fill_rounded, size: 20),
                label: const Text('Simulate User Carousel Completion'),
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
            child: CarouselCompletionRatePanel(),
          ),
        ),
      ),
    ),
  );
}
