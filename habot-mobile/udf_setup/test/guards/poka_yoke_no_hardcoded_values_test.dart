/// POKA-YOKE GUARD -- the mistake-proofing the step sheet demands, executable.
///
/// Requirement sources, verbatim:
///   TTMCS-001 Mistake-Proofing: "Frontend style check sweeps block project
///     compilation steps if local code scripts introduce standalone CSS layout
///     code."
///   RCGLA-001 Completion Measures: "Continuous integration code verification
///     pipelines report zero instances of hardcoded hex colors or spacing
///     values."
///   RCGLA-001 Mistake-Proofing: "Style repository checks automatically fail if
///     layout padding variables use non-standard grid intervals."
///   TTMCS-004 Mistake-Proofing: "Style builders throw compilation errors if
///     raw, untokenized hex codes find their way into layout sheets."
///   BPTR-0422 What Standardized Must Be Done: "Motion and animation design
///     tokens" + Completion: "Standardized CSS transitions defined."
///   BPTR-0128 Mistake-Proofing: "compiler constraints instantly flag compile
///     errors if a developer creates a clickable component without specifying
///     explicit touch padding parameters."
///   MUFCE-028 Setup Step: "Mandatory removal of all mouse hover tooltips and
///     replacement with touch long-press modal sheets." + 4 Substeps #1:
///     "Strip all .onHover logic actions from mobile codebase templates."
///   SSTLA-012 Poka-Yoke: "Code linters block views that do not extend the
///     master layout wrapper." + Self-Chasing: "Missing layout hooks stop
///     compilation, keeping bad code out of testing builds."
///
/// This scans every `.dart` file under `lib/` and fails the build on any
/// violation. The token declaration files are the only sanctioned place a raw
/// value may appear.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Files allowed to declare raw values -- the source of truth itself.
const Set<String> _colourDeclarationSites = <String>{
  'lib/design_system/tokens/color_tokens.dart',
  // The dark elevation ladder is a colour declaration too: its literals are
  // WCAG-audited and re-derived by TTMCS-005-G2.
  'lib/design_system/tokens/elevation_tokens.dart',
  // AISS Step 105 (GEN-00368): the high-contrast schemes are a third colour
  // declaration of the same shape, audited by the same Step 4 engine at the
  // AAA floor rather than the AA one.
  'lib/design_system/tokens/high_contrast_tokens.dart',
};

const Set<String> _metricDeclarationSites = <String>{
  'lib/design_system/tokens/spacing_tokens.dart',
  'lib/design_system/interaction/touch_standards.dart',
  'lib/design_system/tokens/grid_tokens.dart',
  'lib/design_system/tokens/shape_tokens.dart',
  'lib/design_system/tokens/elevation_tokens.dart',
  'lib/design_system/tokens/typography_tokens.dart',
};

/// Only file allowed to build a ThemeData.
const String _themeAdapterSite = 'lib/design_system/theme/habot_theme.dart';

/// Only file allowed to declare a raw Duration or reference a raw Curve.
/// BPTR-0422 and REF-377 both write their tokens here.
const String _motionTokenSite = 'lib/design_system/tokens/motion_tokens.dart';

/// MUFCE-028: a requirement about code that must NOT exist.
///
/// Both rules below are absolute -- there is no exempt site. A hover tooltip
/// is unreachable on a touch device, so information that only appears on hover
/// is, on a phone, information that does not exist. The replacement is
/// `HabotMetadataDisclosure`, which opens a bottom drawer on long-press and on
/// a quick tap of the trailing icon.
///
/// This is why the header's overflow menu is a sheet rather than a
/// `PopupMenuButton`: the framework wraps that button in a `Tooltip`
/// unconditionally, with no API to switch it off.
final RegExp _tooltipWidget = RegExp(r'\bTooltip\s*\(');
final RegExp _hoverCallback = RegExp(r'\bonHover\s*:');

/// SSTLA-012: only the master layout wrapper may construct a Scaffold.
///
/// RCGLA-018-G4 already checks that every screen class *mentions*
/// HabotMasterScaffold. This is the other half: no file may build a bare
/// Scaffold and call it a screen. Together they close the loop the sheet's
/// poka-yoke describes.
const String _scaffoldSite = 'lib/design_system/layout/master_scaffold.dart';
final RegExp _rogueScaffold = RegExp(r'(?<!Habot)(?<!Master)\bScaffold\s*\(');

/// AISS Step 154 (GEN-04825): the FAB must hide when the keyboard opens, and
/// the row's OPTIMAL asks for "automated enforcement (no silent bypass)".
///
/// A widget that hides itself covers the failure mode; the next screen written
/// with a raw FloatingActionButton silently does not, and nothing notices.
/// This rule is the enforcement half: only HabotKeyboardAwareFab may construct
/// one, so a FAB that could be tapped through the keyboard fails the build
/// rather than a review.
const String _fabSite =
    'lib/design_system/interaction/keyboard_aware_fab.dart';
final RegExp _rogueFab = RegExp(r'\bFloatingActionButton\s*\(');

/// Colour names that carry no brand meaning and are therefore permitted.
const Set<String> _allowedMaterialColors = <String>{'transparent'};

/// Constructors whose numeric arguments are layout metrics.
const List<String> _metricConstructors = <String>[
  'EdgeInsets.all',
  'EdgeInsets.only',
  'EdgeInsets.symmetric',
  'EdgeInsets.fromLTRB',
  'BorderRadius.circular',
  'Radius.circular',
  'SizedBox',
];

class _Violation {
  _Violation(this.file, this.line, this.rule, this.snippet);
  final String file;
  final int line;
  final String rule;
  final String snippet;

  @override
  String toString() => '$file:$line  [$rule]  $snippet';
}

/// Blanks out comments and string literals so documentation that *mentions*
/// a hex code or a number is never mistaken for code that uses one.
String _stripCommentsAndStrings(String source) {
  final StringBuffer out = StringBuffer();
  int i = 0;
  while (i < source.length) {
    final String c = source[i];
    final String next = i + 1 < source.length ? source[i + 1] : '';

    // Line comment.
    if (c == '/' && next == '/') {
      while (i < source.length && source[i] != '\n') {
        i++;
      }
      continue;
    }
    // Block comment.
    if (c == '/' && next == '*') {
      i += 2;
      while (i + 1 < source.length && !(source[i] == '*' && source[i + 1] == '/')) {
        if (source[i] == '\n') {
          out.write('\n');
        }
        i++;
      }
      i += 2;
      continue;
    }
    // String literal (single or double quoted, incl. escapes).
    if (c == "'" || c == '"') {
      final String quote = c;
      i++;
      while (i < source.length) {
        if (source[i] == '\\') {
          i += 2;
          continue;
        }
        if (source[i] == quote) {
          i++;
          break;
        }
        if (source[i] == '\n') {
          out.write('\n');
        }
        i++;
      }
      out.write('""');
      continue;
    }
    out.write(c);
    i++;
  }
  return out.toString();
}

/// Splits the argument list starting at [openParen] into top-level arguments.
/// Returns null if the parentheses are unbalanced.
List<String>? _splitArgs(String source, int openParen) {
  int depth = 0;
  final List<String> args = <String>[];
  final StringBuffer current = StringBuffer();
  for (int i = openParen; i < source.length; i++) {
    final String c = source[i];
    if (c == '(' || c == '[' || c == '{') {
      depth++;
      if (depth == 1) {
        continue;
      }
    } else if (c == ')' || c == ']' || c == '}') {
      depth--;
      if (depth == 0) {
        args.add(current.toString());
        return args;
      }
    }
    if (depth == 1 && c == ',') {
      args.add(current.toString());
      current.clear();
      continue;
    }
    if (depth >= 1) {
      current.write(c);
    }
  }
  return null;
}

final RegExp _numericLiteral = RegExp(r'^-?\d+(\.\d+)?$');

int _lineOf(String source, int index) =>
    '\n'.allMatches(source.substring(0, index)).length + 1;

void main() {
  test(
    'POKA-YOKE :: zero hardcoded colours, spacing values, motion values or '
    'rogue ThemeData under lib/',
    () {
      final Directory libDir = Directory('lib');
      expect(
        libDir.existsSync(),
        isTrue,
        reason: 'Run this from the Flutter project root.',
      );

      final List<_Violation> violations = <_Violation>[];

      final List<File> dartFiles = libDir
          .listSync(recursive: true)
          .whereType<File>()
          .where((File f) => f.path.endsWith('.dart'))
          .toList()
        ..sort((File a, File b) => a.path.compareTo(b.path));

      expect(
        dartFiles,
        isNotEmpty,
        reason: 'Guard found no Dart files -- it would pass vacuously.',
      );

      for (final File file in dartFiles) {
        final String path = file.path.replaceAll('\\', '/');
        final String code = _stripCommentsAndStrings(file.readAsStringSync());

        // ---- RULE 1: raw colour literals -------------------------------
        if (!_colourDeclarationSites.contains(path)) {
          for (final RegExpMatch m
              in RegExp(r'Color\(\s*0x[0-9A-Fa-f]{6,8}\s*\)').allMatches(code)) {
            violations.add(
              _Violation(
                path,
                _lineOf(code, m.start),
                'RAW_COLOR_LITERAL',
                m.group(0)!,
              ),
            );
          }
          for (final RegExpMatch m
              in RegExp(r'Color\.fromARGB\(').allMatches(code)) {
            violations.add(
              _Violation(
                path,
                _lineOf(code, m.start),
                'RAW_COLOR_LITERAL',
                'Color.fromARGB(...)',
              ),
            );
          }
          for (final RegExpMatch m
              in RegExp(r'\bColors\.(\w+)').allMatches(code)) {
            if (_allowedMaterialColors.contains(m.group(1))) {
              continue;
            }
            violations.add(
              _Violation(
                path,
                _lineOf(code, m.start),
                'UNTOKENISED_MATERIAL_COLOR',
                m.group(0)!,
              ),
            );
          }
        }

        // ---- RULE 2: raw spacing / radius values -----------------------
        if (!_metricDeclarationSites.contains(path)) {
          for (final String ctor in _metricConstructors) {
            final RegExp pattern = RegExp(
              '\\b${RegExp.escape(ctor)}\\s*\\(',
            );
            for (final RegExpMatch m in pattern.allMatches(code)) {
              final int open = code.indexOf('(', m.start);
              final List<String>? args = _splitArgs(code, open);
              if (args == null) {
                continue;
              }
              for (final String rawArg in args) {
                final String arg = rawArg.trim();
                if (arg.isEmpty) {
                  continue;
                }
                final int colon = arg.indexOf(':');
                final String value = colon == -1
                    ? arg
                    : arg.substring(colon + 1).trim();
                if (_numericLiteral.hasMatch(value)) {
                  violations.add(
                    _Violation(
                      path,
                      _lineOf(code, m.start),
                      'RAW_SPACING_VALUE',
                      '$ctor(... $arg ...)',
                    ),
                  );
                }
              }
            }
          }
        }

        // ---- RULE 3: no raw motion values ------------------------------
        //
        // Refined during Step 66: the rule exists to stop HARDCODED durations,
        // and `Duration(milliseconds: total ~/ count)` is not one -- it is a
        // computed value that has no token to come from. The literal form is
        // still banned. Anything whose argument is not a bare number passes.
        if (path != _motionTokenSite) {
          for (final RegExpMatch m in RegExp(
            r'Duration\(\s*(?:milliseconds|seconds|microseconds)\s*:'
            r'\s*\d+(?:\.\d+)?\s*\)',
          ).allMatches(code)) {
            violations.add(
              _Violation(
                path,
                _lineOf(code, m.start),
                'RAW_DURATION',
                'Duration(...) -- use a HabotMotion token',
              ),
            );
          }
          for (final RegExpMatch m in RegExp(
            r'\bCurves\.\w+',
          ).allMatches(code)) {
            violations.add(
              _Violation(
                path,
                _lineOf(code, m.start),
                'RAW_CURVE',
                '${m.group(0)} -- use a HabotEasing token',
              ),
            );
          }
        }

        // ---- RULE 4: no hover affordances (MUFCE-028) ------------------
        for (final RegExpMatch m in _tooltipWidget.allMatches(code)) {
          violations.add(
            _Violation(
              path,
              _lineOf(code, m.start),
              'HOVER_TOOLTIP',
              'Tooltip(...) -- use HabotMetadataDisclosure.show(...) instead',
            ),
          );
        }
        for (final RegExpMatch m in _hoverCallback.allMatches(code)) {
          violations.add(
            _Violation(
              path,
              _lineOf(code, m.start),
              'HOVER_CALLBACK',
              'onHover: -- hover is unreachable on touch; bind long-press',
            ),
          );
        }

        // ---- RULE 5: only the master wrapper builds a Scaffold ---------
        if (path != _scaffoldSite) {
          for (final RegExpMatch m in _rogueScaffold.allMatches(code)) {
            violations.add(
              _Violation(
                path,
                _lineOf(code, m.start),
                'ROGUE_SCAFFOLD',
                'Scaffold(...) may only be built in $_scaffoldSite -- use '
                    'HabotMasterScaffold',
              ),
            );
          }
        }

        // ---- RULE 6: the FAB is keyboard-aware or it does not exist ----
        if (path != _fabSite) {
          for (final RegExpMatch m in _rogueFab.allMatches(code)) {
            violations.add(
              _Violation(
                path,
                _lineOf(code, m.start),
                'ROGUE_FAB',
                'FloatingActionButton(...) may only be built in $_fabSite -- '
                    'use HabotKeyboardAwareFab, which cannot be tapped '
                    'through an open keyboard',
              ),
            );
          }
        }

        // ---- RULE 7: no standalone theme construction ------------------
        if (path != _themeAdapterSite) {
          for (final RegExpMatch m
              in RegExp(r'\bThemeData\s*\(').allMatches(code)) {
            violations.add(
              _Violation(
                path,
                _lineOf(code, m.start),
                'ROGUE_THEME_CONSTRUCTION',
                'ThemeData(...) may only be built in $_themeAdapterSite',
              ),
            );
          }
        }
      }

      if (violations.isNotEmpty) {
        final StringBuffer buffer = StringBuffer()
          ..writeln('POKA-YOKE FAILED -- ${violations.length} violation(s):');
        for (final _Violation v in violations) {
          buffer.writeln('  $v');
        }
        fail(buffer.toString());
      }
    },
  );

  test('POKA-YOKE :: the guard itself detects a planted violation', () {
    // A guard that can never fail is not a guard. Prove the detector works.
    const String planted = '''
      final x = Color(0xFFAB12CD);
      const p = EdgeInsets.all(13);
      final t = ThemeData();
      const d = Duration(milliseconds: 250);
      const c = Curves.bounceIn;
      final w = Tooltip(message: m, child: c);
      final h = InkWell(onHover: (v) {}, child: c);
      final s = Scaffold(body: c);
    ''';
    final String stripped = _stripCommentsAndStrings(planted);
    expect(
      RegExp(r'Color\(\s*0x[0-9A-Fa-f]{6,8}\s*\)').hasMatch(stripped),
      isTrue,
    );
    final int open = stripped.indexOf('(', stripped.indexOf('EdgeInsets.all'));
    final List<String>? args = _splitArgs(stripped, open);
    expect(args, isNotNull);
    expect(_numericLiteral.hasMatch(args!.first.trim()), isTrue);
    expect(RegExp(r'\bThemeData\s*\(').hasMatch(stripped), isTrue);
    expect(
      RegExp(
        r'Duration\(\s*(?:milliseconds|seconds|microseconds)\s*:',
      ).hasMatch(stripped),
      isTrue,
    );
    expect(RegExp(r'\bCurves\.\w+').hasMatch(stripped), isTrue);
    expect(_tooltipWidget.hasMatch(stripped), isTrue);
    expect(_hoverCallback.hasMatch(stripped), isTrue);
    expect(_rogueScaffold.hasMatch(stripped), isTrue);
    // ...and does NOT fire on the design system's own wrapper.
    expect(_rogueScaffold.hasMatch('HabotMasterScaffold('), isFalse);

    // And prove it does NOT fire on documentation that merely mentions values.
    const String docOnly = '''
      /// Applies a gradient from #F2F6F9 to #EEF2F6 with EdgeInsets.all(16).
      // Color(0xFF00538A) is the brand primary.
      final label = "EdgeInsets.all(24)";
    ''';
    final String docStripped = _stripCommentsAndStrings(docOnly);
    expect(
      RegExp(r'Color\(\s*0x[0-9A-Fa-f]{6,8}\s*\)').hasMatch(docStripped),
      isFalse,
    );
    expect(docStripped.contains('EdgeInsets.all'), isFalse);
  });
}
