// SIDM-006-07 — DataEntryCard Widget for Mobile System Profile Configuration.
// Implements collapsible accordion panels, 48x48dp hit targets, loading placeholders, high-contrast text, and warning typography per Material 3 standards. Includes mock configuration data.

import 'package:flutter/material.dart';

enum ConfigType { string, number, boolean }

enum ValidationStatus { valid, invalid, pending }

class ConfigurationItem {
  final String key;
  final String value;
  final ConfigType type;
  final ValidationStatus validationStatus;
  final DateTime timestamp;

  const ConfigurationItem({
    required this.key,
    required this.value,
    required this.type,
    required this.validationStatus,
    required this.timestamp,
  });
}

const List<ConfigurationItem> kMockConfigurations = [
  ConfigurationItem(
    key: 'cloud_env_location',
    value: 'us-east-1-parent-trace',
    type: ConfigType.string,
    validationStatus: ValidationStatus.valid,
    timestamp: null,
  ),
  ConfigurationItem(
    key: 'revenue_margin_trend',
    value: '-4.2%',
    type: ConfigType.string,
    validationStatus: ValidationStatus.invalid,
    timestamp: null,
  ),
  ConfigurationItem(
    key: 'cluster_server_whitelist',
    value: 'node-01,node-02,node-03',
    type: ConfigType.string,
    validationStatus: ValidationStatus.valid,
    timestamp: null,
  ),
  ConfigurationItem(
    key: 'timeout_threshold_ms',
    value: '5000',
    type: ConfigType.number,
    validationStatus: ValidationStatus.pending,
    timestamp: null,
  ),
];

class DataEntryCardSidm00607 extends StatefulWidget {
  final List<ConfigurationItem> configurations;
  final bool isLoading;

  const DataEntryCardSidm00607({
    super.key,
    this.configurations = kMockConfigurations,
    this.isLoading = false,
  });

  @override
  State<DataEntryCardSidm00607> createState() => _DataEntryCardSidm00607State();
}

class _DataEntryCardSidm00607State extends State<DataEntryCardSidm00607>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TabBar(
            controller: _tabController,
            labelColor: colorScheme.primary,
            unselectedLabelColor: colorScheme.onSurfaceVariant,
            indicatorColor: colorScheme.primary,
            tabs: const [
              Tab(text: 'Revenue'),
              Tab(text: 'Expense'),
            ],
          ),
          SizedBox(
            height: 400,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildConfigList(theme),
                _buildConfigList(theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfigList(ThemeData theme) {
    if (widget.isLoading) {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: widget.configurations.length,
        itemBuilder: (context, index) => _buildLoadingPlaceholder(),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: widget.configurations.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = widget.configurations[index];
        return _ConfigurationAccordion(
          item: item,
          theme: theme,
        );
      },
    );
  }

  Widget _buildLoadingPlaceholder() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}

class _ConfigurationAccordion extends StatelessWidget {
  final ConfigurationItem item;
  final ThemeData theme;

  const _ConfigurationAccordion({
    required this.item,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final isWarning = item.validationStatus == ValidationStatus.invalid &&
        item.key.toLowerCase().contains('trend');

    final titleStyle = theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w600,
      color: isWarning ? theme.colorScheme.error : theme.colorScheme.onSurface,
    );

    final subtitleStyle = theme.textTheme.bodyLarge?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
      fontWeight: FontWeight.w500,
    );

    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
      minTileHeight: 48,
      title: Text(
        item.key.replaceAll('_', ' ').toUpperCase(),
        style: titleStyle,
      ),
      subtitle: Text(
        item.value,
        style: isWarning
            ? subtitleStyle?.copyWith(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.bold,
              )
            : subtitleStyle,
      ),
      children: [
        _buildDetailRow('Type', item.type.name.toUpperCase()),
        const SizedBox(height: 8),
        _buildDetailRow(
          'Validation',
          item.validationStatus.name.toUpperCase(),
          valueColor: item.validationStatus == ValidationStatus.valid
              ? Colors.green
              : item.validationStatus == ValidationStatus.invalid
                  ? theme.colorScheme.error
                  : Colors.orange,
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerRight,
          child: SizedBox(
            width: 48,
            height: 48,
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit Configuration',
              style: IconButton.styleFrom(
                minimumSize: const Size(48, 48),
                tapTargetSize: MaterialTapTargetSize.padded,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: valueColor ?? theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}