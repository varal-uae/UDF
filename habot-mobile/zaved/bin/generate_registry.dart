import 'dart:io';

void main() {
  final componentMap = <String, Map<String, String>>{
    'REF-377-A12': {
      'path': 'lib/ui/progressive_stepper_wizard.dart',
      'class': 'ProgressiveStepperWizard'
    },
    'BPTR-0334-A15': {
      'path': 'lib/ui/fluid_typography_scaling_system.dart',
      'class': 'FluidTypographyScalingSystem'
    },
    'TTMCS-002-A01': {
      'path': 'lib/ui/binary_semantic_color_system.dart',
      'class': 'BinarySemanticColorSystem'
    },
    'HSCPE-007': {
      'path': 'lib/ui/filesystem_tuning_admin_dashboard.dart',
      'class': 'FilesystemTuningAdminDashboard'
    },
    'RCGLA-028': {
      'path': 'lib/habot_design_tokens/layouts/mobile_surgical_container.dart',
      'class': 'MobileSurgicalContainer'
    },
    'BPWSO-007-12': {
      'path': 'lib/ui/lineage_graph_terminal_alert_dashboard.dart',
      'class': 'LineageGraphTerminalAlertDashboard'
    },
    'USMBL-017': {
      'path': 'lib/ui/loading_submit_button_form.dart',
      'class': 'LoadingSubmitButtonForm'
    },
    'ARCPE-005-01': {
      'path': 'lib/ui/ai_output_analytics_view.dart',
      'class': 'AiOutputAnalyticsView'
    },
    'CCPME-002': {
      'path': 'lib/ui/multi_child_registration_form.dart',
      'class': 'MultiChildRegistrationForm'
    },
    'HSCPE-021': {
      'path': 'lib/ui/startup_probe_secure_repository.dart',
      'class': 'StartupProbeSecureRepository'
    },
    'IS26-RCGLA-024-AS01': {
      'path': 'lib/ui/dynamic_context_fab.dart',
      'class': 'DynamicContextFab'
    },
    'RCGLA-043': {
      'path': 'lib/ui/high_density_operational_data_table.dart',
      'class': 'HighDensityOperationalDataTable'
    },
    'CBSV-007': {
      'path': 'lib/ui/universal_lookup_matrix.dart',
      'class': 'UniversalLookupMatrix'
    },
    'EDBAA-015-15': {
      'path': 'lib/ui/component_library_doc_archive.dart',
      'class': 'ComponentLibraryDocArchive'
    },
    'RCGLA-021': {
      'path': 'lib/ui/responsive_layout_grid_engine.dart',
      'class': 'ResponsiveLayoutGridEngine'
    },
    'ACRAE-011': {
      'path': 'lib/ui/mobile_first_ai_chat_flow.dart',
      'class': 'MobileFirstAiChatFlow'
    },
    'ANSA-020-15': {
      'path': 'lib/ui/m3_adaptive_navigation_dashboard.dart',
      'class': 'M3AdaptiveNavigationDashboard'
    },
    'BLGTA-001-11': {
      'path': 'lib/ui/welcoming_initial_input_form.dart',
      'class': 'WelcomingInitialInputForm'
    },
    'MCIIM-020-13': {
      'path': 'lib/ui/hr_metric_target_contextual_modifier.dart',
      'class': 'HrMetricTargetContextualModifier'
    },
    'PCDE-016': {
      'path': 'lib/ui/secure_employee_payroll_register.dart',
      'class': 'SecureEmployeePayrollRegister'
    },
    'NSKFI-005': {
      'path': 'lib/ui/form_input_masking_native_keyboards.dart',
      'class': 'FormInputMaskingNativeKeyboards'
    },
    'BPTR-0803': {
      'path': 'lib/ui/edge_level_validation_form.dart',
      'class': 'EdgeLevelValidationForm'
    },
    'DPRBR-004': {
      'path': 'lib/ui/campaign_target_sku_selection.dart',
      'class': 'CampaignTargetSkuSelection'
    },
    'FLADE-011-06': {
      'path': 'lib/ui/shakti_alert_panel.dart',
      'class': 'ShaktiAlertPanel'
    },
    'AEETE-002-A07': {
      'path': 'lib/ui/ab_test_variant_preservation.dart',
      'class': 'AbTestVariantPreservation'
    },
    'HSFVS-001-A08': {
      'path': 'lib/ui/strict_linear_progression_viewpager.dart',
      'class': 'StrictLinearProgressionViewPager'
    },
    'ERMWD-007-08': {
      'path': 'lib/ui/operations_task_entry.dart',
      'class': 'OperationsTaskEntry'
    },
    'NQSDV-003': {
      'path': 'lib/ui/payment_gateway_verification_dashboard.dart',
      'class': 'PaymentGatewayVerificationDashboard'
    },
    'DSI-001': {
      'path': 'lib/ui/design_system_infrastructure_showcase.dart',
      'class': 'DesignSystemInfrastructureShowcase'
    },
    'IRBCA-061': {
      'path': 'lib/ui/board_signatory_access_constraint.dart',
      'class': 'BoardSignatoryAccessConstraint'
    },
    'PELCE-019-14': {
      'path': 'lib/ui/design_system_merge_dashboard.dart',
      'class': 'DesignSystemMergeDashboard'
    },
    'PELCE-019-01': {
      'path': 'lib/ui/system_verb_button.dart',
      'class': 'SystemVerbButton'
    },
    'NLM-APS-003': {
      'path': 'lib/ui/enterprise_cmek_security_console.dart',
      'class': 'EnterpriseCmekSecurityConsole'
    },
    'TECH-ENG-038': {
      'path': 'lib/ui/cicd_linter_accessibility_dashboard.dart',
      'class': 'CicdLinterAccessibilityDashboard'
    },
    'TECH-ENG-023': {
      'path': 'lib/ui/universal_engineering_notification_center.dart',
      'class': 'UniversalEngineeringNotificationCenter'
    },
    'TECH-ENG-005': {
      'path': 'lib/ui/bigquery_streaming_validation_dashboard.dart',
      'class': 'BigqueryStreamingValidationDashboard'
    },
    'OPMV-002': {
      'path': 'lib/ui/feedback_ranking_sync_ledger.dart',
      'class': 'FeedbackRankingSyncLedger'
    },
    'MCCEA-001': {
      'path': 'lib/ui/satisfaction_analytics_engine_dashboard.dart',
      'class': 'SatisfactionAnalyticsEngineDashboard'
    },
    'GTBPU-001': {
      'path': 'lib/ui/seamless_splash_login_profile_form.dart',
      'class': 'SeamlessSplashLoginProfileForm'
    },
    'UFHT-037': {
      'path': 'lib/ui/referral_link_workspace.dart',
      'class': 'ReferralLinkWorkspace'
    },
    'Row-1367.0': {
      'path': 'lib/ui/rate_limit_throttle_workspace.dart',
      'class': 'RateLimitThrottleWorkspace'
    },
    'FIEVR-002': {
      'path': 'lib/ui/offline_udd_sync_workspace.dart',
      'class': 'OfflineUddSyncWorkspace'
    },
    'DSDD-002': {
      'path': 'lib/ui/payload_upload_widget.dart',
      'class': 'PayloadUploadWidget'
    },
    'BLGTA-048': {
      'path': 'lib/ui/expense_taxonomy_picklist.dart',
      'class': 'ExpenseTaxonomyPicklist'
    },
    'REF-362': {
      'path': 'lib/ui/masked_regex_input_field.dart',
      'class': 'MaskedRegexInputField'
    },
    'AWCV-013': {
      'path': 'lib/ui/asynchronous_consensus_board.dart',
      'class': 'AsynchronousConsensusBoard'
    },
    'DPNDL-011': {
      'path': 'lib/ui/visual_isolation_workspace.dart',
      'class': 'VisualIsolationWorkspace'
    },
    'BPTR-0725': {
      'path': 'lib/ui/numeric_poka_yoke_form.dart',
      'class': 'NumericPokaYokeForm'
    },
    'TTMCS-002': {
      'path': 'lib/ui/validation_status_alert.dart',
      'class': 'ValidationStatusAlert'
    },
    'SCTAS-013': {
      'path': 'lib/widgets/payment_status_banner.dart',
      'class': 'PaymentStatusBanner'
    },
    'HC-IAM-0107': {
      'path': 'lib/ui/protected_analytical_logs.dart',
      'class': 'ProtectedAnalyticalLogsView'
    },
    'MCIIM-010-12': {
      'path': 'lib/ui/smart_bounding_box_document_isolator.dart',
      'class': 'SmartBoundingBoxDocumentIsolatorView'
    },
    'ETMDI-022-17': {
      'path': 'lib/ui/conditional_operations_view.dart',
      'class': 'ConditionalOperationsView'
    },
    'AMLCO-014': {
      'path': 'lib/ui/aml_query_gate_secure_auth_flow.dart',
      'class': 'AmlQueryGateView'
    },
    'BCDLD-013': {
      'path': 'lib/ui/binary_vap_login_modal.dart',
      'class': 'BinaryVapLoginModalView'
    },
    'TTMCS-011': {
      'path': 'lib/ui/master_menu_page.dart',
      'class': 'ThemeAdherenceTest'
    },
    'SSELC-004': {
      'path': 'lib/ui/split_screen_master_layout.dart',
      'class': 'SplitScreenMasterLayout'
    },
    'BPTR-0035': {
      'path': 'lib/ui/inbound_lead_validation_form.dart',
      'class': 'InboundLeadValidationForm'
    },
    'BPTR-0407': {
      'path': 'lib/ui/animated_masked_input_field.dart',
      'class': 'AnimatedMaskedInputField'
    },
    'MUFCE-004': {
      'path': 'lib/ui/dynamic_onboarding_journey.dart',
      'class': 'DynamicOnboardingJourney'
    },
  };

  final buf = StringBuffer();
  buf.writeln("/// Registry storing ready-to-copy source code snippets and metadata for all components.");
  buf.writeln("class ComponentCodeRegistry {");
  buf.writeln("  static final Map<String, Map<String, String>> _codeMap = {");

  for (final entry in componentMap.entries) {
    final refId = entry.key;
    final relPath = entry.value['path']!;
    final className = entry.value['class']!;
    final fileName = relPath.split('/').last;

    final file = File(relPath);
    String code = file.existsSync() ? file.readAsStringSync() : '// File not found: $relPath';

    code = code.replaceAll("'''", "''' + \"'''\" + r'''");

    buf.writeln("    '$refId': {");
    buf.writeln("      'fileName': '$fileName',");
    buf.writeln("      'widgetClassName': '$className',");
    buf.writeln("      'sourceCode': r'''$code''',");
    buf.writeln("    },");
  }

  buf.writeln("  };");
  buf.writeln("");
  buf.writeln("  /// Returns metadata & code for global reference ID or generates fallback");
  buf.writeln("  static Map<String, String> getCodeSpec({");
  buf.writeln("    required String globalRefId,");
  buf.writeln("    required String title,");
  buf.writeln("    required String category,");
  buf.writeln("  }) {");
  buf.writeln("    if (_codeMap.containsKey(globalRefId)) {");
  buf.writeln("      return _codeMap[globalRefId]!;");
  buf.writeln("    }");
  buf.writeln("");
  buf.writeln("    for (final entry in _codeMap.entries) {");
  buf.writeln("      if (globalRefId.startsWith(entry.key) ||");
  buf.writeln("          entry.key.startsWith(globalRefId) ||");
  buf.writeln("          globalRefId.contains(entry.key) ||");
  buf.writeln("          entry.key.contains(globalRefId)) {");
  buf.writeln("        return entry.value;");
  buf.writeln("      }");
  buf.writeln("    }");
  buf.writeln("");
  buf.writeln("    final formattedName = globalRefId.replaceAll('-', '_').toLowerCase();");
  buf.writeln("    final className = globalRefId");
  buf.writeln("        .split('-')");
  buf.writeln("        .map((s) => s.isNotEmpty ? s[0].toUpperCase() + s.substring(1).toLowerCase() : '')");
  buf.writeln("        .join('');");
  buf.writeln("");
  buf.writeln("    return {");
  buf.writeln("      'fileName': '\${formattedName}_widget.dart',");
  buf.writeln("      'widgetClassName': className,");
  buf.writeln("      'sourceCode': 'import \\'package:flutter/material.dart\\';\\n\\n/// Standalone Component Widget for [\$globalRefId] \$title.\\nclass \$className extends StatelessWidget {\\n  const \$className({super.key});\\n\\n  @override\\n  Widget build(BuildContext context) {\\n    return Card(\\n      child: Padding(\\n        padding: const EdgeInsets.all(16.0),\\n        child: Text(\\'\$title (\$globalRefId)\\'),\\n      ),\\n    );\\n  }\\n}',");
  buf.writeln("    };");
  buf.writeln("  }");
  buf.writeln("}");

  File('lib/ui/component_code_registry.dart').writeAsStringSync(buf.toString());
  stdout.writeln('ComponentCodeRegistry generated successfully!');
}
