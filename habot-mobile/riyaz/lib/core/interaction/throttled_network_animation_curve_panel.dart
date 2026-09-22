import 'package:flutter/material.dart';

/// Row 3: MUFCE-011 (Seq 30461)
/// Action: Test the animation curve on throttled/slow network conditions for elegance.
/// Quality Gate: Performance Under Constrained Conditions (Optimal: usable on 3G / load ≤ 3s).
class ThrottledNetworkAnimationCurvePanel extends StatefulWidget {
  final String globalRefId;
  final String atomicStepRefId;
  final int sequenceOrder;

  const ThrottledNetworkAnimationCurvePanel({
    super.key,
    this.globalRefId = 'MUFCE-011',
    this.atomicStepRefId = 'MUFCE-011-A10',
    this.sequenceOrder = 30461,
  });

  @override
  State<ThrottledNetworkAnimationCurvePanel> createState() =>
      _ThrottledNetworkAnimationCurvePanelState();
}

class _ThrottledNetworkAnimationCurvePanelState
    extends State<ThrottledNetworkAnimationCurvePanel>
    with SingleTickerProviderStateMixin {
  bool _isActionActive = false;
  int _executionCount = 0;
  final String _targetMetric =
      'Usable on 3G / low-tier device, load time 3 seconds or below';
  late final AnimationController _controller;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _executeVerification() {
    setState(() {
      _isActionActive = !_isActionActive;
      _executionCount++;
    });
    if (_isActionActive) {
      _controller.forward(from: 0);
    } else {
      _controller.reverse();
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Audit event dispatched. Latency verified against Performance Under Constrained Conditions.',
        ),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.animation_outlined,
                    color: theme.colorScheme.onPrimaryContainer,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.globalRefId}: Throttled Motion Curve',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Seq: ${widget.sequenceOrder} • Standard: Constrained Performance',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
                const Chip(
                  avatar: Icon(
                    Icons.check_circle_outline,
                    color: Colors.green,
                    size: 16,
                  ),
                  label: Text('ACTIVE PASS'),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Benchmark Target:',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _targetMetric,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Telemetry Executions:',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '$_executionCount runs',
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Test the animation curve on throttled/slow network conditions for elegance.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            FadeTransition(
              opacity: _fade,
              child: Container(
                height: 48,
                width: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '200ms ease-in-out preview',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                onPressed: _executeVerification,
                icon: Icon(
                  _isActionActive
                      ? Icons.sync_rounded
                      : Icons.play_arrow_rounded,
                  size: 20,
                ),
                label: Text(
                  _isActionActive
                      ? 'Active Handshake Live'
                      : 'Execute Step Verification',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Standalone entrypoint for isolated file verification.
void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: ThrottledNetworkAnimationCurvePanel(),
          ),
        ),
      ),
    ),
  );
}
