// SSELC-018-A04 — Split-Screen Byt Deconstruction Mobile Paginated Carousel.
// Implements a swipeable horizontal carousel replacing vertical scroll, locking container height to viewport with one action per screen.

import 'package:flutter/material.dart';

/// Mock data representing atomic-level data fields for the Byt carousel.
class BytMockData {
  static const List<Map<String, dynamic>> bytSteps = [
    {
      'id': 'byt_001',
      'label': 'Test Type',
      'hint': 'Enter the type of test performed',
      'fieldKey': 'testType',
    },
    {
      'id': 'byt_002',
      'label': 'Test Result',
      'hint': 'Enter the result of the test',
      'fieldKey': 'testResult',
    },
    {
      'id': 'byt_003',
      'label': 'Test Coverage',
      'hint': 'Enter coverage percentage or scope',
      'fieldKey': 'testCoverage',
    },
    {
      'id': 'byt_004',
      'label': 'Test Timestamp',
      'hint': 'YYYY-MM-DD HH:mm:ss',
      'fieldKey': 'testTimestamp',
    },
    {
      'id': 'byt_005',
      'label': 'Test Log Path',
      'hint': '/logs/test_session_x.log',
      'fieldKey': 'testLogPath',
    },
  ];
}

/// A full-screen swipeable carousel enforcing "one action per screen" (Byt).
/// Replaces vertical scrolling entirely for absolute cognitive focus on mobile.
class BytCarouselWidget extends StatefulWidget {
  const BytCarouselWidget({super.key});

  @override
  State<BytCarouselWidget> createState() => _BytCarouselWidgetState();
}

class _BytCarouselWidgetState extends State<BytCarouselWidget> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final Map<String, String> _formData = {};
  final Map<String, TextEditingController> _controllers = {};

  final List<Map<String, dynamic>> _steps = BytMockData.bytSteps;

  @override
  void initState() {
    super.initState();
    for (final step in _steps) {
      final key = step['fieldKey'] as String;
      _controllers[key] = TextEditingController();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _saveCurrentAndNext() {
    final currentStep = _steps[_currentPage];
    final key = currentStep['fieldKey'] as String;
    final value = _controllers[key]?.text.trim() ?? '';

    // Poka-Yoke: Mathematically impossible to skip a field.
    if (value.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${currentStep['label']} is mandatory. Please fill it before proceeding.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    setState(() {
      _formData[key] = value;
    });

    if (_currentPage < _steps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _onComplete();
    }
  }

  void _goBack() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onComplete() {
    // Captures granular timestamps for each micro-task.
    final completionRecord = {
      ..._formData,
      'completionStatus': 'Pass / Fail',
      'actionEventTimestamp': DateTime.now().toIso8601String(),
    };
    debugPrint('Byt Carousel Completed: $completionRecord');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All Byt screens completed successfully.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Lock container height to viewport (equivalent to 100vh and overflow: hidden)
    return SizedBox.expand(
      child: Column(
        children: [
          // Top horizontal progress bar
          LinearProgressIndicator(
            value: (_currentPage + 1) / _steps.length,
            minHeight: 6,
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(), // Enforce button-only progression (Poka-Yoke)
              itemCount: _steps.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                final step = _steps[index];
                final fieldKey = step['fieldKey'] as String;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Step ${index + 1} of ${_steps.length}',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        step['label'] as String,
                        style: Theme.of(context).textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      TextField(
                        controller: _controllers[fieldKey],
                        decoration: InputDecoration(
                          hintText: step['hint'] as String,
                          border: const OutlineInputBorder(),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surfaceContainerLow,
                        ),
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 48),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (index > 0)
                            OutlinedButton.icon(
                              onPressed: _goBack,
                              icon: const Icon(Icons.arrow_back),
                              label: const Text('Back'),
                            )
                          else
                            const SizedBox.shrink(),
                          FilledButton.icon(
                            onPressed: _saveCurrentAndNext,
                            icon: Icon(index == _steps.length - 1 ? Icons.check : Icons.arrow_forward),
                            label: Text(index == _steps.length - 1 ? 'Submit' : 'Next'),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
