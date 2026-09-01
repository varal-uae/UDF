/// COMPONENT METADATA BLOCK
/// Object Type: DYNAMIC_ONBOARDING_JOURNEY_PAGEVIEW
/// Object Location/Path: /lib/ui/dynamic_onboarding_journey.dart
/// Open Status: ACTIVE
/// Timestamp: 2026-08-18T10:38:28Z
/// File Handle ID: HANDLE-MUFCE-004-PAGEVIEW-001
/// Completion Status: Target: Complete - Requirements Traceability Coverage
library;

import 'package:flutter/material.dart';

/// MUFCE-004: Dynamic Onboarding Journey (AIF) with Single-Milestone Focus
class DynamicOnboardingJourney extends StatefulWidget {
  final VoidCallback? onJourneyComplete;

  const DynamicOnboardingJourney({
    super.key,
    this.onJourneyComplete,
  });

  @override
  State<DynamicOnboardingJourney> createState() =>
      _DynamicOnboardingJourneyState();
}

class _DynamicOnboardingJourneyState extends State<DynamicOnboardingJourney> {
  late PageController _pageController;
  int _currentPage = 0;
  final int _totalPages = 3;

  // Controllers for each single milestone step
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _roleController = TextEditingController();

  final _step1Key = GlobalKey<FormState>();
  final _step2Key = GlobalKey<FormState>();
  final _step3Key = GlobalKey<FormState>();

  bool _isStep1Valid = false;
  bool _isStep2Valid = false;
  bool _isStep3Valid = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _roleController.dispose();
    super.dispose();
  }

  bool get _allStepsValid => _isStep1Valid && _isStep2Valid && _isStep3Valid;

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.animateToPage(
        _currentPage - 1,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final keyboardBottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainer,
      appBar: AppBar(
        title: const Text('Dynamic Onboarding'),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        actions: [
          // Header Progress Wheel (PageView index vs total steps)
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  value: (_currentPage + 1) / _totalPages,
                  strokeWidth: 3.5,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  color: colorScheme.primary,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        // Dynamic Keyboard Margins via Padding responding to viewInsets.bottom
        child: Padding(
          padding: EdgeInsets.only(bottom: keyboardBottomPadding),
          child: SingleChildScrollView(
            child: SizedBox(
              height: MediaQuery.of(context).size.height - 120,
              child: Column(
                children: [
                  // Step Indicator Header
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Step ${_currentPage + 1} of $_totalPages',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${((_currentPage + 1) / _totalPages * 100).round()}% Completed',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Sliding Milestone PageView
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(), // Enforce button step flow
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                      },
                      children: [
                        _buildStep1(colorScheme, theme),
                        _buildStep2(colorScheme, theme),
                        _buildStep3(colorScheme, theme),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Step 1: Legal Name Milestone
  Widget _buildStep1(ColorScheme colorScheme, ThemeData theme) {
    return _buildMilestoneCard(
      colorScheme: colorScheme,
      theme: theme,
      title: 'Milestone 1: Identity',
      subtitle: 'Please enter your full official legal name.',
      formKey: _step1Key,
      onChanged: () {
        setState(() {
          _isStep1Valid = _step1Key.currentState?.validate() ?? false;
        });
      },
      field: TextFormField(
        controller: _nameController,
        keyboardType: TextInputType.name,
        validator: (val) =>
            val == null || val.trim().isEmpty ? 'Full name is required' : null,
        decoration: InputDecoration(
          labelText: 'Full Legal Name',
          prefixIcon: Icon(Icons.person, color: colorScheme.primary),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: colorScheme.primary, width: 2.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: colorScheme.primary, width: 2.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: colorScheme.error, width: 2.0),
          ),
        ),
      ),
      explanatoryContext:
          'Explanatory Context: We collect your full legal name to generate compliant authorization certificates across back-office services.',
      buttonLabel: 'Continue to Step 2',
      isNextEnabled: _isStep1Valid,
      onNextPressed: () {
        if (_step1Key.currentState?.validate() ?? false) {
          _nextPage();
        }
      },
    );
  }

  /// Step 2: Contact Milestone
  Widget _buildStep2(ColorScheme colorScheme, ThemeData theme) {
    return _buildMilestoneCard(
      colorScheme: colorScheme,
      theme: theme,
      title: 'Milestone 2: Contact',
      subtitle: 'Please enter your primary mobile phone number.',
      formKey: _step2Key,
      onChanged: () {
        setState(() {
          _isStep2Valid = _step2Key.currentState?.validate() ?? false;
        });
      },
      field: TextFormField(
        controller: _phoneController,
        keyboardType: TextInputType.phone,
        validator: (val) => val == null || val.trim().length < 10
            ? 'Enter a valid 10-digit phone number'
            : null,
        decoration: InputDecoration(
          labelText: 'Mobile Phone Number',
          prefixIcon: Icon(Icons.phone, color: colorScheme.primary),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: colorScheme.primary, width: 2.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: colorScheme.primary, width: 2.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: colorScheme.error, width: 2.0),
          ),
        ),
      ),
      explanatoryContext:
          'Explanatory Context: Phone verification protects your account with multi-factor authentication triggers.',
      buttonLabel: 'Continue to Final Step',
      isNextEnabled: _isStep2Valid,
      onNextPressed: () {
        if (_step2Key.currentState?.validate() ?? false) {
          _nextPage();
        }
      },
      onBackPressed: _previousPage,
    );
  }

  /// Step 3: Role Milestone & Locked Submittal
  Widget _buildStep3(ColorScheme colorScheme, ThemeData theme) {
    return _buildMilestoneCard(
      colorScheme: colorScheme,
      theme: theme,
      title: 'Milestone 3: Organization Role',
      subtitle: 'Select or specify your operational team role.',
      formKey: _step3Key,
      onChanged: () {
        setState(() {
          _isStep3Valid = _step3Key.currentState?.validate() ?? false;
        });
      },
      field: TextFormField(
        controller: _roleController,
        keyboardType: TextInputType.text,
        validator: (val) =>
            val == null || val.trim().isEmpty ? 'Role is required' : null,
        decoration: InputDecoration(
          labelText: 'Operational Role',
          prefixIcon: Icon(Icons.badge, color: colorScheme.primary),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: colorScheme.primary, width: 2.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: colorScheme.primary, width: 2.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: colorScheme.error, width: 2.0),
          ),
        ),
      ),
      explanatoryContext:
          'Explanatory Context: Role configuration grants explicit access rights to workspace modules.',
      buttonLabel: 'Complete Profile',

      // Poka-Yoke Locked Submittal: disabled (null) until ALL steps valid
      isNextEnabled: _allStepsValid,
      onNextPressed: _allStepsValid
          ? () {
              if (widget.onJourneyComplete != null) {
                widget.onJourneyComplete!();
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: colorScheme.primary,
                  content: Text(
                    'Profile onboarding completed successfully!',
                    style: TextStyle(color: colorScheme.onPrimary),
                  ),
                ),
              );
            }
          : null,
      onBackPressed: _previousPage,
    );
  }

  Widget _buildMilestoneCard({
    required ColorScheme colorScheme,
    required ThemeData theme,
    required String title,
    required String subtitle,
    required GlobalKey<FormState> formKey,
    required VoidCallback onChanged,
    required Widget field,
    required String explanatoryContext,
    required String buttonLabel,
    required bool isNextEnabled,
    required VoidCallback? onNextPressed,
    VoidCallback? onBackPressed,
  }) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Form(
        key: formKey,
        onChanged: onChanged,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6.0),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24.0),

            // High-Contrast Input Field
            field,

            const SizedBox(height: 12.0),

            // Explanatory Context
            Text(
              explanatoryContext,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),

            const Spacer(),

            // Actions Row
            Row(
              children: [
                if (onBackPressed != null) ...[
                  OutlinedButton(
                    onPressed: onBackPressed,
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    child: const Text('Back'),
                  ),
                  const SizedBox(width: 12.0),
                ],
                Expanded(
                  child: SizedBox(
                    height: 48.0,
                    child: FilledButton(
                      onPressed: isNextEnabled ? onNextPressed : null,
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      child: Text(
                        buttonLabel,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
