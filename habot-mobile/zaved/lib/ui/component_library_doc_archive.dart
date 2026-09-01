import 'package:flutter/material.dart';

/// Data Model for Release Documentation fulfilling DAMA-DMBOK2 Metadata Standards.
class ReleaseDocumentation {
  final String? docTitle;
  final String? url;
  final String? lastUpdatedDate;
  final String? accessibilityStatus;
  final String? accessLog;

  const ReleaseDocumentation({
    this.docTitle,
    this.url,
    this.lastUpdatedDate,
    this.accessibilityStatus,
    this.accessLog,
  });

  Map<String, String?> toMap() {
    return {
      'Document Title': docTitle,
      'URL': url,
      'Last Updated Date': lastUpdatedDate,
      'Accessibility Status': accessibilityStatus,
      'Access Log': accessLog,
    };
  }
}

/// EDBAA-015-15: Responsive Component Library Documentation Archive Dashboard
class ComponentLibraryDocArchive extends StatefulWidget {
  const ComponentLibraryDocArchive({super.key});

  @override
  State<ComponentLibraryDocArchive> createState() =>
      _ComponentLibraryDocArchiveState();
}

class _ComponentLibraryDocArchiveState
    extends State<ComponentLibraryDocArchive> {
  // Mock Release Documentation records
  final List<ReleaseDocumentation> _documents = const [
    ReleaseDocumentation(
      docTitle: 'MD3 Navigation Rail System Specification',
      url: 'https://docs.enterprise.internal/spec/nav-rail-v3',
      lastUpdatedDate: '2026-08-10',
      accessibilityStatus: 'WCAG 2.2 AAA Compliant',
      accessLog: '2,840 views | Granted to Tier-3 ArchTeam',
    ),
    ReleaseDocumentation(
      docTitle: 'CMEK Key Rotation & Cryptographic Standard',
      url: 'https://docs.enterprise.internal/sec/cmek-key-rotation',
      lastUpdatedDate: '2026-08-12',
      accessibilityStatus: 'WCAG 2.1 AA Compliant',
      accessLog: '5,120 views | Granted to SecOps Daemon',
    ),
    ReleaseDocumentation(
      docTitle: 'Poka-Yoke Form Validation & Data Integrity Blueprint',
      url: 'https://docs.enterprise.internal/arch/poka-yoke-forms',
      lastUpdatedDate: '2026-08-01',
      accessibilityStatus: 'WCAG 2.2 AA Compliant',
      accessLog: '1,490 views | Granted to Frontend Engineers',
    ),
    ReleaseDocumentation(
      docTitle: 'Incomplete Draft Protocol Document', // Poka-Yoke target: has null/empty fields
      url: '', // Empty field triggering "Not Complete" validation
      lastUpdatedDate: '2026-08-14',
      accessibilityStatus: 'Pending Audit',
      accessLog: '12 views | Restricted',
    ),
  ];

  late String _metadataCompletenessStatus;
  int _incompleteDocCount = 0;

  @override
  void initState() {
    super.initState();
    _validateMetadataCompleteness();
  }

  /// Metadata Completeness Enforcer (Poka-Yoke):
  /// Iterates through document fields. If any atomic field is null or empty, sets status to "Not Complete".
  /// If all are populated across all documents, sets it to "Complete (100%)", fulfilling DAMA-DMBOK2 Metadata Management Standard.
  void _validateMetadataCompleteness() {
    bool hasIncomplete = false;
    int incompleteCount = 0;

    for (final doc in _documents) {
      final map = doc.toMap();
      bool docIsIncomplete = false;
      for (final entry in map.entries) {
        if (entry.value == null || entry.value!.trim().isEmpty) {
          hasIncomplete = true;
          docIsIncomplete = true;
        }
      }
      if (docIsIncomplete) {
        incompleteCount++;
      }
    }

    setState(() {
      _incompleteDocCount = incompleteCount;
      if (hasIncomplete) {
        _metadataCompletenessStatus = 'Not Complete (DAMA-DMBOK2 Audit Warning)';
      } else {
        _metadataCompletenessStatus = 'Complete (100%) - DAMA-DMBOK2 Compliant';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Locked Sizing Scales (WCAG Readability): Restricts textScaler to range 1.0 - 1.2
    return MediaQuery.withClampedTextScaling(
      minScaleFactor: 1.0,
      maxScaleFactor: 1.2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Component Library Documentation Archive'),
          elevation: 2,
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth <= 600;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // DAMA-DMBOK2 Metadata Completeness Header Banner
                  Material(
                    color: _incompleteDocCount > 0
                        ? theme.colorScheme.errorContainer
                        : theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(16.0),
                    elevation: 1,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16.0),
                      splashColor: theme.colorScheme.primary.withValues(alpha: 0.2),
                      highlightColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'DAMA-DMBOK2 Metadata Status: $_metadataCompletenessStatus',
                            ),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Icon(
                              _incompleteDocCount > 0
                                  ? Icons.warning_amber
                                  : Icons.verified,
                              color: _incompleteDocCount > 0
                                  ? theme.colorScheme.error
                                  : theme.colorScheme.onPrimaryContainer,
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'DAMA-DMBOK2 Metadata Completeness Status',
                                    style: theme.textTheme.labelMedium?.copyWith(
                                      color: _incompleteDocCount > 0
                                          ? theme.colorScheme.error
                                          : theme.colorScheme.onPrimaryContainer,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _metadataCompletenessStatus,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: _incompleteDocCount > 0
                                          ? theme.colorScheme.onErrorContainer
                                          : theme.colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Chip(
                              label: Text(
                                '${_documents.length - _incompleteDocCount}/${_documents.length} Valid',
                                style: const TextStyle(fontSize: 11),
                              ),
                              visualDensity: VisualDensity.compact,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Interactive Action Control Bar with explicit InkWell Feedback
                  Row(
                    children: [
                      Material(
                        color: theme.colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          splashColor: theme.colorScheme.primary.withValues(alpha: 0.3),
                          highlightColor: theme.colorScheme.primary.withValues(alpha: 0.15),
                          onTap: _validateMetadataCompleteness,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.refresh,
                                  size: 18,
                                  color: theme.colorScheme.onSecondaryContainer,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Re-audit Metadata',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onSecondaryContainer,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        isMobile
                            ? 'Layout: Mobile (Compact Tabular Cards)'
                            : 'Layout: Web/Tablet (Crisp Bordered DataTable)',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Responsive Architecture: Mobile ListView Cards vs Web/Tablet DataTable
                  if (isMobile)
                    _buildMobileTabularCardList(theme)
                  else
                    _buildCrispBorderedDataTable(theme),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// Web/Tablet View (maxWidth > 600): Full width crisp-bordered DataTable with TableBorder.all
  Widget _buildCrispBorderedDataTable(ThemeData theme) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: SizedBox(
        width: double.infinity,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Table(
            // Crisp Tabular Boundaries using TableBorder.all
            border: TableBorder.all(
              color: theme.dividerColor,
              width: 1.0,
            ),
            columnWidths: const {
              0: FixedColumnWidth(220),
              1: FixedColumnWidth(260),
              2: FixedColumnWidth(130),
              3: FixedColumnWidth(180),
              4: FixedColumnWidth(240),
            },
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              // Header Row
              TableRow(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                ),
                children: const [
                  _TableHeaderCell('Document Title'),
                  _TableHeaderCell('URL'),
                  _TableHeaderCell('Last Updated'),
                  _TableHeaderCell('Accessibility'),
                  _TableHeaderCell('Access Log'),
                ],
              ),
              // Data Rows with InkWell Click Feedback
              ..._documents.map((doc) {
                final map = doc.toMap();
                final isDocComplete =
                    !map.values.any((v) => v == null || v.trim().isEmpty);

                return TableRow(
                  decoration: BoxDecoration(
                    color: isDocComplete
                        ? null
                        : theme.colorScheme.errorContainer.withValues(alpha: 0.15),
                  ),
                  children: [
                    _TableCellInteractive(
                      text: doc.docTitle ?? 'N/A (Missing)',
                      isBold: true,
                    ),
                    _TableCellInteractive(
                      text: (doc.url != null && doc.url!.isNotEmpty)
                          ? doc.url!
                          : 'MISSING_URL_FIELD',
                      isError: doc.url == null || doc.url!.isEmpty,
                    ),
                    _TableCellInteractive(text: doc.lastUpdatedDate ?? 'N/A'),
                    _TableCellInteractive(
                      text: doc.accessibilityStatus ?? 'N/A',
                    ),
                    _TableCellInteractive(text: doc.accessLog ?? 'N/A'),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  /// Mobile View (maxWidth <= 600): Compact ListView of tabular cards
  Widget _buildMobileTabularCardList(ThemeData theme) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _documents.length,
      itemBuilder: (context, index) {
        final doc = _documents[index];
        final map = doc.toMap();
        final isDocComplete =
            !map.values.any((v) => v == null || v.trim().isEmpty);

        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isDocComplete
                  ? theme.colorScheme.outlineVariant
                  : theme.colorScheme.error.withValues(alpha: 0.6),
            ),
          ),
          child: Material(
            color: theme.colorScheme.surface.withValues(alpha: 0.0),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              splashColor: theme.colorScheme.primary.withValues(alpha: 0.2),
              highlightColor: theme.colorScheme.primary.withValues(alpha: 0.1),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Selected Document: ${doc.docTitle ?? "Untitled"}'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isDocComplete ? Icons.article : Icons.error_outline,
                          color: isDocComplete
                              ? theme.colorScheme.primary
                              : theme.colorScheme.error,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            doc.docTitle ?? 'N/A (Missing Title)',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        Chip(
                          label: Text(
                            isDocComplete ? 'VALID' : 'INCOMPLETE',
                            style: TextStyle(
                              fontSize: 10,
                              color: isDocComplete
                                  ? theme.colorScheme.onPrimaryContainer
                                  : theme.colorScheme.error,
                            ),
                          ),
                          backgroundColor: isDocComplete
                              ? theme.colorScheme.primaryContainer
                              : theme.colorScheme.errorContainer,
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    // Table structure inside Mobile Card with crisp borders
                    Table(
                      border: TableBorder.all(
                        color: theme.dividerColor.withValues(alpha: 0.5),
                        width: 1.0,
                      ),
                      children: [
                        _buildMobileTableRow(
                            'URL', doc.url ?? 'MISSING_FIELD', theme,
                            isError: doc.url == null || doc.url!.isEmpty),
                        _buildMobileTableRow(
                            'Last Updated', doc.lastUpdatedDate ?? 'N/A', theme),
                        _buildMobileTableRow('Accessibility',
                            doc.accessibilityStatus ?? 'N/A', theme),
                        _buildMobileTableRow(
                            'Access Log', doc.accessLog ?? 'N/A', theme),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  TableRow _buildMobileTableRow(
      String label, String value, ThemeData theme,
      {bool isError = false}) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(6.0),
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(6.0),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 11,
              color: isError ? theme.colorScheme.error : null,
              fontWeight: isError ? FontWeight.bold : FontWeight.normal,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _TableHeaderCell extends StatelessWidget {
  final String title;
  const _TableHeaderCell(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
      ),
    );
  }
}

class _TableCellInteractive extends StatelessWidget {
  final String text;
  final bool isBold;
  final bool isError;

  const _TableCellInteractive({
    required this.text,
    this.isBold = false,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surface.withValues(alpha: 0.0),
      child: InkWell(
        splashColor: theme.colorScheme.primary.withValues(alpha: 0.2),
        highlightColor: theme.colorScheme.primary.withValues(alpha: 0.1),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text(
            text,
            style: TextStyle(
              fontWeight: isBold || isError ? FontWeight.bold : FontWeight.normal,
              color: isError ? theme.colorScheme.error : null,
              fontSize: 12,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
