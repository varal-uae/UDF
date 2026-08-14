import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habot_lucky/core/components/voice_search_bar.dart';

// BPTR-0269-A05 — Permission denial must not break text entry.

void main() {
  testWidgets('text entry works when voice permission unavailable', (tester) async {
    var lastQuery = '';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HabotVoiceSearchBar(
            onQueryChanged: (q) => lastQuery = q,
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(SearchBar), 'tax record');
    await tester.pump(const Duration(milliseconds: 350));

    expect(lastQuery, 'tax record');
  });

  testWidgets('mic tap shows fallback snackbar without breaking field', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: HabotVoiceSearchBar(),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Voice search'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Voice search unavailable — continue typing instead.'),
        findsOneWidget);

    await tester.enterText(find.byType(SearchBar), 'still works');
    await tester.pump();
    expect(find.text('still works'), findsOneWidget);
  });
}
