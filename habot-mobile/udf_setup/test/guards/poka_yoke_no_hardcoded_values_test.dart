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
};

const Set<String> _metricDeclarationSites = <String>{
  'lib/design_system/tokens/spacing_tokens.dart',
  'lib/design_system/tokens/grid_tokens.dart',
  'lib/design_system/tokens/shape_tokens.dart',
  'lib/design_system/tokens/elevation_tokens.dart',
  'lib/design_system/tokens/typography_tokens.dart',
};

/// Only file allowed to build a ThemeData.
const String _themeAdapterSite = 'lib/design_system/theme/habot_theme.dart';

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
    'POKA-YOKE :: zero hardcoded colours, spacing values or rogue ThemeData '
    'under lib/',
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

        // ---- RULE 3: no standalone theme construction ------------------
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
