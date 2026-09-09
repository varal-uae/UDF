// ARCPE-001 — Login Card Component with accessible touch targets and responsive single-column layout.
// Implements Material 3 design: 16px outer margins, 48px minimum interactive dimensions, and typography scale constraints.
import 'package:flutter/material.dart';

/// A responsive single-column login card for ARCPE-001.
/// Enforces 48px touch targets, 16px grid margins on mobile, and collapses
/// multi-column structures to single rows on tight screens.
class Arcpe001LoginCard extends StatefulWidget {
  const Arcpe001LoginCard({super.key, this.onSubmit});

  final ValueChanged<LoginCredentials>? onSubmit;

  @override
  State<Arcpe001LoginCard> createState() => _Arcpe001LoginCardState();
}

class _Arcpe001LoginCardState extends State<Arcpe001LoginCard> with RestorationMixin {
  final RestorableTextEditingController _emailController = RestorableTextEditingController();
  final RestorableTextEditingController _passwordController = RestorableTextEditingController();

  @override
  String get restorationId => 'arcpe_001_login_card';

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_emailController, 'email_controller');
    registerForRestoration(_passwordController, 'password_controller');
    super.restoreState(oldBucket, initialRestore);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    widget.onSubmit?.call(
      LoginCredentials(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Card(
            elevation: 0,
            color: colorScheme.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Sign in',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: colorScheme.onSurface,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      hintText: 'you@example.com',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    style: Theme.of(context).textTheme.bodyLarge,
                    minLines: 1,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _submit(),
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                    style: Theme.of(context).textTheme.bodyLarge,
                    minLines: 1,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 48,
                    child: FilledButton(
                      onPressed: _submit,
                      child: const Text('Continue'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Simple credentials value object.
class LoginCredentials {
  const LoginCredentials({required this.email, required this.password});

  final String email;
  final String password;
}
