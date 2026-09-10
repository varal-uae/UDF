// BPTR-0773-A07 — Pinned Sidebar Drawer Account Row.
// Renders the active user avatar, full username, and account role as a
// lower-tier sidebar control with truncation, Material 3 tokens, and semantics.
import 'package:flutter/material.dart';

class SidebarDrawerAccountRowBPTR0773A07 extends StatelessWidget {
  const SidebarDrawerAccountRowBPTR0773A07({
    super.key,
    required this.username,
    required this.role,
    this.avatarUrl,
    this.onTap,
    this.onSettingsPressed,
    this.backgroundColor,
    this.foregroundColor,
  });

  final String username;
  final String role;
  final String? avatarUrl;
  final VoidCallback? onTap;
  final VoidCallback? onSettingsPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color effectiveBackground = backgroundColor ??
        theme.navigationDrawerTheme.backgroundColor ??
        theme.colorScheme.surface;
    final Color effectiveForeground = foregroundColor ?? theme.colorScheme.onSurface;
    final Color mutedForeground = effectiveForeground.withOpacity(0.72);

    return Material(
      color: effectiveBackground,
      child: SafeArea(
        top: false,
        child: Semantics(
          container: true,
          label: 'Account controls for $username, role $role',
          button: onTap != null,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _Avatar(
                    avatarUrl: avatarUrl,
                    username: username,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    username,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: effectiveForeground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    role,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: mutedForeground,
                    ),
                  ),
                  if (onSettingsPressed != null) ...<Widget>[
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: onSettingsPressed,
                        icon: const Icon(Icons.settings_outlined, size: 18),
                        label: const Text('Account settings'),
                        style: TextButton.styleFrom(
                          foregroundColor: mutedForeground,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          minimumSize: const Size(0, 32),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.avatarUrl,
    required this.username,
  });

  final String? avatarUrl;
  final String username;

  String get _initials {
    final List<String> parts = username
        .trim()
        .split(' ')
        .where((String part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) {
      return '?';
    }
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String? url = avatarUrl;
    final ImageProvider<Object>? imageProvider =
        (url == null || url.isEmpty) ? null : NetworkImage(url);

    return CircleAvatar(
      radius: 24,
      backgroundColor: theme.colorScheme.primaryContainer,
      foregroundColor: theme.colorScheme.onPrimaryContainer,
      backgroundImage: imageProvider,
      child: imageProvider == null
          ? Text(
              _initials,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w700,
              ),
            )
          : null,
    );
  }
}
