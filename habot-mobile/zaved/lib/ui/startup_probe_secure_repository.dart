import 'package:flutter/material.dart';

/// Mock Data Model tracking system loading states & initialization milestones.
class StepExecution {
  final String executionId;
  final String status; // 'pending', 'in_progress', 'completed', 'failed'
  final DateTime timestamp;
  final String outcome;
  final String userId;

  const StepExecution({
    required this.executionId,
    required this.status,
    required this.timestamp,
    required this.outcome,
    required this.userId,
  });
}

/// Mock Data Model for Repository Documents.
class SecureDocument {
  final String id;
  final String title;
  final String category;
  final String classification;
  final bool requiresHighClearance;
  final String contentSnippet;
  final String author;
  final DateTime lastModified;

  const SecureDocument({
    required this.id,
    required this.title,
    required this.category,
    required this.classification,
    required this.requiresHighClearance,
    required this.contentSnippet,
    required this.author,
    required this.lastModified,
  });
}

/// HSCPE-021: Responsive Startup Probe & Secure Document Repository
class StartupProbeSecureRepository extends StatefulWidget {
  const StartupProbeSecureRepository({super.key});

  @override
  State<StartupProbeSecureRepository> createState() =>
      _StartupProbeSecureRepositoryState();
}

class _StartupProbeSecureRepositoryState
    extends State<StartupProbeSecureRepository> {
  final List<String> _complianceAlertLogs = [];

  // Mock Initialization Milestones
  final List<StepExecution> _startupLogs = [
    StepExecution(
      executionId: 'EXEC-001',
      status: 'completed',
      timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      outcome: 'Kernel security modules initialized successfully.',
      userId: 'SYS_ADMIN_01',
    ),
    StepExecution(
      executionId: 'EXEC-002',
      status: 'completed',
      timestamp: DateTime.now().subtract(const Duration(minutes: 12)),
      outcome: 'CMEK Key Rotation handshake verified.',
      userId: 'SEC_DAEMON',
    ),
    StepExecution(
      executionId: 'EXEC-003',
      status: 'in_progress',
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      outcome: 'Ingesting workspace telemetry and scanning documents.',
      userId: 'PROBE_SERVICE',
    ),
    StepExecution(
      executionId: 'EXEC-004',
      status: 'pending',
      timestamp: DateTime.now(),
      outcome: 'Awaiting high-assurance clearance attestation.',
      userId: 'AUDIT_DAEMON',
    ),
    StepExecution(
      executionId: 'EXEC-005',
      status: 'failed',
      timestamp: DateTime.now(),
      outcome: 'Legacy unencrypted socket connection blocked.',
      userId: 'FIREWALL_DAEMON',
    ),
  ];

  // Mock Repository Documents
  final List<SecureDocument> _documents = [
    SecureDocument(
      id: 'DOC-101',
      title: 'Q3 Enterprise Architecture Blueprint',
      category: 'Architecture',
      classification: 'Confidential',
      requiresHighClearance: false,
      contentSnippet:
          'Contains high-level diagrams and microservice event streams for multi-region deployment.',
      author: 'ArchTeam',
      lastModified: DateTime.now().subtract(const Duration(days: 2)),
    ),
    SecureDocument(
      id: 'DOC-102',
      title: 'Core CMEK Encryption Keys & Secret Hash',
      category: 'Security',
      classification: 'Top Secret',
      requiresHighClearance: true,
      contentSnippet: 'Symmetric KMS root keys and cryptographic hashes.',
      author: 'SecOps',
      lastModified: DateTime.now().subtract(const Duration(hours: 4)),
    ),
    SecureDocument(
      id: 'DOC-103',
      title: 'Operational SLA & Uptime Standards',
      category: 'Operations',
      classification: 'Internal',
      requiresHighClearance: false,
      contentSnippet:
          'Defines 99.999% availability targets and automated fallback protocols.',
      author: 'DevOps',
      lastModified: DateTime.now().subtract(const Duration(days: 10)),
    ),
    SecureDocument(
      id: 'DOC-104',
      title: 'Executive Financial Audit & Compliance Log',
      category: 'Governance',
      classification: 'Restricted',
      requiresHighClearance: true,
      contentSnippet:
          'SOX Compliance report and financial transaction ledgers.',
      author: 'ChiefAuditor',
      lastModified: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  void _logComplianceAlert(SecureDocument doc) {
    final alertMessage =
        'HIGH-PRIORITY COMPLIANCE ALERT: User requested clearance access for restricted item "${doc.title}" [ID: ${doc.id}] at ${DateTime.now().toIso8601String()}';
    setState(() {
      _complianceAlertLogs.insert(0, alertMessage);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Access requested for "${doc.title}". Compliance alert logged.'),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Maps status to explicit MD3 Icon widgets & colors.
  Widget _buildStatusIcon(String status) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (status.toLowerCase()) {
      case 'completed':
      case 'success':
        return Icon(Icons.check_circle, color: colorScheme.primary);
      case 'in_progress':
      case 'pending':
        return Icon(Icons.pending, color: colorScheme.tertiary);
      case 'failed':
      case 'error':
        return Icon(Icons.error, color: colorScheme.error);
      default:
        return Icon(Icons.help_outline, color: colorScheme.outline);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Startup Probe & Secure Repository'),
          centerTitle: false,
          elevation: 2,
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth <= 600;

            if (isMobile) {
              // Mobile View (maxWidth <= 600): Rely heavily on TabBarView to toggle
              return Column(
                children: [
                  Container(
                    color: theme.colorScheme.surface,
                    child: const TabBar(
                      tabs: [
                        Tab(
                          icon: Icon(Icons.folder_special),
                          text: 'Secure Repository',
                        ),
                        Tab(
                          icon: Icon(Icons.terminal),
                          text: 'Startup Logs',
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildDocumentGridOrList(isMobile: true),
                        _buildStartupLogsPanel(),
                      ],
                    ),
                  ),
                ],
              );
            } else {
              // Web/Tablet View (maxWidth > 600): Ignore Tabs, render persistent side-panel & right grid
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Side Panel: Persistent Startup Logs
                  SizedBox(
                    width: 340.0,
                    child: Card(
                      margin: const EdgeInsets.all(12.0),
                      elevation: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12.0),
                                topRight: Radius.circular(12.0),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.terminal,
                                  color: theme.colorScheme.onPrimaryContainer,
                                ),
                                const SizedBox(width: 8.0),
                                Text(
                                  'Startup Probe Logs',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color:
                                        theme.colorScheme.onPrimaryContainer,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(child: _buildStartupLogsPanel()),
                        ],
                      ),
                    ),
                  ),
                  // Right Main Content Area: Document Cards GridView
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Secure Document Repository',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Chip(
                                avatar: const Icon(Icons.shield, size: 18),
                                label: Text(
                                  ' clearance-enforced ',
                                  style: theme.textTheme.labelMedium,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12.0),
                          Expanded(
                            child: _buildDocumentGridOrList(isMobile: false),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  /// Renders Milestones using ListView.builder with MD3 icons strictly mapped to status.
  Widget _buildStartupLogsPanel() {
    final theme = Theme.of(context);

    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(12.0),
            itemCount: _startupLogs.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final step = _startupLogs[index];

              return ListTile(
                leading: _buildStatusIcon(step.status),
                title: Text(
                  '${step.executionId} - ${step.status.toUpperCase()}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4.0),
                    Text(step.outcome),
                    const SizedBox(height: 2.0),
                    Text(
                      'User: ${step.userId} | ${step.timestamp.toIso8601String().substring(11, 19)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        if (_complianceAlertLogs.isNotEmpty) ...[
          const Divider(height: 1),
          Container(
            padding: const EdgeInsets.all(8.0),
            color: theme.colorScheme.errorContainer.withValues(alpha: 0.4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.warning, color: theme.colorScheme.error, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'Compliance Alert Log (${_complianceAlertLogs.length})',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _complianceAlertLogs.first,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  /// Renders Document Cards in Grid (Desktop/Tablet) or List (Mobile).
  Widget _buildDocumentGridOrList({required bool isMobile}) {
    if (isMobile) {
      return ListView.builder(
        padding: const EdgeInsets.all(12.0),
        itemCount: _documents.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: _buildDocumentCard(_documents[index]),
          );
        },
      );
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.4,
        crossAxisSpacing: 12.0,
        mainAxisSpacing: 12.0,
      ),
      itemCount: _documents.length,
      itemBuilder: (context, index) {
        return _buildDocumentCard(_documents[index]);
      },
    );
  }

  /// Document Card with Security Poka-Yoke lock banner if high clearance is required.
  Widget _buildDocumentCard(SecureDocument doc) {
    final theme = Theme.of(context);

    if (doc.requiresHighClearance) {
      // Crisp Lock Banner (Security Poka-Yoke): BLOCKS document data and renders lock banner.
      return Card(
        clipBehavior: Clip.antiAlias,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
          side: BorderSide(color: theme.colorScheme.error.withValues(alpha: 0.5)),
        ),
        child: Container(
          color: theme.colorScheme.surfaceContainerHighest,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock,
                size: 44.0,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 8.0),
              Text(
                'HIGH CLEARANCE REQUIRED',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.error,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                'Document Data Blocked [${doc.id}]',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12.0),
              TextButton.icon(
                onPressed: () => _logComplianceAlert(doc),
                icon: const Icon(Icons.gavel),
                label: const Text('Request Access'),
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.error,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Normal Document Data Display
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
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: theme.colorScheme.primaryContainer,
                  foregroundColor: theme.colorScheme.onPrimaryContainer,
                  child: const Icon(Icons.description),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doc.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'ID: ${doc.id} | Class: ${doc.classification}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12.0),
            Text(
              doc.contentSnippet,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium,
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Chip(
                  label: Text(
                    doc.category,
                    style: const TextStyle(fontSize: 11),
                  ),
                  visualDensity: VisualDensity.compact,
                ),
                Text(
                  'Author: ${doc.author}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
