import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habot_lucky/core/components/loading_button.dart';

void main() {
  testWidgets('LoadingButton renders in idle state with correct label and icon', (tester) async {
    var pressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LoadingButton(
            label: 'Submit',
            icon: Icons.login,
            onPressed: () => pressed = true,
          ),
        ),
      ),
    );

    // Verify resting state elements
    expect(find.text('Submit'), findsOneWidget);
    expect(find.byIcon(Icons.login), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    // Tap and verify callback works
    await tester.tap(find.byType(LoadingButton));
    await tester.pump();
    expect(pressed, true);
  });

  testWidgets('LoadingButton displays loading graphic and updates label based on ServiceTrackingContext', (tester) async {
    var pressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LoadingButton(
            label: 'Submit',
            icon: Icons.login,
            isLoading: true,
            serviceContext: const ServiceTrackingContext(
              stateLabel: 'Connecting...',
              icon: Icons.sync,
            ),
            onPressed: () => pressed = true,
          ),
        ),
      ),
    );

    // Verify loading state graphics and service text
    expect(find.text('Submit'), findsNothing);
    expect(find.byIcon(Icons.login), findsNothing);
    expect(find.text('Connecting...'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Tap should be blocked while loading to prevent double-tap submits
    await tester.tap(find.byType(LoadingButton));
    await tester.pump();
    expect(pressed, false);
  });

  testWidgets('LoadingButton disables visually and physically when onPressed is null', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: LoadingButton(
            label: 'Submit',
            onPressed: null,
          ),
        ),
      ),
    );

    // Verify text is rendered mutely
    expect(find.text('Submit'), findsOneWidget);

    // Verify gesture detection doesn't respond
    final gestureDetector = tester.widget<GestureDetector>(find.byType(GestureDetector).first);
    expect(gestureDetector.onTap, isNull);
  });
}
