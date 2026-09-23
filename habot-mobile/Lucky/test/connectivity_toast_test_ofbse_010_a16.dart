// OFBSE-010-A16 — Connectivity Detection to Toast Logic Unit Tests.
// Verifies that network state changes trigger the correct Material 3 SnackBar overlays and that local error wrappers intercept transport faults gracefully.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// --- Mock Connectivity Listener Wrapper ---

enum NetworkState { connected, disconnected }

class MockConnectivityListener {
  final StreamController<NetworkState> _controller =
      StreamController<NetworkState>.broadcast();

  Stream<NetworkState> get onNetworkStateChanged => _controller.stream;

  void emitState(NetworkState state) {
    _controller.add(state);
  }

  void dispose() {
    _controller.close();
  }
}

// --- Fallback UI Component (Offline Toast) ---

class OfflineToastWrapper extends StatefulWidget {
  final MockConnectivityListener listener;
  final Widget child;

  const OfflineToastWrapper({
    super.key,
    required this.listener,
    required this.child,
  });

  @override
  State<OfflineToastWrapper> createState() => _OfflineToastWrapperState();
}

class _OfflineToastWrapperState extends State<OfflineToastWrapper> {
  late StreamSubscription<NetworkState> _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = widget.listener.onNetworkStateChanged.listen(_handleState);
  }

  void _handleState(NetworkState state) {
    if (!mounted) return;

    if (state == NetworkState.disconnected) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          key: const Key('offline_snackbar'),
          content: const Text('You are currently offline.'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(days: 1), // Persistent until reconnected
          margin: const EdgeInsets.all(16.0),
        ),
      );
    } else if (state == NetworkState.connected) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          key: const Key('online_snackbar'),
          content: const Text('Connection restored.'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(16.0),
        ),
      );
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

// --- Test Harness ---

class _TestApp extends StatelessWidget {
  final MockConnectivityListener listener;

  const _TestApp({required this.listener});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: OfflineToastWrapper(
        listener: listener,
        child: const Scaffold(
          body: Center(child: Text('Main Content')),
        ),
      ),
    );
  }
}

// --- Unit & Widget Tests ---

void main() {
  group('OFBSE-010-A16: Connectivity-Detection-to-Toast Logic', () {
    late MockConnectivityListener mockListener;

    setUp(() {
      mockListener = MockConnectivityListener();
    });

    tearDown(() {
      mockListener.dispose();
    });

    testWidgets(
        'displays persistent error snackbar when network disconnects (Poka-Yoke)',
        (WidgetTester tester) async {
      await tester.pumpWidget(_TestApp(listener: mockListener));

      // Simulate transport fault / edge drop
      mockListener.emitState(NetworkState.disconnected);
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('offline_snackbar')), findsOneWidget);
      expect(find.text('You are currently offline.'), findsOneWidget);

      final snackBar = tester.widget<SnackBar>(find.byType(SnackBar).first);
      expect(snackBar.behavior, SnackBarBehavior.floating);
      expect(snackBar.duration, const Duration(days: 1));
    });

    testWidgets(
        'displays transient success snackbar when network reconnects and dismisses it',
        (WidgetTester tester) async {
      await tester.pumpWidget(_TestApp(listener: mockListener));

      // Go offline first
      mockListener.emitState(NetworkState.disconnected);
      await tester.pumpAndSettle();

      // Reconnect
      mockListener.emitState(NetworkState.connected);
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('online_snackbar')), findsOneWidget);
      expect(find.text('Connection restored.'), findsOneWidget);

      // Verify auto-dismiss after 3 seconds
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('online_snackbar')), findsNothing);
    });

    testWidgets('hides previous snackbar before showing new state',
        (WidgetTester tester) async {
      await tester.pumpWidget(_TestApp(listener: mockListener));

      mockListener.emitState(NetworkState.disconnected);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('offline_snackbar')), findsOneWidget);

      mockListener.emitState(NetworkState.connected);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('offline_snackbar')), findsNothing);
      expect(find.byKey(const Key('online_snackbar')), findsOneWidget);
    });

    testWidgets('applies Material 3 color tokens correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(_TestApp(listener: mockListener));

      mockListener.emitState(NetworkState.disconnected);
      await tester.pumpAndSettle();

      final BuildContext ctx = tester.element(find.byType(Scaffold));
      final SnackBar snackBar =
          tester.widget<SnackBar>(find.byKey(const Key('offline_snackbar')));

      expect(snackBar.backgroundColor, Theme.of(ctx).colorScheme.error);

      mockListener.emitState(NetworkState.connected);
      await tester.pumpAndSettle();

      final SnackBar onlineSnackBar =
          tester.widget<SnackBar>(find.byKey(const Key('online_snackbar')));
      expect(onlineSnackBar.backgroundColor, Theme.of(ctx).colorScheme.primary);
    });

    test('MockConnectivityListener emits states in correct sequence', () async {
      final states = <NetworkState>[];
      final sub = mockListener.onNetworkStateChanged.listen(states.add);

      mockListener.emitState(NetworkState.disconnected);
      mockListener.emitState(NetworkState.connected);
      mockListener.emitState(NetworkState.disconnected);

      await Future<void>.delayed(Duration.zero);

      expect(states, [
        NetworkState.disconnected,
        NetworkState.connected,
        NetworkState.disconnected,
      ]);

      await sub.cancel();
    });
  });
}
