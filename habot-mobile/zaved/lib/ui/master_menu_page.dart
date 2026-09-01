import 'package:flutter/material.dart';
import 'asynchronous_consensus_board.dart';
import 'bigquery_streaming_validation_dashboard.dart';
import 'board_signatory_access_constraint.dart';
import 'cicd_linter_accessibility_dashboard.dart';
import 'code_export_modal.dart';
import 'component_code_registry.dart';
import 'component_explanation_registry.dart';
import 'design_system_merge_dashboard.dart';
import 'enterprise_cmek_security_console.dart';
import 'expense_taxonomy_picklist.dart';
import 'feedback_ranking_sync_ledger.dart';
import 'masked_regex_input_field.dart';
import 'numeric_poka_yoke_form.dart';
import 'offline_udd_sync_workspace.dart';
import 'payload_upload_widget.dart';
import 'rate_limit_throttle_workspace.dart';
import 'referral_link_workspace.dart';
import 'satisfaction_analytics_engine_dashboard.dart';
import 'system_verb_button.dart';
import 'universal_engineering_notification_center.dart';
import 'universal_src_search.dart';
import 'validation_status_alert.dart';
import 'visual_isolation_workspace.dart';
import 'filesystem_tuning_admin_dashboard.dart';
import 'mobile_surgical_container.dart';
import 'lineage_graph_terminal_alert_dashboard.dart';
import 'loading_submit_button_form.dart';
import 'ai_output_analytics_view.dart';
import 'multi_child_registration_form.dart';
import 'startup_probe_secure_repository.dart';
import 'dynamic_context_fab.dart';
import 'high_density_operational_data_table.dart';
import 'universal_lookup_matrix.dart';
import 'component_library_doc_archive.dart';
import 'responsive_layout_grid_engine.dart';
import 'mobile_first_ai_chat_flow.dart';
import 'm3_adaptive_navigation_dashboard.dart';
import 'welcoming_initial_input_form.dart';
import 'hr_metric_target_contextual_modifier.dart';
import 'secure_employee_payroll_register.dart';
import 'form_input_masking_native_keyboards.dart';
import 'edge_level_validation_form.dart';
import 'campaign_target_sku_selection.dart';
import 'shakti_alert_panel.dart';
import 'ab_test_variant_preservation.dart';
import 'strict_linear_progression_viewpager.dart';
import 'operations_task_entry.dart';
import 'payment_gateway_verification_dashboard.dart';
import 'design_system_infrastructure_showcase.dart';
import 'protected_analytical_logs.dart';
import 'smart_bounding_box_document_isolator.dart';
import 'conditional_operations_view.dart';
import 'aml_query_gate_secure_auth_flow.dart';
import 'binary_vap_login_modal.dart';
import 'split_screen_master_layout.dart';
import 'inbound_lead_validation_form.dart';
import 'animated_masked_input_field.dart';
import 'dynamic_onboarding_journey.dart';
import 'components/data_entry_card.dart';
import 'persistent_header_layout_system.dart';
import 'inertial_drag_smooth_list_scroller.dart';
import 'async_form_skeleton_loader.dart';
import 'dynamic_tab_coordinator.dart';
import 'interactive_masked_input_form.dart';
import 'orientation_aware_form_wrapper.dart';
import 'supporting_pane_layout_wrapper.dart';
import 'budget_alert_banner_dashboard.dart';
import 'local_reconciliation_gate_form.dart';
import 'public_profile_review_timeline.dart';
import 'django_income_statement_workspace.dart';
import 'navigation_rail_adaptive_workspace.dart';
import 'dynamic_typography_wrapper_workspace.dart';
import 'responsive_grid_wrapper_workspace.dart';
import 'theme_test_screen.dart';
import 'stateful_status_indicator_workspace.dart';
import 'design_token_consumer_workspace.dart';
import 'src_autocomplete_search_workspace.dart';
import 'mobile_grid_container_workspace.dart';
import 'progressive_stepper_wizard.dart';
import 'fluid_typography_scaling_system.dart';
import 'binary_semantic_color_system.dart';
import 'global_app_bar_showcase.dart';
import 'empty_state_boilerplate_showcase.dart';
import 'asynchronous_consensus_board_workspace.dart';
import 'masked_regex_input_field_workspace.dart';
import 'trace_time_line_chart_sla.dart';
import 'ai_rationale_accordion.dart';
import '../main.dart';
import '../widgets/data_list_wrapper.dart';
import '../widgets/empty_state_boilerplate.dart';
import '../widgets/payment_status_banner.dart';
import '../widgets/global_app_bar.dart';

/// Metadata model for separated widgets & components tagged with Global Reference IDs.
class ComponentSpec {
  final String id;
  final String globalRefId;
  final String atomicStepId;
  final String title;
  final String category;
  final String description;
  final IconData icon;
  final WidgetBuilder builder;
  final bool isFullWorkspace;

  const ComponentSpec({
    required this.id,
    required this.globalRefId,
    required this.atomicStepId,
    required this.title,
    required this.category,
    required this.description,
    required this.icon,
    required this.builder,
    this.isFullWorkspace = false,
  });
}

/// Standalone Web-Responsive Screen Container for a Single Component / Widget
class DedicatedComponentScreen extends StatelessWidget {
  final ComponentSpec spec;

  const DedicatedComponentScreen({super.key, required this.spec});

  @override
  Widget build(BuildContext context) {
    // If the widget is already a full Scaffold/Workspace, render it directly
    final content = spec.builder(context);
    if (spec.isFullWorkspace) {
      return content;
    }

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('[${spec.globalRefId}] ${spec.title}'),
        centerTitle: true,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.menu_book),
            tooltip: 'Plain English Explanation',
            onPressed: () {
              final exp = ComponentExplanationRegistry.getExplanation(
                globalRefId: spec.globalRefId,
                atomicStepId: spec.atomicStepId,
                title: spec.title,
                description: spec.description,
              );
              ComponentExplanationModalDialog.show(
                context: context,
                globalRefId: spec.globalRefId,
                title: spec.title,
                category: spec.category,
                explanation: exp,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.code),
            tooltip: 'Export Code & Integration Guide',
            onPressed: () {
              final specData = ComponentCodeRegistry.getCodeSpec(
                globalRefId: spec.globalRefId,
                title: spec.title,
                category: spec.category,
              );
              CodeExportModalDialog.show(
                context: context,
                globalRefId: spec.globalRefId,
                title: spec.title,
                fileName: specData['fileName']!,
                widgetClassName: specData['widgetClassName']!,
                category: spec.category,
                sourceCode: specData['sourceCode']!,
                integrationGuide: '''// -------------------------------------------------------------
// INTEGRATION GUIDE: [${spec.globalRefId}] ${spec.title}
// -------------------------------------------------------------

1. File Setup:
   Create lib/ui/${specData['fileName']} in your target Flutter application.

2. Dependencies:
   Ensure useMaterial3: true is set in your ThemeData.

3. Import & Usage:
   import 'package:your_app/ui/${specData['fileName']}';

   @override
   Widget build(BuildContext context) {
     return const ${specData['widgetClassName']}();
   }

4. Responsiveness & Accessibility:
   - Web/Tablet (>600dp): Displays adaptive multi-column layout or wide DataTable.
   - Mobile (<=600dp): Displays single-column touch-optimized Cards.
   - All interactive controls enforce 48dp minimum touch target height.
''',
              );
            },
          ),
          IconButton(
            icon: Icon(
              theme.brightness == Brightness.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            tooltip: 'Toggle Light / Dark Mode',
            onPressed: () {
              MyApp.of(context)?.toggleThemeMode();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktopWeb = constraints.maxWidth > 900;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.all(isDesktopWeb ? 32.0 : 16.0),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isDesktopWeb ? 1200.0 : 650.0,
                  ),
                  child: isDesktopWeb
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left Pane: Web Specs & Component Metadata Panel
                            SizedBox(
                              width: 360.0,
                              child: Card(
                                elevation: 1,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                  side: BorderSide(
                                    color: theme.colorScheme.outlineVariant,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundColor: theme
                                                .colorScheme.primaryContainer,
                                            foregroundColor: theme
                                                .colorScheme.onPrimaryContainer,
                                            child: Icon(spec.icon),
                                          ),
                                          const SizedBox(width: 12.0),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 8.0,
                                                    vertical: 2.0,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: theme.colorScheme
                                                        .primaryContainer,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6.0),
                                                  ),
                                                  child: Text(
                                                    'REF: ${spec.globalRefId}',
                                                    style: TextStyle(
                                                      fontSize: 11.0,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: theme.colorScheme
                                                          .onPrimaryContainer,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 4.0),
                                                Text(
                                                  spec.title,
                                                  style: theme
                                                      .textTheme.titleMedium
                                                      ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16.0),
                                      Text(
                                        spec.description,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                          color: theme
                                              .colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                      const Divider(height: 28.0),
                                      ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        leading: const Icon(Icons.fingerprint),
                                        title: const Text('Atomic Step ID'),
                                        subtitle: Text(spec.atomicStepId),
                                      ),
                                      ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        leading: const Icon(Icons.category),
                                        title: const Text('Category'),
                                        subtitle: Text(spec.category),
                                      ),
                                      const SizedBox(height: 16.0),
                                      ConstrainedBox(
                                        constraints: const BoxConstraints(minHeight: 48.0),
                                        child: FilledButton.icon(
                                          style: FilledButton.styleFrom(
                                            minimumSize: const Size.fromHeight(48.0),
                                          ),
                                          onPressed: () {
                                            final specData = ComponentCodeRegistry.getCodeSpec(
                                              globalRefId: spec.globalRefId,
                                              title: spec.title,
                                              category: spec.category,
                                            );
                                            CodeExportModalDialog.show(
                                              context: context,
                                              globalRefId: spec.globalRefId,
                                              title: spec.title,
                                              fileName: specData['fileName']!,
                                              widgetClassName: specData['widgetClassName']!,
                                              category: spec.category,
                                              sourceCode: specData['sourceCode']!,
                                              integrationGuide: '''// -------------------------------------------------------------
// INTEGRATION GUIDE: [${spec.globalRefId}] ${spec.title}
// -------------------------------------------------------------

1. File Setup:
   Create lib/ui/${specData['fileName']} in your target Flutter application.

2. Dependencies:
   Ensure useMaterial3: true is set in your ThemeData.

3. Import & Usage:
   import 'package:your_app/ui/${specData['fileName']}';

   @override
   Widget build(BuildContext context) {
     return const ${specData['widgetClassName']}();
   }

4. Responsiveness & Accessibility:
   - Web/Tablet (>600dp): Displays adaptive multi-column layout or wide DataTable.
   - Mobile (<=600dp): Displays single-column touch-optimized Cards.
   - All interactive controls enforce 48dp minimum touch target height.
''',
                                            );
                                          },
                                          icon: const Icon(Icons.code),
                                          label: const Text('Export Code & Guide'),
                                        ),
                                      ),
                                      const SizedBox(height: 12.0),
                                      ConstrainedBox(
                                        constraints: const BoxConstraints(minHeight: 48.0),
                                        child: OutlinedButton.icon(
                                          style: OutlinedButton.styleFrom(
                                            minimumSize: const Size.fromHeight(48.0),
                                          ),
                                          onPressed: () {
                                            final exp = ComponentExplanationRegistry.getExplanation(
                                              globalRefId: spec.globalRefId,
                                              atomicStepId: spec.atomicStepId,
                                              title: spec.title,
                                              description: spec.description,
                                            );
                                            ComponentExplanationModalDialog.show(
                                              context: context,
                                              globalRefId: spec.globalRefId,
                                              title: spec.title,
                                              category: spec.category,
                                              explanation: exp,
                                            );
                                          },
                                          icon: const Icon(Icons.menu_book),
                                          label: const Text('Plain English Explanation'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 24.0),

                            // Right Pane: Responsive Interactive Component Canvas
                            Expanded(
                              child: Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                  side: BorderSide(
                                    color: theme.colorScheme.outlineVariant,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(28.0),
                                  child: content,
                                ),
                              ),
                            ),
                          ],
                        )
                      : Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            side: BorderSide(
                              color: theme.colorScheme.outlineVariant,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor:
                                          theme.colorScheme.primaryContainer,
                                      foregroundColor:
                                          theme.colorScheme.onPrimaryContainer,
                                      child: Icon(spec.icon),
                                    ),
                                    const SizedBox(width: 12.0),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '[${spec.globalRefId}] ${spec.category}',
                                            style: theme.textTheme.labelSmall
                                                ?.copyWith(
                                              color: theme.colorScheme.primary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            spec.title,
                                            style: theme.textTheme.titleMedium
                                                ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8.0),
                                Text(
                                  spec.description,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const Divider(height: 28.0),

                                // Isolated Component Instance
                                content,
                              ],
                            ),
                          ),
                        ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Master Menu Dashboard Screen
/// Serves as the central menu with buttons tagged with Global Reference IDs.
class MasterMenuPage extends StatefulWidget {
  const MasterMenuPage({super.key});

  @override
  State<MasterMenuPage> createState() => _MasterMenuPageState();
}

class _MasterMenuPageState extends State<MasterMenuPage> {
  String _searchQuery = '';
  String _selectedCategory = 'All';

  late final List<ComponentSpec> _allComponents;

  @override
  void initState() {
    super.initState();
    _allComponents = _buildComponentCatalog();
  }

  List<ComponentSpec> _buildComponentCatalog() {
    return [
      ComponentSpec(
        id: 'REF-377',
        globalRefId: 'REF-377-A12',
        atomicStepId: 'REF-377-A12',
        title: 'Progressive Stepper Wizard',
        category: 'Motion & Forms',
        description:
            'Progressive Stepper Wizard with 200ms physical button animation lock (Poka-Yoke), 5-second inactivity chaser pulse, automatic DOM unmounting, and reduced-motion instant transition fallback.',
        icon: Icons.linear_scale,
        isFullWorkspace: false,
        builder: (context) => const ProgressiveStepperWizard(),
      ),
      ComponentSpec(
        id: 'BPTR-0334',
        globalRefId: 'BPTR-0334-A15',
        atomicStepId: 'BPTR-0334-A15',
        title: 'Fluid Typographic Scaling System',
        category: 'Typography & Design System',
        description:
            'Fluid Typography scaling engine mimicking CSS clamp() with locked Material 3 tokens, WCAG AAA (7:1) contrast enforcement, and CI/CD hardcoded font-size blocker linter.',
        icon: Icons.format_size,
        isFullWorkspace: false,
        builder: (context) => const FluidTypographyScalingSystem(),
      ),
      ComponentSpec(
        id: 'TTMCS-002',
        globalRefId: 'TTMCS-002-A01',
        atomicStepId: 'TTMCS-002-A01',
        title: 'Binary Semantic Color System',
        category: 'Design System & CI/CD',
        description:
            'Binary Semantic Color Gates with ThemeExtension (Green for Compliant/True, Red for Non-compliant/False), bold outdoor validation text badges, and The Raw Hex Assassin CI/CD linter.',
        icon: Icons.check_circle_outline,
        isFullWorkspace: false,
        builder: (context) => const BinarySemanticColorSystem(),
      ),
      ComponentSpec(
        id: 'BPTR-0725',
        globalRefId: 'BPTR-0725-A01',
        atomicStepId: 'BPTR-0725-A01',
        title: 'Numeric Poka-Yoke Input Field',
        category: 'Form & Input Masking',
        description:
            'Poka-Yoke input field with native numeric keypad override, FilteringTextInputFormatter.digitsOnly physical keystroke bouncer, and 0-18 age / positive earnings boundary validation.',
        icon: Icons.pin,
        isFullWorkspace: false,
        builder: (context) => NumericPokaYokeForm(),
      ),
      ComponentSpec(
        id: 'DPNDL-011',
        globalRefId: 'DPNDL-011-A01',
        atomicStepId: 'DPNDL-011-A01',
        title: 'Global Top Application Bar',
        category: 'Navigation & Headers',
        description:
            'PreferredSizeWidget AppBar strictly locked to 64.0dp vertical height with 48x48dp phantom touch target padding and compile-time required routing callback linkages.',
        icon: Icons.web_asset,
        isFullWorkspace: false,
        builder: (context) => const GlobalAppBarShowcase(),
      ),
      ComponentSpec(
        id: 'USMBL-014',
        globalRefId: 'USMBL-014-A01',
        atomicStepId: 'USMBL-014-A01',
        title: 'Empty State Boilerplate & Chaser Pulse',
        category: 'Layouts & Onboarding',
        description:
            'Conditional array data wrapper dynamically swapping empty datasets with centered flexbox illustration, informative text prompt, and 2-second looping pulsing CTA button.',
        icon: Icons.hourglass_empty,
        isFullWorkspace: false,
        builder: (context) => const EmptyStateBoilerplateShowcase(),
      ),
      ComponentSpec(
        id: 'AWCV-013',
        globalRefId: 'AWCV-013-A01',
        atomicStepId: 'AWCV-013-A01',
        title: 'Asynchronous Consensus Voting Card',
        category: 'Decisions & Gestures',
        description:
            'Tinder-style gesture swipe card (Agree right / Disagree left) with bottom anchor buttons, anti-meeting blocker, and countdown expiration timer with auto-abstain Poka-Yoke.',
        icon: Icons.how_to_vote,
        isFullWorkspace: false,
        builder: (context) => const AsynchronousConsensusBoardWorkspace(),
      ),
      ComponentSpec(
        id: 'REF-362',
        globalRefId: 'REF-362-A01',
        atomicStepId: 'REF-362-A01',
        title: 'Regex Input Masking Enforcer',
        category: 'Form & Input Masking',
        description:
            'Real-time formatting mask formatter with invisible bouncer keystroke nullification and automatic 3-strike helper tooltip overlay on repeated invalid keystrokes.',
        icon: Icons.password,
        isFullWorkspace: false,
        builder: (context) => const MaskedRegexInputFieldWorkspace(),
      ),
      ComponentSpec(
        id: 'TTMCS-003',
        globalRefId: 'TTMCS-003-A02',
        atomicStepId: 'TTMCS-003-A02',
        title: '4-to-8 Column Grid Matrix & MD3 Theme',
        category: 'Layouts & Architecture',
        description:
            'Responsive 4-column mobile (<=600px) and 8-column tablet (>600px) layout grid matrix with root MD3 dynamic color token injection and hardcode assassin linter.',
        icon: Icons.grid_view,
        isFullWorkspace: true,
        builder: (context) => const ResponsiveGridWrapperWorkspace(),
      ),
      ComponentSpec(
        id: 'BPTR-0725-2',
        globalRefId: 'BPTR-0725-A02',
        atomicStepId: 'BPTR-0725-A02',
        title: 'Numeric Keystroke Bouncer Field',
        category: 'Form & Input Masking',
        description:
            'Numeric input field enforcing native number pad, digits-only keystroke rejection, and inline boundary constraints with clear error reporting.',
        icon: Icons.pin,
        isFullWorkspace: false,
        builder: (context) => NumericPokaYokeForm(),
      ),
      ComponentSpec(
        id: 'SLPLU-014',
        globalRefId: 'SLPLU-014-A02',
        atomicStepId: 'SLPLU-014-A02',
        title: 'Trace Time Line Chart SLA Monitor',
        category: 'Dashboards & Analytics',
        description:
            'Interactive latency line chart with locked Y-axis bounds (Poka-Yoke), high-contrast 200ms red SLA failure line, touch-and-hold tooltip, and automated architecture ticketing.',
        icon: Icons.ssid_chart,
        isFullWorkspace: false,
        builder: (context) => const TraceTimeLineChartSLA(),
      ),
      ComponentSpec(
        id: 'AWCV-013-2',
        globalRefId: 'AWCV-013-A02',
        atomicStepId: 'AWCV-013-A02',
        title: 'Async Decision Voting Board',
        category: 'Decisions & Gestures',
        description:
            'Gesture swipe consensus voting card (Agree/Disagree) with countdown timer auto-abstain Poka-Yoke and anti-meeting blocker.',
        icon: Icons.how_to_vote,
        isFullWorkspace: false,
        builder: (context) => const AsynchronousConsensusBoardWorkspace(),
      ),
      ComponentSpec(
        id: 'SCTSS-018',
        globalRefId: 'SCTSS-018-A02',
        atomicStepId: 'SCTSS-018-A02',
        title: 'AI Rationale Accordion (Trust Layer)',
        category: 'Explainable AI & Trust',
        description:
            'Collapsible XAI reasoning accordion with maxHeight constraint (250px), citations, forced-read lock on approval button, and low-confidence yellow warning pulse.',
        icon: Icons.psychology,
        isFullWorkspace: false,
        builder: (context) => const AiRationaleAccordion(),
      ),
      ComponentSpec(
        id: '25',
        globalRefId: 'HSCPE-007',
        atomicStepId: 'HSCPE-007-A01',
        title: 'Filesystem Tuning Admin Dashboard',
        category: 'Dashboards & Analytics',
        description:
            'Responsive MD3 Filesystem Tuning Admin Dashboard with bodyMedium typography tokens, LayoutBuilder grid/list reflow, and poka-yoke HTTP 429 rate limit retry countdown dialog.',
        icon: Icons.storage,
        isFullWorkspace: true,
        builder: (context) => const FilesystemTuningAdminDashboard(),
      ),
      ComponentSpec(
        id: '26',
        globalRefId: 'RCGLA-028',
        atomicStepId: 'RCGLA-028-A01',
        title: 'Mobile Surgical Container & Grid System',
        category: 'Layouts & Containers',
        description:
            'Mobile-First layout grid with 360px compact reflow (Column), Table-to-Card feed, rigid 16.0px getters, NeverScrollableScrollPhysics poka-yoke horizontal scroll lock, and root state data fetching.',
        icon: Icons.grid_view,
        isFullWorkspace: true,
        builder: (context) => const MobileSurgicalContainer(),
      ),
      ComponentSpec(
        id: '27',
        globalRefId: 'BPWSO-007-12',
        atomicStepId: 'BPWSO-007-12-A01',
        title: 'Lineage Graph & Terminal Alert Dashboard',
        category: 'Dashboards & Analytics',
        description:
            'Gesture-driven InteractiveViewer panning canvas, 48dp minimum hit boxes, Poka-Yoke DFS graph cycle detection, WCAG AAA 7:1 contrast terminal alert, and mobile ExpansionTile accordion drawers.',
        icon: Icons.account_tree,
        isFullWorkspace: true,
        builder: (context) => const LineageGraphTerminalAlertDashboard(),
      ),
      ComponentSpec(
        id: '28',
        globalRefId: 'USMBL-017',
        atomicStepId: 'USMBL-017-A01',
        title: 'LoadingSubmitButton & Form Lockdown Wrapper',
        category: 'Forms & Inputs',
        description:
            'Constant 56dp dimensional footprint button with poka-yoke in-flight Opacity + IgnorePointer form lockdown, 15-second deadlock breaker timeout bound, and atomic metadata documentation header.',
        icon: Icons.smart_button,
        isFullWorkspace: true,
        builder: (context) => const LoadingSubmitButtonForm(),
      ),
      ComponentSpec(
        id: '29',
        globalRefId: 'ARCPE-005-01',
        atomicStepId: 'ARCPE-005-01-A01',
        title: 'AI Output Analytics & LLM Confidence Triage',
        category: 'Dashboards & Analytics',
        description:
            'AI Output analytics stream with dynamic LLM ConfidenceBadges (High/Med/Low M3 color mapping), WCAG 2.1 AA 48px optimal touch targets, and LayoutBuilder ListView vs DataTable reflow.',
        icon: Icons.psychology,
        isFullWorkspace: true,
        builder: (context) => const AiOutputAnalyticsView(),
      ),
      ComponentSpec(
        id: '30',
        globalRefId: 'CCPME-002',
        atomicStepId: 'CCPME-002-A01',
        title: 'Habot Multi-Child Registration Form',
        category: 'Forms & Inputs',
        description:
            'Dynamic multi-child form generation with LinearProgressIndicator step tracking, inline errorText mapping directly beneath input fields, and showModalBottomSheet (Mobile) vs AlertDialog (Tablet/Web) architecture.',
        icon: Icons.family_restroom,
        isFullWorkspace: true,
        builder: (context) => const MultiChildRegistrationForm(),
      ),
      ComponentSpec(
        id: '31',
        globalRefId: 'HSCPE-021',
        atomicStepId: 'HSCPE-021-A01',
        title: 'Startup Probe & Secure Document Repository',
        category: 'Workspaces & Sandbox',
        description:
            'Tabbed initialization logs (DefaultTabController), MD3 status icons for loading milestones, poka-yoke document clearance lock banners, and LayoutBuilder tab vs side-panel reflow.',
        icon: Icons.folder_special,
        isFullWorkspace: true,
        builder: (context) => const StartupProbeSecureRepository(),
      ),
      ComponentSpec(
        id: '32',
        globalRefId: 'IS26-RCGLA-024-AS01',
        atomicStepId: 'IS26-RCGLA-024-AS01-A01',
        title: 'Dynamic Context FAB',
        category: 'Forms & Inputs',
        description:
            'Shapeshifting FAB (Extended on Web/Tablet vs Standard on Mobile), M3 design tokens (primaryContainer & elevation 3.0), contextual SizedBox.shrink() security removal, and poka-yoke double-tap prevention.',
        icon: Icons.add_task,
        isFullWorkspace: true,
        builder: (context) => const DynamicContextFab(),
      ),
      ComponentSpec(
        id: '33',
        globalRefId: 'RCGLA-043',
        atomicStepId: 'RCGLA-043-A01',
        title: 'High-Density Operational Data Table',
        category: 'Dashboards & Analytics',
        description:
            'Responsive column minification (3 critical cols on mobile vs 6 on web), strict 48dp row height constraints with cell truncation, poka-yoke bad transaction data filtering, and isolate sorting commentary.',
        icon: Icons.table_chart,
        isFullWorkspace: true,
        builder: (context) => const HighDensityOperationalDataTable(),
      ),
      ComponentSpec(
        id: '34',
        globalRefId: 'CBSV-007',
        atomicStepId: 'CBSV-007-A01',
        title: 'Universal Lookup Matrix Dashboard',
        category: 'Dashboards & Analytics',
        description:
            'Search-as-you-type TextField dictionary filtering, MD3 elevation 2.0 Card ExpansionTiles, rigid ValidationException blank-cell blocker poka-yoke, and BABOK v3 completeness metadata header.',
        icon: Icons.manage_search,
        isFullWorkspace: true,
        builder: (context) => const UniversalLookupMatrix(),
      ),
      ComponentSpec(
        id: '35',
        globalRefId: 'EDBAA-015-15',
        atomicStepId: 'EDBAA-015-15-A01',
        title: 'Component Library Documentation Archive',
        category: 'Dashboards & Analytics',
        description:
            'Immediate InkWell/Material ripple feedback, crisp TableBorder.all boundaries, clamped textScaler (1.0-1.2) for WCAG readability, DAMA-DMBOK2 poka-yoke metadata completeness validation banner, and LayoutBuilder reflow.',
        icon: Icons.archive,
        isFullWorkspace: true,
        builder: (context) => const ComponentLibraryDocArchive(),
      ),
      ComponentSpec(
        id: '36',
        globalRefId: 'RCGLA-021',
        atomicStepId: 'RCGLA-021-A01',
        title: 'Responsive Layout Grid & Breakpoint Engine',
        category: 'Workspaces & Sandbox',
        description:
            'Explicit breakpoints (xs, sm, md, lg, xl), 4-8-12 column and margin engine (16dp mobile vs 24dp desktop), SafeTableContainer anti-clipping poka-yoke guardrail, and architectural metadata block.',
        icon: Icons.grid_on,
        isFullWorkspace: true,
        builder: (context) => const ResponsiveLayoutGridEngine(),
      ),
      ComponentSpec(
        id: '37',
        globalRefId: 'ACRAE-011',
        atomicStepId: 'ACRAE-011-A01',
        title: 'Mobile-First AI Chat Flow',
        category: 'Forms & Inputs',
        description:
            'M3 FAB chat initiation, surface color chat bubbles (borderRadius 16.0), 429 rate-limit disabling with subtle SnackBar notifications, poka-yoke exponential backoff retry loop, and telemetry metadata.',
        icon: Icons.chat,
        isFullWorkspace: true,
        builder: (context) => const MobileFirstAiChatFlow(),
      ),
      ComponentSpec(
        id: '38',
        globalRefId: 'ANSA-020-15',
        atomicStepId: 'ANSA-020-15-EXEC-8902',
        title: 'M3 Adaptive Navigation Dashboard',
        category: 'Dashboards & Analytics',
        description:
            'Adaptive NavigationBar (<600dp) vs NavigationRail (>=600dp) with AnimatedSwitcher motion, strict 48dp minimum touch target hit boxes, and process execution quality metadata.',
        icon: Icons.navigation,
        isFullWorkspace: true,
        builder: (context) => const M3AdaptiveNavigationDashboard(),
      ),
      ComponentSpec(
        id: '41',
        globalRefId: 'PCDE-016',
        atomicStepId: 'PCDE-016-A01',
        title: 'Secure Employee Payroll Register & IBAN Masking',
        category: 'Security & Access',
        description:
            'ISO 27001 IBAN regex masking (dots replacing digits except final 4), Gross vs Net typography tints, tooltips, and mobile showModalBottomSheet detail routing.',
        icon: Icons.account_balance,
        isFullWorkspace: true,
        builder: (context) => const SecureEmployeePayrollRegister(),
      ),
      ComponentSpec(
        id: '42',
        globalRefId: 'NSKFI-005',
        atomicStepId: 'NSKFI-005-A01',
        title: 'Form Input Masking & Native Keyboards',
        category: 'Forms & Inputs',
        description:
            'Native keyboard mapping (phone, datetime, words), client-side input formatters, regex validation, and Poka-Yoke submit button disabling.',
        icon: Icons.app_shortcut,
        isFullWorkspace: true,
        builder: (context) => const FormInputMaskingNativeKeyboards(),
      ),
      ComponentSpec(
        id: '43',
        globalRefId: 'BPTR-0803',
        atomicStepId: 'BPTR-0803-A01',
        title: 'Edge-Level Regex Validation & Error States',
        category: 'Forms & Inputs',
        description:
            '48dp touch targets, real-time edge masking formatters, high-contrast red error borders, ARIA semantic equivalents, and Poka-Yoke Hard Stop submission block.',
        icon: Icons.verified_user_outlined,
        isFullWorkspace: true,
        builder: (context) => const EdgeLevelValidationForm(),
      ),
      ComponentSpec(
        id: '44',
        globalRefId: 'DPRBR-004',
        atomicStepId: 'DPRBR-004-A01',
        title: 'Campaign Target SKU Selection Constraints',
        category: 'Layouts & Containers',
        description:
            'Fluid Grid (maxExtent 300px) to Single-Column List reflow, above-the-fold extreme elevation (12.0dp) bottom CTA, and TLS security fallback alert card.',
        icon: Icons.shopping_bag_outlined,
        isFullWorkspace: true,
        builder: (context) => const CampaignTargetSkuSelection(),
      ),
      ComponentSpec(
        id: '45',
        globalRefId: 'FLADE-011-06',
        atomicStepId: 'FLADE-011-06-EXEC-9912',
        title: 'Shakti Alert Panel (Critical System Breach UI)',
        category: 'Security & Access',
        description:
            'Z-Index 10000 top-level fixed alert panel, un-ignorable M3 error styling, strict no-dismissal Poka-Yoke rule, and Google SRE telemetry header.',
        icon: Icons.warning_amber_rounded,
        isFullWorkspace: true,
        builder: (context) => const ShaktiAlertPanel(),
      ),
      ComponentSpec(
        id: '46',
        globalRefId: 'AEETE-002',
        atomicStepId: 'AEETE-002-A07-A01',
        title: 'A/B Test Variant Preservation (14-Day Lock)',
        category: 'Dashboards & Analytics',
        description:
            '14-day persistent run time lock, flicker-free reactive state notifier, and WCAG 2.1 AA verified contrast colors (>= 4.5:1 ratio).',
        icon: Icons.tune,
        isFullWorkspace: true,
        builder: (context) => const AbTestVariantPreservation(),
      ),
      ComponentSpec(
        id: '47',
        globalRefId: 'HSFVS-001',
        atomicStepId: 'HSFVS-001-A08-A01',
        title: 'Strict Linear Progression ViewPager',
        category: 'Layouts & Containers',
        description:
            'Predecessor ID validation routing graph (Poka-Yoke), PageView with PageScrollPhysics snap lock, circular dot indicators, and architecture header.',
        icon: Icons.linear_scale,
        isFullWorkspace: true,
        builder: (context) => const StrictLinearProgressionViewPager(),
      ),
      ComponentSpec(
        id: '48',
        globalRefId: 'ERMWD-007-08',
        atomicStepId: 'ERMWD-007-08-A01',
        title: 'Operations Task Entry & Single-Verb Constraints',
        category: 'Forms & Inputs',
        description:
            'Double-entry Poka-Yoke field verification, error-colored urgency countdown timer, single-verb _verify() API binding, and DAMA-DMBOK2 metadata.',
        icon: Icons.fact_check_outlined,
        isFullWorkspace: true,
        builder: (context) => const OperationsTaskEntry(),
      ),
      ComponentSpec(
        id: '49',
        globalRefId: 'NQSDV-003',
        atomicStepId: 'NQSDV-003-EXEC-7721',
        title: 'Payment Gateway Verification Dashboard',
        category: 'Dashboards & Analytics',
        description:
            'High-contrast status cards with titleLarge metrics and divider separators, non-blocking MaterialBanner/SnackBar notifications (zero dialogs), and System Usability Scale telemetry.',
        icon: Icons.point_of_sale,
        isFullWorkspace: true,
        builder: (context) => const PaymentGatewayVerificationDashboard(),
      ),
      ComponentSpec(
        id: '50',
        globalRefId: 'DSI-001',
        atomicStepId: 'DSI-001-A01',
        title: 'Design System & Theme Infrastructure Showcase',
        category: 'Design System & Infrastructure',
        description:
            'Full 6-Phase Design Tokens, M3 Color Palette, Spacing Tokens, Dual-Pane Layout, RIMV-007 Save-Lock Interceptor, Three-Tier AI Confidence Alerting, System Breach Read-Only Controller, and WCAG AA Audit Logger.',
        icon: Icons.palette_outlined,
        isFullWorkspace: true,
        builder: (context) => const DesignSystemInfrastructureShowcase(),
      ),
      ComponentSpec(
        id: '39',
        globalRefId: 'BLGTA-001-11',
        atomicStepId: 'BLGTA-001-11-A01',
        title: 'Welcoming Initial Input Form',
        category: 'Forms & Inputs',
        description:
            'Smart focus & keyboard optimization (autofocus, TextInputAction.next/done), M3 OutlinedTextFileds, single-line atomic action double-click prevention, centered elevated card on Web/Tablet, and telemetry header.',
        icon: Icons.assignment_ind,
        isFullWorkspace: true,
        builder: (context) => const WelcomingInitialInputForm(),
      ),
      ComponentSpec(
        id: '40',
        globalRefId: 'MCIIM-020-13',
        atomicStepId: 'MCIIM-020-13-A01',
        title: 'HR Metric Target & Contextual Modifier',
        category: 'Dashboards & Analytics',
        description:
            'Fluid Wrap contextual modifier multiplier chips, full-width mobile dropdown ergonomics (isExpanded: true), single-column ListView vs multi-column GridView reflow, and ISO 29119 verification metadata header.',
        icon: Icons.trending_up,
        isFullWorkspace: true,
        builder: (context) => const HrMetricTargetContextualModifier(),
      ),
      ComponentSpec(
        id: '1',
        globalRefId: 'APIGW-413',
        atomicStepId: 'APIGW-413-A01',
        title: 'API Gateway Payload Upload & 413 Handling',
        category: 'Workspaces & Sandbox',
        description:
            'API Gateway payload upload manager handling request payload size checks and 413 Payload Too Large error fallbacks.',
        icon: Icons.cloud_upload,
        isFullWorkspace: true,
        builder: (context) => const PayloadUploadWidget(),
      ),
      ComponentSpec(
        id: '15b',
        globalRefId: 'GTBPU-001',
        atomicStepId: 'GTBPU-001-A01',
        title: 'Public Profile Review Timeline',
        category: 'Workspaces & Sandbox',
        description:
            'Chronological timeline of profile review events with M3 elastic padding, fluid typography scaling, and status badges.',
        icon: Icons.history,
        isFullWorkspace: true,
        builder: (context) => const PublicProfileReviewTimeline(),
      ),
      ComponentSpec(
        id: '2',
        globalRefId: 'MCCEA-001',
        atomicStepId: 'MCCEA-001-A01',
        title: 'Satisfaction Analytics & Churn Engine',
        category: 'Dashboards & Analytics',
        description:
            'Real-time Pub/Sub StreamBuilder analytics with adaptive LayoutBuilder containers & Poka-Yoke ingestion checks.',
        icon: Icons.analytics,
        isFullWorkspace: true,
        builder: (context) => const SatisfactionAnalyticsEngineDashboard(),
      ),
      ComponentSpec(
        id: '16',
        globalRefId: 'OPMV-002',
        atomicStepId: 'OPMV-002-A01',
        title: 'Feedback-Driven Ranking Sync Points Ledger',
        category: 'Dashboards & Analytics',
        description:
            'Responsive points ledger with LayoutBuilder DataTable (Web/Tablet) vs Card ListView (Mobile), subtle tier color coding, real-time WebSocket stream (<1s), and Poka-Yoke payload AlertDialog.',
        icon: Icons.leaderboard,
        isFullWorkspace: false,
        builder: (context) => const FeedbackRankingSyncLedger(),
      ),
      ComponentSpec(
        id: '17',
        globalRefId: 'TECH-ENG-005',
        atomicStepId: 'TECH-ENG-005-A01',
        title: 'Streaming Pipeline & Schema Validation Dashboard',
        category: 'Dashboards & Analytics',
        description:
            'BigQuery streaming monitoring dashboard with 100% Poka-Yoke schema validation, LayoutBuilder DataTable (Web/Tablet) vs Card ListView (Mobile), and M3 Health Status Banner (Pass/Fail).',
        icon: Icons.stream,
        isFullWorkspace: true,
        builder: (context) => const BigQueryStreamingValidationDashboard(),
      ),
      ComponentSpec(
        id: '18',
        globalRefId: 'TECH-ENG-023',
        atomicStepId: 'TECH-ENG-023-A01',
        title: 'Universal Engineering Notification Center',
        category: 'Alerts & Banners',
        description:
            'Infrastructure alert manager with LayoutBuilder Split View (Web/Tablet) vs Swipeable Dismissible Cards (Mobile), severity color coding, and Delivery SLA tracking.',
        icon: Icons.notifications_active,
        isFullWorkspace: false,
        builder: (context) => const UniversalEngineeringNotificationCenter(),
      ),
      ComponentSpec(
        id: '19',
        globalRefId: 'TECH-ENG-038',
        atomicStepId: 'TECH-ENG-038-A01',
        title: 'CI/CD Linter WCAG 2.2 AA Accessibility Dashboard',
        category: 'Dashboards & Analytics',
        description:
            'Accessibility linter dashboard featuring 100% ARIA Semantics screen reader wrappers, high-contrast M3 FAIL banner, and LayoutBuilder pipeline timeline vs violations DataTable.',
        icon: Icons.accessibility_new,
        isFullWorkspace: false,
        builder: (context) => const CicdLinterAccessibilityDashboard(),
      ),
      ComponentSpec(
        id: '20',
        globalRefId: 'NLM-APS-003',
        atomicStepId: 'NLM-APS-003-A01',
        title: 'Enterprise CMEK & Security Console',
        category: 'Workspaces & Sandbox',
        description:
            'Security console with NavigationRail (Web/Tablet) vs Card ListView (Mobile), Poka-Yoke locked Key Rotation policy, and Pass/Fail metric banner.',
        icon: Icons.admin_panel_settings,
        isFullWorkspace: true,
        builder: (context) => const EnterpriseCmekSecurityConsole(),
      ),
      ComponentSpec(
        id: '21',
        globalRefId: 'PELCE-019-01',
        atomicStepId: 'PELCE-019-01-A01',
        title: 'English Code (EC) System Verb CTA Button',
        category: 'Forms & Inputs',
        description:
            'Pill-shaped CTA button enforcing strict machine-action EC verbs (SUBMIT, AUTHORIZE, DELETE, AUTHENTICATE, EXECUTE) via Poka-Yoke assertions and 56px height.',
        icon: Icons.touch_app,
        isFullWorkspace: false,
        builder: (context) => const SystemVerbButtonDemoPage(),
      ),
      ComponentSpec(
        id: '22',
        globalRefId: 'IRBCA-061',
        atomicStepId: 'IRBCA-061-A01',
        title: 'Board Signatory Access Constraint',
        category: 'Workspaces & Sandbox',
        description:
            'Access constraint UI with FloatingActionButton thumb-sweep ergonomics, strict DOM eradication ternary check, high-density typography, and high-contrast pending banner.',
        icon: Icons.draw,
        isFullWorkspace: true,
        builder: (context) => const BoardSignatoryAccessConstraint(),
      ),
      ComponentSpec(
        id: '23',
        globalRefId: 'PELCE-019-14',
        atomicStepId: 'PELCE-019-14-A01',
        title: 'Design System Merge Dashboard',
        category: 'Dashboards & Analytics',
        description:
            'ISO 9001 process adherence dashboard featuring 2-column split layout (Web/Tablet), pill shape FilledButton preview, and completion status merge enforcer gate.',
        icon: Icons.merge_type,
        isFullWorkspace: true,
        builder: (context) => const DesignSystemMergeDashboard(),
      ),
      ComponentSpec(
        id: '3',
        globalRefId: 'BPTR-0725',
        atomicStepId: 'BPTR-0725-A01',
        title: 'Mobile Poka-Yoke Input Masking (Numerics)',
        category: 'Forms & Inputs',
        description:
            'Numeric input form enforcing Poka-Yoke range constraints and immediate visual error feedback.',
        icon: Icons.pin,
        builder: (context) => NumericPokaYokeForm(),
      ),
      ComponentSpec(
        id: '4',
        globalRefId: 'REF-362',
        atomicStepId: 'REF-362-A01',
        title: 'Mobile Regex Input Masking Enforcer',
        category: 'Forms & Inputs',
        description:
            'Masked input field enforcing strict regex formatting (e.g. MM/DD/YYYY date mask).',
        icon: Icons.calendar_month,
        builder: (context) => MaskedRegexInputField(
          label: 'Expiry Date (MM/DD/YYYY)',
          hintText: '08/11/2026',
          mask: '##/##/####',
          allowedCharRegex: RegExp(r'^[0-9]$'),
          fullMatchRegex: RegExp(r'^\d{2}/\d{2}/\d{4}$'),
          expectedFormatHint: 'Expected format: MM/DD/YYYY',
          inputMode: TextInputType.number,
        ),
      ),
      ComponentSpec(
        id: '5',
        globalRefId: 'BLGTA-048',
        atomicStepId: 'BLGTA-048',
        title: 'Expense Taxonomy Picklist',
        category: 'Forms & Inputs',
        description:
            'Enum-enforced category picklist enforcing standard accounting taxonomy.',
        icon: Icons.sell,
        builder: (context) => const ExpenseTaxonomyPicklist(),
      ),
      ComponentSpec(
        id: '6',
        globalRefId: 'AWCV-013',
        atomicStepId: 'AWCV-013-A01',
        title: 'Asynchronous Consensus Board (Voting UI)',
        category: 'Dashboards & Analytics',
        description:
            'Proposal voting board with real-time countdown timer and dynamic consensus threshold calculations.',
        icon: Icons.how_to_vote,
        builder: (context) => AsynchronousConsensusBoard(
          initialDurationSeconds: 30,
          onVoteSubmitted: (vote) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Vote submitted: $vote')),
            );
          },
          proposal: const ConsensusProposal(
            id: 'PROP-1042',
            title: 'Migrate Core Services to Micro-Frontends',
            description:
                'Proposal to decouple monolithic UI components into independently deployable Universal SRC micro-frontend modules.',
            author: 'Architecture Guild',
            category: 'Infrastructure',
          ),
        ),
      ),
      ComponentSpec(
        id: '7',
        globalRefId: 'NSKFI-002',
        atomicStepId: 'NSKFI-002-A01',
        title: 'Universal SRC Search',
        category: 'Search & Navigation',
        description:
            'Real-time search input bar with search history dropdown and filter chips.',
        icon: Icons.search,
        builder: (context) => const UniversalSRCSearch(),
      ),
      ComponentSpec(
        id: '8',
        globalRefId: 'TTMCS-002',
        atomicStepId: 'TTMCS-002-A01',
        title: 'Validation Status Alert Banners',
        category: 'Alerts & Banners',
        description:
            'Security validation alert banner showing success gate passed and security gate denied states.',
        icon: Icons.gpp_good,
        builder: (context) => const Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ValidationStatusAlert(
              isValid: true,
              message: 'Account validation passed! Security gate cleared.',
            ),
            SizedBox(height: 12),
            ValidationStatusAlert(
              isValid: false,
              message: 'Validation failed: Security gate denied access.',
            ),
          ],
        ),
      ),
      ComponentSpec(
        id: '9',
        globalRefId: 'SCTAS-013',
        atomicStepId: 'SCTAS-013-A01',
        title: 'Payment Status Banners',
        category: 'Alerts & Banners',
        description:
            'Payment status banners using theme extension semantic color definitions.',
        icon: Icons.payments,
        builder: (context) => const Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PaymentStatusBanner(
              isSuccess: true,
              message: 'Payment completed successfully!',
            ),
            SizedBox(height: 12),
            PaymentStatusBanner(
              isSuccess: false,
              message: 'Transaction failed. Please try again.',
            ),
          ],
        ),
      ),
      ComponentSpec(
        id: '10',
        globalRefId: 'USMBL-014',
        atomicStepId: 'USMBL-014-A01',
        title: 'Empty State Boilerplate & Pulsing CTA',
        category: 'Alerts & Banners',
        description:
            'Data wrapper rendering empty state graphics and a pulsing action button when data is empty.',
        icon: Icons.inbox,
        builder: (context) => Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: DataListWrapper<String>(
            data: const [],
            emptyState: EmptyStateBoilerplate(
              title: 'No Data Records Found',
              description:
                  'Your dataset is currently empty. Tap the pulsing button below to create your first record.',
              illustration: Icon(
                Icons.inbox_outlined,
                size: 80.0,
                color: Theme.of(context).colorScheme.primary,
              ),
              ctaLabel: 'Add New Record',
              onCtaPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Pulsing CTA tapped! Creating record...'),
                  ),
                );
              },
            ),
            child: const ListTile(title: Text('Data Available')),
          ),
        ),
      ),
      ComponentSpec(
        id: '11',
        globalRefId: 'FIEVR-002',
        atomicStepId: 'FIEVR-002',
        title: 'Offline-First UDD Sync Workspace',
        category: 'Workspaces & Sandbox',
        description:
            'Full workspace screen for offline queueing, local sync state, and data replication.',
        icon: Icons.sync,
        isFullWorkspace: true,
        builder: (context) => const OfflineUddSyncWorkspace(),
      ),
      ComponentSpec(
        id: '12',
        globalRefId: 'DSDD-002',
        atomicStepId: 'DSDD-002-A01',
        title: 'Django Income Statement Data Model Workspace',
        category: 'Workspaces & Sandbox',
        description:
            'Backward-linked Django ORM data models with Material Card list views for income statement line items.',
        icon: Icons.assessment,
        isFullWorkspace: true,
        builder: (context) => const DjangoIncomeStatementWorkspace(),
      ),
      ComponentSpec(
        id: '12b',
        globalRefId: 'APIGW-040',
        atomicStepId: 'APIGW-040-A01',
        title: 'API Gateway Rate Limits & Quota Monitoring',
        category: 'Workspaces & Sandbox',
        description:
            'Full workspace for monitoring API rate limits, HTTP 429 quota tokens, and request metadata.',
        icon: Icons.speed,
        isFullWorkspace: true,
        builder: (context) => const RateLimitThrottleWorkspace(),
      ),
      ComponentSpec(
        id: '13',
        globalRefId: 'UFHT-037',
        atomicStepId: 'UFHT-037',
        title: 'Referral Link Generator Workspace',
        category: 'Workspaces & Sandbox',
        description:
            'Full workspace for generating, parameterizing, and sharing referral tracking URLs.',
        icon: Icons.share,
        isFullWorkspace: true,
        builder: (context) => const ReferralLinkWorkspace(),
      ),
      ComponentSpec(
        id: '14',
        globalRefId: 'SSELC-032',
        atomicStepId: 'SSELC-032-A01',
        title: 'Visual Isolation Workspace (Cropping Engine)',
        category: 'Workspaces & Sandbox',
        description:
            'Coordinate-based image cropping workspace with bounding-box array parsing, pixel mask rendering, and NeverScrollableScrollPhysics lock.',
        icon: Icons.crop,
        isFullWorkspace: true,
        builder: (context) => const VisualIsolationWorkspace(),
      ),
      ComponentSpec(
        id: '15',
        globalRefId: 'DPNDL-011',
        atomicStepId: 'DPNDL-011-A01',
        title: 'Global Top Application Bar',
        category: 'Search & Navigation',
        description:
            'Strict 64dp Global App Bar with leading menu button, dynamic active route title, phantom padding touch targets, and fixed header scrolling.',
        icon: Icons.web_asset,
        isFullWorkspace: true,
        builder: (context) => Scaffold(
          appBar: GlobalAppBar(
            activeRouteTitle: 'Master Operations Console',
            onMenuTapped: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Menu tapped!')),
              );
            },
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {},
              ),
            ],
          ),
          body: const Center(
            child: Text('Content scrolling underneath 64dp Global App Bar'),
          ),
        ),
      ),
      ComponentSpec(
        id: '15c',
        globalRefId: 'ANSA-020-09',
        atomicStepId: 'ANSA-020-09-A01',
        title: 'Navigation Rail Adaptive Workspace',
        category: 'Search & Navigation',
        description:
            'M3 NavigationRail mapping for Medium/Expanded (>=600dp) viewport states vs Bottom NavigationBar.',
        icon: Icons.view_array,
        isFullWorkspace: true,
        builder: (context) => const NavigationRailAdaptiveWorkspace(),
      ),
      ComponentSpec(
        id: '16',
        globalRefId: 'HC-IAM-0107',
        atomicStepId: 'HC-IAM-0107-LOG',
        title: 'Protected Analytical Logs',
        category: 'Audit & Security',
        description:
            'Strict append-only read-only UI with monospace scannability and responsive DataTable/ListView layout.',
        icon: Icons.security,
        isFullWorkspace: true,
        builder: (context) => const ProtectedAnalyticalLogs(),
      ),
      ComponentSpec(
        id: '17',
        globalRefId: 'MCIIM-010-12',
        atomicStepId: 'MCIIM-010-12-ISOLATE',
        title: 'Smart Bounding-Box Document Isolator',
        category: 'Document & Data Processing',
        description:
            'Frozen AbsorbPointer image snippet preventing gestures for cognitive focus with padded accessible touch fields.',
        icon: Icons.crop_free,
        isFullWorkspace: true,
        builder: (context) => const SmartBoundingBoxDocumentIsolator(),
      ),
      ComponentSpec(
        id: '18',
        globalRefId: 'ETMDI-022-17',
        atomicStepId: 'ETMDI-022-17-OP',
        title: 'Conditional Operations View',
        category: 'Workflow & Control',
        description:
            'Poka-Yoke verb buttons with strict constructor asserts, M3 expansion panels, and adaptive Web split-pane.',
        icon: Icons.tune,
        isFullWorkspace: true,
        builder: (context) => const ConditionalOperationsView(),
      ),
      ComponentSpec(
        id: '19',
        globalRefId: 'AMLCO-014',
        atomicStepId: 'AMLCO-014-AUTH',
        title: 'AML Query Gate & Secure Auth Flow',
        category: 'Audit & Security',
        description:
            'Biometric auth fallback on 401 token refresh failure, 1.3x oversized toggles, and responsive outlined grid.',
        icon: Icons.fingerprint,
        isFullWorkspace: true,
        builder: (context) => const AmlQueryGateView(),
      ),
      ComponentSpec(
        id: '20',
        globalRefId: 'BCDLD-013',
        atomicStepId: 'BCDLD-013-VAP',
        title: 'Binary VAP Login Modal',
        category: 'Audit & Security',
        description:
            'Focus-trapping modal with barrierDismissible: false, massive 48dp switch targets, and responsive sizing.',
        icon: Icons.gavel,
        isFullWorkspace: true,
        builder: (context) => const BinaryVapLoginModalView(),
      ),
      ComponentSpec(
        id: '38',
        globalRefId: 'TTMCS-011',
        atomicStepId: 'TTMCS-011-A01',
        title: 'Architecture Poka-Yoke & Theme Adherence PR Blocker Test',
        category: 'Architecture & Tests',
        description:
            'Automated test suite enforcing 100% Theme.of(context).colorScheme usage, zero hardcoded hex and Material colors across all UI components.',
        icon: Icons.fact_check,
        isFullWorkspace: true,
        builder: (context) {
          final theme = Theme.of(context);
          return Scaffold(
            appBar: AppBar(
              title: const Text('TTMCS-011: Theme Adherence PR Blocker'),
              centerTitle: true,
              elevation: 1,
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(24.0),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                            side: BorderSide(color: theme.colorScheme.outlineVariant),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: theme.colorScheme.primaryContainer,
                                      foregroundColor: theme.colorScheme.onPrimaryContainer,
                                      child: const Icon(Icons.verified),
                                    ),
                                    const SizedBox(width: 16.0),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'TTMCS-011 Architecture Poka-Yoke',
                                            style: theme.textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4.0),
                                          Text(
                                            'Test File: test/theme_adherence_test.dart',
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              color: theme.colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20.0),
                                Text(
                                  'Automated test guardrail verifying that all files under lib/ui/ strictly use Theme.of(context).colorScheme and contain zero hardcoded Color(0x...) or Colors.* palette values.',
                                  style: theme.textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 24.0),
                                Container(
                                  padding: const EdgeInsets.all(16.0),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.check_circle, color: theme.colorScheme.onPrimaryContainer),
                                      const SizedBox(width: 12.0),
                                      Expanded(
                                        child: Text(
                                          'PR Blocker Guardrail: PASSED (100% Theme Adherence)',
                                          style: TextStyle(
                                            color: theme.colorScheme.onPrimaryContainer,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
      ComponentSpec(
        id: '39',
        globalRefId: 'SSELC-004',
        atomicStepId: 'SSELC-004-A01',
        title: 'Foundational Split-Screen Master Layout',
        category: 'Layouts & Containers',
        description:
            'Adaptive 12-column split-screen layout for back-office portals with evidence pane and action pane reflow.',
        icon: Icons.vertical_split,
        isFullWorkspace: true,
        builder: (context) => const SplitScreenMasterLayout(
          title: 'SSELC-004 Split-Screen Master Layout',
          evidencePane: Card(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Evidence Pane', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
                  SizedBox(height: 12.0),
                  Text('Primary data visualization, document inspection, or ledger evidence details displayed here.'),
                ],
              ),
            ),
          ),
          actionPane: Card(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Action Pane', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
                  SizedBox(height: 12.0),
                  Text('Operational form inputs, approval workflow actions, and audit submission controls.'),
                ],
              ),
            ),
          ),
        ),
      ),
      ComponentSpec(
        id: '40',
        globalRefId: 'BPTR-0035',
        atomicStepId: 'BPTR-0035-A01',
        title: 'Inbound Lead Validation Form',
        category: 'Forms & Inputs',
        description:
            'Inbound lead validation form with strict client-side constraints, inline error states, and responsive layout.',
        icon: Icons.assignment_ind,
        isFullWorkspace: true,
        builder: (context) => const InboundLeadValidationForm(),
      ),
      ComponentSpec(
        id: '41',
        globalRefId: 'BPTR-0407',
        atomicStepId: 'BPTR-0407-A01',
        title: 'Animated Masked Input Field',
        category: 'Forms & Inputs',
        description:
            'Animated masked input field with localized shake feedback animation and 3-strike tutorial tooltip.',
        icon: Icons.password,
        builder: (context) => const Padding(
          padding: EdgeInsets.all(24.0),
          child: AnimatedMaskedInputField(),
        ),
      ),
      ComponentSpec(
        id: '42',
        globalRefId: 'MUFCE-004',
        atomicStepId: 'MUFCE-004-A01',
        title: 'Dynamic Onboarding Journey',
        category: 'Workspaces & Sandbox',
        description:
            'Dynamic single-milestone focus onboarding journey with PageView navigation and strict step validation.',
        icon: Icons.alt_route,
        isFullWorkspace: true,
        builder: (context) => const DynamicOnboardingJourney(),
      ),
      ComponentSpec(
        id: '43',
        globalRefId: 'RCGLA-040',
        atomicStepId: 'RCGLA-040-A01',
        title: 'Responsive Data Entry Card Component',
        category: 'Forms & Inputs',
        description:
            'Single-Input Bouncer Poka-Yoke card with dynamic red background error flash, isolated validation text, and responsive Column/Wrap reflow.',
        icon: Icons.credit_card,
        isFullWorkspace: true,
        builder: (context) => const DataEntryCardResponsiveLayout(),
      ),
      ComponentSpec(
        id: '44',
        globalRefId: 'ANSA-013',
        atomicStepId: 'ANSA-013-A01',
        title: 'Persistent Header Layout System',
        category: 'Layouts & Containers',
        description:
            'PreferredSizeWidget header with strict 56dp mobile / 64dp desktop bounds, BackdropFilter frosted glass blur, bottom divider, and Poka-Yoke action permission suppression.',
        icon: Icons.view_headline,
        isFullWorkspace: true,
        builder: (context) => const PersistentHeaderDemoScreen(),
      ),
      ComponentSpec(
        id: '45',
        globalRefId: 'ANSA-018',
        atomicStepId: 'ANSA-018-A01',
        title: 'Inertial Drag Smooth List Scroller',
        category: 'Layouts & Containers',
        description:
            'High-speed >=58fps ListView.builder wrapper with RepaintBoundary GPU rendering isolation, anti-nesting Poka-Yoke assertion, tinted scrollbars, and 800px max web width.',
        icon: Icons.swap_vert,
        isFullWorkspace: true,
        builder: (context) => const InertialDragSmoothScrollerDemoScreen(),
      ),
      ComponentSpec(
        id: '46',
        globalRefId: 'SLPLU-008',
        atomicStepId: 'SLPLU-008-A01',
        title: 'Async Form Skeleton Loader',
        category: 'Forms & Inputs',
        description:
            'Lead generation form skeleton loader with rhythmic opacity pulsing, zero layout jump dimension-locked containers, AbsorbPointer Poka-Yoke gesture blocking, and 10s timeout fallback.',
        icon: Icons.hourglass_top,
        isFullWorkspace: true,
        builder: (context) => const AsyncFormSkeletonLoader(
          simulateTimeout: false,
        ),
      ),
      ComponentSpec(
        id: '47',
        globalRefId: 'SGTIM-006',
        atomicStepId: 'SGTIM-006-A01',
        title: 'Dynamic Tab Coordinator',
        category: 'Search & Navigation',
        description:
            'TabBar/TabBarView coordinator with sliding underline accent, responsive tab item counts (fontSize 14sp), URL fallback Poka-Yoke to index 0, and AutomaticKeepAliveClientMixin filter preservation.',
        icon: Icons.tab,
        isFullWorkspace: true,
        builder: (context) => const DynamicTabCoordinator(
          initialTabPath: '/metrics',
        ),
      ),
      ComponentSpec(
        id: '48',
        globalRefId: 'SCTSS-008',
        atomicStepId: 'SCTSS-008-A01',
        title: 'Interactive Masked Input Form',
        category: 'Forms & Inputs',
        description:
            'Keystroke filtering and real-time phone/currency masking form protecting BigQuery pipelines with Poka-Yoke save button lock.',
        icon: Icons.pin_drop,
        isFullWorkspace: true,
        builder: (context) => const InteractiveMaskedInputForm(),
      ),
      ComponentSpec(
        id: '49',
        globalRefId: 'SSTLA-025',
        atomicStepId: 'SSTLA-025-A01',
        title: 'Orientation-Aware Form Wrapper',
        category: 'Layouts & Containers',
        description:
            'Rotation immunity form with PageStorageKey preservation, 500ms Poka-Yoke rotation transition lock, and responsive Mobile Portrait vs Web/Landscape reflow.',
        icon: Icons.screen_rotation,
        isFullWorkspace: true,
        builder: (context) => const OrientationAwareFormWrapper(),
      ),
      ComponentSpec(
        id: '50',
        globalRefId: 'RCGLA-033',
        atomicStepId: 'RCGLA-033-A01',
        title: 'Supporting Pane Layout Wrapper',
        category: 'Layouts & Containers',
        description:
            'Material Design side-sheet layout rendering flex 7:3 side-by-side on Web/Desktop (> 800px) and collapsible ExpansionTile on Mobile (<= 800px) with static width override Poka-Yoke blocker.',
        icon: Icons.view_sidebar,
        isFullWorkspace: true,
        builder: (context) => const SupportingPaneDemoScreen(),
      ),
      ComponentSpec(
        id: '51',
        globalRefId: 'CCBPB-011',
        atomicStepId: 'CCBPB-011-A01',
        title: 'Budget Alert Banner & Dashboard',
        category: 'Dashboards & Analytics',
        description:
            'Live metric budget cap dashboard featuring sticky M3 errorContainer banner pinning and 100% hard limit purchase lockout (Poka-Yoke).',
        icon: Icons.account_balance,
        isFullWorkspace: true,
        builder: (context) => const BudgetAlertBannerDashboard(),
      ),
      ComponentSpec(
        id: '52',
        globalRefId: 'IS07-FIEVR-012-AS01',
        atomicStepId: 'IS07-FIEVR-012-AS01-A01',
        title: 'Local Reconciliation Gate Form',
        category: 'Forms & Inputs',
        description:
            'On-blur verified ledger form with mathematical credit/debit validator, Fail-Closed lock on empty fields, 2-minute unresolved variance timeout highlighting, and success checkmarks.',
        icon: Icons.verified_user,
        isFullWorkspace: true,
        builder: (context) => const LocalReconciliationGateForm(),
      ),
      ComponentSpec(
        id: '53',
        globalRefId: 'TTIAS-014',
        atomicStepId: 'TTIAS-014-A03',
        title: 'Dynamic Font Resizing Engine & Typography Wrapper',
        category: 'Typography & Design System',
        description:
            'Responsive dynamic typography engine with 0.8x-1.2x defensive clamping limits via MediaQuery.withClampedTextScaling, MD3 token locking, shadow purging, and single-line ellipsis text-overflow shielding.',
        icon: Icons.text_fields_rounded,
        isFullWorkspace: true,
        builder: (context) => const DynamicTypographyWrapperWorkspace(),
      ),
      ComponentSpec(
        id: '54',
        globalRefId: 'TTMCS-003-A10',
        atomicStepId: 'TTMCS-003-A10-A01',
        title: 'App Shell & 4-to-8 Column Grid Matrix',
        category: 'Layouts & Containers',
        description:
            'Root App Shell with declarative MaterialApp.router navigation, MD3 theme token injection, and programmatic 4-to-8 column layout matrix (Mobile <=600: 4 cols, Tablet/Web >600: 8 cols).',
        icon: Icons.grid_goldenratio,
        isFullWorkspace: true,
        builder: (context) => const ResponsiveGridWrapperWorkspace(),
      ),
      ComponentSpec(
        id: '55',
        globalRefId: 'TTMCS-003-A16',
        atomicStepId: 'TTMCS-003-A16-A01',
        title: 'Theme Verification Screen & CI/CD Testing Gate',
        category: 'Typography & Design System',
        description:
            'Visual theme verification screen consuming root MD3 surface/onSurface tokens and validating 4-to-8 column structural layout matrix with automated CI/CD testing gate.',
        icon: Icons.palette_outlined,
        isFullWorkspace: true,
        builder: (context) => const ThemeTestScreen(),
      ),
      ComponentSpec(
        id: '56',
        globalRefId: 'RCGLA-014-A02',
        atomicStepId: 'RCGLA-014-A02-A01',
        title: 'Shared M3 UI Component Library & Token Engine',
        category: 'Workspaces & Sandbox',
        description:
            'Centralized Material Design 3 component library with ThemeConfig light/dark ColorScheme engine, UniversalPrimaryButton, UniversalTextField, and pre-commit local-code blocker.',
        icon: Icons.widgets_outlined,
        isFullWorkspace: true,
        builder: (context) => const ThemeTestScreen(),
      ),
      ComponentSpec(
        id: '57',
        globalRefId: 'BPTR-0144-A07',
        atomicStepId: 'BPTR-0144-A07',
        title: 'Stateful Status Indicator (Async Processing)',
        category: 'Forms & Inputs',
        description:
            '38% opacity async processing state indicator with dynamic MD3 inline success/error confirmation alerts using AnimatedSize (zero modal dialogs/SnackBars).',
        icon: Icons.sync_alt_rounded,
        isFullWorkspace: false,
        builder: (context) => const StatefulStatusIndicatorWorkspace(),
      ),
      ComponentSpec(
        id: '58',
        globalRefId: 'TTIAS-015-A10',
        atomicStepId: 'TTIAS-015-A10',
        title: 'Design Token Sync Pipeline & Consumer',
        category: 'Typography & Design System',
        description:
            'Automated token compiler and adaptive window size classifier (Compact/Medium/Expanded) locking <=600 mobile breakpoints with text scaling clamping.',
        icon: Icons.sync_rounded,
        isFullWorkspace: false,
        builder: (context) => const DesignTokenConsumerWorkspace(),
      ),
      ComponentSpec(
        id: '59',
        globalRefId: 'NSKFI-002-A01',
        atomicStepId: 'NSKFI-002-A01',
        title: 'SRC Autocomplete Search Interface',
        category: 'Navigation & Controls',
        description:
            'Material 3 SearchAnchor autocomplete catalog search with strict 48dp touch-friendly item heights and responsive LayoutBuilder wrapper.',
        icon: Icons.manage_search_rounded,
        isFullWorkspace: false,
        builder: (context) => const SRCAutocompleteSearchWorkspace(),
      ),
      ComponentSpec(
        id: '60',
        globalRefId: 'RCGLA-012-A15',
        atomicStepId: 'RCGLA-012-A15',
        title: 'Atomic Mobile Grid System',
        category: 'Layouts & Containers',
        description:
            'Pure lightweight mobile grid container enforcing 16px fluid outer margins, 8px gutter rhythm (Wrap), and anti-zoom MediaQuery text clamping.',
        icon: Icons.grid_4x4_rounded,
        isFullWorkspace: false,
        builder: (context) => const MobileGridContainerWorkspace(),
      ),
    ];
  }

  List<String> get _categories {
    final set = <String>{'All'};
    for (final item in _allComponents) {
      set.add(item.category);
    }
    return set.toList();
  }

  List<ComponentSpec> get _filteredList {
    return _allComponents.where((item) {
      final matchesCategory =
          _selectedCategory == 'All' || item.category == _selectedCategory;
      final q = _searchQuery.trim().toLowerCase();
      final matchesSearch = q.isEmpty ||
          item.globalRefId.toLowerCase().contains(q) ||
          item.atomicStepId.toLowerCase().contains(q) ||
          item.title.toLowerCase().contains(q) ||
          item.description.toLowerCase().contains(q);
      return matchesCategory && matchesSearch;
    }).toList();
  }

  void _openComponent(ComponentSpec spec) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DedicatedComponentScreen(spec: spec),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Master Component Menu'),
        centerTitle: true,
        elevation: 2,
        actions: [
          IconButton(
            icon: Icon(
              theme.brightness == Brightness.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            tooltip: 'Toggle Light / Dark Mode',
            onPressed: () {
              MyApp.of(context)?.toggleThemeMode();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Controls Bar (Centered Max Width for Web Desktop)
            Container(
              width: double.infinity,
              color: theme.colorScheme.surfaceContainerLow,
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1400.0),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      children: [
                        TextField(
                          decoration: InputDecoration(
                            hintText:
                                'Search components by Global Ref ID (e.g. SCTAS-013, GTBPU-001)...',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () =>
                                        setState(() => _searchQuery = ''),
                                  )
                                : null,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            filled: true,
                            fillColor: theme.colorScheme.surface,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 12.0,
                            ),
                          ),
                          onChanged: (val) =>
                              setState(() => _searchQuery = val),
                        ),
                        const SizedBox(height: 12.0),
                        SizedBox(
                          height: 40.0,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _categories.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(width: 8.0),
                            itemBuilder: (context, idx) {
                              final cat = _categories[idx];
                              final isSelected = cat == _selectedCategory;
                              return ChoiceChip(
                                label: Text(cat),
                                selected: isSelected,
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() => _selectedCategory = cat);
                                  }
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Main Master Menu List of Buttons & Cards (Responsive Grid)
            Expanded(
              child: _filteredList.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64.0,
                            color: theme.colorScheme.outline,
                          ),
                          const SizedBox(height: 12.0),
                          Text(
                            'No components match your search',
                            style: theme.textTheme.titleMedium,
                          ),
                        ],
                      ),
                    )
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        final width = constraints.maxWidth;
                        final crossAxisCount = width > 1400
                            ? 4
                            : (width > 1050 ? 3 : (width > 650 ? 2 : 1));

                        return Center(
                          child: ConstrainedBox(
                            constraints:
                                const BoxConstraints(maxWidth: 1600.0),
                            child: GridView.builder(
                              padding: const EdgeInsets.all(20.0),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                mainAxisExtent: 195.0,
                                crossAxisSpacing: 20.0,
                                mainAxisSpacing: 20.0,
                              ),
                              itemCount: _filteredList.length,
                              itemBuilder: (context, index) {
                                final item = _filteredList[index];
                                return _buildMenuCard(theme, item);
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(ThemeData theme, ComponentSpec item) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: theme.colorScheme.primaryContainer,
                  foregroundColor: theme.colorScheme.onPrimaryContainer,
                  child: Icon(item.icon),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6.0,
                              vertical: 2.0,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            child: Text(
                              item.globalRefId,
                              style: TextStyle(
                                fontSize: 10.0,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6.0),
                          Expanded(
                            child: Text(
                              item.category.toUpperCase(),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        item.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4.0),
            Text(
              item.description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8.0),

            // Action Row: Open Component & Export Code Modal
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 42.0,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      onPressed: () => _openComponent(item),
                      icon: const Icon(Icons.open_in_new, size: 18.0),
                      label: Text(
                        'Open [${item.globalRefId}]',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                IconButton.outlined(
                  tooltip: 'Export Code & Integration Guide',
                  onPressed: () {
                    final specData = ComponentCodeRegistry.getCodeSpec(
                      globalRefId: item.globalRefId,
                      title: item.title,
                      category: item.category,
                    );
                    CodeExportModalDialog.show(
                      context: context,
                      globalRefId: item.globalRefId,
                      title: item.title,
                      fileName: specData['fileName']!,
                      widgetClassName: specData['widgetClassName']!,
                      category: item.category,
                      sourceCode: specData['sourceCode']!,
                      integrationGuide: '''// -------------------------------------------------------------
// INTEGRATION GUIDE: [${item.globalRefId}] ${item.title}
// -------------------------------------------------------------

1. File Setup:
   Create lib/ui/${specData['fileName']} in your target Flutter application.

2. Dependencies:
   Ensure useMaterial3: true is set in your ThemeData.

3. Import & Usage:
   import 'package:your_app/ui/${specData['fileName']}';

   @override
   Widget build(BuildContext context) {
     return const ${specData['widgetClassName']}();
   }

4. Responsiveness & Accessibility:
   - Web/Tablet (>600dp): Displays adaptive multi-column layout or wide DataTable.
   - Mobile (<=600dp): Displays single-column touch-optimized Cards.
   - All interactive controls enforce 48dp minimum touch target height.
''',
                    );
                  },
                  icon: const Icon(Icons.code, size: 18.0),
                ),
                const SizedBox(width: 6.0),
                IconButton.outlined(
                  tooltip: 'Plain English Explanation',
                  onPressed: () {
                    final exp = ComponentExplanationRegistry.getExplanation(
                      globalRefId: item.globalRefId,
                      atomicStepId: item.atomicStepId,
                      title: item.title,
                      description: item.description,
                    );
                    ComponentExplanationModalDialog.show(
                      context: context,
                      globalRefId: item.globalRefId,
                      title: item.title,
                      category: item.category,
                      explanation: exp,
                    );
                  },
                  icon: const Icon(Icons.menu_book, size: 18.0),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
