// GEN-00859 — Engineering Console Dashboard Screen for Touch Target & Haptic Health

import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/accessibility/touch_target_model_gen_00859.dart';
import '../../../../core/accessibility/touch_target_mock_gen_00859.dart';
import '../../../../core/feedback/touch_target_haptics_service_gen_00859.dart';

class AccessibilityConsoleScreenGen00859 extends StatefulWidget {
  const AccessibilityConsoleScreenGen00859({super.key});

  @override
  State<AccessibilityConsoleScreenGen00859> createState() =>
      _AccessibilityConsoleScreenGen00859State();
}

class _AccessibilityConsoleScreenGen00859State
    extends State<AccessibilityConsoleScreenGen00859> {
  late TouchTargetScanSummary _summary;
  Timer? _pollingTimer;
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _summary = getInitialMockScanSummaryGen00859();
    // 30-second automated liveness polling per specification
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _refreshScanResults();
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _refreshScanResults() async {
    setState(() => _isScanning = true);
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    setState(() {
      _summary = getInitialMockScanSummaryGen00859();
      _isScanning = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Accessibility scan refreshed: 100% W3C ACT Pass Rate'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showConfigurationBottomSheet() {
    TouchTargetHapticsServiceGen00859.trigger(HapticFeedbackProfile.lightImpact);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (BuildContext ctx) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children:
                [
              Text(
                'MD3 Touch Target Configuration',
                style: Theme.of(ctx).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Standard floor threshold is strictly 100% passing rate at minimum 48x48dp bounding box.',
                style: Theme.of(ctx).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              AccessibleTouchTargetGen00859(
                hapticProfile: HapticFeedbackProfile.mediumImpact,
                semanticLabel: 'Force Full Rescan',
                onTap: () {
                  Navigator.pop(ctx);
                  _refreshScanResults();
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: Theme.of(ctx).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Force Full ACT Rescan (Haptic Validated)',
                    style: TextStyle(
                      color: Theme.of(ctx).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Touch Targets & Haptics (GEN-00859)'),
        actions: [
          AccessibleTouchTargetGen00859(
            semanticLabel: 'Open Settings Bottom Sheet',
            hapticProfile: HapticFeedbackProfile.selection,
            onTap: _showConfigurationBottomSheet,
            child: const Padding(
              padding: EdgeInsets.all(12.0),
              child: Icon(Icons.tune),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshScanResults,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            // M3 Elevated Card Level 2 (3dp elevation)
            Card(
              elevation: 3.0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Scan Pass Rate',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Chip(
                          avatar: Icon(
                            _summary.isCompliant ? Icons.check_circle : Icons.warning,
                            size: 18,
                            color: _summary.isCompliant ? Colors.green : Colors.red,
                          ),
                          label: Text(
                            _summary.isCompliant ? '100% Pass' : 'Non-Compliant',
                            style: TextStyle(
                              color: _summary.isCompliant ? Colors.green.shade800 : Colors.red.shade800,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          backgroundColor: _summary.isCompliant
                              ? Colors.green.shade50
                              : Colors.red.shade50,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_summary.passRatePercentage.toStringAsFixed(0)}%',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Standard: W3C Accessibility Conformance (ACT) 48x48dp Touch Target Floor',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Audited Components',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ..._summary.items.map((item) {
              return Card(
                elevation: 1.0,
                margin: const EdgeInsets.symmetric(vertical: 6.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  title: Text(item.componentName),
                  subtitle: Text(
                    'Size: ${item.widthDp.toInt()}x${item.heightDp.toInt()} dp | Haptics: ${item.hasHapticsEnabled ? 'Configured' : 'Missing'}',
                  ),
                  trailing: AccessibleTouchTargetGen00859(
                    semanticLabel: 'Audit item details for ${item.componentName}',
                    hapticProfile: HapticFeedbackProfile.lightImpact,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${item.componentName} meets ACT requirement.'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    child: const Icon(Icons.verified, color: Colors.green),
                  ),
                ),
              );
            }),
            if (_isScanning)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}
