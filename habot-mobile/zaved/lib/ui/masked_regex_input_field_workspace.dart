// ============================================================================
// ARCHITECTURAL TRACKING METADATA BLOCK
// Architecture Pattern: Regex Input Masking Enforcer Workspace
// Component Hierarchy: MaskedRegexInputFieldWorkspace -> MaskedRegexInputField -> RegexMaskFormatter
// Poka-Yoke: 3-Strike Invalidation Tooltip & Instant Keystroke Nullification
// Completion Status: Complete (Ref: REF-362-A01)
// ============================================================================

import 'package:flutter/material.dart';
import 'masked_regex_input_field.dart';

/// REF-362-A01: Masked Regex Input Field Interactive Workspace
class MaskedRegexInputFieldWorkspace extends StatefulWidget {
  const MaskedRegexInputFieldWorkspace({super.key});

  @override
  State<MaskedRegexInputFieldWorkspace> createState() =>
      _MaskedRegexInputFieldWorkspaceState();
}

class _MaskedRegexInputFieldWorkspaceState
    extends State<MaskedRegexInputFieldWorkspace> {
  final _dateController = TextEditingController();
  final _currencyController = TextEditingController();
  final _creditCardController = TextEditingController();

  @override
  void dispose() {
    _dateController.dispose();
    _currencyController.dispose();
    _creditCardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.vpn_key_outlined,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'REGEX INPUT MASKING ENFORCER',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    Text(
                      'Invisible Bouncer & 3-Strike Tooltip (Poka-Yoke)',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Date Mask Demo (MM/DD/YYYY)
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '1. Date Format Mask (MM/DD/YYYY)',
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Type non-digit characters (e.g. letters) 3 times to trigger the 3-strike helper tooltip.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  MaskedRegexInputField(
                    controller: _dateController,
                    label: 'Effective Date',
                    hintText: 'MM/DD/YYYY',
                    mask: '##/##/####',
                    allowedCharRegex: RegExp(r'[0-9]'),
                    fullMatchRegex: RegExp(r'^(0[1-9]|1[0-2])\/(0[1-9]|[12][0-9]|3[01])\/\d{4}$'),
                    expectedFormatHint: 'Must be in MM/DD/YYYY numeric format',
                    inputMode: TextInputType.number,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Currency Mask Demo (###,###,### USD)
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '2. Corporate Allocation Code (ALPHA-NUMERIC)',
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Requires uppercase alphanumeric sequence masked as AA-####-AA.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  MaskedRegexInputField(
                    controller: _currencyController,
                    label: 'Allocation Code',
                    hintText: 'US-9021-TX',
                    mask: '##-####-##',
                    allowedCharRegex: RegExp(r'[a-zA-Z0-9]'),
                    fullMatchRegex: RegExp(r'^[A-Z]{2}-\d{4}-[A-Z]{2}$'),
                    expectedFormatHint: 'Must match AA-####-AA format',
                    inputMode: TextInputType.text,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
