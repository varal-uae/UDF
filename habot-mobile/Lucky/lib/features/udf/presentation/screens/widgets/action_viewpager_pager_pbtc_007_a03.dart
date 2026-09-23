// PBTC-007-A03 — Action ViewPager Pager with MD3 FABs and Lexicon Enforcement.
// Implements swipeable paginated screens to divide compound "AND" logic into single-action pages with fixed 56x56dp Material 3 FABs.

import 'package:flutter/material.dart';

/// Verb ENUMs mapping to UI for lexicon enforcement across the mobile codebase.
enum MobileActionVerb {
  submit,
  approve,
  reject,
  confirm,
  cancel;

  String get label => name.toUpperCase();
}

/// Atomic-level data fields required for step execution tracking.
class StepExecutionRecord {
  final String stepExecutionId;
  final String executionStatus;
  final DateTime executionTimestamp;
  final String stepOutcome;
  final String userId;

  const StepExecutionRecord({
    required this.stepExecutionId,
    required this.executionStatus,
    required this.executionTimestamp,
    required this.stepOutcome,
    required this.userId,
  });
}

/// Mock repository supplying realistic local mock data for action steps.
class MockActionRepository {
  static const List<MobileActionVerb> compoundActions = [
    MobileActionVerb.approve,
    MobileActionVerb.submit,
  ];

  static StepExecutionRecord generateMockRecord(MobileActionVerb verb) {
    return StepExecutionRecord(
      stepExecutionId: 'EXEC-${verb.name.toUpperCase()}-001',
      executionStatus: 'COMPLETED',
      executionTimestamp: DateTime.now(),
      stepOutcome: 'SUCCESS',
      userId: 'USER-MOCK-999',
    );
  }
}

/// Regex parser mechanically drops string resource files containing banned human verbs during compilation.
/// This simulates the Poka-Yoke mistake-proofing requirement.
class LexiconValidator {
  static const Set<String> _bannedHumanVerbs = {
    'MAYBE',
    'TRY',
    'PROBABLY',
    'GUESS',
    'HOPEFULLY',
  };

  static bool isValid(String text) {
    final upperText = text.toUpperCase();
    for (final banned in _bannedHumanVerbs) {
      if (upperText.contains(banned)) {
        throw AssertionError(
          'Lexicon Violation: Banned human verb "$banned" detected. Build rejected.',
        );
      }
    }
    return true;
  }
}

/// The primary ViewPager structure hosting divided actions.
class ActionViewPagerPager extends StatefulWidget {
  const ActionViewPagerPager({super.key});

  @override
  State<ActionViewPagerPager> createState() => _ActionViewPagerPagerState();
}

class _ActionViewPagerPagerState extends State<ActionViewPagerPager> {
  late final PageController _pageController;
  int _currentPage = 0;

  final List<MobileActionVerb> _actions = MockActionRepository.compoundActions;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _executeAction(MobileActionVerb verb) {
    // Enforce lexicon validation before execution
    LexiconValidator.isValid(verb.label);

    final record = MockActionRepository.generateMockRecord(verb);
    debugPrint(
      'Executed: ${record.stepExecutionId} | Status: ${record.executionStatus} | Outcome: ${record.stepOutcome}',
    );

    if (_currentPage < _actions.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'ACTION WORKFLOW',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _actions.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final verb = _actions[index];
                  return _ActionPage(
                    verb: verb,
                    onExecute: () => _executeAction(verb),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Individual paginated screen enforcing the Rule of AND (single-action-per-screen).
class _ActionPage extends StatelessWidget {
  final MobileActionVerb verb;
  final VoidCallback onExecute;

  const _ActionPage({
    required this.verb,
    required this.onExecute,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.touch_app_outlined,
                  size: 80,
                  color: colorScheme.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  'STEP ACTION REQUIRED',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Review the details and tap the action button to proceed.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        // MD3 FAB positioned fixed bottom right per UX Translation requirements
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            onPressed: onExecute,
            backgroundColor: colorScheme.primaryContainer,
            foregroundColor: colorScheme.onPrimaryContainer,
            shape: const CircleBorder(),
            heroTag: 'fab_${verb.name}',
            child: Text(
              verb.label.substring(0, 3), // Crisp iconography/label fitting 56x56dp
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}