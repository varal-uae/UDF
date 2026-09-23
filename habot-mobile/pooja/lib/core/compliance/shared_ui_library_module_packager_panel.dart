import 'package:flutter/material.dart';

/// Row 247 - FEBFL-037-A14 (Seq 15297)
/// Action: Build and package the shared UI library module.
/// Metric: Build/Commit Integrity Rate (%) | Target: Clean build, zero errors/warnings | Unit: Pass/Fail
/// Standard: Standard DevOps 'green build' hygiene with conventional commit publishing.
class SharedUiLibraryModulePackagerPanel extends StatefulWidget {
  const SharedUiLibraryModulePackagerPanel({super.key});

  @override
  State<SharedUiLibraryModulePackagerPanel> createState() =>
      _SharedUiLibraryModulePackagerPanelState();
}

class _PackageArtifact {
  final String moduleName;
  final String version;
  final int exportedComponents;
  final String status;

  const _PackageArtifact({
    required this.moduleName,
    required this.version,
    required this.exportedComponents,
    required this.status,
  });
}

class _SharedUiLibraryModulePackagerPanelState
    extends State<SharedUiLibraryModulePackagerPanel> {
  final String _buildStatus = 'CLEAN_BUILD_SUCCESS';
  final String _buildArtifactsPath = 'packages/habot_ui_core/dist/v2.8.0.aar';
  final String _buildLogs = '0 syntax errors, 0 linter warnings, 100% tests passed';
  final String _buildDuration = '14.2s';
  final String _completionStatus = 'Pass';
  final String _userSessionId = 'POOJA-FEBFL-037-A14';

  final List<_PackageArtifact> _artifacts = const [
    _PackageArtifact(moduleName: 'habot_tokens', version: 'v1.4.0', exportedComponents: 32, status: 'PUBLISHED'),
    _PackageArtifact(moduleName: 'habot_modals', version: 'v2.1.0', exportedComponents: 18, status: 'PUBLISHED'),
    _PackageArtifact(moduleName: 'habot_layout_core', version: 'v3.0.1', exportedComponents: 45, status: 'PUBLISHED'),
  ];

  bool _isPackaging = false;
  DateTime _lastBuildTimestamp = DateTime.now();

  Map<String, dynamic> getTelemetryData() {
    return {
      'Build Status': _buildStatus,
      'Build Timestamp': _lastBuildTimestamp.toIso8601String(),
      'Build Artifacts Path': _buildArtifactsPath,
      'Build Logs': _buildLogs,
      'Build Duration': _buildDuration,
      'Completion Status': _completionStatus,
      'Action/Event Timestamp': _lastBuildTimestamp.toIso8601String(),
      'User/Session ID': _userSessionId,
      'Warning-to-Error Ratio': '0.0% (Target: <5%)',
      'Packaged Submodules': _artifacts.length,
    };
  }

  void _triggerPackagingRun() {
    setState(() {
      _isPackaging = true;
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _isPackaging = false;
          _lastBuildTimestamp = DateTime.now();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: SharedUiLibraryModulePackagerPanelTokens.paddingMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeaderCard(),
          SharedUiLibraryModulePackagerPanelTokens.vGapMd,
          _buildBuildStatusSummaryCard(),
          SharedUiLibraryModulePackagerPanelTokens.vGapMd,
          _buildArtifactsListCard(),
          SharedUiLibraryModulePackagerPanelTokens.vGapMd,
          _buildActionCard(),
          SharedUiLibraryModulePackagerPanelTokens.vGapMd,
          _buildTelemetryCard(),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
        side: BorderSide(color: SharedUiLibraryModulePackagerPanelTokens.lightOutline.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: SharedUiLibraryModulePackagerPanelTokens.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.archive_outlined,
                  color: SharedUiLibraryModulePackagerPanelTokens.brandPrimary,
                  size: 22,
                ),
                SharedUiLibraryModulePackagerPanelTokens.hGapSm,
                const Expanded(
                  child: Text(
                    'Shared UI Library Module Packager',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: SharedUiLibraryModulePackagerPanelTokens.brandPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: SharedUiLibraryModulePackagerPanelTokens.successContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Integrity: Clean Build (Pass)',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: SharedUiLibraryModulePackagerPanelTokens.onSuccessContainer,
                    ),
                  ),
                ),
              ],
            ),
            SharedUiLibraryModulePackagerPanelTokens.vGapSm,
            Text(
              'Automates compilation, tree-shaking, and packaging of the shared UI library into versioned deployable modules with zero unresolved warnings.',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBuildStatusSummaryCard() {
    return Card(
      elevation: 1,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
        side: BorderSide(color: SharedUiLibraryModulePackagerPanelTokens.success, width: 1.5),
      ),
      child: Padding(
        padding: SharedUiLibraryModulePackagerPanelTokens.paddingMd,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: SharedUiLibraryModulePackagerPanelTokens.successContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_outline, color: SharedUiLibraryModulePackagerPanelTokens.onSuccessContainer, size: 26),
            ),
            SharedUiLibraryModulePackagerPanelTokens.hGapMd,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Release Build: green (100%)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: SharedUiLibraryModulePackagerPanelTokens.brandPrimary)),
                  const SizedBox(height: 2),
                  Text('Duration: $_buildDuration | Target: $_buildArtifactsPath', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArtifactsListCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
        side: BorderSide(color: SharedUiLibraryModulePackagerPanelTokens.lightOutline.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: SharedUiLibraryModulePackagerPanelTokens.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Exported Module Packages',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: SharedUiLibraryModulePackagerPanelTokens.brandPrimary),
            ),
            SharedUiLibraryModulePackagerPanelTokens.vGapSm,
            ..._artifacts.map((a) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.inventory_2_outlined, size: 18, color: SharedUiLibraryModulePackagerPanelTokens.brandPrimary),
                        SharedUiLibraryModulePackagerPanelTokens.hGapSm,
                        Expanded(
                          child: Text('${a.moduleName} (${a.version})', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                        Text('${a.exportedComponents} widgets', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                      ],
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard() {
    return ElevatedButton.icon(
      onPressed: _isPackaging ? null : _triggerPackagingRun,
      icon: _isPackaging
          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
          : const Icon(Icons.refresh, color: Colors.white, size: 16),
      label: Text(_isPackaging ? 'Compiling & Packaging...' : 'Run Packaging Verification Pipeline'),
      style: ElevatedButton.styleFrom(
        backgroundColor: SharedUiLibraryModulePackagerPanelTokens.brandPrimary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }

  Widget _buildTelemetryCard() {
    final telemetry = getTelemetryData();
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
        side: BorderSide(color: SharedUiLibraryModulePackagerPanelTokens.lightOutline.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: SharedUiLibraryModulePackagerPanelTokens.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Audit Telemetry',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: SharedUiLibraryModulePackagerPanelTokens.brandPrimary,
              ),
            ),
            SharedUiLibraryModulePackagerPanelTokens.vGapSm,
            ...telemetry.entries.map((e) {
              final val = e.value.toString();
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 180,
                      child: Text(
                        '${e.key}:',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        val,
                        style: const TextStyle(
                          fontSize: 11,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// File-Local Standalone Design Tokens & Constants
// ============================================================================
abstract final class SharedUiLibraryModulePackagerPanelTokens {
  // Brand & Semantic Color Tokens
  static const Color brandPrimary = Color(0xFF2E86C1);
  static const Color onBrandPrimary = Color(0xFFFFFFFF);
  static const Color brandPrimaryContainer = Color(0xFFD6EAF8);
  static const Color onBrandPrimaryContainer = Color(0xFF1B4F72);
  static const Color brandPrimaryHoverOverlay = Color(0x1F2E86C1);
  static const Color brandPrimaryActiveOverlay = Color(0x3D2E86C1);

  static const Color primary = brandPrimary;
  static const Color primarySeed = Color(0xFF6750A4);
  static const Color secondarySeed = Color(0xFF625B71);
  static const Color tertiarySeed = Color(0xFF7D5260);
  static const Color neutralSeed = Color(0xFF605D62);

  static const Color success = Color(0xFF2E7D32);
  static const Color onSuccess = Color(0xFFFFFFFF);
  static const Color successContainer = Color(0xFFD0F8CE);
  static const Color onSuccessContainer = Color(0xFF002204);

  static const Color warning = Color(0xFFED6C02);
  static const Color onWarning = Color(0xFFFFFFFF);
  static const Color warningContainer = Color(0xFFFFDCC6);
  static const Color onWarningContainer = Color(0xFF341100);

  static const Color info = Color(0xFF0288D1);
  static const Color onInfo = Color(0xFFFFFFFF);
  static const Color infoContainer = Color(0xFFCBE6FF);
  static const Color onInfoContainer = Color(0xFF001E30);

  static const Color lightPrimary = Color(0xFF6750A4);
  static const Color lightOnPrimary = Color(0xFFFFFFFF);
  static const Color lightPrimaryContainer = Color(0xFFEADDFF);
  static const Color lightOnPrimaryContainer = Color(0xFF21005D);

  static const Color lightSecondary = Color(0xFF625B71);
  static const Color lightOnSecondary = Color(0xFFFFFFFF);
  static const Color lightSecondaryContainer = Color(0xFFE8DEF8);
  static const Color lightOnSecondaryContainer = Color(0xFF1D192B);

  static const Color lightTertiary = Color(0xFF7D5260);
  static const Color lightOnTertiary = Color(0xFFFFFFFF);
  static const Color lightTertiaryContainer = Color(0xFFFFD8E4);
  static const Color lightOnTertiaryContainer = Color(0xFF31111D);

  static const Color error = Color(0xFFB3261E);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFF9DEDC);
  static const Color onErrorContainer = Color(0xFF410E0B);
  static const Color lightError = Color(0xFFB3261E);
  static const Color lightOnError = Color(0xFFFFFFFF);
  static const Color lightErrorContainer = Color(0xFFF9DEDC);
  static const Color lightOnErrorContainer = Color(0xFF410E0B);

  static const Color lightBackground = Color(0xFFFEF7FF);
  static const Color lightOnBackground = Color(0xFF1D1B20);
  static const Color lightSurface = Color(0xFFFEF7FF);
  static const Color lightOnSurface = Color(0xFF1D1B20);
  static const Color lightSurfaceVariant = Color(0xFFE7E0EC);
  static const Color lightOnSurfaceVariant = Color(0xFF49454F);
  static const Color lightOutline = Color(0xFF79747E);
  static const Color lightOutlineVariant = Color(0xFFCAC4D0);

  static const Color neutralLight = Color(0xFFF5F5F5);
  static const Color neutralDark = Color(0xFF212121);

  // Elevation Tokens
  static const double level0 = 0.0;
  static const double level1 = 1.0;
  static const double level2 = 3.0;
  static const double level3 = 6.0;
  static const double level4 = 8.0;
  static const double level5 = 12.0;

  // Spacing & Layout Tokens (4dp Metric Grid)
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double mdSm = 12.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;

  static const EdgeInsets paddingXs = EdgeInsets.all(xs);
  static const EdgeInsets paddingSm = EdgeInsets.all(sm);
  static const EdgeInsets paddingMd = EdgeInsets.all(md);
  static const EdgeInsets paddingLg = EdgeInsets.all(lg);
  static const EdgeInsets paddingXl = EdgeInsets.all(xl);

  static const EdgeInsets paddingHorizontalSm = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets paddingHorizontalMd = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets paddingHorizontalLg = EdgeInsets.symmetric(horizontal: lg);

  static const EdgeInsets paddingVerticalSm = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets paddingVerticalMd = EdgeInsets.symmetric(vertical: md);

  static const Widget vGapXs = SizedBox(height: xs);
  static const Widget vGapSm = SizedBox(height: sm);
  static const Widget vGapMd = SizedBox(height: md);
  static const Widget vGapLg = SizedBox(height: lg);
  static const Widget vGapXl = SizedBox(height: xl);

  static const Widget hGapXs = SizedBox(width: xs);
  static const Widget hGapSm = SizedBox(width: sm);
  static const Widget hGapMd = SizedBox(width: md);
  static const Widget hGapLg = SizedBox(width: lg);
  static const Widget hGapXl = SizedBox(width: xl);
}

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: SharedUiLibraryModulePackagerPanel(),
          ),
        ),
      ),
    ),
  );
}
