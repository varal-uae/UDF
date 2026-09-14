/// AISS GATE -- Step 172 of 175
/// Global Reference ID:       GEN-01187
/// Atomic Steps Reference ID: GEN-01187
/// Setup Step (Action) / Atomic Step: "Set up automated push notification
///   triggers that alert parents when a favorited service drops in price or
///   opens new scheduling slots."
/// Metric: Mean Time to Detect (MTTD) -- Floor "<15 min", Optimal "<2 min",
///         Ceiling "<30 min". Good / Average / Poor.
///
/// MTTD IS A SERVER FIGURE -- no phone is watching a price. What the client
/// owns is the watch, the threshold, the direction, and the preference check
/// that decides whether a detected change may interrupt somebody. The alert
/// that fires on a one-penny move is the one that gets notifications turned
/// off.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/data/favourites_repository.dart';
import 'package:udf_setup/design_system/data/local_store.dart';
import 'package:udf_setup/design_system/data/outbox.dart';
import 'package:udf_setup/design_system/i18n/fixed_precision.dart';
import 'package:udf_setup/design_system/notifications/watch_triggers.dart';
import 'package:udf_setup/design_system/tokens/motion_tokens.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  int sentWhileMuted = -1;
  int suppressedByPreference = 0;

  void gate(
    String id,
    String source,
    String description,
    Future<bool> Function() run,
  ) {
    test('[$id] $description', () async {
      bool passed = false;
      try {
        passed = await run();
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

  late HabotMemoryStore store;
  late HabotOutbox outbox;
  late HabotFavouritesRepository favourites;
  late Set<HabotWatchKind> allowedCategories;
  late HabotWatchTriggers triggers;

  setUp(() {
    store = HabotMemoryStore();
    outbox = HabotOutbox(store: store);
    favourites = HabotFavouritesRepository(store: store, outbox: outbox);
    allowedCategories = HabotWatchKind.values.toSet();
    triggers = HabotWatchTriggers(
      favourites: favourites,
      isCategoryAllowed: allowedCategories.contains,
    );
  });

  HabotFixed aed(String text) => HabotPrecision.cacAedValue(text);

  Future<void> favourite(String id) =>
      favourites.add(entityId: id, itemId: 'service-$id');

  group('GEN-01187 :: "drops in price" has to mean something', () {
    gate(
      'GEN-01187-G1',
      'Atomic Step: "...alert parents when a favorited service DROPS in '
          'price." "A system that alerts on both because it compared two '
          'numbers and found them different is one nobody trusts twice."',
      'The condition is DIRECTIONAL: a fall past the threshold satisfies it '
          'and a rise of the same size does not, however large',
      () async {
        final HabotWatchCondition c = HabotWatchCondition.priceDrop();
        return c.isSatisfiedByPrice(
              before: aed('120.0000'),
              after: aed('100.0000'),
            ) &&
            !c.isSatisfiedByPrice(
              before: aed('100.0000'),
              after: aed('120.0000'),
            ) &&
            !c.isSatisfiedByPrice(
              before: aed('100.0000'),
              after: aed('100.0000'),
            ) &&
            HabotWatchTriggers.thresholdNote.contains('DIRECTION');
      },
    );

    gate(
      'GEN-01187-G2',
      '"The alert that fires on a one-penny move is the one that gets '
          'notifications turned off."',
      'A drop smaller than the threshold does not alert, the default threshold '
          'is a whole unit of currency -- the smallest move a person would '
          'call a drop -- and a caller can raise it, which then suppresses a '
          'change that would otherwise have fired',
      () async {
        final HabotWatchCondition standard = HabotWatchCondition.priceDrop();
        final HabotWatchCondition strict = HabotWatchCondition.priceDrop(
          minimum: aed('10.0000'),
        );
        return !standard.isSatisfiedByPrice(
              before: aed('100.0000'),
              after: aed('99.5000'),
            ) &&
            standard.isSatisfiedByPrice(
              before: aed('100.0000'),
              after: aed('99.0000'),
            ) &&
            !strict.isSatisfiedByPrice(
              before: aed('100.0000'),
              after: aed('95.0000'),
            ) &&
            strict.isSatisfiedByPrice(
              before: aed('100.0000'),
              after: aed('90.0000'),
            ) &&
            HabotWatchCondition.defaultMinimumDrop
                    .compareTo(aed('1.0000')) ==
                0;
      },
    );

    gate(
      'GEN-01187-G3',
      'Step 140: money is exact, never a double.',
      'The threshold is an exact fixed-precision amount and it travels to the '
          'server as a plain decimal string rather than as a floating-point '
          'number, so the figure the server compares against is the figure the '
          'client meant',
      () async {
        final HabotWatch w = HabotWatch(
          favouriteId: 'fav-1',
          condition: HabotWatchCondition.priceDrop(minimum: aed('2.5000')),
        );
        final Map<String, Object?> registration = w.toRegistration();
        return registration['favourite_id'] == 'fav-1' &&
            registration['kind'] == 'priceDrop' &&
            registration['minimum_drop'] is String &&
            registration['minimum_drop'] is! double &&
            (registration['minimum_drop']! as String).startsWith('2.5') &&
            w.condition.minimumDrop is HabotFixed;
      },
    );

    gate(
      'GEN-01187-G4',
      'Atomic Step: "...or OPENS NEW SCHEDULING SLOTS."',
      'The second condition the row names is a distinct kind with its own '
          'threshold, and the two do not answer for each other -- a price '
          'watch does not fire on slots and a slot watch does not fire on '
          'price',
      () async {
        final HabotWatchCondition slots =
            HabotWatchCondition.slotsOpened(minimum: 2);
        final HabotWatchCondition price = HabotWatchCondition.priceDrop();
        return HabotWatchKind.values.length == 2 &&
            slots.isSatisfiedBySlots(newSlots: 3) &&
            slots.isSatisfiedBySlots(newSlots: 2) &&
            !slots.isSatisfiedBySlots(newSlots: 1) &&
            !slots.isSatisfiedByPrice(
              before: aed('100.0000'),
              after: aed('10.0000'),
            ) &&
            !price.isSatisfiedBySlots(newSlots: 50) &&
            HabotWatchCondition.slotsOpened().minimumNewSlots == 1;
      },
    );
  });

  group('GEN-01187 :: through the preference gate, not around it', () {
    gate(
      'GEN-01187-G5',
      '"A trigger that sends because it has something to say is spam." Step '
          '50 owns whether a category may interrupt somebody.',
      'A qualifying change on a muted category is recorded as suppressed with '
          'the reason rather than sent, and the count of alerts sent while '
          'muted is zero -- so "I turned those off and still got one" cannot '
          'happen',
      () async {
        await favourite('fav-1');
        triggers.register(
          HabotWatch(
            favouriteId: 'fav-1',
            condition: HabotWatchCondition.priceDrop(),
          ),
        );
        allowedCategories.remove(HabotWatchKind.priceDrop);
        final HabotAlertDecision? d = triggers.onPriceChange(
          favouriteId: 'fav-1',
          before: aed('120.0000'),
          after: aed('100.0000'),
        );
        suppressedByPreference =
            triggers.suppressedFor(HabotAlertSuppression.preferenceMuted);
        sentWhileMuted = triggers.sentWhileMuted;
        return d != null &&
            !d.willSend &&
            d.suppression == HabotAlertSuppression.preferenceMuted &&
            suppressedByPreference == 1 &&
            triggers.sent == 0 &&
            sentWhileMuted == 0 &&
            HabotWatchTriggers.preferenceGateNote.contains('still got one');
      },
    );

    gate(
      'GEN-01187-G6',
      'A gate that blocks everything is as useless as one that blocks nothing.',
      'With the category allowed, a qualifying change sends; a change below '
          'the threshold is suppressed for that reason rather than for the '
          'preference; and a change on a service with no watch produces '
          'nothing at all',
      () async {
        await favourite('fav-1');
        triggers.register(
          HabotWatch(
            favouriteId: 'fav-1',
            condition: HabotWatchCondition.priceDrop(),
          ),
        );
        final HabotAlertDecision? sent = triggers.onPriceChange(
          favouriteId: 'fav-1',
          before: aed('120.0000'),
          after: aed('100.0000'),
        );
        final HabotAlertDecision? tooSmall = triggers.onPriceChange(
          favouriteId: 'fav-1',
          before: aed('100.0000'),
          after: aed('99.5000'),
        );
        final HabotAlertDecision? unwatched = triggers.onPriceChange(
          favouriteId: 'fav-nothing',
          before: aed('120.0000'),
          after: aed('100.0000'),
        );
        return sent != null &&
            sent.willSend &&
            tooSmall != null &&
            tooSmall.suppression == HabotAlertSuppression.belowThreshold &&
            unwatched == null &&
            triggers.sent == 1 &&
            triggers.sentWhileMuted == 0 &&
            triggers.decisions.length == 2;
      },
    );

    gate(
      'GEN-01187-G7',
      '"A watch list maintained separately from the favourites is a list that '
          'drifts, and the symptom is alerts about things a user deliberately '
          'removed."',
      'Un-favouriting a service removes its watches: the prune drops exactly '
          'the watches whose favourite is gone, keeps the rest, and a removed '
          'service stops producing decisions entirely',
      () async {
        await favourite('fav-1');
        await favourite('fav-2');
        triggers
          ..register(
            HabotWatch(
              favouriteId: 'fav-1',
              condition: HabotWatchCondition.priceDrop(),
            ),
          )
          ..register(
            HabotWatch(
              favouriteId: 'fav-2',
              condition: HabotWatchCondition.priceDrop(),
            ),
          )
          ..register(
            HabotWatch(
              favouriteId: 'fav-2',
              condition: HabotWatchCondition.slotsOpened(),
            ),
          );
        await favourites.remove('fav-2');
        final List<String> removed = await triggers.pruneToFavourites();
        final HabotAlertDecision? afterRemoval = triggers.onPriceChange(
          favouriteId: 'fav-2',
          before: aed('120.0000'),
          after: aed('100.0000'),
        );
        return removed.length == 2 &&
            removed.contains(
              HabotWatchTriggers.keyOf('fav-2', HabotWatchKind.priceDrop),
            ) &&
            removed.contains(
              HabotWatchTriggers.keyOf('fav-2', HabotWatchKind.slotsOpened),
            ) &&
            triggers.watches.length == 1 &&
            triggers.watches.single.favouriteId == 'fav-1' &&
            afterRemoval == null &&
            HabotWatchTriggers.favouriteLifetimeNote.contains('drifts');
      },
    );
  });

  group('GEN-01187 :: the metric, and whose figure it is', () {
    gate(
      'GEN-01187-G8',
      'Metric: Mean Time to Detect -- floor <15 min, optimal <2 min, '
          'ceiling <30 min. "Detecting that a price fell is something the '
          'backend does against its own catalogue; no phone is watching a '
          'price."',
      'The bands are held as tokens and applied to a detection time the SERVER '
          'supplies, reaching every state including Poor, and the boundary is '
          'recorded rather than left looking like an omission',
      () async =>
          HabotWatchTriggers.optimal == HabotMotion.watchDetectOptimal &&
          HabotWatchTriggers.floor == HabotMotion.watchDetectFloor &&
          HabotWatchTriggers.ceiling == HabotMotion.watchDetectCeiling &&
          HabotWatchTriggers.optimal == const Duration(minutes: 2) &&
          HabotWatchTriggers.floor == const Duration(minutes: 15) &&
          HabotWatchTriggers.ceiling == const Duration(minutes: 30) &&
          HabotWatchTriggers.bandFor(const Duration(minutes: 1)) == 'Good' &&
          HabotWatchTriggers.bandFor(const Duration(minutes: 10)) ==
              'Average' &&
          HabotWatchTriggers.bandFor(const Duration(minutes: 25)) ==
              'Average' &&
          HabotWatchTriggers.bandFor(const Duration(minutes: 45)) == 'Poor' &&
          !HabotWatchTriggers.withinCeiling(const Duration(minutes: 45)) &&
          HabotWatchTriggers.mttdIsServerSide.contains('no phone is watching'),
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-01187',
        atomicStepReferenceId: 'GEN-01187',
        setupStepAction:
            'Set up automated push notification triggers that alert parents '
            'when a favorited service drops in price or opens new scheduling '
            'slots.',
        implementationOrder: 172,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotWatchTriggers / HabotWatchCondition',
          'Component Properties':
              '${HabotWatchKind.values.length} watch kinds (price drop, slots '
              'opened); ${HabotAlertSuppression.values.length} suppression '
              'reasons; price thresholds held as exact HabotFixed amounts '
              '(Step 140) with a default of '
              '${HabotWatchCondition.defaultMinimumDrop.toPlainString()}; '
              'watches bound to Step 132 favourites and pruned with them; '
              'every alert admitted by the Step 50 preference gate',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'BOUNDARY RECORDED: Mean Time to Detect is a server figure. '
              'Detecting that a price fell is something the backend does '
              'against its own catalogue; no phone is watching a price. The '
              'client owns the watch -- which service, on what condition, for '
              'whom -- and the preference check that decides whether a '
              'detected change may interrupt someone. The MTTD bands are '
              'implemented and applied to a figure the server supplies.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Mean Time to Detect (MTTD)',
            observed:
                'NOT MEASURED ON THE CLIENT -- see the note. Bands implemented '
                'against HabotMotion.watchDetect*: Good under 2 minutes, '
                'Average to 30 minutes, Poor beyond, and applied to a '
                'detection time the server supplies.',
            floor: '<15 min',
            optimal: '<2 min',
            ceiling: '<30 min',
            higherIsBetter: false,
          ),
          AissMeasurement(
            metricName: 'Alerts sent while the category was muted',
            observed:
                '$sentWhileMuted. A qualifying price drop on a muted category '
                'is recorded as suppressed with the reason '
                '($suppressedByPreference suppression in the gate run) rather '
                'than sent. A trigger that sends because it has something to '
                'say is spam, and every alert here passes the same Step 50 '
                'gate every other notification passes.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/notifications/watch_triggers.dart',
        ],
      ),
    );
  });
}
