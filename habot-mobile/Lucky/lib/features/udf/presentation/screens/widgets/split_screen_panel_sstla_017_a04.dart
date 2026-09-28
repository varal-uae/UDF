// SSTLA-017-A04 — Split-Screen Panel View with Isolated Document Crops.
// Enforces strict isolation boundaries separating document image canvas elements from input fields, with lazy-loading and mobile-first vertical stacking.

import 'package:flutter/material.dart';

/// Mock data model representing an atomic step execution unit loaded from Pub/Sub.
class StepExecutionData {
  final String stepExecutionId;
  final String executionStatus;
  final DateTime executionTimestamp;
  final String stepOutcome;
  final String userId;
  final String completionStatus;
  final String documentCropUrl;
  final List<InputFieldData> inputFields;

  const StepExecutionData({
    required this.stepExecutionId,
    required this.executionStatus,
    required this.executionTimestamp,
    required this.stepOutcome,
    required this.userId,
    required this.completionStatus,
    required this.documentCropUrl,
    required this.inputFields,
  });
}

class InputFieldData {
  final String fieldId;
  final String label;
  final String initialValue;

  const InputFieldData({
    required this.fieldId,
    required this.label,
    required this.initialValue,
  });
}

/// Hardcoded mock repository simulating asynchronous Pub/Sub queue pipeline data.
class MockPubSubRepository {
  static const List<StepExecutionData> steps = [
    StepExecutionData(
      stepExecutionId: 'EXEC-001',
      executionStatus: 'PENDING',
      executionTimestamp: null,
      stepOutcome: 'AWAITING_INPUT',
      userId: 'USR-9921',
      completionStatus: 'Partial',
      documentCropUrl: 'mock://crop/isolated_section_01.png',
      inputFields: [
        InputFieldData(fieldId: 'F1', label: 'Extracted Name', initialValue: ''),
        InputFieldData(fieldId: 'F2', label: 'Extracted ID Number', initialValue: ''),
      ],
    ),
    StepExecutionData(
      stepExecutionId: 'EXEC-002',
      executionStatus: 'COMPLETED',
      executionTimestamp: null,
      stepOutcome: 'VERIFIED',
      userId: 'USR-9921',
      completionStatus: 'Complete',
      documentCropUrl: 'mock://crop/isolated_section_02.png',
      inputFields: [
        InputFieldData(fieldId: 'F3', label: 'Date of Birth', initialValue: '1990-01-01'),
      ],
    ),
  ];
}

/// Main split-screen panel enforcing strict isolation between document crops and inputs.
class SplitScreenPanelSstla017A04 extends StatefulWidget {
  const SplitScreenPanelSstla017A04({super.key});

  @override
  State<SplitScreenPanelSstla017A04> createState() => _SplitScreenPanelSstla017A04State();
}

class _SplitScreenPanelSstla017A04State extends State<SplitScreenPanelSstla017A04> {
  late final List<StepExecutionData> _steps;

  @override
  void initState() {
    super.initState();
    // Simulate loading from Pub/Sub queue
    _steps = MockPubSubRepository.steps;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 600;

        if (isMobile) {
          // Mobile App First Implication: Vertical step views to fit small display areas
          return _buildMobileVerticalView();
        } else {
          // Desktop/Tablet: Side-by-side split screen
          return _buildDesktopSplitView(constraints);
        }
      },
    );
  }

  Widget _buildMobileVerticalView() {
    return ListView.builder(
      itemCount: _steps.length,
      itemBuilder: (context, index) {
        return _IsolatedStepCard(
          step: _steps[index],
          isMobile: true,
        );
      },
    );
  }

  Widget _buildDesktopSplitView(BoxConstraints constraints) {
    return Row(
      children: [
        // Left Panel: Isolated Document Canvas (Strictly cropped, no full document)
        SizedBox(
          width: constraints.maxWidth * 0.5,
          child: ListView.builder(
            itemCount: _steps.length,
            itemBuilder: (context, index) {
              return _IsolatedDocumentCanvas(step: _steps[index]);
            },
          ),
        ),
        const VerticalDivider(width: 1, thickness: 2),
        // Right Panel: Data Inputs strictly isolated from canvas
        SizedBox(
          width: constraints.maxWidth * 0.5,
          child: ListView.builder(
            itemCount: _steps.length,
            itemBuilder: (context, index) {
              return _IsolatedInputPanel(step: _steps[index]);
            },
          ),
        ),
      ],
    );
  }
}

/// Card used in mobile vertical layout combining isolated sections safely.
class _IsolatedStepCard extends StatelessWidget {
  final StepExecutionData step;
  final bool isMobile;

  const _IsolatedStepCard({required this.step, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _IsolatedDocumentCanvas(step: step),
          const Divider(height: 1, thickness: 2, color: Colors.black12),
          _IsolatedInputPanel(step: step),
        ],
      ),
    );
  }
}

/// Strictly isolated document canvas. Conceals surrounding document sections.
/// Self-Chasing: Breaks visibly if uncropped full documents hit client views.
class _IsolatedDocumentCanvas extends StatelessWidget {
  final StepExecutionData step;

  const _IsolatedDocumentCanvas({required this.step});

  @override
  Widget build(BuildContext context) {
    // Poka-Yoke: Validate crop URL format to ensure full document isn't rendered
    final bool isSafeCrop = step.documentCropUrl.contains('/crop/');

    if (!isSafeCrop) {
      // Self-chasing: Front-end components break visibly if uncropped
      return Container(
        height: 200,
        color: Colors.red,
        alignment: Alignment.center,
        child: const Text(
          'SECURITY VIOLATION: Uncropped document detected.',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      );
    }

    // Lazy-loading optimization placeholder
    return Container(
      height: 200,
      color: Colors.grey[200],
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.crop_free, size: 48, color: Colors.blueGrey),
          const SizedBox(height: 8),
          Text('Isolated Crop: ${step.documentCropUrl}'),
          Text('Execution ID: ${step.stepExecutionId}', style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

/// Strictly isolated input panel separated from the document canvas.
class _IsolatedInputPanel extends StatelessWidget {
  final StepExecutionData step;

  const _IsolatedInputPanel({required this.step});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Data Entry - ${step.stepExecutionId}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text('Status: ${step.completionStatus}', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 16),
          ...step.inputFields.map((field) => Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: field.label,
                hintText: field.initialValue.isEmpty ? 'Enter value' : field.initialValue,
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          )),
        ],
      ),
    );
  }
}