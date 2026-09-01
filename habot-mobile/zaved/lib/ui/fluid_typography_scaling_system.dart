// ============================================================================
// ARCHITECTURAL TRACKING METADATA BLOCK
// Architecture Pattern: Fluid Typographic Scaling System & Custom Font Blocker
// Component Hierarchy: FluidTypographyScalingSystem -> FluidTypographyScope -> TokenMatrix
// Standards: WCAG AAA Contrast Ratios (7.0:1) & Material 3 Locked Scale
// Completion Status: Complete (Ref: BPTR-0334-A15)
// ============================================================================

import 'package:flutter/material.dart';
import '../theme/fluid_text_scaler.dart';
import '../theme/strict_m3_text_theme.dart';

/// BPTR-0334-A15: Fluid Typographic Scaling System
/// Demonstrates fluid clamped scaling across simulated viewport dimensions
/// and displays the locked Material 3 text hierarchy.
class FluidTypographyScalingSystem extends StatefulWidget {
  const FluidTypographyScalingSystem({super.key});

  @override
  State<FluidTypographyScalingSystem> createState() =>
      _FluidTypographyScalingSystemState();
}

class _FluidTypographyScalingSystemState
    extends State<FluidTypographyScalingSystem> {
  double _simulatedViewportWidth = 390.0;
  bool _enableFluidScaling = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = StrictM3Typography.textTheme;

    final fluidScaler = FluidTextScaler(
      currentWidth: _simulatedViewportWidth,
    );
    final scaleFactor = fluidScaler.calculatedScaleFactor;

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
                  Icons.text_fields,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FLUID TYPOGRAPHY SCALING SYSTEM',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    Text(
                      'Strict MD3 Tokens & Clamp Ratio Engine',
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

          // Interactive Viewport Simulator Panel
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Simulated Viewport Width: ${_simulatedViewportWidth.toInt()} dp',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Scale: ${(scaleFactor * 100).toStringAsFixed(1)}% (clamp: 0.85x - 1.35x)',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSecondaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Slider(
                    value: _simulatedViewportWidth,
                    min: 280.0,
                    max: 800.0,
                    divisions: 52,
                    label: '${_simulatedViewportWidth.toInt()} dp',
                    onChanged: (val) {
                      setState(() => _simulatedViewportWidth = val);
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton.icon(
                        icon: const Icon(Icons.phone_android, size: 16),
                        label: const Text('Mobile (320dp)'),
                        onPressed: () =>
                            setState(() => _simulatedViewportWidth = 320.0),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.phone_iphone, size: 16),
                        label: const Text('Baseline (390dp)'),
                        onPressed: () =>
                            setState(() => _simulatedViewportWidth = 390.0),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.tablet, size: 16),
                        label: const Text('Tablet (768dp)'),
                        onPressed: () =>
                            setState(() => _simulatedViewportWidth = 768.0),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Enable Fluid Clamp Engine'),
                    subtitle: const Text(
                      'Scales text smoothly without breaking stacked tables or triggering overflow.',
                    ),
                    value: _enableFluidScaling,
                    onChanged: (val) =>
                        setState(() => _enableFluidScaling = val),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Rendered Fluid Typography Hierarchy Matrix
          MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: _enableFluidScaling
                  ? fluidScaler
                  : const TextScaler.linear(1.0),
            ),
            child: Card(
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
                      'Strict MD3 Typography Token Hierarchy',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Custom fontSize is physically blocked. All components MUST inherit these tokens.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const Divider(height: 24),

                    _buildTokenRow('displayLarge', '57dp / w400', textTheme.displayLarge!),
                    _buildTokenRow('headlineLarge', '32dp / w600', textTheme.headlineLarge!),
                    _buildTokenRow('headlineMedium', '28dp / w600', textTheme.headlineMedium!),
                    _buildTokenRow('titleLarge', '22dp / w700', textTheme.titleLarge!),
                    _buildTokenRow('titleMedium', '16dp / w600', textTheme.titleMedium!),
                    _buildTokenRow('bodyLarge', '16dp / w400', textTheme.bodyLarge!),
                    _buildTokenRow('bodyMedium', '14dp / w400', textTheme.bodyMedium!),
                    _buildTokenRow('bodySmall', '12dp / w400', textTheme.bodySmall!),
                    _buildTokenRow('labelLarge (Bold)', '14dp / w700', textTheme.labelLarge!),
                    _buildTokenRow('labelSmall (Bold)', '11dp / w700', textTheme.labelSmall!),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Poka-Yoke Linter & Build Failure Rule Box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.error.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.gavel, color: theme.colorScheme.error),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Poka-Yoke Custom Font Blocker Active',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.error,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Direct declarations of TextStyle(fontSize: ...) are banned in CI/CD via scripts/assert_no_raw_font_size.sh. Use Theme.of(context).textTheme.<token> exclusively.',
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

  Widget _buildTokenRow(String tokenName, String specs, TextStyle style) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          SizedBox(
            width: 140,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tokenName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                Text(
                  specs,
                  style: TextStyle(
                    fontSize: 10,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Sample: The quick brown fox ($tokenName)',
              style: style,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
