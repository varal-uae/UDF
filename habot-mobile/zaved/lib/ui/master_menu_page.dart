import 'package:flutter/material.dart';
import 'asynchronous_consensus_board.dart';
import 'bigquery_streaming_validation_dashboard.dart';
import 'board_signatory_access_constraint.dart';
import 'cicd_linter_accessibility_dashboard.dart';
import 'code_export_modal.dart';
import 'component_code_registry.dart';
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
import 'seamless_splash_login_profile_form.dart';
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
import '../main.dart';
import '../widgets/data_list_wrapper.dart';
import '../widgets/empty_state_boilerplate.dart';
import '../widgets/payment_status_banner.dart';

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
        id: '1',
        globalRefId: 'GTBPU-001',
        atomicStepId: 'GTBPU-001',
        title: 'Seamless Splash-to-Interactive Form',
        category: 'Forms & Inputs',
        description:
            'State-preserved login & profile setup form with RestorationMixin, 48px touch targets, dynamic keyboard inset scrolling, and Poka-Yoke checks.',
        icon: Icons.login,
        isFullWorkspace: true,
        builder: (context) => const SeamlessSplashLoginProfileForm(),
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
        atomicStepId: 'DSDD-002',
        title: 'Rate Limits & Metadata Workspace',
        category: 'Workspaces & Sandbox',
        description:
            'Full workspace for monitoring API rate limits, quota tokens, and request metadata.',
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
        title: 'Visual Isolation Workspace',
        category: 'Workspaces & Sandbox',
        description:
            'Full workspace sandbox for visual boundary checking and responsiveness testing.',
        icon: Icons.aspect_ratio,
        isFullWorkspace: true,
        builder: (context) => const VisualIsolationWorkspace(),
      ),
      ComponentSpec(
        id: '15',
        globalRefId: 'DPNDL-011',
        atomicStepId: 'DPNDL-011-A01',
        title: 'Payload Upload Widget Workspace',
        category: 'Workspaces & Sandbox',
        description:
            'Full workspace widget for payload uploads, progress tracking, and file validation.',
        icon: Icons.cloud_upload,
        isFullWorkspace: true,
        builder: (context) => const PayloadUploadWidget(),
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}
