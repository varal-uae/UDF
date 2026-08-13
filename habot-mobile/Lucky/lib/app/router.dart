import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/dashboard/presentation/screens/dashboard_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),

    // Dashboard — hosts AdaptivePanelRouter at the shell level.
    // On compact mobile, row taps push /dashboard/detail/:id as a full screen.
    // On wide layouts, detail renders inside the split panel — no route push.
    GoRoute(
      path: '/dashboard',
      builder: (_, __) => const DashboardScreen(),
      routes: [
        GoRoute(
          path: 'detail/:id',
          builder: (context, state) {
            final id = state.pathParameters['id'] ?? '';
            // TODO: Replace Scaffold with the feature's actual detail screen.
            return Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  iconSize: 28,
                  tooltip: 'Back to Table',
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: () => context.pop(),
                ),
                title: Text('Detail — $id'),
              ),
              body: Center(child: Text('Detail for $id')),
            );
          },
        ),
      ],
    ),
  ],
);
