import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Modal Dialog providing full source code export and step-by-step integration guides
/// for any component or widget across Web, Tablet, and Mobile views.
class CodeExportModalDialog extends StatefulWidget {
  const CodeExportModalDialog({
    super.key,
    required this.globalRefId,
    required this.title,
    required this.fileName,
    required this.widgetClassName,
    required this.category,
    required this.sourceCode,
    required this.integrationGuide,
  });

  final String globalRefId;
  final String title;
  final String fileName;
  final String widgetClassName;
  final String category;
  final String sourceCode;
  final String integrationGuide;

  /// Helper to trigger dialog easily
  static void show({
    required BuildContext context,
    required String globalRefId,
    required String title,
    required String fileName,
    required String widgetClassName,
    required String category,
    required String sourceCode,
    required String integrationGuide,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => CodeExportModalDialog(
        globalRefId: globalRefId,
        title: title,
        fileName: fileName,
        widgetClassName: widgetClassName,
        category: category,
        sourceCode: sourceCode,
        integrationGuide: integrationGuide,
      ),
    );
  }

  @override
  State<CodeExportModalDialog> createState() => _CodeExportModalDialogState();
}

class _CodeExportModalDialogState extends State<CodeExportModalDialog>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    final colorScheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: colorScheme.onPrimary),
            const SizedBox(width: 8.0),
            Expanded(child: Text('$label copied to clipboard!')),
          ],
        ),
        backgroundColor: colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 900.0,
          maxHeight: 750.0,
        ),
        child: Column(
          children: [
            // Modal Header
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHigh,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20.0)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 4.0),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text(
                      widget.globalRefId,
                      style: TextStyle(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12.0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'File: lib/ui/${widget.fileName}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontFamily: 'monospace',
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Tab Bar (Code vs Guide)
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(
                  icon: Icon(Icons.code),
                  text: 'Component Code (.dart)',
                ),
                Tab(
                  icon: Icon(Icons.integration_instructions),
                  text: 'Integration Guide',
                ),
              ],
            ),

            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: Source Code View
                  _buildSourceCodeView(theme, isDark),

                  // Tab 2: Integration Guide View
                  _buildIntegrationGuideView(theme, isDark),
                ],
              ),
            ),

            // Bottom Actions Bar
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerLow,
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(20.0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Class: ${widget.widgetClassName}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => _copyToClipboard(
                          widget.integrationGuide,
                          'Integration Guide',
                        ),
                        icon: const Icon(Icons.copy_all),
                        label: const Text('Copy Guide'),
                      ),
                      const SizedBox(width: 8.0),
                      FilledButton.icon(
                        onPressed: () => _copyToClipboard(
                          widget.sourceCode,
                          'Source Code',
                        ),
                        icon: const Icon(Icons.content_copy),
                        label: const Text('Copy Code'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceCodeView(ThemeData theme, bool isDark) {
    return Container(
      color: theme.colorScheme.surfaceContainerHighest,
      padding: const EdgeInsets.all(16.0),
      child: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: SelectableText(
              widget.sourceCode,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 13.0,
                color: theme.colorScheme.onSurface,
                height: 1.4,
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: FloatingActionButton.small(
              heroTag: 'copy_code_btn',
              tooltip: 'Copy Source Code',
              onPressed: () =>
                  _copyToClipboard(widget.sourceCode, 'Source Code'),
              child: const Icon(Icons.copy),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntegrationGuideView(ThemeData theme, bool isDark) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step 1: File Placement
          _buildGuideSectionHeader(
            theme,
            step: 'Step 1',
            title: 'File Placement in Your Flutter App',
          ),
          const SizedBox(height: 8.0),
          _buildCodeSnippetBox(
            theme,
            isDark,
            '// Create a new Dart file in your target project:\n'
            'lib/ui/${widget.fileName}\n\n'
            '// Paste the copied component source code directly into this file.',
          ),
          const SizedBox(height: 20.0),

          // Step 2: Pubspec & Theme Configuration
          _buildGuideSectionHeader(
            theme,
            step: 'Step 2',
            title: 'Dependencies & Theme Configuration',
          ),
          const SizedBox(height: 8.0),
          Text(
            'Ensure your pubspec.yaml includes Flutter Material 3 support. If the component utilizes semantic status colors, make sure your MaterialApp includes ThemeData with ColorScheme:',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 8.0),
          _buildCodeSnippetBox(
            theme,
            isDark,
            '// pubspec.yaml\n'
            'dependencies:\n'
            '  flutter:\n'
            '    sdk: flutter\n\n'
            '// main.dart ThemeData\n'
            'MaterialApp(\n'
            '  theme: AppTheme.lightTheme,\n'
            ');',
          ),
          const SizedBox(height: 20.0),

          // Step 3: Instantiation & Import
          _buildGuideSectionHeader(
            theme,
            step: 'Step 3',
            title: 'Instantiate Component in Your Screens',
          ),
          const SizedBox(height: 8.0),
          _buildCodeSnippetBox(
            theme,
            isDark,
            "import 'package:your_app/ui/${widget.fileName}';\n\n"
            "// Inside any Widget build() method:\n"
            "Widget build(BuildContext context) {\n"
            "  return const ${widget.widgetClassName}();\n"
            "}",
          ),
          const SizedBox(height: 20.0),

          // Step 4: Web / Tablet / Mobile Responsiveness & Poka-Yoke Rules
          _buildGuideSectionHeader(
            theme,
            step: 'Step 4',
            title: 'Responsiveness & Built-in Features',
          ),
          const SizedBox(height: 8.0),
          Card(
            elevation: 0,
            color: theme.colorScheme.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.devices, color: theme.colorScheme.primary),
                      const SizedBox(width: 8.0),
                      Text(
                        'Layout Breakpoints & Touch Target Rules:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  const Text('• Mobile View: maxWidth <= 600dp'),
                  const Text('• Tablet View: 600dp < maxWidth <= 900dp'),
                  const Text('• Web Desktop View: maxWidth > 900dp'),
                  const Text(
                    '• Accessibility: 48dp minimum touch target height on input fields and buttons.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideSectionHeader(ThemeData theme,
      {required String step, required String title}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          decoration: BoxDecoration(
            color: theme.colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(6.0),
          ),
          child: Text(
            step,
            style: TextStyle(
              fontSize: 12.0,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSecondaryContainer,
            ),
          ),
        ),
        const SizedBox(width: 8.0),
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildCodeSnippetBox(ThemeData theme, bool isDark, String code) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: SelectableText(
        code,
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: 12.0,
          color: theme.colorScheme.onSurface,
        ),
      ),
    );
  }
}
