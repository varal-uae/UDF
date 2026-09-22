// MUFCE-004-A12 — Additional Information Required Form (AIF) Renderer with Fluid Onboarding Animations.
// Implements a dynamic multi-step onboarding form with sliding page animations, keyboard-aware layouts, high-contrast borders, progress tracking, and Poka-Yoke submission locking.

import 'package:flutter/material.dart';

/// Mock data representing atomic-level AIF fields for the onboarding journey.
class _MockAifField {
  final String id;
  final String label;
  final String hint;
  final TextInputType keyboardType;
  final bool isRequired;

  const _MockAifField({
    required this.id,
    required this.label,
    required this.hint,
    required this.keyboardType,
    this.isRequired = true,
  });
}

/// Mock milestones grouping the AIF fields into single-data-milestone viewports.
final List<List<_MockAifField>> _mockMilestones = [
  [
    const _MockAifField(
      id: 'step_exec_id',
      label: 'Step Execution ID',
      hint: 'Enter your unique execution identifier',
      keyboardType: TextInputType.text,
    ),
    const _MockAifField(
      id: 'user_id',
      label: 'User ID',
      hint: 'Enter your registered User ID',
      keyboardType: TextInputType.text,
    ),
  ],
  [
    const _MockAifField(
      id: 'exec_status',
      label: 'Execution Status',
      hint: 'Current status of the execution step',
      keyboardType: TextInputType.text,
    ),
    const _MockAifField(
      id: 'exec_timestamp',
      label: 'Execution Timestamp',
      hint: 'YYYY-MM-DD HH:mm:ss',
      keyboardType: TextInputType.datetime,
    ),
  ],
  [
    const _MockAifField(
      id: 'step_outcome',
      label: 'Step Outcome',
      hint: 'Describe the outcome of this step',
      keyboardType: TextInputType.multiline,
    ),
  ],
];

/// Core Additional Information Required Form (AIF) field renderer.
/// Replaces /ui/forms/aif_renderer.py with a Flutter production implementation.
class AifRendererMufce004A12 extends StatefulWidget {
  final VoidCallback? onComplete;

  const AifRendererMufce004A12({super.key, this.onComplete});

  @override
  State<AifRendererMufce004A12> createState() => _AifRendererMufce004A12State();
}

class _AifRendererMufce004A12State extends State<AifRendererMufce004A12>
    with TickerProviderStateMixin {
  late final PageController _pageController;
  late final AnimationController _slideAnimationController;
  late final Animation<Offset> _slideAnimation;

  int _currentMilestone = 0;
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, bool> _fieldValidity = {};

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // Fluid sliding page animations between onboarding milestone views
    _slideAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.05, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideAnimationController,
      curve: Curves.easeOutCubic,
    ));

    // Initialize controllers and validity trackers for mock data
    for (final milestone in _mockMilestones) {
      for (final field in milestone) {
        _controllers[field.id] = TextEditingController();
        _fieldValidity[field.id] = false;
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _slideAnimationController.dispose();
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  bool get _isCurrentMilestoneValid {
    final currentFields = _mockMilestones[_currentMilestone];
    return currentFields.every((f) => !f.isRequired || (_fieldValidity[f.id] ?? false));
  }

  bool get _areAllFieldsPopulated {
    return _mockMilestones
        .expand((m) => m)
        .every((f) => !f.isRequired || (_fieldValidity[f.id] ?? false));
  }

  void _onFieldChanged(String fieldId, String value, bool isRequired) {
    setState(() {
      _fieldValidity[fieldId] = isRequired ? value.trim().isNotEmpty : true;
    });
  }

  void _goToNextMilestone() {
    if (_currentMilestone < _mockMilestones.length - 1) {
      setState(() => _currentMilestone++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      _slideAnimationController.forward(from: 0.0);
    }
  }

  void _goToPreviousMilestone() {
    if (_currentMilestone > 0) {
      setState(() => _currentMilestone--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      _slideAnimationController.forward(from: 0.0);
    }
  }

  void _submitForm() {
    if (!_areAllFieldsPopulated) return;

    // Mock payload sync to BigQuery query schemas
    final Map<String, dynamic> payload = {
      'step_execution_id': _controllers['step_exec_id']?.text,
      'execution_status': _controllers['exec_status']?.text,
      'execution_timestamp': _controllers['exec_timestamp']?.text,
      'step_outcome': _controllers['step_outcome']?.text,
      'user_id': _controllers['user_id']?.text,
      'completion_status': 'Complete',
      'action_timestamp': DateTime.now().toIso8601String(),
    };

    debugPrint('AIF Payload Ready for BigQuery Sync: $payload');
    widget.onComplete?.call();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile readiness complete. Data synced.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final progress = (_currentMilestone + 1) / _mockMilestones.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Client Registration Profile'),
        actions: [
          // Clean interactive progress wheels tracking profile readiness
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 3.0,
                backgroundColor: colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(), // Restrict layout to single data milestones per viewport canvas
                itemCount: _mockMilestones.length,
                itemBuilder: (context, index) {
                  return SlideTransition(
                    position: index == _currentMilestone ? _slideAnimation : const AlwaysStoppedAnimation(Offset.zero),
                    child: _buildMilestonePage(
                      context,
                      _mockMilestones[index],
                      index,
                    ),
                  );
                },
              ),
            ),
            _buildBottomNavigation(context),
          ],
        ),
      ),
    );
  }

  Widget _buildMilestonePage(
    BuildContext context,
    List<_MockAifField> fields,
    int pageIndex,
  ) {
    // Transition input field box margins dynamically to fit software soft keyboard displays
    return KeyboardAvoidingWrapper(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Milestone ${pageIndex + 1} of ${_mockMilestones.length}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700, // Precise typographical weight guidelines
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Clear contextual guidelines detailing exactly why each input is required.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 24),
            ...fields.map((field) => _buildInputBlock(context, field)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBlock(BuildContext context, _MockAifField field) {
    final isValid = _fieldValidity[field.id] ?? false;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Style text input labels with precise typographical weight guidelines
          Text(
            field.label,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          // Style entry blocks using high-contrast outer borders & explicit layout borders
          TextField(
            controller: _controllers[field.id],
            keyboardType: field.keyboardType,
            maxLines: field.keyboardType == TextInputType.multiline ? 3 : 1,
            onChanged: (val) => _onFieldChanged(field.id, val, field.isRequired),
            decoration: InputDecoration(
              hintText: field.hint,
              filled: true,
              fillColor: theme.colorScheme.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(
                  color: theme.colorScheme.outline,
                  width: 2.0, // High-contrast outer borders
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(
                  color: theme.colorScheme.outline,
                  width: 2.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(
                  color: theme.colorScheme.primary,
                  width: 2.5,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(
                  color: theme.colorScheme.error,
                  width: 2.0,
                ),
              ),
              // Route verification symbols to high-contrast accents perfectly
              suffixIcon: field.isRequired && _controllers[field.id]!.text.isNotEmpty
                  ? Icon(
                      isValid ? Icons.check_circle_rounded : Icons.error_outline_rounded,
                      color: isValid ? Colors.greenAccent[700] : theme.colorScheme.error,
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation(BuildContext context) {
    final theme = Theme.of(context);
    final isLastPage = _currentMilestone == _mockMilestones.length - 1;

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(color: theme.colorScheme.outlineVariant, width: 1.0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentMilestone > 0)
            OutlinedButton.icon(
              onPressed: _goToPreviousMilestone,
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back'),
            )
          else
            const SizedBox.shrink(),
          
          // Poka-Yoke: Lock final submittal parameters until users populate all required AIF variables
          ElevatedButton.icon(
            onPressed: isLastPage
                ? (_areAllFieldsPopulated ? _submitForm : null)
                : (_isCurrentMilestoneValid ? _goToNextMilestone : null),
            icon: Icon(isLastPage ? Icons.check : Icons.arrow_forward),
            label: Text(isLastPage ? 'Submit Profile' : 'Next Milestone'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}

/// Wrapper to handle keyboard avoidance gracefully on mobile viewports.
class KeyboardAvoidingWrapper extends StatelessWidget {
  final Widget child;
  const KeyboardAvoidingWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // Wrap array rows to multiple lines neatly if device screen limits contract past parameters
    return AnimatedPadding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      duration: const Duration(milliseconds: 200),
      curve: Curves.decelerate,
      child: child,
    );
  }
}

/// Automated mobile notification chips for incomplete profile runs (Self-Chasing).
class IncompleteProfileNotificationChip extends StatelessWidget {
  final int remainingBlocks;
  final VoidCallback onTap;

  const IncompleteProfileNotificationChip({
    super.key,
    required this.remainingBlocks,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (remainingBlocks <= 0) return const SizedBox.shrink();

    return ActionChip(
      avatar: const Icon(Icons.info_outline, color: Colors.orangeAccent, size: 18),
      label: Text('Complete $remainingBlocks remaining block(s)'),
      onPressed: onTap,
      backgroundColor: Colors.orange.withOpacity(0.1),
      side: const BorderSide(color: Colors.orangeAccent, width: 1.5),
    );
  }
}
