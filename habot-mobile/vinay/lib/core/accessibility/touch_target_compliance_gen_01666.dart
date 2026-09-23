// GEN-01666 — Touch Target Compliance Auditor & Engineering Console Widget.
// Identifies all visual icons and interactive elements measuring under 48x48dp, enforces WCAG 2.1 AA (2.5.5) & Material Design 3 accessibility standards, and displays compliance via M3 Elevated Cards with status chips.

import 'package:flutter/material.dart';

/// Mock data representing interactive elements audited for touch target compliance.
final List<TouchTargetAuditItem> mockAuditData = [
  const TouchTargetAuditItem(
    elementId: 'btn_submit_form',
    elementType: 'ElevatedButton',
    widthDp: 48.0,
    heightDp: 48.0,
    isCompliant: true,
  ),
  const TouchTargetAuditItem(
    elementId: 'icon_close_dialog',
    elementType: 'IconButton',
    widthDp: 40.0,
    heightDp: 40.0,
    isCompliant: false,
  ),
  const TouchTargetAuditItem(
    elementId: 'chip_filter_status',
    elementType: 'FilterChip',
    widthDp: 64.0,
    heightDp: 48.0,
    isCompliant: true,
  ),
  const TouchTargetAuditItem(
    elementId: 'link_terms_conditions',
    elementType: 'TextButton',
    widthDp: 48.0,
    heightDp: 32.0,
    isCompliant: false,
  ),
  const TouchTargetAuditItem(
    elementId: 'nav_drawer_menu',
    elementType: 'ListTile',
    widthDp: 56.0,
    heightDp: 56.0,
    isCompliant: true,
  ),
];

/// Data model for a single touch target audit result.
class TouchTargetAuditItem {
  final String elementId;
  final String elementType;
  final double widthDp;
  final double heightDp;
  final bool isCompliant;

  const TouchTargetAuditItem({
    required this.elementId,
    required this.elementType,
    required this.widthDp,
    required this.heightDp,
    required this.isCompliant,
  });
}

/// Service to calculate touch target compliance rate against WCAG 2.1 AA (2.5.5).
class TouchTargetComplianceService {
  static const double floorThreshold = 95.0;
  static const double optimalTarget = 100.0;
  static const double ceilingBoundary = 100.0;
  static const double minimumTouchTargetDp = 48.0;

  /// Returns the compliance rate as a percentage.
  static double calculateComplianceRate(List<TouchTargetAuditItem> items) {
    if (items.isEmpty) return 0.0;
    final compliantCount = items.where((item) => item.isCompliant).length;
    return (compliantCount / items.length) * 100.0;
  }

  /// Returns Pass/Fail based on the floor threshold of 95%.
  static String getQualitativeOutput(double complianceRate) {
    return complianceRate >= floorThreshold ? 'Pass' : 'Fail';
  }

  /// Identifies all elements strictly under 48x48dp.
  static List<TouchTargetAuditItem> identifyNonCompliantElements(
    List<TouchTargetAuditItem> items,
  ) {
    return items
        .where(
          (item) =>
              item.widthDp < minimumTouchTargetDp ||
              item.heightDp < minimumTouchTargetDp,
        )
        .toList();
  }
}

/// Engineering console screen displaying step health via M3 Elevated Card with inline status chip.
/// M3 responsive layout: single-column on mobile (<600dp), multi-column on desktop (>=840dp).
class TouchTargetComplianceScreen extends StatelessWidget {
  const TouchTargetComplianceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double complianceRate =
        TouchTargetComplianceService.calculateComplianceRate(mockAuditData);
    final String status =
        TouchTargetComplianceService.getQualitativeOutput(complianceRate);
    final List<TouchTargetAuditItem> nonCompliant =
        TouchTargetComplianceService.identifyNonCompliantElements(mockAuditData);

    return Scaffold(
      appBar: AppBar(
        title: const Text('GEN-01666: Touch Target Compliance'),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool isDesktop = constraints.maxWidth >= 840;

          if (isDesktop) {
            return _buildMultiColumnLayout(
              context,
              complianceRate,
              status,
              nonCompliant,
            );
          }
          return _buildSingleColumnLayout(
            context,
            complianceRate,
            status,
            nonCompliant,
          );
        },
      ),
    );
  }

  Widget _buildSingleColumnLayout(
    BuildContext context,
    double complianceRate,
    String status,
    List<TouchTargetAuditItem> nonCompliant,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        // Pull-to-refresh triggers manual sync simulation
        await Future.delayed(const Duration(seconds: 1));
      },
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildKpiCard(context, complianceRate, status),
          const SizedBox(height: 16.0),
          _buildAuditList(nonCompliant),
        ],
      ),
    );
  }

  Widget _buildMultiColumnLayout(
    BuildContext context,
    double complianceRate,
    String status,
    List<TouchTargetAuditItem> nonCompliant,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildKpiCard(context, complianceRate, status),
          ),
        ),
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildAuditList(nonCompliant),
          ),
        ),
      ],
    );
  }

  /// M3 Elevated Cards Level 2 (3dp) with M3 Status Chips for health indicators.
  Widget _buildKpiCard(
    BuildContext context,
    double complianceRate,
    String status,
  ) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bool isPass = status == 'Pass';

    return Card(
      elevation: 3.0, // M3 Elevated Cards Level 2 (3dp)
      surfaceTintColor: colorScheme.surfaceTint,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Touch Target Compliance Rate',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Chip(
                  label: Text(status),
                  backgroundColor:
                      isPass ? colorScheme.primaryContainer : colorScheme.errorContainer,
                  labelStyle: TextStyle(
                    color: isPass ? colorScheme.onPrimaryContainer : colorScheme.onErrorContainer,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Text(
              '${complianceRate.toStringAsFixed(1)}%',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: isPass ? colorScheme.primary : colorScheme.error,
                  ),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Floor Threshold: ${TouchTargetComplianceService.floorThreshold}% | Standard: WCAG 2.1 AA (2.5.5) & M3',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuditList(List<TouchTargetAuditItem> nonCompliant) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          child: Text(
            'Elements Under 48x48dp (${nonCompliant.length} found)',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        if (nonCompliant.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('All interactive elements meet the 48x48dp minimum requirement.'),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: nonCompliant.length,
            itemBuilder: (context, index) {
              final item = nonCompliant[index];
              return ListTile(
                leading: const Icon(Icons.warning_amber_rounded, color: Colors.orange),
                title: Text(item.elementId),
                subtitle: Text('${item.elementType} • ${item.widthDp}x${item.heightDp}dp'),
                trailing: const Text('Fail', style: TextStyle(color: Colors.red)),
              );
            },
          ),
      ],
    );
  }
}
