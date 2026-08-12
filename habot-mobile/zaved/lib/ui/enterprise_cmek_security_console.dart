import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'code_export_modal.dart';
import 'component_code_registry.dart';

/// Data class holding security configuration & compliance metrics for NLM-APS-003.
class SecurityConfig {
  final bool isVpcScEnforced;
  final String keyRotationPolicy;
  final double complianceScore;

  const SecurityConfig({
    required this.isVpcScEnforced,
    required this.keyRotationPolicy,
    required this.complianceScore,
  });

  SecurityConfig copyWith({
    bool? isVpcScEnforced,
    String? keyRotationPolicy,
    double? complianceScore,
  }) {
    return SecurityConfig(
      isVpcScEnforced: isVpcScEnforced ?? this.isVpcScEnforced,
      keyRotationPolicy: keyRotationPolicy ?? this.keyRotationPolicy,
      complianceScore: complianceScore ?? this.complianceScore,
    );
  }
}

/// Responsive 'Enterprise CMEK & Security Console' Widget (NLM-APS-003).
/// Features:
/// 1. SecurityConfig state initialized to keyRotationPolicy = 'Never' & complianceScore = 100.0.
/// 2. LayoutBuilder with Mobile ListView vs Web/Tablet NavigationRail & expansive Grid layout.
/// 3. Poka-Yoke Locked UI State: Disabled Key Rotation switch showing "Never (Manual Rotation)".
/// 4. Pass/Fail Metric Banner: Green (Pass >= 95.0) vs Red (Fail < 95.0) on "Test Auto-Rotate".
class EnterpriseCmekSecurityConsole extends StatefulWidget {
  const EnterpriseCmekSecurityConsole({super.key});

  @override
  State<EnterpriseCmekSecurityConsole> createState() =>
      _EnterpriseCmekSecurityConsoleState();
}

class _EnterpriseCmekSecurityConsoleState
    extends State<EnterpriseCmekSecurityConsole> {
  SecurityConfig _config = const SecurityConfig(
    isVpcScEnforced: true,
    keyRotationPolicy: 'Never (Manual Rotation)',
    complianceScore: 100.0,
  );

  int _selectedNavIndex = 0;

  void _testAutoRotateViolation() {
    setState(() {
      _config = _config.copyWith(
        complianceScore: 82.5, // Drops below 95.0 trigger
      );
    });

    developer.log(
      'Policy Violation Triggered: Auto-Rotate attempt detected. ISO/IEC 27001 A.10 Violation.',
      name: 'SecurityConsole',
      level: 1000,
    );
  }

  void _resetCompliance() {
    setState(() {
      _config = _config.copyWith(
        complianceScore: 100.0,
      );
    });
  }

  void _openCodeExportModal() {
    final specData = ComponentCodeRegistry.getCodeSpec(
      globalRefId: 'NLM-APS-003',
      title: 'Enterprise CMEK & Security Console',
      category: 'Workspaces & Sandbox',
    );
    CodeExportModalDialog.show(
      context: context,
      globalRefId: 'NLM-APS-003',
      title: 'Enterprise CMEK & Security Console',
      fileName: specData['fileName']!,
      widgetClassName: specData['widgetClassName']!,
      category: 'Workspaces & Sandbox',
      sourceCode: specData['sourceCode']!,
      integrationGuide: '''// -------------------------------------------------------------
// INTEGRATION GUIDE: [NLM-APS-003] Enterprise CMEK & Security Console
// -------------------------------------------------------------

1. File Setup:
   Create lib/ui/${specData['fileName']} in your target Flutter application.

2. Dependencies:
   Ensure useMaterial3: true is set in your ThemeData.

3. Import & Usage:
   import 'package:your_app/ui/${specData['fileName']}';

   @override
   Widget build(BuildContext context) {
     return const ${specData['widgetClassName']}();
   }

4. Responsiveness & Accessibility:
   - Web/Tablet (>600dp): Displays NavigationRail side bar & 3-column configuration grid.
   - Mobile (<=600dp): Displays single-column scrollable Card list.
   - All interactive controls enforce 48dp minimum touch target height.
''',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('[NLM-APS-003] Enterprise CMEK & Security Console'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.code),
            tooltip: 'Export Code & Integration Guide',
            onPressed: _openCodeExportModal,
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktopWebTablet = constraints.maxWidth > 600;

          if (isDesktopWebTablet) {
            return _buildWebTabletRailLayout(theme);
          } else {
            return _buildMobileListViewLayout(theme);
          }
        },
      ),
    );
  }

  /// Web/Tablet View Layout (maxWidth > 600): NavigationRail + Expansive Configuration Grid
  Widget _buildWebTabletRailLayout(ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Side Navigation Rail
        NavigationRail(
          selectedIndex: _selectedNavIndex,
          onDestinationSelected: (idx) {
            setState(() {
              _selectedNavIndex = idx;
            });
          },
          labelType: NavigationRailLabelType.selected,
          destinations: const [
            NavigationRailDestination(
              icon: Icon(Icons.security),
              selectedIcon: Icon(Icons.security, color: Colors.deepPurple),
              label: Text('Console'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.vpn_key),
              label: Text('CMEK Keys'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.shield),
              label: Text('VPC-SC'),
            ),
          ],
        ),
        const VerticalDivider(thickness: 1, width: 1),

        // Main Expansive Content Area
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Pass/Fail Metric Banner
                _buildPassFailBanner(theme),
                const SizedBox(height: 24.0),

                // Responsive Configuration Grid using LayoutBuilder
                LayoutBuilder(
                  builder: (context, gridConstraints) {
                    final isWideDesktop = gridConstraints.maxWidth > 900;

                    if (isWideDesktop) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _buildCmekSettingsCard(theme)),
                          const SizedBox(width: 16.0),
                          Expanded(child: _buildVpcScStatusCard(theme)),
                          const SizedBox(width: 16.0),
                          Expanded(child: _buildComplianceMetricsCard(theme)),
                        ],
                      );
                    } else {
                      return Column(
                        children: [
                          _buildCmekSettingsCard(theme),
                          const SizedBox(height: 16.0),
                          _buildVpcScStatusCard(theme),
                          const SizedBox(height: 16.0),
                          _buildComplianceMetricsCard(theme),
                        ],
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Mobile View Layout (maxWidth <= 600): Single ListView with Material Cards
  Widget _buildMobileListViewLayout(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Pass/Fail Metric Banner
          _buildPassFailBanner(theme),
          const SizedBox(height: 16.0),

          // CMEK Settings Card
          _buildCmekSettingsCard(theme),
          const SizedBox(height: 16.0),

          // VPC-SC Status Card
          _buildVpcScStatusCard(theme),
          const SizedBox(height: 16.0),

          // Compliance Metrics Card
          _buildComplianceMetricsCard(theme),
        ],
      ),
    );
  }

  /// Pass/Fail Metric Banner evaluating complianceScore
  Widget _buildPassFailBanner(ThemeData theme) {
    final isPass = _config.complianceScore >= 95.0;
    final bannerBg = isPass ? Colors.green.shade100 : Colors.red.shade100;
    final bannerColor = isPass ? Colors.green.shade900 : Colors.red.shade900;
    final iconData = isPass ? Icons.verified_user : Icons.gpp_bad;

    return Card(
      elevation: 2,
      color: bannerBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: BorderSide(
          color: isPass ? Colors.green : Colors.red,
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Icon(iconData, size: 36.0, color: bannerColor),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'NotebookLM Enterprise Compliance Status',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: bannerColor.withValues(alpha: 0.8),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    isPass
                        ? 'PASS: 100% Compliant'
                        : 'FAIL: ISO/IEC 27001 A.10 Violation',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: bannerColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    'Current Compliance Rating: ${_config.complianceScore.toStringAsFixed(1)}%',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: bannerColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12.0),
            if (isPass)
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  foregroundColor: Colors.white,
                ),
                onPressed: _testAutoRotateViolation,
                icon: const Icon(Icons.sync_problem, size: 18.0),
                label: const Text('Test Auto-Rotate'),
              )
            else
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red.shade900,
                  side: BorderSide(color: Colors.red.shade900),
                ),
                onPressed: _resetCompliance,
                icon: const Icon(Icons.restore),
                label: const Text('Reset Compliance'),
              ),
          ],
        ),
      ),
    );
  }

  /// Locked UI State (Poka-Yoke) CMEK Settings Card
  Widget _buildCmekSettingsCard(ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.key, color: theme.colorScheme.primary),
                const SizedBox(width: 8.0),
                Text(
                  'CMEK Key Management',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),

            // Poka-Yoke Locked Control
            Tooltip(
              message:
                  'Enforced by NotebookLM Enterprise configuration (NIST SP 800-57)',
              child: SwitchListTile(
                value: false,
                onChanged: null, // Visually disabled / locked
                title: const Text(
                  'Key Rotation Policy',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 4.0),
                    Text(
                      'Never (Manual Rotation)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 4.0),
                    Row(
                      children: [
                        Icon(Icons.lock, size: 14.0, color: Colors.grey),
                        SizedBox(width: 4.0),
                        Expanded(
                          child: Text(
                            'Enforced by NotebookLM Enterprise configuration (NIST SP 800-57)',
                            style: TextStyle(
                              fontSize: 11.0,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVpcScStatusCard(ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.shield_outlined, color: theme.colorScheme.primary),
                const SizedBox(width: 8.0),
                Text(
                  'VPC-SC Perimeter Status',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Service Perimeter Enforcement'),
              subtitle: const Text('ACTIVE - Project ID: nlm-ent-sec-01'),
              trailing: Icon(
                _config.isVpcScEnforced
                    ? Icons.check_circle
                    : Icons.cancel_outlined,
                color: _config.isVpcScEnforced ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComplianceMetricsCard(ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics_outlined, color: theme.colorScheme.primary),
                const SizedBox(width: 8.0),
                Text(
                  'NIST Compliance Rating',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            LinearProgressIndicator(
              value: _config.complianceScore / 100.0,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              color: _config.complianceScore >= 95.0 ? Colors.green : Colors.red,
              minHeight: 8.0,
              borderRadius: BorderRadius.circular(4.0),
            ),
            const SizedBox(height: 12.0),
            Text(
              '${_config.complianceScore.toStringAsFixed(1)}% / 100.0%',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
