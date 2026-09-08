/// AISS GATE -- Step 104 of 115
/// Global Reference ID:       GEN-02279
/// Atomic Steps Reference ID: GEN-02279-A01
/// Setup Step (Action):       "Configure the mobile UI to use progressive
///                             disclosure."
/// Metric: UI Compliance Rate -- Floor 0.95.
///
/// COLUMN NOTE, RECORDED: Setup Step (Action) and Setup Step Description are
/// the identical string on this row.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/a11y/progressive_disclosure.dart';
import 'package:udf_setup/design_system/a11y/semantic_hints.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];

  void record(String id, String source, String description, bool passed) {
    gates.add(
      AissGate(
        id: id,
        requirementSource: source,
        description: description,
        passed: passed,
      ),
    );
  }

  void gate(String id, String source, String description, bool Function() run) {
    test('[$id] $description', () {
      bool passed = false;
      try {
        passed = run();
        expect(passed, isTrue, reason: '$id failed: $description');
      } finally {
        record(id, source, description, passed);
      }
    });
  }

  void widgetGate(
    String id,
    String source,
    String description,
    Future<bool> Function(WidgetTester tester) run,
  ) {
    testWidgets('[$id] $description', (WidgetTester tester) async {
      bool passed = false;
      try {
        passed = await run(tester);
        expect(passed, isTrue, reason: '$id failed: $description');
      } finally {
        record(id, source, description, passed);
      }
    });
  }

  List<HabotDisclosureSection> sections() => <HabotDisclosureSection>[
    HabotDisclosureSection(
      title: 'Provenance',
      tier: HabotDisclosureTier.forensic,
      builder: (BuildContext _) => const Text('Ingested 09:14 from batch 42'),
    ),
    HabotDisclosureSection(
      title: 'Related jobs',
      tier: HabotDisclosureTier.supporting,
      builder: (BuildContext _) => const Text('Three other jobs on this site'),
    ),
  ];

  Widget group104() => MaterialApp(
    home: Material(
      child: HabotDisclosureGroup(
        primary: const Text('Job B-2026-08'),
        sections: sections(),
      ),
    ),
  );

  group('GEN-02279-A01 :: the poka-yoke', () {
    gate(
      'GEN-02279-G1',
      'Progressive disclosure fails in one predictable way: the "more" '
          'section becomes where required information lives.',
      'Content marked essential cannot be placed behind a disclosure control '
          '-- the group throws at construction with a message that says why, '
          'rather than rendering a form only a guesser can complete',
      () {
        bool threw = false;
        try {
          HabotDisclosureGroup(
            primary: const Text('x'),
            sections: <HabotDisclosureSection>[
              HabotDisclosureSection(
                title: 'Signature required',
                tier: HabotDisclosureTier.essential,
                builder: (BuildContext _) => const Text('sign here'),
              ),
            ],
          );
        } on HabotDisclosureViolation catch (e) {
          threw = e.toString().contains('Signature required') &&
              e.toString().contains('without an extra action');
        }
        return threw;
      },
    );

    gate(
      'GEN-02279-G2',
      'Metric: UI Compliance Rate, floor 0.95.',
      'The compliance figure is computed from the tiering of the sections '
          'actually supplied, not asserted -- and an essential section drags '
          'it below the floor rather than being quietly accepted',
      () {
        final double clean = HabotDisclosureGroup.complianceRate(sections());
        final double dirty = HabotDisclosureGroup.complianceRate(
          <HabotDisclosureSection>[
            ...sections(),
            HabotDisclosureSection(
              title: 'Signature',
              tier: HabotDisclosureTier.essential,
              builder: (BuildContext _) => const Text('x'),
            ),
          ],
        );
        return clean == 1.0 && dirty < 0.95;
      },
    );
  });

  group('GEN-02279-A01 :: what a screen reader is told', () {
    widgetGate(
      'GEN-02279-G3',
      'Step 99: a control that changes what is on screen must say so. '
          'Disclosure without an announcement moves a reader to content that '
          'was not there a moment ago.',
      'The trigger exposes its expansion state as a toggle and carries the '
          'Step 99 disclosure hint, so the reader says "collapsed" then '
          '"expanded" rather than nothing',
      (WidgetTester tester) async {
        final SemanticsHandle handle = tester.ensureSemantics();
        try {
          await tester.pumpWidget(group104());
          SemanticsNode node = tester.getSemantics(
            find.byKey(HabotDisclosureGroup.triggerKeyFor('Related jobs')),
          );
          final bool collapsed =
              node.hasFlag(SemanticsFlag.hasToggledState) &&
              !node.hasFlag(SemanticsFlag.isToggled) &&
              node.hint == HabotHints.of(HabotActionKind.discloseMetadata).hint;

          await tester.tap(
            find.byKey(HabotDisclosureGroup.triggerKeyFor('Related jobs')),
          );
          await tester.pumpAndSettle();

          node = tester.getSemantics(
            find.byKey(HabotDisclosureGroup.triggerKeyFor('Related jobs')),
          );
          return collapsed && node.hasFlag(SemanticsFlag.isToggled);
        } finally {
          handle.dispose();
        }
      },
    );

    widgetGate(
      'GEN-02279-G4',
      'Setup Step (Action): "use progressive disclosure" -- the point is that '
          'the secondary content is NOT there until asked for.',
      'Collapsed content is absent from the tree entirely, and appears on '
          'request inside the trigger container so swipe-next reaches it',
      (WidgetTester tester) async {
        await tester.pumpWidget(group104());
        final bool hiddenFirst =
            find.text('Three other jobs on this site').evaluate().isEmpty &&
            find.text('Job B-2026-08').evaluate().isNotEmpty;
        await tester.tap(
          find.byKey(HabotDisclosureGroup.triggerKeyFor('Related jobs')),
        );
        await tester.pumpAndSettle();
        return hiddenFirst &&
            find
                .byKey(HabotDisclosureGroup.panelKeyFor('Related jobs'))
                .evaluate()
                .isNotEmpty &&
            find.text('Three other jobs on this site').evaluate().isNotEmpty;
      },
    );

    widgetGate(
      'GEN-02279-G5',
      'MUFCE-028 (Step 24): nothing hover-shaped.',
      'Each section opens on tap and stays open; there is no hover callback '
          'and no tooltip anywhere in the rendered tree',
      (WidgetTester tester) async {
        await tester.pumpWidget(group104());
        await tester.tap(
          find.byKey(HabotDisclosureGroup.triggerKeyFor('Provenance')),
        );
        await tester.pumpAndSettle();
        final bool opened = find
            .text('Ingested 09:14 from batch 42')
            .evaluate()
            .isNotEmpty;
        // Independence: opening one must not close the other.
        await tester.tap(
          find.byKey(HabotDisclosureGroup.triggerKeyFor('Related jobs')),
        );
        await tester.pumpAndSettle();
        return opened &&
            find.text('Ingested 09:14 from batch 42').evaluate().isNotEmpty &&
            find.text('Three other jobs on this site').evaluate().isNotEmpty &&
            find.byType(Tooltip).evaluate().isEmpty;
      },
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-02279',
        atomicStepReferenceId: 'GEN-02279-A01',
        setupStepAction: 'Configure the mobile UI to use progressive '
            'disclosure.',
        implementationOrder: 104,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotDisclosureGroup / HabotDisclosureSection',
          'Component Properties':
              '${HabotDisclosureTier.values.length} content tiers; essential '
              'content refused at construction; expansion exposed as a '
              'semantics toggle carrying the Step 99 hint',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'Setup Step (Action) and Setup Step Description are the '
              'identical string on this row.',
        },
        measurements: <AissMeasurement>[
          const AissMeasurement(
            metricName: 'UI Compliance Rate (sections correctly tiered)',
            observed:
                '1.0 for a well-formed group. A group containing essential '
                'content cannot be constructed at all, so the rate cannot '
                'silently drift below the floor -- it fails earlier than that.',
            floor: '0.95',
            optimal: '1.0',
            ceiling: '1.0',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/a11y/progressive_disclosure.dart',
        ],
      ),
    );
  });
}
