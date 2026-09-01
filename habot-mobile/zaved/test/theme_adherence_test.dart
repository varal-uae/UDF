import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TTMCS-011 Architecture Poka-Yoke PR Blocker Test', () {
    final hexColorRegex = RegExp(r'Color\s*\(\s*0x[0-9a-fA-F]+\s*\)');
    final materialColorsRegex = RegExp(r'\bColors\.[a-zA-Z0-9_]+');

    test('All Dart files in lib/ui/ must strictly use Theme.of(context).colorScheme and zero hardcoded colors', () {
      final uiDirectory = Directory('lib/ui');

      if (!uiDirectory.existsSync()) {
        fail('Required UI directory "lib/ui" does not exist.');
      }

      final uiFiles = uiDirectory
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.dart'))
          .toList();

      final violations = <String>[];

      for (final file in uiFiles) {
        final lines = file.readAsLinesSync();

        for (int i = 0; i < lines.length; i++) {
          final line = lines[i];
          // Skip comments
          final trimmed = line.trim();
          if (trimmed.startsWith('//') || trimmed.startsWith('*') || trimmed.startsWith('/*')) {
            continue;
          }

          final hexMatches = hexColorRegex.allMatches(line);
          for (final match in hexMatches) {
            violations.add(
              '${file.path}:${i + 1} - Found hardcoded hex code: "${match.group(0)}"',
            );
          }

          final materialMatches = materialColorsRegex.allMatches(line);
          for (final match in materialMatches) {
            violations.add(
              '${file.path}:${i + 1} - Found standard Material color constant: "${match.group(0)}"',
            );
          }
        }
      }

      if (violations.isNotEmpty) {
        fail(
          'PR CODE BLOCKER TRIGGERED!\n'
          'Hardcoded hex codes and standard Material color constants are strictly forbidden in lib/ui/.\n'
          'All components must utilize the authorized Theme.of(context).colorScheme token registry.\n\n'
          'Violations Detected (${violations.length}):\n'
          '${violations.join('\n')}\n',
        );
      }
    });
  });
}
