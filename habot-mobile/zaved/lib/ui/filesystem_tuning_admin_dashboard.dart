import 'dart:async';
import 'package:flutter/material.dart';

/// Storage Tuning Parameter Model
class StorageTuningParameter {
  final String id;
  final String key;
  final String category;
  final String currentValue;
  final String recommendedValue;
  final String status;
  final bool isOptimized;

  const StorageTuningParameter({
    required this.id,
    required this.key,
    required this.category,
    required this.currentValue,
    required this.recommendedValue,
    required this.status,
    required this.isOptimized,
  });
}

/// Filesystem Tuning Admin Dashboard Stateful Widget (HSCPE-007)
class FilesystemTuningAdminDashboard extends StatefulWidget {
  const FilesystemTuningAdminDashboard({super.key});

  @override
  State<FilesystemTuningAdminDashboard> createState() =>
      _FilesystemTuningAdminDashboardState();
}

class _FilesystemTuningAdminDashboardState
    extends State<FilesystemTuningAdminDashboard> {
  Timer? _pollingTimer;
  Timer? _retryCountdownTimer;
  int _pollCounter = 0;
  bool _isRateLimited = false;
  int _retryCountdownSeconds = 5;
  BuildContext? _dialogContext;

  final List<StorageTuningParameter> _tuningParameters = const [
    StorageTuningParameter(
      id: 'ST-101',
      key: 'read_ahead_kb',
      category: 'I/O Subsystem',
      currentValue: '4096 KB',
      recommendedValue: '4096 KB',
      status: 'OPTIMAL',
      isOptimized: true,
    ),
    StorageTuningParameter(
      id: 'ST-102',
      key: 'dirty_background_ratio',
      category: 'Virtual Memory',
      currentValue: '10%',
      recommendedValue: '5%',
      status: 'SUBOPTIMAL',
      isOptimized: false,
    ),
    StorageTuningParameter(
      id: 'ST-103',
      key: 'nr_requests',
      category: 'Block Device Queue',
      currentValue: '256',
      recommendedValue: '1024',
      status: 'NEEDS TUNING',
      isOptimized: false,
    ),
    StorageTuningParameter(
      id: 'ST-104',
      key: 'nfs_mount_timeout',
      category: 'Network Storage',
      currentValue: '600s',
      recommendedValue: '600s',
      status: 'OPTIMAL',
      isOptimized: true,
    ),
    StorageTuningParameter(
      id: 'ST-105',
      key: 'ext4_journal_mode',
      category: 'Filesystem Journal',
      currentValue: 'ordered',
      recommendedValue: 'ordered',
      status: 'OPTIMAL',
      isOptimized: true,
    ),
    StorageTuningParameter(
      id: 'ST-106',
      key: 'nvme_max_qp_depth',
      category: 'NVMe Queue',
      currentValue: '64',
      recommendedValue: '128',
      status: 'SUBOPTIMAL',
      isOptimized: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _retryCountdownTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!mounted) return;
      setState(() {
        _pollCounter++;
      });

      // Simulate HTTP 429 Rate-Limit Breach every 4 polling ticks
      if (_pollCounter % 4 == 0) {
        _triggerRateLimitBreach();
      }
    });
  }

  void _triggerRateLimitBreach() {
    _pollingTimer?.cancel();
    setState(() {
      _isRateLimited = true;
      _retryCountdownSeconds = 5;
    });

    _showRateLimitAlertDialog();

    _retryCountdownTimer?.cancel();
    _retryCountdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_retryCountdownSeconds > 0) {
          _retryCountdownSeconds--;
        } else {
          timer.cancel();
          _dismissRateLimitAlertDialog();
        }
      });
    });
  }

  void _showRateLimitAlertDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        _dialogContext = ctx;
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            final theme = Theme.of(dialogCtx);
            return AlertDialog(
              backgroundColor: theme.colorScheme.errorContainer,
              icon: Icon(
                Icons.warning_amber_rounded,
                color: theme.colorScheme.onErrorContainer,
                size: 36,
              ),
              title: Text(
                'HTTP 429 Rate Limit Breached',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onErrorContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Too Many Requests, Retrying in $_retryCountdownSeconds Seconds',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onErrorContainer,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: _retryCountdownSeconds / 5.0,
                    backgroundColor:
                        theme.colorScheme.onErrorContainer.withValues(alpha: 0.2),
                    color: theme.colorScheme.onErrorContainer,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _dismissRateLimitAlertDialog() {
    if (_dialogContext != null && mounted) {
      Navigator.of(_dialogContext!).pop();
      _dialogContext = null;
    }
    setState(() {
      _isRateLimited = false;
    });
    _startPolling();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bodyMediumStyle = theme.textTheme.bodyMedium ??
        const TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.normal,
          height: 1.43,
        );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Filesystem Tuning Admin Dashboard'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Chip(
              avatar: Icon(
                _isRateLimited ? Icons.sync_disabled : Icons.sync,
                size: 16,
                color: _isRateLimited
                    ? theme.colorScheme.error
                    : theme.colorScheme.primary,
              ),
              label: Text(
                _isRateLimited
                    ? '429 Rate Limited'
                    : 'Polling Active ($_pollCounter)',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth <= 600;

          return Column(
            children: [
              // Header Banner & Trigger Button
              Container(
                padding: const EdgeInsets.all(16.0),
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Active Storage Tuning Parameters',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            'Strict MD3 typography (bodyMedium) applied to all parameters in grid/list views.',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    ElevatedButton.icon(
                      onPressed:
                          _isRateLimited ? null : () => _triggerRateLimitBreach(),
                      icon: const Icon(Icons.bolt),
                      label: const Text('Simulate 429'),
                    ),
                  ],
                ),
              ),

              // Main Tuning Parameters View (Responsive Grid or List)
              Expanded(
                child: isMobile
                    ? _buildMobileListView(bodyMediumStyle)
                    : _buildTabletWebGridView(bodyMediumStyle),
              ),

              // Bottom Metadata Panel: Atomic MD3 Design Tokens Currently in Use
              _buildMetadataTokenPanel(theme, bodyMediumStyle),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMobileListView(TextStyle bodyMediumStyle) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _tuningParameters.length,
      itemBuilder: (context, index) {
        final param = _tuningParameters[index];
        final theme = Theme.of(context);

        return Card(
          margin: const EdgeInsets.only(bottom: 12.0),
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
            side: BorderSide(color: theme.colorScheme.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      param.id,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Chip(
                      visualDensity: VisualDensity.compact,
                      backgroundColor: param.isOptimized
                          ? theme.colorScheme.primaryContainer
                          : theme.colorScheme.errorContainer,
                      label: Text(
                        param.status,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: param.isOptimized
                              ? theme.colorScheme.onPrimaryContainer
                              : theme.colorScheme.onErrorContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                // Parameter Key with strict bodyMedium token styling
                Text(
                  param.key,
                  style: bodyMediumStyle.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  'Category: ${param.category}',
                  style: bodyMediumStyle.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const Divider(height: 16.0),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Current', style: theme.textTheme.labelSmall),
                          Text(param.currentValue, style: bodyMediumStyle),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Recommended', style: theme.textTheme.labelSmall),
                          Text(param.recommendedValue, style: bodyMediumStyle),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabletWebGridView(TextStyle bodyMediumStyle) {
    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 380,
        childAspectRatio: 1.5,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _tuningParameters.length,
      itemBuilder: (context, index) {
        final param = _tuningParameters[index];
        final theme = Theme.of(context);

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
            side: BorderSide(color: theme.colorScheme.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      param.id,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: param.isOptimized
                            ? theme.colorScheme.primaryContainer
                            : theme.colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        param.status,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: param.isOptimized
                              ? theme.colorScheme.onPrimaryContainer
                              : theme.colorScheme.onErrorContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  param.key,
                  style: bodyMediumStyle.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Category: ${param.category}',
                  style: bodyMediumStyle.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Current', style: theme.textTheme.labelSmall),
                          Text(param.currentValue, style: bodyMediumStyle),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Recommended', style: theme.textTheme.labelSmall),
                          Text(param.recommendedValue, style: bodyMediumStyle),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMetadataTokenPanel(ThemeData theme, TextStyle bodyMediumStyle) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.style_outlined,
                size: 16,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8.0),
              Text(
                'Atomic Design Tokens Panel (bodyMedium)',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          Wrap(
            spacing: 16.0,
            runSpacing: 8.0,
            children: [
              _buildTokenBadge(
                theme,
                'Font Name',
                bodyMediumStyle.fontFamily ?? 'Roboto (Default)',
              ),
              _buildTokenBadge(
                theme,
                'Font Size',
                '${bodyMediumStyle.fontSize ?? 14.0} px',
              ),
              _buildTokenBadge(
                theme,
                'Line Height',
                '${bodyMediumStyle.height ?? 1.43}',
              ),
              _buildTokenBadge(
                theme,
                'Font Weight',
                '${bodyMediumStyle.fontWeight ?? FontWeight.w400}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTokenBadge(ThemeData theme, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6.0),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: RichText(
        text: TextSpan(
          style: theme.textTheme.bodySmall,
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}
