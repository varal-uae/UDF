// BPTR-0773-A05 — Permanent Sidebar Profile Controls.
// Pins account/profile actions at the sidebar footer, truncates long labels, and falls back to a mobile profile sheet.

import 'package:flutter/material.dart';

class SidebarProfileAction {
  const SidebarProfileAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.semanticLabel,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final String? semanticLabel;
}

class PermanentSidebarProfileControls extends StatelessWidget {
  const PermanentSidebarProfileControls({
    super.key,
    required this.actions,
    this.userName,
    this.userEmail,
    this.onProfileTap,
    this.sidebarWidth = 280,
  });

  final List<SidebarProfileAction> actions;
  final String? userName;
  final String? userEmail;
  final VoidCallback? onProfileTap;
  final double sidebarWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        if (isMobile) {
          return _MobileProfileSheetTrigger(
            userName: userName,
            userEmail: userEmail,
            actions: actions,
            onProfileTap: onProfileTap,
          );
        }

        return SizedBox(
          width: sidebarWidth,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Divider(height: 1),
              _ProfileHeader(
                userName: userName,
                userEmail: userEmail,
                onTap: onProfileTap,
              ),
              for (final action in actions)
                _SidebarActionTile(action: action),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.userName,
    required this.userEmail,
    required this.onTap,
  });

  final String? userName;
  final String? userEmail;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayName = userName?.trim().isNotEmpty == true ? userName! : 'Profile';
    final displayEmail = userEmail?.trim().isNotEmpty == true ? userEmail! : 'Account settings';

    return Semantics(
      button: onTap != null,
      label: 'Profile and account controls',
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Icon(
                  Icons.person_outline,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      displayEmail,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SidebarActionTile extends StatelessWidget {
  const _SidebarActionTile({required this.action});

  final SidebarProfileAction action;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 48),
      child: Semantics(
        button: true,
        label: action.semanticLabel ?? action.label,
        child: ListTile(
          leading: Icon(action.icon),
          title: Text(
            action.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          onTap: action.onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        ),
      ),
    );
  }
}

class _MobileProfileSheetTrigger extends StatelessWidget {
  const _MobileProfileSheetTrigger({
    required this.userName,
    required this.userEmail,
    required this.actions,
    required this.onProfileTap,
  });

  final String? userName;
  final String? userEmail;
  final List<SidebarProfileAction> actions;
  final VoidCallback? onProfileTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: FloatingActionButton.small(
          tooltip: 'Profile and account controls',
          onPressed: () => _showProfileSheet(context),
          child: const Icon(Icons.account_circle_outlined),
        ),
      ),
    );
  }

  void _showProfileSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        final displayName = userName?.trim().isNotEmpty == true ? userName! : 'Profile';
        final displayEmail = userEmail?.trim().isNotEmpty == true ? userEmail! : 'Account settings';

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Icon(
                    Icons.person_outline,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                title: Text(
                  displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  displayEmail,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: onProfileTap == null
                    ? null
                    : () {
                        Navigator.of(sheetContext).pop();
                        onProfileTap!.call();
                      },
              ),
              const Divider(height: 1),
              for (final action in actions)
                ListTile(
                  leading: Icon(action.icon),
                  title: Text(
                    action.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    action.onTap();
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}
