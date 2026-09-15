import 'package:flutter/material.dart';

enum StepCategory {
  all('All Steps', Icons.apps),
  dataAndForms('Data & Forms', Icons.table_chart_outlined),
  realTimeSync('Real-Time & Sync', Icons.sync),
  aiAndAutomation('AI & Automation', Icons.auto_awesome),
  analyticsKpi('Analytics & KPI', Icons.analytics_outlined),
  infrastructure('Infrastructure', Icons.dns_outlined),
  compliance('Compliance & Security', Icons.verified_user_outlined),
  interaction('Interaction & Navigation', Icons.touch_app_outlined),
  ui('UI & Components', Icons.palette_outlined),
  tokens('Design Tokens', Icons.style_outlined),
  layout('Layout & Grid', Icons.dashboard_customize_outlined),
  versioning('Versioning & Vault', Icons.lock_outline),
  accessibility('Accessibility (A11y)', Icons.accessibility_new_outlined),
  network('Network & Telemetry', Icons.cloud_sync_outlined);

  final String label;
  final IconData icon;
  const StepCategory(this.label, this.icon);
}

class StepItem {
  final String stepCode;
  final String? atomicStepCode;
  final String title;
  final String description;
  final StepCategory category;
  final IconData icon;
  final WidgetBuilder builder;

  const StepItem({
    required this.stepCode,
    this.atomicStepCode,
    required this.title,
    required this.description,
    required this.category,
    required this.icon,
    required this.builder,
  });

  String get effectiveAtomicCode => (atomicStepCode != null && atomicStepCode!.isNotEmpty)
      ? atomicStepCode!
      : stepCode;
}
