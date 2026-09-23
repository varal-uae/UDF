import 'package:flutter/material.dart';

/// Row 336: GEN-00671 (Seq 17380)
/// Action: Set primary KPI typography font size to 2-3x larger than body text.
/// Quality Gate: Google Material Design 3 Spec (Typography Size Multiplier: >= 2x, Target: 3x).
class KpiTypographyScaleEnforcerPanel extends StatefulWidget {
  final String globalRefId;
  final String atomicStepRefId;
  final int sequenceOrder;

  const KpiTypographyScaleEnforcerPanel({
    super.key,
    this.globalRefId = 'GEN-00671',
    this.atomicStepRefId = 'GEN-00671',
    this.sequenceOrder = 17380,
  });

  @override
  State<KpiTypographyScaleEnforcerPanel> createState() =>
      _KpiTypographyScaleEnforcerPanelState();
}

class _KpiTypographyScaleEnforcerPanelState
    extends State<KpiTypographyScaleEnforcerPanel> {
  final double _bodyFontSize = 14.0;
  double _multiplier = 2.5;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final kpiFontSize = _bodyFontSize * _multiplier;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.format_size_rounded,
                    color: theme.colorScheme.onTertiaryContainer,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'GEN-00671: KPI Typography Scale',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Seq: 17380 • Standard: Google Material Design 3 Spec',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
                Chip(
                  avatar: const Icon(
                    Icons.check_circle_outline,
                    color: Colors.green,
                    size: 16,
                  ),
                  label: Text('${_multiplier.toStringAsFixed(1)}x Scale PASS'),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Body Baseline: ${_bodyFontSize.toInt()} pt',
                  style: theme.textTheme.bodyMedium,
                ),
                Text(
                  'KPI Size: ${kpiFontSize.toStringAsFixed(1)} pt (${_multiplier.toStringAsFixed(1)}x)',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Daily Active Conversion Rate (MD3 Display KPI):',
                    style: TextStyle(fontSize: _bodyFontSize),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '78.4%',
                    style: TextStyle(
                      fontSize: kpiFontSize,
                      fontWeight: FontWeight.w900,
                      color: theme.colorScheme.primary,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Slider(
              value: _multiplier,
              min: 2.0,
              max: 3.0,
              divisions: 10,
              label: '${_multiplier.toStringAsFixed(1)}x',
              onChanged: (val) {
                setState(() {
                  _multiplier = val;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: KpiTypographyScaleEnforcerPanel(),
          ),
        ),
      ),
    ),
  );
}
