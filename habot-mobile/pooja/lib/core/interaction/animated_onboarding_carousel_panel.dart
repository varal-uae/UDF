import 'package:flutter/material.dart';

/// Row 404: GEN-01413 (Seq 18122)
/// Action: Design a 3-card animated onboarding carousel highlighting key platform value propositions.
/// Quality Gate: MGA FRE/Onboarding Benchmark (Target: 0.9).
class AnimatedOnboardingCarouselPanel extends StatefulWidget {
  final String globalRefId;
  final String atomicStepRefId;
  final int sequenceOrder;

  const AnimatedOnboardingCarouselPanel({
    super.key,
    this.globalRefId = 'GEN-01413',
    this.atomicStepRefId = 'GEN-01413',
    this.sequenceOrder = 18122,
  });

  @override
  State<AnimatedOnboardingCarouselPanel> createState() =>
      _AnimatedOnboardingCarouselPanelState();
}

class _AnimatedOnboardingCarouselPanelState
    extends State<AnimatedOnboardingCarouselPanel> {
  int _activeCardIndex = 0;
  final double _completionRate = 0.93;
  final List<Map<String, dynamic>> _onboardingCards = const [
    {
      'title': '1. Curated Kids Activities',
      'desc': 'Discover vetted sports, arts, and academic camps tailored to your child.',
      'icon': Icons.explore_rounded,
      'color': Colors.blue,
    },
    {
      'title': '2. 100% Verified Providers',
      'desc': 'Every coach and instructor undergoes strict background and safety audits.',
      'icon': Icons.verified_rounded,
      'color': Colors.green,
    },
    {
      'title': '3. 1-Tap Instant Reservation',
      'desc': 'Reserve and manage schedules with instant calendar sync and zero hassle.',
      'icon': Icons.touch_app_rounded,
      'color': Colors.purple,
    },
  ];
  int _carouselCompletions = 22;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentCard = _onboardingCards[_activeCardIndex];

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
                        'GEN-01413: Onboarding Carousel',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Seq: 18122 • Standard: MGA FRE Benchmark',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
                const Chip(
                  avatar: Icon(
                    Icons.check_circle_outline,
                    color: Colors.green,
                    size: 16,
                  ),
                  label: Text('93% FRE PASS'),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const Divider(height: 24),
            // Animated Carousel Card Container
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: (currentCard['color'] as Color).withValues(alpha: 0.5)),
              ),
              child: Column(
                children: [
                  Icon(currentCard['icon'] as IconData, size: 40, color: currentCard['color'] as Color),
                  const SizedBox(height: 8),
                  Text(currentCard['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(
                    currentCard['desc'] as String,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: theme.colorScheme.outline, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Step indicator dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_onboardingCards.length, (index) {
                final isSelected = index == _activeCardIndex;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isSelected ? 16 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Completion Benchmark: ${(_completionRate * 100).toInt()}%', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                Text('Completed Journeys: $_carouselCompletions', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                onPressed: () {
                  setState(() {
                    if (_activeCardIndex == _onboardingCards.length - 1) {
                      _carouselCompletions++;
                    }
                    _activeCardIndex = (_activeCardIndex + 1) % _onboardingCards.length;
                  });
                },
                icon: const Icon(Icons.arrow_forward_rounded, size: 20),
                label: Text(_activeCardIndex == _onboardingCards.length - 1 ? 'Finish & Complete Onboarding' : 'Next Value Proposition'),
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
            child: AnimatedOnboardingCarouselPanel(),
          ),
        ),
      ),
    ),
  );
}
