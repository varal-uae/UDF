import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SCTAS-013 Architecture Token Gate: Hex Code Prohibition', () {
    final hexColorRegex = RegExp(r'Color\s*\(\s*0x[0-9a-fA-F]+\s*\)');

    test('All Dart source files outside authorized design token definitions must physically forbid raw hex Color()', () {
      final libDirectory = Directory('lib');
      if (!libDirectory.existsSync()) {
        fail('Required directory "lib" does not exist.');
      }

      // Authorized token source files
      final authorizedTokenFiles = [
        'lib/theme/app_design_tokens.dart',
      ].map((p) => p.replaceAll('/', Platform.pathSeparator)).toList();

      final dartFiles = libDirectory
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.dart'))
          .toList();

      final violations = <String>[];

      for (final file in dartFiles) {
        final normalizedPath = file.path.replaceAll('\\', '/');
        // If file is an authorized token registry, skip hex check
        if (authorizedTokenFiles.any((auth) => file.path.endsWith(auth) || normalizedPath.endsWith('lib/theme/app_design_tokens.dart'))) {
          continue;
        }

        final lines = file.readAsLinesSync();
        for (int i = 0; i < lines.length; i++) {
          final line = lines[i];
          final trimmed = line.trim();
          if (trimmed.startsWith('//') || trimmed.startsWith('*') || trimmed.startsWith('/*')) {
            continue;
          }

          final matches = hexColorRegex.allMatches(line);
          for (final match in matches) {
            violations.add(
              '${file.path}:${i + 1} - Found hardcoded hex code "${match.group(0)}"',
            );
          }
        }
      }

      if (violations.isNotEmpty) {
        fail(
          'SCTAS-013 TOKEN GATE FAILED!\n'
          'Raw hex Color(0x...) declarations are physically forbidden outside authorized token files.\n'
          'Move all color definitions to lib/theme/app_design_tokens.dart and reference them semantically.\n\n'
          'Violations Detected (${violations.length}):\n'
          '${violations.join('\n')}\n',
        );
      }
    });
  });
}
