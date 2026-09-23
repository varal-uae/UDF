import 'package:flutter/material.dart';

/// Row 330 | Task: GEN-00605 | Seq: 17314
/// Action: Open the mobile scaffolds library mobile_core/ui/scaffolds/.
/// Metric: Path Access Integrity (Target: 100%, Standard: Flutter Component Layout)
class MobileScaffoldLibraryPanel extends StatefulWidget {
  const MobileScaffoldLibraryPanel({super.key});

  @override
  State<MobileScaffoldLibraryPanel> createState() =>
      _MobileScaffoldLibraryPanelState();
}

class _MobileScaffoldLibraryPanelState
    extends State<MobileScaffoldLibraryPanel> {
  final String _libraryPath = 'mobile_core/ui/scaffolds/';
  final List<String> _scaffoldModules = const [
    'standard_app_scaffold.dart',
    'collapsible_sliver_scaffold.dart',
    'split_pane_tablet_scaffold.dart',
    'bottom_nav_workspace_scaffold.dart',
  ];
  bool _pathVerified = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.folder_copy_outlined,
                    color: theme.colorScheme.onPrimaryContainer,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'GEN-00605: Mobile Scaffolds Library',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Seq: 17314 • Standard: Flutter Component Layout',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
                Chip(
                  avatar: Icon(
                    _pathVerified
                        ? Icons.check_circle_outline
                        : Icons.error_outline,
                    color: _pathVerified ? Colors.green : Colors.red,
                    size: 16,
                  ),
                  label: Text(_pathVerified ? '100% Verified' : 'Check Path'),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const Divider(height: 24),
            Text(
              'Scaffold Directory Path:',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                _libraryPath,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Registered Scaffold Templates:',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            ..._scaffoldModules.map(
              (module) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    const Icon(
                      Icons.widgets_outlined,
                      size: 16,
                      color: Colors.blueAccent,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      module,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _pathVerified = !_pathVerified;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Scaffold library path $_libraryPath status: ${_pathVerified ? "Verified" : "Unverified"}',
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(Icons.refresh, size: 20),
                label: const Text('Re-verify Scaffold Layout Tree'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: MobileScaffoldLibraryPanel(),
          ),
        ),
      ),
    ),
  );
}
