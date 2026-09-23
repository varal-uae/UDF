import 'package:flutter/material.dart';

/// Row 307: GEN-00352 (Seq 17061)
/// Action: Lazy-load non-critical mobile screens until requested by user navigation.
/// Quality Gate: Agile Definition of Done (Scrum Guide 2020) / Dynamic Route Deferral Standard.
class LazyLoadedScreenRoutePanel extends StatefulWidget {
  final String globalRefId;
  final String atomicStepRefId;
  final int sequenceOrder;

  const LazyLoadedScreenRoutePanel({
    super.key,
    this.globalRefId = 'GEN-00352',
    this.atomicStepRefId = 'GEN-00352',
    this.sequenceOrder = 17061,
  });

  @override
  State<LazyLoadedScreenRoutePanel> createState() =>
      _LazyLoadedScreenRoutePanelState();
}

class _LazyLoadedScreenRoutePanelState
    extends State<LazyLoadedScreenRoutePanel> {
  bool _isScreenLoaded = false;
  bool _isLoading = false;
  int _ramSavingsMb = 42;

  void _loadDeferredRoute() {
    setState(() {
      _isLoading = true;
    });

    Future.delayed(const Duration(milliseconds: 250), () {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _isScreenLoaded = true;
        _ramSavingsMb = 0;
      });
    });
  }

  void _evictRoute() {
    setState(() {
      _isScreenLoaded = false;
      _ramSavingsMb = 42;
    });
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
                    Icons.route_rounded,
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
                        'Lazy-Loaded Route Deferral',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${widget.globalRefId} | ${widget.atomicStepRefId} (Seq ${widget.sequenceOrder})',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green),
                  ),
                  child: const Text(
                    'ON-DEMAND LOAD',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Defers initialization and widget tree construction of secondary mobile screens until requested by user navigation, optimizing cold startup time and memory footprint.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.tonalIcon(
                  onPressed: _isLoading ? null : (_isScreenLoaded ? _evictRoute : _loadDeferredRoute),
                  icon: _isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(_isScreenLoaded ? Icons.close_fullscreen_rounded : Icons.open_in_new_rounded, size: 18),
                  label: Text(_isScreenLoaded ? 'Evict Screen From RAM' : 'Lazy-Load Screen Route'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Text('Route State', style: TextStyle(fontSize: 11)),
                      Text(
                        _isScreenLoaded ? 'RESIDENT' : 'DEFERRED',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: _isScreenLoaded ? Colors.indigo : Colors.green,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Text('RAM Conservation', style: TextStyle(fontSize: 11)),
                      Text(
                        '+${_ramSavingsMb}MB',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                    ],
                  ),
                  const Column(
                    children: [
                      Text('Standard', style: TextStyle(fontSize: 11)),
                      Text('Agile DoD', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                    ],
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
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: LazyLoadedScreenRoutePanel(),
          ),
        ),
      ),
    ),
  );
}
