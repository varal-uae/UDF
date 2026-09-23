import 'package:flutter/material.dart';

/// Row 241 - FEBFL-023-A16 (Seq 15206)
/// Action: Commit the visual isolation code updates to the layout repository branch.
/// Metric: Version Control Compliance (%) | Floor: 90% | Target: 98% | Ceiling: 100% | Unit: Complete/Partial/Not Complete
/// Standard: Traceable, peer-reviewed commits baseline for auditable engineering.
class VisualIsolationBranchCommitPanel extends StatefulWidget {
  const VisualIsolationBranchCommitPanel({super.key});

  @override
  State<VisualIsolationBranchCommitPanel> createState() =>
      _VisualIsolationBranchCommitPanelState();
}

class _VisualIsolationBranchCommitPanelState
    extends State<VisualIsolationBranchCommitPanel> {
  final String _repoUrl = 'git@github.com:habot/habot-mobile-enterprise.git';
  final String _repoBranch = 'feature/febfl-023-visual-isolation';
  final String _accessRights = 'Protected Branch (Requires Signed Commits & PR Review)';
  final String _repoVersion = 'v2.5.0-rc1';
  final String _cloneStatus = 'CLONED_CLEAN_WORKING_TREE';
  final String _completionStatus = 'Complete';
  final String _userSessionId = 'POOJA-FEBFL-023-A16';

  final List<Map<String, String>> _commitHistory = const [
    {
      'sha': '7a4b91f',
      'message': 'feat(layout): enforce single-root focal action pattern on dashboard',
      'author': 'Pooja <pooja@habot.io>',
      'status': 'PEER_REVIEWED_PASSED',
    },
    {
      'sha': '9c2e401',
      'message': 'refactor(ui): remove redundant secondary root buttons to avoid choice paralysis',
      'author': 'Pooja <pooja@habot.io>',
      'status': 'PEER_REVIEWED_PASSED',
    },
    {
      'sha': '3f18b77',
      'message': 'test(poka-yoke): add linter check blocking multiple primary root buttons',
      'author': 'Pooja <pooja@habot.io>',
      'status': 'PEER_REVIEWED_PASSED',
    },
  ];

  final DateTime _lastCommitTimestamp = DateTime.now();

  Map<String, dynamic> getTelemetryData() {
    return {
      'Repository URL': _repoUrl,
      'Repository Branch': _repoBranch,
      'Access Rights': _accessRights,
      'Commit History': '${_commitHistory.length} commits verified',
      'Repository Version': _repoVersion,
      'Clone Status': _cloneStatus,
      'Compliance Rate': '99.1% (Target: ≥98%)',
      'Completion Status': _completionStatus,
      'Action/Event Timestamp': _lastCommitTimestamp.toIso8601String(),
      'User/Session ID': _userSessionId,
      'Poka-Yoke Status': 'COMPILER_GATE_ACTIVE_BLOCKING_MULTI_ROOT',
    };
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: VisualIsolationBranchCommitPanelTokens.paddingMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeaderCard(),
          VisualIsolationBranchCommitPanelTokens.vGapMd,
          _buildRepoInfoCard(),
          VisualIsolationBranchCommitPanelTokens.vGapMd,
          _buildCommitHistoryCard(),
          VisualIsolationBranchCommitPanelTokens.vGapMd,
          _buildTelemetryCard(),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
        side: BorderSide(color: VisualIsolationBranchCommitPanelTokens.lightOutline.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: VisualIsolationBranchCommitPanelTokens.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.commit_outlined,
                  color: VisualIsolationBranchCommitPanelTokens.brandPrimary,
                  size: 22,
                ),
                VisualIsolationBranchCommitPanelTokens.hGapSm,
                const Expanded(
                  child: Text(
                    'Visual Isolation Branch Commit',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: VisualIsolationBranchCommitPanelTokens.brandPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: VisualIsolationBranchCommitPanelTokens.successContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Compliance: 99.1%',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: VisualIsolationBranchCommitPanelTokens.onSuccessContainer,
                    ),
                  ),
                ),
              ],
            ),
            VisualIsolationBranchCommitPanelTokens.vGapSm,
            Text(
              'Tracks peer-reviewed, traceable commits for the visual isolation updates to the repository branch, satisfying continuous version control compliance standards.',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRepoInfoCard() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
        side: BorderSide(color: VisualIsolationBranchCommitPanelTokens.lightOutline.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: VisualIsolationBranchCommitPanelTokens.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Git Repository Target Configuration',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: VisualIsolationBranchCommitPanelTokens.brandPrimary),
            ),
            VisualIsolationBranchCommitPanelTokens.vGapSm,
            _buildInfoRow('Branch', _repoBranch),
            _buildInfoRow('Version Tag', _repoVersion),
            _buildInfoRow('Access Policy', _accessRights),
            _buildInfoRow('Working Tree', _cloneStatus),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 11, fontFamily: 'monospace')),
          ),
        ],
      ),
    );
  }

  Widget _buildCommitHistoryCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
        side: BorderSide(color: VisualIsolationBranchCommitPanelTokens.lightOutline.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: VisualIsolationBranchCommitPanelTokens.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tracked & Reviewed Commits',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: VisualIsolationBranchCommitPanelTokens.brandPrimary),
            ),
            VisualIsolationBranchCommitPanelTokens.vGapSm,
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _commitHistory.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final commit = _commitHistory[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: VisualIsolationBranchCommitPanelTokens.brandPrimaryContainer,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      commit['sha']!,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'monospace', color: VisualIsolationBranchCommitPanelTokens.brandPrimary),
                    ),
                  ),
                  title: Text(commit['message']!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  subtitle: Text('${commit['author']} | ${commit['status']}', style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
                  trailing: const Icon(Icons.verified, color: VisualIsolationBranchCommitPanelTokens.success, size: 16),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTelemetryCard() {
    final telemetry = getTelemetryData();
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
        side: BorderSide(color: VisualIsolationBranchCommitPanelTokens.lightOutline.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: VisualIsolationBranchCommitPanelTokens.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Audit Telemetry',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: VisualIsolationBranchCommitPanelTokens.brandPrimary,
              ),
            ),
            VisualIsolationBranchCommitPanelTokens.vGapSm,
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
abstract final class VisualIsolationBranchCommitPanelTokens {
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
            child: VisualIsolationBranchCommitPanel(),
          ),
        ),
      ),
    ),
  );
}
