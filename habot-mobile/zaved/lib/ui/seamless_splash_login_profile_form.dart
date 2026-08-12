import 'dart:developer' as developer;
import 'package:flutter/material.dart';

/// Mandatory Field Label Helper Widget
/// Uses [RichText] to render the label text and appends a red asterisk
/// (using [Theme.of(context).colorScheme.error]) when [isMandatory] is true.
class MandatoryFieldLabel extends StatelessWidget {
  final String label;
  final bool isMandatory;
  final TextStyle? style;

  const MandatoryFieldLabel({
    super.key,
    required this.label,
    this.isMandatory = true,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseStyle = style ?? theme.textTheme.bodyMedium ?? const TextStyle();

    return RichText(
      text: TextSpan(
        text: label,
        style: baseStyle,
        children: isMandatory
            ? [
                TextSpan(
                  text: ' *',
                  style: baseStyle.copyWith(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ]
            : null,
      ),
    );
  }
}

/// A 'Seamless Splash-to-Interactive' Login/Profile form implementing:
/// 1. State Preservation via [RestorationMixin] and [RestorableTextEditingController]s.
/// 2. Keyboard Overlap Prevention via [SafeArea] & [SingleChildScrollView] reacting to [MediaQuery.of(context).viewInsets.bottom].
/// 3. Material 3 Accessibility (strict 16.0 horizontal margin & 48.0 minHeight constraints).
/// 4. Mandatory Field Styling using [MandatoryFieldLabel] with red asterisk via `colorScheme.error`.
/// 5. Poka-Yoke (Validation Check) enforcing mandatory `predecessor_id` validation parameter.
class SeamlessSplashLoginProfileForm extends StatefulWidget {
  final String? restorationId;
  final String? initialPredecessorId;
  final void Function(Map<String, String> formData)? onSubmitSuccess;

  const SeamlessSplashLoginProfileForm({
    super.key,
    this.restorationId = 'seamless_splash_login_profile_form',
    this.initialPredecessorId,
    this.onSubmitSuccess,
  });

  @override
  State<SeamlessSplashLoginProfileForm> createState() =>
      _SeamlessSplashLoginProfileFormState();
}

class _SeamlessSplashLoginProfileFormState
    extends State<SeamlessSplashLoginProfileForm>
    with RestorationMixin, SingleTickerProviderStateMixin {
  // Restorable Controllers for Form State Preservation
  late final RestorableTextEditingController _usernameController;
  late final RestorableTextEditingController _emailController;
  late final RestorableTextEditingController _passwordController;
  late final RestorableTextEditingController _bioController;
  late final RestorableTextEditingController _predecessorIdController;

  // Restorable Splash View State
  final RestorableBool _isSplashState = RestorableBool(true);

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  String? _validationErrorMessage;
  bool _showHiddenPredecessorField = false;

  @override
  String? get restorationId => widget.restorationId;

  @override
  void initState() {
    super.initState();
    _usernameController = RestorableTextEditingController();
    _emailController = RestorableTextEditingController();
    _passwordController = RestorableTextEditingController();
    _bioController = RestorableTextEditingController();
    _predecessorIdController = RestorableTextEditingController(
      text: widget.initialPredecessorId ?? 'PRED-8849-POKA-YOKE',
    );

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    );

    _scaleAnim = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOutBack,
      ),
    );

    _animController.forward();
  }

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_usernameController, 'username_controller');
    registerForRestoration(_emailController, 'email_controller');
    registerForRestoration(_passwordController, 'password_controller');
    registerForRestoration(_bioController, 'bio_controller');
    registerForRestoration(_predecessorIdController, 'predecessor_id_controller');
    registerForRestoration(_isSplashState, 'is_splash_state');
  }

  @override
  void dispose() {
    _animController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _bioController.dispose();
    _predecessorIdController.dispose();
    _isSplashState.dispose();
    super.dispose();
  }

  void _transitionToInteractiveForm() {
    setState(() {
      _isSplashState.value = false;
    });
  }

  /// Poka-Yoke Mockup Submit Function
  /// Physically prevents progression and logs an error if [predecessor_id] is missing.
  void _submitForm() {
    final predecessorId = _predecessorIdController.value.text.trim();

    // Poka-Yoke Validation Check
    if (predecessorId.isEmpty) {
      const errorMessage =
          'Poka-Yoke Enforcement Failed: Mandatory parameter [predecessor_id] is missing!';
      developer.log(
        errorMessage,
        name: 'ValidationPipeline',
        level: 1000,
        error: Exception('MissingPredecessorId'),
      );

      setState(() {
        _validationErrorMessage = errorMessage;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
          content: Row(
            children: [
              Icon(
                Icons.gpp_bad,
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: Text(
                  errorMessage,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          duration: const Duration(seconds: 4),
        ),
      );
      return; // Physical prevention of progression
    }

    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _validationErrorMessage = null;
      });

      developer.log(
        'Poka-Yoke Validation Passed. predecessor_id: $predecessorId',
        name: 'ValidationPipeline',
      );

      final formData = {
        'username': _usernameController.value.text,
        'email': _emailController.value.text,
        'bio': _bioController.value.text,
        'predecessor_id': predecessorId,
      };

      widget.onSubmitSuccess?.call(formData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          content: Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: Text(
                  'Profile submitted successfully! (predecessor_id verified)',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login / Profile Setup'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              _showHiddenPredecessorField
                  ? Icons.lock_open
                  : Icons.lock_outline,
            ),
            tooltip: 'Toggle Poka-Yoke Parameter Visibility',
            onPressed: () {
              setState(() {
                _showHiddenPredecessorField = !_showHiddenPredecessorField;
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktopWeb = constraints.maxWidth > 850;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              padding: EdgeInsets.fromLTRB(
                isDesktopWeb ? 32.0 : 16.0,
                24.0,
                isDesktopWeb ? 32.0 : 16.0,
                24.0 + bottomInset,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isDesktopWeb ? 1100.0 : 600.0,
                  ),
                  child: ScaleTransition(
                    scale: _scaleAnim,
                    child: FadeTransition(
                      opacity: _fadeAnim,
                      child: isDesktopWeb
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Left Pane: Splash Hero Card
                                Expanded(
                                  flex: 5,
                                  child: Column(
                                    children: [
                                      _buildSplashHero(theme),
                                      const SizedBox(height: 20.0),
                                      if (_isSplashState.value)
                                        _buildSplashCTA(theme),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 32.0),

                                // Right Pane: Interactive Form
                                Expanded(
                                  flex: 7,
                                  child: Card(
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                      side: BorderSide(
                                        color: theme.colorScheme.outlineVariant,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(24.0),
                                      child: _buildInteractiveForm(theme),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Splash View Hero Section
                                _buildSplashHero(theme),
                                const SizedBox(height: 24.0),

                                if (_isSplashState.value)
                                  _buildSplashCTA(theme)
                                else
                                  _buildInteractiveForm(theme),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSplashHero(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.tertiaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 16.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 36.0,
            backgroundColor: theme.colorScheme.primary,
            child: Icon(
              Icons.account_circle,
              size: 48.0,
              color: theme.colorScheme.onPrimary,
            ),
          ),
          const SizedBox(height: 12.0),
          Text(
            'Seamless Profile Portal',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onPrimaryContainer,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6.0),
          Text(
            'Material 3 state-preserved, accessible, and poka-yoke protected workflow.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSplashCTA(ThemeData theme) {
    return Column(
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48.0),
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(48.0),
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
            onPressed: _transitionToInteractiveForm,
            icon: const Icon(Icons.arrow_forward),
            label: const Text(
              'Get Started / Enter Profile Info',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(height: 12.0),
        Text(
          'Tap to smoothly transition from splash state into interactive form.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildInteractiveForm(ThemeData theme) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_validationErrorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: theme.colorScheme.error),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: theme.colorScheme.error),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Text(
                      _validationErrorMessage!,
                      style: TextStyle(
                        color: theme.colorScheme.onErrorContainer,
                        fontWeight: FontWeight.w500,
                        fontSize: 13.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
          ],

          // Username Field (Mandatory)
          const MandatoryFieldLabel(
            label: 'Username',
            isMandatory: true,
          ),
          const SizedBox(height: 6.0),
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48.0),
            child: TextFormField(
              controller: _usernameController.value,
              decoration: InputDecoration(
                hintText: 'Enter your unique username',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 14.0,
                  horizontal: 16.0,
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Username is required';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 16.0),

          // Email Field (Mandatory)
          const MandatoryFieldLabel(
            label: 'Email Address',
            isMandatory: true,
          ),
          const SizedBox(height: 6.0),
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48.0),
            child: TextFormField(
              controller: _emailController.value,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'name@example.com',
                prefixIcon: const Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 14.0,
                  horizontal: 16.0,
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Email address is required';
                }
                if (!value.contains('@')) {
                  return 'Enter a valid email address';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 16.0),

          // Password Field (Mandatory)
          const MandatoryFieldLabel(
            label: 'Password',
            isMandatory: true,
          ),
          const SizedBox(height: 6.0),
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48.0),
            child: TextFormField(
              controller: _passwordController.value,
              obscureText: true,
              decoration: InputDecoration(
                hintText: '••••••••',
                prefixIcon: const Icon(Icons.lock),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 14.0,
                  horizontal: 16.0,
                ),
              ),
              validator: (value) {
                if (value == null || value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 16.0),

          // Bio Field (Optional)
          const MandatoryFieldLabel(
            label: 'Bio / Notes',
            isMandatory: false,
          ),
          const SizedBox(height: 6.0),
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48.0),
            child: TextFormField(
              controller: _bioController.value,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Tell us a little bit about yourself...',
                prefixIcon: const Icon(Icons.notes),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 14.0,
                  horizontal: 16.0,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16.0),

          // Poka-Yoke Hidden Parameter Control Section
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Poka-Yoke Validation Parameter',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Switch(
                      value: _predecessorIdController.value.text.isNotEmpty,
                      onChanged: (val) {
                        setState(() {
                          if (val) {
                            _predecessorIdController.value.text =
                                'PRED-8849-POKA-YOKE';
                          } else {
                            _predecessorIdController.value.text = '';
                          }
                        });
                      },
                    ),
                  ],
                ),
                if (_showHiddenPredecessorField) ...[
                  const SizedBox(height: 8.0),
                  ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 48.0),
                    child: TextFormField(
                      controller: _predecessorIdController.value,
                      decoration: InputDecoration(
                        labelText: 'predecessor_id (Hidden System Parameter)',
                        helperText:
                            'Clear this field to test Poka-Yoke physical submit blocking.',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  Text(
                    'hidden predecessor_id: "${_predecessorIdController.value.text}"',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                      color: _predecessorIdController.value.text.isEmpty
                          ? theme.colorScheme.error
                          : theme.colorScheme.primary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24.0),

          // Submit Button (Interactive Element with minHeight: 48.0)
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48.0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48.0),
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              onPressed: _submitForm,
              icon: const Icon(Icons.check_circle_outline),
              label: const Text(
                'Submit Profile',
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 12.0),

          // Back to Splash Toggle
          Center(
            child: TextButton.icon(
              onPressed: () {
                setState(() {
                  _isSplashState.value = true;
                });
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back to Splash View'),
            ),
          ),
        ],
      ),
    );
  }
}
