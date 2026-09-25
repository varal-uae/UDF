// SSELC-012-A03 — MasterLayout Universal MTOI Split-Screen Template.
// Enforces a 12-column grid structure with side-by-side evidence and action forms, responsive reflow for mobile, fixed bottom action bar, and focus retention on input fields.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Mock data representing atomic-level template configuration parameters.
/// In production, these would be fetched from local key-value storage or backend.
class _MockTemplateConfig {
  static const String templateName = 'Universal MTOI Split-Screen';
  static const String templateVersion = '1.0.0';
  static const String templateType = 'MTOI_EXCEPTION';
  static const String layoutType = '12_COLUMN_GRID';
  static const int gridColumns = 12;
  static const double spacingRules = 8.0; // 8pt grid baseline
}

/// Poka-Yoke: This widget MUST wrap all MTOI task pages.
/// Linter rules should enforce that no page component bypasses [MasterLayout].
class MasterLayout extends StatefulWidget {
  final Widget evidencePanel;
  final Widget actionForm;
  final List<Widget> bottomActions;
  final String? title;
  final FocusNode? initialFocusNode;

  const MasterLayout({
    super.key,
    required this.evidencePanel,
    required this.actionForm,
    required this.bottomActions,
    this.title,
    this.initialFocusNode,
  });

  @override
  State<MasterLayout> createState() => _MasterLayoutState();
}

class _MasterLayoutState extends State<MasterLayout> {
  @override
  void initState() {
    super.initState();
    // Focus retention on input field upon load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialFocusNode != null && mounted) {
        widget.initialFocusNode!.requestFocus();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? _MockTemplateConfig.templateName),
        centerTitle: false,
        elevation: 0,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool isDesktopOrTablet = constraints.maxWidth >= 600;

          if (isDesktopOrTablet) {
            // Side-by-side evidence and action forms (12-column grid logic)
            return _buildSplitScreen(constraints);
          } else {
            // Responsive reflow (stacking) for smaller administrative screens
            return _buildMobileStacked(constraints);
          }
        },
      ),
      // Fixed action bar at bottom on smaller screens
      bottomNavigationBar: _buildFixedActionBar(),
    );
  }

  Widget _buildSplitScreen(BoxConstraints constraints) {
    // Simulating 12-column grid: Evidence takes 7 cols, Action takes 5 cols
    // Using fractional widths to strictly adhere to grid proportions
    final double totalWidth = constraints.maxWidth;
    final double spacing = _MockTemplateConfig.spacingRules * 2;
    final double evidenceWidth = (totalWidth * (7 / 12)) - spacing;
    final double actionWidth = (totalWidth * (5 / 12)) - spacing;

    return Padding(
      padding: EdgeInsets.all(_MockTemplateConfig.spacingRules * 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: evidenceWidth,
            child: Material(
              elevation: 1,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: EdgeInsets.all(_MockTemplateConfig.spacingRules * 2),
                child: widget.evidencePanel,
              ),
            ),
          ),
          SizedBox(width: spacing),
          SizedBox(
            width: actionWidth,
            child: Material(
              elevation: 1,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: EdgeInsets.all(_MockTemplateConfig.spacingRules * 2),
                child: widget.actionForm,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileStacked(BoxConstraints constraints) {
    // Stacking for mobile, separating Evidence from Action via Material Cards
    return SingleChildScrollView(
      padding: EdgeInsets.all(_MockTemplateConfig.spacingRules * 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: EdgeInsets.all(_MockTemplateConfig.spacingRules * 2),
              child: widget.evidencePanel,
            ),
          ),
          SizedBox(height: _MockTemplateConfig.spacingRules * 2),
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: EdgeInsets.all(_MockTemplateConfig.spacingRules * 2),
              child: widget.actionForm,
            ),
          ),
          // Bottom padding to prevent content hiding behind fixed action bar
          SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildFixedActionBar() {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: _MockTemplateConfig.spacingRules * 2,
          vertical: _MockTemplateConfig.spacingRules,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: widget.bottomActions
              .map((action) => Padding(
                    padding: EdgeInsets.only(left: _MockTemplateConfig.spacingRules),
                    child: action,
                  ))
              .toList(),
        ),
      ),
    );
  }
}

/// Input masking linked to dropdown state.
/// Dynamic regex updating based on dropdown selection.
class MaskedInputField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String label;
  final String dropdownValue;

  const MaskedInputField({
    super.key,
    required this.controller,
    required this.label,
    required this.dropdownValue,
    this.focusNode,
  });

  @override
  State<MaskedInputField> createState() => _MaskedInputFieldState();
}

class _MaskedInputFieldState extends State<MaskedInputField> {
  late List<TextInputFormatter> _currentFormatters;

  @override
  void initState() {
    super.initState();
    _updateFormatters();
  }

  @override
  void didUpdateWidget(covariant MaskedInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.dropdownValue != widget.dropdownValue) {
      _updateFormatters();
    }
  }

  void _updateFormatters() {
    // Dynamic regex updating based on dropdown state
    switch (widget.dropdownValue) {
      case 'PHONE':
        _currentFormatters = [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(10),
        ];
        break;
      case 'ALPHANUMERIC_ID':
        _currentFormatters = [
          FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
          LengthLimitingTextInputFormatter(12),
        ];
        break;
      default:
        _currentFormatters = [];
        break;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      inputFormatters: _currentFormatters,
      // Frictionless typing on native keyboards
      keyboardType: widget.dropdownValue == 'PHONE'
          ? TextInputType.phone
          : TextInputType.text,
      decoration: InputDecoration(
        labelText: widget.label,
        border: const OutlineInputBorder(),
        filled: true,
      ),
    );
  }
}