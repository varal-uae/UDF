// GEN-04124 — Re-drive Message Action Button
// Implements a single-tap M3 Elevated Card action button for the dashboard with mock latency validation, 48x48dp touch targets, and Material You dynamic color.

import 'package:flutter/material.dart';

/// Mock data simulating backend response for Re-drive Message action.
class _MockReDriveRepository {
  static const Duration simulatedLatency = Duration(milliseconds: 15);
  static const String mockStatus = 'Pass';
  static const String mockTraceId = 'trace-gen-04124-9999';

  static Future<bool> triggerReDrive() async {
    await Future.delayed(simulatedLatency);
    return true;
  }
}

class ReDriveMessageButtonGen04124 extends StatefulWidget {
  const ReDriveMessageButtonGen04124({super.key});

  @override
  State<ReDriveMessageButtonGen04124> createState() => _ReDriveMessageButtonGen04124State();
}

class _ReDriveMessageButtonGen04124State extends State<ReDriveMessageButtonGen04124> {
  bool _isLoading = false;
  String _status = 'Idle';
  int _latencyMs = 0;

  Future<void> _handleSingleTap() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _status = 'Processing';
    });

    final stopwatch = Stopwatch()..start();
    final success = await _MockReDriveRepository.triggerReDrive();
    stopwatch.stop();

    final elapsed = stopwatch.elapsedMilliseconds;

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _latencyMs = elapsed;
      _status = success ? _MockReDriveRepository.mockStatus : 'Fail';
    });

    // M3 Snackbar for confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Re-drive Message ${success ? 'successful' : 'failed'} (${elapsed}ms)'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Color _getStatusColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (_status) {
      case 'Pass':
        return colorScheme.primary;
      case 'Fail':
        return colorScheme.error;
      case 'Processing':
        return colorScheme.tertiary;
      default:
        return colorScheme.outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        // M3 responsive layout: single-column on mobile (<600dp)
        final isMobile = constraints.maxWidth < 600;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: isMobile ? double.infinity : 400,
            // M3 Elevated Cards Level 2 (3dp elevation)
            child: Card(
              elevation: 3.0,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: InkWell(
                onTap: _isLoading ? null : _handleSingleTap,
                // 48x48dp minimum touch target enforced by parent sizing
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 48.0, minWidth: 48.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Re-drive Message',
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4.0),
                              Text(
                                'Single-tap action to re-trigger pipeline message.',
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              if (_latencyMs > 0) ...[
                                const SizedBox(height: 8.0),
                                Text(
                                  'Latency: ${_latencyMs}ms | Trace: ${_MockReDriveRepository.mockTraceId}',
                                  style: textTheme.labelSmall?.copyWith(
                                    color: colorScheme.outline,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 16.0),
                        // M3 Status Chip for health indicator
                        _buildStatusChip(context),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        width: 24.0,
        height: 24.0,
        child: CircularProgressIndicator(strokeWidth: 2.0),
      );
    }

    return Chip(
      label: Text(
        _status,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSecondaryContainer,
          fontSize: 12.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: _getStatusColor(context).withOpacity(0.15),
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      visualDensity: VisualDensity.compact,
    );
  }
}
