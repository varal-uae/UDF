/// AISS GATE -- Step 209 of 215
/// Global Reference ID:       GEN-01573
/// Atomic Steps Reference ID: GEN-01573
/// Setup Step (Action): (EMPTY on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Render a dynamic vector QR code pass on the order
///               confirmation screen."
/// Metric: Digital Pass/QR Generation & Scan Success Rate -- Floor 0.97,
///         Optimal 0.999, Ceiling 1. Pass/Fail.
///
/// "DYNAMIC" IS DOING MORE WORK THAN IT LOOKS: a QR encoding a booking id is a
/// permanent credential that survives being screenshotted and forwarded. And
/// scan failures are almost never about the encoding -- they are the quiet
/// zone, the brightness and the module size, all of which are decided here.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/confirmation/qr_pass.dart';
import 'package:udf_setup/design_system/tokens/motion_tokens.dart';
import 'package:udf_setup/design_system/tokens/spacing_tokens.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  double generation = 0;

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

  const String reference = '7QF3M2K9XZ4T8VB6NC1RDS';
  const String signature = 'a91f3e77c2';

  String pass({int window = 29348172}) => HabotQrPass.payloadFor(
        bookingReference: reference,
        windowIndex: window,
        signature: signature,
      );

  group('GEN-01573 :: the payload', () {
    gate(
      'GEN-01573-G1',
      'Atomic Step: "a DYNAMIC vector QR code pass."',
      'The payload is bound to a rotation window, so the same booking produces '
          'a different pass in a later window -- a screenshot forwarded on '
          'expires instead of admitting someone indefinitely',
      () {
        final String now = pass();
        final String later = pass(window: 29348177);
        return now != later &&
            now.startsWith(HabotQrPass.formatTag) &&
            HabotQrPass.validityWindow == HabotMotion.passValidityWindow &&
            HabotQrPass.rotationPeriod == HabotMotion.passRotationPeriod &&
            HabotQrPass.rotationPeriod < HabotQrPass.validityWindow;
      },
    );

    gate(
      'GEN-01573-G2',
      '"Rotation limits the damage, it does not remove it."',
      'A pass presented in the window it was generated in is accepted and one '
          'five windows later is not, while the fact that single use is the '
          'door\'s job rather than rotation\'s is stated rather than implied',
      () =>
          HabotQrPass.isWithinValidity(
            generatedWindow: 100,
            presentedWindow: 100,
          ) &&
          HabotQrPass.isWithinValidity(
            generatedWindow: 100,
            presentedWindow: 104,
          ) &&
          !HabotQrPass.isWithinValidity(
            generatedWindow: 100,
            presentedWindow: 105,
          ) &&
          !HabotQrPass.isWithinValidity(
            generatedWindow: 100,
            presentedWindow: 99,
          ) &&
          HabotQrPass.rotationLimitsNotPreventsNote
              .contains('Single use is enforced at the door'),
    );

    gate(
      'GEN-01573-G3',
      '"A QR is a thing people photograph and forward."',
      'The payload shape is constrained to a tag, an opaque reference, a '
          'window and a signature, so nothing that names a child, a parent or '
          'a service can be encoded through this path',
      () =>
          HabotQrPass.payloadIsWellFormed(pass()) &&
          !HabotQrPass.payloadIsWellFormed(
            'HB1:Amal Hassan:29348172:a91f3e77c2',
          ) &&
          !HabotQrPass.payloadIsWellFormed('booking-4471') &&
          !pass().contains(' '),
    );
  });

  group('GEN-01573 :: why scans fail', () {
    gate(
      'GEN-01573-G4',
      '"The most common scan failure is a QR laid out flush to a card edge."',
      'The quiet zone is four modules per the specification and is part of the '
          'rendered geometry rather than padding a layout can remove: the '
          'rendered side is wider than the symbol by eight modules',
      () {
        final HabotQrGeometry? g = HabotQrPass.geometryFor(pass());
        return g != null &&
            g.quietZoneModules == 4 &&
            g.modulesWithQuietZone == g.modules + 8 &&
            g.renderedSideDp > g.symbolSideDp &&
            HabotQrPass.quietZoneDpFor(g) > 0 &&
            HabotQrPass.quietZoneIsTheCommonFailureNote
                .contains('part of the symbol, not padding');
      },
    );

    gate(
      'GEN-01573-G5',
      '"A blurred module boundary is the one thing a scanner cannot recover '
          'from."',
      'The 46-character payload selects version 4 at error-correction level Q '
          '-- 33 modules, 41 with the quiet zone -- and at the 240dp render '
          'size each module is 5.85dp, above the 4dp floor for resolving off a '
          'screen',
      () {
        final HabotQrGeometry? g = HabotQrPass.geometryFor(pass());
        return g != null &&
            pass().length == 46 &&
            g.version == 4 &&
            g.modules == 33 &&
            g.modulesWithQuietZone == 41 &&
            (g.moduleSizeDp - 240 / 41).abs() < 1e-9 &&
            HabotQrPass.moduleSizeIsScannable(g) &&
            HabotQrPass.targetSideDp == HabotSpacing.xxxl * 5 &&
            HabotQrPass.errorCorrection == HabotQrErrorCorrection.quartile;
      },
    );

    gate(
      'GEN-01573-G6',
      '"A payload sitting at capacity grows the symbol by four modules per '
          'side the moment one character is added."',
      'The headroom at the chosen version is zero and is reported rather than '
          'hidden, and one more character does move the pass to version 5 -- '
          'so the knife edge is a number somebody can see',
      () {
        final int headroom = HabotQrPass.headroomFor(pass());
        final String longer = '${pass()}X';
        return headroom == 0 &&
            HabotQrPass.versionFor(longer.length) == 5 &&
            HabotQrPass.modulesForVersion(5) == 37 &&
            HabotQrPass.byteCapacityAtQuartile[4] == 46 &&
            HabotQrPass.moduleSizeIsScannable(
              HabotQrPass.geometryFor(longer)!,
            );
      },
    );

    gate(
      'GEN-01573-G7',
      'Metric: Digital Pass/QR Generation & Scan Success Rate -- floor 0.97, '
          'Pass/Fail.',
      'The generation half and the screen-side conditions that cause most scan '
          'failures are computed and all nine hold, giving 1.0; the scan half '
          'depends on a camera, a scanner and a room, and no figure is '
          'invented for it',
      () {
        generation = HabotQrPass.generationSuccessRate(pass());
        return HabotQrPass.checksFor(pass()).length == 9 &&
            HabotQrPass.checksFor(pass()).values.every((bool b) => b) &&
            generation == 1.0 &&
            generation >= HabotQrPass.floor &&
            HabotQrPass.qualitativeOutput(generation) == 'Pass' &&
            HabotQrPass.rendersOffline &&
            HabotQrPass.raisesScreenBrightness &&
            HabotQrPass.restoresBrightnessOnLeave &&
            HabotQrPass.scanHalfIsNotOursNote.contains('a camera, a scanner') &&
            HabotQrPass.columnNote.contains('EMPTY');
      },
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-01573',
        atomicStepReferenceId: 'GEN-01573',
        setupStepAction:
            'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic '
            'Step: "Render a dynamic vector QR code pass on the order '
            'confirmation screen."',
        implementationOrder: 209,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotQrPass / HabotQrGeometry',
          'Component Properties':
              'Version 4 at error-correction level Q for a 46-byte payload; '
              '33 modules plus a 4-module quiet zone each side; '
              '${HabotQrPass.targetSideDp.toStringAsFixed(0)}dp rendered side '
              'giving 5.85dp modules against a '
              '${HabotQrPass.minimumModuleDp.toStringAsFixed(0)}dp floor; '
              'payload rotates every '
              '${HabotQrPass.rotationPeriod.inMinutes} minute and stays valid '
              'for ${HabotQrPass.validityWindow.inMinutes}; renders offline; '
              'brightness raised and restored',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'READING RECORDED: "dynamic" is doing more work than it looks. A '
              'QR encoding a booking id is a permanent credential -- a '
              'screenshot forwarded to anyone admits them indefinitely, and '
              'the parent who forwarded it is not doing anything they would '
              'recognise as wrong. The payload is bound to a rotation window '
              'so a screenshot expires. Rotation LIMITS the exposure; it does '
              'not make the pass single-use, and that is the door\'s job -- '
              'saying which mechanism does what matters more than either. '
              'FINDING: scan failures are almost never about the encoding. In '
              'order of frequency they are a missing quiet zone (a QR laid out '
              'flush to a card edge), a dim screen, and too small a symbol. '
              'All three are layout decisions on this screen and all three are '
              'settled here as numbers: the quiet zone is in the geometry '
              'rather than in a padding a layout can remove, the module size '
              'is derived and checked against a floor, and the screen '
              'brightens while the pass is shown and is restored on leaving. '
              'REPORTED: the payload sits exactly at version 4 capacity, so '
              'one added character moves it to version 5 -- the headroom is '
              'zero and is reported rather than hidden. SUBSTITUTION: the scan '
              'half of the metric depends on a camera, a scanner and a room, '
              'and no figure is produced for it.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Digital Pass/QR Generation & Scan Success Rate '
                '(generation half)',
            observed:
                '${generation.toStringAsFixed(2)} over '
                '${HabotQrPass.checksFor(pass()).length} checks: version '
                'selection, quiet zone, module size, error correction, payload '
                'shape, expiry, offline rendering and brightness. The scan '
                'half is not producible on this host and is not invented.',
            floor: '0.97',
            optimal: '0.999',
            ceiling: '1',
          ),
          AissMeasurement(
            metricName: 'Module size at the rendered pass size',
            observed:
                '5.85dp per module -- 240dp across 41 modules including the '
                'quiet zone -- against a 4dp floor for resolving off a screen '
                'at arm\'s length. Payload headroom at this version is 0, so '
                'one more character drops the module size to 5.33dp.',
            floor: '4dp',
            optimal: '6dp',
            ceiling: 'n/a',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/confirmation/qr_pass.dart',
        ],
      ),
    );
  });
}
