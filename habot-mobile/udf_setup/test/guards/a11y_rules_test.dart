/// ACCESSIBILITY GUARD -- AISS Step 97 (GEN-04242), executable.
///
/// Requirement source, verbatim:
///   GEN-04242 Setup Step (Action): "Automated accessibility linter
///   integration in Cloud Build pipelines."
///
/// TRANSLATION RECORDED: there is no Cloud Build pipeline in this project.
/// There is `tool/verify_aiss.sh`, whose G-C stage runs `flutter test
/// test/guards` and fails the run on any violation. That is the same mechanism,
/// so the accessibility rules go there rather than into a second pipeline.
///
/// Per the decision recorded in the Steps 96-110 build order, these rules FAIL
/// THE BUILD, and any file in Steps 1-95 that violates one is fixed in this
/// batch rather than exempted. Four were found and all four were fixed:
///
///   lib/design_system/notifications/alert_panel.dart   -- unnamed icon button
///   lib/design_system/notifications/in_app_banner.dart -- unnamed icon button
///   lib/design_system/mto/isolated_viewport.dart       -- raw Image.network
///   lib/design_system/dashboard/skeleton.dart          -- silent loading state
///
/// ONE RULE WAS NARROWED RATHER THAN ONE FILE BEING EXEMPTED. The first
/// version of A11Y_UNNAMED_ICON_BUTTON matched any `icon: const Icon(Icons.x)`
/// and fired on `TextButton.icon(icon: ..., label: Text('Filter'))` in
/// habot_shell_page.dart -- which is correct code, because an icon beside a
/// visible label needs no name of its own. The rule was wrong, not the file,
/// so the rule was fixed and the false-positive case is now asserted against
/// below so it cannot come back.
///
/// The rules themselves are DATA, declared in
/// `lib/design_system/a11y/a11y_rules.dart`, so the Step 98 runbook can print
/// them and a developer can read what will fail without reading this file.
/// This file is only the scanner.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/a11y/a11y_rules.dart';

/// Blanks comments and string literals, so documentation that MENTIONS a
/// banned construct is never mistaken for code that uses one. Same technique
/// as the poka-yoke guard, kept deliberately separate: two guards that share a
/// helper are two guards that fail together when the helper is wrong.
String _stripCommentsAndStrings(String source) {
  final StringBuffer out = StringBuffer();
  int i = 0;
  while (i < source.length) {
    final String c = source[i];
    final String next = i + 1 < source.length ? source[i + 1] : '';

    if (c == '/' && next == '/') {
      while (i < source.length && source[i] != '\n') {
        i++;
      }
      continue;
    }
    if (c == '/' && next == '*') {
      i += 2;
      while (i < source.length - 1 &&
          !(source[i] == '*' && source[i + 1] == '/')) {
        i++;
      }
      i += 2;
      continue;
    }
    if (c == '"' || c == "'") {
      final String quote = c;
      final bool triple = source.startsWith(quote * 3, i);
      if (triple) {
        i += 3;
        while (i < source.length - 2 && !source.startsWith(quote * 3, i)) {
          i++;
        }
        i += 3;
      } else {
        i++;
        while (i < source.length && source[i] != quote) {
          if (source[i] == '\\') {
            i++;
          }
          i++;
        }
        i++;
      }
      out.write(' ');
      continue;
    }
    out.write(c);
    i++;
  }
  return out.toString();
}

int _lineOf(String source, int index) =>
    '\n'.allMatches(source.substring(0, index)).length + 1;

class _A11yViolation {
  const _A11yViolation(this.file, this.line, this.rule, this.snippet);

  final String file;
  final int line;
  final HabotA11yRule rule;
  final String snippet;

  @override
  String toString() => '$file:$line  [${rule.id}]  $snippet\n'
      '      -> ${rule.message}';
}

void main() {
  test('A11Y GUARD :: the rule set is well formed', () {
    // Every rule names the step it protects, explains the alternative, and
    // gives a reason for any exemption. A rule set that decays does so here
    // first: someone adds an exemption without saying why.
    expect(
      HabotA11yRules.isWellFormed,
      isTrue,
      reason:
          'A rule is missing its owner, its message is too short to be '
          'actionable, or an exemption has no rationale.',
    );
    expect(HabotA11yRules.all.length, greaterThanOrEqualTo(6));
    final Set<String> ids =
        HabotA11yRules.all.map((HabotA11yRule r) => r.id).toSet();
    expect(
      ids.length,
      HabotA11yRules.all.length,
      reason: 'Two rules share an id; the runbook would report one of them '
          'twice and the other not at all.',
    );
  });

  test('A11Y GUARD :: no accessibility violations under lib/', () {
    final Directory lib = Directory('lib');
    expect(lib.existsSync(), isTrue, reason: 'run from the project root');

    final List<_A11yViolation> violations = <_A11yViolation>[];

    for (final FileSystemEntity entity in lib.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) {
        continue;
      }
      final String path = entity.path.replaceAll('\\', '/');
      final String code = _stripCommentsAndStrings(entity.readAsStringSync());

      for (final HabotA11yRule rule in HabotA11yRules.all) {
        if (!rule.appliesTo(path)) {
          continue;
        }
        for (final RegExpMatch m in rule.pattern.allMatches(code)) {
          violations.add(
            _A11yViolation(path, _lineOf(code, m.start), rule, m.group(0)!),
          );
        }
      }
    }

    if (violations.isNotEmpty) {
      final StringBuffer buffer = StringBuffer()
        ..writeln(
          'ACCESSIBILITY GUARD FAILED -- ${violations.length} violation(s):',
        );
      for (final _A11yViolation v in violations) {
        buffer.writeln('  $v');
      }
      fail(buffer.toString());
    }
  });

  test('A11Y GUARD :: the guard itself detects planted violations', () {
    // A guard that can never fail is not a guard.
    const String planted = '''
      final a = Image.network(url);
      final b = IconButton(onPressed: f, icon: const Icon(Icons.close));
      final c = MediaQuery(data: d.copyWith(textScaleFactor: 1.0), child: w);
      final e = BlockSemantics(child: w);
      Widget build(BuildContext context) { return ExcludeSemantics(child: w); }
      final g = ButtonStyle(minimumSize: WidgetStatePropertyAll(Size(20, 20)));
    ''';
    final String stripped = _stripCommentsAndStrings(planted);

    for (final String id in <String>[
      'A11Y_RAW_IMAGE',
      'A11Y_UNNAMED_ICON_BUTTON',
      'A11Y_TEXT_SCALING_SUPPRESSED',
      'A11Y_RAW_SEMANTIC_MODAL',
      'A11Y_SEMANTICS_EXCLUDED_AT_ROOT',
      'A11Y_LITERAL_TOUCH_SIZE',
    ]) {
      expect(
        HabotA11yRules.byId(id).pattern.hasMatch(stripped),
        isTrue,
        reason: '$id did not fire on a planted violation',
      );
    }

    // ...and does NOT fire on the sanctioned alternatives.
    const String sanctioned = '''
      final a = HabotImage(image: p, alt: 'A signed delivery note');
      final b = HabotDecorativeImage(image: p);
      final c = IconButton(icon: const Icon(Icons.close, semanticLabel: 'Close'));
      final d = HabotFocusTrap(onDismiss: f, label: 'Filters', child: w);
      final e = Size(w, h);
      final g = TextButton.icon(
        onPressed: f,
        icon: const Icon(Icons.filter_list),
        label: const Text('Filter'),
      );
    ''';
    final String ok = _stripCommentsAndStrings(sanctioned);
    expect(HabotA11yRules.byId('A11Y_RAW_IMAGE').pattern.hasMatch(ok), isFalse);
    expect(
      HabotA11yRules.byId('A11Y_UNNAMED_ICON_BUTTON').pattern.hasMatch(ok),
      isFalse,
      reason: 'an Icon carrying a semanticLabel is exactly what the rule asks '
          'for and must not be flagged, and neither is an icon sitting beside '
          'a visible label -- the false positive this rule was narrowed to '
          'stop',
    );
    expect(
      HabotA11yRules.byId('A11Y_LITERAL_TOUCH_SIZE').pattern.hasMatch(ok),
      isFalse,
    );

    // And does not fire on documentation that merely mentions a construct.
    const String docOnly = '''
      /// Use HabotImage rather than Image.network(url), and never write
      /// icon: const Icon(Icons.close) without a semanticLabel.
      final label = "Image.network(url)";
    ''';
    final String doc = _stripCommentsAndStrings(docOnly);
    expect(HabotA11yRules.byId('A11Y_RAW_IMAGE').pattern.hasMatch(doc), isFalse);
    expect(
      HabotA11yRules.byId('A11Y_UNNAMED_ICON_BUTTON').pattern.hasMatch(doc),
      isFalse,
    );
  });
}
