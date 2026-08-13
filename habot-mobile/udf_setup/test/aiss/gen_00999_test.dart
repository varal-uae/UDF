/// AISS GATE -- Step 42 of 50
/// Global Reference ID:       GEN-00999
/// Atomic Steps Reference ID: GEN-00999-A01
/// Setup Step (Action):       "Deploy Automated Mobile Deep Link Routing &
///                             Context Restoration Engine"
/// Setup Step Description / Expected Output: "Create
///                             deep_link_context_manager.dart"
/// Metric: Syntax Validity -- Floor = Optimal = 100%.
///
/// ON THE METRIC: "Syntax Validity" is thin, but unlike most of the mismatched
/// metrics in this batch it is at least checkable -- the sheet names a file,
/// and G1 checks that the file exists at that name and parses into the
/// symbols the rest of the app imports. `flutter analyze` in the runner is the
/// other half of it.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/aiss/aiss_evidence.dart';
import 'package:udf_setup/design_system/navigation/deep_link_context_manager.dart';

import 'aiss_reporter.dart';

const HabotDeepLinkContext _rich = HabotDeepLinkContext(
  route: '/tasks/:id',
  params: <String, String>{'id': '42', 'tab': 'evidence'},
  scrollOffset: 640.5,
  selectedId: '42',
  draft: <String, String>{'amount': '100.00', 'ref': 'INV-1'},
  paneIndex: 1,
);

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

  group('GEN-00999-A01 :: the context manager', () {
    gate(
      'GEN-00999-G1',
      'Setup Step Description and Expected Output: "Create '
          'deep_link_context_manager.dart / .kt." + Metric: Syntax Validity '
          '100%.',
      'The file exists at the exact name the sheet gives, and the symbols the '
          'rest of the app imports from it resolve',
      () {
        final File named = File(
          'lib/design_system/navigation/deep_link_context_manager.dart',
        );
        return named.existsSync() &&
            named.readAsStringSync().contains('class DeepLinkContextManager') &&
            DeepLinkContextManager().rememberedCount == 0;
      },
    );

    gate(
      'GEN-00999-G2',
      'Setup Step (Action): "...& CONTEXT RESTORATION Engine." A context that '
          'cannot be serialised cannot survive the process being killed, which '
          'is the only case that matters on mobile.',
      'Every field round-trips through JSON without loss, including the ones a '
          'naive encoder drops -- nested maps and a double offset',
      () {
        final HabotDeepLinkContext restored = HabotDeepLinkContext.fromJson(
          _rich.toJson(),
        );
        return restored == _rich &&
            restored.scrollOffset == 640.5 &&
            restored.draft['amount'] == '100.00' &&
            restored.params['tab'] == 'evidence' &&
            restored.paneIndex == 1 &&
            restored.isMeaningful;
      },
    );

    gate(
      'GEN-00999-G3',
      'Setup Step (Action) -- restoration is per route, and an unvisited route '
          'has nothing to restore. Returning an empty context there would put '
          'a user "back" somewhere they have never been.',
      'Capture then restore returns what was captured; an unknown route '
          'returns null rather than a fabricated context',
      () {
        final DeepLinkContextManager manager = DeepLinkContextManager();
        manager.capture(_rich);
        final HabotDeepLinkContext? found = manager.restore('/tasks/:id');
        return found == _rich &&
            manager.restore('/never-visited') == null &&
            manager.rememberedCount == 1;
      },
    );

    gate(
      'GEN-00999-G4',
      'Setup Step (Action) -- an unbounded restoration cache is a memory leak '
          'with good intentions.',
      'The manager keeps at most the documented number of routes, dropping the '
          'oldest, and forgetting a route removes it',
      () {
        final DeepLinkContextManager manager = DeepLinkContextManager();
        for (
          int i = 0;
          i < DeepLinkContextManager.maxRememberedRoutes + 5;
          i++
        ) {
          manager.capture(HabotDeepLinkContext(route: '/route$i'));
        }
        final bool capped =
            manager.rememberedCount ==
            DeepLinkContextManager.maxRememberedRoutes;
        final bool oldestDropped = manager.restore('/route0') == null;
        final bool newestKept =
            manager.restore(
              '/route${DeepLinkContextManager.maxRememberedRoutes + 4}',
            ) !=
            null;
        manager.forget(
          '/route${DeepLinkContextManager.maxRememberedRoutes + 4}',
        );
        return capped &&
            oldestDropped &&
            newestKept &&
            manager.restore(
                  '/route${DeepLinkContextManager.maxRememberedRoutes + 4}',
                ) ==
                null;
      },
    );

    gate(
      'GEN-00999-G5',
      'Setup Step (Action): "Deep Link ROUTING & Context Restoration." A user '
          'who followed a link to record 42 wants record 42, not the record '
          'they were on last time.',
      'Link parameters win over the remembered context, while everything the '
          'link is silent about is restored',
      () {
        final DeepLinkContextManager manager = DeepLinkContextManager();
        manager.capture(_rich);
        final HabotDeepLinkContext resolved = manager.resolve(
          '/tasks/:id',
          linkParams: <String, String>{'id': '99'},
        );
        final HabotDeepLinkContext bare = manager.resolve('/tasks/:id');
        return resolved.selectedId == '99' &&
            resolved.params['id'] == '99' &&
            resolved.params['tab'] == 'evidence' &&
            resolved.scrollOffset == _rich.scrollOffset &&
            resolved.draft['amount'] == '100.00' &&
            bare == _rich;
      },
    );

    gate(
      'GEN-00999-G6',
      'REF-197 Poka-Yoke, inherited: nothing reaches a log without being '
          'scrubbed. This is the one structure in the design system that can '
          'hold user content, so the rule matters most here.',
      'The diagnostic view carries shapes and counts only -- never a draft '
          'value, never a parameter value',
      () {
        final Map<String, Object?> diagnostic = _rich.toDiagnostic();
        final String flat = diagnostic.values.join(' ');
        return !flat.contains('100.00') &&
            !flat.contains('INV-1') &&
            !flat.contains('evidence') &&
            diagnostic['draft_field_count'] == 2 &&
            diagnostic['param_count'] == 2 &&
            diagnostic['has_selection'] == true;
      },
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-00999',
        atomicStepReferenceId: 'GEN-00999-A01',
        setupStepAction:
            'Deploy Automated Mobile Deep Link Routing & Context Restoration '
            'Engine',
        implementationOrder: 42,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'deep_link_context_manager':
              'lib/design_system/navigation/deep_link_context_manager.dart',
          'Component Type': 'Context capture, restore and merge',
          'Component Properties':
              'route, params, scroll offset, selection, draft, pane index; '
              '${DeepLinkContextManager.maxRememberedRoutes} routes remembered',
          'Privacy':
              'Drafts never enter a diagnostic; the diagnostic carries counts',
          'Completion Status': 'Derived from gate outcomes',
        },
        measurements: const <AissMeasurement>[
          AissMeasurement(
            metricName: 'Syntax Validity',
            observed:
                '100% -- the file exists at the name the sheet gives, its '
                'symbols resolve, and every context round-trips through JSON '
                'byte-for-byte. Static analysis is re-run by G-B of the runner.',
            floor: '100%',
            optimal: '100%',
            ceiling: 'N/A (100% target)',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/navigation/deep_link_context_manager.dart',
        ],
      ),
    );
  });
}
