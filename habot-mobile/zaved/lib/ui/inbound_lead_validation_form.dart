/// COMPONENT METADATA BLOCK
/// Step Execution ID: STEP-BPTR-0035-EXEC-01
/// Execution Status: SUCCESS
/// Execution Timestamp: 2026-08-18T10:38:28Z
/// Step Outcome: FORM_VALIDATED_AND_SUBMITTED
/// User ID: USER-SYS-PROD-001
/// Completion Status: Target: Complete - Requirements Traceability Coverage
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// BPTR-0035: Inbound Lead Validation Form with Strict Client-Side Constraints
class InboundLeadValidationForm extends StatefulWidget {
  final ValueChanged<Map<String, String>>? onSubmit;

  const InboundLeadValidationForm({
    super.key,
    this.onSubmit,
  });

  @override
  State<InboundLeadValidationForm> createState() =>
      _InboundLeadValidationFormState();
}

class _InboundLeadValidationFormState extends State<InboundLeadValidationForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _zipController = TextEditingController();

  bool _isFormValid = false;
  bool _isSubmitted = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _zipController.dispose();
    super.dispose();
  }

  void _validateFormContinuously() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (isValid != _isFormValid) {
      setState(() {
        _isFormValid = isValid;
      });
    }
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isSubmitted = true;
      });
      if (widget.onSubmit != null) {
        widget.onSubmit!({
          'name': _nameController.text,
          'email': _emailController.text,
          'zip': _zipController.text,
        });
      }
    }
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Full name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email address is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validateZip(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Zip code is required';
    }
    if (value.trim().length != 5) {
      return 'Zip code must be exactly 5 digits';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final inputDecorationTheme = InputDecorationTheme(
      hoverColor: colorScheme.surfaceContainerHighest.withAlpha(0),
      helperMaxLines: 2,
      errorMaxLines: 2,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(
          color: colorScheme.outline,
          width: 1.0,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(
          color: colorScheme.primary,
          width: 2.0,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(
          color: colorScheme.error,
          width: 2.0,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(
          color: colorScheme.error,
          width: 2.0,
        ),
      ),
    );

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLow,
      appBar: AppBar(
        title: const Text('BPTR-0035: Inbound Lead Validation'),
        centerTitle: true,
        elevation: 1,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800.0),
              child: Theme(
                data: theme.copyWith(inputDecorationTheme: inputDecorationTheme),
                child: Material(
                  elevation: 2,
                  borderRadius: BorderRadius.circular(16.0),
                  color: colorScheme.surface,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      onChanged: _validateFormContinuously,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final isMobile = constraints.maxWidth <= 600;

                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Inbound Lead Validation',
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  color: colorScheme.onSurface,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              Text(
                                'Please fill in your details for verification.',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 24.0),

                              // Responsive Data Layout Lanes
                              if (isMobile) ...[
                                // Mobile View (maxWidth <= 600): Single-Focus Column Stack
                                _buildNameField(colorScheme),
                                const SizedBox(height: 16.0),
                                _buildEmailField(colorScheme),
                                const SizedBox(height: 16.0),
                                _buildZipField(colorScheme),
                              ] else ...[
                                // Web/Tablet View (maxWidth > 600): Symmetrical Side-by-Side Lanes
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(child: _buildNameField(colorScheme)),
                                    const SizedBox(width: 16.0),
                                    Expanded(child: _buildEmailField(colorScheme)),
                                  ],
                                ),
                                const SizedBox(height: 16.0),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(child: _buildZipField(colorScheme)),
                                    const SizedBox(width: 16.0),
                                    const Expanded(child: SizedBox.shrink()),
                                  ],
                                ),
                              ],

                              const SizedBox(height: 32.0),

                              // Blurred Submission Blocker (Poka-Yoke): null onPressed when invalid
                              SizedBox(
                                height: 50.0,
                                child: FilledButton(
                                  onPressed: _isFormValid ? _handleSubmit : null,
                                  style: FilledButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                  ),
                                  child: Text(
                                    _isSubmitted ? 'Lead Validated & Sent' : 'Submit Lead Validation',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNameField(ColorScheme colorScheme) {
    return TextFormField(
      controller: _nameController,
      keyboardType: TextInputType.name,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z\s]")),
      ],
      validator: _validateName,
      decoration: InputDecoration(
        labelText: 'Full Name',
        hintText: 'e.g., Alex Johnson',
        helperText: 'Letters and spaces only',
        prefixIcon: Icon(Icons.person_outline, color: colorScheme.primary),
      ),
    );
  }

  Widget _buildEmailField(ColorScheme colorScheme) {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      validator: _validateEmail,
      decoration: InputDecoration(
        labelText: 'Email Address',
        hintText: 'e.g., alex@company.com',
        helperText: 'Corporate or primary email',
        prefixIcon: Icon(Icons.email_outlined, color: colorScheme.primary),
      ),
    );
  }

  Widget _buildZipField(ColorScheme colorScheme) {
    return TextFormField(
      controller: _zipController,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(5),
      ],
      validator: _validateZip,
      decoration: InputDecoration(
        labelText: 'Zip Code',
        hintText: '5-digit postal code',
        helperText: 'Numbers only (5 digits)',
        prefixIcon: Icon(Icons.pin_drop_outlined, color: colorScheme.primary),
      ),
    );
  }
}
