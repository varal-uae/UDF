/// AISS GATE -- Step 53 of 65
/// Global Reference ID:       LSAV-027
/// Atomic Steps Reference ID: LSAV-027
/// Setup Step (Action):       "Building Mobile-View Shakti Dashboard Widget
///                             Mockups."
/// Setup Step Description:    "Style widget borders to match corporate
///                             Material Design 3 design system tokens."
/// Metric: Design System Component Compliance -- Floor 70% token adherence,
///         Optimal 95%, Ceiling 100%.
///
/// CONTAMINATED ROW, RECORDED. Six columns of this sheet row describe Google
/// Cloud Secret Manager and credential hygiene rather than a dashboard widget:
/// Expected Output ("Terraform scripts provisioning Secret Manager access"),
/// Completion Measures ("Cloud Run instances successfully boot fetching keys
/// at runtime"), Poka-Yoke ("GitHub secret-scanning blocks any commit
/// containing strings that match API key formats"), Decision Before ("Audit
/// all current hardcoded credentials"), Atomic Reusability ("Native GCP Secret
/// Manager API calls") and Mobile App First ("Secures third-party API keys").
///
/// None of those are gated. Three columns are coherent with the Setup Step and
/// are what this suite measures: the Setup Step Description, the Metric, and
/// the Data Collected column ("Token Name; Token Value; Token Type; Colour
/// Values; Typography Settings; Token Application Map").
///
/// This is the worst contamination in any batch so far, and it is recorded
/// here and in the evidence rather than quietly reinterpreted.
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/aiss/aiss_evidence.dart';
import 'package:udf_setup/design_system/charts/habot_charts.dart';
import 'package:udf_setup/design_system/dashboard/kpi_card.dart';
import 'package:udf_setup/design_system/dashboard/widget_token_audit.dart';
import 'package:udf_setup/design_system/surfaces/card_chassis.dart';
import 'package:udf_setup/design_system/tokens/dashboard_tokens.dart';
import 'package:udf_setup/design_system/tokens/shape_tokens.dart';
import 'package:udf_setup/design_system/tokens/surface_tokens.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  HabotTokenAuditResult? audit;

  void gate(String id, String source, String description, bool Function() run) {
    test('[$id] $description', () {
      bool passed = false;
      try {
        passed = run();
        expect(passed, isTrue, reason: '$id failed: $description');
      } finally {
        gates.add(
          AissGate(
            id: id,
            requirementSource: source,
            description: description,
            passed: passed,
          ),
        );
      }
    });
  }

  group('LSAV-027 :: the coherent columns', () {
    gate(
      'LSAV-027-G1',
      'Metric: Design System Component Compliance -- Floor 70%, Optimal 95%, '
          'Ceiling 100% design-token adherence.',
      'All three bands are the sheet\'s own numbers, and they are held in the '
          'audit rather than restated at each call site',
      () =>
          HabotWidgetTokenAudit.floorAdherence == 0.70 &&
          HabotWidgetTokenAudit.optimalAdherence == 0.95 &&
          HabotWidgetTokenAudit.ceilingAdherence == 1.0 &&
          HabotWidgetTokenAudit.floorAdherence <
              HabotWidgetTokenAudit.optimalAdherence,
    );

    gate(
      'LSAV-027-G2',
      'Setup Step Description: "STYLE WIDGET BORDERS to match corporate '
          'Material Design 3 design system tokens."',
      'The border the description names comes from the Step 29 card spec and '
          'the audited colour scheme -- there is no dashboard-specific border '
          'width or radius, which is what "match the design system" means when '
          'it is implemented rather than promised',
      () {
        final List<String> names = HabotWidgetTokenAudit.applicationMap
            .map((HabotTokenApplication a) => a.tokenName)
            .toList();
        return HabotCardSpec.borderWidth == HabotShape.borderWidth &&
            HabotCardSpec.cornerRadius == HabotShape.md &&
            names.contains('HabotCardSpec.borderWidth') &&
            names.contains('HabotCardSpec.cornerRadius') &&
            names.contains('colorScheme.outlineVariant');
      },
    );

    gate(
      'LSAV-027-G3',
      'Data Collected: "Token Name; Token Value; Token Type; Colour Values; '
          'Typography Settings; TOKEN APPLICATION MAP."',
      'The application map is populated rather than declared empty, every '
          'entry names a token, a type and the component that consumes it, and '
          'the types span colour, shape, spacing and typography',
      () {
        final List<HabotTokenApplication> map =
            HabotWidgetTokenAudit.applicationMap;
        if (map.length < 8) {
          return false;
        }
        for (final HabotTokenApplication entry in map) {
          final Map<String, String> record = entry.toRecord();
          if (record.length != 3 ||
              record.values.any((String v) => v.isEmpty)) {
            return false;
          }
        }
        final Set<String> types =
            map.map((HabotTokenApplication a) => a.tokenType).toSet();
        return types.containsAll(<String>{
          'Colour',
          'Shape',
          'Spacing',
          'Typography',
        });
      },
    );
  });

  group('LSAV-027 :: measured adherence', () {
    gate(
      'LSAV-027-G4',
      'Metric: Design System Component Compliance. The number, measured over '
          'the dashboard and chart sources this step is responsible for.',
      'Token adherence across the audited directories is computed from source '
          'and clears the 70% floor -- and the audit names any literal it '
          'finds, so the number is actionable rather than a verdict',
      () {
        audit = HabotWidgetTokenAudit.run();
        return audit!.styledProperties > 0 && audit!.meetsFloor;
      },
    );

    gate(
      'LSAV-027-G5',
      'Metric Optimal: "95% design-token adherence."',
      'Adherence also clears the optimal band, so the dashboard layer is '
          'reported at optimal rather than merely above the floor',
      () {
        audit ??= HabotWidgetTokenAudit.run();
        return audit!.meetsOptimal;
      },
    );

    gate(
      'LSAV-027-G6',
      'A compliance measure that cannot report non-compliance is decoration.',
      'The audit distinguishes its bands: a hypothetical result below 70% '
          'reports "below floor", one between the bands reports "floor", and '
          'the measured result reports its own band honestly',
      () {
        const HabotTokenAuditResult poor = HabotTokenAuditResult(
          styledProperties: 100,
          tokenSourced: 40,
          offenders: <String>['synthetic'],
        );
        const HabotTokenAuditResult middling = HabotTokenAuditResult(
          styledProperties: 100,
          tokenSourced: 80,
          offenders: <String>['synthetic'],
        );
        return !poor.meetsFloor &&
            poor.band == 'below floor' &&
            middling.meetsFloor &&
            !middling.meetsOptimal &&
            middling.band == 'floor';
      },
    );
  });

  group('LSAV-027 :: token drift', () {
    gate(
      'LSAV-027-G7',
      'RCGLA-001 (Step 2) made tokens.json the source of truth. A token layer '
          'that only exists in Dart is a token layer that will drift from the '
          'file the design side reads.',
      'Every dashboard and chart dimension in tokens.json matches its Dart '
          'constant exactly, and both new sections declare which atomic steps '
          'they serve',
      () {
        final Map<String, dynamic> tokens =
            jsonDecode(File('lib/design_system/tokens/tokens.json')
                .readAsStringSync()) as Map<String, dynamic>;
        final Map<String, dynamic> dashboard =
            tokens['dashboard'] as Map<String, dynamic>;
        final Map<String, dynamic> charts =
            tokens['charts'] as Map<String, dynamic>;

        bool matches(num json, double dart) => json.toDouble() == dart;

        return matches(
              dashboard['tile_gutter_dp'] as num,
              HabotDashboardTokens.tileGutter,
            ) &&
            matches(
              dashboard['summary_strip_height_dp'] as num,
              HabotDashboardTokens.summaryStripHeight,
            ) &&
            matches(
              dashboard['skeleton_corner_radius_dp'] as num,
              HabotDashboardTokens.skeletonCornerRadius,
            ) &&
            matches(
              dashboard['chip_height_dp'] as num,
              HabotDashboardTokens.chipHeight,
            ) &&
            matches(
              dashboard['kpi_card_min_height_dp'] as num,
              HabotKpiSpec.minHeight,
            ) &&
            matches(
              dashboard['token_adherence_floor'] as num,
              HabotWidgetTokenAudit.floorAdherence,
            ) &&
            matches(
              charts['stroke_compact_dp'] as num,
              HabotChartStroke.compact,
            ) &&
            matches(
              charts['grid_line_ratio'] as num,
              HabotChartStroke.gridLineRatio,
            ) &&
            matches(
              charts['min_chart_width_dp'] as num,
              HabotChartSpec.minChartWidth,
            ) &&
            charts['max_subdivisions'] == HabotChartGrid.maxSubdivisions &&
            charts['package_name'] == HabotChartsPackage.name &&
            charts['package_path'] == HabotChartsPackage.path &&
            (dashboard['_source'] as String).contains('LSAV-027') &&
            (charts['_source'] as String).contains('LSAV-025') &&
            ((tokens['meta'] as Map<String, dynamic>)['covers_atomic_steps']
                    as List<dynamic>)
                .contains('LSAV-027');
      },
    );
  });

  tearDownAll(() {
    final HabotTokenAuditResult result = audit ?? HabotWidgetTokenAudit.run();
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'LSAV-027',
        atomicStepReferenceId: 'LSAV-027',
        setupStepAction: 'Building Mobile-View Shakti Dashboard Widget '
            'Mockups.',
        implementationOrder: 53,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Token Application Map':
              '${HabotWidgetTokenAudit.applicationMap.length} entries across '
              'colour, shape, spacing and typography',
          'Token Type':
              'Colour, Shape, Spacing, Typography -- all four represented',
          'Component Name': 'HabotWidgetTokenAudit',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'CONTAMINATED ROW -- six columns (Expected Output, Completion '
              'Measures, Poka-Yoke, Decision Before, Atomic Reusability, '
              'Mobile App First) describe GCP Secret Manager and credential '
              'hygiene, not a dashboard widget. Not gated. Only the Setup Step '
              'Description, the Metric and the Data Collected column were used.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Design System Component Compliance',
            observed:
                '${(result.adherence * 100).toStringAsFixed(1)}% -- '
                '${result.tokenSourced} of ${result.styledProperties} styled '
                'properties across '
                '${HabotWidgetTokenAudit.auditedDirectories.join(' and ')} '
                'came from a token. Band: ${result.band}. '
                '${result.offenders.isEmpty ? 'No raw literals found.' : 'Literals: ${result.offenders.join('; ')}'}',
            floor: '70% design-token adherence',
            optimal: '95% design-token adherence',
            ceiling: '100% design-token adherence',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/dashboard/widget_token_audit.dart',
        ],
      ),
    );
  });
}
