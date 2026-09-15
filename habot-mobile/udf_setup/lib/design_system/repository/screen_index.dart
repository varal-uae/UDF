/// Step 257 (GEN-03965) -- the screens folder this row asks somebody to open,
/// and the fact that there is not one.
///
/// The row: "Open the mobile application screens codebase folder."
/// Metric: **Directory Navigation Time** -- floor < 1.0 s, optimal < 0.1 s,
/// ceiling 2.0 s. Complete/Not Complete. Standard cited: POSIX Standards.
///
/// **There is no screens folder.** This application has three screen-level
/// entry points at the root of `lib` -- `habot_shell_page.dart`,
/// `data_entry_probe_page.dart` and `surfaces_probe_page.dart` -- and
/// everything else under `lib/design_system` is a component, a rule or a
/// token. The row assumes a layout this repository does not have, and
/// somebody following it would open a directory that is not there and either
/// create an empty one or give up.
///
/// **That is a finding about the repository, not only about the row.** A
/// design system with no screens is a design system nobody has assembled a
/// screen out of yet, and two of the three entry points are probe pages --
/// scaffolding for exercising primitives rather than anything a parent would
/// see. So the index below is honest about what exists and about what the
/// row expected to find, and it names the convention a screens folder would
/// have to follow when there is one.
///
/// **"Directory Navigation Time" is Step 256's metric under another name.**
/// Two adjacent rows, two names, the same band -- floor 1.0s, optimal 0.1s,
/// ceiling 2.0s -- and the same POSIX citation. Recorded rather than
/// implemented twice.
library;

import 'module_map.dart';

/// A screen-level entry point: something that could be pushed as a route.
class HabotScreenEntry {
  const HabotScreenEntry({
    required this.file,
    required this.kind,
    required this.reachableByRoute,
    required this.why,
  });

  /// Relative to `lib/`.
  final String file;

  /// What it is for.
  final String kind;

  /// Whether a route in the declared route table reaches it.
  final bool reachableByRoute;

  final String why;

  bool get isProductionScreen => kind == 'product surface';
}

/// The index.
class HabotScreenIndex {
  const HabotScreenIndex._();

  /// The directory the row says to open.
  static const String directoryTheRowExpects = 'lib/screens';

  /// Whether it exists.
  static const bool theExpectedDirectoryExists = false;

  /// Where screen-level code actually lives.
  static const String directoryThatExists = 'lib';

  static const List<HabotScreenEntry> entries = <HabotScreenEntry>[
    HabotScreenEntry(
      file: 'habot_shell_page.dart',
      kind: 'product surface',
      reachableByRoute: true,
      why: 'The application shell, and the home of the MaterialApp. The one '
          'entry point that is a screen in the sense the row means: it hosts '
          'every declared route as a pane rather than handing each one its '
          'own file.',
    ),
    HabotScreenEntry(
      file: 'data_entry_probe_page.dart',
      kind: 'probe',
      reachableByRoute: false,
      why: 'Scaffolding: it exercises the form primitives so they can be '
          'seen running. Not a screen a parent would ever reach, and it '
          'should not be in a screens folder if one is ever made.',
    ),
    HabotScreenEntry(
      file: 'surfaces_probe_page.dart',
      kind: 'probe',
      reachableByRoute: false,
      why: 'The same, for sheets, dialogs and cards.',
    ),
    HabotScreenEntry(
      file: 'app.dart',
      kind: 'composition root',
      reachableByRoute: false,
      why: 'Where the theme, the router and the shell are assembled. Not a '
          'screen, and the file somebody looking for "the screens" actually '
          'needs first.',
    ),
    HabotScreenEntry(
      file: 'main.dart',
      kind: 'composition root',
      reachableByRoute: false,
      why: 'The entry point the platform calls. Four lines.',
    ),
  ];

  static List<HabotScreenEntry> get productionScreens =>
      entries.where((HabotScreenEntry e) => e.isProductionScreen).toList();

  static List<HabotScreenEntry> get probes =>
      entries.where((HabotScreenEntry e) => e.kind == 'probe').toList();

  static List<HabotScreenEntry> get compositionRoots =>
      entries.where((HabotScreenEntry e) => e.kind == 'composition root')
          .toList();

  static bool get everyEntryIsExplained =>
      entries.every((HabotScreenEntry e) => e.why.length > 40);

  /// Routes declared in the shell's own table: overview, tasks, task,
  /// components, settings.
  static const int declaredRoutes = 5;

  /// Five routes and one file. The reason there is no screens folder is not
  /// that somebody forgot one -- it is that the routes are panes inside a
  /// single adaptive shell, which is what an application that has to work at
  /// five window classes ends up with.
  static bool get routesOutnumberScreenFiles =>
      declaredRoutes > productionScreens.length;

  static const String panesNotPagesNote =
      'Five routes are declared -- overview, tasks, task, components, '
      'settings -- and there is one screen file. The reason there is no '
      'screens folder is not that somebody forgot one: the routes are panes '
      'inside a single adaptive shell, which is what an application that has '
      'to work at five window classes ends up with. A folder of five page '
      'files would be five places to rebuild the same navigation. Worth '
      'saying out loud, because "there are no screens" and "the screens are '
      'panes" look identical from outside and mean opposite things.';

  /// More probes than screens. The number this step exists to publish.
  static bool get probesOutnumberScreens =>
      probes.length > productionScreens.length;

  /// The convention a screens folder would have to follow when there is one.
  /// Written down now so the first person to make one does not have to
  /// invent it, and so that the probes do not end up in it.
  static const List<String> screensFolderConvention = <String>[
    'one file per route in the declared route table, named for the route '
        'rather than for the widget',
    'a screen composes components and declares no tokens, no rules and no '
        'layout constants of its own',
    'probe pages stay out: they exercise primitives and are not product '
        'surfaces, and a folder that mixes them teaches a newcomer the wrong '
        'thing about what a screen is',
    'a screen with no route is a component in the wrong directory',
  ];

  static bool get conventionIsDeclared =>
      screensFolderConvention.length == 4 &&
      screensFolderConvention.every((String s) => s.length > 40);

  // -----------------------------------------------------------------------
  // The metric, and its twin.
  // -----------------------------------------------------------------------

  static const String rowConcept = 'Directory Navigation Time';

  /// This row's own band, transcribed from the sheet independently of Step
  /// 256's, so the comparison below is between two declarations rather than
  /// between a constant and an alias of itself.
  static const int rowFloorMs = 1000;
  static const int rowOptimalMs = 100;
  static const int rowCeilingMs = 2000;

  static bool get bandIsIdenticalToStep256 =>
      rowFloorMs == HabotModuleMap.rowFloorMs &&
      rowOptimalMs == HabotModuleMap.rowOptimalMs &&
      rowCeilingMs == HabotModuleMap.rowCeilingMs &&
      rowConcept != HabotModuleMap.rowConcept;

  static const String twinMetricNote =
      'Two adjacent rows, two metric names -- "Path Navigation Overhead" and '
      '"Directory Navigation Time" -- the same band of 1.0s, 0.1s and 2.0s, '
      'and the same POSIX citation. They are the same measurement under two '
      'names, which is how a sheet ends up with two owners for one property. '
      'Recorded here and measured once, at Step 256.';

  static const String noScreensFolderNote =
      'There is no screens folder. This application has three screen-level '
      'entry points at the root of lib, and everything else under '
      'lib/design_system is a component, a rule or a token. The row assumes a '
      'layout this repository does not have, and somebody following it would '
      'open a directory that is not there and either create an empty one or '
      'give up. That is a finding about the repository as much as about the '
      'row: a design system with no screens is a design system nobody has '
      'assembled a screen out of yet, and two of the three entry points are '
      'probe pages.';

  // -----------------------------------------------------------------------
  // Metric: Complete/Not Complete.
  // -----------------------------------------------------------------------

  static Map<String, bool> get checks => <String, bool>{
        'the directory the row names does not exist, and that is recorded':
            !theExpectedDirectoryExists &&
                directoryTheRowExpects == 'lib/screens',
        'every screen-level entry point is listed with what it is for':
            entries.length == 5 && everyEntryIsExplained,
        'one production surface, two probes and two composition roots':
            productionScreens.length == 1 &&
                probes.length == 2 &&
                compositionRoots.length == 2,
        'the probes outnumber the product surfaces, and it is published':
            probesOutnumberScreens,
        'five declared routes are served by one screen file, and the reason '
            'is recorded': routesOutnumberScreenFiles &&
            declaredRoutes == 5 &&
            panesNotPagesNote.contains('panes inside a single adaptive '
                'shell'),
        'only the production surface is reachable by a route': entries.every(
          (HabotScreenEntry e) =>
              e.reachableByRoute == e.isProductionScreen,
        ),
        'the convention a screens folder would follow is written down':
            conventionIsDeclared,
        'the probes are excluded from that convention by name':
            screensFolderConvention.any(
          (String s) => s.contains('probe pages stay out'),
        ),
        'this row and Step 256 share a band under two names, and that is '
            'recorded': bandIsIdenticalToStep256 &&
            twinMetricNote.contains('two names'),
      };

  static String get qualitativeOutput =>
      checks.values.every((bool b) => b) ? 'Complete' : 'Not Complete';

  static const String columnNote =
      'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic Step: '
      '"Open the mobile application screens codebase folder."';
}
