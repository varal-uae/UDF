// GEN-00173 — Fallback UI Screens for Critical Error States.
// Single-column M3 layout (<600dp) / multi-column (>=840dp) covering network loss, render crash, and 500 error with retry, drill-down, and accessible status chips.
import 'package:flutter/material.dart';

/// EC: Classify critical fallback error kinds.
enum CriticalErrorKind {
  networkLoss,
  renderCrash,
  serverError,
}

/// EC: Describe fallback screen configuration.
@immutable
class CriticalErrorConfig {
  final CriticalErrorKind kind;
  final String title;
  final String message;
  final String traceId;
  final DateTime timestamp;
  final VoidCallback? onRetry;
  final VoidCallback? onGoHome;
  final VoidCallback? onDrillDown;

  const CriticalErrorConfig({
    required this.kind,
    required this.title,
    required this.message,
    this.traceId = '',
    required this.timestamp,
    this.onRetry,
    this.onGoHome,
    this.onDrillDown,
  });

  /// EC: Build preset for network loss.
  factory CriticalErrorConfig.networkLoss({
    String traceId = '',
    VoidCallback? onRetry,
    VoidCallback? onGoHome,
    VoidCallback? onDrillDown,
  }) {
    return CriticalErrorConfig(
      kind: CriticalErrorKind.networkLoss,
      title: 'No connection',
      message: 'We could not reach the server. Check your connection and try again. Your progress is saved.',
      traceId: traceId,
      timestamp: DateTime.now(),
      onRetry: onRetry,
      onGoHome: onGoHome,
      onDrillDown: onDrillDown,
    );
  }

  /// EC: Build preset for render crash.
  factory CriticalErrorConfig.renderCrash({
    String traceId = '',
    VoidCallback? onRetry,
    VoidCallback? onGoHome,
    VoidCallback? onDrillDown,
  }) {
    return CriticalErrorConfig(
      kind: CriticalErrorKind.renderCrash,
      title: 'Something failed to display',
      message: 'This view crashed during render. Reload the screen to restore a safe state.',
      traceId: traceId,
      timestamp: DateTime.now(),
      onRetry: onRetry,
      onGoHome: onGoHome,
      onDrillDown: onDrillDown,
    );
  }

  /// EC: Build preset for 500 server error.
  factory CriticalErrorConfig.serverError({
    String traceId = '',
    VoidCallback? onRetry,
    VoidCallback? onGoHome,
    VoidCallback? onDrillDown,
  }) {
    return CriticalErrorConfig(
      kind: CriticalErrorKind.serverError,
      title: 'Server error (500)',
      message: 'Our service hit an unexpected error. Our team has been notified. Please retry in a moment.',
      traceId: traceId,
      timestamp: DateTime.now(),
      onRetry: onRetry,
      onGoHome: onGoHome,
      onDrillDown: onDrillDown,
    );
  }
}

/// EC: Render responsive fallback UI for all critical error states.
class CriticalErrorFallbackScreen extends StatelessWidget {
  final CriticalErrorConfig config;
  final bool enablePullToRefresh;

  const CriticalErrorFallbackScreen({
    super.key,
    required this.config,
    this.enablePullToRefresh = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    Widget body = LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 840;
        if (isWide) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 960),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _ErrorIllustration(kind: config.kind)),
                  const SizedBox(width: 24),
                  Expanded(child: _ErrorDetailCard(config: config)),
                ],
              ),
            ),
          );
        }
        return SingleChildScrollView(
          // EC: Avoid clipping focus ring — allow overflow visible for focus outlines.
          clipBehavior: Clip.none,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ErrorIllustration(kind: config.kind),
              const SizedBox(height: 16),
              _ErrorDetailCard(config: config),
            ],
          ),
        );
      },
    );

    if (enablePullToRefresh && config.onRetry != null) {
      body = RefreshIndicator(
        onRefresh: () async {
          config.onRetry?.call();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Retrying request...')),
          );
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          clipBehavior: Clip.none,
          child: body,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Something went wrong'),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: body,
        ),
      ),
    );
  }

  /// EC: Show error details in M3 bottom sheet.
  static Future<void> showDetailsSheet(BuildContext context, CriticalErrorConfig config) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      builder: (ctx) => _ErrorDetailsSheet(config: config),
    );
  }
}

/// EC: Illustrate error with semantic M3 iconography.
class _ErrorIllustration extends StatelessWidget {
  final CriticalErrorKind kind;
  const _ErrorIllustration({required this.kind});

  IconData get _icon {
    switch (kind) {
      case CriticalErrorKind.networkLoss:
        return Icons.wifi_off_rounded;
      case CriticalErrorKind.renderCrash:
        return Icons.broken_image_outlined;
      case CriticalErrorKind.serverError:
        return Icons.cloud_off_outlined;
    }
  }

  String get _label {
    switch (kind) {
      case CriticalErrorKind.networkLoss:
        return 'Network loss illustration';
      case CriticalErrorKind.renderCrash:
        return 'Render crash illustration';
      case CriticalErrorKind.serverError:
        return 'Server error illustration';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Semantics(
      label: _label,
      image: true,
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Center(
          child: Icon(_icon, size: 72, color: cs.onSurfaceVariant),
        ),
      ),
    );
  }
}

/// EC: Display M3 elevated card with status chip and actions.
class _ErrorDetailCard extends StatelessWidget {
  final CriticalErrorConfig config;
  const _ErrorDetailCard({required this.config});

  String get _chipLabel {
    switch (config.kind) {
      case CriticalErrorKind.networkLoss:
        return 'OFFLINE';
      case CriticalErrorKind.renderCrash:
        return 'RENDER FAIL';
      case CriticalErrorKind.serverError:
        return '500 ERROR';
    }
  }

  Color _chipColor(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    switch (config.kind) {
      case CriticalErrorKind.networkLoss:
        return cs.tertiary;
      case CriticalErrorKind.renderCrash:
        return cs.error;
      case CriticalErrorKind.serverError:
        return cs.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              children: [
                Semantics(
                  label: 'Error status: $_chipLabel',
                  child: Chip(
                    label: Text(_chipLabel),
                    backgroundColor: _chipColor(context).withOpacity(0.14),
                    side: BorderSide(color: _chipColor(context)),
                    labelStyle: textTheme.labelMedium?.copyWith(color: _chipColor(context)),
                  ),
                ),
                if (config.traceId.isNotEmpty)
                  ActionChip(
                    label: Text('Trace ${config.traceId}'),
                    onPressed: config.onDrillDown,
                    tooltip: 'Open trace drill-down',
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(config.title, style: textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(config.message, style: textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                if (config.onRetry != null)
                  FilledButton.icon(
                    onPressed: () {
                      config.onRetry!.call();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Retrying...')),
                      );
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    style: FilledButton.styleFrom(minimumSize: const Size(120, 48)),
                  ),
                if (config.onGoHome != null)
                  OutlinedButton.icon(
                    onPressed: config.onGoHome,
                    icon: const Icon(Icons.home_outlined),
                    label: const Text('Go home'),
                    style: OutlinedButton.styleFrom(minimumSize: const Size(120, 48)),
                  ),
                TextButton(
                  onPressed: () => CriticalErrorFallbackScreen.showDetailsSheet(context, config),
                  style: TextButton.styleFrom(minimumSize: const Size(120, 48)),
                  child: const Text('View details'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// EC: Present diagnostics and drill-down actions.
class _ErrorDetailsSheet extends StatelessWidget {
  final CriticalErrorConfig config;
  const _ErrorDetailsSheet({required this.config});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Error details', style: textTheme.titleLarge),
            const SizedBox(height: 12),
            _DetailRow(label: 'Type', value: config.kind.name),
            _DetailRow(label: 'Time', value: config.timestamp.toIso8601String()),
            _DetailRow(label: 'Trace', value: config.traceId.isEmpty ? 'n/a' : config.traceId),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  config.onDrillDown?.call();
                },
                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                child: const Text('Open diagnostics'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// EC: Render label-value diagnostic row.
class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 72, child: Text(label, style: textTheme.labelMedium)),
          Expanded(child: SelectableText(value, style: textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
