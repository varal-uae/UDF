/*
 * GEN-01898 — Store the standard implementation in the Compliance Utils library.
 * 
 * Global Reference ID: GEN-01898
 * Atomic Steps Reference ID: GEN-01898
 * Setup Step (Action): Store the standard implementation in the Compliance Utils library.
 * Setup Step Description: Single-column mobile layout with M3 status cards displaying step completion state.
 * S.No: 6636 | Sequence Order: 18607 | Assigned Team: GFD (Pooja)
 * 
 * Dependency: Dependent on prior foundational steps.
 * Decision Group: Architecture & Implementation Governance
 * Why This Matters: Store the standard implementation in the Compliance Utils library. is a critical implementation step. Without it, downstream steps lack the required baseline configuration.
 * Mobile App First Implication: Ensures sub-100ms API response latencies on mobile clients via optimized backend configuration.
 * Data Requirement: Data/artifacts to prepare: Store the standard implementation in the Compliance Utils library.. Metric config: 'Compliance Gate Pass Rate (%)' (floor threshold: 98). Reference standard/spec to configure against: ISO/IEC 27001:2022 Compliance & Regulatory Standards. Output field to capture: Pass/Fail.
 * User Interaction / Flow Impact: Users interact with this step exclusively through the mobile engineering console. Read-only M3 KPI cards with deep-link drill-down.
 * Dashboard / Interface Implication: Engineering console dashboard displays step health via M3 Elevated Card with inline status chip.
 * What Standardized Must Be Done: English Code (EC) blueprint required before any code is written. All functions must have single-verb EC headers.
 * Atomic Reusability: Core pattern for this step stored as a reusable module in the shared library.
 * Common Library to Store: @habot/shared-library
 * GCP / BigQuery Alignment: All step execution events stream to BigQuery partitioned by event_date, clustered by trace_id.
 * Estimated Time Required: 4 Hours
 * Expected Output: Fully configured and validated implementation of: Store the standard implementation in the Compliance Utils library..
 * Completion Measures: 100% CI/CD pass rate. All validation checks passing. Documentation committed to runbook.
 * M3 UX Decision: M3 responsive layout: single-column on mobile (<600dp), multi-column on desktop (≥840dp).
 * M3 UI Decision: M3 Elevated Cards Level 2 (3dp). M3 Status Chips for health indicators. 48x48dp touch targets.
 * M3 UX Implementation: Background polling refreshes data every 30 seconds. Pull-to-refresh triggers manual sync.
 * M3 UI Implementation: M3 Bottom Sheet for configuration inputs. M3 Snackbar for confirmations. Material You dynamic color.
 * Domain Expertise Needed: Mobile Engineering, GCP Architecture, UX/UI Design (MD3), DCDF Engine Architecture.
 * Mistake-Proofing (Poka-Yoke): CI/CD pipeline physically blocks deployment if any gate for this step fails.
 * Self-Chasing: Automated Liveness Handshake monitors this step every 30 seconds and triggers rollback on failure.
 * Vitality & Prosperity (Us): Eliminates manual overhead, reduces operational cost, and protects revenue pipelines.
 * Vitality & Prosperity (Customer): Engineers and end-users experience reliable, uninterrupted platform performance.
 * Responsive UX/UI Design: M3 responsive single-column on mobile, multi-panel on tablet/desktop. 48x48dp touch targets.
 * Vitality & Prosperity (VAP): Us: Eliminates manual overhead and reduces operational cost. | Customer: Reliable, uninterrupted platform performance.
 * 
 * AUDIT NOTICE & BOUNDARY TARGETS:
 * Standard: ISO/IEC 27001:2022 Compliance & Regulatory Standards
 * Metric Boundaries:
 * - Floor Boundary: 98
 * - Optimal Target: 100
 * - Ceiling Boundary: 100
 * Best Qualitative Output: Pass/Fail
 * Data Collected by System: Store the standard implementation in the Compliance Utils library.; Completion Status ('Pass/Fail'); Action/Event Timestamp; User/Session ID
 */

import 'package:flutter/material.dart';

/// Style tokens for the Compliance Utils Registry Console.
abstract final class ComplianceUtilsTokens {
  static const Color primaryIndigo = Color(0xFF4338CA);
  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);
  static const Color successGreen = Color(0xFF16A34A);
  static const Color codeBackground = Color(0xFF0F172A);
  static const Color codeHighlight = Color(0xFF818CF8);
}

/// Catalog entry for standardized compliance utility module.
class ComplianceUtilEntry {
  final String id;
  final String name;
  final String standardRef;
  final String description;
  final String sampleFunctionSignature;

  const ComplianceUtilEntry({
    required this.id,
    required this.name,
    required this.standardRef,
    required this.description,
    required this.sampleFunctionSignature,
  });
}

/// Central registry console storing and executing standard implementations in the Compliance Utils library.
class ComplianceUtilsRegistryConsole extends StatefulWidget {
  final ValueChanged<String>? onUtilitySelected;

  const ComplianceUtilsRegistryConsole({
    super.key,
    this.onUtilitySelected,
  });

  @override
  State<ComplianceUtilsRegistryConsole> createState() =>
      _ComplianceUtilsRegistryConsoleState();
}

class _ComplianceUtilsRegistryConsoleState
    extends State<ComplianceUtilsRegistryConsole> {
  int _selectedUtilityIndex = 0;
  final TextEditingController _testInputController =
      TextEditingController(text: 'user.john_doe@enterprise-client.com');
  String _liveSanitizedOutput = 'u***.j***@enterprise-client.com';

  final List<ComplianceUtilEntry> _utilities = const [
    ComplianceUtilEntry(
      id: 'COMP-UTIL-01',
      name: 'PiiMaskingSanitizer',
      standardRef: 'ISO/IEC 27001:2022 A.8.11',
      description:
          'Masks personally identifiable information (PII) before telemetry ingestion and persistent logging.',
      sampleFunctionSignature:
          'String maskPii(String rawEmail, {bool preserveDomain = true})',
    ),
    ComplianceUtilEntry(
      id: 'COMP-UTIL-02',
      name: 'CryptographicAuditHasher',
      standardRef: 'ISO/IEC 27001:2022 A.8.24',
      description:
          'Computes immutable SHA-256 HMAC integrity hashes for all transactional state transitions.',
      sampleFunctionSignature:
          'String computeHmac(String payload, String secretKey)',
    ),
    ComplianceUtilEntry(
      id: 'COMP-UTIL-03',
      name: 'DataRetentionEvaluator',
      standardRef: 'ISO/IEC 27001:2022 A.8.10',
      description:
          'Calculates statutory retention thresholds and tags expired record partitions for automated purge.',
      sampleFunctionSignature:
          'bool isRecordExpired(DateTime creationDate, Duration retentionCap)',
    ),
  ];

  @override
  void dispose() {
    _testInputController.dispose();
    super.dispose();
  }

  void _runLiveSanitization(String input) {
    setState(() {
      if (input.contains('@')) {
        final parts = input.split('@');
        final user = parts[0];
        final domain = parts.length > 1 ? parts[1] : '';
        final maskedUser = user.length > 2
            ? '${user[0]}***${user[user.length - 1]}'
            : '***';
        _liveSanitizedOutput = '$maskedUser@$domain';
      } else if (input.length > 4) {
        _liveSanitizedOutput = '***${input.substring(input.length - 4)}';
      } else {
        _liveSanitizedOutput = '***';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final activeUtil = _utilities[_selectedUtilityIndex];

    return Container(
      color: ComplianceUtilsTokens.backgroundLight,
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Header Card
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: ComplianceUtilsTokens.surfaceCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: ComplianceUtilsTokens.borderLight),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Compliance Utils Library',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: ComplianceUtilsTokens.textDark,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'GEN-01898 • ISO/IEC 27001 Standard Implementations',
                        style: TextStyle(
                          fontSize: 12,
                          color: ComplianceUtilsTokens.textMuted,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: ComplianceUtilsTokens.primaryIndigo
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '3 Modules',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: ComplianceUtilsTokens.primaryIndigo,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Utility Selector List
            ...List.generate(_utilities.length, (index) {
              final util = _utilities[index];
              final isSelected = index == _selectedUtilityIndex;
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedUtilityIndex = index);
                  widget.onUtilitySelected?.call(util.id);
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? ComplianceUtilsTokens.primaryIndigo
                            .withValues(alpha: 0.05)
                        : ComplianceUtilsTokens.surfaceCard,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? ComplianceUtilsTokens.primaryIndigo
                          : ComplianceUtilsTokens.borderLight,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        color: isSelected
                            ? ComplianceUtilsTokens.primaryIndigo
                            : ComplianceUtilsTokens.textMuted,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              util.name,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? ComplianceUtilsTokens.primaryIndigo
                                    : ComplianceUtilsTokens.textDark,
                              ),
                            ),
                            Text(
                              util.standardRef,
                              style: const TextStyle(
                                fontSize: 11,
                                color: ComplianceUtilsTokens.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),

            // Active Utility Details Card
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: ComplianceUtilsTokens.surfaceCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: ComplianceUtilsTokens.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        activeUtil.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: ComplianceUtilsTokens.textDark,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: ComplianceUtilsTokens.successGreen
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'STANDARDIZED',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: ComplianceUtilsTokens.successGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    activeUtil.description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: ComplianceUtilsTokens.textMuted,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: ComplianceUtilsTokens.codeBackground,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      activeUtil.sampleFunctionSignature,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        color: ComplianceUtilsTokens.codeHighlight,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Live Testing Sandbox
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: ComplianceUtilsTokens.surfaceCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: ComplianceUtilsTokens.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Interactive Live Sandbox',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: ComplianceUtilsTokens.textDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _testInputController,
                    onChanged: _runLiveSanitization,
                    decoration: InputDecoration(
                      labelText: 'Sample Input Data',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: ComplianceUtilsTokens.backgroundLight,
                      borderRadius: BorderRadius.circular(8),
                      border:
                          Border.all(color: ComplianceUtilsTokens.borderLight),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Masked Output:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: ComplianceUtilsTokens.textDark,
                          ),
                        ),
                        Text(
                          _liveSanitizedOutput,
                          style: const TextStyle(
                            fontSize: 12,
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.bold,
                            color: ComplianceUtilsTokens.successGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: ComplianceUtilsRegistryConsole(),
        ),
      ),
    ),
  );
}
