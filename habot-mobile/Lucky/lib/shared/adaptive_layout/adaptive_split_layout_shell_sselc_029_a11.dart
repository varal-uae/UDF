// SSELC-029-A11 — AdaptiveSplitLayoutShell: Master/detail responsive split-panel layout.
// Provides a 60/40 horizontal split view on widescreen layouts and full-screen routing with a prominent back button on mobile devices. Enforces 48x48dp touch targets, high-contrast palettes, and standard border dividers.

import 'package:flutter/material.dart';

/// Mock data model for document details.
class DocumentDetail {
  final String id;
  final String title;
  final String url;
  final DateTime lastUpdated;
  final String accessibilityStatus;
  final String accessLog;

  const DocumentDetail({
    required this.id,
    required this.title,
    required this.url,
    required this.lastUpdated,
    required this.accessibilityStatus,
    required this.accessLog,
  });
}

/// Local mock data repository to simulate backend fetching.
class MockDocumentRepository {
  static const List<DocumentDetail> documents = [
    DocumentDetail(
      id: 'DOC-001',
      title: 'UDF Architecture Guidelines',
      url: 'https://internal.varal.ae/docs/udf-arch',
      lastUpdated: DateTime(2026, 9, 25),
      accessibilityStatus: 'Compliant',
      accessLog: 'Accessed by Admin on 2026-09-26',
    ),
    DocumentDetail(
      id: 'DOC-002',
      title: 'Material Design Implementation Specs',
      url: 'https://internal.varal.ae/docs/md-specs',
      lastUpdated: DateTime(2026, 9, 20),
      accessibilityStatus: 'Pending Review',
      accessLog: 'Accessed by Dev Team on 2026-09-21',
    ),
    DocumentDetail(
      id: 'DOC-003',
      title: 'Mobile-First UX Strategy',
      url: 'https://internal.varal.ae/docs/mobile-ux',
      lastUpdated: DateTime(2026, 9, 15),
      accessibilityStatus: 'Compliant',
      accessLog: 'Accessed by QA on 2026-09-18',
    ),
    DocumentDetail(
      id: 'DOC-004',
      title: 'Network Bandwidth Optimization',
      url: 'https://internal.varal.ae/docs/net-opt',
      lastUpdated: DateTime(2026, 9, 10),
      accessibilityStatus: 'Compliant',
      accessLog: 'Accessed by Architect on 2026-09-12',
    ),
  ];
}

/// Fluid master/detail split-panel layout wrapper shell.
/// Adapts interfaces based on screen widths (SSELC-029).
class AdaptiveSplitLayoutShell extends StatefulWidget {
  const AdaptiveSplitLayoutShell({super.key});

  @override
  State<AdaptiveSplitLayoutShell> createState() => _AdaptiveSplitLayoutShellState();
}

class _AdaptiveSplitLayoutShellState extends State<AdaptiveSplitLayoutShell> {
  DocumentDetail? _selectedDocument;

  /// Threshold for switching between mobile full-screen and desktop split-view.
  static const double _kDesktopBreakpoint = 600.0;

  void _selectDocument(DocumentDetail doc) {
    setState(() {
      _selectedDocument = doc;
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedDocument = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= _kDesktopBreakpoint;

    if (isDesktop) {
      return _buildDesktopSplitView();
    } else {
      return _buildMobileRoutingView();
    }
  }

  /// Desktop/Tablet: Elegant 60/40 horizontal split view.
  Widget _buildDesktopSplitView() {
    return Row(
      children: [
        // Left panel: 60% width
        Expanded(
          flex: 6,
          child: Container(
            color: Theme.of(context).colorScheme.surface,
            child: _MasterListView(
              selectedId: _selectedDocument?.id,
              onSelect: _selectDocument,
            ),
          ),
        ),
        // Clean, simple border divider line to separate side-by-side panels uniformly.
        VerticalDivider(
          width: 1.0,
          thickness: 1.0,
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
        // Right panel: 40% width
        Expanded(
          flex: 4,
          child: Container(
            color: Theme.of(context).colorScheme.surfaceContainerLowest,
            child: _selectedDocument != null
                ? _DetailView(document: _selectedDocument!, isMobile: false, onBack: _clearSelection)
                : _EmptyDetailPlaceholder(),
          ),
        ),
      ],
    );
  }

  /// Mobile: Clean, separate full-screen routing for lists and details.
  Widget _buildMobileRoutingView() {
    if (_selectedDocument == null) {
      return _MasterListView(
        selectedId: null,
        onSelect: _selectDocument,
      );
    } else {
      return _DetailView(
        document: _selectedDocument!,
        isMobile: true,
        onBack: _clearSelection,
      );
    }
  }
}

/// Left list navigation structure keeping screens clean and legible.
class _MasterListView extends StatelessWidget {
  final String? selectedId;
  final ValueChanged<DocumentDetail> onSelect;

  const _MasterListView({
    required this.selectedId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView.separated(
      itemCount: MockDocumentRepository.documents.length,
      separatorBuilder: (_, __) => Divider(
        height: 1.0,
        thickness: 1.0,
        color: theme.colorScheme.outlineVariant,
      ),
      itemBuilder: (context, index) {
        final doc = MockDocumentRepository.documents[index];
        final isSelected = doc.id == selectedId;

        return Material(
          color: isSelected
              ? theme.colorScheme.primaryContainer
              : Colors.transparent,
          child: InkWell(
            onTap: () => onSelect(doc),
            child: Padding(
              // Enforce 48x48dp Touch Target Padding Constraints
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doc.title,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          'Updated: ${doc.lastUpdated.year}-${doc.lastUpdated.month.toString().padLeft(2, '0')}-${doc.lastUpdated.day.toString().padLeft(2, '0')}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.check_circle,
                      color: theme.colorScheme.primary,
                      size: 24.0,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Detail view mapping historical documentation elements.
class _DetailView extends StatelessWidget {
  final DocumentDetail document;
  final bool isMobile;
  final VoidCallback onBack;

  const _DetailView({
    required this.document,
    required this.isMobile,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: isMobile
          ? AppBar(
              backgroundColor: theme.colorScheme.surface,
              elevation: 0.0,
              leading: Tooltip(
                message: 'Return to the document table list',
                child: IconButton(
                  // Clear, large "Back to Table" arrow button within mobile detail headers.
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 28.0),
                  onPressed: onBack,
                  constraints: const BoxConstraints(minWidth: 48.0, minHeight: 48.0),
                  color: theme.colorScheme.onSurface,
                ),
              ),
              title: Text(
                'Details',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
            )
          : null,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMobile) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Document Details', style: theme.textTheme.headlineSmall),
                  Tooltip(
                    message: 'Close details panel',
                    child: IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: onBack,
                      constraints: const BoxConstraints(minWidth: 48.0, minHeight: 48.0),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24.0),
              Divider(color: theme.colorScheme.outlineVariant, thickness: 1.0),
              const SizedBox(height: 24.0),
            ],
            _DetailRow(label: 'Title', value: document.title, theme: theme),
            _DetailRow(label: 'URL', value: document.url, theme: theme),
            _DetailRow(
              label: 'Last Updated',
              value: '${document.lastUpdated.year}-${document.lastUpdated.month.toString().padLeft(2, '0')}-${document.lastUpdated.day.toString().padLeft(2, '0')}',
              theme: theme,
            ),
            _DetailRow(label: 'Accessibility Status', value: document.accessibilityStatus, theme: theme),
            _DetailRow(label: 'Access Log', value: document.accessLog, theme: theme),
          ],
        ),
      ),
    );
  }
}

/// Standardized row component applying accessible high-contrast palettes.
class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final ThemeData theme;

  const _DetailRow({
    required this.label,
    required this.value,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            value,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16.0),
          Divider(color: theme.colorScheme.outlineVariant.withOpacity(0.5), thickness: 1.0),
        ],
      ),
    );
  }
}

/// Placeholder when no item is selected in widescreen layouts.
class _EmptyDetailPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.description_outlined,
            size: 64.0,
            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
          const SizedBox(height: 16.0),
          Text(
            'Select a document from the list to view details.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}