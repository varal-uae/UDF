// SSTLA-014-A13 — Split-Screen Master View Layout with Adaptive Responsive Behavior.
// Partitions screens symmetrically into reference context frames and single-purpose input blocks, auto-collapsing to vertical layout below 600dp.

import 'package:flutter/material.dart';

/// Configuration sheet for the fluid container parameters.
class FluidContainerConfig {
  final double collapseThresholdDp;
  final EdgeInsets padding;
  final double spacing;

  const FluidContainerConfig({
    this.collapseThresholdDp = 600.0,
    this.padding = const EdgeInsets.all(16.0),
    this.spacing = 16.0,
  });
}

/// Poka-Yoke (Mistake-Proofing) enforcement class.
/// Layout building modules throw compilation/assertion errors if screen code
/// attempts to declare custom menu or page parameters outside the designated structure.
class LayoutPokaYokeEnforcer {
  const LayoutPokaYokeEnforcer._();

  static void validateNoCustomMenus(List<Widget> children) {
    for (final child in children) {
      if (child is AppBar || child is Drawer || child is NavigationBar) {
        throw FlutterError(
          'SSTLA-014-A13 Poka-Yoke Violation: Layout files cannot declare '
          'custom menu or page parameters (AppBar, Drawer, NavigationBar). '
          'Breaching designated margins detected.',
        );
      }
    }
  }
}

/// Form controller mapping input_retry_count (INT) to track input slips.
class InputRetryFormController {
  int inputRetryCount = 0;

  void recordInputSlip() {
    inputRetryCount++;
  }

  void reset() {
    inputRetryCount = 0;
  }
}

/// Mock data representing atomic-level data fields for execution tracking.
class StepExecutionMockData {
  final String stepExecutionId;
  final String executionStatus;
  final DateTime executionTimestamp;
  final String stepOutcome;
  final String userId;

  const StepExecutionMockData({
    required this.stepExecutionId,
    required this.executionStatus,
    required this.executionTimestamp,
    required this.stepOutcome,
    required this.userId,
  });

  static List<StepExecutionMockData> get mockRecords => [
        const StepExecutionMockData(
          stepExecutionId: 'EXEC-001',
          executionStatus: 'Pass',
          executionTimestamp: null as dynamic,
          stepOutcome: 'Validated successfully',
          userId: 'USR-992',
        ),
        const StepExecutionMockData(
          stepExecutionId: 'EXEC-002',
          executionStatus: 'Fail',
          executionTimestamp: null as dynamic,
          stepOutcome: 'Input slip detected',
          userId: 'USR-104',
        ),
      ];
}

/// Split-Screen Component Class.
/// Isolates visual evidence beside exactly one restricted data input field.
class SplitScreenLayout extends StatelessWidget {
  final Widget evidenceFrame;
  final Widget inputBlock;
  final FluidContainerConfig config;
  final InputRetryFormController retryController;

  const SplitScreenLayout({
    super.key,
    required this.evidenceFrame,
    required this.inputBlock,
    this.config = const FluidContainerConfig(),
    InputRetryFormController? retryController,
  }) : retryController = retryController ?? const _DefaultRetryController();

  @override
  Widget build(BuildContext context) {
    // Poka-Yoke validation
    LayoutPokaYokeEnforcer.validateNoCustomMenus([evidenceFrame, inputBlock]);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool isMobilePortrait =
            constraints.maxWidth < config.collapseThresholdDp;

        if (isMobilePortrait) {
          // Auto-collapses horizontal structures into a vertical layout below 600dp,
          // stacking evidence frames directly above inputs to protect mobile portrait ratios.
          return SingleChildScrollView(
            padding: config.padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                evidenceFrame,
                SizedBox(height: config.spacing),
                inputBlock,
              ],
            ),
          );
        }

        // Symmetrical partition for wider screens
        return Padding(
          padding: config.padding,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: evidenceFrame,
              ),
              SizedBox(width: config.spacing),
              Expanded(
                flex: 1,
                child: inputBlock,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DefaultRetryController implements InputRetryFormController {
  const _DefaultRetryController();

  @override
  int get inputRetryCount => 0;

  @override
  set inputRetryCount(int value) {}

  @override
  void recordInputSlip() {}

  @override
  void reset() {}
}

/// Example usage / demonstration widget for UDF presentation layer.
class SplitScreenDemoView extends StatefulWidget {
  const SplitScreenDemoView({super.key});

  @override
  State<SplitScreenDemoView> createState() => _SplitScreenDemoViewState();
}

class _SplitScreenDemoViewState extends State<SplitScreenDemoView> {
  final InputRetryFormController _retryController = InputRetryFormController();
  final TextEditingController _inputController = TextEditingController();

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _handleValidation() {
    if (_inputController.text.trim().isEmpty) {
      _retryController.recordInputSlip();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Validation failed. Input slips: ${_retryController.inputRetryCount}'),
        ),
      );
    } else {
      setState(() {
        _retryController.reset();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SplitScreenLayout(
      retryController: _retryController,
      evidenceFrame: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Reference Context Frame',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              Text(
                'Visual evidence isolated for operator exception processing. '
                'Concentrates focus entirely on single-sentence validation steps.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              ...StepExecutionMockData.mockRecords.map((record) => ListTile(
                    title: Text(record.stepExecutionId),
                    subtitle: Text(record.stepOutcome),
                    trailing: Chip(
                      label: Text(record.executionStatus),
                      backgroundColor: record.executionStatus == 'Pass'
                          ? Colors.green.shade100
                          : Colors.red.shade100,
                    ),
                  )),
            ],
          ),
        ),
      ),
      inputBlock: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Single-Purpose Input Block',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              TextField(
                controller: _inputController,
                decoration: const InputDecoration(
                  labelText: 'Restricted Data Input Field',
                  border: OutlineInputBorder(),
                  hintText: 'Enter validation data...',
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _handleValidation,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Validate Step'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
