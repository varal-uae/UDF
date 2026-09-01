// ============================================================================
// ARCHITECTURAL TRACKING METADATA BLOCK
// Architecture Pattern: Strict Linear Progression Wizard Graph (Poka-Yoke)
// Component Hierarchy: ViewPagerHost -> PageView -> StepCard -> DotIndicatorRow
// Data Flow Diagram: Step_01 (PRED-NONE) -> Step_02 (PRED-STEP-01) -> Step_03 (PRED-STEP-02)
// Integration Points: Predecessor ID Validation Engine & PageController State Listener
// Mobile Platform: Flutter Universal (iOS / Android / Web / Desktop)
// OS Version: Cross-Platform Universal Runtime
// Device Type: Responsive Adaptive Container (Web, Tablet, Mobile)
// Screen Dimensions: Fluid LayoutBuilder Viewport
// Mobile Configuration: PageScrollPhysics Snap Lock Enforced
// Completion Status: Good - Optimal 1 day turnaround (Target: Good)
// ============================================================================

import 'package:flutter/material.dart';

/// HSFVS-001-A08: Strict Linear Progression ViewPager & Routing Validation
class StrictLinearProgressionViewPager extends StatefulWidget {
  const StrictLinearProgressionViewPager({super.key});

  @override
  State<StrictLinearProgressionViewPager> createState() =>
      _StrictLinearProgressionViewPagerState();
}

class StepData {
  final String stepId;
  final String predecessorId;
  final String title;
  final String description;
  final IconData icon;

  StepData({
    required this.stepId,
    required this.predecessorId,
    required this.title,
    required this.description,
    required this.icon,
  });
}

class _StrictLinearProgressionViewPagerState
    extends State<StrictLinearProgressionViewPager> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<StepData> _wizardSteps = [
    StepData(
      stepId: 'STEP-01',
      predecessorId: 'START-ROOT',
      title: 'Step 1: Account Setup',
      description: 'Initialize primary operational credentials and security keys.',
      icon: Icons.person_add_outlined,
    ),
    StepData(
      stepId: 'STEP-02',
      predecessorId: 'STEP-01',
      title: 'Step 2: Organization Profile',
      description: 'Define organizational tax entity, billing domain, and regional zone.',
      icon: Icons.business_outlined,
    ),
    StepData(
      stepId: 'STEP-03',
      predecessorId: 'STEP-02',
      title: 'Step 3: Verification & Launch',
      description: 'Review SLA parameters and execute final system provisioning.',
      icon: Icons.rocket_launch_outlined,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Strict Routing Graph Validation (Predecessor ID Poka-Yoke)
  void _navigateToStep(int targetIndex, {required String predecessorId}) {
    final targetStep = _wizardSteps[targetIndex];

    // Predecessor ID Poka-Yoke Check
    if (targetStep.predecessorId != predecessorId) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.error,
          content: Text(
            'ROUTING ERROR: Invalid Predecessor ID ("$predecessorId" != expected "${targetStep.predecessorId}"). Navigation Blocked!',
          ),
        ),
      );
      // HARD STOP Exception
      throw Exception(
        'Poka-Yoke Violation: Cannot jump to ${targetStep.stepId} without valid predecessor ID ${targetStep.predecessorId}',
      );
    }

    _pageController.animateToPage(
      targetIndex,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('HSFVS-001: Linear Progression ViewPager'),
        elevation: 2,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth <= 600;

          return Column(
            children: [
              // Header Step Progress Counter
              Container(
                padding: const EdgeInsets.all(16),
                color: theme.colorScheme.surfaceContainerHigh,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Wizard Progression (${_currentPage + 1} of ${_wizardSteps.length})',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Chip(
                      label: Text('Active: ${_wizardSteps[_currentPage].stepId}'),
                      backgroundColor: theme.colorScheme.primaryContainer,
                    ),
                  ],
                ),
              ),

              // PageView & Snap Scrolling (PageScrollPhysics Enforced)
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isMobile ? double.infinity : 600,
                    ),
                    child: PageView.builder(
                      controller: _pageController,
                      physics: const PageScrollPhysics(), // Page Snap Lock
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                      },
                      itemCount: _wizardSteps.length,
                      itemBuilder: (context, index) {
                        final step = _wizardSteps[index];
                        return _buildStepCard(step, index, theme);
                      },
                    ),
                  ),
                ),
              ),

              // Dot Indicators & Controls Row
              Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  border: Border(
                    top: BorderSide(
                      color: theme.colorScheme.outlineVariant,
                    ),
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      // Circular Dot Indicators Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _wizardSteps.length,
                          (index) => _buildDotIndicator(index, theme),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Navigation Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          OutlinedButton.icon(
                            onPressed: _currentPage > 0
                                ? () {
                                    _pageController.previousPage(
                                      duration:
                                          const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                    );
                                  }
                                : null,
                            icon: const Icon(Icons.arrow_back),
                            label: const Text('Previous'),
                          ),
                          FilledButton.icon(
                            onPressed: _currentPage < _wizardSteps.length - 1
                                ? () {
                                    final currentStep =
                                        _wizardSteps[_currentPage];
                                    _navigateToStep(
                                      _currentPage + 1,
                                      predecessorId: currentStep.stepId,
                                    );
                                  }
                                : () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        backgroundColor:
                                            theme.colorScheme.primary,
                                        content: const Text(
                                          'Linear Wizard Completed Successfully!',
                                        ),
                                      ),
                                    );
                                  },
                            icon: Icon(_currentPage < _wizardSteps.length - 1
                                ? Icons.arrow_forward
                                : Icons.check_circle),
                            label: Text(_currentPage < _wizardSteps.length - 1
                                ? 'Next Step'
                                : 'Complete Setup'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Step Content Card
  Widget _buildStepCard(StepData step, int index, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: theme.colorScheme.primaryContainer,
                foregroundColor: theme.colorScheme.onPrimaryContainer,
                child: Icon(step.icon, size: 36),
              ),
              const SizedBox(height: 24),
              Text(
                step.title,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                step.description,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Required Predecessor ID: ${step.predecessorId}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Circular Dot Indicator
  Widget _buildDotIndicator(int index, ThemeData theme) {
    final isActive = _currentPage == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      height: 10.0,
      width: isActive ? 24.0 : 10.0,
      decoration: BoxDecoration(
        color: isActive
            ? theme.colorScheme.primary
            : theme.colorScheme.outlineVariant,
        borderRadius: BorderRadius.circular(5.0),
      ),
    );
  }
}
