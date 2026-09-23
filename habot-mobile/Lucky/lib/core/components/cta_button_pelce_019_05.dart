// PELCE-019-05 — CTAButton with ApprovedCTAVerbs enumeration and Material 3 styling.
// Restricts all mobile buttons to strict machine-action verbs using an enum, applies full-width layout, border-radius 100px, Roboto Mono font, syntax highlighting colors for system verbs, and secondary container background.

import 'package:flutter/material.dart';

/// Approved system verbs for mobile CTAs (English Code System Verbs).
enum ApprovedCTAVerbs {
  submit('SUBMIT'),
  confirm('CONFIRM'),
  cancel('CANCEL'),
  save('SAVE'),
  delete('DELETE'),
  execute('EXECUTE'),
  approve('APPROVE'),
  reject('REJECT'),
  sync('SYNC'),
  upload('UPLOAD');

  const ApprovedCTAVerbs(this.label);
  final String label;
}

/// Mock telemetry data structure as per requirement atomic-level data fields.
class StepExecutionTelemetry {
  final String stepExecutionId;
  final String executionStatus;
  final DateTime executionTimestamp;
  final String stepOutcome;
  final String userId;

  const StepExecutionTelemetry({
    required this.stepExecutionId,
    required this.executionStatus,
    required this.executionTimestamp,
    required this.stepOutcome,
    required this.userId,
  });

  Map<String, dynamic> toJson() => {
        'Step Execution ID': stepExecutionId,
        'Execution Status': executionStatus,
        'Execution Timestamp': executionTimestamp.toIso8601String(),
        'Step Outcome': stepOutcome,
        'User ID': userId,
      };
}

/// A Material 3 Filled Button component restricted to [ApprovedCTAVerbs].
/// Enforces full width, 100px border radius, Roboto Mono font, and semantic contrast.
class CTAButton extends StatelessWidget {
  final ApprovedCTAVerbs verb;
  final VoidCallback onPressed;
  final bool isEnabled;

  const CTAButton({
    super.key,
    required this.verb,
    required this.onPressed,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    // Syntax highlighting color mapping for system verbs
    Color getVerbColor(ApprovedCTAVerbs v) {
      switch (v) {
        case ApprovedCTAVerbs.submit:
        case ApprovedCTAVerbs.execute:
          return const Color(0xFF569CD6); // Blue
        case ApprovedCTAVerbs.confirm:
        case ApprovedCTAVerbs.approve:
        case ApprovedCTAVerbs.save:
          return const Color(0xFF4EC9B0); // Teal
        case ApprovedCTAVerbs.cancel:
        case ApprovedCTAVerbs.reject:
          return const Color(0xFFD7BA7D); // Yellow
        case ApprovedCTAVerbs.delete:
          return const Color(0xFFF44747); // Red
        case ApprovedCTAVerbs.sync:
        case ApprovedCTAVerbs.upload:
          return const Color(0xFFC586C0); // Purple
      }
    }

    final Color verbColor = getVerbColor(verb);

    return SizedBox(
      width: double.infinity, // width: 100%
      child: FilledButton(
        onPressed: isEnabled ? () {
          // Automated validation & telemetry logging mock
          final telemetry = StepExecutionTelemetry(
            stepExecutionId: 'STEP-${verb.name.toUpperCase()}-${DateTime.now().millisecondsSinceEpoch}',
            executionStatus: 'Triggered',
            executionTimestamp: DateTime.now(),
            stepOutcome: 'Pending',
            userId: 'MOCK_USER_001',
          );
          debugPrint('Telemetry Captured: ${telemetry.toJson()}');
          onPressed();
        } : null,
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.secondaryContainer, // Secondary container for background
          foregroundColor: verbColor, // Syntax highlighting for system verbs
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100), // border-radius: 100px
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(
            fontFamily: 'RobotoMono', // Font: Roboto Mono
            fontWeight: FontWeight.w600,
            fontSize: 14,
            letterSpacing: 1.2,
          ),
        ),
        child: Text(verb.label),
      ),
    );
  }
}

/// Preview widget demonstrating the expandable logic blocks card constraint.
class CTAButtonPreviewCard extends StatelessWidget {
  const CTAButtonPreviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        title: const Text(
          'System Actions',
          style: TextStyle(fontFamily: 'RobotoMono'),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: ApprovedCTAVerbs.values.map((verb) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: CTAButton(
                    verb: verb,
                    onPressed: () {},
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}