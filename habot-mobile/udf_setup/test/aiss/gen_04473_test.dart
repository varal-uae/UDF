/// AISS GATE -- Step 259 of 275
/// Global Reference ID:       GEN-04473
/// Atomic Steps Reference ID: GEN-04473
/// Setup Step (Action): (EMPTY on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Standardize the custom URL scheme for application entry
///               links."
/// Metric: Deep Link Resolution Success Rate -- Floor 0.95, Optimal 0.99,
///         Ceiling 0.999. Pass/Fail.
///
/// A CUSTOM SCHEME IS NOT VERIFIED. ANY APPLICATION ON THE DEVICE CAN CLAIM
/// habot://, SO IT IS THE FALLBACK AND NOT THE STANDARD.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/navigation/link_scheme_policy.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  double rate = 0;

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

  group('GEN-04473 :: which channel is the standard', () {
    gate(
      'GEN-04473-G1',
      'Atomic Step: "Standardize the custom URL scheme".',
      'The verified https channel is primary and the custom scheme is the '
          'fallback, because nothing stops another application registering '
          'habot:// while a verified domain cannot be claimed by anybody else',
      () =>
          HabotLinkSchemePolicy.customScheme == 'habot' &&
          HabotLinkSchemePolicy.primaryChannel ==
              HabotLinkChannel.verifiedHttps &&
          HabotLinkSchemePolicy.fallbackChannel ==
              HabotLinkChannel.customScheme &&
          HabotLinkSchemePolicy.theCustomSchemeIsNotPrimary &&
          HabotLinkSchemePolicy.unverifiedSchemeNote.contains('FALLBACK'),
    );

    gate(
      'GEN-04473-G2',
      'The verified host belongs to an earlier row.',
      'The host used is the one GEN-00798 already provisioned rather than a '
          'second domain invented here',
      () =>
          HabotLinkSchemePolicy.verifiedHost == 'link.habot.io' &&
          HabotLinkSchemePolicy.verifiedHostOwningRow == 'GEN-00798',
    );

    gate(
      'GEN-04473-G3',
      'Substring matching on a host is how link hijacks work.',
      'Scheme and host are matched by equality rather than by containment, so '
          'link.habot.io.evil.test is foreign, and the classifier agrees with '
          'the expected channel on every case in the corpus',
      () =>
          HabotLinkSchemePolicy.corpus.length == 8 &&
          HabotLinkSchemePolicy.corpusIsClassifiedCorrectly &&
          !HabotLinkSchemePolicy.isOurs(
            'https://link.habot.io.evil.test/b/1',
          ) &&
          HabotLinkSchemePolicy.hostCheckNote.isNotEmpty,
    );

    gate(
      'GEN-04473-G4',
      'A link is untrusted input.',
      'Foreign links are refused, and the refusal reuses the tier and failure '
          'reason the existing fallback vocabulary already declares rather '
          'than adding a new one',
      () =>
          HabotLinkSchemePolicy.foreignLinksAreRefused &&
          HabotLinkSchemePolicy.theRefusedTierAlreadyExists &&
          HabotLinkSchemePolicy.untrustedInputNote.isNotEmpty,
    );
  });

  group('GEN-04473 :: entry links and the denominator', () {
    gate(
      'GEN-04473-G5',
      'Authorisation must not depend on how the person arrived.',
      'Every private entry link requires authorisation, and the requirement '
          'is a property of the destination rather than of the channel -- the '
          'same link over https and over habot:// is gated identically',
      () =>
          HabotLinkSchemePolicy.entryLinks.length == 4 &&
          HabotLinkSchemePolicy.everyPrivateLinkRequiresAuthorisation &&
          HabotLinkSchemePolicy.authorisationDoesNotDependOnTheChannel,
    );

    gate(
      'GEN-04473-G6',
      'Metric: Deep Link Resolution Success Rate -- 0.95 / 0.99 / 0.999.',
      'The rate is 1.0 over the links that can resolve and 0.375 over every '
          'link in the corpus, so the denominator decides whether this row '
          'passes or fails and it is published rather than chosen quietly',
      () {
        rate = HabotLinkSchemePolicy.resolutionSuccessRate;
        return rate == 1.0 &&
            (HabotLinkSchemePolicy.rateOverEveryLink - 0.375).abs() < 1e-9 &&
            HabotLinkSchemePolicy.theDenominatorChangesTheAnswer &&
            HabotLinkSchemePolicy.denominatorNote.isNotEmpty;
      },
    );

    gate(
      'GEN-04473-G7',
      'Output: Pass/Fail.',
      'All nine declared checks hold and the step reports Pass on the '
          'resolvable population, with the other reading stated beside it',
      () =>
          HabotLinkSchemePolicy.checks.length == 9 &&
          HabotLinkSchemePolicy.checks.values.every((bool b) => b) &&
          HabotLinkSchemePolicy.qualitativeOutput == 'Pass' &&
          HabotLinkSchemePolicy.floor == 0.95 &&
          HabotLinkSchemePolicy.optimal == 0.99 &&
          HabotLinkSchemePolicy.ceiling == 0.999 &&
          HabotLinkSchemePolicy.columnNote.contains('EMPTY'),
    );
  });

  tearDownAll(() {
    final String resolvable =
        '${HabotLinkSchemePolicy.resolvableCases.length}';
    final String corpus = '${HabotLinkSchemePolicy.corpus.length}';
    final String naive =
        HabotLinkSchemePolicy.rateOverEveryLink.toStringAsFixed(3);
    final String verified = '${HabotLinkSchemePolicy.verifiedLinks.length}';
    final String custom = '${HabotLinkSchemePolicy.customSchemeLinks.length}';

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-04473',
        atomicStepReferenceId: 'GEN-04473',
        setupStepAction:
            'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic '
            'Step: "Standardize the custom URL scheme for application entry '
            'links."',
        implementationOrder: 259,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name':
              'HabotLinkSchemePolicy / HabotEntryLink / HabotLinkCase',
          'Component Properties':
              '${HabotLinkSchemePolicy.entryLinks.length} entry links '
              '($verified verified https, $custom custom scheme) on '
              '${HabotLinkSchemePolicy.verifiedHost}; $corpus classified '
              'cases of which $resolvable are resolvable; scheme and host '
              'matched by equality',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'FINDING: ${HabotLinkSchemePolicy.unverifiedSchemeNote} '
              'DENOMINATOR: ${HabotLinkSchemePolicy.denominatorNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Deep Link Resolution Success Rate',
            observed:
                '${rate.toStringAsFixed(3)} over the $resolvable resolvable '
                'cases; $naive over all $corpus, which is the naive reading '
                'and would fail the floor. The denominator is the whole '
                'question and is stated rather than chosen quietly.',
            floor: '0.95',
            optimal: '0.99',
            ceiling: '0.999',
          ),
          AissMeasurement(
            metricName: 'Foreign links accepted',
            observed:
                '0. Host and scheme are compared by equality, so a host that '
                'merely contains the verified one is refused through the '
                'tier the existing fallback vocabulary already had.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/navigation/link_scheme_policy.dart',
        ],
      ),
    );
  });
}
