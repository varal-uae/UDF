// BPTR-0741-A08 — Adaptive Segment View Variant Generator.
// Controller-driven layout component that swaps Enterprise diagnostic data-grid variations
// using dynamic segment configuration and design-system components without full app updates.
import 'package:flutter/material.dart';

enum LayoutViewVariation { enterprise, standard, compact }

enum LayoutValidationStatus { valid, invalid, pending }

class LayoutParameters {
  final LayoutViewVariation layoutType;
  final int gridColumns;
  final double spacing;
  final Alignment alignment;
  final LayoutValidationStatus validationStatus;

  const LayoutParameters({
    required this.layoutType,
    required this.gridColumns,
    required this.spacing,
    required this.alignment,
    required this.validationStatus,
  });

  LayoutParameters copyWith({
    LayoutViewVariation? layoutType,
    int? gridColumns,
    double? spacing,
    Alignment? alignment,
    LayoutValidationStatus? validationStatus,
  }) {
    return LayoutParameters(
      layoutType: layoutType ?? this.layoutType,
      gridColumns: gridColumns ?? this.gridColumns,
      spacing: spacing ?? this.spacing,
      alignment: alignment ?? this.alignment,
      validationStatus: validationStatus ?? this.validationStatus,
    );
  }
}

class AdaptiveSegmentViewVariantController extends ChangeNotifier {
  LayoutParameters _parameters;
  String _segmentKey;

  AdaptiveSegmentViewVariantController({
    LayoutParameters? initialParameters,
    String initialSegmentKey = 'default',
  })  : _parameters = initialParameters ??
            const LayoutParameters(
              layoutType: LayoutViewVariation.standard,
              gridColumns: 2,
              spacing: 8,
              alignment: Alignment.center,
              validationStatus: LayoutValidationStatus.pending,
            ),
        _segmentKey = initialSegmentKey;

  LayoutParameters get parameters => _parameters;
  String get segmentKey => _segmentKey;

  void updateSegment(String segmentKey, {LayoutParameters? parameters}) {
    _segmentKey = segmentKey;
    if (parameters != null) {
      _parameters = parameters;
    }
    _validateLayout();
    notifyListeners();
  }

  void updateLayoutParameters(LayoutParameters parameters) {
    _parameters = parameters;
    _validateLayout();
    notifyListeners();
  }

  void _validateLayout() {
    final columns = _parameters.gridColumns;
    final spacing = _parameters.spacing;
    final isValid = columns > 0 && columns <= 12 && spacing >= 0 && spacing <= 32;
    _parameters = _parameters.copyWith(
      validationStatus: isValid
          ? LayoutValidationStatus.valid
          : LayoutValidationStatus.invalid,
    );
  }
}

class AdaptiveSegmentViewVariantGenerator extends StatelessWidget {
  final AdaptiveSegmentViewVariantController controller;

  const AdaptiveSegmentViewVariantGenerator({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final parameters = controller.parameters;
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: _VariationLayout(
            key: ValueKey(parameters.layoutType),
            parameters: parameters,
            segmentKey: controller.segmentKey,
          ),
        );
      },
    );
  }
}

class _VariationLayout extends StatelessWidget {
  final LayoutParameters parameters;
  final String segmentKey;

  const _VariationLayout({
    super.key,
    required this.parameters,
    required this.segmentKey,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isCompact = parameters.layoutType == LayoutViewVariation.compact;

    return Align(
      alignment: parameters.alignment,
      child: Padding(
        padding: EdgeInsets.all(parameters.spacing),
        child: Semantics(
          label: 'Adaptive segment view variation ${parameters.layoutType.name}',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _VariationHeader(
                layoutType: parameters.layoutType,
                segmentKey: segmentKey,
                validationStatus: parameters.validationStatus,
              ),
              SizedBox(height: parameters.spacing),
              Expanded(
                child: GridView.builder(
                  itemCount: 12,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: parameters.gridColumns,
                    mainAxisSpacing: parameters.spacing,
                    crossAxisSpacing: parameters.spacing,
                    childAspectRatio: isCompact ? 2.4 : 1.6,
                  ),
                  itemBuilder: (context, index) {
                    return Card(
                      color: colorScheme.surfaceContainerHighest,
                      child: Padding(
                        padding: EdgeInsets.all(parameters.spacing),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Metric ${index + 1}',
                              style: theme.textTheme.labelMedium,
                            ),
                            Text(
                              _metricValue(index),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              parameters.validationStatus.name,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: parameters.validationStatus == LayoutValidationStatus.valid
                                    ? colorScheme.primary
                                    : colorScheme.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _metricValue(int index) {
    const values = <String>[
      '97',
      '98',
      '94',
      '99',
      '96',
      '95',
      '97',
      '93',
      '98',
      '99',
      '96',
      '97',
    ];
    return values[index % values.length];
  }
}

class _VariationHeader extends StatelessWidget {
  final LayoutViewVariation layoutType;
  final String segmentKey;
  final LayoutValidationStatus validationStatus;

  const _VariationHeader({
    required this.layoutType,
    required this.segmentKey,
    required this.validationStatus,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          layoutType.name.toUpperCase(),
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          '$segmentKey • ${validationStatus.name}',
          style: theme.textTheme.labelLarge,
        ),
      ],
    );
  }
}
