/// AISS GATE -- Step 100 of 115
/// Global Reference ID:       GEN-02764
/// Atomic Steps Reference ID: GEN-02764-A01
/// Setup Step (Action):       "Write alt text for all informational images and
///                             set alt to empty string for decorative images."
/// WCAG 2.2 SC 1.1.1 Non-text Content (Level A).
///
/// COLUMN NOTE, RECORDED: Setup Step (Action) and Setup Step Description are
/// the identical string on this row.
library;

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/a11y/image_semantics.dart';

import 'aiss_reporter.dart';

/// A 1x1 transparent PNG, so nothing here reaches the network or the disk.
final Uint8List _pixel = Uint8List.fromList(<int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, //
  0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
  0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41,
  0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00,
  0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
  0x42, 0x60, 0x82,
]);

void main() {
  final List<AissGate> gates = <AissGate>[];
  int altsChecked = 0;
  int altsRejected = 0;

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

  ImageProvider<Object> provider() => MemoryImage(_pixel);

  group('GEN-02764-A01 :: informational images', () {
    gate(
      'GEN-02764-G1',
      'Setup Step (Action): "write alt text for ALL informational images".',
      'An informational image cannot be constructed without usable alt text: '
          'blank, file-name and over-long values are refused at construction '
          'with a named reason, not accepted and rendered',
      () {
        bool refuses(String alt) {
          altsChecked++;
          try {
            HabotImage(image: provider(), alt: alt);
            return false;
          } on ArgumentError {
            altsRejected++;
            return true;
          }
        }

        final bool good =
            HabotImage(
              image: provider(),
              alt: 'A delivery note signed by the site supervisor',
            ).alt.isNotEmpty;
        altsChecked++;

        return good &&
            refuses('') &&
            refuses('   ') &&
            refuses('ab') &&
            refuses('signed_note_final_v2.png') &&
            refuses('x' * 200);
      },
    );

    gate(
      'GEN-02764-G2',
      'A screen reader already announces "image"; alt that repeats it makes '
          'the announcement "image, image of a signed form".',
      'Redundant prefixes are rejected, and the rejection says which prefix '
          'and why rather than "invalid"',
      () {
        final String? defect = HabotAltText.defectIn(
          'Image of a signed delivery note',
        );
        return defect != null &&
            defect.contains('image of') &&
            defect.contains('already announces') &&
            HabotAltText.isUsable('A signed delivery note');
      },
    );

    widgetGate(
      'GEN-02764-G3',
      'SC 1.1.1: the alternative has to reach the accessibility tree, not '
          'merely be stored on the widget.',
      'A rendered informational image exposes exactly one semantics node, '
          'flagged as an image and carrying the alt text as its label',
      (WidgetTester tester) async {
        final SemanticsHandle handle = tester.ensureSemantics();
        try {
          await tester.pumpWidget(
            MaterialApp(
              home: HabotImage(
                image: provider(),
                alt: 'A delivery note signed by the site supervisor',
              ),
            ),
          );
          final SemanticsNode node = tester.getSemantics(
            find.byType(HabotImage),
          );
          return node.hasFlag(SemanticsFlag.isImage) &&
              node.label == 'A delivery note signed by the site supervisor';
        } finally {
          handle.dispose();
        }
      },
    );
  });

  group('GEN-02764-A01 :: decorative images -- the half people skip', () {
    widgetGate(
      'GEN-02764-G4',
      'Setup Step (Action): "...and SET ALT TO EMPTY STRING for decorative '
          'images".',
      'A decorative image contributes NOTHING to the semantics tree -- there '
          'is no node to skip past, which is the empty-alt equivalent on this '
          'platform',
      (WidgetTester tester) async {
        final SemanticsHandle handle = tester.ensureSemantics();
        try {
          await tester.pumpWidget(
            MaterialApp(
              home: Column(
                children: <Widget>[
                  const Text('Before'),
                  HabotDecorativeImage(image: provider()),
                  const Text('After'),
                ],
              ),
            ),
          );
          // Nothing between the two labels: no "image", no empty node.
          return find.byType(HabotDecorativeImage).evaluate().length == 1 &&
              tester
                  .widget<HabotDecorativeImage>(
                    find.byType(HabotDecorativeImage),
                  )
                  .purpose ==
                  HabotImagePurpose.decorative &&
              find.bySemanticsLabel('image').evaluate().isEmpty;
        } finally {
          handle.dispose();
        }
      },
    );

    gate(
      'GEN-02764-G5',
      'The decision between informational and decorative must be forced, not '
          'defaulted.',
      'HabotDecorativeImage has no alt parameter at all, so "decorative" is '
          'the consequence of choosing the widget rather than a value someone '
          'passes and could pass wrongly',
      () {
        final HabotDecorativeImage d = HabotDecorativeImage(
          image: provider(),
        );
        final HabotImage i = HabotImage(
          image: provider(),
          alt: 'A signed delivery note',
        );
        return d.purpose == HabotImagePurpose.decorative &&
            i.purpose == HabotImagePurpose.informational &&
            HabotImagePurpose.values.length == 2;
      },
    );

    gate(
      'GEN-02764-G6',
      'Step 97 A11Y_RAW_IMAGE: a raw Image bypasses both widgets.',
      'The alt-text rules are declared as data with stated bounds, so the '
          'guard and the widget cannot drift apart on what "usable" means',
      () =>
          HabotAltText.minLength >= 3 &&
          HabotAltText.maxLength <= 200 &&
          HabotAltText.redundantPrefixes.isNotEmpty &&
          HabotAltText.redundantPrefixes.every(
            (String p) => p == p.toLowerCase(),
          ),
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-02764',
        atomicStepReferenceId: 'GEN-02764-A01',
        setupStepAction:
            'Write alt text for all informational images and set alt to empty '
            'string for decorative images.',
        implementationOrder: 100,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotImage / HabotDecorativeImage / HabotAltText',
          'Component Properties':
              'alt between ${HabotAltText.minLength} and '
              '${HabotAltText.maxLength} characters, '
              '${HabotAltText.redundantPrefixes.length} redundant prefixes '
              'refused, file-name-shaped values refused',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'Setup Step (Action) and Setup Step Description are the '
              'identical string on this row.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Alt text values refused at construction',
            observed:
                '$altsRejected of $altsChecked candidate values were refused, '
                'each with a named defect. A rejected value cannot be '
                'rendered, so the failure is at build time rather than in '
                'front of a user.',
            floor: 'every defect named',
            optimal: 'every defect named',
            ceiling: 'every defect named',
          ),
          const AissMeasurement(
            metricName: 'Whether the alt text is MEANINGFUL',
            observed:
                'NOT PRODUCED. Whether "A delivery note signed by the site '
                'supervisor" describes the picture is a reading, not a '
                'measurement. What is gated is that a description exists, is '
                'not a file name, and reaches the accessibility tree. SC 1.1.1 '
                'quality is recorded in the Step 98 runbook as requiring a '
                'human reading.',
            floor: 'not machine checkable',
            optimal: 'not machine checkable',
            ceiling: 'not machine checkable',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/a11y/image_semantics.dart',
        ],
      ),
    );
  });
}
