// ignore_for_file: avoid_print
import 'dart:io';

void main() {
  final hexColorRegex = RegExp(r'Color\s*\(\s*0x[0-9a-fA-F]+\s*\)');
  final materialColorsRegex = RegExp(r'\bColors\.[a-zA-Z0-9_]+');

  final uiDirectory = Directory('lib/ui');
  if (!uiDirectory.existsSync()) {
    print('lib/ui does not exist');
    return;
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

  print('TOTAL VIOLATIONS FOUND: ${violations.length}');
  for (final v in violations) {
    print(v);
  }
}
