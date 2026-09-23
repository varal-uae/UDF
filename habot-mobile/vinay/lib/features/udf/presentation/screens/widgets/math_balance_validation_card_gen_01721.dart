// GEN-01721 — Mathematical Balance Validation Status Card.
// M3 Elevated Card displaying data input validation state (mathematical balance vs string formatting) with status chips, 48x48dp touch targets, and responsive single/multi-column layout.

import 'package:flutter/material.dart';

enum ValidationStatus { complete, partial, notComplete }

class MathBalanceValidationInput {
  final String inputId;
  final String inputName;
  final String validationType;
  final double accuracyPercent;
  final ValidationStatus status;
  final DateTime lastValidated;

  const MathBalanceValidationInput({
    required this.inputId,
    required this.inputName,
    required this.validationType,
    required this.accuracyPercent,
    required this.status,
    required this.lastValidated,
  });
}

final List<MathBalanceValidationInput> mockValidationData = [
  const MathBalanceValidationInput(
    inputId: 'INP-001',
    inputName: 'Transaction Ledger Amount',
    validationType: 'Strict Mathematical Balance',
    accuracyPercent: 99.99,
    status: ValidationStatus.complete,
    lastValidated: DateTime(2026, 9, 23, 10, 15),
  ),
  const MathBalanceValidationInput(
    inputId: 'INP-002',
    inputName: 'User Reference Code',
    validationType: 'Standard String Formatting',
    accuracyPercent: 100.0,
    status: ValidationStatus.complete,
    lastValidated: DateTime(2026, 9, 23, 10, 15),
  ),
  const MathBalanceValidationInput(
    inputId: 'INP-003',
    inputName: 'Tax Calculation Base',
    validationType: 'Strict Mathematical Balance',
    accuracyPercent: 99.4,
    status: ValidationStatus.partial,
    lastValidated: DateTime(2026, 9, 23, 10, 14),
  ),
  const MathBalanceValidationInput(
    inputId: 'INP-004',
    inputName: 'ISO Currency Payload',
    validationType: 'Standard String Formatting',
    accuracyPercent: 85.0,
    status: ValidationStatus.notComplete,
    lastValidated: DateTime(2026, 9, 23, 10, 10),
  ),
];

class MathBalanceValidationCardGen01721 extends StatelessWidget {
  final MathBalanceValidationInput input;
  final VoidCallback? onDrillDown;

  const MathBalanceValidationCardGen01721({
    super.key,
    required this.input,
    this.onDrillDown,
  });

  Color _statusColor(BuildContext context, ValidationStatus status) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (status) {
      case ValidationStatus.complete:
        return colorScheme.primary;
      case ValidationStatus.partial:
        return colorScheme.tertiary;
      case ValidationStatus.notComplete:
        return colorScheme.error;
    }
  }

  String _statusLabel(ValidationStatus status) {
    switch (status) {
      case ValidationStatus.complete:
        return 'Complete';
      case ValidationStatus.partial:
        return 'Partial';
      case ValidationStatus.notComplete:
        return 'Not Complete';
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 3.0, // M3 Elevated Cards Level 2 (3dp)
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onDrillDown,
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
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
                      input.inputName,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Chip(
                    label: Text(
                      _statusLabel(input.status),
                      style: textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    backgroundColor: _statusColor(context, input.status),
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
              Text(
                'ID: ${input.inputId}',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                'Type: ${input.validationType}',
                style: textTheme.bodyMedium,
              ),
              const SizedBox(height: 4.0),
              Text(
                'Accuracy: ${input.accuracyPercent.toStringAsFixed(2)}%',
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: input.accuracyPercent >= 99.5
                      ? colorScheme.primary
                      : colorScheme.error,
                ),
              ),
              const SizedBox(height: 12.0),
              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  height: 48.0, // 48x48dp touch target
                  width: 48.0,
                  child: IconButton(
                    icon: const Icon(Icons.open_in_new),
                    tooltip: 'Drill-down details',
                    onPressed: onDrillDown,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MathBalanceValidationDashboardGen01721 extends StatefulWidget {
  const MathBalanceValidationDashboardGen01721({super.key});

  @override
  State<MathBalanceValidationDashboardGen01721> createState() =>
      _MathBalanceValidationDashboardGen01721State();
}

class _MathBalanceValidationDashboardGen01721State
    extends State<MathBalanceValidationDashboardGen01721> {
  late List<MathBalanceValidationInput> _data;

  @override
  void initState() {
    super.initState();
    _data = mockValidationData;
  }

  Future<void> _handleRefresh() async {
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() {
      _data = List.from(mockValidationData);
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Validation data synced successfully.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  int _calculateCrossAxisCount(double width) {
    if (width < 600) return 1; // Single-column mobile
    if (width < 840) return 2; // Multi-column tablet
    return 3; // Multi-panel desktop
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Input Validation Console'),
        centerTitle: false,
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount =
                _calculateCrossAxisCount(constraints.maxWidth);
            return GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: crossAxisCount == 1 ? 2.8 : 1.8,
              ),
              itemCount: _data.length,
              itemBuilder: (context, index) {
                final item = _data[index];
                return MathBalanceValidationCardGen01721(
                  input: item,
                  onDrillDown: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (ctx) => Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Configuration: ${item.inputName}',
                              style: Theme.of(ctx).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 16.0),
                            Text('Reference ID: ${item.inputId}'),
                            Text('Validation Type: ${item.validationType}'),
                            Text(
                                'Accuracy Threshold: 99.5% | Actual: ${item.accuracyPercent}%'),
                            Text(
                                'Standard: ISO/IEC 27035:2016 & OWASP Standards'),
                            const SizedBox(height: 24.0),
                            SizedBox(
                              width: double.infinity,
                              height: 48.0,
                              child: FilledButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('Close'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
