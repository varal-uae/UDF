/*
 * GEN-01887 — Test the functionality by allowing a timer to reach zero during data entry.
 * 
 * Global Reference ID: GEN-01887
 * Atomic Steps Reference ID: GEN-01887
 * Setup Step (Action): Test the functionality by allowing a timer to reach zero during data entry.
 * Setup Step Description: Single-column mobile layout with M3 status cards displaying step completion state.
 * S.No: 6628 | Sequence Order: 18596 | Assigned Team: ADFA (Pooja)
 * 
 * Dependency: Dependent on prior foundational steps.
 * Decision Group: Architecture & Implementation Governance
 * Why This Matters: Test the functionality by allowing a timer to reach zero during data entry. is a critical implementation step. Without it, downstream steps lack the required baseline configuration.
 * Mobile App First Implication: Ensures sub-100ms API response latencies on mobile clients via optimized backend configuration.
 * Data Requirement: Data/artifacts to prepare: Test the functionality by allowing a timer to reach zero…. Metric config: 'Test Case Success Rate (%)' (floor threshold: 95). Reference standard/spec to configure against: ISO/IEC 27001 Testing Standards. Output field to capture: Pass/Fail.
 * User Interaction / Flow Impact: Users interact with this step exclusively through the mobile engineering console. Read-only M3 KPI cards with deep-link drill-down.
 * Dashboard / Interface Implication: Engineering console dashboard displays step health via M3 Elevated Card with inline status chip.
 * What Standardized Must Be Done: English Code (EC) blueprint required before any code is written. All functions must have single-verb EC headers.
 * Atomic Reusability: Core pattern for this step stored as a reusable module in the shared library.
 * Common Library to Store: @habot/shared-library
 * GCP / BigQuery Alignment: All step execution events stream to BigQuery partitioned by event_date, clustered by trace_id.
 * Estimated Time Required: 4 Hours
 * Expected Output: Fully configured and validated implementation of: Test the functionality by allowing a timer to reach zero during data entry..
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
 * Standard: ISO/IEC 27001 Testing Standards
 * Metric Boundaries:
 * - Floor Boundary: 95
 * - Optimal Target: 99.5
 * - Ceiling Boundary: 100
 * Best Qualitative Output: Pass/Fail
 * Data Collected by System: Test the functionality by allowing a timer to reach zero…; Completion Status ('Pass/Fail'); Action/Event Timestamp; User/Session ID
 */

import 'dart:async';
import 'package:flutter/material.dart';

/// Style tokens for the SLA Timer Zero-Breach Tester.
abstract final class SlaBreachTokens {
  static const Color primaryCrimson = Color(0xFF991B1B);
  static const Color breachBannerBg = Color(0xFFFEF2F2);
  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);
  static const Color successGreen = Color(0xFF16A34A);
  static const Color alertRed = Color(0xFFDC2626);
  static const Color amberWarning = Color(0xFFD97706);
}

/// Test harness specifically simulating and validating system behavior when an SLA timer hits zero during data entry.
class SlaTimerZeroBreachTester extends StatefulWidget {
  final VoidCallback? onBreachHandled;

  const SlaTimerZeroBreachTester({
    super.key,
    this.onBreachHandled,
  });

  @override
  State<SlaTimerZeroBreachTester> createState() =>
      _SlaTimerZeroBreachTesterState();
}

class _SlaTimerZeroBreachTesterState extends State<SlaTimerZeroBreachTester> {
  final TextEditingController _sensitiveDataController =
      TextEditingController(text: 'TRX-9482751-CONFIDENTIAL');
  final TextEditingController _authCodeController =
      TextEditingController(text: 'SEC-8921');

  int _countdown = 10;
  Timer? _timer;
  bool _isBreached = false;
  bool _dataEncryptedAndQuarantined = false;
  int _breachIncidentCount = 0;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _sensitiveDataController.dispose();
    _authCodeController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() {
      _countdown = 10;
      _isBreached = false;
      _dataEncryptedAndQuarantined = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 1) {
        setState(() => _countdown--);
      } else {
        _timer?.cancel();
        _handleZeroBreach();
      }
    });
  }

  void _handleZeroBreach() {
    setState(() {
      _countdown = 0;
      _isBreached = true;
      _dataEncryptedAndQuarantined = true;
      _breachIncidentCount++;
    });
    widget.onBreachHandled?.call();
  }

  void _simulateRecoveryReauth() {
    setState(() {
      _dataEncryptedAndQuarantined = false;
      _isBreached = false;
      _countdown = 15;
    });
    _startCountdown();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Re-authenticated successfully. Form session decrypted and restored.',
        ),
        backgroundColor: SlaBreachTokens.successGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: SlaBreachTokens.backgroundLight,
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Card
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: SlaBreachTokens.surfaceCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: SlaBreachTokens.borderLight),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SLA Zero-Breach Tester',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: SlaBreachTokens.textDark,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'GEN-01887 • Expiration During Active Data Entry',
                        style: TextStyle(
                          fontSize: 12,
                          color: SlaBreachTokens.textMuted,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _isBreached
                          ? SlaBreachTokens.alertRed.withValues(alpha: 0.1)
                          : SlaBreachTokens.amberWarning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _isBreached ? 'BREACHED' : '00:${_countdown.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _isBreached
                            ? SlaBreachTokens.alertRed
                            : SlaBreachTokens.amberWarning,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Breach Alarm Banner
            if (_isBreached)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: SlaBreachTokens.breachBannerBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: SlaBreachTokens.alertRed),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: SlaBreachTokens.alertRed,
                      size: 28,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SLA ZERO BREACH TRIGGERED',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: SlaBreachTokens.alertRed,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Form session auto-frozen under ISO 27001 data protection protocols. Inputs quarantined.',
                            style: TextStyle(
                              fontSize: 11,
                              color: SlaBreachTokens.textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            if (_isBreached) const SizedBox(height: 16),

            // Live Input Form Under Test
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: SlaBreachTokens.surfaceCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isBreached
                      ? SlaBreachTokens.alertRed
                      : SlaBreachTokens.borderLight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Active Ledger Session Entry',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: SlaBreachTokens.textDark,
                        ),
                      ),
                      if (_dataEncryptedAndQuarantined)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: SlaBreachTokens.primaryCrimson
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.lock,
                                size: 12,
                                color: SlaBreachTokens.primaryCrimson,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'QUARANTINED',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: SlaBreachTokens.primaryCrimson,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _sensitiveDataController,
                    enabled: !_isBreached,
                    obscureText: _dataEncryptedAndQuarantined,
                    decoration: InputDecoration(
                      labelText: 'Confidential Payload ID',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.vpn_key, size: 18),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _authCodeController,
                    enabled: !_isBreached,
                    obscureText: _dataEncryptedAndQuarantined,
                    decoration: InputDecoration(
                      labelText: 'Operator Approval Hash',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.fingerprint, size: 18),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Incident Telemetry Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: SlaBreachTokens.surfaceCard,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: SlaBreachTokens.borderLight),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Breaches Simulated:',
                        style: TextStyle(
                          fontSize: 12,
                          color: SlaBreachTokens.textMuted,
                        ),
                      ),
                      Text(
                        '#$_breachIncidentCount incidents',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: SlaBreachTokens.textDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'State Quarantine Status:',
                        style: TextStyle(
                          fontSize: 12,
                          color: SlaBreachTokens.textMuted,
                        ),
                      ),
                      Text(
                        _dataEncryptedAndQuarantined
                            ? 'Encrypted in Memory'
                            : 'Active / Unlocked',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _dataEncryptedAndQuarantined
                              ? SlaBreachTokens.alertRed
                              : SlaBreachTokens.successGreen,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Action Buttons
            if (_isBreached)
              ElevatedButton.icon(
                onPressed: _simulateRecoveryReauth,
                icon: const Icon(Icons.lock_open, size: 16),
                label: const Text('Re-Authenticate & Decrypt Draft'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: SlaBreachTokens.successGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              )
            else
              ElevatedButton.icon(
                onPressed: () {
                  _timer?.cancel();
                  _handleZeroBreach();
                },
                icon: const Icon(Icons.timer_off, size: 16),
                label: const Text('Force Zero Breach Instantly'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: SlaBreachTokens.alertRed,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
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
          child: SlaTimerZeroBreachTester(),
        ),
      ),
    ),
  );
}
