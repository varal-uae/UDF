import 'package:flutter/material.dart';

// Core Themes & Models
import 'core/theme/app_theme_wrapper.dart';
import 'core/models/step_item.dart';
import 'core/tokens/spacing_tokens.dart';
import 'core/ui/master_menu_page.dart';

// Core Step Components
import 'core/ui/m3_dense_table.dart';
import 'core/ui/end_document_layout.dart';
import 'core/network/offline_sync_indicator.dart';
import 'core/ui/binary_checklist_stepper.dart';
import 'core/ui/ai_human_split_viewport.dart';
import 'core/interaction/contextual_fab.dart';
import 'core/versioning/context_isolation_panel.dart';
import 'core/interaction/swipe_approval_matrix.dart';
import 'core/ui/floating_callout_overlay.dart';
import 'core/network/sse_status_indicator.dart';
import 'core/network/multi_zone_sync_bar.dart';
import 'core/ui/m3_fluid_media_grid.dart';
import 'core/ui/executive_performance_dashboard.dart';
import 'core/interaction/ab_testing_card_switch.dart';
import 'core/ui/clean_kpi_performance_card.dart';
import 'core/network/bigquery_telemetry_monitor.dart';
import 'core/network/bottleneck_highlight_dashboard.dart';
import 'core/network/finops_budget_dashboard.dart';
import 'core/accessibility/smart_keyboard_field.dart';
import 'core/ui/md3_elevated_success_card.dart';
import 'core/ui/brand_cta_mapping_panel.dart';
import 'core/ui/referral_reward_matrix_panel.dart';
import 'core/accessibility/status_badge_system_panel.dart';
import 'core/compliance/db_linter_entity_panel.dart';
import 'core/compliance/mathematical_vendor_success_panel.dart';
import 'core/compliance/design_compliance_validator_panel.dart';
import 'core/compliance/lineage_trace_test_panel.dart';
import 'core/ui/referral_reward_injection_panel.dart';
import 'core/ui/responsive_nav_rail_panel.dart';
import 'core/compliance/private_package_enforcement_panel.dart';
import 'core/versioning/master_library_lock_panel.dart';
import 'core/interaction/system_verb_icon_panel.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppThemeWrapper(
      initialMode: AppThemeMode.system,
      builder: (context, lightTheme, darkTheme, mode) {
        return MaterialApp(
          title: 'Habot Enterprise Mobile UI Design System',
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: mode,
          debugShowCheckedModeBanner: false,
          home: MasterMenuPage(
            steps: _buildAppStepDirectory(),
            fullStreamBuilder: (context) => const LegacyFullStreamView(),
          ),
        );
      },
    );
  }
}

List<StepItem> _buildAppStepDirectory() {
  // Step 1 mock data
  const rcglaFields = [
    DataFieldDefinition(fieldId: 'F-101', label: 'Customer Name', dataType: 'String', value: 'Acme Corp', isRequired: true),
    DataFieldDefinition(fieldId: 'F-102', label: 'Tax Identification', dataType: 'TaxID', value: 'TX-998822', isRequired: true),
    DataFieldDefinition(fieldId: 'F-103', label: 'Region Code', dataType: 'Enum', value: 'US-EAST-1', isRequired: false),
  ];

  // Step 2 mock data
  final edebsDocument = EndDocumentDefinition(
    documentId: 'DOC-2026-0811',
    title: 'Q3 Financial Auditing Summary',
    author: 'Principal Compliance Officer',
    completionDate: DateTime(2026, 8, 11),
  );

  // Step 4 mock data
  final offboardingSteps = [
    const OffboardingStepItem(id: 'S-1', title: 'Revoke AWS IAM Roles', description: 'Remove permissions from production account', targetSystem: 'AWS Account 88219', isCompleted: true),
    const OffboardingStepItem(id: 'S-2', title: 'Disable GitHub Enterprise SSO', description: 'Revoke org member access', targetSystem: 'GitHub Enterprise', isCompleted: false),
    const OffboardingStepItem(id: 'S-3', title: 'Archive Slack Conversations', description: 'Export workspace history', targetSystem: 'Slack Workspace', isCompleted: false),
  ];

  // Step 5 mock data
  const splitConfig = AiDraftSplitConfig(
    aiSuggestionContent: 'Automated AI Summary: Contract renewal terms verified against compliance policy v4.2.',
    humanEditContent: 'Contract renewal terms verified against compliance policy v4.2 with custom security clause.',
    defaultSplitRatio: 0.5,
  );

  // Step 7 mock data
  const isolationItem = IsolationContextItem(
    targetFieldId: 'CONF-889',
    fieldName: 'API Secret Key',
    croppedAssetUrl: 'https://placeholder.com/crop.png',
    extractedText: 'sk_live_8829910aacc',
  );

  // Step 8 mock data
  final claimsList = [
    const ApprovalClaimItem(claimId: 'CLM-101', employeeName: 'Sarah Connor', amount: '\$450.00', category: 'Travel & Lodging', receiptThumbnailUrl: 'https://placeholder.com/receipt.png'),
    const ApprovalClaimItem(claimId: 'CLM-102', employeeName: 'John Doe', amount: '\$1,200.00', category: 'Software Licenses', receiptThumbnailUrl: 'https://placeholder.com/receipt2.png'),
  ];

  // Step 9 mock data
  const calloutConfig = CalloutOverlayConfig(
    title: 'Security Compliance Notice',
    message: 'All audit documents must be signed using multi-factor biometric key before archival.',
    type: CalloutType.warning,
  );

  // Step 11 mock data
  const haConfig = HaSyncConfig(
    primaryZoneName: 'us-east1-a',
    secondaryZoneName: 'us-east1-b',
    status: HaZoneStatus.primaryActive,
    latencyMs: 18,
    lastHeartbeat: '10s ago',
  );

  // Step 12 mock data
  const mediaList = [
    MediaThumbnailItem(id: 'M-1', title: 'hero_banner.jpg', fileSizeBytes: '1.2 MB'),
    MediaThumbnailItem(id: 'M-2', title: 'product_demo.png', fileSizeBytes: '840 KB'),
    MediaThumbnailItem(id: 'M-3', title: 'architecture_diagram.pdf', fileSizeBytes: '3.4 MB'),
  ];

  // Step 13 mock data
  const execData = ExecutiveSummaryData(
    periodLabel: 'Q3 2026',
    netRevenue: '\$1,420,000.00',
    conversionRate: '4.8%',
    totalOperationalCost: '\$310,000.00',
  );

  // Step 14 mock data
  const abVariants = [
    AbTestVariant(variantId: 'VAR-A', variantName: 'Variant A (Compact)', description: 'Dense single-column layout', conversionRate: 0.048),
    AbTestVariant(variantId: 'VAR-B', variantName: 'Variant B (Fluid)', description: 'Expanded fluid grid layout', conversionRate: 0.062),
  ];

  // Step 15 mock data
  const perfConfig = PerformanceLogConfig(
    zeroTouchConversionRate: '68.4%',
    weeklyVelocityShift: '+12.5%',
  );

  // Step 16 mock data
  final telemetryEvents = [
    TelemetryEvent(eventName: 'user_sign_up', serviceId: 'AUTH-SRV', timestamp: DateTime.now(), userHash: 'usr_882a', latencyMs: 142),
    TelemetryEvent(eventName: 'db_read_query', serviceId: 'DATA-SRV', timestamp: DateTime.now(), userHash: 'usr_993b', latencyMs: 380),
  ];

  // Step 17 mock data
  const bottlenecks = [
    BottleneckEventItem(id: 'B-1', serviceName: 'Telemetry Parsing Engine', description: 'DB Query Latency spike to 450ms', severity: BottleneckSeverity.warning, currentLoadPercentage: 0.82),
  ];

  // Step 18 mock data
  const finopsData = FinOpsCostData(
    dailySpend: '\$1,240.00',
    cumulativeSpend: '\$34,500.00',
    remainingBudget: '\$15,500.00',
    burnRateTrend: '+4.2%',
    loadTimeSeconds: 1.4,
  );

  // Step 20 mock data
  const successRecord = OnboardingSuccessRecord(
    vendorId: 'VND-99218',
    vendorName: 'Global Enterprise Logistics Ltd',
    verificationHash: '0x88f2991a004c',
    timestamp: '2026-08-11 18:45:00 UTC',
    adherenceScorePercentage: 0.98,
  );

  // Step 21 mock data
  const brandCtaRecord = BrandCtaMappingRecord(
    repositoryUrl: 'https://github.com/habot/enterprise-portal.git',
    repositoryBranch: 'main',
    accessRights: 'Read/Write Admin (UI Systems Engineer)',
    commitHistory: 'c8a2b1f (HC-SCH-0081: Token standardization)',
    repositoryVersion: 'v2.4.0-prod',
    cloneStatus: 'Active Cloned',
    completionStatus: 'Complete',
    actionTimestamp: '2026-08-12 15:00:00 UTC',
    userSessionId: 'USR-JOHN-8891',
    mappedFieldsCount: 9,
    totalFieldsCount: 9,
  );

  // Step 22 mock data
  const referralRewardRecord = ReferralRewardMatrixRecord(
    layoutType: 'Adaptive Outlined Grid',
    layoutGridDimensions: '640dp Max-Width / 16dp Padding',
    spacingRules: 'Material M3 16dp Standard',
    alignmentSettings: 'Center / Fluid Stretch',
    layoutValidationStatus: 'Validated & Compliant',
    completionStatus: 'High',
    actionTimestamp: '2026-08-12 16:21:00 UTC',
    userSessionId: 'USR-JOHN-9921',
    tertiaryColorQualityIndex: 1.0,
    floorBoundary: 0.9,
    optimalTarget: 1.0,
    ceilingBoundary: 0.98,
    rowLevelAuditCoverage: 1.0,
    isTenMinuteBufferSatisfied: true,
  );

  const referralTokensList = [
    RewardCreditTokenItem(
      tokenId: 'TOK-REF-101',
      rewardTitle: 'Gold Referral Milestone',
      creditAmount: '\$250.00 Credit',
      tierLevel: 'Tier 1 (Gold)',
    ),
    RewardCreditTokenItem(
      tokenId: 'TOK-REF-102',
      rewardTitle: 'Silver Partner Bonus',
      creditAmount: '\$100.00 Credit',
      tierLevel: 'Tier 2 (Silver)',
    ),
  ];

  // Step 23 mock data
  const statusBadgeRecord = StatusBadgeLibraryRecord(
    libraryName: '@habot-core/status-pill-badge',
    libraryVersion: 'v3.2.0-stable',
    componentCount: '12 Active Badge Components',
    installationStatus: 'Installed & Registered',
    dependencyList: 'flutter_m3_tokens, accessibility_utils',
    libraryLocationPath: 'lib/src/core/widgets/status_pill_badge.dart',
    completionStatus: 'Complete',
    actionTimestamp: '2026-08-12 16:38:00 UTC',
    userSessionId: 'USR-JOHN-7712',
    confirmedAssetsPercentage: 1.0,
    floorBoundary: 0.90,
    optimalTarget: 1.00,
    ceilingBoundary: 1.00,
    wcagContrastRatio: 4.8,
  );

  // Step 24 mock data
  const dbLinterRecord = DbLinterEntityRecord(
    libraryName: '@habot-core/db-linter-rules',
    libraryVersion: 'v1.8.0-linter',
    componentCount: '16 Entity Components',
    installationStatus: 'Active Linter Enforced',
    dependencyList: 'analysis_options, custom_lint',
    libraryLocationPath: 'lib/src/core/utils/db_identifier_linter.dart',
    completionStatus: 'Good (100%)',
    actionTimestamp: '2026-08-12 16:51:00 UTC',
    userSessionId: 'USR-JOHN-6619',
    designSystemAdherenceRate: 1.0,
    floorBoundary: 0.85,
    optimalTarget: 0.95,
    ceilingBoundary: 1.00,
  );

  const entityRecordItemsList = [
    EntityRecordItem(
      entityIdKey: 'USER_ID',
      entityName: 'Registered Customer User',
      maskedUserToken: 'USR-TOK-8891',
      fullInternalReferenceKey: '0x88a29910-user-pk-guid-991',
    ),
    EntityRecordItem(
      entityIdKey: 'VENDOR_ID',
      entityName: 'Global Enterprise Logistics',
      maskedUserToken: 'VND-TOK-9921',
      fullInternalReferenceKey: '0x77b38821-vendor-pk-guid-882',
    ),
  ];

  // Step 25 mock data
  const vendorProofRecord = VendorOnboardingProofRecord(
    libraryName: '@habot-core/vendor-onboarding-success',
    libraryVersion: 'v4.1.0-ddd',
    componentCount: '8 Mathematical Proof Views',
    installationStatus: 'Active Proven & Verified',
    dependencyList: 'crypto_utils, domain_driven_design',
    libraryLocationPath: 'lib/src/steps/edebs_008_15/widgets/mathematical_vendor_success_panel.dart',
    completionStatus: 'Good (100%)',
    actionTimestamp: '2026-08-12 17:03:00 UTC',
    userSessionId: 'USR-JOHN-5521',
    vendorId: 'VND-99218',
    vendorName: 'Global Enterprise Logistics Ltd',
    verificationHash: '0x88f2991a004c99e28f101a002',
    adherenceScorePercentage: 0.98,
    mathematicalProofIndex: 1.0,
    designSystemAdherenceRate: 1.0,
    floorBoundary: 0.85,
    optimalTarget: 0.95,
    ceilingBoundary: 1.00,
  );

  // Step 26 mock data
  const designComplianceRecord = DesignComplianceValidatorRecord(
    objectType: 'LinterEngineRule',
    objectLocationPath: 'devops/ci/DesignComplianceLinterEngine.dart',
    openStatus: 'Active Enforced',
    timestamp: '2026-08-12 17:07:00 UTC',
    fileHandleId: 'HDL-LINT-8891',
    completionStatus: 'Pass',
    actionTimestamp: '2026-08-12 17:07:00 UTC',
    userSessionId: 'USR-JOHN-4410',
    deploymentBuildStabilityRate: 0.999,
    floorBoundary: 0.95,
    optimalTarget: 0.999,
    ceilingBoundary: 1.00,
  );

  const universalUiTemplatesList = [
    UniversalUiTemplateItem(
      templateId: 'TPL-LAYOUT-01',
      templateName: 'Adaptive Flexible Card Layout',
      layoutStrategy: 'LayoutBuilder + Dynamic Flex Scaling',
    ),
    UniversalUiTemplateItem(
      templateId: 'TPL-TYPO-02',
      templateName: 'Material 3 Type Scale Harmony',
      layoutStrategy: 'Google Material 3 Standard Typescale',
    ),
  ];

  // Step 27 mock data
  const lineageTraceRecord = LineageTraceTestRecord(
    stepExecutionId: 'EXEC-TRACE-9981',
    executionStatus: 'Completed Passed',
    executionTimestamp: '2026-08-12 17:12:00 UTC',
    stepOutcome: 'Zero Lineage Anomaly (Score = 0)',
    userId: 'USR-JOHN-3319',
    completionStatus: 'Good (100%)',
    actionTimestamp: '2026-08-12 17:12:00 UTC',
    userSessionId: 'USR-JOHN-3319',
    observabilityAlertCoverage: 1.0,
    floorBoundary: 0.90,
    optimalTarget: 1.00,
    ceilingBoundary: 1.00,
    anomalyScore: 0.0,
  );

  // Step 28 mock data
  const referralRewardInjectionRecord = ReferralRewardInjectionRecord(
    stepExecutionId: 'EXEC-REF-7718',
    executionStatus: 'Completed Active',
    executionTimestamp: '2026-08-12 18:39:00 UTC',
    stepOutcome: 'Referral Reward Injected (56dp FAB Target Compliant)',
    userId: 'USR-JOHN-2219',
    completionStatus: 'Pass (56dp Large FAB)',
    actionTimestamp: '2026-08-12 18:39:00 UTC',
    userSessionId: 'USR-JOHN-2219',
    fabTouchTargetSizeDp: 56.0,
    floorBoundaryDp: 44.0,
    optimalTargetDp: 48.0,
    ceilingBoundaryDp: 56.0,
    referralCode: 'REF-HABOT-2026',
    rewardAmountStr: '\$50.00 Credit',
  );

  // Step 29 mock data
  const responsiveNavRailRecord = ResponsiveNavRailRecord(
    repositoryUrl: 'https://github.com/habot/shared-ui-components.git',
    repositoryBranch: 'main',
    accessRights: 'Read/Write Admin (Lead Layout Architect)',
    commitHistory: 'a991f82 (TNRML-007: 80dp Nav Rail Shell)',
    repositoryVersion: 'v3.5.0-rail',
    cloneStatus: 'Active Cloned & Linked',
    completionStatus: 'Good (1 Click)',
    actionTimestamp: '2026-08-12 18:58:00 UTC',
    userSessionId: 'USR-JOHN-1192',
    navigationClickDepth: 1,
    floorClicks: 1,
    optimalClicks: 2,
    ceilingClicks: 3,
    railWidthDp: 80.0,
    breakpointWidthDp: 600.0,
  );

  // Step 30 mock data
  const privatePackageRecord = PrivatePackageEnforcementRecord(
    repositoryUrl: 'https://pub.habot.internal/packages/flutter_m3_components.git',
    repositoryBranch: 'main',
    accessRights: 'Read/Write Admin (Design System Engineering)',
    commitHistory: 'b441a99 (FEBFL-005: Enforce Private Pub Package)',
    repositoryVersion: 'v5.0.0-private-pub',
    cloneStatus: 'Active Linked & Verified',
    completionStatus: 'Pass (95% Optimal Access)',
    actionTimestamp: '2026-08-12 19:11:00 UTC',
    userSessionId: 'USR-JOHN-9988',
    accessConfirmationRate: 0.95,
    floorBoundary: 0.80,
    optimalTarget: 0.95,
    ceilingBoundary: 1.00,
  );

  // Step 31 mock data
  const masterLibraryLockRecord = MasterLibraryLockRecord(
    repositoryUrl: 'https://github.com/habot/master-component-library.git',
    repositoryBranch: 'release/v6.0.0-locked',
    accessRights: 'Read-Only Developer Distribution (QC Locked)',
    commitHistory: 'f992a10 (EDBAA-015-09: Lock Master Library)',
    repositoryVersion: 'v6.0.0-frozen-release',
    cloneStatus: 'Active Read-Only Locked',
    completionStatus: 'Complete (100%)',
    actionTimestamp: '2026-08-12 19:45:00 UTC',
    userSessionId: 'USR-JOHN-9912',
    processAdherenceRate: 1.0,
    floorBoundary: 0.90,
    optimalTarget: 1.00,
    ceilingBoundary: 1.00,
    isLibraryLockedReadOnly: true,
  );

  const preApprovedModulesList = [
    PreApprovedViewModuleItem(
      moduleId: 'MOD-01',
      moduleName: 'Responsive Navigation Rail Shell',
      targetStepCode: 'TNRML-007',
    ),
    PreApprovedViewModuleItem(
      moduleId: 'MOD-02',
      moduleName: 'Private Pub Package Split-Screen',
      targetStepCode: 'FEBFL-005',
    ),
    PreApprovedViewModuleItem(
      moduleId: 'MOD-03',
      moduleName: 'High-Contrast Mobile Status Badge',
      targetStepCode: 'IS29-SCTAS-007',
    ),
  ];

  // Step 32 mock data
  const systemVerbIconRecord = SystemVerbIconRecord(
    versionNumber: 'v7.1.0-system-verbs',
    versionType: 'Major Verb Matrix Release',
    releaseDate: '2026-08-12',
    versionStatus: 'Active Committed & Locked',
    versionChecksum: 'sha256-a99f102b8812c99',
    completionStatus: 'Good (100%)',
    actionTimestamp: '2026-08-12 19:47:00 UTC',
    userSessionId: 'USR-JOHN-8812',
    singleActionGranularityRate: 1.0,
    floorBoundary: 0.90,
    optimalTarget: 1.00,
    ceilingBoundary: 1.00,
    iconBoundingBoxDp: 24.0,
    touchTargetPhantomPaddingDp: 48.0,
  );

  const systemVerbsList = [
    SystemVerbItem(verbName: 'SAVE', actionDescription: 'Commit Data Changes', iconData: Icons.save),
    SystemVerbItem(verbName: 'DELETE', actionDescription: 'Purge Target Record', iconData: Icons.delete_outline),
    SystemVerbItem(verbName: 'SYNC', actionDescription: 'Sync Storage Data', iconData: Icons.sync),
    SystemVerbItem(verbName: 'EXPORT', actionDescription: 'Export Telemetry Log', iconData: Icons.file_download_outlined),
    SystemVerbItem(verbName: 'REFRESH', actionDescription: 'Refresh Grid State', iconData: Icons.refresh),
    SystemVerbItem(verbName: 'SEARCH', actionDescription: 'Query Index Search', iconData: Icons.search),
    SystemVerbItem(verbName: 'SETTINGS', actionDescription: 'Configure System Tokens', iconData: Icons.settings_outlined),
  ];

  return [
    StepItem(
      stepNumber: 1,
      stepCode: 'RCGLA-014',
      title: 'M3 Dense Data Table',
      description: 'Compact material data grid for high-density enterprise record editing.',
      category: StepCategory.dataAndForms,
      icon: Icons.table_chart,
      builder: (_) => const M3DenseTable(fields: rcglaFields),
    ),
    StepItem(
      stepNumber: 2,
      stepCode: 'EDEBS-032',
      title: 'End Document Summary Layout',
      description: 'Formal document completion summary with metadata badges and download actions.',
      category: StepCategory.dataAndForms,
      icon: Icons.description_outlined,
      builder: (_) => EndDocumentLayout(document: edebsDocument),
    ),
    StepItem(
      stepNumber: 3,
      stepCode: 'BPTR-0498',
      title: 'Offline Sync Status Indicator',
      description: 'Real-time offline queue counter and network connectivity indicator.',
      category: StepCategory.realTimeSync,
      icon: Icons.sync,
      builder: (context) => Card(
        child: Padding(
          padding: AppSpacingTokens.paddingMd,
          child: Column(
            children: [
              const Text('Header Action Bar Sync Preview:'),
              AppSpacingTokens.vGapSm,
              OfflineSyncIndicator(
                syncState: const SyncStateDefinition(
                  status: SyncStatus.online,
                  pendingQueueCount: 0,
                  lastSyncedTimestamp: 'Just Now',
                ),
                onSyncTap: () {},
              ),
            ],
          ),
        ),
      ),
    ),
    StepItem(
      stepNumber: 4,
      stepCode: 'RRCVG-024',
      title: 'Binary Checklist Stepper',
      description: 'Interactive offboarding step-by-step checklist with system verification.',
      category: StepCategory.dataAndForms,
      icon: Icons.rule_folder_outlined,
      builder: (_) => Card(
        child: Padding(
          padding: AppSpacingTokens.paddingMd,
          child: BinaryChecklistStepper(initialSteps: offboardingSteps),
        ),
      ),
    ),
    StepItem(
      stepNumber: 5,
      stepCode: 'SCTSS-017',
      title: 'AI-Human Split Viewport',
      description: 'Side-by-side comparison of AI generated drafts vs human edited content.',
      category: StepCategory.aiAndAutomation,
      icon: Icons.difference_outlined,
      builder: (_) => const AiHumanSplitViewport(config: splitConfig),
    ),
    StepItem(
      stepNumber: 6,
      stepCode: 'SGTIM-019',
      title: 'Contextual Floating Action Button',
      description: 'Expandable speed-dial action bar for quick task shortcuts.',
      category: StepCategory.dataAndForms,
      icon: Icons.add_circle_outline,
      builder: (context) => SizedBox(
        height: 200,
        child: Center(
          child: ContextualFab(
            actions: [
              FabShortcutAction(id: 'a1', label: 'Quick Action 1', icon: Icons.flash_on, onTap: () {}),
              FabShortcutAction(id: 'a2', label: 'Quick Action 2', icon: Icons.bookmark, onTap: () {}),
            ],
          ),
        ),
      ),
    ),
    StepItem(
      stepNumber: 7,
      stepCode: 'SSELC-002',
      title: 'Context Isolation Panel',
      description: 'Secured text field sandbox with confidential document extraction context.',
      category: StepCategory.infrastructure,
      icon: Icons.shield_outlined,
      builder: (_) => const ContextIsolationPanel(item: isolationItem),
    ),
    StepItem(
      stepNumber: 8,
      stepCode: 'IRBCA-055',
      title: 'Swipe Approval Matrix',
      description: 'Swipeable claim approval queue with haptic feedback and swipe gestures.',
      category: StepCategory.dataAndForms,
      icon: Icons.swipe_outlined,
      builder: (_) => SizedBox(
        height: 350,
        child: SwipeApprovalMatrix(claims: claimsList),
      ),
    ),
    StepItem(
      stepNumber: 9,
      stepCode: 'LSAV-024',
      title: 'Floating Callout Overlay',
      description: 'Prominent contextual alert card with custom severity highlights.',
      category: StepCategory.dataAndForms,
      icon: Icons.info_outline,
      builder: (_) => const FloatingCalloutOverlay(config: calloutConfig),
    ),
    StepItem(
      stepNumber: 10,
      stepCode: '168',
      title: 'Server-Sent Events Indicator',
      description: 'Live streaming event counter and connection monitor.',
      category: StepCategory.realTimeSync,
      icon: Icons.stream,
      builder: (context) => SseStatusIndicator(
        sseStatus: const SseConnectionStatus(
          state: SseState.connected,
          serverEndpoint: 'https://api.habot.internal/events/stream',
          eventCountReceived: 240,
        ),
        onReconnectTap: () {},
      ),
    ),
    StepItem(
      stepNumber: 11,
      stepCode: 'HAZFE-001',
      title: 'Multi-Zone HA Sync & Sign-Up Wireframe',
      description: 'Low-fidelity auth signup layout paired with active multi-zone sync bar.',
      category: StepCategory.realTimeSync,
      icon: Icons.cloud_sync_outlined,
      builder: (_) => const Column(
        children: [
          MultiZoneSyncBar(config: haConfig),
          AppSpacingTokens.vGapLg,
          AuthSignUpWireframe(),
        ],
      ),
    ),
    StepItem(
      stepNumber: 12,
      stepCode: 'MUFCE-001',
      title: 'M3 Fluid Media Grid',
      description: 'Responsive thumbnail grid for viewing and uploading media assets.',
      category: StepCategory.dataAndForms,
      icon: Icons.grid_view_outlined,
      builder: (_) => M3FluidMediaGrid(items: mediaList, onAddMedia: () {}),
    ),
    StepItem(
      stepNumber: 13,
      stepCode: 'LSAV-001',
      title: 'Executive Performance Dashboard',
      description: 'High-level financial KPIs, revenue cards, and period metrics.',
      category: StepCategory.analyticsKpi,
      icon: Icons.bar_chart_rounded,
      builder: (_) => const ExecutivePerformanceDashboard(data: execData),
    ),
    StepItem(
      stepNumber: 14,
      stepCode: 'AEETE-001',
      title: 'Byte-Level A/B Test Switcher',
      description: 'Interactive variant toggle card displaying conversion rates.',
      category: StepCategory.analyticsKpi,
      icon: Icons.alt_route,
      builder: (_) => const AbTestingCardSwitch(variants: abVariants),
    ),
    StepItem(
      stepNumber: 15,
      stepCode: 'MUFCE-024',
      title: 'Clean KPI Performance Card',
      description: 'Streamlined metric card highlighting zero-touch conversion trends.',
      category: StepCategory.analyticsKpi,
      icon: Icons.trending_up,
      builder: (_) => const CleanKpiPerformanceCard(config: perfConfig),
    ),
    StepItem(
      stepNumber: 16,
      stepCode: 'TECH-ENG-015',
      title: 'BigQuery Telemetry Monitor',
      description: 'Real-time telemetry event logger and backend latency audit list.',
      category: StepCategory.infrastructure,
      icon: Icons.data_usage_outlined,
      builder: (_) => BigQueryTelemetryMonitor(events: telemetryEvents),
    ),
    StepItem(
      stepNumber: 17,
      stepCode: 'TECH-ENG-034',
      title: 'Bottleneck Highlight Dashboard',
      description: 'Infrastructure health monitor flagging DB query spikes and bottleneck services.',
      category: StepCategory.infrastructure,
      icon: Icons.warning_amber_rounded,
      builder: (_) => const BottleneckHighlightDashboard(events: bottlenecks),
    ),
    StepItem(
      stepNumber: 18,
      stepCode: 'TECH-ENG-046',
      title: 'GCP FinOps Budget Dashboard',
      description: 'Cloud spend tracking dashboard with daily spend, remaining budget, and burn trends.',
      category: StepCategory.infrastructure,
      icon: Icons.account_balance_wallet_outlined,
      builder: (_) => const FinOpsBudgetDashboard(data: finopsData),
    ),
    StepItem(
      stepNumber: 19,
      stepCode: 'NSKFI-015',
      title: 'Smart Keyboard Interceptor',
      description: 'Adaptive text input triggering numeric keypad for SSN/currency fields.',
      category: StepCategory.dataAndForms,
      icon: Icons.keyboard_outlined,
      builder: (_) => const Card(
        child: Padding(
          padding: AppSpacingTokens.paddingMd,
          child: SmartKeyboardField(
            label: 'Numeric Keypad Interceptor (SSN / Amount)',
            hintText: 'Tap to summon numeric keypad automatically...',
          ),
        ),
      ),
    ),
    StepItem(
      stepNumber: 20,
      stepCode: 'EDEBS-008-16',
      title: 'MD3 Elevated Success Card',
      description: 'Elevated vendor onboarding completion card with security hash verification.',
      category: StepCategory.dataAndForms,
      icon: Icons.verified_user_outlined,
      builder: (_) => const Md3ElevatedSuccessCard(record: successRecord),
    ),
    StepItem(
      stepNumber: 21,
      stepCode: 'SCTAS-002',
      title: 'Brand Primary #2E86C1 Token & Field Mapping',
      description: 'Hardcoded #2E86C1 CTA styling framework paired with 1-to-1 data dictionary accuracy panel.',
      category: StepCategory.dataAndForms,
      icon: Icons.palette,
      builder: (_) => const BrandCtaMappingPanel(record: brandCtaRecord),
    ),
    StepItem(
      stepNumber: 22,
      stepCode: 'PDMV-032',
      title: 'Referral Reward Credit Token Matrix',
      description: 'Material M3 tertiary color tokens and outlined cards with BigQuery CHANGES TVF audit logging.',
      category: StepCategory.dataAndForms,
      icon: Icons.stars,
      builder: (_) => const ReferralRewardMatrixPanel(
        record: referralRewardRecord,
        rewardTokens: referralTokensList,
      ),
    ),
    StepItem(
      stepNumber: 23,
      stepCode: 'IS29-SCTAS-007-AS01',
      title: 'High-Contrast Mobile Status Badge System',
      description: 'Atomic status pill badges under 20 lines with WCAG AA 4.5:1 contrast compliance and poka-yoke fallback.',
      category: StepCategory.dataAndForms,
      icon: Icons.label,
      builder: (_) => const StatusBadgeSystemPanel(record: statusBadgeRecord),
    ),
    StepItem(
      stepNumber: 24,
      stepCode: 'CBSV-005-10',
      title: 'DB Identifier _ID Linter & Masked Entity Tokens',
      description: 'Strict linter forcing _ID suffix on DB primary keys with scannable masked user tokens and clipboard copy.',
      category: StepCategory.infrastructure,
      icon: Icons.terminal,
      builder: (_) => const DbLinterEntityPanel(
        record: dbLinterRecord,
        entities: entityRecordItemsList,
      ),
    ),
    StepItem(
      stepNumber: 25,
      stepCode: 'EDEBS-008-15',
      title: 'Mathematical Vendor Onboarding Success & MD3 Card',
      description: 'Mathematically proves vendor onboarding success P(s)=1.0 with MD3 elevated card and 48dp structural padding.',
      category: StepCategory.dataAndForms,
      icon: Icons.verified_user,
      builder: (_) => const MathematicalVendorSuccessPanel(record: vendorProofRecord),
    ),
    StepItem(
      stepNumber: 26,
      stepCode: 'MUFCE-018',
      title: 'Universal Design Component Compliance Validator',
      description: 'DevOps CI/CD linter engine enforcing zero custom static pixel heights and token mapping compliance.',
      category: StepCategory.infrastructure,
      icon: Icons.integration_instructions,
      builder: (_) => const DesignComplianceValidatorPanel(
        record: designComplianceRecord,
        templates: universalUiTemplatesList,
      ),
    ),
    StepItem(
      stepNumber: 27,
      stepCode: 'EDEBS-015-10',
      title: 'Lineage Trace Test & Release Gate Control',
      description: 'Executes lineage trace test and physically disables Release to Tech button if anomaly score > 0.',
      category: StepCategory.analyticsKpi,
      icon: Icons.alt_route,
      builder: (_) => const LineageTraceTestPanel(record: lineageTraceRecord),
    ),
    StepItem(
      stepNumber: 28,
      stepCode: 'PDMV-016-10',
      title: 'Mobile Referral-First Reward Injection',
      description: 'Sizes Share FAB to 56dp large touch target with native share intent and celebration animation.',
      category: StepCategory.dataAndForms,
      icon: Icons.card_giftcard,
      builder: (_) => const ReferralRewardInjectionPanel(record: referralRewardInjectionRecord),
    ),
    StepItem(
      stepNumber: 29,
      stepCode: 'TNRML-007',
      title: 'Responsive Tablet Sidebar Navigation Rail Shell',
      description: 'Shifts bottom navigation to a locked 80dp sidebar Navigation Rail at 600dp viewport breakpoint.',
      category: StepCategory.infrastructure,
      icon: Icons.view_sidebar_outlined,
      builder: (_) => const ResponsiveNavRailPanel(record: responsiveNavRailRecord),
    ),
    StepItem(
      stepNumber: 30,
      stepCode: 'FEBFL-005',
      title: 'Private Flutter Pub Package Import Enforcement',
      description: 'Enforces private Flutter pub package component imports with contextual split-screen framework and 48dp touch targets.',
      category: StepCategory.infrastructure,
      icon: Icons.inventory_2_outlined,
      builder: (_) => const PrivatePackageEnforcementPanel(record: privatePackageRecord),
    ),
    StepItem(
      stepNumber: 31,
      stepCode: 'EDBAA-015-09',
      title: 'Package & Lock Master Component Library',
      description: 'Freezes codebase integrity into a read-only distribution package with ISO 9001 process conformance.',
      category: StepCategory.infrastructure,
      icon: Icons.lock,
      builder: (_) => const MasterLibraryLockPanel(
        record: masterLibraryLockRecord,
        modules: preApprovedModulesList,
      ),
    ),
    StepItem(
      stepNumber: 32,
      stepCode: 'DLQDP-015-13',
      title: 'System-Verb Icon Mapping Matrix',
      description: 'Enforces strict system action iconography mapping with 24x24dp bounds and 48dp phantom touch targets.',
      category: StepCategory.infrastructure,
      icon: Icons.category_outlined,
      builder: (_) => const SystemVerbIconPanel(
        record: systemVerbIconRecord,
        verbs: systemVerbsList,
      ),
    ),
  ];
}

class LegacyFullStreamView extends StatelessWidget {
  const LegacyFullStreamView({super.key});

  @override
  Widget build(BuildContext context) {
    final steps = _buildAppStepDirectory();
    return SingleChildScrollView(
      padding: AppSpacingTokens.paddingMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: steps.map((step) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Step ${step.stepNumber} (${step.stepCode}): ${step.title}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              AppSpacingTokens.vGapSm,
              Builder(builder: step.builder),
              AppSpacingTokens.vGapLg,
            ],
          );
        }).toList(),
      ),
    );
  }
}
