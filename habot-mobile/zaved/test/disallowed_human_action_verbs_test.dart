import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ETMDI-022-17 Architecture Static Linter: Disallowed Human-Action Verbs', () {
    // Disallowed human-centric / ambiguous UI action terms in button/action contexts
    final disallowedTermsRegex = RegExp(
      r'''\b(click here|tap here|press here|please click|hit here|punch here)\b''',
      caseSensitive: false,
    );

    test('Source files in lib/ui/ must strictly avoid disallowed human-action terms in action components', () {
      final uiDir = Directory('lib/ui');
      if (!uiDir.existsSync()) {
        fail('Required UI directory "lib/ui" does not exist.');
      }

      final dartFiles = uiDir
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))
          .toList();

      final violations = <String>[];

      for (final file in dartFiles) {
        final lines = file.readAsLinesSync();
        for (int i = 0; i < lines.length; i++) {
          final line = lines[i];
          final trimmed = line.trim();
          if (trimmed.startsWith('//') || trimmed.startsWith('*') || trimmed.startsWith('/*')) {
            continue;
          }

          final matches = disallowedTermsRegex.allMatches(line);
          for (final match in matches) {
            violations.add(
              '${file.path}:${i + 1} - Found disallowed human action term: "${match.group(0)}"',
            );
          }
        }
      }

      if (violations.isNotEmpty) {
        fail(
          'ETMDI-022-17 STATIC LINTER RULE TRIGGERED!\n'
          'Disallowed ambiguous human-action terms were detected in engineering source files.\n'
          'All mobile action triggers must utilize approved machine-action verbs.\n\n'
          'Violations Detected (${violations.length}):\n'
          '${violations.join('\n')}\n',
        );
      }
    });
  });
}
