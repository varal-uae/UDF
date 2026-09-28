// SSTLA-017-A14 — MTB API Universal Split-Screen Panel View Ratio.
// Defines canvas layout rules that split screens into isolated document crops and data inputs, switching to vertical step views on mobile.

import 'package:flutter/material.dart';

/// Mock data representing atomic-level test fields for the isolated task context.
class _MockSplitScreenData {
  static const String testType = 'PII_BOUNDARY_VERIFICATION';
  static const String testResult = 'PASS';
  static const double testCoverage = 1.0;
  static final DateTime testTimestamp = DateTime(2026, 9, 28, 10, 30);
  static const String testLogPath = '/logs/sstla_017_a14_boundary_test.log';
  static const String completionStatus = 'Pass/Fail';
  static const String userSessionId = 'session_udf_88392_mock';
}

/// Threshold/Boundary Definition Precision metric constants.
class _BoundaryMetrics {
  static const double floorBoundary = 0.95;
  static const double optimalTarget = 1.0;
  static const double ceilingBoundary = 1.0;
}

/// A responsive split-screen panel widget that conceals broader document files
/// from operators, ensuring PII bounds are secured completely.
/// On desktop/tablet, it displays a side-by-side split view.
/// On mobile, it switches to focused, vertical step views.
class SplitScreenPanelView extends StatelessWidget {
  const SplitScreenPanelView({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool isMobile = constraints.maxWidth < 600;

        if (isMobile) {
          return _MobileVerticalStepView(
            documentCrop: _buildIsolatedDocumentCrop(context),
            dataInput: _buildDataInputPanel(context),
          );
        }

        return _DesktopSplitView(
          documentCrop: _buildIsolatedDocumentCrop(context),
          dataInput: _buildDataInputPanel(context),
        );
      },
    );
  }

  /// Builds the isolated document crop, explicitly hiding surrounding sections.
  Widget _buildIsolatedDocumentCrop(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    
    // Poka-Yoke: Canvas layouts conceal surrounding document sections.
    // Self-Chasing: Front-end components break visibly if uncropped full documents hit client views.
    return ClipRect(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          border: Border.all(
            color: theme.colorScheme.outlineVariant,
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Isolated Document Crop',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12.0),
            Expanded(
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: const Text(
                  '[CROPPED PII BOUNDARY VIEW]\nSurrounding sections concealed.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the data input panel for operator verification tasks.
  Widget _buildDataInputPanel(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Operator Data Input',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16.0),
          _buildReadOnlyField('Test Type', _MockSplitScreenData.testType, theme),
          _buildReadOnlyField('Test Result', _MockSplitScreenData.testResult, theme),
          _buildReadOnlyField('Test Coverage', '${(_MockSplitScreenData.testCoverage * 100).toStringAsFixed(1)}%', theme),
          _buildReadOnlyField('Test Timestamp', _MockSplitScreenData.testTimestamp.toIso8601String(), theme),
          _buildReadOnlyField('Test Log Path', _MockSplitScreenData.testLogPath, theme),
          _buildReadOnlyField('Completion Status', _MockSplitScreenData.completionStatus, theme),
          _buildReadOnlyField('User/Session ID', _MockSplitScreenData.userSessionId, theme),
          const Spacer(),
          _buildBoundaryPrecisionIndicator(theme),
        ],
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4.0),
          TextField(
            readOnly: true,
            controller: TextEditingController(text: value),
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBoundaryPrecisionIndicator(ThemeData theme) {
    final double precision = _BoundaryMetrics.optimalTarget;
    final bool isWithinBounds = precision >= _BoundaryMetrics.floorBoundary && 
                                precision <= _BoundaryMetrics.ceilingBoundary;

    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: isWithinBounds 
            ? theme.colorScheme.primaryContainer 
            : theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        children: [
          Icon(
            isWithinBounds ? Icons.check_circle_outline : Icons.error_outline,
            color: isWithinBounds 
                ? theme.colorScheme.onPrimaryContainer 
                : theme.colorScheme.onErrorContainer,
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              'Threshold Precision: ${(precision * 100).toStringAsFixed(1)}% (Floor: ${(_BoundaryMetrics.floorBoundary * 100).toStringAsFixed(1)}%)',
              style: theme.textTheme.bodySmall?.copyWith(
                color: isWithinBounds 
                    ? theme.colorScheme.onPrimaryContainer 
                    : theme.colorScheme.onErrorContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Desktop/Tablet side-by-side split view implementation.
class _DesktopSplitView extends StatelessWidget {
  final Widget documentCrop;
  final Widget dataInput;

  const _DesktopSplitView({
    required this.documentCrop,
    required this.dataInput,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 6,
          child: documentCrop,
        ),
        const SizedBox(width: 16.0),
        Expanded(
          flex: 4,
          child: dataInput,
        ),
      ],
    );
  }
}

/// Mobile focused vertical step view implementation.
class _MobileVerticalStepView extends StatelessWidget {
  final Widget documentCrop;
  final Widget dataInput;

  const _MobileVerticalStepView({
    required this.documentCrop,
    required this.dataInput,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            height: 300,
            child: documentCrop,
          ),
          const SizedBox(height: 16.0),
          SizedBox(
            height: 500,
            child: dataInput,
          ),
        ],
      ),
    );
  }
}