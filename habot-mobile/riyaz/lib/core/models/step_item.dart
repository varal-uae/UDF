import 'package:flutter/material.dart';

/// Domain classification for Habot atomic step components.
enum StepCategory {
  ui,
  compliance,
  interaction,
  layout,
  tokens,
  network,
  accessibility,
  versioning,
}

/// Catalog entry for one atomic checklist step.
class StepItem {
  final String stepCode;
  final String atomicStepCode;
  final String title;
  final String description;
  final StepCategory category;
  final IconData icon;
  final WidgetBuilder builder;
  final int excelRow;
  final int sequenceOrder;

  const StepItem({
    required this.stepCode,
    required this.atomicStepCode,
    required this.title,
    required this.description,
    required this.category,
    required this.icon,
    required this.builder,
    this.excelRow = 0,
    this.sequenceOrder = 0,
  });

  String get categoryLabel {
    switch (category) {
      case StepCategory.ui:
        return 'ui';
      case StepCategory.compliance:
        return 'compliance';
      case StepCategory.interaction:
        return 'interaction';
      case StepCategory.layout:
        return 'layout';
      case StepCategory.tokens:
        return 'tokens';
      case StepCategory.network:
        return 'network';
      case StepCategory.accessibility:
        return 'accessibility';
      case StepCategory.versioning:
        return 'versioning';
    }
  }
}
