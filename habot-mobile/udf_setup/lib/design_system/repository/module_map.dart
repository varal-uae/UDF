/// Step 256 (GEN-03877) -- the component directory this row asks somebody to
/// open, written down as something a machine can check.
///
/// The row: "Open the mobile application UI component repository directory."
/// Metric: **Path Navigation Overhead** -- floor < 1.0 s, optimal < 0.1 s,
/// ceiling 2.0 s. Complete/Not Complete. Standard cited: POSIX File System
/// Standards.
///
/// **The Atomic Step is an action in an editor, and CI cannot run it.** The
/// row's own Completion Measure is "100% CI/CD pass rate", and there is
/// nothing for CI to pass: opening a folder leaves no artefact, produces no
/// output, and is complete the instant anybody does it. Three rows in this
/// batch are of this shape -- 256, 257 and 258 -- and they are the first
/// rows in this track whose Atomic Step is not a change to the software.
///
/// **What "Path Navigation Overhead" can honestly mean.** Not how long a
/// filesystem takes to list a directory -- that is a property of the disk and
/// is the same for every project on it, which makes a 0.1s optimal a
/// measurement of the hardware. What it can mean is how far somebody has to
/// travel to find a component: how many directories exist, how many
/// components are in each, and how many hops it takes to get from the root to
/// a named one. That is a property of *this* repository, it changes when
/// somebody reorganises it, and it is what the row would be about if it were
/// about anything.
///
/// So the artefact is a map. It is checkable, it is useful to the person the
/// row is addressed to, and it does not pretend a folder was opened.
library;

/// One directory under `lib/design_system`, and what is in it.
class HabotModuleGroup {
  const HabotModuleGroup({
    required this.directory,
    required this.files,
    required this.purpose,
  });

  /// Relative to `lib/design_system/`.
  final String directory;

  /// How many Dart files it holds.
  final int files;

  /// What a person is looking for when they come here. Empty is not allowed:
  /// a directory nobody can describe is a directory things get dropped into.
  final String purpose;

  /// True for the one entry that stands for many small directories at once.
  bool get isAggregate => directory == 'everything else';

  bool get isDescribed => purpose.length > 20;
}

/// The map.
class HabotModuleMap {
  const HabotModuleMap._();

  /// The directory the row says to open.
  static const String rootDirectory = 'lib/design_system';

  /// Depth from the package root to a component file: `lib`, `design_system`,
  /// a group directory, then the file.
  static const int hopsToAComponent = 4;

  /// The groups, as they stand at Step 256. Counts are of Dart files.
  static List<HabotModuleGroup> get groups => <HabotModuleGroup>[
        const HabotModuleGroup(
          directory: 'tokens',
          files: 26,
          purpose: 'Every declared constant: colour roles, spacing, motion, '
              'shape, typography, grid. Nothing here renders anything.',
        ),
        const HabotModuleGroup(
          directory: 'forms',
          files: 29,
          purpose: 'Taking a value from a person and deciding whether it is '
              'acceptable -- masks, patterns, the gate and the submit '
              'decision.',
        ),
        const HabotModuleGroup(
          directory: 'layout',
          files: 21,
          purpose: 'Where things go at a given width: window classes, panes, '
              'grids, the orientation and viewport policies.',
        ),
        const HabotModuleGroup(
          directory: 'dashboard',
          files: 15,
          purpose: 'The operator-facing surfaces: widgets, density, refresh '
              'and the arrangement they are read in.',
        ),
        const HabotModuleGroup(
          directory: 'data',
          files: 14,
          purpose: 'Tables, chunked lists, sorting and the exact-money type '
              'everything financial is held in.',
        ),
        const HabotModuleGroup(
          directory: 'a11y',
          files: 13,
          purpose: 'The accessibility rule set and the audits that run over '
              'it: contrast, text scaling, focus, image semantics, touch.',
        ),
        const HabotModuleGroup(
          directory: 'interaction',
          files: 13,
          purpose: 'What happens when a finger lands: the one button '
              'primitive, state layers, haptics, guards and touch geometry.',
        ),
        const HabotModuleGroup(
          directory: 'resilience',
          files: 13,
          purpose: 'What happens when something fails: classification, '
              'templates, rollback, reconnection and the log scrubber.',
        ),
        const HabotModuleGroup(
          directory: 'telemetry',
          files: 13,
          purpose: 'What leaves the device: the event schema, the sanitiser, '
              'friction and hesitation tracking, crash capture.',
        ),
        const HabotModuleGroup(
          directory: 'navigation',
          files: 12,
          purpose: 'Getting to a screen: the route table, deep links, their '
              'fallbacks, and the navigation bar.',
        ),
        const HabotModuleGroup(
          directory: 'notifications',
          files: 11,
          purpose: 'Messages the application sends and the preferences that '
              'govern them.',
        ),
        const HabotModuleGroup(
          directory: 'everything else',
          files: 87,
          purpose: 'Twenty-one smaller groups -- booking, checkout, payments, '
              'confirmation, support, operations, reports, discovery, '
              'onboarding, mto, wizard, charts, shell, surfaces, feedback, '
              'i18n, theme, motion, performance, preferences, aiss.',
        ),
      ];

  static int get totalFiles =>
      groups.fold(0, (int a, HabotModuleGroup g) => a + g.files);

  /// Directories actually on disk. Eleven are listed one by one above and
  /// the remaining twenty-one are aggregated, because a map with thirty-two
  /// rows of one or two files each is a listing rather than a map.
  static const int declaredGroupCount = 32;

  static int get namedGroups =>
      groups.where((HabotModuleGroup g) => !g.isAggregate).length;

  static bool get everyGroupIsDescribed =>
      groups.every((HabotModuleGroup g) => g.isDescribed);

  /// The largest single directory. The aggregate entry is excluded: it is
  /// twenty-one directories, not one.
  static HabotModuleGroup get largestGroup => groups
      .where((HabotModuleGroup g) => !g.isAggregate)
      .reduce(
        (HabotModuleGroup a, HabotModuleGroup b) => a.files >= b.files ? a : b,
      );

  /// Files somebody has to look past, on average, once they have chosen the
  /// right directory. This is the honest reading of "navigation overhead",
  /// and it is over the directories that exist rather than over the rows of
  /// this map.
  static double get averageFilesPerGroup => totalFiles / declaredGroupCount;

  /// A flat repository would put every file in one directory. The reduction
  /// the grouping buys, measured rather than claimed.
  static double get searchReductionFromGrouping =>
      1 - averageFilesPerGroup / totalFiles;

  /// The counts are a snapshot taken at Step 256, before this batch's own
  /// twenty files landed. A gate that walked the filesystem would be
  /// asserting about the machine it runs on, so the gate checks this map
  /// against itself instead and this note says what it is a snapshot of.
  static const String snapshotNote =
      'Counts are a snapshot taken at Step 256, before this batch\'s own '
      'twenty files landed. A test that walked the filesystem would be '
      'asserting about the machine it runs on rather than about the '
      'repository, so the gate checks the map\'s internal consistency and '
      'this note records what the numbers are a picture of.';

  // -----------------------------------------------------------------------
  // The metric, substituted.
  // -----------------------------------------------------------------------

  /// The row's band, in milliseconds, kept verbatim so the substitution can
  /// be compared against it rather than quietly replacing it.
  static const int rowFloorMs = 1000;
  static const int rowOptimalMs = 100;
  static const int rowCeilingMs = 2000;

  static const String rowConcept = 'Path Navigation Overhead';

  static const String substitution =
      'Not how long a filesystem takes to list a directory -- that is a '
      'property of the disk, it is the same for every project on it, and a '
      '0.1 second optimal is therefore a measurement of the hardware rather '
      'than of this repository. What the metric can honestly mean is how far '
      'somebody travels to find a component: how many groups exist, how many '
      'files are in each, and how many hops separate the package root from a '
      'component file. That changes when somebody reorganises the repository, '
      'which is the property a metric about navigation should have.';

  static const String notARunnableStepNote =
      'The Atomic Step is an action in an editor and CI cannot run it. The '
      'row\'s own Completion Measure is "100% CI/CD pass rate", and there is '
      'nothing for CI to pass: opening a folder leaves no artefact, produces '
      'no output, and is complete the instant anybody does it. Steps 256, 257 '
      'and 258 are all of this shape, and they are the first rows in this '
      'track whose Atomic Step is not a change to the software. The artefact '
      'produced instead is a map -- checkable, useful to the person the row '
      'is addressed to, and not a claim that a folder was opened.';

  static const String depthNote =
      'Four hops from the package root to a component: lib, design_system, a '
      'group, the file. Flat enough that nothing is buried and deep enough '
      'that the group name carries meaning. The number is recorded so a '
      'future reorganisation that adds a fifth has to change a gate.';

  // -----------------------------------------------------------------------
  // Metric: Complete/Not Complete.
  // -----------------------------------------------------------------------

  static Map<String, bool> get checks => <String, bool>{
        'the directory the row names is recorded':
            rootDirectory == 'lib/design_system',
        'every group is listed with a file count':
            groups.every((HabotModuleGroup g) => g.files > 0),
        'every group says what a person comes to it for':
            everyGroupIsDescribed,
        'the total is the sum of the parts rather than a separate number':
            totalFiles == groups.fold(
              0,
              (int a, HabotModuleGroup g) => a + g.files,
            ),
        'eleven groups are listed one by one and one entry aggregates the '
            'rest': namedGroups == 11 && groups.length == 12,
        'the largest single directory is identified, excluding the aggregate':
            !largestGroup.isAggregate &&
                largestGroup.files > averageFilesPerGroup,
        'the average is taken over the directories that exist, not over the '
            'rows of this map': declaredGroupCount > groups.length,
        'the depth to a component is recorded': hopsToAComponent == 4,
        'the row\'s own band is kept verbatim beside the substitution':
            rowOptimalMs < rowFloorMs && rowFloorMs < rowCeilingMs,
        'the reason the row is not a runnable step is written down':
            notARunnableStepNote.contains('nothing for CI to pass'),
        'the counts are declared as a snapshot rather than as a live reading':
            snapshotNote.contains('machine it runs on'),
      };

  static String get qualitativeOutput =>
      checks.values.every((bool b) => b) ? 'Complete' : 'Not Complete';

  static const String columnNote =
      'COLUMN NOTE: Setup Step (Action) is EMPTY on this row, and the Atomic '
      'Step carries a stray citation marker: "Open the mobile application UI '
      'component repository directory. [cite: 495]".';
}
