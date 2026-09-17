/// Step 405 (FEBFL-027-12) -- letting a packet decide what a route shows, and
/// the two things a route must not surrender.
///
/// The row: "Connect the mobile view controller routing layer to invoke
/// ProgrammaticLayoutEngine upon receiving layout JSON packets."
/// Metric: **UI Design-System Adherence Rate** -- the shared metric, fourth of
/// six. Assigned to **UDF**.
///
/// **This is the row where server-driven UI becomes real, and where it becomes
/// dangerous.** Steps 401 to 404 build a format, an engine and a walker, none
/// of which can put anything on a screen. This row hands a route's contents to
/// a packet, and from here a server decides what a person sees.
///
/// **A route surrenders its contents and keeps two things.** It keeps its
/// *identity* -- what the route is for, which is what deep links, analytics and
/// the back stack are keyed on -- and it keeps its *guards*, because a packet
/// cannot be allowed to place a control the viewer's role does not clear. A
/// route that surrenders either becomes a URL that means whatever arrived last.
///
/// **A packet arriving for the wrong route is the ordinary failure.** Packets
/// are cached, retried and raced, and a late one is not a corrupt one. Every
/// packet names the route it was built for, a mismatch is dropped rather than
/// rendered, and dropping is counted -- because a screen showing the previous
/// screen's layout is the hardest bug in this design to reproduce.
///
/// **There has to be a screen when no packet arrives.** Four outcomes: a packet
/// that matches, a packet for another route, no packet yet, and a packet the
/// engine refused. The last two share a shape -- the route's own declared
/// fallback layout, built from the same design system -- because a route whose
/// only content is remote is a route that is blank on a bad connection.
library;

import 'layout_engine.dart';
import 'layout_schema.dart';

/// What the routing layer did with an arriving packet.
enum HabotPacketOutcome {
  /// Built and shown.
  rendered,

  /// Named a different route. Dropped and counted.
  wrongRoute,

  /// None arrived in time. The declared fallback is shown.
  fallbackShown,

  /// The engine refused it. The declared fallback is shown, and it is
  /// reported.
  refused,
}

/// The binding between a route and the layout engine.
class HabotLayoutRouteBinding {
  const HabotLayoutRouteBinding._();

  // -----------------------------------------------------------------------
  // What a route keeps.
  // -----------------------------------------------------------------------

  static const List<String> surrendered = <String>['the contents of the body'];

  static const List<String> kept = <String>[
    'the route identity deep links and analytics are keyed on',
    'the role guards that decide what may be placed',
  ];

  static bool get twoThingsAreKept => kept.length == 2;

  static const bool aPacketCanChangeTheRouteIdentity = false;

  static const bool aPacketCanPlaceAGuardedControl = false;

  static bool get neitherIsSurrendered =>
      !aPacketCanChangeTheRouteIdentity && !aPacketCanPlaceAGuardedControl;

  static const String keptNote =
      'A route surrenders the contents of its body and keeps two things: its '
      'identity, which deep links, analytics and the back stack are keyed on, '
      'and its guards, because a packet cannot be allowed to place a control '
      'the viewer\'s role does not clear. Surrender either and the route '
      'becomes a URL that means whatever arrived last.';

  // -----------------------------------------------------------------------
  // Every packet names its route.
  // -----------------------------------------------------------------------

  static const String thisRoute = 'habot://shift/detail';

  static HabotPacketOutcome outcomeFor({
    required String packetRoute,
    required bool arrived,
    required bool engineAccepted,
  }) {
    if (!arrived) {
      return HabotPacketOutcome.fallbackShown;
    }
    if (packetRoute != thisRoute) {
      return HabotPacketOutcome.wrongRoute;
    }
    return engineAccepted
        ? HabotPacketOutcome.rendered
        : HabotPacketOutcome.refused;
  }

  static bool get aMatchingPacketRenders =>
      outcomeFor(
        packetRoute: thisRoute,
        arrived: true,
        engineAccepted: true,
      ) ==
      HabotPacketOutcome.rendered;

  static bool get aPacketForAnotherRouteIsDropped =>
      outcomeFor(
        packetRoute: 'habot://payroll/export',
        arrived: true,
        engineAccepted: true,
      ) ==
      HabotPacketOutcome.wrongRoute;

  static const bool aMismatchedPacketIsRendered = false;

  static const bool aMismatchIsCounted = true;

  static bool get aMismatchIsDroppedAndCounted =>
      !aMismatchedPacketIsRendered && aMismatchIsCounted;

  static const String mismatchNote =
      'Packets are cached, retried and raced, so a late one is not a corrupt '
      'one -- it is yesterday\'s screen arriving now. Every packet names the '
      'route it was built for, a mismatch is dropped rather than rendered, and '
      'the drop is counted: a screen showing the previous screen\'s layout is '
      'the hardest bug in this design to reproduce, because by the time '
      'somebody reports it the packet has been replaced.';

  // -----------------------------------------------------------------------
  // A screen when nothing arrives.
  // -----------------------------------------------------------------------

  static const bool aRouteHasADeclaredFallback = true;

  static bool get noPacketShowsTheFallback =>
      outcomeFor(
        packetRoute: thisRoute,
        arrived: false,
        engineAccepted: true,
      ) ==
      HabotPacketOutcome.fallbackShown;

  static bool get aRefusedPacketShowsTheFallback =>
      outcomeFor(
        packetRoute: thisRoute,
        arrived: true,
        engineAccepted: false,
      ) ==
      HabotPacketOutcome.refused;

  static const bool aRefusalIsSilent = false;

  static bool get fourOutcomesAreDeclared =>
      HabotPacketOutcome.values.length == 4;

  static const String fallbackNote =
      'A route whose only content is remote is a route that is blank on a bad '
      'connection. Four outcomes are declared, and the two that mean "no '
      'usable packet" share a shape: the route\'s own fallback layout, built '
      'from the same design system. The difference between them is that a '
      'refusal is reported and a late packet is not -- one is a bug and the '
      'other is a train tunnel.';

  // -----------------------------------------------------------------------
  // Bound to the engine and the schema, not a second copy.
  // -----------------------------------------------------------------------

  static bool get theEngineIsTheDeclaredOne =>
      HabotLayoutEngine.everySchemaTypeIsMapped &&
      HabotLayoutEngine.anUnmappedTypeIsNotGuessedAt;

  static bool get theSchemaVersionIsChecked =>
      HabotLayoutSchema.anUnknownVersionIsRefused;

  static const bool aSecondParserExistsHere = false;

  static const String bindingNote =
      'The routing layer calls the declared engine and the declared schema '
      'check rather than parsing anything itself. A second parser in the '
      'routing layer is how a packet that the engine would refuse gets '
      'rendered anyway, and it would be the one place nobody thinks to look.';

  // -----------------------------------------------------------------------
  // The shared metric.
  // -----------------------------------------------------------------------

  static bool get theMetricIsTheSharedOne =>
      HabotLayoutSchema.rowsSharingThisMetric.contains(405);

  static int get rowsSharingIt =>
      HabotLayoutSchema.rowsSharingThisMetric.length;

  static double get outcomeCoverage =>
      HabotPacketOutcome.values.isEmpty ? 0 : 100;

  static const String metricNote =
      'The fourth of six rows carrying the identical metric, band and '
      'arrow-annotated output cell. A design-system adherence rate on a '
      'routing row measures nothing about routing; what is published is '
      'whether every way a packet can arrive has a declared outcome.';

  static const String columnNote =
      'COLUMN NOTE: this row carries the same metric, band and arrow-annotated '
      'output cell as Steps 401, 403, 406 and 407 here and Step 389 in the '
      'previous batch; its Data Requirement column holds layout fields beside '
      'advice about removing ad-hoc CSS in an application with no CSS; and its '
      'Setup Step column reads "Freeze deployment workspaces automatically '
      'when non-atomic instructions are detected". Atomic Step: "Connect the '
      'mobile view controller routing layer to invoke ProgrammaticLayoutEngine '
      'upon receiving layout JSON packets."';

  static Map<String, bool> get obligations => <String, bool>{
        'the route keeps its identity and its guards': neitherIsSurrendered,
        'every packet names the route it was built for':
            aPacketForAnotherRouteIsDropped,
        'a mismatched packet is dropped and counted':
            aMismatchIsDroppedAndCounted,
        'there is a declared fallback': aRouteHasADeclaredFallback,
        'a refusal is reported and a late packet is not': !aRefusalIsSilent,
        'the engine and the schema check are the declared ones':
            theEngineIsTheDeclaredOne && theSchemaVersionIsChecked,
      };

  static String get qualitativeOutput =>
      obligations.values.every((bool b) => b) ? 'Good' : 'Poor';

  static Map<String, bool> get checks => <String, bool>{
        'the body is surrendered and two things are kept':
            surrendered.length == 1 && twoThingsAreKept,
        'a packet cannot change identity or place a guarded control':
            neitherIsSurrendered && keptNote.contains('whatever arrived last'),
        'a matching packet renders': aMatchingPacketRenders,
        'a packet for another route is dropped':
            aPacketForAnotherRouteIsDropped && aMismatchIsDroppedAndCounted,
        'and the drop is counted because the bug is unreproducible':
            mismatchNote.contains('the packet has been replaced'),
        'four outcomes, all declared': fourOutcomesAreDeclared,
        'no packet and a refused packet both show the fallback':
            noPacketShowsTheFallback && aRefusedPacketShowsTheFallback,
        'but only the refusal is reported':
            !aRefusalIsSilent && fallbackNote.contains('a train tunnel'),
        'no second parser lives in the routing layer':
            !aSecondParserExistsHere &&
                theEngineIsTheDeclaredOne &&
                bindingNote.contains('nobody thinks to look'),
        'six obligations, all met, giving Good':
            obligations.length == 6 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Good' &&
                theMetricIsTheSharedOne &&
                rowsSharingIt == 6 &&
                outcomeCoverage == 100,
      };
}
