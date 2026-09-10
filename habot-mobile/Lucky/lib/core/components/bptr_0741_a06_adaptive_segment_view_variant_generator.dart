// BPTR-0741-A06 — Adaptive Segment View Variant Generator.
// Provides a controller and widget for swapping Standard, Premium, and Enterprise
// layout sub-templates based on segment data while preserving design-system tokens.
import 'package:flutter/material.dart';

enum LayoutVariantType { standard, premium, enterprise }

@immutable
class LayoutVariantConfig {
  const LayoutVariantConfig({
    required this.templateName,
    required this.templateVersion,
    required this.templateType,
    required this.layoutType,
    required this.gridColumns,
    required this.spacing,
    required this.alignment,
    required this.validationStatus,
  });

  final String templateName;
  final String templateVersion;
  final String templateType;
  final LayoutVariantType layoutType;
  final int gridColumns;
  final double spacing;
  final Alignment alignment;
  final bool validationStatus;

  LayoutVariantConfig copyWith({
    String? templateName,
    String? templateVersion,
    String? templateType,
    LayoutVariantType? layoutType,
    int? gridColumns,
    double? spacing,
    Alignment? alignment,
    bool? validationStatus,
  }) {
    return LayoutVariantConfig(
      templateName: templateName ?? this.templateName,
      templateVersion: templateVersion ?? this.templateVersion,
      templateType: templateType ?? this.templateType,
      layoutType: layoutType ?? this.layoutType,
      gridColumns: gridColumns ?? this.gridColumns,
      spacing: spacing ?? this.spacing,
      alignment: alignment ?? this.alignment,
      validationStatus: validationStatus ?? this.validationStatus,
    );
  }
}

class AdaptiveSegmentViewVariantController extends ChangeNotifier {
  AdaptiveSegmentViewVariantController({
    Map<LayoutVariantType, LayoutVariantConfig>? initialVariants,
  }) : _variants = initialVariants ?? _defaultVariants;

  static final Map<LayoutVariantType, LayoutVariantConfig> _defaultVariants = {
    LayoutVariantType.standard: LayoutVariantConfig(
      templateName: 'Standard',
      templateVersion: '1.0.0',
      templateType: 'standard',
      layoutType: LayoutVariantType.standard,
      gridColumns: 1,
      spacing: 16,
      alignment: Alignment.center,
      validationStatus: true,
    ),
    LayoutVariantType.premium: LayoutVariantConfig(
      templateName: 'Premium',
      templateVersion: '1.0.0',
      templateType: 'premium',
      layoutType: LayoutVariantType.premium,
      gridColumns: 2,
      spacing: 20,
      alignment: Alignment.centerLeft,
      validationStatus: true,
    ),
    LayoutVariantType.enterprise: LayoutVariantConfig(
      templateName: 'Enterprise',
      templateVersion: '1.0.0',
      templateType: 'enterprise',
      layoutType: LayoutVariantType.enterprise,
      gridColumns: 3,
      spacing: 24,
      alignment: Alignment.topLeft,
      validationStatus: true,
    ),
  };

  final Map<LayoutVariantType, LayoutVariantConfig> _variants;
  LayoutVariantType _currentVariant = LayoutVariantType.standard;

  Map<LayoutVariantType, LayoutVariantConfig> get variants =>
      Map<LayoutVariantType, LayoutVariantConfig>.unmodifiable(_variants);
  LayoutVariantType get currentVariant => _currentVariant;
  LayoutVariantConfig get currentConfig => _variants[_currentVariant]!;

  void selectVariant(LayoutVariantType variant) {
    if (_variants.containsKey(variant) && _currentVariant != variant) {
      _currentVariant = variant;
      notifyListeners();
    }
  }

  void selectVariantForSegment(String segment) {
    final normalized = segment.trim().toLowerCase();
    final variant = switch (normalized) {
      'premium' => LayoutVariantType.premium,
      'enterprise' => LayoutVariantType.enterprise,
      _ => LayoutVariantType.standard,
    };
    selectVariant(variant);
  }

  void updateVariant(LayoutVariantType type, LayoutVariantConfig config) {
    _variants[type] = config;
    if (_currentVariant == type) {
      notifyListeners();
    }
  }
}

class AdaptiveSegmentViewVariantGenerator extends StatelessWidget {
  const AdaptiveSegmentViewVariantGenerator({
    super.key,
    required this.controller,
    required this.builder,
  });

  final AdaptiveSegmentViewVariantController controller;
  final Widget Function(BuildContext context, LayoutVariantConfig config) builder;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final config = controller.currentConfig;
        return LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints.maxWidth;
            final columnCount = config.gridColumns.clamp(1, 3);
            final itemWidth =
                (maxWidth - (config.spacing * (columnCount - 1))) / columnCount;
            return Align(
              alignment: config.alignment,
              child: Wrap(
                spacing: config.spacing,
                runSpacing: config.spacing,
                children: [
                  SizedBox(
                    width: itemWidth > 0 ? itemWidth : maxWidth,
                    child: builder(context, config),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
