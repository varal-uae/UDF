// ============================================================================
// SYSTEM INFRASTRUCTURE SPECIFICATION METADATA BLOCK
// Global Reference ID: DSI-001
// Configuration Key: DESIGN_SYSTEM_INFRASTRUCTURE_PHASE_1_TO_6
// Implementation Level: Full 6-Phase System Compliance
// Verification Status: WCAG 2.1 AA Compliant & RIMV-007 Interceptor Enforced
// Configuration Timestamp: 2026-08-17T13:49:00Z
// ============================================================================

import 'package:flutter/material.dart';
import '../theme/app_design_tokens.dart';
import '../widgets/app_responsive_layout.dart';
import '../widgets/app_component_library.dart';
import '../widgets/app_system_guardrails.dart';

/// DSI-001: Design System & Theme Infrastructure Master Showcase
class DesignSystemInfrastructureShowcase extends StatefulWidget {
  const DesignSystemInfrastructureShowcase({super.key});

  @override
  State<DesignSystemInfrastructureShowcase> createState() =>
      _DesignSystemInfrastructureShowcaseState();
}

class _DesignSystemInfrastructureShowcaseState
    extends State<DesignSystemInfrastructureShowcase>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Form Controllers for Masking & RIMV-007 Interceptor
  final TextEditingController _entityIdController = TextEditingController();
  final TextEditingController _currencyController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  // State Toggles for Demonstration
  bool _isHardLockActive = false;
  bool _isSystemBreached = false;
  double _aiConfidenceScore = 0.95; // High confidence by default
  bool _toggleValue = true;
  int _bottomNavIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _entityIdController.dispose();
    _currencyController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _triggerRimv007SaveLock() {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppDesignTokens.errorMain,
          content: Text(
            'RIMV-007 SAVE-LOCK INTERCEPTOR: Submission blocked due to invalid input fields!',
          ),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: AppDesignTokens.successMain,
        content: Text(
          'LEVEL 2 & LEVEL 3 PASSED: Form Payload Transmitted Successfully!',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('[DSI-001] Design System Infrastructure'),
        elevation: AppDesignTokens.elevation2,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.palette), text: 'Phase 1: Tokens'),
            Tab(icon: Icon(Icons.grid_view), text: 'Phase 2: Layouts'),
            Tab(icon: Icon(Icons.widgets), text: 'Phase 3: Components'),
            Tab(icon: Icon(Icons.psychology), text: 'Phase 4: AI & Locks'),
            Tab(icon: Icon(Icons.security), text: 'Phase 5: Policy'),
            Tab(icon: Icon(Icons.accessibility), text: 'Phase 6: WCAG & Audit'),
          ],
        ),
      ),

      body: AppHardLockNavigationGuard(
        isDataEntryActive: _isHardLockActive,
        onSave: () {
          setState(() {
            _isHardLockActive = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Hard Lock Saved & Released!')),
          );
        },
        onCancel: () {
          setState(() {
            _isHardLockActive = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Hard Lock Cancelled!')),
          );
        },
        child: Column(
          children: [
            // Read-Only System Breach Alert if Triggered
            if (_isSystemBreached)
              const AppCapacityBreachAlertCard(
                currentCapacityPercent: 104.8,
                systemName: 'Primary Cluster API Gateway',
                lockReason: 'Capacity limit >100% breached. Operations forced to Read-Only.',
                isoTimestamp: '2026-08-17T13:49:00Z',
              ),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildPhase1Tokens(theme),
                  _buildPhase2Layouts(theme),
                  _buildPhase3Components(theme),
                  _buildPhase4AiAndLocks(theme),
                  _buildPhase5PolicyAndLocks(theme),
                  _buildPhase6WcagAndAudit(theme),
                ],
              ),
            ),
          ],
        ),
      ),

      // 3.4 80dp Bottom Navigation Bar Component
      bottomNavigationBar: AppBottomNavigationBar(
        selectedIndex: _bottomNavIndex,
        onDestinationSelected: (idx) => setState(() => _bottomNavIndex = idx),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.analytics), label: 'Analytics'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'System Settings'),
        ],
      ),
    );
  }

  // ==========================================================================
  // Phase 1: Tokens (Colors, Spacing, Typography, Radii)
  // ==========================================================================
  Widget _buildPhase1Tokens(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDesignTokens.spaceL),
      child: AppFullWidthContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Phase 1: Design Tokens & Theme Infrastructure', style: AppDesignTokens.headlineMedium),
            const SizedBox(height: AppDesignTokens.spaceM),

            // Color Tokens Palette
            Text('1.1 Color Tokens', style: AppDesignTokens.titleMedium),
            const SizedBox(height: AppDesignTokens.spaceS),
            Wrap(
              spacing: AppDesignTokens.spaceS,
              runSpacing: AppDesignTokens.spaceS,
              children: [
                _buildColorChip('Success Main', AppDesignTokens.successMain, AppDesignTokens.successText),
                _buildColorChip('Success Container', AppDesignTokens.successContainer, AppDesignTokens.successDark),
                _buildColorChip('Error Main', AppDesignTokens.errorMain, AppDesignTokens.errorText),
                _buildColorChip('Error Container', AppDesignTokens.errorContainer, AppDesignTokens.errorDark),
                _buildColorChip('Warning Main', AppDesignTokens.warningMain, AppDesignTokens.warningText),
                _buildColorChip('Warning Container', AppDesignTokens.warningContainer, AppDesignTokens.warningDark),
                _buildColorChip('Info Main', AppDesignTokens.infoMain, AppDesignTokens.infoText),
                _buildColorChip('Info Container', AppDesignTokens.infoContainer, AppDesignTokens.infoDark),
              ],
            ),
            const Divider(height: 32),

            // Spacing Tokens
            Text('1.2 Fixed Spacing Tokens', style: AppDesignTokens.titleMedium),
            const SizedBox(height: AppDesignTokens.spaceS),
            Wrap(
              spacing: AppDesignTokens.spaceM,
              children: const [
                Chip(label: Text('xs: 4px')),
                Chip(label: Text('s: 8px')),
                Chip(label: Text('m: 16px')),
                Chip(label: Text('l: 24px')),
                Chip(label: Text('xl: 32px')),
                Chip(label: Text('2xl: 48px')),
              ],
            ),
            const Divider(height: 32),

            // Typography & Monospace Tokens
            Text('1.3 Typography Scale & Monospace Token', style: AppDesignTokens.titleMedium),
            const SizedBox(height: AppDesignTokens.spaceS),
            Text('Display Large 57px', style: AppDesignTokens.displaySmall),
            Text('Headline Medium 28px', style: AppDesignTokens.headlineMedium),
            Text('Title Large 22px', style: AppDesignTokens.titleLarge),
            Text('Body Medium 14px', style: AppDesignTokens.bodyMedium),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(AppDesignTokens.spaceS),
              color: theme.colorScheme.surfaceContainerHigh,
              child: Text(
                'MONOSPACE TOKEN: AUDIT_ID_9921_HASH_881903 (14px Monospace)',
                style: AppDesignTokens.monospaceToken,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorChip(String label, Color bg, Color text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppDesignTokens.radiusSmall),
      ),
      child: Text(
        label,
        style: TextStyle(color: text, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  // ==========================================================================
  // Phase 2: Responsive Grid & Layouts
  // ==========================================================================
  Widget _buildPhase2Layouts(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDesignTokens.spaceL),
      child: AppFullWidthContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Phase 2: Responsive Grid & Layout System', style: AppDesignTokens.headlineMedium),
            const SizedBox(height: AppDesignTokens.spaceS),
            Text(
              'Breakpoints: Mobile (360px+ / 4 cols) -> Tablet (600px+ / 8 cols) -> Desktop (1200px+ / 12 cols, max 1200px)',
              style: AppDesignTokens.bodyMedium,
            ),
            const SizedBox(height: AppDesignTokens.spaceL),

            Text('2.2 Dual-Pane Layout Component (50/50 Desktop vs Collapsible Mobile)', style: AppDesignTokens.titleMedium),
            const SizedBox(height: AppDesignTokens.spaceM),

            AppDualPaneLayout(
              contextTitle: 'Read-Only Context & Evidence',
              contextPane: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Evidence ID: EVD-99218', style: AppDesignTokens.monospaceToken),
                  SizedBox(height: 8),
                  Text('Audit Log Source: GCP Cloud Audit Stream'),
                  Text('Timestamp: 2026-08-17T13:49:00Z'),
                  Text('Confidence Verification: High (>90%)'),
                ],
              ),
              dataEntryPane: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Form Input Data Entry', style: AppDesignTokens.titleSmall),
                  const SizedBox(height: 8),
                  AppFormField(
                    label: 'Verification Note',
                    controller: TextEditingController(),
                    hint: 'Enter analyst verification notes...',
                  ),
                  const SizedBox(height: 12),
                  AppButton(
                    label: 'Save Verification',
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // Phase 3: Component Library (Buttons, Masks, Steppers)
  // ==========================================================================
  Widget _buildPhase3Components(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDesignTokens.spaceL),
      child: AppFullWidthContainer(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Phase 3: Core Component Library', style: AppDesignTokens.headlineMedium),
              const SizedBox(height: AppDesignTokens.spaceL),

              // Buttons
              Text('3.1 Button Variants & States (Min 44x48px Touch Targets)', style: AppDesignTokens.titleMedium),
              const SizedBox(height: AppDesignTokens.spaceS),
              Wrap(
                spacing: AppDesignTokens.spaceS,
                runSpacing: AppDesignTokens.spaceS,
                children: [
                  AppButton(label: 'Filled Button', onPressed: () {}),
                  AppButton(label: 'Outlined', variant: AppButtonVariant.outlined, onPressed: () {}),
                  AppButton(label: 'Tonal', variant: AppButtonVariant.tonal, onPressed: () {}),
                  AppButton(label: 'Elevated', variant: AppButtonVariant.elevated, onPressed: () {}),
                  AppButton(label: 'Text', variant: AppButtonVariant.text, onPressed: () {}),
                  AppButton(label: 'Loading', isLoading: true, onPressed: () {}),
                  const AppButton(label: 'Disabled', onPressed: null),
                ],
              ),
              const Divider(height: 32),

              // Form Masking & RIMV-007 Interceptor
              Text('3.2 Real-Time Input Masking & RIMV-007 Save-Lock Interceptor', style: AppDesignTokens.titleMedium),
              const SizedBox(height: AppDesignTokens.spaceM),

              AppFormField(
                label: 'Entity ID (Mask: AAA-000)',
                controller: _entityIdController,
                hint: 'e.g. ABC-123',
                isMonospace: true,
                inputFormatters: [AppEntityIdFormatter()],
                validator: (val) {
                  if (val == null || !RegExp(r'^[A-Z]{3}-\d{3}$').hasMatch(val)) {
                    return 'Invalid Entity ID! Must match AAA-000 pattern.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppDesignTokens.spaceM),

              AppFormField(
                label: 'Currency USD (Mask: \$0,000.00)',
                controller: _currencyController,
                hint: '\$0.00',
                isMonospace: true,
                keyboardType: TextInputType.number,
                inputFormatters: [AppCurrencyFormatter()],
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Currency amount is required.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppDesignTokens.spaceM),

              AppButton(
                label: 'Execute Form Submission (RIMV-007 Check)',
                icon: Icons.shield,
                onPressed: _triggerRimv007SaveLock,
              ),
              const Divider(height: 32),

              // Stepper & Toggles
              Text('3.3 Toggles, Checkboxes & Steppers', style: AppDesignTokens.titleMedium),
              const SizedBox(height: AppDesignTokens.spaceM),
              Row(
                children: [
                  const Text('52x32dp Toggle Switch: '),
                  AppToggleSwitch(
                    value: _toggleValue,
                    onChanged: (val) => setState(() => _toggleValue = val),
                  ),
                ],
              ),
              const SizedBox(height: AppDesignTokens.spaceM),
              const AppBlockedStepIndicator(title: 'Step 4: Executive Approval'),
              const SizedBox(height: AppDesignTokens.spaceM),

              AppVerticalStepper(
                steps: [
                  AppStepItem(
                    title: 'Step 1: Input Validation',
                    subtitle: 'Real-time format check passed',
                    auditId: 'AUD-001-VAL',
                    isCompleted: true,
                  ),
                  AppStepItem(
                    title: 'Step 2: RIMV-007 Interceptor Check',
                    subtitle: 'Pre-submission validation active',
                    auditId: 'AUD-002-INT',
                    isCurrent: true,
                  ),
                  AppStepItem(
                    title: 'Step 3: Database Commit',
                    subtitle: 'Level 3 server verification pending',
                    auditId: 'AUD-003-CMT',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // Phase 4: AI & Navigation Isolation Locks
  // ==========================================================================
  Widget _buildPhase4AiAndLocks(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDesignTokens.spaceL),
      child: AppFullWidthContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Phase 4: Application Logic & Hard Locks', style: AppDesignTokens.headlineMedium),
            const SizedBox(height: AppDesignTokens.spaceL),

            Text('4.1 Three-Tier AI Confidence Alerting Container', style: AppDesignTokens.titleMedium),
            const SizedBox(height: AppDesignTokens.spaceS),
            Text('Adjust Confidence Score (${(_aiConfidenceScore * 100).toStringAsFixed(0)}%):'),
            Slider(
              value: _aiConfidenceScore,
              min: 0.40,
              max: 1.00,
              divisions: 12,
              label: '${(_aiConfidenceScore * 100).toStringAsFixed(0)}%',
              onChanged: (val) => setState(() => _aiConfidenceScore = val),
            ),
            const SizedBox(height: AppDesignTokens.spaceM),

            AppAiConfidenceContainer(
              confidenceScore: _aiConfidenceScore,
              extractedDataLabel: 'Invoice Tax ID',
              extractedValue: 'TX-99812-US',
              onRouteToHumanReview: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Item routed to Human Review Queue!')),
                );
              },
            ),
            const Divider(height: 32),

            Text('4.2 Navigation Isolation Hard Lock Toggle', style: AppDesignTokens.titleMedium),
            const SizedBox(height: AppDesignTokens.spaceS),
            SwitchListTile(
              title: const Text('Engage Hard Lock Navigation Guard'),
              subtitle: const Text('When active, back navigation is blocked until explicit Save/Cancel.'),
              value: _isHardLockActive,
              onChanged: (val) => setState(() => _isHardLockActive = val),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // Phase 5: Policy & System Locks
  // ==========================================================================
  Widget _buildPhase5PolicyAndLocks(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDesignTokens.spaceL),
      child: AppFullWidthContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Phase 5: Policy Enforcement & System Locks', style: AppDesignTokens.headlineMedium),
            const SizedBox(height: AppDesignTokens.spaceL),

            Text('5.2 System Capacity & Budget Breach Lock Toggle', style: AppDesignTokens.titleMedium),
            const SizedBox(height: AppDesignTokens.spaceS),
            SwitchListTile(
              title: const Text('Simulate >100% Capacity Breach Lock'),
              subtitle: const Text('Forces infrastructure into READ-ONLY state with alert payload.'),
              value: _isSystemBreached,
              activeThumbColor: AppDesignTokens.errorMain,
              onChanged: (val) => setState(() => _isSystemBreached = val),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // Phase 6: WCAG 2.1 AA & Immutable Audit Trails
  // ==========================================================================
  Widget _buildPhase6WcagAndAudit(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDesignTokens.spaceL),
      child: AppFullWidthContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Phase 6: Accessibility (WCAG 2.1 AA) & Immutable Audits', style: AppDesignTokens.headlineMedium),
            const SizedBox(height: AppDesignTokens.spaceL),

            Container(
              padding: const EdgeInsets.all(AppDesignTokens.spaceM),
              decoration: BoxDecoration(
                color: AppDesignTokens.successContainer,
                borderRadius: BorderRadius.circular(AppDesignTokens.radiusMedium),
              ),
              child: Row(
                children: const [
                  Icon(Icons.accessibility_new, color: AppDesignTokens.successDark),
                  SizedBox(width: AppDesignTokens.spaceM),
                  Expanded(
                    child: Text(
                      'WCAG 2.1 AA Contrast Compliance: Verified >= 4.5:1 ratio for normal text & 3:1 for large text.',
                      style: TextStyle(fontWeight: FontWeight.bold, color: AppDesignTokens.successDark),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDesignTokens.spaceL),

            Text('5.3 Immutable Monospace Audit Trail Logs', style: AppDesignTokens.titleMedium),
            const SizedBox(height: AppDesignTokens.spaceM),

            const AppImmutableAuditLogCard(
              actionName: 'API_KEY_INVALIDATION',
              triggerSource: 'SYSTEM_AUTOSCALER',
              isoTimestamp: '2026-08-17T13:49:00Z',
              verificationHash: '0x88921AFA901823BCA771291823',
            ),
            const SizedBox(height: AppDesignTokens.spaceS),
            const AppImmutableAuditLogCard(
              actionName: 'SSO_SESSION_SUSPENSION',
              triggerSource: 'SECURITY_POLICY_ENGINE',
              isoTimestamp: '2026-08-17T13:48:45Z',
              verificationHash: '0x33189BEF109283AAC991827461',
            ),
          ],
        ),
      ),
    );
  }
}
