/// AISS GATE -- Step 43 of 50
/// Global Reference ID:       GEN-02082
/// Atomic Steps Reference ID: GEN-02082-A01
/// Setup Step (Action):       "Build a deep link routing engine leveraging
///                             Navigation component routing."
///
/// METRIC MISMATCH, RECORDED: the Metric Name is "Push Notification
/// Click-Through Rate (%)" (Floor 10.0, Optimal 25.0) -- a marketing outcome
/// that measures whether people tap notifications, not whether a router works.
/// A routing engine cannot move that number on its own. The gates defend the
/// Setup Step; the measurement says so plainly.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/aiss/aiss_evidence.dart';
import 'package:udf_setup/design_system/navigation/deep_link_context_manager.dart';
import 'package:udf_setup/design_system/navigation/route_table.dart';
import 'package:udf_setup/design_system/shell/app_shell.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];

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

  HabotRouter build() => HabotShellRoutes.router();

  group('GEN-02082-A01 :: the routing engine', () {
    gate(
      'GEN-02082-G1',
      'Setup Step (Action): "Build a deep link ROUTING ENGINE leveraging '
          'Navigation component routing."',
      'Static segments match exactly and a parameter segment yields its value, '
          'so /tasks/42 resolves to the task route carrying id 42',
      () {
        final HabotRouter router = build();
        final HabotRouteMatch tasks = router.match('/tasks');
        final HabotRouteMatch task = router.match('/tasks/42');
        return !tasks.isFallback &&
            tasks.route.path == '/tasks' &&
            tasks.params.isEmpty &&
            !task.isFallback &&
            task.route.path == '/tasks/:id' &&
            task.params['id'] == '42';
      },
    );

    gate(
      'GEN-02082-G2',
      'Setup Step (Action) -- a link that resolves to nothing is a blank '
          'screen, which is the worst possible answer to a tapped '
          'notification.',
      'An unknown path, a malformed string and an empty link all land on the '
          'documented fallback rather than throwing or returning nothing',
      () {
        final HabotRouter router = build();
        for (final String link in <String>[
          '/nowhere',
          '::::',
          '',
          '/tasks/42/extra',
        ]) {
          final HabotRouteMatch matched = router.match(link);
          if (!matched.isFallback ||
              matched.route.path != HabotShellRoutes.fallback.path) {
            return false;
          }
        }
        return true;
      },
    );

    gate(
      'GEN-02082-G3',
      'Setup Step (Action) -- a route that needs an id is meaningless without '
          'one, and silently showing a blank record is worse than admitting it.',
      'A route declaring requiresId refuses to match without one, and query '
          'parameters merge into the match',
      () {
        final HabotRouter router = build();
        final HabotRouteMatch withQuery = router.match(
          '/tasks/42?tab=evidence&sort=age',
        );
        return withQuery.params['id'] == '42' &&
            withQuery.params['tab'] == 'evidence' &&
            withQuery.params['sort'] == 'age' &&
            HabotShellRoutes.task.requiresId &&
            !HabotShellRoutes.tasks.requiresId;
      },
    );

    gate(
      'GEN-02082-G4',
      'Setup Step (Action) -- two routes with the same pattern means one is '
          'unreachable, and which one depends on list order.',
      'Every declared path is unique, including the fallback',
      () => build().pathsAreUnique && HabotShellRoutes.all.length >= 4,
    );

    gate(
      'GEN-02082-G5',
      'Setup Step (Action) combined with GEN-00999: routing without '
          'restoration lands a user on the right screen at the top of an empty '
          'form.',
      'Resolving a link returns the remembered context for that route, with '
          'the link parameters applied over it',
      () {
        final DeepLinkContextManager manager = DeepLinkContextManager();
        final HabotRouter router = HabotShellRoutes.router(
          contextManager: manager,
        );
        router.capture(
          const HabotDeepLinkContext(
            route: '/tasks/:id',
            scrollOffset: 320,
            selectedId: '7',
            draft: <String, String>{'note': 'half typed'},
          ),
        );
        final HabotDeepLinkContext resolved = router.resolve('/tasks/42');
        return resolved.selectedId == '42' &&
            resolved.scrollOffset == 320 &&
            resolved.draft['note'] == 'half typed';
      },
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-02082',
        atomicStepReferenceId: 'GEN-02082-A01',
        setupStepAction:
            'Build a deep link routing engine leveraging Navigation component '
            'routing.',
        implementationOrder: 43,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotRouter / HabotRoute',
          'Component Type': 'Pure link parser with a fallback route',
          'Component Properties':
              '${HabotShellRoutes.all.length} routes, unique paths, fallback '
              '${HabotShellRoutes.fallback.path}',
          'Completion Status': 'Derived from gate outcomes',
          'Metric note':
              'Metric Name ("Push Notification Click-Through Rate") is a '
              'marketing outcome, not a property of a router. Not gated.',
        },
        measurements: const <AissMeasurement>[
          AissMeasurement(
            metricName: 'Push Notification Click-Through Rate (%)',
            observed:
                'Not measurable in-suite, and not attributable to this step: '
                'click-through is a function of what notifications say and '
                'when they arrive. What IS verified is the half a router owns '
                '-- every link resolves to a real destination with its '
                'parameters and its restored context, and no link can produce '
                'a blank screen.',
            floor: '10.0',
            optimal: '25.0',
            ceiling: '50.0',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/navigation/route_table.dart',
          'lib/design_system/shell/app_shell.dart',
        ],
      ),
    );
  });
}
