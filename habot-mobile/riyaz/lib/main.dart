import 'package:flutter/material.dart';
import 'core/models/step_item.dart';
import 'core/theme/app_theme_wrapper.dart';

import 'core/accessibility/keyboard_focus_ring_indicator_panel.dart';
import 'core/accessibility/letter_key_blockage_syntax_guard_panel.dart';
import 'core/accessibility/native_numeric_keyboard_trigger_panel.dart';
import 'core/accessibility/platform_focus_ring_rendering_panel.dart';
import 'core/accessibility/reduced_motion_accessibility_panel.dart';
import 'core/accessibility/semantic_contrast_color_tone_panel.dart';
import 'core/accessibility/share_fab_touch_target_size_panel.dart';
import 'core/accessibility/toast_screen_reader_announcement_panel.dart';
import 'core/accessibility/virtual_keypad_mobile_trigger_panel.dart';
import 'core/accessibility/zero_overflow_320px_viewport_panel.dart';
import 'core/compliance/api_failure_rollback_simulator_panel.dart';
import 'core/compliance/api_interceptor_lockout_auditor_panel.dart';
import 'core/compliance/banking_identity_regex_rule_panel.dart';
import 'core/compliance/byt_type_regex_keyboard_test_panel.dart';
import 'core/compliance/code_review_merge_gate_panel.dart';
import 'core/compliance/compound_action_pattern_test_panel.dart';
import 'core/compliance/concurrent_loading_flag_coordinator_panel.dart';
import 'core/compliance/cross_functional_sign_off_gate_panel.dart';
import 'core/compliance/cross_team_workflow_requirements_panel.dart';
import 'core/compliance/design_compliance_linter_engine_panel.dart';
import 'core/compliance/failed_compliance_alert_simulation_panel.dart';
import 'core/compliance/form_validation_pattern_finalizer_panel.dart';
import 'core/compliance/global_unmount_latency_verifier_panel.dart';
import 'core/compliance/ingress_form_input_masking_policy_panel.dart';
import 'core/compliance/input_text_masking_field_auditor_panel.dart';
import 'core/compliance/input_validation_pattern_embed_panel.dart';
import 'core/compliance/layout_jitter_visual_scanner_gate_panel.dart';
import 'core/compliance/m3_codebase_consistency_enforcer_panel.dart';
import 'core/compliance/m3_standard_widget_compliance_panel.dart';
import 'core/compliance/malformed_string_denial_verifier_panel.dart';
import 'core/compliance/mypy_layout_flag_config_panel.dart';
import 'core/compliance/network_disconnection_simulation_panel.dart';
import 'core/compliance/offboarding_manual_analyzer_panel.dart';
import 'core/compliance/on_blur_input_length_validator_panel.dart';
import 'core/compliance/online_dependent_feature_catalog_panel.dart';
import 'core/compliance/operational_health_monitor_badge_panel.dart';
import 'core/compliance/organism_flow_integration_test_panel.dart';
import 'core/compliance/production_rollback_handler_deployment_panel.dart';
import 'core/compliance/quarantine_audit_event_repository_panel.dart';
import 'core/compliance/regex_valid_pattern_pass_through_panel.dart';
import 'core/compliance/src_unit_test_coverage_panel.dart';
import 'core/compliance/staging_disabling_framework_verifier_panel.dart';
import 'core/compliance/staging_environment_validation_panel.dart';
import 'core/compliance/staging_server_layout_deployment_panel.dart';
import 'core/compliance/standardized_component_linter_rule_panel.dart';
import 'core/compliance/static_code_scanner_deployment_gate_panel.dart';
import 'core/compliance/strict_input_mask_deployment_panel.dart';
import 'core/compliance/submission_blocked_error_snackbar_panel.dart';
import 'core/compliance/ui_regression_test_suite_runner_panel.dart';
import 'core/compliance/unauthorized_ui_linter_verifier_panel.dart';
import 'core/interaction/backspace_formatting_jump_handler_panel.dart';
import 'core/interaction/chip_filter_latency_verifier_panel.dart';
import 'core/interaction/compound_action_split_rule_panel.dart';
import 'core/interaction/cursor_auto_advance_formatter_panel.dart';
import 'core/interaction/desktop_hover_trigger_pointer_panel.dart';
import 'core/interaction/dual_value_form_controller_exposure_panel.dart';
import 'core/interaction/load_state_interaction_blocker_panel.dart';
import 'core/interaction/mobile_input_masking_hook_panel.dart';
import 'core/interaction/mobile_long_press_trigger_panel.dart';
import 'core/interaction/non_zero_difference_button_disabler_panel.dart';
import 'core/interaction/number_pad_trigger_config_panel.dart';
import 'core/interaction/organism_state_management_coordinator_panel.dart';
import 'core/interaction/overlay_activation_state_trigger_panel.dart';
import 'core/interaction/real_time_keystroke_interceptor_panel.dart';
import 'core/interaction/regex_mask_violation_blocker_panel.dart';
import 'core/interaction/rule_of_and_viewpager_enforcer_panel.dart';
import 'core/interaction/scroll_position_listener_tracking_panel.dart';
import 'core/interaction/sequential_execution_state_orchestrator_panel.dart';
import 'core/interaction/side_panel_slide_toggle_mechanic_panel.dart';
import 'core/interaction/throttled_network_animation_curve_panel.dart';
import 'core/interaction/toast_animation_transition_panel.dart';
import 'core/layout/absolute_root_layout_container_panel.dart';
import 'core/layout/clean_text_wrap_layout_panel.dart';
import 'core/layout/compact_viewport_single_column_ban_panel.dart';
import 'core/layout/core_grid_engine_breakpoint_panel.dart';
import 'core/layout/device_posture_orientation_listener_panel.dart';
import 'core/layout/document_corner_crop_slider_panel.dart';
import 'core/layout/fluid_client_layout_container_panel.dart';
import 'core/layout/full_width_banner_container_panel.dart';
import 'core/layout/grid_container_flex_layout_panel.dart';
import 'core/layout/immersive_modal_sheet_layout_panel.dart';
import 'core/layout/multi_device_viewport_test_panel.dart';
import 'core/layout/multi_step_wizard_layout_panel.dart';
import 'core/layout/nested_layout_composition_test_panel.dart';
import 'core/layout/organism_responsive_breakpoint_panel.dart';
import 'core/layout/responsive_breathing_room_layout_panel.dart';
import 'core/layout/togglable_side_pane_layout_panel.dart';
import 'core/layout/wide_window_side_sheet_panel.dart';
import 'core/layout/z_index_layering_boundary_panel.dart';
import 'core/network/automated_data_broadcast_trigger_panel.dart';
import 'core/network/bigquery_layout_rendering_tracker_panel.dart';
import 'core/network/image_crop_coordinate_streamer_panel.dart';
import 'core/network/jwt_token_header_extractor_panel.dart';
import 'core/network/keystroke_interceptor_deployment_panel.dart';
import 'core/network/network_information_tracking_hooks_panel.dart';
import 'core/network/offline_chart_cache_streamer_panel.dart';
import 'core/network/payload_pipeline_filter_integration_panel.dart';
import 'core/network/quarantine_event_collection_channel_panel.dart';
import 'core/network/re_authentication_identity_provider_panel.dart';
import 'core/network/signed_url_image_payload_security_panel.dart';
import 'core/network/submit_interceptor_state_handler_panel.dart';
import 'core/network/telemetry_pipeline_transfer_panel.dart';
import 'core/network/vanity_dataset_filter_engine_panel.dart';
import 'core/theme/data_transmission_disabled_style_panel.dart';
import 'core/tokens/alignment_variables_token_repository_panel.dart';
import 'core/tokens/autocorrect_off_code_field_panel.dart';
import 'core/tokens/body_small_typescale_token_panel.dart';
import 'core/tokens/byt_data_type_regex_pattern_panel.dart';
import 'core/tokens/core_private_package_style_inheritance_panel.dart';
import 'core/tokens/dense_table_row_height_token_panel.dart';
import 'core/tokens/eight_dp_baseline_grid_token_panel.dart';
import 'core/tokens/eight_dp_horizontal_cell_padding_panel.dart';
import 'core/tokens/fluid_height_constraint_enforcer_panel.dart';
import 'core/tokens/focus_ring_token_documentation_panel.dart';
import 'core/tokens/frame_rendering_fps_threshold_panel.dart';
import 'core/tokens/global_design_token_definition_panel.dart';
import 'core/tokens/grid_setup_style_repository_panel.dart';
import 'core/tokens/m3_spatial_token_clutter_prevention_panel.dart';
import 'core/tokens/material_design_3_token_definition_panel.dart';
import 'core/tokens/motion_token_definition_panel.dart';
import 'core/tokens/responsive_spacing_multiplier_token_panel.dart';
import 'core/tokens/shimmer_gradient_contrast_token_panel.dart';
import 'core/tokens/success_color_token_indicator_panel.dart';
import 'core/tokens/tertiary_color_token_outlined_card_panel.dart';
import 'core/ui/auth_timeout_fallback_node_panel.dart';
import 'core/ui/binary_checklist_gate_row_panel.dart';
import 'core/ui/collapsible_transaction_table_panel.dart';
import 'core/ui/connectivity_toast_style_panel.dart';
import 'core/ui/financial_dashboard_variance_tracker_panel.dart';
import 'core/ui/focused_data_display_isolation_panel.dart';
import 'core/ui/manual_dismiss_overlay_card_panel.dart';
import 'core/ui/masked_input_component_wrapper_panel.dart';
import 'core/ui/md3_linear_progress_bar_panel.dart';
import 'core/ui/minimalist_single_purpose_screen_panel.dart';
import 'core/ui/motion_curve_browser_consistency_panel.dart';
import 'core/ui/non_blocking_background_process_decision_panel.dart';
import 'core/ui/non_blocking_navigation_pattern_panel.dart';
import 'core/ui/overlay_freeze_container_scenario_panel.dart';
import 'core/ui/payroll_user_interface_access_panel.dart';
import 'core/ui/raw_audit_log_layout_locator_panel.dart';
import 'core/ui/referral_savings_metric_dashboard_panel.dart';
import 'core/ui/registered_element_tooltip_wiring_panel.dart';
import 'core/ui/semantic_outline_alert_frame_panel.dart';
import 'core/ui/skeleton_card_volume_wrapper_panel.dart';
import 'core/ui/smart_keyboard_field_access_panel.dart';
import 'core/ui/team_leader_verification_queue_panel.dart';
import 'core/ui/text_region_error_track_panel.dart';
import 'core/ui/toast_deduplication_queue_panel.dart';
import 'core/ui/transaction_error_parameter_mapper_panel.dart';
import 'core/ui/visual_parity_spec_verifier_panel.dart';
import 'core/versioning/component_library_linter_docs_panel.dart';
import 'core/versioning/design_library_attribute_pull_panel.dart';
import 'core/versioning/design_system_workspace_config_panel.dart';
import 'core/versioning/feature_toggle_ui_wrapper_panel.dart';
import 'core/versioning/global_button_component_swapper_panel.dart';
import 'core/versioning/local_draft_indexed_db_panel.dart';
import 'core/versioning/molecular_component_inventory_panel.dart';
import 'core/versioning/reusable_independent_function_panel.dart';
import 'core/versioning/row_level_data_insulation_barrier_panel.dart';
import 'core/versioning/shimmer_speed_design_system_docs_panel.dart';
import 'core/versioning/tooltip_registry_documentation_panel.dart';

void main() {
  runApp(const HabotMobileUiApp());
}

class HabotMobileUiApp extends StatelessWidget {
  const HabotMobileUiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppThemeWrapper(
      child: StepCatalogHomePage(),
    );
  }
}

class StepCatalogHomePage extends StatefulWidget {
  const StepCatalogHomePage({super.key});

  @override
  State<StepCatalogHomePage> createState() => _StepCatalogHomePageState();
}

class _StepCatalogHomePageState extends State<StepCatalogHomePage> {
  late final List<StepItem> _steps = _buildAppStepDirectory();
  String _query = '';
  StepCategory? _filter;
  bool _latestBatchOnly = false;

  int get _maxRow =>
      _steps.isEmpty ? 0 : _steps.map((s) => s.excelRow).reduce((a, b) => a > b ? a : b);
  int get _minLatestRow => _maxRow > 10 ? (_maxRow - 9) : 2;

  List<StepItem> get _visibleSteps {
    return _steps.where((step) {
      final matchesFilter = _filter == null || step.category == _filter;
      final matchesLatest = !_latestBatchOnly || (step.excelRow >= _minLatestRow);
      final haystack =
          '${step.stepCode} ${step.atomicStepCode} ${step.title} ${step.description}'
              .toLowerCase();
      final matchesQuery = _query.isEmpty || haystack.contains(_query);
      return matchesFilter && matchesLatest && matchesQuery;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final visible = _visibleSteps;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Habot Mobile UI Catalog'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: Text(
                '${_steps.length} steps',
                style: theme.textTheme.labelLarge,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                labelText: 'Search atomic steps',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() => _query = value.trim().toLowerCase());
              },
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                FilterChip(
                  avatar: const Icon(Icons.auto_awesome, size: 16),
                  label: Text(_latestBatchOnly
                      ? 'Latest Batch (Rows $_minLatestRow–$_maxRow)'
                      : 'Latest Batch'),
                  selected: _latestBatchOnly,
                  selectedColor: theme.colorScheme.primaryContainer,
                  onSelected: (val) {
                    setState(() {
                      _latestBatchOnly = val;
                    });
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('All'),
                  selected: _filter == null && !_latestBatchOnly,
                  onSelected: (_) => setState(() {
                    _filter = null;
                    _latestBatchOnly = false;
                  }),
                ),
                ...StepCategory.values.map((category) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: FilterChip(
                      label: Text(category.name),
                      selected: _filter == category,
                      onSelected: (_) {
                        setState(() => _filter = category);
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: visible.isEmpty
                ? const Center(child: Text('No steps match the current filter.'))
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 24),
                    itemCount: visible.length,
                    itemBuilder: (context, index) {
                      final step = visible[index];
                      return ListTile(
                        leading: Icon(step.icon),
                        title: Text('${step.atomicStepCode} — ${step.title}'),
                        subtitle: Text(
                          'Row ${step.excelRow} • Seq ${step.sequenceOrder} • ${step.categoryLabel}',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (context) => StepDetailPage(step: step),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class StepDetailPage extends StatelessWidget {
  final StepItem step;

  const StepDetailPage({super.key, required this.step});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(step.atomicStepCode),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              step.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          step.builder(context),
        ],
      ),
    );
  }
}

List<StepItem> _buildAppStepDirectory() {
  return [
    StepItem(
      stepCode: 'MUFCE-010',
      atomicStepCode: 'MUFCE-010-A05',
      title: 'Network Info Hooks',
      description:
          'Set up client-side tracking hooks using the Browser Network Information API to read network speeds.',
      category: StepCategory.network,
      icon: Icons.network_check_outlined,
      excelRow: 2,
      sequenceOrder: 30440,
      builder: (_) => const NetworkInformationTrackingHooksPanel(),
    ),
    StepItem(
      stepCode: 'MUFCE-011',
      atomicStepCode: 'MUFCE-011-A10',
      title: 'Throttled Motion Curve',
      description:
          'Test the animation curve on throttled/slow network conditions for elegance.',
      category: StepCategory.interaction,
      icon: Icons.animation_outlined,
      excelRow: 3,
      sequenceOrder: 30461,
      builder: (_) => const ThrottledNetworkAnimationCurvePanel(),
    ),
    StepItem(
      stepCode: 'MUFCE-011',
      atomicStepCode: 'MUFCE-011-A12',
      title: 'Browser Motion Consistency',
      description:
          'Confirm the motion curve behaves consistently across supported browsers.',
      category: StepCategory.ui,
      icon: Icons.web_asset_outlined,
      excelRow: 4,
      sequenceOrder: 30463,
      builder: (_) => const MotionCurveBrowserConsistencyPanel(),
    ),
    StepItem(
      stepCode: 'MUFCE-011',
      atomicStepCode: 'MUFCE-011-A13',
      title: 'Reduced Motion Gate',
      description:
          'Confirm the motion curve respects reduced-motion accessibility settings.',
      category: StepCategory.accessibility,
      icon: Icons.accessibility_new_outlined,
      excelRow: 5,
      sequenceOrder: 30464,
      builder: (_) => const ReducedMotionAccessibilityPanel(),
    ),
    StepItem(
      stepCode: 'MUFCE-011',
      atomicStepCode: 'MUFCE-011-A19',
      title: 'Code Review Merge Gate',
      description:
          'Conduct code review and merge the change.',
      category: StepCategory.compliance,
      icon: Icons.merge_type_outlined,
      excelRow: 6,
      sequenceOrder: 30470,
      builder: (_) => const CodeReviewMergeGatePanel(),
    ),
    StepItem(
      stepCode: 'MUFCE-011',
      atomicStepCode: 'MUFCE-011-A20',
      title: 'Staging Environment Validation',
      description:
          'Validate the final behavior in the staging environment.',
      category: StepCategory.compliance,
      icon: Icons.cloud_done_outlined,
      excelRow: 7,
      sequenceOrder: 30471,
      builder: (_) => const StagingEnvironmentValidationPanel(),
    ),
    StepItem(
      stepCode: 'MUFCE-012',
      atomicStepCode: 'MUFCE-012-A16',
      title: 'Chip Filter Latency Verifier',
      description:
          'Verify that activating chip elements triggers backend table filter sweeps in under 300 ms.',
      category: StepCategory.interaction,
      icon: Icons.label_outline_rounded,
      excelRow: 8,
      sequenceOrder: 30487,
      builder: (_) => const ChipFilterLatencyVerifierPanel(),
    ),
    StepItem(
      stepCode: 'MUFCE-018',
      atomicStepCode: 'MUFCE-018-A01',
      title: 'Design Compliance Linter',
      description:
          'Open the DevOps CI/CD pipeline code analysis directory and locate DesignComplianceLinterEngine.',
      category: StepCategory.compliance,
      icon: Icons.rule_folder_outlined,
      excelRow: 9,
      sequenceOrder: 30520,
      builder: (_) => const DesignComplianceLinterEnginePanel(),
    ),
    StepItem(
      stepCode: 'MUFCE-018',
      atomicStepCode: 'MUFCE-018-A07',
      title: 'Fluid Height Enforcer',
      description:
          'Outlaw custom raw static pixel height statements inside product code bases globally.',
      category: StepCategory.tokens,
      icon: Icons.height_rounded,
      excelRow: 10,
      sequenceOrder: 30526,
      builder: (_) => const FluidHeightConstraintEnforcerPanel(),
    ),
    StepItem(
      stepCode: 'MUFCE-020',
      atomicStepCode: 'MUFCE-020-A09',
      title: 'Document Corner Crop Slider',
      description:
          'Allow operators to touch and slide corner bounding handles to crop document dimensions cleanly before transmission.',
      category: StepCategory.layout,
      icon: Icons.crop_rotate_rounded,
      excelRow: 11,
      sequenceOrder: 30556,
      builder: (_) => const DocumentCornerCropSliderPanel(),
    ),
    StepItem(
      stepCode: 'MUFCE-024',
      atomicStepCode: 'MUFCE-024',
      title: 'Vanity Dataset Filter Engine',
      description:
          'Set analytical engines to block displays if users overlay social vanity datasets.',
      category: StepCategory.network,
      icon: Icons.security_update_good_rounded,
      excelRow: 12,
      sequenceOrder: 30578,
      builder: (_) => const VanityDatasetFilterEnginePanel(),
    ),
    StepItem(
      stepCode: 'MUFCE-030',
      atomicStepCode: 'MUFCE-030-A10',
      title: 'Image Coordinate Streamer',
      description:
          'Restrict raw image delivery sizes, passing cropped snippet coordinates to optimization servers.',
      category: StepCategory.network,
      icon: Icons.filter_hdr_outlined,
      excelRow: 13,
      sequenceOrder: 30667,
      builder: (_) => const ImageCropCoordinateStreamerPanel(),
    ),
    StepItem(
      stepCode: 'NSKFI-001',
      atomicStepCode: 'NSKFI-001-A08',
      title: 'Keyboard Focus Ring Indicator',
      description:
          'Implement the focus ring CSS using the :focus-visible pseudo-class — applies only on keyboard focus.',
      category: StepCategory.accessibility,
      icon: Icons.keyboard_alt_outlined,
      excelRow: 14,
      sequenceOrder: 30905,
      builder: (_) => const KeyboardFocusRingIndicatorPanel(),
    ),
    StepItem(
      stepCode: 'NSKFI-001',
      atomicStepCode: 'NSKFI-001-A15',
      title: 'Platform Focus Ring Rendering',
      description:
          'Test focus ring behavior on Android and iOS — verify platform-specific focus rendering is consistent.',
      category: StepCategory.accessibility,
      icon: Icons.devices_other_outlined,
      excelRow: 15,
      sequenceOrder: 30912,
      builder: (_) => const PlatformFocusRingRenderingPanel(),
    ),
    StepItem(
      stepCode: 'NSKFI-001',
      atomicStepCode: 'NSKFI-001-A18',
      title: 'Focus Ring Token Documentation',
      description:
          'Document the focus ring token values and the :focus-visible implementation pattern.',
      category: StepCategory.tokens,
      icon: Icons.book_outlined,
      excelRow: 16,
      sequenceOrder: 30915,
      builder: (_) => const FocusRingTokenDocumentationPanel(),
    ),
    StepItem(
      stepCode: 'NSKFI-002',
      atomicStepCode: 'NSKFI-002-A10',
      title: 'SRC Unit Test Coverage',
      description:
          'Write unit tests for each SRC covering all variants and edge cases.',
      category: StepCategory.compliance,
      icon: Icons.bug_report_outlined,
      excelRow: 17,
      sequenceOrder: 30925,
      builder: (_) => const SrcUnitTestCoveragePanel(),
    ),
    StepItem(
      stepCode: 'NSKFI-003',
      atomicStepCode: 'NSKFI-003-A01',
      title: 'Overlay Freeze Scenarios',
      description:
          'Define the scenarios where the overlay freeze container is triggered — form submission, processing, critical alert.',
      category: StepCategory.ui,
      icon: Icons.layers_clear_outlined,
      excelRow: 18,
      sequenceOrder: 30934,
      builder: (_) => const OverlayFreezeContainerScenarioPanel(),
    ),
    StepItem(
      stepCode: 'NSKFI-003',
      atomicStepCode: 'NSKFI-003-A03',
      title: 'Z-Index Layering Boundary',
      description:
          'Define the z-index value — set to 4000 to ensure it sits above all standard UI layers.',
      category: StepCategory.layout,
      icon: Icons.format_line_spacing_rounded,
      excelRow: 19,
      sequenceOrder: 30936,
      builder: (_) => const ZIndexLayeringBoundaryPanel(),
    ),
    StepItem(
      stepCode: 'NSKFI-003',
      atomicStepCode: 'NSKFI-003-A06',
      title: 'Overlay Activation Trigger',
      description:
          'Implement the activation mechanism — overlay is triggered by a boolean prop or global state flag.',
      category: StepCategory.interaction,
      icon: Icons.switch_access_shortcut_add_outlined,
      excelRow: 20,
      sequenceOrder: 30939,
      builder: (_) => const OverlayActivationStateTriggerPanel(),
    ),
    StepItem(
      stepCode: 'NSKFI-004',
      atomicStepCode: 'NSKFI-004-A01',
      title: 'Ingress Form Input Masking',
      description:
          'Review the Poka-Yoke input masking strategy specifications for Right Ingress Forms.',
      category: StepCategory.compliance,
      icon: Icons.password_outlined,
      excelRow: 21,
      sequenceOrder: 30952,
      builder: (_) => const IngressFormInputMaskingPolicyPanel(),
    ),
    StepItem(
      stepCode: 'NSKFI-004',
      atomicStepCode: 'NSKFI-004-A07',
      title: 'Native Numeric Keyboard Trigger',
      description:
          'Declare the matching native keyboard trigger rule to force numeric keyboards on mobile viewports.',
      category: StepCategory.accessibility,
      icon: Icons.dialpad_outlined,
      excelRow: 22,
      sequenceOrder: 30958,
      builder: (_) => const NativeNumericKeyboardTriggerPanel(),
    ),
    StepItem(
      stepCode: 'NSKFI-004',
      atomicStepCode: 'NSKFI-004-A12',
      title: 'Regex Mask Violation Blocker',
      description:
          'Prevent the text property field from updating if characters violate the active regex formatting mask.',
      category: StepCategory.interaction,
      icon: Icons.block_outlined,
      excelRow: 23,
      sequenceOrder: 30963,
      builder: (_) => const RegexMaskViolationBlockerPanel(),
    ),
    StepItem(
      stepCode: 'NSKFI-005',
      atomicStepCode: 'NSKFI-005-A02',
      title: 'Number-Pad Trigger Config',
      description:
          'Configure number-pad call triggers for numeric input fields.',
      category: StepCategory.interaction,
      icon: Icons.dialpad_rounded,
      excelRow: 24,
      sequenceOrder: 30972,
      builder: (_) => const NumberPadTriggerConfigPanel(),
    ),
    StepItem(
      stepCode: 'NSKFI-005',
      atomicStepCode: 'NSKFI-005-A10',
      title: 'Regex Valid Pattern Pass-Through',
      description:
          'Test regex rejection allows a valid string pattern through.',
      category: StepCategory.compliance,
      icon: Icons.checklist_outlined,
      excelRow: 25,
      sequenceOrder: 30980,
      builder: (_) => const RegexValidPatternPassThroughPanel(),
    ),
    StepItem(
      stepCode: 'NSKFI-005',
      atomicStepCode: 'NSKFI-005-A13',
      title: 'Malformed String Denial Verifier',
      description:
          'Verify malformed strings are denied consistently across the form.',
      category: StepCategory.compliance,
      icon: Icons.gpp_bad_outlined,
      excelRow: 26,
      sequenceOrder: 30983,
      builder: (_) => const MalformedStringDenialVerifierPanel(),
    ),
    StepItem(
      stepCode: 'NSKFI-007',
      atomicStepCode: 'NSKFI-007-A09',
      title: 'Autocorrect Off Code Field',
      description:
          'Apply the autocorrect="off" tag on designated code fields.',
      category: StepCategory.tokens,
      icon: Icons.spellcheck_rounded,
      excelRow: 27,
      sequenceOrder: 30993,
      builder: (_) => const AutocorrectOffCodeFieldPanel(),
    ),
    StepItem(
      stepCode: 'NSKFI-008',
      atomicStepCode: 'NSKFI-008-A02',
      title: 'Motion Token Definition',
      description:
          'Define a standard set of motion tokens (duration, easing) for the design system.',
      category: StepCategory.tokens,
      icon: Icons.animation_rounded,
      excelRow: 28,
      sequenceOrder: 31002,
      builder: (_) => const MotionTokenDefinitionPanel(),
    ),
    StepItem(
      stepCode: 'NSKFI-008',
      atomicStepCode: 'NSKFI-008-A14',
      title: 'Frame Rendering FPS Threshold',
      description:
          'Set performance test thresholds to confirm frame rendering remains at or above 60 FPS.',
      category: StepCategory.tokens,
      icon: Icons.speed_outlined,
      excelRow: 29,
      sequenceOrder: 31014,
      builder: (_) => const FrameRenderingFpsThresholdPanel(),
    ),
    StepItem(
      stepCode: 'NSKFI-015',
      atomicStepCode: 'NSKFI-015-A01',
      title: 'SmartKeyboardField Access',
      description:
          'Access the SmartKeyboardField component inside the Frontend Design System.',
      category: StepCategory.ui,
      icon: Icons.keyboard_outlined,
      excelRow: 30,
      sequenceOrder: 31068,
      builder: (_) => const SmartKeyboardFieldAccessPanel(),
    ),
    StepItem(
      stepCode: 'NSKFI-015',
      atomicStepCode: 'NSKFI-015-A14',
      title: 'Virtual Keypad Mobile Trigger',
      description:
          'Test virtual keypad triggering across mobile devices to confirm numeric pads slide up for values.',
      category: StepCategory.accessibility,
      icon: Icons.phonelink_rounded,
      excelRow: 31,
      sequenceOrder: 31081,
      builder: (_) => const VirtualKeypadMobileTriggerPanel(),
    ),
    StepItem(
      stepCode: 'NSKFI-015',
      atomicStepCode: 'NSKFI-015-A15',
      title: 'Letter Key Blockage Syntax Guard',
      description:
          'Confirm that letter key blockages eliminate syntax errors and typos during data entry.',
      category: StepCategory.accessibility,
      icon: Icons.no_encryption_gmailerrorred_outlined,
      excelRow: 32,
      sequenceOrder: 31082,
      builder: (_) => const LetterKeyBlockageSyntaxGuardPanel(),
    ),
    StepItem(
      stepCode: 'OFBSE-010',
      atomicStepCode: 'OFBSE-010-A03',
      title: 'Connectivity Toast Style',
      description:
          'Standardize the visual style (color, icon, placement) across all connectivity toasts.',
      category: StepCategory.ui,
      icon: Icons.style_outlined,
      excelRow: 33,
      sequenceOrder: 31140,
      builder: (_) => const ConnectivityToastStylePanel(),
    ),
    StepItem(
      stepCode: 'OFBSE-010',
      atomicStepCode: 'OFBSE-010-A06',
      title: 'Toast Animation Transition',
      description:
          'Implement smooth entry and exit animations for the toast transitions.',
      category: StepCategory.interaction,
      icon: Icons.auto_awesome_motion_outlined,
      excelRow: 34,
      sequenceOrder: 31143,
      builder: (_) => const ToastAnimationTransitionPanel(),
    ),
    StepItem(
      stepCode: 'OFBSE-010',
      atomicStepCode: 'OFBSE-010-A07',
      title: 'Toast Deduplication Queue',
      description:
          'Ensure only one connectivity toast is visible at a time (dedupe logic).',
      category: StepCategory.ui,
      icon: Icons.filter_none_outlined,
      excelRow: 35,
      sequenceOrder: 31144,
      builder: (_) => const ToastDeduplicationQueuePanel(),
    ),
    StepItem(
      stepCode: 'OFBSE-010',
      atomicStepCode: 'OFBSE-010-A15',
      title: 'Toast Screen-Reader Announcement',
      description:
          'Confirm screen-reader announcements for connectivity toast changes.',
      category: StepCategory.accessibility,
      icon: Icons.record_voice_over_outlined,
      excelRow: 36,
      sequenceOrder: 31151,
      builder: (_) => const ToastScreenReaderAnnouncementPanel(),
    ),
    StepItem(
      stepCode: 'ONCS-010-02',
      atomicStepCode: 'ONCS-010-02',
      title: 'Local Draft IndexedDB',
      description:
          'Initialize an IndexedDB database instance dedicated to local draft persistence.',
      category: StepCategory.versioning,
      icon: Icons.storage_outlined,
      excelRow: 37,
      sequenceOrder: 31320,
      builder: (_) => const LocalDraftIndexedDbPanel(),
    ),
    StepItem(
      stepCode: 'ONCS-010-14',
      atomicStepCode: 'ONCS-010-14',
      title: 'Network Disconnection Sim',
      description:
          'Simulate a physical network disconnection during active form entry in a test environment.',
      category: StepCategory.compliance,
      icon: Icons.signal_wifi_off_outlined,
      excelRow: 38,
      sequenceOrder: 31332,
      builder: (_) => const NetworkDisconnectionSimulationPanel(),
    ),
    StepItem(
      stepCode: 'ONCS-011',
      atomicStepCode: 'ONCS-011',
      title: 'Offline Chart Cache Streamer',
      description:
          'Configure dynamic charts to update instantly using locally cached parameters without loading delays or screen-freezing hiccups.',
      category: StepCategory.network,
      icon: Icons.area_chart_outlined,
      excelRow: 39,
      sequenceOrder: 31334,
      builder: (_) => const OfflineChartCacheStreamerPanel(),
    ),
    StepItem(
      stepCode: 'ONCS-022',
      atomicStepCode: 'ONCS-022',
      title: 'Payload Pipeline Filter',
      description:
          'Integrate the filter into the payload processing pipeline.',
      category: StepCategory.network,
      icon: Icons.filter_alt_outlined,
      excelRow: 40,
      sequenceOrder: 31401,
      builder: (_) => const PayloadPipelineFilterIntegrationPanel(),
    ),
    StepItem(
      stepCode: 'ONLSC-008-19',
      atomicStepCode: 'ONLSC-008-19',
      title: 'Operational Health Badge',
      description:
          'Confirm operational health monitors present pristine "Verified Badge" state.',
      category: StepCategory.compliance,
      icon: Icons.verified_user_outlined,
      excelRow: 41,
      sequenceOrder: 31641,
      builder: (_) => const OperationalHealthMonitorBadgePanel(),
    ),
    StepItem(
      stepCode: 'OPMV-016',
      atomicStepCode: 'OPMV-016-A02',
      title: 'Transaction Error Parameter Mapper',
      description:
          'Map core error presentation parameters matching failed transaction records.',
      category: StepCategory.ui,
      icon: Icons.error_outline_rounded,
      excelRow: 42,
      sequenceOrder: 32149,
      builder: (_) => const TransactionErrorParameterMapperPanel(),
    ),
    StepItem(
      stepCode: 'OPMV-016',
      atomicStepCode: 'OPMV-016-A04',
      title: 'Semantic Contrast Color Tones',
      description:
          'Apply forced standard color tones matching certified semantic contrast guidelines.',
      category: StepCategory.accessibility,
      icon: Icons.contrast_outlined,
      excelRow: 43,
      sequenceOrder: 32151,
      builder: (_) => const SemanticContrastColorTonePanel(),
    ),
    StepItem(
      stepCode: 'OPMV-016',
      atomicStepCode: 'OPMV-016-A10',
      title: 'Quarantine Audit Event Repository',
      description:
          'Connect alert event triggers to write quarantine metadata fields into central audit repositories.',
      category: StepCategory.compliance,
      icon: Icons.security_outlined,
      excelRow: 44,
      sequenceOrder: 32157,
      builder: (_) => const QuarantineAuditEventRepositoryPanel(),
    ),
    StepItem(
      stepCode: 'OPMV-016',
      atomicStepCode: 'OPMV-016-A13',
      title: 'Quarantine Event Collection Channel',
      description:
          'Connect quarantine tracking functions to record background event collection channels.',
      category: StepCategory.network,
      icon: Icons.stream_outlined,
      excelRow: 45,
      sequenceOrder: 32160,
      builder: (_) => const QuarantineEventCollectionChannelPanel(),
    ),
    StepItem(
      stepCode: 'OPMV-016',
      atomicStepCode: 'OPMV-016-A14',
      title: 'Failed Compliance Alert Simulation',
      description:
          'Run test simulations with failed compliance checks to verify immediate alert card rendering.',
      category: StepCategory.compliance,
      icon: Icons.notification_important_outlined,
      excelRow: 46,
      sequenceOrder: 32161,
      builder: (_) => const FailedComplianceAlertSimulationPanel(),
    ),
    StepItem(
      stepCode: 'OPMV-021',
      atomicStepCode: 'OPMV-021-A03',
      title: 'Full Width Banner Container',
      description:
          'Construct a highly visible banner container stretching fully across the top layout width.',
      category: StepCategory.layout,
      icon: Icons.view_stream_outlined,
      excelRow: 47,
      sequenceOrder: 32180,
      builder: (_) => const FullWidthBannerContainerPanel(),
    ),
    StepItem(
      stepCode: 'PBTC-003',
      atomicStepCode: 'PBTC-003-A04',
      title: 'Dense Table Row Height Token',
      description:
          'Apply the 32dp row height uniformly across all table elements in the layout.',
      category: StepCategory.tokens,
      icon: Icons.table_rows_outlined,
      excelRow: 48,
      sequenceOrder: 32209,
      builder: (_) => const DenseTableRowHeightTokenPanel(),
    ),
    StepItem(
      stepCode: 'PBTC-007',
      atomicStepCode: 'PBTC-007-A02',
      title: 'Compound Action Split Rule',
      description:
          'Define the rule that each compound action splits into two discrete atomic actions.',
      category: StepCategory.interaction,
      icon: Icons.call_split_outlined,
      excelRow: 49,
      sequenceOrder: 32254,
      builder: (_) => const CompoundActionSplitRulePanel(),
    ),
    StepItem(
      stepCode: 'PBTC-007',
      atomicStepCode: 'PBTC-007-A12',
      title: 'Rule of AND Viewpager Enforcer',
      description:
          'Confirm the Rule of AND is enforced programmatically across the viewpager.',
      category: StepCategory.interaction,
      icon: Icons.view_carousel_outlined,
      excelRow: 50,
      sequenceOrder: 32264,
      builder: (_) => const RuleOfAndViewpagerEnforcerPanel(),
    ),
    StepItem(
      stepCode: 'PBTC-007',
      atomicStepCode: 'PBTC-007-A14',
      title: 'Compound Action Pattern Test',
      description:
          'Test the pattern generalizes correctly to the new compound action.',
      category: StepCategory.compliance,
      icon: Icons.flaky_outlined,
      excelRow: 51,
      sequenceOrder: 32266,
      builder: (_) => const CompoundActionPatternTestPanel(),
    ),
    StepItem(
      stepCode: 'PCDE-017',
      atomicStepCode: 'PCDE-017',
      title: 'Team Leader Verification Queue',
      description:
          'Build a verification queue interface for the Team Leader (TL).',
      category: StepCategory.ui,
      icon: Icons.supervisor_account_outlined,
      excelRow: 52,
      sequenceOrder: 32532,
      builder: (_) => const TeamLeaderVerificationQueuePanel(),
    ),
    StepItem(
      stepCode: 'PCDE-025',
      atomicStepCode: 'PCDE-025',
      title: 'Payroll User Interface Access',
      description:
          '9. Access the Payroll User Interface (UI).',
      category: StepCategory.ui,
      icon: Icons.account_balance_wallet_outlined,
      excelRow: 53,
      sequenceOrder: 32672,
      builder: (_) => const PayrollUserInterfaceAccessPanel(),
    ),
    StepItem(
      stepCode: 'PDMV-004',
      atomicStepCode: 'PDMV-004-A12',
      title: 'Financial Dashboard Variance Tracker',
      description:
          'Integrate real-time variance tracking on the financial dashboard.',
      category: StepCategory.ui,
      icon: Icons.query_stats_outlined,
      excelRow: 54,
      sequenceOrder: 32751,
      builder: (_) => const FinancialDashboardVarianceTrackerPanel(),
    ),
    StepItem(
      stepCode: 'PDMV-007-09',
      atomicStepCode: 'PDMV-007-09',
      title: 'Reusable Independent Functionality',
      description:
          'Keep functions independent from specific screen layouts for reusability.',
      category: StepCategory.versioning,
      icon: Icons.extension_outlined,
      excelRow: 55,
      sequenceOrder: 32819,
      builder: (_) => const ReusableIndependentFunctionPanel(),
    ),
    StepItem(
      stepCode: 'PDMV-016-09',
      atomicStepCode: 'PDMV-016-09',
      title: 'Referral Savings Metric Dashboard',
      description:
          'Render the "Savings Metric" on the parent dashboard to show accumulated referral rewards.',
      category: StepCategory.ui,
      icon: Icons.savings_outlined,
      excelRow: 56,
      sequenceOrder: 32979,
      builder: (_) => const ReferralSavingsMetricDashboardPanel(),
    ),
    StepItem(
      stepCode: 'PDMV-016-10',
      atomicStepCode: 'PDMV-016-10',
      title: 'Share FAB Touch Target Size',
      description:
          'Size "Share" Floating Action Buttons (FABs) as large, easily tappable touch targets.',
      category: StepCategory.accessibility,
      icon: Icons.touch_app_outlined,
      excelRow: 57,
      sequenceOrder: 32980,
      builder: (_) => const ShareFabTouchTargetSizePanel(),
    ),
    StepItem(
      stepCode: 'PDMV-032',
      atomicStepCode: 'PDMV-032',
      title: 'Tertiary Color Token Outlined Card',
      description:
          'Select tertiary color tokens (md.sys.color.tertiary) and outlined card component layouts.',
      category: StepCategory.tokens,
      icon: Icons.color_lens_outlined,
      excelRow: 58,
      sequenceOrder: 33238,
      builder: (_) => const TertiaryColorTokenOutlinedCardPanel(),
    ),
    StepItem(
      stepCode: 'PDMV-034',
      atomicStepCode: 'PDMV-034',
      title: 'MD3 Linear Progress Bar',
      description:
          'Design the MD3 Linear Progress Bar component to render the percentage on the mobile home screen.',
      category: StepCategory.ui,
      icon: Icons.horizontal_rule_outlined,
      excelRow: 59,
      sequenceOrder: 33274,
      builder: (_) => const Md3LinearProgressBarPanel(),
    ),
    StepItem(
      stepCode: 'PELCE-007-20',
      atomicStepCode: 'PELCE-007-20',
      title: 'Responsive Breathing Room Layout',
      description:
          'Apply highly responsive dimensions, ample breathing room, and clean contrast parameters to the visual layout components.',
      category: StepCategory.layout,
      icon: Icons.aspect_ratio_outlined,
      excelRow: 60,
      sequenceOrder: 33488,
      builder: (_) => const ResponsiveBreathingRoomLayoutPanel(),
    ),
    StepItem(
      stepCode: 'PELCE-010',
      atomicStepCode: 'PELCE-010',
      title: 'M3 Spatial Token Clutter Prevention',
      description:
          'Apply M3 spatial tokens to prevent visual clutter in the mobile code structure.',
      category: StepCategory.tokens,
      icon: Icons.space_bar_outlined,
      excelRow: 61,
      sequenceOrder: 33523,
      builder: (_) => const M3SpatialTokenClutterPreventionPanel(),
    ),
    StepItem(
      stepCode: 'PELCE-011-10',
      atomicStepCode: 'PELCE-011-10',
      title: 'Minimalist Single Purpose Screen',
      description:
          'Design minimalist UI components and single-purpose screens.',
      category: StepCategory.ui,
      icon: Icons.filter_1_outlined,
      excelRow: 62,
      sequenceOrder: 33555,
      builder: (_) => const MinimalistSinglePurposeScreenPanel(),
    ),
    StepItem(
      stepCode: 'PELCE-011-11',
      atomicStepCode: 'PELCE-011-11',
      title: 'Multi Step Wizard Layout',
      description:
          'Break long forms into multi-step wizard layouts with clear progress constraints.',
      category: StepCategory.layout,
      icon: Icons.linear_scale_outlined,
      excelRow: 63,
      sequenceOrder: 33556,
      builder: (_) => const MultiStepWizardLayoutPanel(),
    ),
    StepItem(
      stepCode: 'PELCE-018',
      atomicStepCode: 'PELCE-018-A04',
      title: 'Desktop Hover Trigger Pointer',
      description:
          'Implement hover-trigger logic for desktop pointer interactions.',
      category: StepCategory.interaction,
      icon: Icons.mouse_outlined,
      excelRow: 64,
      sequenceOrder: 33668,
      builder: (_) => const DesktopHoverTriggerPointerPanel(),
    ),
    StepItem(
      stepCode: 'PELCE-018',
      atomicStepCode: 'PELCE-018-A05',
      title: 'Mobile Long Press Trigger',
      description:
          'Implement long-press-trigger logic for mobile touch interactions.',
      category: StepCategory.interaction,
      icon: Icons.touch_app_outlined,
      excelRow: 65,
      sequenceOrder: 33669,
      builder: (_) => const MobileLongPressTriggerPanel(),
    ),
    StepItem(
      stepCode: 'PELCE-018',
      atomicStepCode: 'PELCE-018-A06',
      title: 'Registered Element Tooltip Wiring',
      description:
          'Wire each registered element to its corresponding tooltip content.',
      category: StepCategory.ui,
      icon: Icons.info_outline_rounded,
      excelRow: 66,
      sequenceOrder: 33670,
      builder: (_) => const RegisteredElementTooltipWiringPanel(),
    ),
    StepItem(
      stepCode: 'PELCE-018',
      atomicStepCode: 'PELCE-018-A18',
      title: 'Tooltip Registry Documentation',
      description:
          'Document the registry format for adding new tooltip entries.',
      category: StepCategory.versioning,
      icon: Icons.import_contacts_outlined,
      excelRow: 67,
      sequenceOrder: 33682,
      builder: (_) => const TooltipRegistryDocumentationPanel(),
    ),
    StepItem(
      stepCode: 'PFLE-002-12',
      atomicStepCode: 'PFLE-002-12',
      title: 'Submission Blocked Error Snackbar',
      description:
          'Confirm that the submission is blocked and the error snackbar pops up from the bottom.',
      category: StepCategory.compliance,
      icon: Icons.error_outline_rounded,
      excelRow: 68,
      sequenceOrder: 34134,
      builder: (_) => const SubmissionBlockedErrorSnackbarPanel(),
    ),
    StepItem(
      stepCode: 'PFLE-007',
      atomicStepCode: 'PFLE-007-A01',
      title: 'Mypy Layout Flag Config',
      description:
          'Add explicit Mypy layout flags inside the global codebase configuration files.',
      category: StepCategory.compliance,
      icon: Icons.flaky_outlined,
      excelRow: 69,
      sequenceOrder: 34182,
      builder: (_) => const MypyLayoutFlagConfigPanel(),
    ),
    StepItem(
      stepCode: 'PNSAD-004',
      atomicStepCode: 'PNSAD-004-A02',
      title: 'Non-Blocking Background Process Decision',
      description:
          'Resolve the upfront decision: Identify which background system processes are non-blocking enough to bypass full modal screen requirements.',
      category: StepCategory.ui,
      icon: Icons.sync_outlined,
      excelRow: 70,
      sequenceOrder: 34456,
      builder: (_) => const NonBlockingBackgroundProcessDecisionPanel(),
    ),
    StepItem(
      stepCode: 'PSAMA-002',
      atomicStepCode: 'PSAMA-002-A07',
      title: 'Non-Blocking Navigation Pattern',
      description:
          'Ensure non-blocking UI patterns are used to allow continued mobile app navigation.',
      category: StepCategory.ui,
      icon: Icons.navigation_outlined,
      excelRow: 71,
      sequenceOrder: 35058,
      builder: (_) => const NonBlockingNavigationPatternPanel(),
    ),
    StepItem(
      stepCode: 'PSAMA-014',
      atomicStepCode: 'PSAMA-014',
      title: 'Automated Data-Broadcast Trigger',
      description:
          'Identify the required work for: Configuration of Automated Data-Broadcast Triggers...',
      category: StepCategory.network,
      icon: Icons.podcasts_outlined,
      excelRow: 72,
      sequenceOrder: 35185,
      builder: (_) => const AutomatedDataBroadcastTriggerPanel(),
    ),
    StepItem(
      stepCode: 'RCGLA-001',
      atomicStepCode: 'RCGLA-001-A06',
      title: 'Global Design Token Definition',
      description:
          'Create the global token definition file in the design token format compatible with the framework.',
      category: StepCategory.tokens,
      icon: Icons.style_outlined,
      excelRow: 73,
      sequenceOrder: 35344,
      builder: (_) => const GlobalDesignTokenDefinitionPanel(),
    ),
    StepItem(
      stepCode: 'RCGLA-001',
      atomicStepCode: 'RCGLA-001-A08',
      title: 'Success Color Token (#2ECC71)',
      description:
          'Implement the success color token (#2ECC71) and apply it across all success state indicators.',
      category: StepCategory.tokens,
      icon: Icons.palette_outlined,
      excelRow: 74,
      sequenceOrder: 35346,
      builder: (_) => const SuccessColorTokenIndicatorPanel(),
    ),
    StepItem(
      stepCode: 'RCGLA-004',
      atomicStepCode: 'RCGLA-004-A11',
      title: 'Immersive Modal Sheet Layout',
      description:
          'Configure the layout to promote panels to immersive modal sheets when screen widths slide under threshold steps.',
      category: StepCategory.layout,
      icon: Icons.vertical_align_bottom_outlined,
      excelRow: 75,
      sequenceOrder: 35403,
      builder: (_) => const ImmersiveModalSheetLayoutPanel(),
    ),
    StepItem(
      stepCode: 'RCGLA-004',
      atomicStepCode: 'RCGLA-004-A16',
      title: 'Telemetry Pipeline Transfer',
      description:
          'Run interface tests to confirm proper telemetry and visualization pipeline data transfer.',
      category: StepCategory.network,
      icon: Icons.sync_alt_outlined,
      excelRow: 76,
      sequenceOrder: 35408,
      builder: (_) => const TelemetryPipelineTransferPanel(),
    ),
    StepItem(
      stepCode: 'RCGLA-005',
      atomicStepCode: 'RCGLA-005-A13',
      title: 'Static Code Scanner Deployment Gate',
      description:
          'Configure static code scanners to block deployments if unapproved local variations exist.',
      category: StepCategory.compliance,
      icon: Icons.security_update_warning_outlined,
      excelRow: 77,
      sequenceOrder: 35421,
      builder: (_) => const StaticCodeScannerDeploymentGatePanel(),
    ),
    StepItem(
      stepCode: 'RCGLA-006',
      atomicStepCode: 'RCGLA-006-A02',
      title: 'Compact Viewport Single-Column Ban',
      description:
          'Establish an absolute, strict ban on multi-column grid matrices inside compact layout view classes.',
      category: StepCategory.layout,
      icon: Icons.view_column_outlined,
      excelRow: 78,
      sequenceOrder: 35426,
      builder: (_) => const CompactViewportSingleColumnBanPanel(),
    ),
    StepItem(
      stepCode: 'RCGLA-007',
      atomicStepCode: 'RCGLA-007-A08',
      title: 'Scroll Position Listener Tracking',
      description:
          'Attach real-time scroll position listener tracking hooks directly to the container viewport track.',
      category: StepCategory.interaction,
      icon: Icons.swap_vert_outlined,
      excelRow: 79,
      sequenceOrder: 35445,
      builder: (_) => const ScrollPositionListenerTrackingPanel(),
    ),
    StepItem(
      stepCode: 'RCGLA-009',
      atomicStepCode: 'RCGLA-009-A13',
      title: 'Multi-Device Viewport Test',
      description:
          'Test layout behavior across desktop, tablet, and mobile viewport sizes.',
      category: StepCategory.layout,
      icon: Icons.devices_outlined,
      excelRow: 80,
      sequenceOrder: 35462,
      builder: (_) => const MultiDeviceViewportTestPanel(),
    ),
    StepItem(
      stepCode: 'RCGLA-011',
      atomicStepCode: 'RCGLA-011-A08',
      title: 'Row-Level Data Insulation Barrier',
      description:
          'Apply row-level data insulation barriers to guarantee metrics are cleanly segmented between categories.',
      category: StepCategory.versioning,
      icon: Icons.shield_outlined,
      excelRow: 81,
      sequenceOrder: 35472,
      builder: (_) => const RowLevelDataInsulationBarrierPanel(),
    ),
    StepItem(
      stepCode: 'RCGLA-013',
      atomicStepCode: 'RCGLA-013-A04',
      title: '8dp Baseline Grid Token',
      description:
          'Set 8 dp typographical grid baseline rules across structural layout container elements.',
      category: StepCategory.tokens,
      icon: Icons.grid_4x4_outlined,
      excelRow: 82,
      sequenceOrder: 35501,
      builder: (_) => const EightDpBaselineGridTokenPanel(),
    ),
    StepItem(
      stepCode: 'RCGLA-013',
      atomicStepCode: 'RCGLA-013-A06',
      title: 'Fluid Client Layout Container',
      description:
          'Configure client-side layout containers to expand fluidly across measured screen dimensions.',
      category: StepCategory.layout,
      icon: Icons.aspect_ratio_outlined,
      excelRow: 83,
      sequenceOrder: 35503,
      builder: (_) => const FluidClientLayoutContainerPanel(),
    ),
    StepItem(
      stepCode: 'RCGLA-013',
      atomicStepCode: 'RCGLA-013-A14',
      title: 'BigQuery Layout Rendering Tracker',
      description:
          'Connect frontend layout rendering metrics to BigQuery tracking instances.',
      category: StepCategory.network,
      icon: Icons.analytics_outlined,
      excelRow: 84,
      sequenceOrder: 35511,
      builder: (_) => const BigqueryLayoutRenderingTrackerPanel(),
    ),
    StepItem(
      stepCode: 'RCGLA-014',
      atomicStepCode: 'RCGLA-014-A01',
      title: 'Material Design 3 Token Definition',
      description:
          'Define the Material Design 3 (M3) design tokens for the library.',
      category: StepCategory.tokens,
      icon: Icons.style_outlined,
      excelRow: 85,
      sequenceOrder: 35516,
      builder: (_) => const MaterialDesign3TokenDefinitionPanel(),
    ),
    StepItem(
      stepCode: 'RCGLA-014',
      atomicStepCode: 'RCGLA-014-A07',
      title: 'M3 Standard Widget Compliance',
      description:
          'Test each standard widget renders per M3 guidelines.',
      category: StepCategory.compliance,
      icon: Icons.verified_outlined,
      excelRow: 86,
      sequenceOrder: 35522,
      builder: (_) => const M3StandardWidgetCompliancePanel(),
    ),
    StepItem(
      stepCode: 'RCGLA-014',
      atomicStepCode: 'RCGLA-014-A11',
      title: 'Standardized Component Linter Rules',
      description:
          'Configure linter rules to enforce use of the standardized components.',
      category: StepCategory.compliance,
      icon: Icons.rule_outlined,
      excelRow: 87,
      sequenceOrder: 35526,
      builder: (_) => const StandardizedComponentLinterRulePanel(),
    ),
    StepItem(
      stepCode: 'RCGLA-014',
      atomicStepCode: 'RCGLA-014-A15',
      title: 'M3 Codebase Consistency Enforcer',
      description:
          'Confirm the library enforces M3 guidelines consistently across the codebase.',
      category: StepCategory.compliance,
      icon: Icons.gavel_outlined,
      excelRow: 88,
      sequenceOrder: 35530,
      builder: (_) => const M3CodebaseConsistencyEnforcerPanel(),
    ),
    StepItem(
      stepCode: 'RCGLA-014',
      atomicStepCode: 'RCGLA-014-A16',
      title: 'Component Library & Linter Docs',
      description:
          'Document the finalized component library and linting configuration.',
      category: StepCategory.versioning,
      icon: Icons.auto_stories_outlined,
      excelRow: 89,
      sequenceOrder: 35531,
      builder: (_) => const ComponentLibraryLinterDocsPanel(),
    ),
    StepItem(
      stepCode: 'RCGLA-016',
      atomicStepCode: 'RCGLA-016-A05',
      title: 'Responsive Spacing Multiplier Tokens',
      description:
          'Define responsive spacing multipliers for each breakpoint tier.',
      category: StepCategory.tokens,
      icon: Icons.space_bar_outlined,
      excelRow: 90,
      sequenceOrder: 35536,
      builder: (_) => const ResponsiveSpacingMultiplierTokenPanel(),
    ),
    StepItem(
      stepCode: 'RCGLA-018',
      atomicStepCode: 'RCGLA-018-A11',
      title: 'Nested Layout Composition Test',
      description:
          'Test nested layout composition (layout within layout) for conflicts.',
      category: StepCategory.layout,
      icon: Icons.layers_outlined,
      excelRow: 91,
      sequenceOrder: 35582,
      builder: (_) => const NestedLayoutCompositionTestPanel(),
    ),
    StepItem(
      stepCode: 'RCGLA-019',
      atomicStepCode: 'RCGLA-019-A10',
      title: 'Visual Parity Spec Verifier',
      description:
          'Verify visual parity against existing design specs after each replacement.',
      category: StepCategory.ui,
      icon: Icons.compare_outlined,
      excelRow: 92,
      sequenceOrder: 35601,
      builder: (_) => const VisualParitySpecVerifierPanel(),
    ),
    StepItem(
      stepCode: 'RCGLA-020',
      atomicStepCode: 'RCGLA-020-A06',
      title: 'Device Posture Orientation Listener',
      description:
          'Set orientation listeners to adjust flex-direction parameters automatically based on device posture.',
      category: StepCategory.layout,
      icon: Icons.screen_rotation_outlined,
      excelRow: 93,
      sequenceOrder: 35617,
      builder: (_) => const DevicePostureOrientationListenerPanel(),
    ),
    StepItem(
      stepCode: 'RCGLA-021',
      atomicStepCode: 'RCGLA-021-A02',
      title: 'Core Grid Engine Breakpoints',
      description:
          'Build the core grid engine supporting configurable column counts per breakpoint.',
      category: StepCategory.layout,
      icon: Icons.grid_on_outlined,
      excelRow: 94,
      sequenceOrder: 35625,
      builder: (_) => const CoreGridEngineBreakpointPanel(),
    ),
    StepItem(
      stepCode: 'RCGLA-026',
      atomicStepCode: 'RCGLA-026-A03',
      title: 'Togglable Side Pane Layout',
      description:
          'Implement a togglable supporting side pane layout window class for secondary content.',
      category: StepCategory.layout,
      icon: Icons.view_sidebar_outlined,
      excelRow: 95,
      sequenceOrder: 35685,
      builder: (_) => const TogglableSidePaneLayoutPanel(),
    ),
    StepItem(
      stepCode: 'RCGLA-026',
      atomicStepCode: 'RCGLA-026-A08',
      title: 'Side Panel Slide Toggle Mechanic',
      description:
          'Build interactive toggle mechanics allowing users to slide supporting panels away as needed.',
      category: StepCategory.interaction,
      icon: Icons.swipe_outlined,
      excelRow: 96,
      sequenceOrder: 35690,
      builder: (_) => const SidePanelSlideToggleMechanicPanel(),
    ),
    StepItem(
      stepCode: 'RCGLA-028',
      atomicStepCode: 'RCGLA-028-A11',
      title: 'Collapsible Transaction Data Table',
      description:
          'Ensure wide multi-column transactional data tables collapse vertically without text truncation errors.',
      category: StepCategory.ui,
      icon: Icons.table_chart_outlined,
      excelRow: 97,
      sequenceOrder: 35706,
      builder: (_) => const CollapsibleTransactionTablePanel(),
    ),
    StepItem(
      stepCode: 'RCGLA-028',
      atomicStepCode: 'RCGLA-028-A13',
      title: 'Layout Jitter Visual Scanner Gate',
      description:
          'Set automated visual scanners to fail build deployment actions if elements trigger layout jitter on narrow profiles.',
      category: StepCategory.compliance,
      icon: Icons.motion_photos_off_outlined,
      excelRow: 98,
      sequenceOrder: 35708,
      builder: (_) => const LayoutJitterVisualScannerGatePanel(),
    ),
    StepItem(
      stepCode: 'RCGLA-031',
      atomicStepCode: 'RCGLA-031-A01',
      title: 'Molecular Component Inventory',
      description:
          'Review the molecular components available for organism-level composition.',
      category: StepCategory.versioning,
      icon: Icons.inventory_2_outlined,
      excelRow: 99,
      sequenceOrder: 35747,
      builder: (_) => const MolecularComponentInventoryPanel(),
    ),
    StepItem(
      stepCode: 'RCGLA-031',
      atomicStepCode: 'RCGLA-031-A07',
      title: 'Organism State Management Coordinator',
      description:
          'Wire organism-level state management coordinating child molecular components.',
      category: StepCategory.interaction,
      icon: Icons.account_tree_outlined,
      excelRow: 100,
      sequenceOrder: 35751,
      builder: (_) => const OrganismStateManagementCoordinatorPanel(),
    ),
    StepItem(
      stepCode: 'RCGLA-031',
      atomicStepCode: 'RCGLA-031-A09',
      title: 'Organism Responsive Breakpoint',
      description:
          'Implement responsive behavior for each organism across breakpoints.',
      category: StepCategory.layout,
      icon: Icons.developer_board_outlined,
      excelRow: 101,
      sequenceOrder: 35753,
      builder: (_) => const OrganismResponsiveBreakpointPanel(),
    ),
    StepItem(
      stepCode: 'RCGLA-031',
      atomicStepCode: 'RCGLA-031-A15',
      title: 'Organism Flow Integration Test',
      description:
          'Add integration tests for full organism interaction flows.',
      category: StepCategory.compliance,
      icon: Icons.quiz_outlined,
      excelRow: 102,
      sequenceOrder: 35759,
      builder: (_) => const OrganismFlowIntegrationTestPanel(),
    ),
    StepItem(
      stepCode: 'RCGLA-032',
      atomicStepCode: 'RCGLA-032-A20',
      title: 'Zero Overflow 320px Viewport',
      description:
          'Confirm zero instances of horizontal scrollbars or overflowing tokens down to 320px width.',
      category: StepCategory.accessibility,
      icon: Icons.phonelink_setup_outlined,
      excelRow: 103,
      sequenceOrder: 35781,
      builder: (_) => const ZeroOverflow320pxViewportPanel(),
    ),
    StepItem(
      stepCode: 'RCGLA-033',
      atomicStepCode: 'RCGLA-033-A09',
      title: 'Wide Window Side Sheet',
      description:
          'Configure component visibility models to present standard side-sheets on wide windows.',
      category: StepCategory.layout,
      icon: Icons.picture_in_picture_outlined,
      excelRow: 104,
      sequenceOrder: 35790,
      builder: (_) => const WideWindowSideSheetPanel(),
    ),
    StepItem(
      stepCode: 'RCGLA-034',
      atomicStepCode: 'RCGLA-034-A02',
      title: 'Design System Workspace Config',
      description:
          'Open the main design system configuration files in the frontend application workspace.',
      category: StepCategory.versioning,
      icon: Icons.folder_open_outlined,
      excelRow: 105,
      sequenceOrder: 35802,
      builder: (_) => const DesignSystemWorkspaceConfigPanel(),
    ),
    StepItem(
      stepCode: 'RCGLA-034',
      atomicStepCode: 'RCGLA-034-A16',
      title: 'Alignment Variables Token Repository',
      description:
          'Save the global alignment variables and container assets to the design token repository.',
      category: StepCategory.tokens,
      icon: Icons.format_align_center_outlined,
      excelRow: 106,
      sequenceOrder: 35816,
      builder: (_) => const AlignmentVariablesTokenRepositoryPanel(),
    ),
    StepItem(
      stepCode: 'RCGLA-034',
      atomicStepCode: 'RCGLA-034-A17',
      title: 'Staging Server Layout Deployment',
      description:
          'Push the updated layout definitions onto the staging test server environment.',
      category: StepCategory.compliance,
      icon: Icons.cloud_upload_outlined,
      excelRow: 107,
      sequenceOrder: 35817,
      builder: (_) => const StagingServerLayoutDeploymentPanel(),
    ),
    StepItem(
      stepCode: 'RCGLA-036',
      atomicStepCode: 'RCGLA-036-A08',
      title: 'Raw Audit Log Layout Locator',
      description:
          'Locate the component file managing the raw audit logs frontend view layout.',
      category: StepCategory.ui,
      icon: Icons.find_in_page_outlined,
      excelRow: 108,
      sequenceOrder: 35826,
      builder: (_) => const RawAuditLogLayoutLocatorPanel(),
    ),
    StepItem(
      stepCode: 'RCGLA-041',
      atomicStepCode: 'RCGLA-041-A06',
      title: 'Input Validation Pattern Embed',
      description:
          'Embed input validation patterns (HC-PAD-0001) directly onto the right data entry form panel.',
      category: StepCategory.compliance,
      icon: Icons.rule_folder_outlined,
      excelRow: 109,
      sequenceOrder: 35857,
      builder: (_) => const InputValidationPatternEmbedPanel(),
    ),
    StepItem(
      stepCode: 'RCGLA-041',
      atomicStepCode: 'RCGLA-041-A07',
      title: 'Focused Data Display Isolation',
      description:
          'Restrict data display properties to isolate processing focus points and eliminate extra context.',
      category: StepCategory.ui,
      icon: Icons.filter_center_focus_outlined,
      excelRow: 110,
      sequenceOrder: 35858,
      builder: (_) => const FocusedDataDisplayIsolationPanel(),
    ),
    StepItem(
      stepCode: 'RCGLA-041',
      atomicStepCode: 'RCGLA-041-A11',
      title: 'Signed URL Image Payload Security',
      description:
          'Secure target source image payloads using signed URLs.',
      category: StepCategory.network,
      icon: Icons.enhanced_encryption_outlined,
      excelRow: 111,
      sequenceOrder: 35862,
      builder: (_) => const SignedUrlImagePayloadSecurityPanel(),
    ),
    StepItem(
      stepCode: 'RCGLA-041',
      atomicStepCode: 'RCGLA-041-A12',
      title: 'Core Private Package Style Inheritance',
      description:
          'Ensure component frameworks inherit styles exclusively from the core private package bundle.',
      category: StepCategory.tokens,
      icon: Icons.account_tree_outlined,
      excelRow: 112,
      sequenceOrder: 35863,
      builder: (_) => const CorePrivatePackageStyleInheritancePanel(),
    ),
    StepItem(
      stepCode: 'RCGLA-043',
      atomicStepCode: 'RCGLA-043-A08',
      title: '8dp Horizontal Cell Padding',
      description:
          'Set the horizontal internal cell padding values strictly to exactly 8dp for left and right spacing.',
      category: StepCategory.tokens,
      icon: Icons.space_bar_outlined,
      excelRow: 113,
      sequenceOrder: 35873,
      builder: (_) => const EightDpHorizontalCellPaddingPanel(),
    ),
    StepItem(
      stepCode: 'REF-001',
      atomicStepCode: 'REF-001-A10',
      title: 'Submit Interceptor State Handler',
      description:
          'Update the SubmitInterceptor to set isProcessing to true upon request initiation.',
      category: StepCategory.network,
      icon: Icons.sync_lock_outlined,
      excelRow: 114,
      sequenceOrder: 36219,
      builder: (_) => const SubmitInterceptorStateHandlerPanel(),
    ),
    StepItem(
      stepCode: 'REF-016',
      atomicStepCode: 'REF-016-A01',
      title: 'Input Text Masking Field Auditor',
      description:
          'Identify all data entry input fields requiring text masking across the application.',
      category: StepCategory.compliance,
      icon: Icons.password_outlined,
      excelRow: 115,
      sequenceOrder: 36223,
      builder: (_) => const InputTextMaskingFieldAuditorPanel(),
    ),
    StepItem(
      stepCode: 'REF-031',
      atomicStepCode: 'REF-031-A12',
      title: 'Re-Authentication Identity Provider',
      description:
          'Integrate the re-authentication form with the identity provider API.',
      category: StepCategory.network,
      icon: Icons.badge_outlined,
      excelRow: 116,
      sequenceOrder: 36249,
      builder: (_) => const ReAuthenticationIdentityProviderPanel(),
    ),
    StepItem(
      stepCode: 'REF-046',
      atomicStepCode: 'REF-046-A09',
      title: 'Manual Dismiss Overlay Card',
      description:
          'Include a manual dismiss button (e.g., an \'X\' icon) on each overlay card.',
      category: StepCategory.ui,
      icon: Icons.cancel_outlined,
      excelRow: 117,
      sequenceOrder: 36261,
      builder: (_) => const ManualDismissOverlayCardPanel(),
    ),
    StepItem(
      stepCode: 'REF-061',
      atomicStepCode: 'REF-061-A08',
      title: 'Online Dependent Feature Catalog',
      description:
          'Identify all online-dependent features and components in the application.',
      category: StepCategory.compliance,
      icon: Icons.wifi_find_outlined,
      excelRow: 118,
      sequenceOrder: 36275,
      builder: (_) => const OnlineDependentFeatureCatalogPanel(),
    ),
    StepItem(
      stepCode: 'REF-121',
      atomicStepCode: 'REF-121-A07',
      title: 'JWT Token Header Extractor',
      description:
          'Extract the JWT token from the request headers or cookies.',
      category: StepCategory.network,
      icon: Icons.key_outlined,
      excelRow: 119,
      sequenceOrder: 36304,
      builder: (_) => const JwtTokenHeaderExtractorPanel(),
    ),
    StepItem(
      stepCode: 'REF-167',
      atomicStepCode: 'REF-167-A02',
      title: 'Form Validation Pattern Finalizer',
      description:
          'Finalize data validation patterns and error string treatments for all forms.',
      category: StepCategory.compliance,
      icon: Icons.rule_outlined,
      excelRow: 120,
      sequenceOrder: 36314,
      builder: (_) => const FormValidationPatternFinalizerPanel(),
    ),
    StepItem(
      stepCode: 'REF-197',
      atomicStepCode: 'REF-197-A14',
      title: 'API Failure Rollback Simulator',
      description:
          'Simulate API failures to test the end-to-end rollback and notification flow.',
      category: StepCategory.compliance,
      icon: Icons.sync_problem_outlined,
      excelRow: 121,
      sequenceOrder: 36356,
      builder: (_) => const ApiFailureRollbackSimulatorPanel(),
    ),
    StepItem(
      stepCode: 'REF-197',
      atomicStepCode: 'REF-197-A15',
      title: 'Production Rollback Handler Deployment',
      description:
          'Deploy the rollback handler to production.',
      category: StepCategory.compliance,
      icon: Icons.rocket_launch_outlined,
      excelRow: 122,
      sequenceOrder: 36357,
      builder: (_) => const ProductionRollbackHandlerDeploymentPanel(),
    ),
    StepItem(
      stepCode: 'REF-212',
      atomicStepCode: 'REF-212-A04',
      title: 'Grid Container Flex Layout',
      description:
          'Create the base .grid-container CSS class utilizing CSS Grid or Flexbox.',
      category: StepCategory.layout,
      icon: Icons.grid_on_outlined,
      excelRow: 123,
      sequenceOrder: 36361,
      builder: (_) => const GridContainerFlexLayoutPanel(),
    ),
    StepItem(
      stepCode: 'REF-212',
      atomicStepCode: 'REF-212-A15',
      title: 'Grid Setup Style Repository',
      description:
          'Merge the grid setup into the main styling repository.',
      category: StepCategory.tokens,
      icon: Icons.merge_type_outlined,
      excelRow: 124,
      sequenceOrder: 36372,
      builder: (_) => const GridSetupStyleRepositoryPanel(),
    ),
    StepItem(
      stepCode: 'REF-227',
      atomicStepCode: 'REF-227-A05',
      title: 'Real-Time Keystroke Interceptor',
      description:
          'Intercept real-time keystrokes on the target fields.',
      category: StepCategory.interaction,
      icon: Icons.keyboard_outlined,
      excelRow: 125,
      sequenceOrder: 36377,
      builder: (_) => const RealTimeKeystrokeInterceptorPanel(),
    ),
    StepItem(
      stepCode: 'REF-242',
      atomicStepCode: 'REF-242-A07',
      title: 'Cursor Auto-Advance Formatter',
      description:
          'Auto-advance the cursor past static formatting characters during user typing.',
      category: StepCategory.interaction,
      icon: Icons.start_outlined,
      excelRow: 126,
      sequenceOrder: 36394,
      builder: (_) => const CursorAutoAdvanceFormatterPanel(),
    ),
    StepItem(
      stepCode: 'REF-242',
      atomicStepCode: 'REF-242-A08',
      title: 'Backspace Formatting Jump Handler',
      description:
          'Handle backspace events to correctly remove characters and jump back over static formatting.',
      category: StepCategory.interaction,
      icon: Icons.backspace_outlined,
      excelRow: 127,
      sequenceOrder: 36395,
      builder: (_) => const BackspaceFormattingJumpHandlerPanel(),
    ),
    StepItem(
      stepCode: 'REF-242',
      atomicStepCode: 'REF-242-A09',
      title: 'OnBlur Input Length Validator',
      description:
          'Validate the final input length against the physical constraint upon onBlur.',
      category: StepCategory.compliance,
      icon: Icons.fact_check_outlined,
      excelRow: 128,
      sequenceOrder: 36396,
      builder: (_) => const OnBlurInputLengthValidatorPanel(),
    ),
    StepItem(
      stepCode: 'REF-242',
      atomicStepCode: 'REF-242-A15',
      title: 'Strict Input Mask Deployment',
      description:
          'Deploy the strict input mask to the target field.',
      category: StepCategory.compliance,
      icon: Icons.pin_outlined,
      excelRow: 129,
      sequenceOrder: 36402,
      builder: (_) => const StrictInputMaskDeploymentPanel(),
    ),
    StepItem(
      stepCode: 'REF-272',
      atomicStepCode: 'REF-272-A07',
      title: 'Global Button Component Swapper',
      description:
          'Execute a global find-and-replace to swap custom HTML <button> tags with the library <Button> component.',
      category: StepCategory.versioning,
      icon: Icons.find_replace_outlined,
      excelRow: 130,
      sequenceOrder: 36409,
      builder: (_) => const GlobalButtonComponentSwapperPanel(),
    ),
    StepItem(
      stepCode: 'REF-272',
      atomicStepCode: 'REF-272-A12',
      title: 'Unauthorized UI Linter Verifier',
      description:
          'Run the linter to confirm no unauthorized custom UI elements remain in the codebase.',
      category: StepCategory.compliance,
      icon: Icons.policy_outlined,
      excelRow: 131,
      sequenceOrder: 36414,
      builder: (_) => const UnauthorizedUiLinterVerifierPanel(),
    ),
    StepItem(
      stepCode: 'REF-272',
      atomicStepCode: 'REF-272-A13',
      title: 'UI Regression Test Suite Runner',
      description:
          'Execute the full suite of UI regression tests.',
      category: StepCategory.compliance,
      icon: Icons.playlist_add_check_circle_outlined,
      excelRow: 132,
      sequenceOrder: 36415,
      builder: (_) => const UiRegressionTestSuiteRunnerPanel(),
    ),
    StepItem(
      stepCode: 'REF-287',
      atomicStepCode: 'REF-287-A09',
      title: 'Auth Timeout Fallback Node',
      description:
          'If authorization fails or times out, immediately render the Fallback UI Node instead of the child view.',
      category: StepCategory.ui,
      icon: Icons.no_accounts_outlined,
      excelRow: 133,
      sequenceOrder: 36426,
      builder: (_) => const AuthTimeoutFallbackNodePanel(),
    ),
    StepItem(
      stepCode: 'REF-332',
      atomicStepCode: 'REF-332-A11',
      title: 'API Interceptor Lockout Auditor',
      description:
          'Verify that API interceptors are not inadvertently bypassing the UI lockout.',
      category: StepCategory.compliance,
      icon: Icons.phonelink_lock_outlined,
      excelRow: 134,
      sequenceOrder: 36458,
      builder: (_) => const ApiInterceptorLockoutAuditorPanel(),
    ),
    StepItem(
      stepCode: 'REF-347',
      atomicStepCode: 'REF-347-A15',
      title: 'Keystroke Interceptor Deployment',
      description:
          'Deploy the keystroke-level interceptor scripts.',
      category: StepCategory.network,
      icon: Icons.keyboard_command_key_outlined,
      excelRow: 135,
      sequenceOrder: 36477,
      builder: (_) => const KeystrokeInterceptorDeploymentPanel(),
    ),
    StepItem(
      stepCode: 'REF-362',
      atomicStepCode: 'REF-362-A04',
      title: 'Mobile Input Masking Hook',
      description:
          'Implement a directive or hook to apply the masking profiles to mobile input fields.',
      category: StepCategory.interaction,
      icon: Icons.password_outlined,
      excelRow: 136,
      sequenceOrder: 36481,
      builder: (_) => const MobileInputMaskingHookPanel(),
    ),
    StepItem(
      stepCode: 'REF-362',
      atomicStepCode: 'REF-362-A11',
      title: 'Dual-Value Form Controller Exposure',
      description:
          'Expose both the masked (display) value and unmasked (raw) value to the form controller.',
      category: StepCategory.interaction,
      icon: Icons.raw_on_outlined,
      excelRow: 137,
      sequenceOrder: 36488,
      builder: (_) => const DualValueFormControllerExposurePanel(),
    ),
    StepItem(
      stepCode: 'REF-392',
      atomicStepCode: 'REF-392-A06',
      title: 'Skeleton Card Volume Wrapper',
      description:
          'Configure the wrapper to display a grid or list of multiple skeleton cards to mimic the expected data volume.',
      category: StepCategory.ui,
      icon: Icons.dashboard_customize_outlined,
      excelRow: 138,
      sequenceOrder: 36513,
      builder: (_) => const SkeletonCardVolumeWrapperPanel(),
    ),
    StepItem(
      stepCode: 'REF-407',
      atomicStepCode: 'REF-407-A08',
      title: 'Shimmer Gradient Contrast Token',
      description:
          'Standardize the shimmer gradient colors to ensure adequate contrast with the background.',
      category: StepCategory.tokens,
      icon: Icons.gradient_outlined,
      excelRow: 139,
      sequenceOrder: 36530,
      builder: (_) => const ShimmerGradientContrastTokenPanel(),
    ),
    StepItem(
      stepCode: 'REF-407',
      atomicStepCode: 'REF-407-A13',
      title: 'Shimmer Speed Design System Docs',
      description:
          'Document the established shimmer speed in the design system guidelines.',
      category: StepCategory.versioning,
      icon: Icons.speed_outlined,
      excelRow: 140,
      sequenceOrder: 36535,
      builder: (_) => const ShimmerSpeedDesignSystemDocsPanel(),
    ),
    StepItem(
      stepCode: 'REF-467',
      atomicStepCode: 'REF-467-A03',
      title: 'Absolute Root Layout Container',
      description:
          'Apply position: absolute; (or fixed, depending on architecture) to the root layout container.',
      category: StepCategory.layout,
      icon: Icons.fullscreen_outlined,
      excelRow: 141,
      sequenceOrder: 36555,
      builder: (_) => const AbsoluteRootLayoutContainerPanel(),
    ),
    StepItem(
      stepCode: 'RIMV-002',
      atomicStepCode: 'RIMV-002-A07',
      title: 'MaskedInput Component Wrapper',
      description:
          'Implement a MaskedInput component wrapping the base input with mask application.',
      category: StepCategory.ui,
      icon: Icons.pin_end_outlined,
      excelRow: 142,
      sequenceOrder: 36573,
      builder: (_) => const MaskedInputComponentWrapperPanel(),
    ),
    StepItem(
      stepCode: 'RIMV-003',
      atomicStepCode: 'RIMV-003-A02',
      title: 'Byt Data Type Regex Pattern',
      description:
          'Define the regex pattern for each Byt data type.',
      category: StepCategory.tokens,
      icon: Icons.pattern_outlined,
      excelRow: 143,
      sequenceOrder: 36585,
      builder: (_) => const BytDataTypeRegexPatternPanel(),
    ),
    StepItem(
      stepCode: 'RIMV-003',
      atomicStepCode: 'RIMV-003-A17',
      title: 'Byt Type Regex Keyboard Test',
      description:
          'Write unit tests for getRegexMask and getKeyboardType covering all registered Byt types.',
      category: StepCategory.compliance,
      icon: Icons.checklist_outlined,
      excelRow: 144,
      sequenceOrder: 36600,
      builder: (_) => const BytTypeRegexKeyboardTestPanel(),
    ),
    StepItem(
      stepCode: 'RIMV-007',
      atomicStepCode: 'RIMV-007-A03',
      title: 'Banking Identity Regex Rule',
      description:
          'Define strict, unyielding Regex boundary rules tailored for banking and corporate identity data rows.',
      category: StepCategory.compliance,
      icon: Icons.account_balance_outlined,
      excelRow: 145,
      sequenceOrder: 36619,
      builder: (_) => const BankingIdentityRegexRulePanel(),
    ),
    StepItem(
      stepCode: 'RIMV-009',
      atomicStepCode: 'RIMV-009-A10',
      title: 'Semantic Outline Alert Frame',
      description:
          'Connect immediate semantic outline alerts to trigger visually around the target field component frame upon character rejection.',
      category: StepCategory.ui,
      icon: Icons.error_outline_rounded,
      excelRow: 146,
      sequenceOrder: 36660,
      builder: (_) => const SemanticOutlineAlertFramePanel(),
    ),
    StepItem(
      stepCode: 'RIMV-018',
      atomicStepCode: 'RIMV-018-A08',
      title: 'Data Transmission Disabled Style',
      description:
          'Apply distinct visual styling to disabled elements during data transmission.',
      category: StepCategory.tokens,
      icon: Icons.color_lens_outlined,
      excelRow: 147,
      sequenceOrder: 36706,
      builder: (_) => const DataTransmissionDisabledStylePanel(),
    ),
    StepItem(
      stepCode: 'RIMV-018',
      atomicStepCode: 'RIMV-018-A09',
      title: 'Load State Interaction Blocker',
      description:
          'Prevent any user interaction from bypassing the disabled state during load.',
      category: StepCategory.interaction,
      icon: Icons.do_not_touch_outlined,
      excelRow: 148,
      sequenceOrder: 36707,
      builder: (_) => const LoadStateInteractionBlockerPanel(),
    ),
    StepItem(
      stepCode: 'RIMV-018',
      atomicStepCode: 'RIMV-018-A10',
      title: 'Concurrent Loading Flag Coordinator',
      description:
          'Handle overlapping/concurrent loading flags without premature re-enabling.',
      category: StepCategory.compliance,
      icon: Icons.swap_calls_outlined,
      excelRow: 149,
      sequenceOrder: 36708,
      builder: (_) => const ConcurrentLoadingFlagCoordinatorPanel(),
    ),
    StepItem(
      stepCode: 'RIMV-018',
      atomicStepCode: 'RIMV-018-A20',
      title: 'Staging Disabling Framework Verifier',
      description:
          'Merge and validate the disabling framework in the staging environment.',
      category: StepCategory.compliance,
      icon: Icons.cloud_done_outlined,
      excelRow: 150,
      sequenceOrder: 36717,
      builder: (_) => const StagingDisablingFrameworkVerifierPanel(),
    ),
    StepItem(
      stepCode: 'RIMV-031',
      atomicStepCode: 'RIMV-031-A12',
      title: 'Text Region Error Track',
      description:
          'Execute error presentation tracks below active text regions if formatting errors occur.',
      category: StepCategory.ui,
      icon: Icons.error_outline,
      excelRow: 151,
      sequenceOrder: 36749,
      builder: (_) => const TextRegionErrorTrackPanel(),
    ),
    StepItem(
      stepCode: 'RRCVG-006',
      atomicStepCode: 'RRCVG-006-A05',
      title: 'Non-Zero Difference Button Disabler',
      description:
          'Apply the disabled prop to the MUI Button if the difference is non-zero.',
      category: StepCategory.interaction,
      icon: Icons.exposure_zero_outlined,
      excelRow: 152,
      sequenceOrder: 36865,
      builder: (_) => const NonZeroDifferenceButtonDisablerPanel(),
    ),
    StepItem(
      stepCode: 'RRCVG-013',
      atomicStepCode: 'RRCVG-013-A08',
      title: 'Design Library Attribute Pull',
      description:
          'Pull component attributes strictly from verified design libraries.',
      category: StepCategory.versioning,
      icon: Icons.collections_bookmark_outlined,
      excelRow: 153,
      sequenceOrder: 36979,
      builder: (_) => const DesignLibraryAttributePullPanel(),
    ),
    StepItem(
      stepCode: 'RRCVG-014',
      atomicStepCode: 'RRCVG-014-A06',
      title: 'Cross-Functional Sign-Off Gate',
      description:
          'Obtain formal sign-offs from security, data engineering, and product operations.',
      category: StepCategory.compliance,
      icon: Icons.assignment_turned_in_outlined,
      excelRow: 154,
      sequenceOrder: 37014,
      builder: (_) => const CrossFunctionalSignOffGatePanel(),
    ),
    StepItem(
      stepCode: 'RRCVG-016-08',
      atomicStepCode: 'RRCVG-016-08',
      title: 'Body Small Typescale Token',
      description:
          'Adhere fine text items strictly to system layout constraints (md.sys.typescale.body-small).',
      category: StepCategory.tokens,
      icon: Icons.text_fields_outlined,
      excelRow: 155,
      sequenceOrder: 37054,
      builder: (_) => const BodySmallTypescaleTokenPanel(),
    ),
    StepItem(
      stepCode: 'RRCVG-018-12',
      atomicStepCode: 'RRCVG-018-12',
      title: 'Feature Toggle UI Wrapper',
      description:
          'Extract the hardcoded UI elements and strictly wrap them inside feature toggle conditional logic.',
      category: StepCategory.versioning,
      icon: Icons.toggle_on_outlined,
      excelRow: 156,
      sequenceOrder: 37090,
      builder: (_) => const FeatureToggleUiWrapperPanel(),
    ),
    StepItem(
      stepCode: 'RRCVG-018-15',
      atomicStepCode: 'RRCVG-018-15',
      title: 'Global Unmount Latency Verifier',
      description:
          'Confirm the targeted UI element unmounts globally on clients in under 5 seconds.',
      category: StepCategory.compliance,
      icon: Icons.timer_outlined,
      excelRow: 157,
      sequenceOrder: 37091,
      builder: (_) => const GlobalUnmountLatencyVerifierPanel(),
    ),
    StepItem(
      stepCode: 'RRCVG-020',
      atomicStepCode: 'RRCVG-020-A04',
      title: 'Clean Text Wrap Layout',
      description:
          'Implement clean layout wrap logic for longer numeric or textual data strings.',
      category: StepCategory.layout,
      icon: Icons.wrap_text_outlined,
      excelRow: 158,
      sequenceOrder: 37093,
      builder: (_) => const CleanTextWrapLayoutPanel(),
    ),
    StepItem(
      stepCode: 'RRCVG-023',
      atomicStepCode: 'RRCVG-023-A01',
      title: 'Cross-Team Workflow Requirements',
      description:
          'Gather cross-functional user workflow requirements from the Tech, OPS, and HRE teams.',
      category: StepCategory.compliance,
      icon: Icons.groups_outlined,
      excelRow: 159,
      sequenceOrder: 37114,
      builder: (_) => const CrossTeamWorkflowRequirementsPanel(),
    ),
    StepItem(
      stepCode: 'RRCVG-024',
      atomicStepCode: 'RRCVG-024-A01',
      title: 'Offboarding Manual Analyzer',
      description:
          'Analyze complex multi-system offboarding manuals provided by Tech, OPS, and HRE teams.',
      category: StepCategory.compliance,
      icon: Icons.menu_book_outlined,
      excelRow: 160,
      sequenceOrder: 37132,
      builder: (_) => const OffboardingManualAnalyzerPanel(),
    ),
    StepItem(
      stepCode: 'RRCVG-024',
      atomicStepCode: 'RRCVG-024-A07',
      title: 'Binary Checklist Gate Row',
      description:
          'Bind each isolated offboarding task directly to an individual binary checklist gate row.',
      category: StepCategory.ui,
      icon: Icons.fact_check_outlined,
      excelRow: 161,
      sequenceOrder: 37138,
      builder: (_) => const BinaryChecklistGateRowPanel(),
    ),
    StepItem(
      stepCode: 'RRCVG-024',
      atomicStepCode: 'RRCVG-024-A08',
      title: 'Sequential Execution State Orchestrator',
      description:
          'Code strict state orchestration scripts forcing sequential execution of list items.',
      category: StepCategory.interaction,
      icon: Icons.alt_route_outlined,
      excelRow: 162,
      sequenceOrder: 37139,
      builder: (_) => const SequentialExecutionStateOrchestratorPanel(),
    ),
  ];
}
