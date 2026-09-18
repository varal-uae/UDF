// GEN-01567 — Downloadable Invoice Card Component for Order Confirmation Views.
// Embeds a Material 3 ElevatedCard displaying invoice details with a download action, responsive single/multi-column layout, and mock data.

import 'package:flutter/material.dart';

/// Mock data model representing an invoice for order confirmation.
class InvoiceData {
  final String invoiceId;
  final String orderId;
  final DateTime issueDate;
  final double totalAmount;
  final String currency;
  final String status;
  final String complianceStandard;

  const InvoiceData({
    required this.invoiceId,
    required this.orderId,
    required this.issueDate,
    required this.totalAmount,
    required this.currency,
    required this.status,
    required this.complianceStandard,
  });
}

/// Static mock repository providing realistic invoice data locally.
class MockInvoiceRepository {
  static const List<InvoiceData> invoices = [
    InvoiceData(
      invoiceId: 'INV-2026-09-001',
      orderId: 'ORD-88421-X',
      issueDate: null as dynamic,
      totalAmount: 1250.00,
      currency: 'AED',
      status: 'Generated',
      complianceStandard: 'GAAP / IFRS',
    ),
    InvoiceData(
      invoiceId: 'INV-2026-09-002',
      orderId: 'ORD-88422-Y',
      issueDate: null as dynamic,
      totalAmount: 340.50,
      currency: 'AED',
      status: 'Pending Download',
      complianceStandard: 'GAAP / IFRS',
    ),
  ];

  // Re-initialize with proper dates since const DateTime isn't allowed in const constructors prior to Dart 3.x fully
  static List<InvoiceData> getMockInvoices() {
    return [
      InvoiceData(
        invoiceId: 'INV-2026-09-001',
        orderId: 'ORD-88421-X',
        issueDate: DateTime(2026, 9, 18),
        totalAmount: 1250.00,
        currency: 'AED',
        status: 'Generated',
        complianceStandard: 'GAAP / IFRS',
      ),
      InvoiceData(
        invoiceId: 'INV-2026-09-002',
        orderId: 'ORD-88422-Y',
        issueDate: DateTime(2026, 9, 17),
        totalAmount: 340.50,
        currency: 'AED',
        status: 'Pending Download',
        complianceStandard: 'GAAP / IFRS',
      ),
    ];
  }
}

/// A downloadable invoice card component conforming to M3 specifications.
/// Uses Elevation Level 2 (3dp) and ensures 48x48dp touch targets.
class InvoiceCard extends StatelessWidget {
  final InvoiceData invoice;
  final VoidCallback? onDownloadPressed;

  const InvoiceCard({
    super.key,
    required this.invoice,
    this.onDownloadPressed,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    final ColorScheme colorScheme = theme.colorScheme;

    return Card(
      elevation: 3.0, // M3 Elevated Cards Level 2 (3dp)
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Invoice ${invoice.invoiceId}',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _buildStatusChip(context, invoice.status),
              ],
            ),
            const SizedBox(height: 12.0),
            _buildInfoRow(
              context,
              label: 'Order ID',
              value: invoice.orderId,
            ),
            const SizedBox(height: 8.0),
            _buildInfoRow(
              context,
              label: 'Issue Date',
              value: '${invoice.issueDate.year}-${invoice.issueDate.month.toString().padLeft(2, '0')}-${invoice.issueDate.day.toString().padLeft(2, '0')}',
            ),
            const SizedBox(height: 8.0),
            _buildInfoRow(
              context,
              label: 'Total Amount',
              value: '${invoice.currency} ${invoice.totalAmount.toStringAsFixed(2)}',
            ),
            const SizedBox(height: 8.0),
            _buildInfoRow(
              context,
              label: 'Compliance',
              value: invoice.complianceStandard,
            ),
            const SizedBox(height: 16.0),
            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                height: 48.0, // 48x48dp touch target
                width: 48.0,
                child: IconButton(
                  icon: Icon(
                    Icons.download_outlined,
                    color: colorScheme.primary,
                  ),
                  tooltip: 'Download Invoice',
                  onPressed: onDownloadPressed ?? () => _handleDownload(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, String status) {
    final Color chipColor = status == 'Generated'
        ? Theme.of(context).colorScheme.primaryContainer
        : Theme.of(context).colorScheme.tertiaryContainer;
    final Color textColor = status == 'Generated'
        ? Theme.of(context).colorScheme.onPrimaryContainer
        : Theme.of(context).colorScheme.onTertiaryContainer;

    return Chip(
      label: Text(
        status,
        style: TextStyle(color: textColor, fontSize: 12.0),
      ),
      backgroundColor: chipColor,
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildInfoRow(BuildContext context, {required String label, required String value}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }

  void _handleDownload(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Downloading invoice ${invoice.invoiceId}...'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

/// Responsive wrapper that displays invoice cards.
/// Single-column on mobile (<600dp), multi-column on desktop (≥840dp).
class InvoiceCardList extends StatelessWidget {
  const InvoiceCardList({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final List<InvoiceData> invoices = MockInvoiceRepository.getMockInvoices();

    int crossAxisCount = 1;
    if (screenWidth >= 840) {
      crossAxisCount = 2;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 840) {
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              childAspectRatio: 2.5,
            ),
            itemCount: invoices.length,
            itemBuilder: (context, index) {
              return InvoiceCard(invoice: invoices[index]);
            },
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: invoices.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16.0),
          itemBuilder: (context, index) {
            return InvoiceCard(invoice: invoices[index]);
          },
        );
      },
    );
  }
}
