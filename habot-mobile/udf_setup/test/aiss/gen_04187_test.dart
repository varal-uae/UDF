/// AISS GATE -- Step 219 of 235
/// Global Reference ID:       GEN-04187
/// Atomic Steps Reference ID: GEN-04187
/// Setup Step (Action): (EMPTY on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Apply the standardization rule: Standardize the
///               <SplitScreenLayout /> Master Component across all web and
///               mobile apps."
/// Metric: Standardization Rule Adherence -- Floor "N/A - Binary Governance
///         Gate", Optimal "100% - Rule Applied Across All In-Scope Assets",
///         Ceiling "N/A - Binary Governance Gate".
///         Complete/Partial/Not Complete.
///
/// REPORTS PARTIAL. A binary governance gate over a scope this repository is
/// half of. The mobile half is verifiable and verified; habot-web is a separate
/// tree nothing here can inspect, and it is named as out of reach rather than
/// counted as conforming.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/layout/pane_split.dart';
import 'package:udf_setup/design_system/layout/split_screen_contract.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  double conformance = 0;

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

  void deferredGate(String id, String source, String description, String why) {
    test('[$id] (DEFERRED) $description', () {
      gates.add(
        AissGate(
          id: id,
          requirementSource: source,
          description: description,
          passed: false,
          deferred: true,
          detail: why,
        ),
      );
      expect(why.isNotEmpty, isTrue);
    });
  }

  group('GEN-04187 :: a contract, not a component', () {
    gate(
      'GEN-04187-G1',
      '"Standardize the SplitScreenLayout Master Component across all web and '
          'mobile apps."',
      'Two codebases in two languages cannot share a widget, so what is '
          'standardised is a contract: six clauses covering pane roles, the '
          'ratio rule, compact behaviour, the minimum extent, where the window '
          'class comes from, and the prop names',
      () =>
          HabotSplitScreenContract.clauses.length == 6 &&
          HabotSplitScreenContract.clauses
                  .map((HabotContractClause c) => c.id)
                  .toSet()
                  .length ==
              6 &&
          HabotSplitScreenContract.clauses.every(
            (HabotContractClause c) => c.statement.length > 60,
          ) &&
          HabotSplitScreenContract.contractNotComponentNote
              .contains('cannot share a widget'),
    );

    gate(
      'GEN-04187-G2',
      '"A clause nothing can check is a sentence in a document."',
      'Five of the six clauses are checkable from this repository and the '
          'sixth -- that both implementations expose the same prop names -- is '
          'marked as not checkable here rather than asserted',
      () =>
          HabotSplitScreenContract.verifiableClauses.length == 5 &&
          HabotSplitScreenContract.unverifiableClauses.length == 1 &&
          HabotSplitScreenContract.unverifiableClauses.single.id == 'SSL-6' &&
          HabotSplitScreenContract.unverifiableClauses.single.statement
              .contains('prop names'),
    );

    gate(
      'GEN-04187-G3',
      'The contract is only worth anything if this repository passes it.',
      'All five checkable clauses hold: pane roles rather than sides, the '
          'ratio from the relation, compact navigating rather than stacking, '
          'the minimum extent enforced at its boundary, and the window class '
          'read from the window',
      () {
        conformance = HabotSplitScreenContract.mobileConformanceRate;
        return HabotSplitScreenContract.mobileConformance.length == 5 &&
            HabotSplitScreenContract.mobileConformance.values
                .every((bool b) => b) &&
            conformance == 1.0 &&
            HabotSplitScreenContract.mobileConformance['SSL-3']! &&
            HabotPaneSplit.presentationFor(
                  HabotPaneRelation.masterDetail,
                  320,
                ) ==
                HabotPanePresentation.navigated;
      },
    );

    gate(
      'GEN-04187-G4',
      'SSL-4: "a pane is never rendered below the declared minimum usable '
          'extent."',
      'The boundary is enforced exactly at the declared value rather than near '
          'it -- one below is refused and the value itself is admitted',
      () =>
          !HabotPaneSplit.paneIsUsable(
            HabotPaneSplit.minimumUsablePaneDp - 1,
          ) &&
          HabotPaneSplit.paneIsUsable(HabotPaneSplit.minimumUsablePaneDp) &&
          HabotPaneSplit.paneIsUsable(
            HabotPaneSplit.minimumUsablePaneDp + 1,
          ),
    );
  });

  group('GEN-04187 :: half the scope', () {
    gate(
      'GEN-04187-G5',
      '"All web and mobile apps" names two codebases.',
      'Both are declared, one is reachable from here and one is not, and the '
          'unreachable one carries the reason rather than an assumption -- so '
          'the scope coverage is a number rather than an oversight',
      () =>
          HabotSplitScreenContract.inScope.length == 2 &&
          HabotSplitScreenContract.reachableAssets.length == 1 &&
          HabotSplitScreenContract.unreachableAssets.length == 1 &&
          HabotSplitScreenContract.unreachableAssets.single.name ==
              'habot-web' &&
          HabotSplitScreenContract.unreachableAssets.single.note
              .contains('out of reach') &&
          HabotSplitScreenContract.scopeCoverage == 0.5,
    );

    gate(
      'GEN-04187-G6',
      'Floor and ceiling are both "N/A - Binary Governance Gate", so there is '
          'no partial credit by construction.',
      'The gate does not pass, because one in-scope asset cannot be seen from '
          'here -- and it does not fail either, because the half that can be '
          'checked passes completely. Reported Partial, which is the only '
          'honest reading of a binary gate over an unreachable scope',
      () =>
          !HabotSplitScreenContract.gatePasses &&
          HabotSplitScreenContract.mobileConformanceRate == 1.0 &&
          HabotSplitScreenContract.qualitativeOutput == 'Partial' &&
          HabotSplitScreenContract.floorBoundary.contains('N/A') &&
          HabotSplitScreenContract.ceilingBoundary.contains('N/A') &&
          HabotSplitScreenContract.binaryGateNote.contains('Step 181'),
    );

    gate(
      'GEN-04187-G7',
      '"Reporting Complete on a rule that covers an asset this repository '
          'cannot see would be reporting on a codebase nobody checked."',
      'The reason the gate is not reported Complete is written down where the '
          'gate is, rather than left to be inferred from a status word',
      () =>
          HabotSplitScreenContract.halfTheScopeNote
              .contains('nobody checked') &&
          HabotSplitScreenContract.componentName == 'SplitScreenLayout' &&
          HabotSplitScreenContract.mobileImplementation
              .contains('HabotMasterDetail') &&
          HabotSplitScreenContract.columnNote.contains('EMPTY'),
    );

    deferredGate(
      'GEN-04187-G8',
      'SSL-6: both implementations expose the same prop names.',
      'The habot-web SplitScreenLayout is checked against this contract',
      'habot-web is a separate tree with its own component registry. Nothing '
          'in this repository can inspect it, import from it or make it '
          'conform, and a gate that asserted its conformance would be '
          'asserting something nobody ran. The contract is published in '
          'executable form so the web side can be held against it by whoever '
          'owns that tree; until they report, this clause stays open and the '
          'step stays Partial.',
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-04187',
        atomicStepReferenceId: 'GEN-04187',
        setupStepAction:
            'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic '
            'Step: "Apply the standardization rule: Standardize the '
            '<SplitScreenLayout /> Master Component across all web and mobile '
            'apps."',
        implementationOrder: 219,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotSplitScreenContract',
          'Component Properties':
              '${HabotSplitScreenContract.clauses.length} contract clauses, '
              '${HabotSplitScreenContract.verifiableClauses.length} checkable '
              'from this repository; '
              '${HabotSplitScreenContract.inScope.length} in-scope assets of '
              'which ${HabotSplitScreenContract.reachableAssets.length} is '
              'reachable; mobile conformance '
              '${HabotSplitScreenContract.mobileConformanceRate}',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'REPORTS PARTIAL, AND CORRECTLY. The metric is a binary '
              'governance gate -- floor and ceiling both "N/A" -- over a scope '
              'that names two codebases. habot-web is a separate tree with its '
              'own component registry; nothing here can inspect it, depend '
              'on it or make it conform. Reporting Complete would be '
              'reporting on a codebase nobody checked; reporting Not Complete '
              'would be wrong about the half that does conform. Five of six '
              'clauses are checkable here and all five hold. SUBSTITUTION: two '
              'codebases in two languages cannot share a widget, so what is '
              'standardised is a CONTRACT -- pane roles rather than sides, the '
              'ratio chosen by the relation rather than by the caller, compact '
              'navigating rather than stacking, the minimum extent, and the '
              'window class read from the window. A contract is something a '
              'reviewer on either side can hold their implementation against. '
              'ONE DEFERRED GATE: the web half. Same shape as Step 181, which '
              'reported Fail on a binary gate rather than inventing partial '
              'credit.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Standardization Rule Adherence',
            observed:
                'PARTIAL. Mobile conformance '
                '${(conformance * 100).toStringAsFixed(0)}% over '
                '${HabotSplitScreenContract.verifiableClauses.length} '
                'checkable clauses; scope coverage '
                '${(HabotSplitScreenContract.scopeCoverage * 100)'
                '.toStringAsFixed(0)}%, because one of the two in-scope '
                'assets cannot be seen from here.',
            floor: 'N/A - Binary Governance Gate',
            optimal: '100% - Rule Applied Across All In-Scope Assets',
            ceiling: 'N/A - Binary Governance Gate',
          ),
          AissMeasurement(
            metricName: 'Clauses checkable from this repository',
            observed:
                '${HabotSplitScreenContract.verifiableClauses.length} of '
                '${HabotSplitScreenContract.clauses.length}. The sixth is '
                'about prop-name parity across two codebases and is marked '
                'unverifiable here rather than asserted -- a clause nothing '
                'can check is a sentence in a document.',
            floor: 'n/a -- descriptive',
            optimal: 'n/a -- descriptive',
            ceiling: 'n/a -- descriptive',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/layout/split_screen_contract.dart',
        ],
      ),
    );
  });
}
