/// Registry storing ready-to-copy source code snippets and metadata for all components.
class ComponentCodeRegistry {
  static final Map<String, Map<String, String>> _codeMap = {
    'IRBCA-061': {
      'fileName': 'board_signatory_access_constraint.dart',
      'widgetClassName': 'BoardSignatoryAccessConstraint',
      'sourceCode': '''import 'package:flutter/material.dart';

/// Board Signatory Access Constraint Interface for IRBCA-061.
class BoardSignatoryAccessConstraint extends StatefulWidget {
  const BoardSignatoryAccessConstraint({super.key});

  @override
  State<BoardSignatoryAccessConstraint> createState() =>
      _BoardSignatoryAccessConstraintState();
}

class _BoardSignatoryAccessConstraintState
    extends State<BoardSignatoryAccessConstraint> {
  bool _isAuthorizedSignatory = true;
  bool _isPendingSignature = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;

        return Scaffold(
          floatingActionButton: _isAuthorizedSignatory
              ? (isWide
                  ? FloatingActionButton.extended(
                      onPressed: () {},
                      icon: const Icon(Icons.draw),
                      label: const Text('Approve Resolution'),
                    )
                  : FloatingActionButton(
                      onPressed: () {},
                      child: const Icon(Icons.draw),
                    ))
              : const SizedBox.shrink(), // Poka-Yoke DOM Eradication
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Container(
                  color: _isPendingSignature
                      ? theme.colorScheme.tertiaryContainer
                      : theme.colorScheme.primaryContainer,
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _isPendingSignature ? 'STATUS: PENDING SIGNATURE' : 'STATUS: APPROVED',
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}''',
    },
    'PELCE-019-14': {
      'fileName': 'design_system_merge_dashboard.dart',
      'widgetClassName': 'DesignSystemMergeDashboard',
      'sourceCode': '''import 'package:flutter/material.dart';

enum CompletionStatus { notComplete, partial, complete }

/// Design System Merge Dashboard for PELCE-019-14.
class DesignSystemMergeDashboard extends StatefulWidget {
  const DesignSystemMergeDashboard({super.key});

  @override
  State<DesignSystemMergeDashboard> createState() =>
      _DesignSystemMergeDashboardState();
}

class _DesignSystemMergeDashboardState
    extends State<DesignSystemMergeDashboard> {
  CompletionStatus _completionStatus = CompletionStatus.notComplete;

  @override
  Widget build(BuildContext context) {
    final isUnlocked = _completionStatus == CompletionStatus.complete;

    return Scaffold(
      appBar: AppBar(title: const Text('Design System Merge Dashboard')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                FilledButton(
                  style: FilledButton.styleFrom(
                    minimumSize: Size(isWide ? 400.0 : double.infinity, 56.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100.0), // Pill Shape
                    ),
                  ),
                  onPressed: isUnlocked ? () {} : null, // Completion Enforcer
                  child: const Text('MERGE REPOSITORY'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}''',
    },
    'NLM-APS-003': {
      'fileName': 'enterprise_cmek_security_console.dart',
      'widgetClassName': 'EnterpriseCmekSecurityConsole',
      'sourceCode': '''import 'package:flutter/material.dart';

/// Responsive Enterprise CMEK & Security Console for NLM-APS-003.
class EnterpriseCmekSecurityConsole extends StatefulWidget {
  const EnterpriseCmekSecurityConsole({super.key});

  @override
  State<EnterpriseCmekSecurityConsole> createState() =>
      _EnterpriseCmekSecurityConsoleState();
}

class _EnterpriseCmekSecurityConsoleState
    extends State<EnterpriseCmekSecurityConsole> {
  double _complianceScore = 100.0;

  @override
  Widget build(BuildContext context) {
    final isPass = _complianceScore >= 95.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Card(
                color: isPass ? Colors.green.shade100 : Colors.red.shade100,
                child: ListTile(
                  leading: Icon(isPass ? Icons.verified_user : Icons.gpp_bad,
                      color: isPass ? Colors.green : Colors.red),
                  title: Text(isPass ? 'PASS: 100% Compliant' : 'FAIL: ISO/IEC 27001 Violation'),
                  trailing: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _complianceScore = isPass ? 82.0 : 100.0;
                      });
                    },
                    child: Text(isPass ? 'Test Auto-Rotate' : 'Reset'),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              Card(
                child: SwitchListTile(
                  value: false,
                  onChanged: null, // Poka-Yoke Locked
                  title: const Text('Key Rotation Policy'),
                  subtitle: const Text('Never (Manual Rotation) - Enforced by NotebookLM Enterprise'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}''',
    },
    'PELCE-019-01': {
      'fileName': 'system_verb_button.dart',
      'widgetClassName': 'SystemVerbButton',
      'sourceCode': '''import 'package:flutter/material.dart';

const List<String> kApprovedSystemVerbs = ['SUBMIT', 'AUTHORIZE', 'DELETE', 'AUTHENTICATE', 'EXECUTE'];

/// Pill-shaped English Code (EC) System Verb Button for PELCE-019-01.
class SystemVerbButton extends StatelessWidget {
  SystemVerbButton({
    super.key,
    required this.label,
    required this.onPressed,
  }) : assert(
          kApprovedSystemVerbs.any((v) => label.toUpperCase().startsWith(v)),
          'EC Verb Violation: label must start with one of \$kApprovedSystemVerbs',
        );

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth <= 600;

        return Center(
          child: SizedBox(
            width: isMobile ? double.infinity : 400.0,
            height: 56.0,
            child: FilledButton(
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100.0), // Pill shape
                ),
              ),
              onPressed: onPressed,
              child: Text(label.toUpperCase()),
            ),
          ),
        );
      },
    );
  }
}''',
    },
    'GTBPU-001': {
      'fileName': 'seamless_splash_login_profile_form.dart',
      'widgetClassName': 'SeamlessSplashLoginProfileForm',
      'sourceCode': '''import 'package:flutter/material.dart';

/// State-preserved login & profile setup form with RestorationMixin for GTBPU-001.
class SeamlessSplashLoginProfileForm extends StatefulWidget {
  const SeamlessSplashLoginProfileForm({super.key});

  @override
  State<SeamlessSplashLoginProfileForm> createState() =>
      _SeamlessSplashLoginProfileFormState();
}

class _SeamlessSplashLoginProfileFormState
    extends State<SeamlessSplashLoginProfileForm> with RestorationMixin {
  final RestorableTextEditingController _emailController =
      RestorableTextEditingController();
  final RestorableTextEditingController _passwordController =
      RestorableTextEditingController();

  @override
  String? get restorationId => 'seamless_splash_form_restoration';

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_emailController, 'email_text');
    registerForRestoration(_passwordController, 'password_text');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 850;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: isWide
              ? Row(
                  children: [
                    Expanded(child: _buildHeroBranding(theme)),
                    const SizedBox(width: 32.0),
                    Expanded(child: _buildFormCard(theme)),
                  ],
                )
              : Column(
                  children: [
                    _buildHeroBranding(theme),
                    const SizedBox(height: 24.0),
                    _buildFormCard(theme),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildHeroBranding(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(32.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(24.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.rocket_launch, size: 56.0, color: theme.colorScheme.primary),
          const SizedBox(height: 16.0),
          Text(
            'Welcome to Perimeter Gateway',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            'Seamless splash-to-interactive state restoration with 48px touch targets.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard(ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextFormField(
              controller: _emailController.value,
              decoration: const InputDecoration(
                labelText: 'Email Address',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: _passwordController.value,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 24.0),
            ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48.0),
              child: FilledButton(
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48.0),
                ),
                onPressed: () {},
                child: const Text('Sign In & Restore State'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}''',
    },
    'MCCEA-001': {
      'fileName': 'satisfaction_analytics_engine_dashboard.dart',
      'widgetClassName': 'SatisfactionAnalyticsEngineDashboard',
      'sourceCode': '''import 'package:flutter/material.dart';

/// Real-time Satisfaction Analytics & Churn Engine Dashboard for MCCEA-001.
class SatisfactionAnalyticsEngineDashboard extends StatelessWidget {
  const SatisfactionAnalyticsEngineDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                color: theme.colorScheme.surfaceContainerHigh,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Text(
                        'Satisfaction & Churn Analytics Stream',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12.0),
                      Text(
                        'Pub/Sub StreamBuilder with adaptive LayoutBuilder matrix.',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              if (isWide)
                Row(
                  children: [
                    Expanded(child: _buildMetricCard(theme, 'CSAT Score', '94.2%', Colors.green)),
                    const SizedBox(width: 16.0),
                    Expanded(child: _buildMetricCard(theme, 'Churn Risk', '1.8%', Colors.orange)),
                  ],
                )
              else ...[
                _buildMetricCard(theme, 'CSAT Score', '94.2%', Colors.green),
                const SizedBox(height: 12.0),
                _buildMetricCard(theme, 'Churn Risk', '1.8%', Colors.orange),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetricCard(ThemeData theme, String title, String val, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8.0),
            Text(val, style: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}''',
    },
    'OPMV-002': {
      'fileName': 'feedback_ranking_sync_ledger.dart',
      'widgetClassName': 'FeedbackRankingSyncLedger',
      'sourceCode': '''import 'package:flutter/material.dart';

/// Responsive Points Ledger for OPMV-002.
class FeedbackRankingSyncLedger extends StatelessWidget {
  const FeedbackRankingSyncLedger({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;

        if (isWide) {
          return DataTable(
            columns: const [
              DataColumn(label: Text('User')),
              DataColumn(label: Text('Points')),
              DataColumn(label: Text('Tier')),
            ],
            rows: const [
              DataRow(cells: [DataCell(Text('Alex')), DataCell(Text('1250')), DataCell(Text('Gold'))]),
              DataRow(cells: [DataCell(Text('Sophia')), DataCell(Text('840')), DataCell(Text('Silver'))]),
            ],
          );
        } else {
          return ListView(
            shrinkWrap: true,
            children: const [
              Card(child: ListTile(title: Text('Alex'), subtitle: Text('1250 pts - Gold'))),
              Card(child: ListTile(title: Text('Sophia'), subtitle: Text('840 pts - Silver'))),
            ],
          );
        }
      },
    );
  }
}''',
    },
    'TECH-ENG-005': {
      'fileName': 'bigquery_streaming_validation_dashboard.dart',
      'widgetClassName': 'BigQueryStreamingValidationDashboard',
      'sourceCode': '''import 'package:flutter/material.dart';

/// BigQuery Streaming Validation Dashboard for TECH-ENG-005.
class BigQueryStreamingValidationDashboard extends StatelessWidget {
  const BigQueryStreamingValidationDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BigQuery Streaming Schema Validation')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Card(
                  color: Colors.green.shade100,
                  child: const ListTile(
                    leading: Icon(Icons.check_circle, color: Colors.green),
                    title: Text('Pipeline Health: PASS'),
                  ),
                ),
                const SizedBox(height: 16.0),
                if (isWide)
                  DataTable(
                    columns: const [
                      DataColumn(label: Text('Event Name')),
                      DataColumn(label: Text('Latency (ms)')),
                      DataColumn(label: Text('Status')),
                    ],
                    rows: const [
                      DataRow(cells: [DataCell(Text('user_signup')), DataCell(Text('142 ms')), DataCell(Text('Valid'))]),
                    ],
                  )
                else
                  const Card(child: ListTile(title: Text('user_signup'), trailing: Text('142 ms'))),
              ],
            ),
          );
        },
      ),
    );
  }
}''',
    },
    'TECH-ENG-023': {
      'fileName': 'universal_engineering_notification_center.dart',
      'widgetClassName': 'UniversalEngineeringNotificationCenter',
      'sourceCode': '''import 'package:flutter/material.dart';

/// Universal Engineering Notification Center for TECH-ENG-023.
class UniversalEngineeringNotificationCenter extends StatelessWidget {
  const UniversalEngineeringNotificationCenter({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;

        if (isWide) {
          return Row(
            children: [
              Expanded(child: Card(child: ListView(children: const [ListTile(title: Text('Server Down'))]))),
              const SizedBox(width: 16.0),
              const Expanded(child: Card(child: Center(child: Text('Alert Detail Pane')))),
            ],
          );
        } else {
          return ListView(
            shrinkWrap: true,
            children: [
              Dismissible(
                key: const Key('alert_1'),
                child: const Card(child: ListTile(title: Text('Server Down (Swipe to Ack)'))),
              ),
            ],
          );
        }
      },
    );
  }
}''',
    },
    'TECH-ENG-038': {
      'fileName': 'cicd_linter_accessibility_dashboard.dart',
      'widgetClassName': 'CicdLinterAccessibilityDashboard',
      'sourceCode': '''import 'package:flutter/material.dart';

/// CI/CD WCAG 2.2 AA Linter Dashboard for TECH-ENG-038.
class CicdLinterAccessibilityDashboard extends StatelessWidget {
  const CicdLinterAccessibilityDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'CI/CD Accessibility Linter Dashboard',
      child: Card(
        color: Theme.of(context).colorScheme.errorContainer,
        child: const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Build Failed: WCAG 2.2 AA Compliance < 100%'),
        ),
      ),
    );
  }
}''',
    },
    'HSCPE-007': {
      'fileName': 'filesystem_tuning_admin_dashboard.dart',
      'widgetClassName': 'FilesystemTuningAdminDashboard',
      'sourceCode': '''import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/filesystem_tuning_admin_dashboard.dart';

// Filesystem Tuning Admin Dashboard Widget for HSCPE-007
class HSCPE007Widget extends StatelessWidget {
  const HSCPE007Widget({super.key});

  @override
  Widget build(BuildContext context) {
    return const FilesystemTuningAdminDashboard();
  }
}''',
    },
    'RCGLA-028': {
      'fileName': 'mobile_surgical_container.dart',
      'widgetClassName': 'MobileSurgicalContainer',
      'sourceCode': '''import 'package:flutter/material.dart';
import 'package:flutter_application_1/habot_design_tokens/layouts/mobile_surgical_container.dart';

// Mobile Surgical Container Widget for RCGLA-028
class RCGLA028Widget extends StatelessWidget {
  const RCGLA028Widget({super.key});

  @override
  Widget build(BuildContext context) {
    return const MobileSurgicalContainer();
  }
}''',
    },
    'BPWSO-007-12': {
      'fileName': 'lineage_graph_terminal_alert_dashboard.dart',
      'widgetClassName': 'LineageGraphTerminalAlertDashboard',
      'sourceCode': '''import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/lineage_graph_terminal_alert_dashboard.dart';

// Lineage Graph & Terminal Alert Dashboard for BPWSO-007-12
class BPWSO00712Widget extends StatelessWidget {
  const BPWSO00712Widget({super.key});

  @override
  Widget build(BuildContext context) {
    return const LineageGraphTerminalAlertDashboard();
  }
}''',
    },
    'USMBL-017': {
      'fileName': 'loading_submit_button_form.dart',
      'widgetClassName': 'LoadingSubmitButtonForm',
      'sourceCode': '''import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/loading_submit_button_form.dart';

// Loading Submit Button & Form Wrapper for USMBL-017
class USMBL017Widget extends StatelessWidget {
  const USMBL017Widget({super.key});

  @override
  Widget build(BuildContext context) {
    return const LoadingSubmitButtonForm();
  }
}''',
    },
    'ARCPE-005-01': {
      'fileName': 'ai_output_analytics_view.dart',
      'widgetClassName': 'AiOutputAnalyticsView',
      'sourceCode': '''import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/ai_output_analytics_view.dart';

// AI Output Analytics View Widget for ARCPE-005-01
class ARCPE00501Widget extends StatelessWidget {
  const ARCPE00501Widget({super.key});

  @override
  Widget build(BuildContext context) {
    return const AiOutputAnalyticsView();
  }
}''',
    },
    'CCPME-002': {
      'fileName': 'multi_child_registration_form.dart',
      'widgetClassName': 'MultiChildRegistrationForm',
      'sourceCode': '''import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/multi_child_registration_form.dart';

// Multi-Child Registration Form Widget for CCPME-002
class CCPME002Widget extends StatelessWidget {
  const CCPME002Widget({super.key});

  @override
  Widget build(BuildContext context) {
    return const MultiChildRegistrationForm();
  }
}''',
    },
  };

  /// Returns metadata & code for global reference ID or generates fallback
  static Map<String, String> getCodeSpec({
    required String globalRefId,
    required String title,
    required String category,
  }) {
    if (_codeMap.containsKey(globalRefId)) {
      return _codeMap[globalRefId]!;
    }

    // Dynamic clean fallback template for any component
    final formattedName = globalRefId.replaceAll('-', '_').toLowerCase();
    final className = globalRefId
        .split('-')
        .map((s) => s.isNotEmpty ? s[0].toUpperCase() + s.substring(1).toLowerCase() : '')
        .join('');

    return {
      'fileName': '${formattedName}_widget.dart',
      'widgetClassName': className,
      'sourceCode': '''import 'package:flutter/material.dart';

/// Standalone Component Widget for [$globalRefId] $title.
class $className extends StatelessWidget {
  const $className({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Chip(
                  label: const Text('$globalRefId'),
                  backgroundColor: theme.colorScheme.primaryContainer,
                ),
                const SizedBox(height: 12.0),
                Text(
                  '$title',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Fully responsive across Web, Tablet, and Mobile viewports.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16.0),
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 48.0),
                  child: FilledButton(
                    onPressed: () {},
                    child: const Text('Execute Component Action'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}''',
    };
  }
}
