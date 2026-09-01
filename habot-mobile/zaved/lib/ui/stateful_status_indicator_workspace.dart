// ============================================================================
// TELEMETRY METADATA BLOCK
// Color Code (HEX/RGB): MD3 Dynamic (#B3261E / RGB(179,38,30) - Error, #21005D / RGB(33,0,93) - Primary)
// Color Name: MD3 System Tokens (errorContainer, onErrorContainer, primaryContainer, onPrimaryContainer)
// Color Scheme: Material 3 Dynamic (Light & Dark Adaptive)
// Contrast Ratio: WCAG AAA Compliant (>= 7.0:1)
// Color Application Map: {Idle: surfaceContainerHighest, Processing: surfaceContainerLow @ 0.38 Opacity, Success: primaryContainer/onPrimaryContainer, Error: errorContainer/onErrorContainer}
// Completion Status: Pass - Data/Field Mapping Accuracy Rate
// ============================================================================

import 'package:flutter/material.dart';
import 'stateful_status_indicator.dart';

/// Interactive demonstration workspace for BPTR-0144-A07: StatefulStatusIndicator
class StatefulStatusIndicatorWorkspace extends StatefulWidget {
  const StatefulStatusIndicatorWorkspace({super.key});

  @override
  State<StatefulStatusIndicatorWorkspace> createState() =>
      _StatefulStatusIndicatorWorkspaceState();
}

class _StatefulStatusIndicatorWorkspaceState
    extends State<StatefulStatusIndicatorWorkspace> {
  StatusIndicatorState _state = StatusIndicatorState.idle;
  final TextEditingController _leadNameController =
      TextEditingController(text: 'Enterprise Cloud Deployment Lead');
  final TextEditingController _emailController =
      TextEditingController(text: 'lead@enterprise.org');

  @override
  void dispose() {
    _leadNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _triggerAsyncSubmission(bool shouldFail) {
    setState(() {
      _state = StatusIndicatorState.processing;
    });

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() {
          _state = shouldFail
              ? StatusIndicatorState.error
              : StatusIndicatorState.success;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600.0),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
            side: BorderSide(color: colorScheme.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: colorScheme.primaryContainer,
                      foregroundColor: colorScheme.onPrimaryContainer,
                      child: const Icon(Icons.sync_alt_rounded),
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Async Lead Generation Form',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Micro-UX 38% Opacity & MD3 Inline State Indicators',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 32.0),

                // Interactive StatefulStatusIndicator Wrapper
                StatefulStatusIndicator(
                  state: _state,
                  successMessage:
                      'Lead captured successfully! Ingested into Pub/Sub queue.',
                  errorMessage:
                      'Network timeout (Cloud Run 504). Please retry.',
                  onRetry: () => _triggerAsyncSubmission(false),
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(color: colorScheme.outlineVariant),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: _leadNameController,
                          decoration: const InputDecoration(
                            labelText: 'Opportunity Title',
                            prefixIcon: Icon(Icons.business_center_outlined),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        TextField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Contact Email',
                            prefixIcon: Icon(Icons.email_outlined),
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24.0),

                // State Control Buttons
                Text(
                  'Simulation Controls:',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8.0),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: [
                    FilledButton.tonalIcon(
                      onPressed: () => setState(() => _state = StatusIndicatorState.idle),
                      icon: const Icon(Icons.refresh, size: 16.0),
                      label: const Text('Reset (Idle)'),
                    ),
                    FilledButton.icon(
                      onPressed: () => _triggerAsyncSubmission(false),
                      icon: const Icon(Icons.send_rounded, size: 16.0),
                      label: const Text('Submit (Success Flow)'),
                    ),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: colorScheme.error,
                        foregroundColor: colorScheme.onError,
                      ),
                      onPressed: () => _triggerAsyncSubmission(true),
                      icon: const Icon(Icons.error_outline, size: 16.0),
                      label: const Text('Submit (Error Flow)'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
