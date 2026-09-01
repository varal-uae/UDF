import 'package:flutter/material.dart';

// ============================================================================
// UNIVERSAL COMPONENT LIBRARY METADATA
// ============================================================================
// Library Name:        Universal Component Library
// Library Version:     2.4.0
// Component Count:     144
// Installation Status: Installed & Verified
// Dependency List:     flutter/material.dart
// Library Location Path: lib/ui/ai_output_analytics_view.dart
// ============================================================================

/// AI Model Output Data Model
class AiOutputAnalyticsItem {
  final String id;
  final String prompt;
  final String modelName;
  final String outputSnippet;
  final double confidenceScore;
  final String timestamp;

  const AiOutputAnalyticsItem({
    required this.id,
    required this.prompt,
    required this.modelName,
    required this.outputSnippet,
    required this.confidenceScore,
    required this.timestamp,
  });
}

/// Dynamic LLM Confidence Badge Widget (ARCPE-005-01)
class ConfidenceBadge extends StatelessWidget {
  final double score;
  final VoidCallback? onTap;

  const ConfidenceBadge({
    super.key,
    required this.score,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 1. Dynamic Confidence Logic (State Mapping)
    late final Color backgroundColor;
    late final Color textColor;
    late final String label;

    if (score >= 0.85) {
      backgroundColor = theme.colorScheme.tertiaryContainer;
      textColor = theme.colorScheme.onTertiaryContainer;
      label = 'HIGH (${(score * 100).toInt()}%)';
    } else if (score >= 0.50) {
      backgroundColor = theme.colorScheme.secondaryContainer;
      textColor = theme.colorScheme.onSecondaryContainer;
      label = 'MED (${(score * 100).toInt()}%)';
    } else {
      backgroundColor = theme.colorScheme.errorContainer;
      textColor = theme.colorScheme.onErrorContainer;
      label = 'LOW (${(score * 100).toInt()}%)';
    }

    // 2. Strict Accessibility (48px Optimal Touch Target)
    // Enforcing minWidth: 48.0 and minHeight: 48.0 around the pill container
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 48.0,
        minHeight: 48.0,
      ),
      child: Center(
        child: Material(
          color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.0),
          child: InkWell(
            onTap: onTap ??
                () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Confidence Metric: ${(score * 100).toStringAsFixed(1)}% ($label)',
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
            borderRadius: BorderRadius.circular(100.0),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 6.0,
              ),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(100.0),
                border: Border.all(
                  color: textColor.withValues(alpha: 0.3),
                  width: 1.0,
                ),
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: textColor,
                  fontSize: 12.0,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// AI Output Analytics View Stateful Widget (ARCPE-005-01)
class AiOutputAnalyticsView extends StatefulWidget {
  const AiOutputAnalyticsView({super.key});

  @override
  State<AiOutputAnalyticsView> createState() => _AiOutputAnalyticsViewState();
}

class _AiOutputAnalyticsViewState extends State<AiOutputAnalyticsView> {
  final List<AiOutputAnalyticsItem> _analyticsData = const [
    AiOutputAnalyticsItem(
      id: 'AI-801',
      prompt: 'Summarize system telemetry logs for cluster us-east-1',
      modelName: 'Gemini 1.5 Pro',
      outputSnippet: 'Cluster healthy; memory utilization at 42%, zero pod restarts.',
      confidenceScore: 0.94,
      timestamp: '12:28:10',
    ),
    AiOutputAnalyticsItem(
      id: 'AI-802',
      prompt: 'Predict storage quota growth for next 30 days',
      modelName: 'Gemini 1.5 Flash',
      outputSnippet: 'Estimated storage demand: +14.2 TB based on current trend.',
      confidenceScore: 0.72,
      timestamp: '12:28:35',
    ),
    AiOutputAnalyticsItem(
      id: 'AI-803',
      prompt: 'Extract compliance entity IDs from PDF invoice stream',
      modelName: 'PaLM 2 Enterprise',
      outputSnippet: 'Extracted 12 entities; 3 unverified vendor tax IDs detected.',
      confidenceScore: 0.41,
      timestamp: '12:28:50',
    ),
    AiOutputAnalyticsItem(
      id: 'AI-804',
      prompt: 'Generate automated SQL index optimization recommendation',
      modelName: 'Gemini 1.5 Pro',
      outputSnippet: 'CREATE INDEX idx_user_timestamp ON audit_ledger(user_id, timestamp);',
      confidenceScore: 0.89,
      timestamp: '12:29:01',
    ),
    AiOutputAnalyticsItem(
      id: 'AI-805',
      prompt: 'Classify incoming user feedback sentiment',
      modelName: 'Gemini 1.5 Flash',
      outputSnippet: 'Sentiment: POSITIVE (0.64 satisfaction rating).',
      confidenceScore: 0.62,
      timestamp: '12:29:05',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Output Analytics & Confidence Triage'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth <= 600;

          return Column(
            children: [
              // Header Summary Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'LLM Model Generation Confidence Stream',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      'Dynamic confidence mapping with WCAG 2.1 AA 48px touch targets.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              // 3. Fully Responsive Architecture (ListView vs DataTable)
              Expanded(
                child: isMobile
                    ? _buildMobileListView(theme)
                    : _buildTabletWebDataTable(theme),
              ),
            ],
          );
        },
      ),
    );
  }

  // Mobile View: Vertically scrolling ListView of Cards with ConfidenceBadge in trailing edge
  Widget _buildMobileListView(ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _analyticsData.length,
      itemBuilder: (context, index) {
        final item = _analyticsData[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 12.0),
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
            side: BorderSide(color: theme.colorScheme.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
            child: ListTile(
              title: Text(
                item.prompt,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4.0),
                  Text(
                    'Model: ${item.modelName} • ${item.timestamp}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 6.0),
                  Text(
                    item.outputSnippet,
                    style: theme.textTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              // ConfidenceBadge in trailing edge for rapid vertical scanning
              trailing: ConfidenceBadge(score: item.confidenceScore),
            ),
          ),
        );
      },
    );
  }

  // Tablet/Web View: Clean triage-focused DataTable with dedicated Confidence column
  Widget _buildTabletWebDataTable(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
            side: BorderSide(color: theme.colorScheme.outlineVariant),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Query ID')),
                DataColumn(label: Text('Prompt Query')),
                DataColumn(label: Text('LLM Model')),
                DataColumn(label: Text('Output Snippet')),
                DataColumn(label: Text('LLM Confidence')),
                DataColumn(label: Text('Timestamp')),
              ],
              rows: _analyticsData.map((item) {
                return DataRow(
                  cells: [
                    DataCell(
                      Text(
                        item.id,
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    DataCell(
                      SizedBox(
                        width: 200,
                        child: Text(
                          item.prompt,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    DataCell(Text(item.modelName)),
                    DataCell(
                      SizedBox(
                        width: 250,
                        child: Text(
                          item.outputSnippet,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    // Dedicated Confidence Badges column
                    DataCell(ConfidenceBadge(score: item.confidenceScore)),
                    DataCell(Text(item.timestamp)),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
