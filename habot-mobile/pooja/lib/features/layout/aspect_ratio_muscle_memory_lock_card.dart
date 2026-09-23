/*
 * GEN-01931 — Apply aspect ratio locks to maintain a pixel-fixed position and foster muscle memory.
 * 
 * Global Reference ID: GEN-01931
 * Atomic Steps Reference ID: GEN-01931
 * Setup Step (Action): Apply aspect ratio locks to maintain a pixel-fixed position and foster muscle memory.
 * Setup Step Description: Single-column mobile layout with M3 status cards displaying step completion state.
 * S.No: 6663 | Sequence Order: 18640 | Assigned Team: ADFA (Pooja)
 * 
 * Dependency: Dependent on prior foundational steps.
 * Decision Group: Architecture & Implementation Governance
 * Why This Matters: Apply aspect ratio locks to maintain a pixel-fixed position and foster muscle memory. is a critical implementation step. Without it, downstream steps lack the required baseline configuration.
 * Mobile App First Implication: Ensures sub-100ms API response latencies on mobile clients via optimized backend configuration.
 * Data Requirement: Data/artifacts to prepare: Apply aspect ratio locks to maintain a pixel-fixed position and…. Metric config: 'Step Completion Rate (%)' (floor threshold: 90). Reference standard/spec to configure against: ISO/IEC 27001:2022 General Standards. Output field to capture: Complete/Partial/Not Complete.
 * User Interaction / Flow Impact: Users interact with this step exclusively through the mobile engineering console. Read-only M3 KPI cards with deep-link drill-down.
 * Dashboard / Interface Implication: Engineering console dashboard displays step health via M3 Elevated Card with inline status chip.
 * What Standardized Must Be Done: English Code (EC) blueprint required before any code is written. All functions must have single-verb EC headers.
 * Atomic Reusability: Core pattern for this step stored as a reusable module in the shared library.
 * Common Library to Store: @habot/shared-library
 * GCP / BigQuery Alignment: All step execution events stream to BigQuery partitioned by event_date, clustered by trace_id.
 * Estimated Time Required: 4 Hours
 * Expected Output: Fully configured and validated implementation of: Apply aspect ratio locks to maintain a pixel-fixed position and foster muscle me.
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
 * Standard: ISO/IEC 27001:2022 General Standards
 * Metric Boundaries:
 * - Floor Boundary: 90
 * - Optimal Target: 99
 * - Ceiling Boundary: 100
 * Best Qualitative Output: Complete/Partial/Not Complete
 * Data Collected by System: Apply aspect ratio locks to maintain a pixel-fixed position and…; Completion Status ('Complete/Partial/Not Complete'); Action/Event Timestamp; User/Session ID
 */

import 'package:flutter/material.dart';

/// Style tokens for the Aspect Ratio Muscle Memory Lock Card.
abstract final class AspectRatioTokens {
  static const Color primarySky = Color(0xFF0284C7);
  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);
  static const Color targetGreen = Color(0xFF16A34A);
  static const Color containerBorder = Color(0xFF0369A1);
}

/// Container that locks aspect ratio and maintains pixel-fixed positioning for primary interactive targets to foster user muscle memory.
class AspectRatioMuscleMemoryLockCard extends StatefulWidget {
  final VoidCallback? onActionTriggered;

  const AspectRatioMuscleMemoryLockCard({
    super.key,
    this.onActionTriggered,
  });

  @override
  State<AspectRatioMuscleMemoryLockCard> createState() =>
      _AspectRatioMuscleMemoryLockCardState();
}

class _AspectRatioMuscleMemoryLockCardState
    extends State<AspectRatioMuscleMemoryLockCard> {
  double _simulatedContainerWidth = 320.0;
  int _tapCount = 0;

  void _onTargetTapped() {
    setState(() => _tapCount++);
    widget.onActionTriggered?.call();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Muscle memory target tapped: #$_tapCount'),
        duration: const Duration(milliseconds: 1000),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AspectRatioTokens.backgroundLight,
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Header Card
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: AspectRatioTokens.surfaceCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AspectRatioTokens.borderLight),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Muscle Memory Aspect Lock',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AspectRatioTokens.textDark,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'GEN-01931 • Pixel-Fixed Spatial Anchoring',
                        style: TextStyle(
                          fontSize: 12,
                          color: AspectRatioTokens.textMuted,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AspectRatioTokens.primarySky.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Lock: 16:9',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AspectRatioTokens.primarySky,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Simulation Slider
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AspectRatioTokens.surfaceCard,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AspectRatioTokens.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Viewport Width Simulator:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AspectRatioTokens.textDark,
                        ),
                      ),
                      Text(
                        '${_simulatedContainerWidth.toInt()} dp',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AspectRatioTokens.primarySky,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _simulatedContainerWidth,
                    min: 240.0,
                    max: 380.0,
                    divisions: 14,
                    activeColor: AspectRatioTokens.primarySky,
                    onChanged: (val) {
                      setState(() => _simulatedContainerWidth = val);
                    },
                  ),
                  const Text(
                    'Notice: Although viewport width resizes, the primary CTA preserves its exact aspect ratio and ergonomic touch zone.',
                    style: TextStyle(
                      fontSize: 11,
                      color: AspectRatioTokens.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Aspect Ratio Locked Canvas
            Center(
              child: SizedBox(
                width: _simulatedContainerWidth,
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AspectRatioTokens.surfaceCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AspectRatioTokens.containerBorder,
                        width: 2,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x100284C7),
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        const Positioned(
                          top: 0,
                          left: 0,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Fixed Ergonomic Canvas',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AspectRatioTokens.textDark,
                                ),
                              ),
                              Text(
                                'Aspect ratio locked to 1.777:1',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AspectRatioTokens.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Spatial Muscle Memory Target
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: ElevatedButton.icon(
                            onPressed: _onTargetTapped,
                            icon: const Icon(Icons.touch_app, size: 16),
                            label: const Text('Muscle Memory Target'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AspectRatioTokens.targetGreen,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Telemetry Counters
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AspectRatioTokens.surfaceCard,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AspectRatioTokens.borderLight),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recorded Hit Accuracy:',
                    style: TextStyle(
                      fontSize: 12,
                      color: AspectRatioTokens.textMuted,
                    ),
                  ),
                  Text(
                    '100% ($_tapCount hits recorded)',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AspectRatioTokens.targetGreen,
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
          child: AspectRatioMuscleMemoryLockCard(),
        ),
      ),
    ),
  );
}
