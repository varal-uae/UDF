import 'package:flutter/material.dart';

/// 1. 360px Compact Breakpoint Constant
const double kCompactPhoneWidth = 360.0;

/// Rigid Spacing Token Utility Class (RCGLA-028 Requirement 3)
class HabotSpacingTokens {
  /// Enforces exact 16.0 logical pixel increments for horizontal gutters & baselines
  static double get gutterSpacing => 16.0;
  static double get spacing16 => 16.0;
  static double get elementMargin => 16.0;
}

/// Transactional Data Model for Table-to-Card Feed Simulation
class TransactionFeedItem {
  final String transactionId;
  final String timestamp;
  final String sourceNode;
  final String payloadSize;
  final double latencyMs;
  final String status;

  const TransactionFeedItem({
    required this.transactionId,
    required this.timestamp,
    required this.sourceNode,
    required this.payloadSize,
    required this.latencyMs,
    required this.status,
  });
}

/// Mobile Surgical Container Widget (RCGLA-028)
class MobileSurgicalContainer extends StatefulWidget {
  const MobileSurgicalContainer({super.key});

  @override
  State<MobileSurgicalContainer> createState() =>
      _MobileSurgicalContainerState();
}

class _MobileSurgicalContainerState extends State<MobileSurgicalContainer> {
  late List<TransactionFeedItem> _transactionFeed;
  bool _isLoading = true;
  String _layoutConfigStatus = 'Initializing Root State';

  @override
  void initState() {
    super.initState();
    // 5. Root Data Fetching (State Separation): All layout configuration data fetches
    // are conceptually executed inside root container object
    _fetchRootLayoutConfigurationData();
  }

  /// Simulates root container state data fetching & layout configuration
  Future<void> _fetchRootLayoutConfigurationData() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    setState(() {
      _layoutConfigStatus = 'Root Layout Config Loaded';
      _transactionFeed = const [
        TransactionFeedItem(
          transactionId: 'TX-9021',
          timestamp: '12:20:45',
          sourceNode: 'us-east-1a',
          payloadSize: '2.4 MB',
          latencyMs: 14.2,
          status: 'SUCCESS',
        ),
        TransactionFeedItem(
          transactionId: 'TX-9022',
          timestamp: '12:20:49',
          sourceNode: 'us-west-2b',
          payloadSize: '18.1 MB',
          latencyMs: 89.5,
          status: 'SUCCESS',
        ),
        TransactionFeedItem(
          transactionId: 'TX-9023',
          timestamp: '12:20:52',
          sourceNode: 'eu-central-1',
          payloadSize: '512 KB',
          latencyMs: 142.0,
          status: 'WARN_RETRY',
        ),
        TransactionFeedItem(
          transactionId: 'TX-9024',
          timestamp: '12:20:55',
          sourceNode: 'ap-southeast-1',
          payloadSize: '8.9 MB',
          latencyMs: 32.1,
          status: 'SUCCESS',
        ),
      ];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 4. Poka-Yoke (Forced Clipping & Scroll Hierarchy)
    // Horizontal axis scroll is physically blocked using NeverScrollableScrollPhysics
    // and ClipRect to prevent horizontal bleeding or layout overflow bugs.
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mobile Surgical Container (RCGLA-028)'),
      ),
      body: ClipRect(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(), // Forced blocking of horizontal scroll
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            physics: const BouncingScrollPhysics(),
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: HabotSpacingTokens.gutterSpacing,
                  vertical: HabotSpacingTokens.gutterSpacing,
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isCompact360 =
                        constraints.maxWidth <= kCompactPhoneWidth;

                    // 1. 360px Compact Breakpoint (Responsive Reflow)
                    // When width <= 360, ALL content MUST be forced to stack vertically (Column)
                    if (isCompact360) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildBreakpointBanner(theme, isCompact360),
                          SizedBox(height: HabotSpacingTokens.gutterSpacing),
                          _buildControlHeader(theme),
                          SizedBox(height: HabotSpacingTokens.gutterSpacing),
                          _buildCardFeedView(theme),
                        ],
                      );
                    }

                    // For width > 360 (Regular Mobile / Tablet / Web)
                    final isWideView = constraints.maxWidth > 600;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildBreakpointBanner(theme, isCompact360),
                        SizedBox(height: HabotSpacingTokens.gutterSpacing),
                        _buildControlHeader(theme),
                        SizedBox(height: HabotSpacingTokens.gutterSpacing),
                        isWideView
                            ? _buildWideDataTable(theme)
                            : _buildCardFeedView(theme),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBreakpointBanner(ThemeData theme, bool isCompact360) {
    return Container(
      padding: EdgeInsets.all(HabotSpacingTokens.gutterSpacing),
      decoration: BoxDecoration(
        color: isCompact360
            ? theme.colorScheme.tertiaryContainer
            : theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCompact360 ? Icons.smartphone : Icons.devices,
                color: isCompact360
                    ? theme.colorScheme.onTertiaryContainer
                    : theme.colorScheme.onPrimaryContainer,
              ),
              SizedBox(width: HabotSpacingTokens.gutterSpacing),
              Expanded(
                child: Text(
                  isCompact360
                      ? 'COMPACT BREAKPOINT TRIGGERED (<= 360px)'
                      : 'STANDARD DISPLAY MODE (> 360px)',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isCompact360
                        ? theme.colorScheme.onTertiaryContainer
                        : theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6.0),
          Text(
            isCompact360
                ? 'All layout elements forced into single-column vertical stack (flex-direction: column) with rigid 16.0px gutters.'
                : 'Wide multi-column data table collapses automatically into vertical card feed when scaled down.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: isCompact360
                  ? theme.colorScheme.onTertiaryContainer
                  : theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 8.0),
          Chip(
            visualDensity: VisualDensity.compact,
            label: Text(
              'State Fetch: $_layoutConfigStatus',
              style: theme.textTheme.labelSmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlHeader(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Transactional Data Feed Simulation',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        IconButton.filledTonal(
          onPressed: () {
            setState(() {
              _isLoading = true;
            });
            _fetchRootLayoutConfigurationData();
          },
          icon: const Icon(Icons.refresh),
          tooltip: 'Re-trigger Root Data Fetch',
        ),
      ],
    );
  }

  // 2. Table-to-Card Feed Simulation (Compact / Mobile Mode)
  Widget _buildCardFeedView(ThemeData theme) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Column(
      children: _transactionFeed.map((item) {
        return Card(
          margin: EdgeInsets.only(bottom: HabotSpacingTokens.gutterSpacing),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
            side: BorderSide(color: theme.colorScheme.outlineVariant),
          ),
          child: Padding(
            padding: EdgeInsets.all(HabotSpacingTokens.gutterSpacing),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.transactionId,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: item.status == 'SUCCESS'
                            ? theme.colorScheme.primaryContainer
                            : theme.colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item.status,
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: item.status == 'SUCCESS'
                              ? theme.colorScheme.onPrimaryContainer
                              : theme.colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: HabotSpacingTokens.gutterSpacing / 2),
                Row(
                  children: [
                    Icon(Icons.schedule, size: 14, color: theme.colorScheme.outline),
                    const SizedBox(width: 4),
                    Text(item.timestamp, style: theme.textTheme.bodySmall),
                    const Spacer(),
                    Icon(Icons.dns, size: 14, color: theme.colorScheme.outline),
                    const SizedBox(width: 4),
                    Text(item.sourceNode, style: theme.textTheme.bodySmall),
                  ],
                ),
                Divider(height: HabotSpacingTokens.gutterSpacing),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Payload: ${item.payloadSize}',
                        style: theme.textTheme.bodyMedium),
                    Text('Latency: ${item.latencyMs}ms',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        )),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // Multi-Column Table View (Wide View)
  Widget _buildWideDataTable(ThemeData theme) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Transaction ID')),
          DataColumn(label: Text('Timestamp')),
          DataColumn(label: Text('Source Node')),
          DataColumn(label: Text('Payload Size')),
          DataColumn(label: Text('Latency')),
          DataColumn(label: Text('Status')),
        ],
        rows: _transactionFeed.map((item) {
          return DataRow(
            cells: [
              DataCell(Text(item.transactionId,
                  style: const TextStyle(fontWeight: FontWeight.bold))),
              DataCell(Text(item.timestamp)),
              DataCell(Text(item.sourceNode)),
              DataCell(Text(item.payloadSize)),
              DataCell(Text('${item.latencyMs} ms')),
              DataCell(
                Chip(
                  visualDensity: VisualDensity.compact,
                  label: Text(item.status, style: const TextStyle(fontSize: 10)),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
