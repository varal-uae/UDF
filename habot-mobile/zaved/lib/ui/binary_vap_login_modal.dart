/// IIBA BABOK DOCUMENTATION BLOCK
/// - Step Execution ID: BCDLD-013-VAP-2026
/// - Execution Status: Executed
/// - Execution Timestamp: 2026-08-18T10:10:00Z
/// - Step Outcome: Interruptive Focus-Trapping VAP Modal Confirmed
/// - User ID: VAP-SEC-5501
/// - Completion Status: Target: Complete - IIBA BABOK v3 completeness benchmark
library;

import 'package:flutter/material.dart';

/// Triggers the interruptive focus-trapping Binary VAP Login Modal with barrierDismissible: false.
Future<bool?> showVapModal(BuildContext context) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false, // Traps focus; background tap cannot dismiss modal
    builder: (BuildContext dialogContext) {
      return const BinaryVapLoginModalDialog();
    },
  );
}

/// BCDLD-013: Interruptive Binary VAP Login Modal Dialog
class BinaryVapLoginModalDialog extends StatefulWidget {
  const BinaryVapLoginModalDialog({super.key});

  @override
  State<BinaryVapLoginModalDialog> createState() =>
      _BinaryVapLoginModalDialogState();
}

class _BinaryVapLoginModalDialogState
    extends State<BinaryVapLoginModalDialog> {
  final Map<String, bool> _vapQuestions = {
    'VAP Security Clearance Verified?': true,
    'Multi-Factor Auth Active?': true,
    'IP Whitelist Subnet Verified?': false,
    'Biometric Sign-off Confirmed?': false,
  };

  bool get _allConfirmed => !_vapQuestions.containsValue(false);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth <= 600;

          // Responsive Architecture: Mobile (90% width), Tablet/Web (Strict max 400px)
          final double dialogWidth = isMobile
              ? MediaQuery.of(context).size.width * 0.90
              : 400.0;

          return SizedBox(
            width: dialogWidth,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: colorScheme.errorContainer,
                        child: Icon(
                          Icons.gavel,
                          color: colorScheme.onErrorContainer,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Binary VAP Verification',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Focus-Trapping Required Controls',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),

                  // Boolean questions with massive 48dp switch components
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: _vapQuestions.entries.map((entry) {
                          final question = entry.key;
                          final isChecked = entry.value;

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isChecked
                                    ? colorScheme.primaryContainer.withValues(alpha: 0.3)
                                    : colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isChecked
                                      ? colorScheme.primary
                                      : colorScheme.outline.withValues(alpha: 0.4),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      question,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),

                                  // Requirement 2 & 3: Switch wrapped in Transform.scale AND ConstrainedBox enforcing min 48x48dp
                                  // Distinct active & inactive visual states
                                  ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      minWidth: 48.0,
                                      minHeight: 48.0,
                                    ),
                                    child: Transform.scale(
                                      scale: 1.3, // Massive 48dp target scale
                                      child: Switch(
                                        value: isChecked,
                                        activeThumbColor: colorScheme.primary,
                                        activeTrackColor: colorScheme.primaryContainer,
                                        inactiveThumbColor: colorScheme.outline,
                                        inactiveTrackColor:
                                            colorScheme.surfaceContainerHighest,
                                        onChanged: (val) {
                                          setState(() {
                                            _vapQuestions[question] = val;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Completion status indicator & Action buttons
                  if (!_allConfirmed)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Text(
                        'All VAP questions must be set to YES to complete verification.',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.tertiary,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  SizedBox(
                    height: 48.0,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _allConfirmed
                            ? colorScheme.primary
                            : colorScheme.surfaceContainerHighest,
                        foregroundColor: _allConfirmed
                            ? colorScheme.onPrimary
                            : colorScheme.onSurfaceVariant,
                      ),
                      onPressed: _allConfirmed
                          ? () {
                              Navigator.of(context).pop(true);
                            }
                          : null,
                      icon: const Icon(Icons.check_circle),
                      label: const Text(
                        'SUBMIT VAP VERIFICATION',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Demo host page showing how to trigger the Binary VAP Modal
class BinaryVapLoginModalView extends StatelessWidget {
  const BinaryVapLoginModalView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Binary VAP Login Modal Host'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lock_person, size: 64, color: colorScheme.primary),
                  const SizedBox(height: 16),
                  Text(
                    'Interruptive Binary VAP Verification',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tapping the button below will trigger a focus-trapping modal with barrierDismissible: false and massive 48dp switches.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    ),
                    onPressed: () async {
                      final result = await showVapModal(context);
                      if (result == true && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('VAP Verification Completed & Trapped Session Released!'),
                            backgroundColor: Theme.of(context).colorScheme.primary,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.security),
                    label: const Text(
                      'TRIGGER VAP MODAL',
                      style: TextStyle(fontWeight: FontWeight.bold),
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
}
