// GEN-04291 — Universal Component Library Widgetbook Setup for Mobile Interactions.
// Provides a Widgetbook catalog with M3 Elevated Cards, Status Chips, and responsive layouts for atomic component documentation.

import 'package:flutter/material.dart';

/// Entry point for the Widgetbook / Storybook catalog.
/// Run this file directly to preview all atomic components.
void main() {
  runApp(const Gen04291WidgetbookApp());
}

class Gen04291WidgetbookApp extends StatelessWidget {
  const Gen04291WidgetbookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UDF Component Library (GEN-04291)',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        brightness: Brightness.dark,
      ),
      home: const ComponentCatalogScreen(),
    );
  }
}

class ComponentCatalogScreen extends StatefulWidget {
  const ComponentCatalogScreen({super.key});

  @override
  State<ComponentCatalogScreen> createState() => _ComponentCatalogScreenState();
}

class _ComponentCatalogScreenState extends State<ComponentCatalogScreen> {
  bool _isPolling = true;

  @override
  void initState() {
    super.initState();
    // Simulates background polling every 30 seconds per requirement specs
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted && _isPolling) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _isPolling = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 840;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Engineering Console'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 1));
          if (mounted) setState(() {});
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: isMobile || isTablet
                  ? _buildSingleColumnLayout()
                  : _buildMultiColumnLayout(),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSingleColumnLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: _buildCatalogItems(),
    );
  }

  Widget _buildMultiColumnLayout() {
    return Wrap(
      spacing: 16.0,
      runSpacing: 16.0,
      children: _buildCatalogItems().map((item) {
        return SizedBox(
          width: 400,
          child: item,
        );
      }).toList(),
    );
  }

  List<Widget> _buildCatalogItems() {
    return [
      const SectionHeader(title: 'M3 Elevated Cards & Status Chips'),
      const StepCompletionCard(
        stepName: 'Create Storybook / Widgetbook stories',
        status: CompletionStatus.complete,
        coverageRate: 0.95,
      ),
      const SizedBox(height: 16),
      const StepCompletionCard(
        stepName: 'Backend Configuration Validation',
        status: CompletionStatus.partial,
        coverageRate: 0.82,
      ),
      const SizedBox(height: 16),
      const StepCompletionCard(
        stepName: 'CI/CD Pipeline Gates',
        status: CompletionStatus.notComplete,
        coverageRate: 0.45,
      ),
      const SizedBox(height: 32),
      const SectionHeader(title: 'Interactive Components'),
      const SizedBox(height: 16),
      ConfigurationBottomSheetButton(),
    ];
  }
}

enum CompletionStatus { complete, partial, notComplete }

class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}

/// M3 Elevated Card Level 2 (3dp) displaying step completion state.
/// Includes inline M3 Status Chips for health indicators.
class StepCompletionCard extends StatelessWidget {
  final String stepName;
  final CompletionStatus status;
  final double coverageRate;

  const StepCompletionCard({
    super.key,
    required this.stepName,
    required this.status,
    required this.coverageRate,
  });

  Color _getStatusColor(BuildContext context) {
    switch (status) {
      case CompletionStatus.complete:
        return Theme.of(context).colorScheme.primary;
      case CompletionStatus.partial:
        return Theme.of(context).colorScheme.tertiary;
      case CompletionStatus.notComplete:
        return Theme.of(context).colorScheme.error;
    }
  }

  String _getStatusLabel() {
    switch (status) {
      case CompletionStatus.complete:
        return 'Complete';
      case CompletionStatus.partial:
        return 'Partial';
      case CompletionStatus.notComplete:
        return 'Not Complete';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3.0, // M3 Elevated Card Level 2
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          // Deep-link drill-down simulation
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Drilling down into: $stepName'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      stepName,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  _StatusChip(
                    label: _getStatusLabel(),
                    color: _getStatusColor(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    'Documentation Coverage Rate:',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${(coverageRate * 100).toStringAsFixed(1)}%',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: coverageRate >= 0.8
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.error,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: coverageRate.clamp(0.0, 1.0),
                backgroundColor: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getStatusColor(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// M3 Status Chip for health indicators.
class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
      backgroundColor: color.withOpacity(0.12),
      side: BorderSide(color: color.withOpacity(0.5)),
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }
}

/// Button that triggers an M3 Bottom Sheet for configuration inputs.
class ConfigurationBottomSheetButton extends StatelessWidget {
  ConfigurationBottomSheetButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48, // 48x48dp touch targets minimum
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            useSafeArea: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            builder: (context) => const _ConfigurationBottomSheet(),
          );
        },
        icon: const Icon(Icons.settings),
        label: const Text('Open Configuration Inputs'),
      ),
    );
  }
}

/// M3 Bottom Sheet for configuration inputs.
class _ConfigurationBottomSheet extends StatelessWidget {
  const _ConfigurationBottomSheet();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Step Configuration',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              labelText: 'Metric Config Target',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              labelText: 'ISO/IEC/IEEE 26515 Reference Standard',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 48, // 48x48dp touch target
            child: FilledButton(
              onPressed: () {
                Navigator.pop(context);
                // M3 Snackbar for confirmations
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Configuration saved successfully.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text('Save Configuration'),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}