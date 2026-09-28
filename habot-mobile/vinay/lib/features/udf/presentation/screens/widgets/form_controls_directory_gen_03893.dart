// GEN-03893 — Form Controls Directory Screen.
// Displays the mobile application form controls directory using M3 Elevated Cards, status chips, and responsive single/multi-column layout with 30s polling and pull-to-refresh.

import 'dart:async';
import 'package:flutter/material.dart';

enum ControlStatus { complete, notComplete }

class FormControlItem {
  final String id;
  final String name;
  final ControlStatus status;
  final double latencyMs;
  final DateTime timestamp;

  const FormControlItem({
    required this.id,
    required this.name,
    required this.status,
    required this.latencyMs,
    required this.timestamp,
  });
}

class MockFormControlsRepository {
  static List<FormItem> getControls() {
    return [
      FormControlItem(
        id: 'CTRL-001',
        name: 'Text Input Field',
        status: ControlStatus.complete,
        latencyMs: 45.2,
        timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
      ),
      FormControlItem(
        id: 'CTRL-002',
        name: 'Dropdown Selector',
        status: ControlStatus.complete,
        latencyMs: 62.1,
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      FormControlItem(
        id: 'CTRL-003',
        name: 'Date Picker',
        status: ControlStatus.notComplete,
        latencyMs: 120.5,
        timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
      ),
      FormControlItem(
        id: 'CTRL-004',
        name: 'Radio Group',
        status: ControlStatus.complete,
        latencyMs: 38.0,
        timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
      ),
      FormControlItem(
        id: 'CTRL-005',
        name: 'Checkbox List',
        status: ControlStatus.notComplete,
        latencyMs: 150.3,
        timestamp: DateTime.now(),
      ),
    ];
  }
}

class FormControlsDirectoryScreen extends StatefulWidget {
  const FormControlsDirectoryScreen({super.key});

  @override
  State<FormControlsDirectoryScreen> createState() => _FormControlsDirectoryScreenState();
}

class _FormControlsDirectoryScreenState extends State<FormControlsDirectoryScreen> {
  late Future<List<FormItem>> _controlsFuture;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _loadData();
    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _loadData() {
    setState(() {
      _controlsFuture = Future.delayed(
        const Duration(milliseconds: 300),
        () => MockFormControlsRepository.getControls(),
      );
    });
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) _loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Controls Directory'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadData(),
        child: FutureBuilder<List<FormItem>>(
          future: _controlsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No form controls available.'));
            }

            final controls = snapshot.data!;
            return LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 600;
                final isTabletOrDesktop = constraints.maxWidth >= 840;

                if (isMobile) {
                  return ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: controls.length,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: _ControlCard(control: controls[index]),
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16.0),
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: isTabletOrDesktop ? 400 : 300,
                    mainAxisSpacing: 16.0,
                    crossAxisSpacing: 16.0,
                    childAspectRatio: isTabletOrDesktop ? 2.5 : 2.0,
                  ),
                  itemCount: controls.length,
                  itemBuilder: (context, index) => _ControlCard(control: controls[index]),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _ControlCard extends StatelessWidget {
  final FormControlItem control;

  const _ControlCard({required this.control});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isComplete = control.status == ControlStatus.complete;

    return Card(
      elevation: 3.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.0),
        onTap: () {
          showModalBottomSheet(
            context: context,
            builder: (ctx) => SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Configuration: ${control.name}', style: theme.textTheme.titleLarge),
                    const SizedBox(height: 16),
                    Text('ID: ${control.id}'),
                    Text('Latency: ${control.latencyMs.toStringAsFixed(1)} ms'),
                    Text('Status: ${isComplete ? "Complete" : "Not Complete"}'),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48.0,
                      child: FilledButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Sync triggered for ${control.name}'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        child: const Text('Apply Configuration'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      control.name,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Latency: ${control.latencyMs.toStringAsFixed(1)} ms',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Chip(
                avatar: Icon(
                  isComplete ? Icons.check_circle : Icons.error_outline,
                  size: 18,
                  color: isComplete ? Colors.green : Colors.red,
                ),
                label: Text(isComplete ? 'Complete' : 'Not Complete'),
                backgroundColor: isComplete
                    ? theme.colorScheme.primaryContainer.withOpacity(0.3)
                    : theme.colorScheme.errorContainer.withOpacity(0.3),
                side: BorderSide.none,
              ),
            ],
          ),
        ),
      ),
    );
  }
}