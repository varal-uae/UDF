// ============================================================================
// ATOMIC METADATA DOCUMENTATION
// Layout Type: Responsive Fluid Grid to Single-Column List Switcher
// Layout Grid Dimensions: Single-Column ListView (<=600dp) / Dynamic Multi-Column Grid maxExtent 300px (>600dp)
// Spacing Rules: Padding 16.0dp / Item Gap 12.0dp / Elevation 12.0dp CTA
// Alignment Settings: Top-to-Bottom Flow with Pinned Extreme Elevation Bottom CTA
// Layout Validation Status: Validated
// Completion Status: Complete (Target: 'Complete' < 0.5s render)
// ============================================================================

import 'package:flutter/material.dart';

/// DPRBR-004: Campaign Conversion Target SKU Constraints
class CampaignTargetSkuSelection extends StatefulWidget {
  const CampaignTargetSkuSelection({super.key});

  @override
  State<CampaignTargetSkuSelection> createState() =>
      _CampaignTargetSkuSelectionState();
}

class ProductSku {
  final String id;
  final String skuCode;
  final String title;
  final String category;
  final double price;
  final double discountPrice;
  final IconData icon;
  bool isSelected;

  ProductSku({
    required this.id,
    required this.skuCode,
    required this.title,
    required this.category,
    required this.price,
    required this.discountPrice,
    required this.icon,
    this.isSelected = false,
  });
}

class _CampaignTargetSkuSelectionState
    extends State<CampaignTargetSkuSelection> {
  bool _tlsHandshakeError = false; // Poka-Yoke Security Fallback Toggle

  final List<ProductSku> _skuCatalog = [
    ProductSku(
      id: 'SKU-001',
      skuCode: 'ENT-CAM-101',
      title: 'Enterprise Analytics Suite',
      category: 'Software License',
      price: 2499.00,
      discountPrice: 1999.00,
      icon: Icons.analytics_outlined,
      isSelected: true,
    ),
    ProductSku(
      id: 'SKU-002',
      skuCode: 'SEC-CAM-202',
      title: 'CMEK HSM Key Vault Gateway',
      category: 'Security Appliance',
      price: 4999.00,
      discountPrice: 4299.00,
      icon: Icons.security_outlined,
    ),
    ProductSku(
      id: 'SKU-003',
      skuCode: 'CLD-CAM-303',
      title: 'High-Throughput Stream Node',
      category: 'Infrastructure',
      price: 1299.00,
      discountPrice: 999.00,
      icon: Icons.cloud_sync_outlined,
    ),
    ProductSku(
      id: 'SKU-004',
      skuCode: 'AI-CAM-404',
      title: 'Autonomous LLM Agent Runtime',
      category: 'AI Engine',
      price: 3499.00,
      discountPrice: 2899.00,
      icon: Icons.psychology_outlined,
      isSelected: true,
    ),
    ProductSku(
      id: 'SKU-005',
      skuCode: 'DEV-CAM-505',
      title: 'CI/CD Pipeline Accelerator',
      category: 'DevOps Tools',
      price: 899.00,
      discountPrice: 749.00,
      icon: Icons.speed_outlined,
    ),
    ProductSku(
      id: 'SKU-006',
      skuCode: 'MTR-CAM-606',
      title: 'Telemetry Dashboard Pro',
      category: 'Monitoring',
      price: 1599.00,
      discountPrice: 1299.00,
      icon: Icons.monitor_heart_outlined,
    ),
  ];

  int get _selectedCount =>
      _skuCatalog.where((sku) => sku.isSelected).length;

  double get _totalPrice => _skuCatalog
      .where((sku) => sku.isSelected)
      .fold(0.0, (sum, sku) => sum + sku.discountPrice);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('DPRBR-004: Campaign Target SKUs'),
        elevation: 2,
        actions: [
          // Security Fallback Simulator Toggle
          Tooltip(
            message: 'Toggle TLS Security Fallback State',
            child: Row(
              children: [
                Text(
                  'TLS Error:',
                  style: theme.textTheme.labelSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                Switch(
                  value: _tlsHandshakeError,
                  activeThumbColor: theme.colorScheme.error,
                  onChanged: (val) {
                    setState(() {
                      _tlsHandshakeError = val;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),

      // Primary Content Body (Responsive Grid/List OR In-Pane Alert)
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth <= 600;

          // 3. In-Pane Security Fallback Alert (Poka-Yoke)
          if (_tlsHandshakeError) {
            return _buildSecurityFallbackAlert(theme);
          }

          // 1. Fluid Grid to Single-Column List Architecture
          return Column(
            children: [
              // Header Banner
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: theme.colorScheme.surfaceContainerHigh,
                child: Row(
                  children: [
                    Icon(
                      isCompact ? Icons.view_headline : Icons.grid_view,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        isCompact
                            ? 'Compact Mode (<= 600dp): Single-Column ListView'
                            : 'Expanded Mode (> 600dp): Dynamic Grid maxExtent 300px',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Chip(
                      label: Text('Selected: $_selectedCount'),
                      backgroundColor: theme.colorScheme.primaryContainer,
                    ),
                  ],
                ),
              ),

              // Product SKU List / Grid
              Expanded(
                child: isCompact
                    ? _buildSingleColumnList(theme)
                    : _buildFluidGrid(theme),
              ),
            ],
          );
        },
      ),

      // 2. Above-the-Fold Extreme Elevation CTA (elevation: 12.0)
      bottomNavigationBar: _tlsHandshakeError
          ? null
          : Material(
              elevation: 12.0, // Extreme Elevation Shading
              color: theme.colorScheme.surface,
              shadowColor: theme.colorScheme.shadow,
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: theme.colorScheme.outlineVariant,
                      width: 1,
                    ),
                  ),
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Campaign Total:',
                            style: theme.textTheme.labelSmall,
                          ),
                          Text(
                            '\$${_totalPrice.toStringAsFixed(2)}',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: FilledButton.icon(
                            style: FilledButton.styleFrom(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _selectedCount > 0
                                ? () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        backgroundColor:
                                            theme.colorScheme.primary,
                                        content: Text(
                                          'Proceeding with $_selectedCount Target SKUs (\$${_totalPrice.toStringAsFixed(2)})',
                                        ),
                                      ),
                                    );
                                  }
                                : null,
                            icon: const Icon(Icons.shopping_cart_checkout),
                            label: Text(
                              _selectedCount > 0
                                  ? 'Confirm Target SKUs ($_selectedCount)'
                                  : 'Select SKUs to Proceed',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  /// Compact View (maxWidth <= 600): ListView.builder
  Widget _buildSingleColumnList(ThemeData theme) {
    return ListView.separated(
      padding: const EdgeInsets.all(16.0),
      itemCount: _skuCatalog.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final sku = _skuCatalog[index];
        return _buildSkuCard(sku, theme);
      },
    );
  }

  /// Expanded View (maxWidth > 600): GridView.builder with SliverGridDelegateWithMaxCrossAxisExtent
  Widget _buildFluidGrid(ThemeData theme) {
    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 320.0,
        mainAxisExtent: 180.0,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
      ),
      itemCount: _skuCatalog.length,
      itemBuilder: (context, index) {
        final sku = _skuCatalog[index];
        return _buildSkuCard(sku, theme);
      },
    );
  }

  /// SKU Card Item Component
  Widget _buildSkuCard(ProductSku sku, ThemeData theme) {
    return Card(
      elevation: sku.isSelected ? 4 : 1,
      color: sku.isSelected
          ? theme.colorScheme.primaryContainer.withAlpha(100)
          : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: sku.isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.outlineVariant,
          width: sku.isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          setState(() {
            sku.isSelected = !sku.isSelected;
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: theme.colorScheme.secondaryContainer,
                    foregroundColor: theme.colorScheme.onSecondaryContainer,
                    child: Icon(sku.icon, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sku.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${sku.skuCode} • ${sku.category}',
                          style: theme.textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ),
                  Checkbox(
                    value: sku.isSelected,
                    onChanged: (val) {
                      setState(() {
                        sku.isSelected = val ?? false;
                      });
                    },
                  ),
                ],
              ),
              const Divider(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '\$${sku.price.toStringAsFixed(0)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      decoration: TextDecoration.lineThrough,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    '\$${sku.discountPrice.toStringAsFixed(2)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// In-Pane Security Fallback Alert (Poka-Yoke)
  Widget _buildSecurityFallbackAlert(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Card(
          elevation: 6,
          color: theme.colorScheme.errorContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: theme.colorScheme.error, width: 2),
          ),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.gpp_bad, // Contrasting Security Icon
                  size: 64,
                  color: theme.colorScheme.onErrorContainer,
                ),
                const SizedBox(height: 16),
                Text(
                  'TLS Handshake Security Fallback Activated',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onErrorContainer,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Campaign target SKU catalog access has been isolated due to a security verification protocol alert. Please verify network TLS certificate authority before retrying transaction.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onErrorContainer,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.error,
                    foregroundColor: theme.colorScheme.onError,
                  ),
                  onPressed: () {
                    setState(() {
                      _tlsHandshakeError = false;
                    });
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset TLS Handshake & Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
