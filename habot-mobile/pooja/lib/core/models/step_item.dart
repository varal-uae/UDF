import 'package:flutter/material.dart';

enum StepCategory {
  all('All Steps', Icons.apps),
  dataAndForms('Data & Forms', Icons.table_chart_outlined),
  realTimeSync('Real-Time & Sync', Icons.sync),
  aiAndAutomation('AI & Automation', Icons.auto_awesome),
  analyticsKpi('Analytics & KPI', Icons.analytics_outlined),
  infrastructure('Infrastructure', Icons.dns_outlined);

  final String label;
  final IconData icon;
  const StepCategory(this.label, this.icon);
}

class StepItem {
  final int stepNumber;
  final String stepCode;
  final String title;
  final String description;
  final StepCategory category;
  final IconData icon;
  final WidgetBuilder builder;

  const StepItem({
    required this.stepNumber,
    required this.stepCode,
    required this.title,
    required this.description,
    required this.category,
    required this.icon,
    required this.builder,
  });
}
