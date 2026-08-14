import 'package:flutter/material.dart';

import 'step_up_mfa_prompt.dart';
import 'step_up_verifier.dart';

// BDAE-008-A01 — High-risk action registry & guard.
// Tags critical operations that require step-up MFA before execution.

/// Known high-risk action paths across the application.
enum HighRiskAction {
  massExport('Mass export', 'Export large volumes of data'),
  deepDeletion('Deep deletion', 'Permanently delete records'),
  securitySettings('Security settings', 'Change authentication or access rules'),
  bulkUpdate('Bulk update', 'Modify many records at once'),
  adminOverride('Admin override', 'Bypass standard approval workflow'),
  dataTransfer('Data transfer', 'Move data across jurisdictions');

  const HighRiskAction(this.title, this.description);

  final String title;
  final String description;

  /// Server-side action key sent with verification requests.
  String get actionKey => name;

  IconData get warningIcon {
    switch (this) {
      case HighRiskAction.massExport:
        return Icons.file_download_outlined;
      case HighRiskAction.deepDeletion:
        return Icons.delete_forever_outlined;
      case HighRiskAction.securitySettings:
        return Icons.admin_panel_settings_outlined;
      case HighRiskAction.bulkUpdate:
        return Icons.edit_note_outlined;
      case HighRiskAction.adminOverride:
        return Icons.gpp_maybe_outlined;
      case HighRiskAction.dataTransfer:
        return Icons.swap_horiz_outlined;
    }
  }
}

/// Runs [onApproved] only after the user passes [StepUpMFAPrompt].
abstract class HighRiskActionGuard {
  /// Returns the task result, or null if the user cancelled or failed verification.
  static Future<T?> run<T>({
    required BuildContext context,
    required HighRiskAction action,
    required Future<T> Function(StepUpApprovalToken token) onApproved,
  }) async {
    final token = await StepUpMFAPrompt.show(context, action: action);
    if (token == null || !context.mounted) return null;
    return onApproved(token);
  }
}

/// Critical-action button with a distinct warning icon.
/// Pauses the workflow and opens [StepUpMFAPrompt] before [onConfirmed] fires.
class HighRiskActionButton extends StatelessWidget {
  const HighRiskActionButton({
    super.key,
    required this.action,
    required this.label,
    required this.onConfirmed,
    this.icon,
    this.isLoading = false,
  });

  final HighRiskAction action;
  final String label;
  final ValueChanged<StepUpApprovalToken> onConfirmed;
  final IconData? icon;
  final bool isLoading;

  Future<void> _handlePress(BuildContext context) async {
    final token = await StepUpMFAPrompt.show(context, action: action);
    if (token != null && context.mounted) {
      onConfirmed(token);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FilledButton.tonalIcon(
      onPressed: isLoading ? null : () => _handlePress(context),
      icon: Icon(icon ?? action.warningIcon, size: 20),
      label: Text(label),
      style: FilledButton.styleFrom(
        foregroundColor: theme.colorScheme.error,
        minimumSize: const Size(0, 48),
      ),
    );
  }
}
