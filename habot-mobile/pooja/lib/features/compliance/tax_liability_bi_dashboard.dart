/*
 * GEN-01568 — Display monthly tax liabilities, invoice totals, and compliance verification audit logs on legal BI dashboards.
 * 
 * Global Reference ID: GEN-01568
 * Atomic Steps Reference ID: GEN-01568
 * Setup Step (Action): Display monthly tax liabilities, invoice totals, and compliance verification audit logs on legal BI dashboards.
 * Setup Step Description: Users interact with this step exclusively through the mobile engineering console. Read-only M3 KPI cards with deep-link drill-down.
 * S.No: 418 | Sequence Order: 18277 | Assigned Team: Pooja
 * 
 * AUDIT NOTICE & BOUNDARY TARGETS:
 * Metric Name: Legal BI Data Sync Latency
 * - Floor Boundary: <1 hour | Optimal Target: <5 minutes | Ceiling Boundary: <24 hours
 * - Best Qualitative Output: Good / Average / Poor (Best = Good)
 * - Standard: Modern Data Stack SLA Benchmark (dbt/Fivetran)
 * - Data Collected: Display monthly tax liabilities, invoice totals, and compliance verification audit…; Completion Status ('Good/Average/Poor'); Action/Event Timestamp; User/Session ID
 * 
 * Mobile-First & Responsive UX/UI Decisions:
 *   - 3-tier M3 responsive breakpoint adaptation: Compact (<600dp), Medium (600-839dp), Expanded (>=840dp).
 *   - Strict touch target >= 48x48dp on all triggers.
 *   - Adheres to 4px metric grid spacing tokens.
 *   - Telemetry log export via toExecutionLogJson().
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

abstract final class TaxLiabilityBiDashboardTokens {
  static const Color brandPrimary = Color(0xFF2E86C1);
  static const Color brandSecondary = Color(0xFF1B4F72);
  static const Color neutralBackground = Color(0xFFF8F9FA);
  static const Color neutralSurface = Color(0xFFFFFFFF);
  static const Color neutralBorder = Color(0xFFD5D8DC);
  static const Color textPrimary = Color(0xFF1C2833);
  static const Color textSecondary = Color(0xFF566573);

  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFED6C02);
  static const Color error = Color(0xFFB3261E);
  static const Color lightSurfaceVariant = Color(0xFFE7E0EC);

  static const double level0 = 0.0;
  static const double level1 = 1.0;
  static const double level2 = 3.0;

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;

  static const EdgeInsets paddingSm = EdgeInsets.all(sm);
  static const EdgeInsets paddingMd = EdgeInsets.all(md);
  static const EdgeInsets paddingLg = EdgeInsets.all(lg);

  static const Widget vGapSm = SizedBox(height: sm);
  static const Widget vGapMd = SizedBox(height: md);
  static const Widget vGapLg = SizedBox(height: lg);
  static const Widget hGapSm = SizedBox(width: sm);
  static const Widget hGapMd = SizedBox(width: md);
}

class TaxAuditRecordItem {
  final String invoiceNo;
  final String date;
  final double subtotal;
  final double taxAmount;
  final String taxType;
  final String complianceHash;

  const TaxAuditRecordItem({
    required this.invoiceNo,
    required this.date,
    required this.subtotal,
    required this.taxAmount,
    required this.taxType,
    required this.complianceHash,
  });
}

class TaxLiabilityBiDashboard extends StatefulWidget {
  const TaxLiabilityBiDashboard({super.key});

  @override
  State<TaxLiabilityBiDashboard> createState() => _TaxLiabilityBiDashboardState();
}

class _TaxLiabilityBiDashboardState extends State<TaxLiabilityBiDashboard> {
  String _selectedMonth = 'August 2026';
  final double _monthlyTaxLiability = 42890.50;
  final double _grossInvoiceTotal = 248600.00;
  final int _invoiceCount = 1340;

  final List<TaxAuditRecordItem> _auditLogs = const [
    TaxAuditRecordItem(invoiceNo: 'INV-2026-8812', date: '2026-08-28', subtotal: 12450.00, taxAmount: 2241.00, taxType: 'GST (18%)', complianceHash: '0x882a...91f'),
    TaxAuditRecordItem(invoiceNo: 'INV-2026-8811', date: '2026-08-28', subtotal: 8200.00, taxAmount: 1640.00, taxType: 'VAT (20%)', complianceHash: '0x993b...12c'),
    TaxAuditRecordItem(invoiceNo: 'INV-2026-8810', date: '2026-08-27', subtotal: 45000.00, taxAmount: 4050.00, taxType: 'State Sales (9%)', complianceHash: '0xaa1c...44e'),
    TaxAuditRecordItem(invoiceNo: 'INV-2026-8809', date: '2026-08-27', subtotal: 15300.00, taxAmount: 2754.00, taxType: 'GST (18%)', complianceHash: '0xdd4e...78a'),
  ];

  void _exportTelemetry() {
    final telemetryJson = {
      'step_code': 'GEN-01568',
      'action': 'Display monthly tax liabilities, invoice totals, and compliance verification audit logs on legal BI dashboards.',
      'month': _selectedMonth,
      'total_tax_liability': _monthlyTaxLiability,
      'gross_invoices': _grossInvoiceTotal,
      'invoice_count': _invoiceCount,
      'compliance_status': 'Verified 100%',
      'completion_status': 'Good',
      'timestamp': DateTime.now().toUtc().toIso8601String(),
      'session_id': 'USR-LEGAL-BI-18277',
    };
    Clipboard.setData(ClipboardData(text: telemetryJson.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Legal BI Telemetry log copied to clipboard!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: TaxLiabilityBiDashboardTokens.paddingMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Card
          Card(
            elevation: TaxLiabilityBiDashboardTokens.level2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: TaxLiabilityBiDashboardTokens.paddingMd,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: TaxLiabilityBiDashboardTokens.brandPrimary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.account_balance, color: TaxLiabilityBiDashboardTokens.brandPrimary, size: 28),
                      ),
                      TaxLiabilityBiDashboardTokens.hGapMd,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'GEN-01568: Legal BI Tax Dashboard',
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Monthly Tax Liabilities, Invoice Totals & Audit Logs',
                              style: theme.textTheme.bodySmall?.copyWith(color: TaxLiabilityBiDashboardTokens.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      DropdownButton<String>(
                        value: _selectedMonth,
                        underline: const SizedBox.shrink(),
                        icon: const Icon(Icons.arrow_drop_down, size: 20),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedMonth = val);
                        },
                        items: const [
                          DropdownMenuItem(value: 'August 2026', child: Text('Aug 2026', style: TextStyle(fontSize: 12))),
                          DropdownMenuItem(value: 'July 2026', child: Text('Jul 2026', style: TextStyle(fontSize: 12))),
                          DropdownMenuItem(value: 'June 2026', child: Text('Jun 2026', style: TextStyle(fontSize: 12))),
                        ],
                      ),
                    ],
                  ),
                  TaxLiabilityBiDashboardTokens.vGapMd,

                  // Summary Metric Row
                  Row(
                    children: [
                      _buildMetricTile('Tax Liability', '\$42.8K', TaxLiabilityBiDashboardTokens.error, 'Pending Remittance'),
                      TaxLiabilityBiDashboardTokens.hGapSm,
                      _buildMetricTile('Gross Invoices', '\$248.6K', TaxLiabilityBiDashboardTokens.brandPrimary, '1,340 Invoices'),
                      TaxLiabilityBiDashboardTokens.hGapSm,
                      _buildMetricTile('Audit Health', '100%', TaxLiabilityBiDashboardTokens.success, 'Fully Reconciled'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          TaxLiabilityBiDashboardTokens.vGapMd,

          // Audit Trail List Card
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: TaxLiabilityBiDashboardTokens.paddingMd,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Compliance Verification Audit Logs', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Text('$_selectedMonth Stream', style: const TextStyle(fontSize: 11, color: TaxLiabilityBiDashboardTokens.textSecondary)),
                    ],
                  ),
                  TaxLiabilityBiDashboardTokens.vGapSm,
                  ..._auditLogs.map((log) => _buildAuditRow(log, colorScheme)),
                ],
              ),
            ),
          ),
          TaxLiabilityBiDashboardTokens.vGapMd,

          // Modern Data Stack Benchmark Card
          Card(
            elevation: 0,
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: TaxLiabilityBiDashboardTokens.paddingMd,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Modern Data Stack SLA Benchmark (dbt/Fivetran)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  TaxLiabilityBiDashboardTokens.vGapSm,
                  const Text(
                    'Tax liability transformations execute every 30 seconds. Legal and regulatory BI reports remain strictly reconciled within <5 minute SLA target.',
                    style: TextStyle(fontSize: 12, color: TaxLiabilityBiDashboardTokens.textSecondary),
                  ),
                  TaxLiabilityBiDashboardTokens.vGapSm,
                  Row(
                    children: [
                      const Icon(Icons.verified, size: 16, color: TaxLiabilityBiDashboardTokens.success),
                      const SizedBox(width: 6),
                      Text('Floor: <1h | Optimal Target: <5m (Achieved: 48s)', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          TaxLiabilityBiDashboardTokens.vGapMd,

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(48, 48),
                  ),
                  icon: const Icon(Icons.download_for_offline_outlined, size: 18),
                  label: const Text('Download Tax Pack (CSV)'),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Tax pack generated with immutable cryptographic audit seal.'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ),
              TaxLiabilityBiDashboardTokens.hGapSm,
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(48, 48),
                  backgroundColor: TaxLiabilityBiDashboardTokens.brandPrimary,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.file_upload_outlined, size: 18),
                label: const Text('Export Telemetry'),
                onPressed: _exportTelemetry,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile(String title, String val, Color color, String subtitle) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontSize: 11, color: TaxLiabilityBiDashboardTokens.textSecondary, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(val, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: color)),
            const SizedBox(height: 2),
            Text(subtitle, style: TextStyle(fontSize: 10, color: color.withValues(alpha: 0.8))),
          ],
        ),
      ),
    );
  }

  Widget _buildAuditRow(TaxAuditRecordItem log, ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(log.invoiceNo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: TaxLiabilityBiDashboardTokens.brandPrimary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                      child: Text(log.taxType, style: const TextStyle(fontSize: 10, color: TaxLiabilityBiDashboardTokens.brandPrimary, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text('Date: ${log.date} • Seal: ${log.complianceHash}', style: const TextStyle(fontSize: 10, color: TaxLiabilityBiDashboardTokens.textSecondary)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('\$${log.subtotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              Text('Tax: \$${log.taxAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 11, color: TaxLiabilityBiDashboardTokens.error, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: TaxLiabilityBiDashboard(),
          ),
        ),
      ),
    ),
  );
}
