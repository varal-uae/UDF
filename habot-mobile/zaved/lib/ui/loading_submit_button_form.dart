import 'dart:async';
import 'package:flutter/material.dart';

// ============================================================================
// UNIVERSAL COMPONENT LIBRARY METADATA
// ============================================================================
// Library Name:        Universal Component Library
// Library Version:     2.4.0
// Component Count:     142
// Installation Status: Installed & Verified
// Dependency List:     flutter/material.dart, dart:async
// Library Location Path: lib/ui/loading_submit_button_form.dart
// ============================================================================

/// LoadingSubmitButton Component (USMBL-017)
class LoadingSubmitButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;
  final double height;
  final double? width;

  const LoadingSubmitButton({
    super.key,
    required this.label,
    required this.isLoading,
    required this.onPressed,
    this.height = 56.0,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 1. Strict Dimensional Footprint (No Layout Jumps)
    // Button is wrapped inside a SizedBox with fixed height (56.0) and width.
    return SizedBox(
      height: height,
      width: width ?? double.infinity,
      child: FilledButton(
        style: FilledButton.styleFrom(
          minimumSize: Size(width ?? double.infinity, height),
          maximumSize: Size(width ?? double.infinity, height),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        // 2. In-Flight Protection: When isLoading is true, onPressed is passed as null
        // which automatically shifts button to a muted disabled tone and prevents hammering
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? SizedBox(
                width: 24.0,
                height: 24.0,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.onSurface.withValues(alpha: 0.38),
                  ),
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}

/// LoadingSubmitButton Form Wrapper & Demo Widget (USMBL-017)
class LoadingSubmitButtonForm extends StatefulWidget {
  final Future<void> Function()? onSubmit;

  const LoadingSubmitButtonForm({
    super.key,
    this.onSubmit,
  });

  @override
  State<LoadingSubmitButtonForm> createState() =>
      _LoadingSubmitButtonFormState();
}

class _LoadingSubmitButtonFormState extends State<LoadingSubmitButtonForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _apiKeyController = TextEditingController();

  bool _isLoading = false;
  bool _simulateTimeout = false;

  @override
  void dispose() {
    _emailController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  // 3. Deadlock Breaker (Global Timeout Bound & Poka-Yoke In-Flight Protection)
  Future<void> _handleFormSubmit() async {
    if (_isLoading) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    // 2. Immediately set isLoading = true (disables button & locks down form)
    setState(() {
      _isLoading = true;
    });

    try {
      if (widget.onSubmit != null) {
        // Enforce 15-second global timeout bound on custom onSubmit callback
        await widget.onSubmit!().timeout(const Duration(seconds: 15));
      } else {
        // Default execution flow with 15-second timeout protection
        if (_simulateTimeout) {
          // Simulate hanging server / network drop that exceeds 15-second timeout bound
          await Future.delayed(const Duration(seconds: 18)).timeout(
            const Duration(seconds: 15),
          );
        } else {
          // Standard simulated API request
          await Future.delayed(const Duration(seconds: 2)).timeout(
            const Duration(seconds: 15),
          );
        }
      }

      if (!mounted) return;
      final colorScheme = Theme.of(context).colorScheme;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Form Submission Completed Successfully!'),
          backgroundColor: colorScheme.primary,
        ),
      );
    } on TimeoutException {
      if (!mounted) return;
      final colorScheme = Theme.of(context).colorScheme;
      // 3. Deadlock Breaker: TimeoutException caught -> automatically reset isLoading = false
      // and display local error toast, preventing infinite loading freeze.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'DEADLOCK BREAKER TRIGGERED: Request timed out after 15s boundary. Form unlocked.',
          ),
          backgroundColor: colorScheme.error,
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      final colorScheme = Theme.of(context).colorScheme;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Submission Error: ${e.toString()}'),
          backgroundColor: colorScheme.tertiary,
        ),
      );
    } finally {
      if (mounted) {
        // Always guarantee form lockdown reset
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Loading Submit Button & Form Wrapper'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540.0),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
                side: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Form In-Flight Lockdown & Deadlock Protection',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      'When submitting, form fields are greyed out via Opacity + IgnorePointer, button size remains strictly constant (56dp), and a 15s timeout prevents deadlocks.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const Divider(height: 24.0),

                    // Timeout Simulation Switch
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Simulate Server Timeout (>15s)'),
                      subtitle: const Text(
                        'Tests Deadlock Breaker timeout exception handling',
                      ),
                      value: _simulateTimeout,
                      onChanged: _isLoading
                          ? null
                          : (val) {
                              setState(() {
                                _simulateTimeout = val;
                              });
                            },
                    ),
                    const SizedBox(height: 16.0),

                    // Form Fields with In-Flight Protection (Opacity + IgnorePointer)
                    // 2. Wrap adjacent form fields using IgnorePointer and adjust opacity
                    Opacity(
                      opacity: _isLoading ? 0.5 : 1.0,
                      child: IgnorePointer(
                        ignoring: _isLoading,
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _emailController,
                                decoration: const InputDecoration(
                                  labelText: 'Admin Email',
                                  prefixIcon: Icon(Icons.email_outlined),
                                  border: OutlineInputBorder(),
                                ),
                                validator: (val) {
                                  if (val == null || val.isEmpty) {
                                    return 'Please enter email';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16.0),
                              TextFormField(
                                controller: _apiKeyController,
                                decoration: const InputDecoration(
                                  labelText: 'API Authentication Key',
                                  prefixIcon: Icon(Icons.key_outlined),
                                  border: OutlineInputBorder(),
                                ),
                                validator: (val) {
                                  if (val == null || val.isEmpty) {
                                    return 'Please enter API key';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24.0),

                    // 1 & 2. LoadingSubmitButton Component
                    LoadingSubmitButton(
                      label: 'SUBMIT CONFIGURATION',
                      isLoading: _isLoading,
                      onPressed: _handleFormSubmit,
                      height: 56.0,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
