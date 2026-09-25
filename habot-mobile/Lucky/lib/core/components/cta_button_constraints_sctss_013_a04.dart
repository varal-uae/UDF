// SCTSS-013-A04 — CTA Button Character Limit Constraints.
// Enforces a maximum character count (default 15) for call-to-action buttons to maintain layout integrity on mobile screens, with auto-truncation and visual warning indicators.

import 'package:flutter/material.dart';

/// Maximum allowed characters for CTA button text to prevent layout breaks.
const int kCtaButtonMaxCharacterLimit = 15;

/// A constraint-enforced CTA button that automatically truncates text
/// exceeding the defined character limit and provides a visual warning
/// (pulsing outline) when limits are breached during development/debugging.
class ConstrainedCtaButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final int maxCharacters;
  final bool enableWarningPulse;

  const ConstrainedCtaButton({
    super.key,
    required this.label,
    this.onPressed,
    this.maxCharacters = kCtaButtonMaxCharacterLimit,
    this.enableWarningPulse = true,
  });

  @override
  State<ConstrainedCtaButton> createState() => _ConstrainedCtaButtonState();
}

class _ConstrainedCtaButtonState extends State<ConstrainedCtaButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  bool get _exceedsLimit => widget.label.length > widget.maxCharacters;

  String get _displayLabel {
    if (_exceedsLimit) {
      return '${widget.label.substring(0, widget.maxCharacters - 2)}…';
    }
    return widget.label;
  }

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (_exceedsLimit && widget.enableWarningPulse) {
      _pulseController.repeat(reverse: true);
      debugPrint(
        '[SCTSS-013-A04] WARNING: CTA label "${widget.label}" exceeds '
        '${widget.maxCharacters} character limit. Auto-truncated.',
      );
    }
  }

  @override
  void didUpdateWidget(covariant ConstrainedCtaButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_exceedsLimit && widget.enableWarningPulse) {
      if (!_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      }
    } else {
      if (_pulseController.isAnimating) {
        _pulseController.stop();
        _pulseController.reset();
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final Widget buttonContent = FilledButton(
      onPressed: widget.onPressed,
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 48), // Material 3 touch target compliance
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: theme.textTheme.labelLarge?.copyWith(
          overflow: TextOverflow.ellipsis,
        ),
      ),
      child: Text(
        _displayLabel,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );

    if (_exceedsLimit && widget.enableWarningPulse) {
      return AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.red.withOpacity(_pulseAnimation.value),
                width: 2.0 + (_pulseAnimation.value * 2.0),
              ),
            ),
            child: child,
          );
        },
        child: buttonContent,
      );
    }

    return buttonContent;
  }
}

/// Utility class for validating CTA constraints across the system.
class CtaConstraintValidator {
  const CtaConstraintValidator._();

  /// Returns true if the text complies with the character limit.
  static bool isCompliant(String text, {int maxCharacters = kCtaButtonMaxCharacterLimit}) {
    return text.length <= maxCharacters;
  }

  /// Truncates text to fit within the limit, appending an ellipsis if needed.
  static String enforce(String text, {int maxCharacters = kCtaButtonMaxCharacterLimit}) {
    if (text.length <= maxCharacters) return text;
    return '${text.substring(0, maxCharacters - 2)}…';
  }

  /// Calculates compliance percentage for a list of CTA labels.
  static double calculateComplianceRate(List<String> labels, {int maxCharacters = kCtaButtonMaxCharacterLimit}) {
    if (labels.isEmpty) return 1.0;
    final compliantCount = labels.where((l) => isCompliant(l, maxCharacters: maxCharacters)).length;
    return compliantCount / labels.length;
  }
}

/// Mock data for testing CTA constraint compliance metrics.
class MockCtaData {
  static const List<Map<String, dynamic>> sampleButtons = [
    {'id': 'cta_001', 'label': 'Submit', 'compliant': true},
    {'id': 'cta_002', 'label': 'Cancel', 'compliant': true},
    {'id': 'cta_003', 'label': 'Continue to Payment Gateway', 'compliant': false},
    {'id': 'cta_004', 'label': 'Save Changes', 'compliant': true},
    {'id': 'cta_005', 'label': 'Acknowledge and Proceed Forward', 'compliant': false},
  ];

  static const Map<String, dynamic> mockExecutionRecord = {
    'step_execution_id': 'EXEC-SCTSS-013-A04-001',
    'execution_status': 'COMPLETED',
    'execution_timestamp': '2026-09-25T08:00:00.000Z',
    'step_outcome': 'PASS',
    'user_id': 'USR_MOCK_001',
    'completion_status': 'Pass',
    'action_timestamp': '2026-09-25T08:00:05.000Z',
    'session_id': 'SESS_MOCK_999',
    'compliance_rate': 0.6,
  };
}
