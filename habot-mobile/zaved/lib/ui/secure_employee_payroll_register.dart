// ============================================================================
// ISO 27001 SECURITY TELEMETRY METADATA BLOCK
// Configuration Parameter: IBAN_MASKING_ISO27001_COMPLIANCE
// Current Setting: Mask all characters except final 4 digits with bullet (•)
// Previous Setting: Plaintext IBAN Display (Non-Compliant)
// Change Log: Enforced strict regex masking & mobile modal routing for ISO 27001
// Configuration Timestamp: 2026-08-17T09:42:30Z
// Completion Status: Pass (Target: Pass/Fail based on ISO 27001)
// ============================================================================

import 'package:flutter/material.dart';

/// PCDE-016: Secure Employee Payroll Register & IBAN Masking
class SecureEmployeePayrollRegister extends StatefulWidget {
  const SecureEmployeePayrollRegister({super.key});

  @override
  State<SecureEmployeePayrollRegister> createState() =>
      _SecureEmployeePayrollRegisterState();
}

class EmployeePayrollRecord {
  final String id;
  final String name;
  final String role;
  final String iban;
  final double grossPay;
  final double taxDeduction;
  final double benefitsDeduction;
  final double netPay;

  EmployeePayrollRecord({
    required this.id,
    required this.name,
    required this.role,
    required this.iban,
    required this.grossPay,
    required this.taxDeduction,
    required this.benefitsDeduction,
    required this.netPay,
  });
}

class _SecureEmployeePayrollRegisterState
    extends State<SecureEmployeePayrollRegister> {
  final List<EmployeePayrollRecord> _payrollRecords = [
    EmployeePayrollRecord(
      id: 'EMP-9021',
      name: 'Sarah Jenkins',
      role: 'Principal Systems Architect',
      iban: 'GB82WEST12345698765432',
      grossPay: 12500.00,
      taxDeduction: 3125.00,
      benefitsDeduction: 450.00,
      netPay: 8925.00,
    ),
    EmployeePayrollRecord(
      id: 'EMP-4410',
      name: 'David Chen',
      role: 'Senior Cyber Security Lead',
      iban: 'DE89370400440532013000',
      grossPay: 10800.00,
      taxDeduction: 2700.00,
      benefitsDeduction: 380.00,
      netPay: 7720.00,
    ),
    EmployeePayrollRecord(
      id: 'EMP-7812',
      name: 'Elena Rostova',
      role: 'Staff DevOps Engineer',
      iban: 'FR7630006000011234567890189',
      grossPay: 9600.00,
      taxDeduction: 2400.00,
      benefitsDeduction: 320.00,
      netPay: 6880.00,
    ),
    EmployeePayrollRecord(
      id: 'EMP-3094',
      name: 'Marcus Vance',
      role: 'Lead Cloud Infrastructure Analyst',
      iban: 'NL91ABNA0417164300',
      grossPay: 8900.00,
      taxDeduction: 2135.00,
      benefitsDeduction: 290.00,
      netPay: 6475.00,
    ),
  ];

  EmployeePayrollRecord? _selectedRecord;

  @override
  void initState() {
    super.initState();
    _selectedRecord = _payrollRecords.first;
  }

  /// ISO 27001 Security Helper Function: IBAN Regex Masking
  /// Replaces all alphanumeric characters with bullet (•) EXCEPT for the final 4 digits.
  String maskIban(String iban) {
    final clean = iban.replaceAll(RegExp(r'\s+'), '');
    if (clean.length <= 4) return clean;
    final maskedLength = clean.length - 4;
    final maskedPart = '•' * maskedLength;
    final visiblePart = clean.substring(clean.length - 4);
    return '$maskedPart $visiblePart';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('PCDE-016: Secure Payroll Register'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorScheme.primary),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.shield, size: 16, color: theme.colorScheme.onPrimaryContainer),
                const SizedBox(width: 4),
                Text(
                  'ISO 27001 Compliant',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth <= 600;

          return isMobile
              ? _buildMobileLayout(theme)
              : _buildWideLayout(theme);
        },
      ),
    );
  }

  /// Mobile Layout (maxWidth <= 600)
  /// Tap employee record -> opens detailed salary attributes in showModalBottomSheet
  Widget _buildMobileLayout(ThemeData theme) {
    return ListView.separated(
      padding: const EdgeInsets.all(16.0),
      itemCount: _payrollRecords.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final record = _payrollRecords[index];
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: theme.colorScheme.outlineVariant),
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Text(
              record.name,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(record.role, style: theme.textTheme.bodySmall),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.account_balance,
                        size: 14, color: theme.colorScheme.secondary),
                    const SizedBox(width: 4),
                    Text(
                      maskIban(record.iban),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${record.netPay.toStringAsFixed(2)}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text('Tap details', style: theme.textTheme.labelSmall),
              ],
            ),
            onTap: () => _showMobileDetailsSheet(context, record, theme),
          ),
        );
      },
    );
  }

  /// Tablet / Web Layout (maxWidth > 600)
  /// Renders details in an expanded side panel
  Widget _buildWideLayout(ThemeData theme) {
    return Row(
      children: [
        // Left Column: List of Employee Payroll Records
        Expanded(
          flex: 5,
          child: ListView.separated(
            padding: const EdgeInsets.all(16.0),
            itemCount: _payrollRecords.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final record = _payrollRecords[index];
              final isSelected = _selectedRecord?.id == record.id;
              return Card(
                elevation: isSelected ? 4 : 1,
                color: isSelected
                    ? theme.colorScheme.primaryContainer.withAlpha(120)
                    : null,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outlineVariant,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: ListTile(
                  title: Text(
                    record.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text('${record.role} • ${maskIban(record.iban)}'),
                  trailing: Text(
                    '\$${record.netPay.toStringAsFixed(2)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      _selectedRecord = record;
                    });
                  },
                ),
              );
            },
          ),
        ),

        // Right Column: Side-panel Detail View
        Expanded(
          flex: 6,
          child: Container(
            margin: const EdgeInsets.all(16.0),
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: _selectedRecord == null
                ? const Center(child: Text('Select a record to view details'))
                : _buildDetailPanel(_selectedRecord!, theme),
          ),
        ),
      ],
    );
  }

  /// Detail Salary Attributes Panel with Tooltips & Tints
  Widget _buildDetailPanel(EmployeePayrollRecord record, ThemeData theme) {
    final positiveAccent = theme.colorScheme.primary;
    final warningErrorTint = theme.colorScheme.error;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Text(
                  record.name[0],
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.name,
                      style: theme.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text('${record.role} (${record.id})'),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 32),

          // Security IBAN Banner
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: Row(
              children: [
                const Icon(Icons.lock, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Masked Account (ISO 27001):',
                        style: theme.textTheme.labelSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        maskIban(record.iban),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Text(
            'Financial Breakdown',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // Gross Pay (Positive Accent Tint)
          _buildFinancialRow(
            label: 'Gross Base Pay',
            tooltip: 'Total salary before taxes, health insurance, and retirement deductions.',
            amount: '\$${record.grossPay.toStringAsFixed(2)}',
            textStyle: theme.textTheme.titleMedium?.copyWith(
              color: positiveAccent,
              fontWeight: FontWeight.bold,
            ),
            theme: theme,
          ),
          const SizedBox(height: 12),

          // Tax Deductions (Warning/Error Tint)
          _buildFinancialRow(
            label: 'Tax Withholdings',
            tooltip: 'Federal, State, and Municipal payroll tax obligations.',
            amount: '-\$${record.taxDeduction.toStringAsFixed(2)}',
            textStyle: theme.textTheme.bodyMedium?.copyWith(
              color: warningErrorTint,
              fontWeight: FontWeight.bold,
            ),
            theme: theme,
          ),
          const SizedBox(height: 12),

          // Benefits Deductions (Warning/Error Tint)
          _buildFinancialRow(
            label: 'Benefits & Pension',
            tooltip: 'Health insurance premiums, 401(k) contributions, and group benefits.',
            amount: '-\$${record.benefitsDeduction.toStringAsFixed(2)}',
            textStyle: theme.textTheme.bodyMedium?.copyWith(
              color: warningErrorTint,
              fontWeight: FontWeight.bold,
            ),
            theme: theme,
          ),
          const Divider(height: 28),

          // Net Pay
          _buildFinancialRow(
            label: 'Net Disbursed Amount',
            tooltip: 'Final net amount transferred into employee bank account.',
            amount: '\$${record.netPay.toStringAsFixed(2)}',
            textStyle: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
            theme: theme,
          ),
        ],
      ),
    );
  }

  /// Helper for Financial Rows with Tooltips
  Widget _buildFinancialRow({
    required String label,
    required String tooltip,
    required String amount,
    required TextStyle? textStyle,
    required ThemeData theme,
  }) {
    return Row(
      children: [
        Text(label, style: theme.textTheme.bodyMedium),
        const SizedBox(width: 6),
        Tooltip(
          message: tooltip,
          child: Icon(
            Icons.info_outline,
            size: 16,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const Spacer(),
        Text(amount, style: textStyle),
      ],
    );
  }

  /// Mobile Modal Panel for Employee Detailed Attributes
  void _showMobileDetailsSheet(
    BuildContext context,
    EmployeePayrollRecord record,
    ThemeData theme,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: _buildDetailPanel(record, theme),
        );
      },
    );
  }
}
