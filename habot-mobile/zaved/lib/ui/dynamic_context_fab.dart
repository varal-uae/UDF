import 'package:flutter/material.dart';

/// ============================================================================
/// ATOMIC METADATA
/// Repository URL: https://github.com/organization/aiss_flutter.git
/// Repository Branch: main
/// Access Rights: Write-Allowed / Restricted
/// Commit History: commit_001_initial -> commit_002_poka_yoke_fab -> commit_003_m3_tokens
/// Repository Version: v2.4.0
/// Clone Status: Synced / Up-to-Date
/// ============================================================================

/// IS26-RCGLA-024-AS01: Responsive Dynamic Context FAB Wrapper
class DynamicContextFab extends StatefulWidget {
  const DynamicContextFab({super.key});

  @override
  State<DynamicContextFab> createState() => _DynamicContextFabState();
}

class _DynamicContextFabState extends State<DynamicContextFab> {
  // Contextual Security Visibility state
  bool _hasWritePermissions = true;

  // Double-Tap Prevention (Poka-Yoke) state
  bool _isProcessing = false;

  // Action log feed for demonstration
  final List<String> _actionLogs = [];

  Future<void> _handleFabPressed() async {
    // Double-Tap Prevention (Poka-Yoke): physically blocks duplicate transaction payloads
    if (_isProcessing) {
      debugPrint('[Poka-Yoke Blocked] Double-tap attempt rejected while processing.');
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    final timestamp = DateTime.now().toIso8601String().substring(11, 19);
    _logAction('[$timestamp] Transaction initiated. Ingestion pipeline locked.');

    // Execute mock asynchronous transaction payload
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() {
      _isProcessing = false;
    });

    _logAction('[$timestamp] Transaction payload successfully committed.');
  }

  void _logAction(String message) {
    setState(() {
      _actionLogs.insert(0, message);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth <= 600;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Dynamic Context FAB Workspace'),
            elevation: 2,
            actions: [
              IconButton(
                icon: Icon(
                  _hasWritePermissions ? Icons.admin_panel_settings : Icons.lock_person,
                ),
                tooltip: 'Toggle Write Permissions',
                onPressed: () {
                  setState(() {
                    _hasWritePermissions = !_hasWritePermissions;
                  });
                },
              ),
            ],
          ),
          // Contextual Security Visibility & Poka-Yoke FAB
          floatingActionButton: _hasWritePermissions
              ? (isMobile
                  ? FloatingActionButton(
                      backgroundColor: theme.colorScheme.primaryContainer,
                      elevation: 3.0,
                      onPressed: _isProcessing ? null : _handleFabPressed,
                      child: _isProcessing
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2.5),
                            )
                          : const Icon(Icons.add),
                    )
                  : FloatingActionButton.extended(
                      backgroundColor: theme.colorScheme.primaryContainer,
                      elevation: 3.0,
                      onPressed: _isProcessing ? null : _handleFabPressed,
                      icon: _isProcessing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.add_task),
                      label: Text(
                        _isProcessing ? 'Ingesting Payload...' : 'Create Transaction Record',
                        style: TextStyle(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ))
              : const SizedBox.shrink(), // Returns SizedBox.shrink() when permissions false
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Security & Permission Banner Controls
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: theme.colorScheme.outlineVariant),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _hasWritePermissions ? Icons.verified_user : Icons.gavel,
                              color: _hasWritePermissions
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.error,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _hasWritePermissions
                                    ? 'Security Access: WRITE PERMISSIONS ACTIVE'
                                    : 'Security Access: READ-ONLY (FAB ERASED)',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: _hasWritePermissions
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.error,
                                ),
                              ),
                            ),
                            Switch(
                              value: _hasWritePermissions,
                              onChanged: (val) {
                                setState(() {
                                  _hasWritePermissions = val;
                                });
                              },
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Text(
                          'Poka-Yoke Double-Tap Prevention Status: ${_isProcessing ? "LOCKED (In-Flight)" : "IDLE (Ready)"}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Layout Information Box
                Card(
                  elevation: 1,
                  color: theme.colorScheme.surfaceContainerLow,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Responsive Layout Mode: ${isMobile ? "Mobile (Standard FAB)" : "Web/Tablet (Extended FAB)"}',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Screen width: ${constraints.maxWidth.toStringAsFixed(1)}dp (Breakpoint threshold: 600dp)',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Ingestion Log Feed
                Text(
                  'Transaction Ingestion Logs',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  elevation: 1,
                  child: Container(
                    height: 240,
                    padding: const EdgeInsets.all(12),
                    child: _actionLogs.isEmpty
                        ? Center(
                            child: Text(
                              'Tap the Floating Action Button to trigger transactions.',
                              style: TextStyle(color: Theme.of(context).colorScheme.outline),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _actionLogs.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  children: [
                                    Icon(Icons.bolt, size: 16, color: Theme.of(context).colorScheme.tertiary),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _actionLogs[index],
                                        style: const TextStyle(
                                          fontFamily: 'monospace',
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
