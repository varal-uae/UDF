// ============================================================================
// ARCHITECTURAL TRACKING METADATA BLOCK
// Architecture Pattern: Binary Semantic Color Gate System & Theme Extension
// Component Hierarchy: BinarySemanticColorSystem -> BinarySemanticStatusBadge -> GateAuditTable
// Accessibility: WCAG 2.1 AA & AAA Contrast Compliance for Outdoor Sunlight Visibility
// Mistake-Proofing: The Raw Hex Assassin Linter Gate
// Completion Status: Complete (Ref: TTMCS-002-A01)
// ============================================================================

import 'package:flutter/material.dart';
import '../theme/semantic_colors.dart';
import '../widgets/binary_semantic_status_badge.dart';

/// TTMCS-002-A01: Binary Semantic Color System Showcase
/// Demonstrates binary state color gates (Green for True/Compliant, Red for False/Non-compliant)
/// with bold text treatments and dynamic adaptation to light and dark modes.
class BinarySemanticColorSystem extends StatefulWidget {
  const BinarySemanticColorSystem({super.key});

  @override
  State<BinarySemanticColorSystem> createState() =>
      _BinarySemanticColorSystemState();
}

class _BinarySemanticColorSystemState extends State<BinarySemanticColorSystem> {
  bool _pressureGatePassed = true;
  bool _radiationSealCompliant = false;
  bool _telemetryGateValid = true;
  bool _emergencyValveSealed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantic = theme.extension<SemanticColors>() ??
        (theme.brightness == Brightness.dark
            ? SemanticColors.dark
            : SemanticColors.light);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.palette_outlined,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BINARY SEMANTIC COLOR SYSTEM',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    Text(
                      'High-Contrast Field State Gates (WCAG AAA)',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // High Contrast State Tokens Overview
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Active Semantic Tokens (${theme.brightness.name.toUpperCase()} MODE)',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tokens adapt dynamically to environment lighting while maintaining >= 7.0:1 contrast.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      // Compliant True Token Card
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: semantic.successContainer,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: semantic.success, width: 2),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.check_circle, color: semantic.onSuccessContainer),
                                  const SizedBox(width: 8),
                                  Text(
                                    'TRUE / PASS',
                                    style: TextStyle(
                                      color: semantic.onSuccessContainer,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Token: semantic.success',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: semantic.onSuccessContainer,
                                ),
                              ),
                              Text(
                                'Contrast: 7.8:1 (AAA Pass)',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: semantic.onSuccessContainer,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Non-compliant False Token Card
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: semantic.errorContainer,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: semantic.error, width: 2),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.cancel, color: semantic.onErrorContainer),
                                  const SizedBox(width: 8),
                                  Text(
                                    'FALSE / FAIL',
                                    style: TextStyle(
                                      color: semantic.onErrorContainer,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Token: semantic.error',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: semantic.onErrorContainer,
                                ),
                              ),
                              Text(
                                'Contrast: 8.2:1 (AAA Pass)',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: semantic.onErrorContainer,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Field Worker Safety Telemetry Table
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Field Operational Gate Matrix',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Instant binary feedback allows field personnel to verify parameters instantly without reading dense tables.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Divider(height: 24),

                  _buildGateTile(
                    title: 'Hydraulic Pressure Threshold (>= 3200 PSI)',
                    subtitle: 'Sensor Node #04 - Main Line Pressure',
                    isCompliant: _pressureGatePassed,
                    onToggle: () => setState(() => _pressureGatePassed = !_pressureGatePassed),
                  ),
                  const Divider(),
                  _buildGateTile(
                    title: 'Radiation Containment Perimeter Seal',
                    subtitle: 'Chamber 12 - Micro-vacuum barrier',
                    isCompliant: _radiationSealCompliant,
                    onToggle: () => setState(() => _radiationSealCompliant = !_radiationSealCompliant),
                  ),
                  const Divider(),
                  _buildGateTile(
                    title: 'Real-time Uplink Cryptographic Hash',
                    subtitle: 'Telemetry Bus - SHA-256 integrity check',
                    isCompliant: _telemetryGateValid,
                    onToggle: () => setState(() => _telemetryGateValid = !_telemetryGateValid),
                  ),
                  const Divider(),
                  _buildGateTile(
                    title: 'Emergency Cryogenic Relief Valve',
                    subtitle: 'Auxiliary Vent #02 - Secondary locking mechanism',
                    isCompliant: _emergencyValveSealed,
                    onToggle: () => setState(() => _emergencyValveSealed = !_emergencyValveSealed),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // The Raw Hex Assassin Linter & Gate Box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.error.withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.security, color: theme.colorScheme.error),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Poka-Yoke: The Raw Hex Assassin Enforced',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.error,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'CI/CD runs scripts/raw_hex_assassin.sh. Raw color declarations like Color(0xFF...) and Colors.red are forbidden in UI code. All components must query Theme.of(context).extension<SemanticColors>()! to guarantee dynamic contrast compliance.',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGateTile({
    required String title,
    required String subtitle,
    required bool isCompliant,
    required VoidCallback onToggle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          BinarySemanticStatusBadge(
            isCompliant: isCompliant,
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'Simulate Sensor Change',
            icon: const Icon(Icons.sync, size: 20),
            onPressed: onToggle,
          ),
        ],
      ),
    );
  }
}
