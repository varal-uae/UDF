// RRCVG-017-07 — Mobile OS Version Deprecation Gates.
// Design blocking screen overlays to display across outdated user clients using full-screen Material 3 dialogs, semantic feedback colors, and responsive accordion lists.

import 'package:flutter/material.dart';

/// Mock data model for lock state
enum LockType { osDeprecation, maintenance, security }

enum CompletionStatus { good, average, poor }

class OsDeprecationLockState {
  final LockType lockType;
  final bool isLocked;
  final String lockedBy;
  final DateTime lockTimestamp;
  final String lockReason;
  final CompletionStatus completionStatus;
  final String sessionId;

  const OsDeprecationLockState({
    required this.lockType,
    required this.isLocked,
    required this.lockedBy,
    required this.lockTimestamp,
    required this.lockReason,
    required this.completionStatus,
    required this.sessionId,
  });
}

/// Mock repository providing local dummy data
class MockDeprecationRepository {
  static OsDeprecationLockState getMockLockState() {
    return OsDeprecationLockState(
      lockType: LockType.osDeprecation,
      isLocked: true,
      lockedBy: 'SystemPolicyEngine',
      lockTimestamp: DateTime(2026, 9, 24, 10, 30),
      lockReason:
          'Your mobile operating system version is no longer supported. Please update your device OS to continue using the application securely.',
      completionStatus: CompletionStatus.good,
      sessionId: 'sess_mock_9999_017_07',
    );
  }
}

/// Full-screen blocking overlay widget for OS deprecation gates
class OsDeprecationGateOverlay extends StatelessWidget {
  final OsDeprecationLockState lockState;
  final VoidCallback? onDismissAttempt;

  const OsDeprecationGateOverlay({
    super.key,
    required this.lockState,
    this.onDismissAttempt,
  });

  Color _getSemanticFeedbackColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (lockState.completionStatus) {
      case CompletionStatus.good:
        return colorScheme.primary;
      case CompletionStatus.average:
        return colorScheme.tertiary;
      case CompletionStatus.poor:
        return colorScheme.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final semanticColor = _getSemanticFeedbackColor(context);
    final isNarrow = MediaQuery.of(context).size.width < 600;

    return Material(
      color: colorScheme.surface.withOpacity(0.98),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isNarrow ? 16.0 : 64.0,
            vertical: 24.0,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.system_security_update_warning_rounded,
                size: isNarrow ? 80 : 120,
                color: semanticColor,
              ),
              const SizedBox(height: 32),
              Text(
                'Update Required',
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: semanticColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: colorScheme.outlineVariant),
                  borderRadius: BorderRadius.circular(12),
                  color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                ),
                child: Text(
                  lockState.lockReason,
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 32),
              // High-density validation table compressed into structured accordion list
              _buildAccordionDetails(context, isNarrow),
              const SizedBox(height: 48),
              FilledButton.icon(
                onPressed: onDismissAttempt ?? () {},
                icon: const Icon(Icons.open_in_browser),
                label: const Text('Learn How to Update'),
                style: FilledButton.styleFrom(
                  backgroundColor: semanticColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccordionDetails(BuildContext context, bool isNarrow) {
    final details = [
      {'label': 'Lock Type', 'value': lockState.lockType.name.toUpperCase()},
      {'label': 'Lock Status', 'value': lockState.isLocked ? 'ACTIVE' : 'INACTIVE'},
      {'label': 'Locked By', 'value': lockState.lockedBy},
      {
        'label': 'Lock Timestamp',
        'value': '${lockState.lockTimestamp.year}-${lockState.lockTimestamp.month.toString().padLeft(2, '0')}-${lockState.lockTimestamp.day.toString().padLeft(2, '0')} ${lockState.lockTimestamp.hour}:${lockState.lockTimestamp.minute.toString().padLeft(2, '0')}'
      },
      {'label': 'Session ID', 'value': lockState.sessionId},
      {'label': 'Quality Score', 'value': lockState.completionStatus.name.toUpperCase()},
    ];

    if (isNarrow) {
      // Accordion list for narrow phone formats
      return Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: const Text('Technical Details'),
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
            borderRadius: BorderRadius.circular(8),
          ),
          collapsedShape: RoundedRectangleBorder(
            side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
            borderRadius: BorderRadius.circular(8),
          ),
          children: details.map((detail) {
            return ListTile(
              dense: true,
              visualDensity: VisualDensity.compact,
              title: Text(detail['label']!, style: Theme.of(context).textTheme.labelMedium),
              trailing: Text(detail['value']!, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
            );
          }).toList(),
        ),
      );
    } else {
      // Validation table for wide monitor frames
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Table(
          columnWidths: const {
            0: FlexColumnWidth(1),
            1: FlexColumnWidth(2),
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: details.map((detail) {
            return TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(detail['label']!, style: Theme.of(context).textTheme.labelLarge),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(detail['value']!, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500)),
                ),
              ],
            );
          }).toList(),
        ),
      );
    }
  }
}

/// Helper function to show the deprecation gate as a full-screen dialog
Future<void> showOsDeprecationGateDialog(BuildContext context) async {
  final mockState = MockDeprecationRepository.getMockLockState();
  
  if (!mockState.isLocked) return;

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog.fullscreen(
        backgroundColor: Colors.transparent,
        child: OsDeprecationGateOverlay(
          lockState: mockState,
          onDismissAttempt: () {
            // Blocked action - cannot dismiss without updating OS
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Action blocked: OS update required to proceed.'),
                behavior: SnackBarBehavior.floating,
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          },
        ),
      );
    },
  );
}