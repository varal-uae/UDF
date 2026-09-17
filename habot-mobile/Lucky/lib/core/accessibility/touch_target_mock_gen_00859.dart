// GEN-00859 — Mock Data for MD3 Touch Target and Haptic Verification

import 'touch_target_model_gen_00859.dart';

/// Static mock data representing current scan state of MD3 components
final List<TouchTargetAuditItem> mockAuditItemsGen00859 = [
  const TouchTargetAuditItem(
    id: 'TT-001',
    componentName: 'Primary Action Button',
    widthDp: 48.0,
    heightDp: 48.0,
    hasHapticsEnabled: true,
    status: ComplianceStatus.pass,
  ),
  const TouchTargetAuditItem(
    id: 'TT-002',
    componentName: 'Header Navigation Icon',
    widthDp: 48.0,
    heightDp: 48.0,
    hasHapticsEnabled: true,
    status: ComplianceStatus.pass,
  ),
  const TouchTargetAuditItem(
    id: 'TT-003',
    componentName: 'Filter Chip Close Icon',
    widthDp: 48.0,
    heightDp: 48.0,
    hasHapticsEnabled: true,
    status: ComplianceStatus.pass,
  ),
  const TouchTargetAuditItem(
    id: 'TT-004',
    componentName: 'Card Expand Toggle',
    widthDp: 48.0,
    heightDp: 48.0,
    hasHapticsEnabled: true,
    status: ComplianceStatus.pass,
  ),
  const TouchTargetAuditItem(
    id: 'TT-005',
    componentName: 'Bottom Sheet Drag Pill Action',
    widthDp: 52.0,
    heightDp: 48.0,
    hasHapticsEnabled: true,
    status: ComplianceStatus.pass,
  ),
];

/// Factory snapshot for initial state
TouchTargetScanSummary getInitialMockScanSummaryGen00859() {
  return TouchTargetScanSummary(
    scanId: 'SCAN-ACT-GEN00859-2025',
    timestamp: DateTime.now(),
    passRatePercentage: 100.0,
    totalScanned: mockAuditItemsGen00859.length,
    passedCount: mockAuditItemsGen00859.where((i) => i.status == ComplianceStatus.pass).length,
    failedCount: mockAuditItemsGen00859.where((i) => i.status == ComplianceStatus.fail).length,
    items: mockAuditItemsGen00859,
  );
}
