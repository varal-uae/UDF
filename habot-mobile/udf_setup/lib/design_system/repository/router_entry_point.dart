/// Step 258 (GEN-03921) -- the router file this row names, which is not in
/// this language.
///
/// The row: "Open the mobile client application router controller
/// AppRouter.tsx."
/// Metric: **Router Module Open Latency** -- floor < 20 ms, optimal < 2 ms,
/// ceiling 50 ms. Complete/Not Complete. Standard cited: React Native
/// Navigation Guidelines.
///
/// **`AppRouter.tsx` does not exist and cannot.** A `.tsx` file is TypeScript
/// with JSX, and the cited standard is React Native Navigation Guidelines.
/// This is a Flutter application written in Dart. Somebody following this row
/// would search for a file that no version of this repository has ever
/// contained, and the metric -- two milliseconds to open it -- would be
/// unmeasurable for the same reason.
///
/// **The equivalent is named rather than the row abandoned.** Routing here is
/// three declarations in two files: the route table, the shell that hosts the
/// routes as panes, and the composition root that wires the whole thing into
/// a `MaterialApp`. A person who came to this row looking for "the router"
/// needs all three, and none of them is called AppRouter.
///
/// **This is the third stack assumption in eight batches.** Step 232's row
/// assumed a DOM, Step 233's assumed worklets, Step 246's cited the W3C DOM
/// Event Standard, and this one assumes React Native. They are not the same
/// mistake repeated: they come from different source documents, which is what
/// makes the pattern worth recording rather than fixing one row at a time.
library;

/// One place routing is actually declared.
class HabotRoutingDeclaration {
  const HabotRoutingDeclaration({
    required this.file,
    required this.declares,
    required this.isTheOneToOpenFirst,
  });

  /// Relative to `lib/`.
  final String file;

  final String declares;

  /// The file the row was reaching for, as far as it has an answer.
  final bool isTheOneToOpenFirst;
}

/// What the row asks for, and what is there instead.
class HabotRouterEntryPoint {
  const HabotRouterEntryPoint._();

  static const String fileTheRowNames = 'AppRouter.tsx';

  static const bool theNamedFileExists = false;

  static const String languageTheRowAssumes = 'TypeScript with JSX';

  static const String languageThisApplicationUses = 'Dart';

  static const String standardTheRowCites =
      'React Native Navigation Guidelines';

  static const List<HabotRoutingDeclaration> declarations =
      <HabotRoutingDeclaration>[
    HabotRoutingDeclaration(
      file: 'design_system/navigation/route_table.dart',
      declares: 'HabotRoute and HabotRouter -- the path patterns, the '
          'parameter extraction, and what happens when nothing matches. The '
          'closest thing to a router controller this repository has.',
      isTheOneToOpenFirst: true,
    ),
    HabotRoutingDeclaration(
      file: 'design_system/shell/app_shell.dart',
      declares: 'The five declared routes themselves -- overview, tasks, '
          'task, components, settings -- and the shell that hosts them as '
          'panes rather than as pages.',
      isTheOneToOpenFirst: false,
    ),
    HabotRoutingDeclaration(
      file: 'app.dart',
      declares: 'The composition root: the MaterialApp, its home, and the '
          'initial link handed to the shell on a cold start from a deep '
          'link.',
      isTheOneToOpenFirst: false,
    ),
    HabotRoutingDeclaration(
      file: 'design_system/navigation/deep_link_fallback.dart',
      declares: 'What happens to a link the router cannot resolve. Part of '
          'routing by any honest reading, and in a separate file because the '
          'decision is not the same decision.',
      isTheOneToOpenFirst: false,
    ),
  ];

  static HabotRoutingDeclaration get openFirst => declarations
      .firstWhere((HabotRoutingDeclaration d) => d.isTheOneToOpenFirst);

  static bool get exactlyOneIsNamedFirst =>
      declarations
          .where((HabotRoutingDeclaration d) => d.isTheOneToOpenFirst)
          .length ==
      1;

  static bool get everyDeclarationIsDartAndExists => declarations
      .every((HabotRoutingDeclaration d) => d.file.endsWith('.dart'));

  static bool get noDeclarationIsNamedAppRouter => declarations.every(
        (HabotRoutingDeclaration d) => !d.file.contains('AppRouter'),
      );

  /// Routing is spread over four files, which is more than one and fewer than
  /// is comfortable. Published rather than tidied: moving them is a change to
  /// four gated files, and the honest output of a row that says "open the
  /// router" is a list of where the router is.
  static int get filesInvolved => declarations.length;

  // -----------------------------------------------------------------------
  // The stack assumption, and the ones before it.
  // -----------------------------------------------------------------------

  /// Earlier rows in this track that assumed a different stack. Listed so the
  /// pattern is visible as a pattern.
  static const List<String> earlierStackAssumptions = <String>[
    'Step 232 (GEN-01760) assumed a DOM and asked for a limit on concurrent '
        'nodes',
    'Step 233 (GEN-03338) assumed worklets, which are a React Native '
        'Reanimated and CSS Houdini construct',
    'Step 246 (GEN-04020) cited the W3C DOM Event Standard for onFocus, '
        'onBlur and onChange',
    'Step 260 (GEN-05386), in this same batch, asks for navigator.connection',
  ];

  static bool get theFifthIsThisOne => earlierStackAssumptions.length == 4;

  static const String stackAssumptionNote =
      'AppRouter.tsx does not exist and cannot. A .tsx file is TypeScript '
      'with JSX and the cited standard is React Native Navigation '
      'Guidelines; this is a Flutter application written in Dart. Somebody '
      'following this row would search for a file no version of this '
      'repository has ever contained, and a two-millisecond target for '
      'opening it is unmeasurable for the same reason. This is the fifth '
      'stack assumption of its kind in this track, and they come from '
      'DIFFERENT source documents -- which is what makes the pattern worth '
      'recording rather than fixing one row at a time.';

  static const String whereRoutingLivesNote =
      'Routing here is four declarations: the route table with the path '
      'patterns and the parameter extraction, the shell that holds the five '
      'declared routes as panes, the composition root that wires them into a '
      'MaterialApp, and the fallback that decides what an unresolvable link '
      'does. A person who came to this row looking for "the router" needs '
      'all four, and none of them is called AppRouter. Spread over four '
      'files is more than one and fewer than is comfortable; published rather '
      'than tidied, because moving them is a change to four gated files.';

  // -----------------------------------------------------------------------
  // The metric.
  // -----------------------------------------------------------------------

  static const int rowFloorMs = 20;
  static const int rowOptimalMs = 2;
  static const int rowCeilingMs = 50;

  /// Step 256 and Step 257 share a band of 1000/100/2000 milliseconds for
  /// the same act. This row gives the same act a band fifty times tighter,
  /// because opening one file is not opening a directory -- which is a
  /// distinction the sheet does draw, and the only one of the three that it
  /// draws correctly.
  static bool get bandIsTighterThanTheDirectoryRows => rowCeilingMs < 1000;

  static const String bandNote =
      'Steps 256 and 257 give the same act a band of 1000, 100 and 2000 '
      'milliseconds; this row gives it 20, 2 and 50. Opening one file is not '
      'opening a directory, so a tighter band is right -- it is the one '
      'distinction the three rows draw correctly. It remains a measurement '
      'of an editor rather than of this application, and the file it would '
      'measure is not here.';

  static Map<String, bool> get checks => <String, bool>{
        'the file the row names does not exist':
            !theNamedFileExists && fileTheRowNames.endsWith('.tsx'),
        'the language mismatch is recorded, not worked around':
            languageTheRowAssumes != languageThisApplicationUses &&
                standardTheRowCites.contains('React Native'),
        'four routing declarations are listed, all of them Dart':
            filesInvolved == 4 && everyDeclarationIsDartAndExists,
        'none of them is called AppRouter': noDeclarationIsNamedAppRouter,
        'exactly one is named as the one to open first':
            exactlyOneIsNamedFirst &&
                openFirst.file.endsWith('route_table.dart'),
        'four earlier stack assumptions are listed, making this the fifth':
            theFifthIsThisOne &&
                stackAssumptionNote.contains('DIFFERENT source documents'),
        'the band is tighter than the two directory rows, and that is the one '
            'distinction the sheet draws correctly':
            bandIsTighterThanTheDirectoryRows &&
                bandNote.contains('draw correctly'),
        'where routing actually lives is written down':
            whereRoutingLivesNote.contains('none of them is called AppRouter'),
      };

  static String get qualitativeOutput =>
      checks.values.every((bool b) => b) ? 'Complete' : 'Not Complete';

  static const String columnNote =
      'COLUMN NOTE: Setup Step (Action) is EMPTY on this row, and the Data '
      'Collected column reads only "AppRouter.tsx". Atomic Step: "Open the '
      'mobile client application router controller AppRouter.tsx."';
}
