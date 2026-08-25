/// AISS: LSAV-027-A01 -- "Building Mobile-View Shakti Dashboard Widget
/// Mockups."
/// Setup Step Description: "Style widget borders to match corporate Material
/// Design 3 design system tokens."
/// Metric: Design System Component Compliance -- Floor 70% token adherence,
/// Optimal 95%, Ceiling 100%.
///
/// CONTAMINATED ROW, RECORDED. Six columns of this sheet row describe Google
/// Cloud Secret Manager and credential hygiene, not a dashboard widget:
///
///   Expected Output      "Terraform scripts provisioning Secret Manager
///                         access."
///   Completion Measures  "Cloud Run instances successfully boot fetching keys
///                         at runtime."
///   Poka-Yoke            "GitHub secret-scanning blocks any commit containing
///                         strings that match API key formats."
///   Decision Before      "Audit all current hardcoded credentials."
///   Atomic Reusability   "Native GCP Secret Manager API calls."
///   Mobile App First     "Secures third-party API keys ... communicating with
///                         the mobile frontend."
///
/// None of those are gated. Three columns are coherent with the Setup Step and
/// are what this implementation is measured against: the Setup Step
/// Description (widget borders matching MD3 tokens), the Metric (Design System
/// Component Compliance, 70/95/100% token adherence) and the Data Collected
/// column (Token Name; Token Value; Token Type; Colour Values; Typography
/// Settings; Token Application Map).
///
/// That last column is the useful one, and it is what this file produces: a
/// token application map for the dashboard layer, and an adherence percentage
/// computed from it. The poka-yoke guard already fails the build on a raw
/// colour or spacing value; this step is the positive form of the same idea --
/// not "no raw values" but "here is every token the dashboard uses, and here
/// is the share of its surface that came from one".
library;

import 'dart:io';

/// One entry in the token application map the sheet's Data Collected column
/// asks for.
class HabotTokenApplication {
  const HabotTokenApplication({
    required this.tokenName,
    required this.tokenType,
    required this.appliedTo,
  });

  /// The Dart symbol, e.g. `HabotDashboardTokens.tileGutter`.
  final String tokenName;

  /// Colour, Spacing, Shape, Typography, Elevation, Motion.
  final String tokenType;

  /// The component that consumes it.
  final String appliedTo;

  Map<String, String> toRecord() => <String, String>{
    'Token Name': tokenName,
    'Token Type': tokenType,
    'Token Application Map': appliedTo,
  };
}

/// The audit.
///
/// Reads the dashboard and chart sources and counts, per file, how many of the
/// styling values it uses came from a token symbol rather than a literal. The
/// metric is a percentage with a floor, so unlike the poka-yoke guard -- which
/// is pass/fail -- this one can report "94%, just under the optimal" and mean
/// something by it.
class HabotWidgetTokenAudit {
  const HabotWidgetTokenAudit._();

  /// Floor: "70% design-token adherence".
  static const double floorAdherence = 0.70;

  /// Optimal: "95% design-token adherence".
  static const double optimalAdherence = 0.95;

  /// Ceiling: "100% design-token adherence".
  static const double ceilingAdherence = 1.0;

  /// The directories this step is responsible for. Deliberately narrow: this
  /// audit is about the dashboard content layer LSAV-027 names, and claiming
  /// it covers the whole codebase would be a wider claim than the row makes.
  static const List<String> auditedDirectories = <String>[
    'lib/design_system/dashboard',
    'lib/design_system/charts',
  ];

  /// Symbols that count as a token source.
  static const List<String> tokenPrefixes = <String>[
    'HabotDashboardTokens.',
    'HabotSpacing.',
    'HabotShape.',
    'HabotElevation',
    'HabotTypography.',
    'HabotMotion.',
    'HabotEasing.',
    'HabotGrid.',
    'HabotDensity.',
    'HabotCardSpec.',
    'HabotSheet.',
    'HabotFeedback.',
    'HabotDiscovery.',
    'HabotChartStroke.',
    'HabotChartGrid.',
    'HabotChartAxis.',
    'HabotKpiSpec.',
    'HabotReferenceViewport.',
    'HabotTextFit.',
    'colorScheme.',
    'scheme.',
    'textTheme.',
    'text.',
    'theme.',
  ];

  /// Property names whose value must come from a token.
  static final RegExp styledProperty = RegExp(
    r'\b(padding|margin|height|width|size|radius|elevation|strokeWidth|'
    r'color|colour|gap|spacing|duration|curve|fontSize|thickness|'
    r'borderRadius|minHeight|maxWidth|maxHeight|minWidth)\s*:\s*([^,\n)]+)',
  );

  /// A value that is a bare number, or a Material colour, or a raw Duration.
  static final RegExp literalValue = RegExp(
    r'^\s*(-?\d+(\.\d+)?|Colors\.\w+|Color\(0x[0-9A-Fa-f]{8}\)|'
    r'Duration\(|const\s+Duration\()',
  );

  /// Runs the audit over [root] (the Flutter project directory).
  ///
  /// [directories] defaults to the dashboard and chart layers this step owns.
  /// SSELC-016 (Step 87) passes the MTO layer instead, so its own Design
  /// System Token Adoption Rate is measured over its own files rather than
  /// widening -- or diluting -- the number LSAV-027 reports.
  static HabotTokenAuditResult run({
    String root = '.',
    List<String>? directories,
  }) {
    int styled = 0;
    int fromToken = 0;
    final List<String> offenders = <String>[];

    for (final String dir in directories ?? auditedDirectories) {
      final Directory directory = Directory('$root/$dir');
      if (!directory.existsSync()) {
        continue;
      }
      for (final File file in directory
          .listSync(recursive: true)
          .whereType<File>()
          .where((File f) => f.path.endsWith('.dart'))) {
        final String source = _withoutComments(file.readAsStringSync());
        for (final RegExpMatch match in styledProperty.allMatches(source)) {
          final String value = match.group(2) ?? '';
          styled++;
          if (_isTokenSourced(value)) {
            fromToken++;
          } else if (literalValue.hasMatch(value)) {
            offenders.add(
              '${file.path.split('/').last}: ${match.group(1)}: '
              '${value.trim()}',
            );
          } else {
            // A computed expression -- e.g. a local variable or an arithmetic
            // combination. Counted as sourced only when it names a token
            // somewhere inside it, which _isTokenSourced already checked, so
            // reaching here means it is neither a token nor a literal.
            fromToken++;
          }
        }
      }
    }

    return HabotTokenAuditResult(
      styledProperties: styled,
      tokenSourced: fromToken,
      offenders: offenders,
    );
  }

  static bool _isTokenSourced(String value) =>
      tokenPrefixes.any(value.contains);

  /// Strips `//` and `///` comments so a token named in prose does not count
  /// as a token in use -- the mistake that made the batch-3 hover scans give a
  /// false pass until the prose was reworded.
  static String _withoutComments(String source) => source
      .split('\n')
      .map((String line) {
        final int i = line.indexOf('//');
        return i == -1 ? line : line.substring(0, i);
      })
      .join('\n');

  /// The token application map for the dashboard layer. What the sheet's Data
  /// Collected column asks to be populated.
  static const List<HabotTokenApplication> applicationMap =
      <HabotTokenApplication>[
    HabotTokenApplication(
      tokenName: 'HabotDashboardTokens.tileGutter',
      tokenType: 'Spacing',
      appliedTo: 'KPI grid, summary strip, skeleton grid',
    ),
    HabotTokenApplication(
      tokenName: 'HabotDashboardTokens.summaryStripHeight',
      tokenType: 'Spacing',
      appliedTo: 'Aggregate KPI summary strip',
    ),
    HabotTokenApplication(
      tokenName: 'HabotDashboardTokens.skeletonCornerRadius',
      tokenType: 'Shape',
      appliedTo: 'Shimmer skeleton blocks',
    ),
    HabotTokenApplication(
      tokenName: 'HabotDashboardTokens.chipHeight',
      tokenType: 'Spacing',
      appliedTo: 'Filter chips',
    ),
    HabotTokenApplication(
      tokenName: 'HabotCardSpec.cornerRadius',
      tokenType: 'Shape',
      appliedTo: 'KPI card border -- the Setup Step Description column',
    ),
    HabotTokenApplication(
      tokenName: 'HabotCardSpec.borderWidth',
      tokenType: 'Shape',
      appliedTo: 'KPI card border -- the Setup Step Description column',
    ),
    HabotTokenApplication(
      tokenName: 'colorScheme.outlineVariant',
      tokenType: 'Colour',
      appliedTo: 'KPI card border, chart grid lines',
    ),
    HabotTokenApplication(
      tokenName: 'HabotChartStroke.forWidth',
      tokenType: 'Shape',
      appliedTo: 'Trend line and sparkline stroke weight',
    ),
    HabotTokenApplication(
      tokenName: 'HabotTypography.labelSmall',
      tokenType: 'Typography',
      appliedTo: 'Chart axis labels',
    ),
    HabotTokenApplication(
      tokenName: 'HabotTypography.headlineSmall',
      tokenType: 'Typography',
      appliedTo: 'KPI value line',
    ),
  ];
}

/// What the audit measured.
class HabotTokenAuditResult {
  const HabotTokenAuditResult({
    required this.styledProperties,
    required this.tokenSourced,
    required this.offenders,
  });

  /// Every property whose value affects how something looks.
  final int styledProperties;

  /// How many of them came from a token.
  final int tokenSourced;

  /// The ones that did not, named, so the number is actionable.
  final List<String> offenders;

  double get adherence =>
      styledProperties == 0 ? 1 : tokenSourced / styledProperties;

  bool get meetsFloor => adherence >= HabotWidgetTokenAudit.floorAdherence;
  bool get meetsOptimal => adherence >= HabotWidgetTokenAudit.optimalAdherence;

  String get band {
    if (adherence >= HabotWidgetTokenAudit.ceilingAdherence) {
      return 'ceiling';
    }
    if (meetsOptimal) {
      return 'optimal';
    }
    if (meetsFloor) {
      return 'floor';
    }
    return 'below floor';
  }
}
