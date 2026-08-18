/// Smoke test for the Habot app shell.
///
/// The Flutter counter template this replaced was removed when TTMCS-001
/// installed the Material 3 framework and made [HabotApp] the root widget.
/// Substantive verification lives in `test/aiss/` (one gate per atomic step)
/// and `test/guards/` (poka-yoke).
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/app.dart';
import 'package:udf_setup/design_system/theme/habot_theme_extension.dart';
import 'package:udf_setup/habot_shell_page.dart';

void main() {
  testWidgets('HabotApp boots with the design system theme applied', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const HabotApp());
    await tester.pumpAndSettle();

    // Since Steps 36-50 the app opens on its shell rather than on a probe.
    expect(find.byType(HabotShellPage), findsOneWidget);

    final BuildContext context = tester.element(
      find.byType(HabotShellPage),
    );
    final ThemeData theme = Theme.of(context);

    expect(theme.useMaterial3, isTrue);
    expect(theme.extension<HabotTokens>(), isNotNull);
    expect(tester.takeException(), isNull);
  });
}
