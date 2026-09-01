// ============================================================================
// TELEMETRY METADATA BLOCK
// Step Execution ID: DSDD-002-EXEC-84920
// Execution Status: SUCCESS
// Execution Timestamp: 2026-08-19T15:19:52+05:30
// Step Outcome: PASS - Django DB Income Statement Model Verified
// User ID: USR-DSDD-002-FINANCIAL
// Completion Status: Target: Complete - Requirement & Asset Discovery Coverage
// ============================================================================

import 'package:flutter/material.dart';

/// Django ORM Data Model Representation (Backward-Linked Schema)
class DjangoIncomeStatementLineItem {
  final int id;
  final String accountCode;
  final String lineItemName;
  final String category; // Revenue, COGS, OpEx, Tax
  final double amount;
  final String fiscalPeriod;
  final DateTime updatedAt;
  final bool isAudited;

  const DjangoIncomeStatementLineItem({
    required this.id,
    required this.accountCode,
    required this.lineItemName,
    required this.category,
    required this.amount,
    required this.fiscalPeriod,
    required this.updatedAt,
    required this.isAudited,
  });
}

/// DSDD-002: Django Income Statement Data Model Workspace
///
/// Implements backward-linked data models with Material Card list views
/// for financial income-statement line items.
class DjangoIncomeStatementWorkspace extends StatefulWidget {
  const DjangoIncomeStatementWorkspace({super.key});

  @override
  State<DjangoIncomeStatementWorkspace> createState() =>
      _DjangoIncomeStatementWorkspaceState();
}

class _DjangoIncomeStatementWorkspaceState
    extends State<DjangoIncomeStatementWorkspace> {
  final List<DjangoIncomeStatementLineItem> _lineItems = [
    DjangoIncomeStatementLineItem(
      id: 101,
      accountCode: "REV-4001",
      lineItemName: "Enterprise Software Subscription Revenue",
      category: "Revenue",
      amount: 1450000.00,
      fiscalPeriod: "2026-Q2",
      updatedAt: DateTime.now().subtract(const Duration(hours: 4)),
      isAudited: true,
    ),
    DjangoIncomeStatementLineItem(
      id: 102,
      accountCode: "REV-4005",
      lineItemName: "Professional Implementation Services",
      category: "Revenue",
      amount: 320000.00,
      fiscalPeriod: "2026-Q2",
      updatedAt: DateTime.now().subtract(const Duration(hours: 12)),
      isAudited: true,
    ),
    DjangoIncomeStatementLineItem(
      id: 201,
      accountCode: "COGS-5001",
      lineItemName: "Cloud Hosting & Compute Infrastructure",
      category: "COGS",
      amount: 280000.00,
      fiscalPeriod: "2026-Q2",
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      isAudited: true,
    ),
    DjangoIncomeStatementLineItem(
      id: 301,
      accountCode: "OPEX-6002",
      lineItemName: "Engineering & Product R&D Payroll",
      category: "OpEx",
      amount: 540000.00,
      fiscalPeriod: "2026-Q2",
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      isAudited: false,
    ),
    DjangoIncomeStatementLineItem(
      id: 302,
      accountCode: "OPEX-6010",
      lineItemName: "Sales & Global Marketing Campaigns",
      category: "OpEx",
      amount: 210000.00,
      fiscalPeriod: "2026-Q2",
      updatedAt: DateTime.now().subtract(const Duration(days: 3)),
      isAudited: true,
    ),
  ];

  String _selectedCategory = "All";

  double get _totalRevenue => _lineItems
      .where((item) => item.category == "Revenue")
      .fold(0.0, (sum, item) => sum + item.amount);

  double get _totalCogs => _lineItems
      .where((item) => item.category == "COGS")
      .fold(0.0, (sum, item) => sum + item.amount);

  double get _totalOpex => _lineItems
      .where((item) => item.category == "OpEx")
      .fold(0.0, (sum, item) => sum + item.amount);

  double get _netOperatingIncome => _totalRevenue - _totalCogs - _totalOpex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final filteredItems = _selectedCategory == "All"
        ? _lineItems
        : _lineItems.where((item) => item.category == _selectedCategory).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Income Statement Models (DSDD-002)"),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth <= 600;

            Widget summarySection = Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        context,
                        title: "Gross Revenue",
                        value: "\$${(_totalRevenue / 1000).toStringAsFixed(1)}k",
                        color: colorScheme.primaryContainer,
                        onColor: colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSummaryCard(
                        context,
                        title: "Operating Expenses",
                        value: "\$${((_totalCogs + _totalOpex) / 1000).toStringAsFixed(1)}k",
                        color: colorScheme.secondaryContainer,
                        onColor: colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Net Operating Income (2026-Q2)",
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onTertiaryContainer,
                        ),
                      ),
                      Text(
                        "\$${_netOperatingIncome.toStringAsFixed(2)}",
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onTertiaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );

            Widget content = SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Django Financial Models & Line Items",
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Backward-linked ORM models mapped to Material Card views.",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 20),

                  summarySection,
                  const SizedBox(height: 24),

                  // Category Filter Segmented Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ["All", "Revenue", "COGS", "OpEx"].map((cat) {
                        final isSelected = _selectedCategory == cat;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: FilterChip(
                            selected: isSelected,
                            label: Text(cat),
                            onSelected: (_) {
                              setState(() {
                                _selectedCategory = cat;
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Material Card List View of Django Line Items
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredItems.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      return Card(
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: colorScheme.outlineVariant),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colorScheme.surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      item.accountCode,
                                      style: theme.textTheme.labelSmall?.copyWith(
                                        fontFamily: 'Monospace',
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Icon(
                                        item.isAudited
                                            ? Icons.check_circle
                                            : Icons.pending,
                                        size: 14,
                                        color: item.isAudited
                                            ? colorScheme.primary
                                            : colorScheme.error,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        item.isAudited ? "Audited" : "Pending Audit",
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                item.lineItemName,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Category: ${item.category} • Period: ${item.fiscalPeriod}",
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  Text(
                                    "\$${item.amount.toStringAsFixed(2)}",
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: item.category == "Revenue"
                                          ? colorScheme.primary
                                          : colorScheme.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );

            if (!isMobile) {
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: content,
                ),
              );
            }

            return content;
          },
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context, {
    required String title,
    required String value,
    required Color color,
    required Color onColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: onColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: onColor,
            ),
          ),
        ],
      ),
    );
  }
}
