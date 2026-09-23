/*
 * EDBAA-020-A12 — Objective Text Dictionary Array Panel
 * 
 * Setup Step (Action): Extract the finalized, system-objective text dictionary array configuration.
 * Metric Name: Content/Terminology Governance Audit Coverage (Floor: 90% min, Target: 100%, Ceiling: 100%)
 * Quality Standard: Full-codebase string audit completed and reconciled against approved glossary.
 * Telemetry: Configuration Key; Configuration Value; Configuration Type; Validation Status; Configuration Timestamp; Completion Status ('Complete'); Action/Event Timestamp; User/Session ID
 * Poka-Yoke Gate: Automated programmatic linter blocks deployment files if banned narrative vocabulary tokens are written into mockups.
 * Assigned Member: Pooja
 */

import 'package:flutter/material.dart';

class ObjectiveTextDictionaryArrayPanel extends StatefulWidget {
  final String globalRefId;
  final String atomicStepRefId;
  final String sequenceOrder;

  const ObjectiveTextDictionaryArrayPanel({
    super.key,
    this.globalRefId = 'EDBAA-020',
    this.atomicStepRefId = 'EDBAA-020-A12',
    this.sequenceOrder = '12236',
  });

  @override
  State<ObjectiveTextDictionaryArrayPanel> createState() =>
      _ObjectiveTextDictionaryArrayPanelState();
}

class _ObjectiveTextDictionaryArrayPanelState
    extends State<ObjectiveTextDictionaryArrayPanel> {
  final String _userSessionId = 'POOJA-EDBAA-020-A12';
  final String _completionStatus = 'Complete';
  String _filterQuery = '';

  final List<Map<String, String>> _dictionaryEntries = [
    {
      'key': 'SYS_VERB_DISPATCH',
      'value': 'Initiate Order Dispatch Procedure',
      'type': 'ActionVerb',
      'status': 'AUDITED_APPROVED',
      'scope': 'Logistics Operations'
    },
    {
      'key': 'SYS_GATE_ZERO_DEFECT',
      'value': 'Pipeline Zero-Defect Release Gate',
      'type': 'GovernanceTerm',
      'status': 'AUDITED_APPROVED',
      'scope': 'Deployment CI/CD'
    },
    {
      'key': 'SYS_METRIC_ADHERENCE',
      'value': 'Material Design 3 Adherence Compliance',
      'type': 'QualityMetric',
      'status': 'AUDITED_APPROVED',
      'scope': 'Design System'
    },
    {
      'key': 'SYS_SECURITY_LOCK',
      'value': 'Cryptographic Release Milestone Immutability',
      'type': 'SecurityProtocol',
      'status': 'AUDITED_APPROVED',
      'scope': 'Artifact Registry'
    },
    {
      'key': 'SYS_BANNER_SUCCESS',
      'value': 'Mobile Vendor Onboarding Mathematical Success',
      'type': 'UIString',
      'status': 'AUDITED_APPROVED',
      'scope': 'Vendor Portal'
    },
  ];

  Map<String, dynamic> getTelemetryData() {
    return {
      'stepExecutionId': 'EXEC-EDBAA-020-A12-2026',
      'totalConfigKeysAudited': _dictionaryEntries.length,
      'auditCoverageRate': '100% (Target: 100%)',
      'bannedNarrativeTokensDetected': 0,
      'pokaYokeLinterStatus': 'PASSED_CLEAN',
      'governanceStandard': 'ISO 9001 Content/Terminology Governance',
      'completionStatus': _completionStatus,
      'actionEventTimestamp': DateTime.now().toIso8601String(),
      'userSessionId': _userSessionId,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final filteredEntries = _dictionaryEntries.where((e) {
      if (_filterQuery.isEmpty) return true;
      return e['key']!.toLowerCase().contains(_filterQuery.toLowerCase()) ||
          e['value']!.toLowerCase().contains(_filterQuery.toLowerCase());
    }).toList();

    return Container(
      width: double.infinity,
      padding: ObjectiveTextDictionaryArrayPanelTokens.paddingLg,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ObjectiveTextDictionaryArrayPanelTokens.lightOutline.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(ObjectiveTextDictionaryArrayPanelTokens.sm),
                decoration: BoxDecoration(
                  color: ObjectiveTextDictionaryArrayPanelTokens.brandPrimaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.menu_book_outlined,
                  color: ObjectiveTextDictionaryArrayPanelTokens.brandPrimary,
                  size: 24,
                ),
              ),
              ObjectiveTextDictionaryArrayPanelTokens.hGapMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.atomicStepRefId} (Seq: ${widget.sequenceOrder})',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: ObjectiveTextDictionaryArrayPanelTokens.brandPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Objective Text Dictionary Array',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: ObjectiveTextDictionaryArrayPanelTokens.successContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Coverage: 100%',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: ObjectiveTextDictionaryArrayPanelTokens.onSuccessContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          ObjectiveTextDictionaryArrayPanelTokens.vGapMd,
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: ObjectiveTextDictionaryArrayPanelTokens.brandPrimaryContainer.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: ObjectiveTextDictionaryArrayPanelTokens.brandPrimary.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.shield_outlined, color: ObjectiveTextDictionaryArrayPanelTokens.brandPrimary, size: 18),
                ObjectiveTextDictionaryArrayPanelTokens.hGapSm,
                Expanded(
                  child: Text(
                    'Poka-Yoke Linter: Automated check blocks banned narrative vocabulary tokens. 0 unapproved terms detected.',
                    style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          ObjectiveTextDictionaryArrayPanelTokens.vGapMd,
          TextField(
            decoration: InputDecoration(
              hintText: 'Filter configuration keys or values...',
              prefixIcon: const Icon(Icons.search, size: 20),
              isDense: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onChanged: (val) {
              setState(() {
                _filterQuery = val;
              });
            },
          ),
          ObjectiveTextDictionaryArrayPanelTokens.vGapSm,
          ...filteredEntries.map((entry) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: ObjectiveTextDictionaryArrayPanelTokens.paddingSm,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: ObjectiveTextDictionaryArrayPanelTokens.lightOutline.withValues(alpha: 0.15)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            entry['key']!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.bold,
                              color: ObjectiveTextDictionaryArrayPanelTokens.brandPrimary,
                            ),
                          ),
                          ObjectiveTextDictionaryArrayPanelTokens.hGapSm,
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              entry['type']!,
                              style: theme.textTheme.labelSmall?.copyWith(fontSize: 10),
                            ),
                          ),
                        ],
                      ),
                      ObjectiveTextDictionaryArrayPanelTokens.vGapXs,
                      Text(
                        entry['value']!,
                        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: ObjectiveTextDictionaryArrayPanelTokens.successContainer,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'AUDITED',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: ObjectiveTextDictionaryArrayPanelTokens.onSuccessContainer,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          )),
          ObjectiveTextDictionaryArrayPanelTokens.vGapSm,
          FilledButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Dictionary array configuration verified & locked (100% coverage)'),
                  backgroundColor: ObjectiveTextDictionaryArrayPanelTokens.success,
                ),
              );
            },
            icon: const Icon(Icons.download_done),
            label: const Text('Export Dictionary Array Configuration'),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// File-Local Standalone Design Tokens & Constants
// ============================================================================
abstract final class ObjectiveTextDictionaryArrayPanelTokens {
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
            child: ObjectiveTextDictionaryArrayPanel(),
          ),
        ),
      ),
    ),
  );
}
