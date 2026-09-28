// SSTLA-030-A05 — Exception Form Presentation Layout Template.
// Provides a mobile-first vertical layout for exception forms with bottom-aligned validation, sliding focus animations, crisp icons, and disclosure menus for non-essential data.

import 'package:flutter/material.dart';

/// Mock data representing atomic-level system configuration details.
class _MockSystemData {
  static const String systemName = 'UDF Exception Handler';
  static const String systemVersion = '1.4.2-Lucky';
  static const List<String> componentList = [
    'FormController',
    'ValidationEngine',
    'DisclosureManager'
  ];
  static const Map<String, String> tokenValues = {
    'primary_color': '#1A73E8',
    'error_color': '#D93025',
    'spacing_unit': '8.0'
  };
  static const String documentationLink = 'https://docs.internal.udf/patterns/exception-forms';
  static const String configDetails = '{"auto_disclose": true, "animation_ms": 300}';
}

/// A standardized layout template for MTO exception forms.
/// Enforces vertical alignment, bottom-reach validation keys, and scaled font weights.
class ExceptionFormLayoutSstla030A05 extends StatefulWidget {
  const ExceptionFormLayoutSstla030A05({super.key});

  @override
  State<ExceptionFormLayoutSstla030A05> createState() => _ExceptionFormLayoutSstla030A05State();
}

class _ExceptionFormLayoutSstla030A05State extends State<ExceptionFormLayoutSstla030A05>
    with SingleTickerProviderStateMixin {
  final FocusNode _field1Focus = FocusNode();
  final FocusNode _field2Focus = FocusNode();
  final TextEditingController _controller1 = TextEditingController();
  final TextEditingController _controller2 = TextEditingController();

  late final AnimationController _slideController;
  late final Animation<Offset> _slideAnimation;

  bool _isField1Valid = false;
  bool _isField2Valid = false;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));

    _field1Focus.addListener(_onFocusChange);
    _field2Focus.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (_field1Focus.hasFocus || _field2Focus.hasFocus) {
      _slideController.forward();
    } else {
      _slideController.reverse();
    }
  }

  @override
  void dispose() {
    _field1Focus.removeListener(_onFocusChange);
    _field2Focus.removeListener(_onFocusChange);
    _field1Focus.dispose();
    _field2Focus.dispose();
    _controller1.dispose();
    _controller2.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _validateInputs() {
    setState(() {
      _isField1Valid = _controller1.text.trim().isNotEmpty;
      _isField2Valid = _controller2.text.trim().isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Exception Task Details',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      body: SlideTransition(
        position: _slideAnimation,
        child: SafeArea(
          child: Column(
            children: [
              // Scrollable form area built for natural thumb movements
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Scaled font weight to separate system labels from data fields
                      Text(
                        'System Configuration',
                        style: textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w400,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_MockSystemData.systemName} v${_MockSystemData.systemVersion}',
                        style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 24),

                      // Data Field 1 with crisp validation icon
                      TextFormField(
                        controller: _controller1,
                        focusNode: _field1Focus,
                        decoration: InputDecoration(
                          labelText: 'Component Identifier',
                          labelStyle: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w400),
                          suffixIcon: Icon(
                            _isField1Valid ? Icons.check_circle_outline : Icons.error_outline,
                            color: _isField1Valid ? theme.colorScheme.primary : theme.colorScheme.error,
                          ),
                          border: const OutlineInputBorder(),
                        ),
                        onChanged: (_) => _validateInputs(),
                      ),
                      const SizedBox(height: 16),

                      // Data Field 2 with crisp validation icon
                      TextFormField(
                        controller: _controller2,
                        focusNode: _field2Focus,
                        decoration: InputDecoration(
                          labelText: 'Token Value Input',
                          labelStyle: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w400),
                          suffixIcon: Icon(
                            _isField2Valid ? Icons.check_circle_outline : Icons.error_outline,
                            color: _isField2Valid ? theme.colorScheme.primary : theme.colorScheme.error,
                          ),
                          border: const OutlineInputBorder(),
                        ),
                        onChanged: (_) => _validateInputs(),
                      ),
                      const SizedBox(height: 24),

                      // Disclosure menu compressing non-essential information automatically
                      ExpansionTile(
                        title: Text(
                          'Advanced System Details',
                          style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        leading: const Icon(Icons.info_outline),
                        childrenPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        children: [
                          _buildDetailRow('Components', _MockSystemData.componentList.join(', ')),
                          _buildDetailRow('Tokens', _MockSystemData.tokenValues.toString()),
                          _buildDetailRow('Documentation', _MockSystemData.documentationLink),
                          _buildDetailRow('Config', _MockSystemData.configDetails),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Mobile-First UX: Validation keys near the bottom for better touch reach
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            _controller1.clear();
                            _controller2.clear();
                            _isField1Valid = false;
                            _isField2Valid = false;
                          });
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reset'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: FilledButton.icon(
                        onPressed: (_isField1Valid && _isField2Valid)
                            ? () {
                                // Submit logic
                              }
                            : null,
                        icon: const Icon(Icons.check),
                        label: const Text('Validate & Submit'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w400,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
