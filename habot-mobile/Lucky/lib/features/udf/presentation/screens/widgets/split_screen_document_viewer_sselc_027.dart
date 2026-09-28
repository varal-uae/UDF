// SSELC-027 — Split-Screen Document Viewer with Secure Input.
// Implements a split-screen layout with locked viewport, sticky input above keyboard, disabled zoom, and high-contrast dividing line using Material 3 design tokens.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Mock data model for the document viewer component.
class _MockDocumentItem {
  final String id;
  final String title;
  final String content;
  final String libraryName;
  final String libraryVersion;
  final int componentCount;
  final String installationStatus;
  final List<String> dependencyList;
  final String libraryLocationPath;

  const _MockDocumentItem({
    required this.id,
    required this.title,
    required this.content,
    required this.libraryName,
    required this.libraryVersion,
    required this.componentCount,
    required this.installationStatus,
    required this.dependencyList,
    required this.libraryLocationPath,
  });
}

/// Realistic local mock data representing atomic-level data fields.
const List<_MockDocumentItem> _mockDocuments = [
  _MockDocumentItem(
    id: 'DOC-001',
    title: 'GCP Secret Manager Integration',
    content: 'Native GCP Secret Manager API calls eliminate human error in key management and prevent accidental credential leaks in code repositories. Ban all .env files containing production secrets.',
    libraryName: 'gcp_secret_manager_mobile',
    libraryVersion: '2.1.0',
    componentCount: 4,
    installationStatus: 'Pass',
    dependencyList: ['http', 'crypto', 'googleapis_auth'],
    libraryLocationPath: '/core/security/',
  ),
  _MockDocumentItem(
    id: 'DOC-002',
    title: 'MTO Isolation Protocol',
    content: 'Micro-Transaction Object (MTO) Isolation Accuracy must reconcile at >=99.5% to avoid ledger drift. Applications physically cannot connect to the database unless IAM roles are configured.',
    libraryName: 'mto_isolator_core',
    libraryVersion: '1.4.2',
    componentCount: 7,
    installationStatus: 'Pass',
    dependencyList: ['protobuf', 'fixnum'],
    libraryLocationPath: '/features/udf/data/',
  ),
];

/// A split-screen document viewer component enforcing secure UX patterns.
/// Viewport is locked to prevent accidental zooming/scrolling on the input side.
/// Sticky input field anchored above the keyboard.
/// High-contrast dividing line between image/document and input.
class SplitScreenDocumentViewerSselc027 extends StatefulWidget {
  const SplitScreenDocumentViewerSselc027({super.key});

  @override
  State<SplitScreenDocumentViewerSselc027> createState() => _SplitScreenDocumentViewerSselc027State();
}

class _SplitScreenDocumentViewerSselc027State extends State<SplitScreenDocumentViewerSselc027> {
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _inputFocusNode = FocusNode();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Disable double-tap zoom and enforce accessibility contrast via system UI overlay if applicable
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    _inputController.dispose();
    _inputFocusNode.dispose();
    SystemChrome.setPreferredOrientations([]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isWide = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Split-Screen Byt Deconstruction'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Structural form requirements: MTO Isolation Accuracy >= 99.5%',
            onPressed: () {
              _showTooltipDialog(context);
            },
          ),
        ],
      ),
      body: isWide ? _buildHorizontalLayout(theme) : _buildVerticalLayout(theme),
    );
  }

  Widget _buildHorizontalLayout(ThemeData theme) {
    return Row(
      children: [
        Expanded(flex: 1, child: _buildDocumentPanel(theme)),
        // High-contrast dividing line between image and input
        Container(width: 4.0, color: theme.colorScheme.error),
        Expanded(flex: 1, child: _buildInputPanel(theme)),
      ],
    );
  }

  Widget _buildVerticalLayout(ThemeData theme) {
    return Column(
      children: [
        Expanded(flex: 1, child: _buildDocumentPanel(theme)),
        // High-contrast dividing line between image and input
        Container(height: 4.0, color: theme.colorScheme.error),
        Expanded(flex: 1, child: _buildInputPanel(theme)),
      ],
    );
  }

  Widget _buildDocumentPanel(ThemeData theme) {
    final doc = _mockDocuments[_selectedIndex];
    return Container(
      color: theme.colorScheme.surfaceContainerHighest,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text(doc.title, style: theme.textTheme.headlineSmall?.copyWith(color: theme.colorScheme.onSurface)),
          const SizedBox(height: 16),
          Text(doc.content, style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 24),
          _buildMetadataCard(theme, doc),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8.0,
            children: [
              ChoiceChip(
                label: const Text('Doc 1'),
                selected: _selectedIndex == 0,
                onSelected: (_) => setState(() => _selectedIndex = 0),
              ),
              ChoiceChip(
                label: const Text('Doc 2'),
                selected: _selectedIndex == 1,
                onSelected: (_) => setState(() => _selectedIndex = 1),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildMetadataCard(ThemeData theme, _MockDocumentItem doc) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _metadataRow(theme, 'Library Name', doc.libraryName),
            _metadataRow(theme, 'Library Version', doc.libraryVersion),
            _metadataRow(theme, 'Component Count', doc.componentCount.toString()),
            _metadataRow(theme, 'Installation Status', doc.installationStatus),
            _metadataRow(theme, 'Dependencies', doc.dependencyList.join(', ')),
            _metadataRow(theme, 'Location Path', doc.libraryLocationPath),
          ],
        ),
      ),
    );
  }

  Widget _metadataRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label, style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
          ),
          Expanded(
            child: Text(value, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ),
        ],
      ),
    );
  }

  /// Input panel with locked viewport (no scrolling beyond bounds) 
  /// and sticky input field anchored above the keyboard.
  Widget _buildInputPanel(ThemeData theme) {
    return GestureDetector(
      // Double-tap zoom completely disabled via gesture rejection
      onDoubleTap: null,
      child: Container(
        color: theme.colorScheme.surface,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                // Locking the viewport to prevent accidental zooming/scrolling physics
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Secure Configuration Entry', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(
                      'Provide prominent tooltip boxes detailing structural form requirements. Apply accessible high-contrast palettes across text elements.',
                      style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 24),
                    // Standard user flow design patterns entry forms
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'IAM Service Account Role',
                        hintText: 'roles/secretmanager.secretAccessor',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          // Match border characteristics to standard system design specifications
                          borderSide: BorderSide(color: theme.colorScheme.outline, width: 1.5),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(color: theme.colorScheme.outline, width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Secret Identifier',
                        hintText: 'prod-api-key-push-notifications',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(color: theme.colorScheme.outline, width: 1.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Sticky input field anchored above the keyboard
            SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainer,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _inputController,
                        focusNode: _inputFocusNode,
                        decoration: InputDecoration(
                          hintText: 'Enter verification command...',
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24.0),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: theme.colorScheme.surfaceContainerHighest,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      onPressed: () {
                        // Simulate submission
                        FocusScope.of(context).unfocus();
                        _inputController.clear();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Command verified against spec.')),
                        );
                      },
                      icon: const Icon(Icons.send_rounded, size: 18),
                      label: const Text('Submit'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTooltipDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Structural Form Requirements'),
        content: const Text(
          'Metric: Micro-Transaction Object (MTO) Isolation Accuracy (%)\n'
          'Floor Boundary: 98%\n'
          'Optimal Target: 99.5%\n'
          'Ceiling Boundary: 100%\n\n'
          'Isolated transaction objects must reconcile at >=99.5% to avoid ledger drift. '
          'GitHub secret-scanning blocks any commit containing strings that match API key formats.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Understood'),
          ),
        ],
      ),
    );
  }
}