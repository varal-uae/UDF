import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Unique styling tokens for Cross Platform Input Masking Field.
abstract final class InputMaskingTokens {
  static const Color primaryTeal = Color(0xFF0D9488);
  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);

  static const Color badgeOwaspBg = Color(0xFFDCFCE7);
  static const Color badgeOwaspText = Color(0xFF166534);
}

/// Mask type presets.
enum MaskPreset {
  uaePhone, // +971 (50) 123-4567
  creditCard, // 4111 2222 3333 4444
  isoDate, // YYYY-MM-DD
}

/// Standalone pure SDK custom input formatter implementing cross-platform masking.
class PatternInputMaskFormatter extends TextInputFormatter {
  final MaskPreset preset;

  PatternInputMaskFormatter({required this.preset});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final raw = newValue.text.replaceAll(RegExp(r'\D'), '');

    String formatted = '';
    switch (preset) {
      case MaskPreset.uaePhone:
        // Pattern: +971 (XX) XXX-XXXX
        final digits = raw.startsWith('971') ? raw.substring(3) : raw;
        if (digits.isEmpty) {
          formatted = '';
        } else if (digits.length <= 2) {
          formatted = '+971 ($digits';
        } else if (digits.length <= 5) {
          formatted = '+971 (${digits.substring(0, 2)}) ${digits.substring(2)}';
        } else {
          final maxDigits = digits.substring(0, digits.length.clamp(0, 9));
          formatted =
              '+971 (${maxDigits.substring(0, 2)}) ${maxDigits.substring(2, 5)}-${maxDigits.substring(5)}';
        }
        break;

      case MaskPreset.creditCard:
        // Pattern: XXXX XXXX XXXX XXXX
        final limited = raw.substring(0, raw.length.clamp(0, 16));
        final buffer = StringBuffer();
        for (int i = 0; i < limited.length; i++) {
          if (i > 0 && i % 4 == 0) buffer.write(' ');
          buffer.write(limited[i]);
        }
        formatted = buffer.toString();
        break;

      case MaskPreset.isoDate:
        // Pattern: YYYY-MM-DD
        final limited = raw.substring(0, raw.length.clamp(0, 8));
        final buffer = StringBuffer();
        for (int i = 0; i < limited.length; i++) {
          if (i == 4 || i == 6) buffer.write('-');
          buffer.write(limited[i]);
        }
        formatted = buffer.toString();
        break;
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// A cross-platform input masking field compliant with OWASP Input Validation.
class CrossPlatformInputMaskingField extends StatefulWidget {
  final void Function(String rawValue, String maskedValue)? onMaskedChanged;

  const CrossPlatformInputMaskingField({
    super.key,
    this.onMaskedChanged,
  });

  @override
  State<CrossPlatformInputMaskingField> createState() =>
      _CrossPlatformInputMaskingFieldState();
}

class _CrossPlatformInputMaskingFieldState
    extends State<CrossPlatformInputMaskingField> {
  MaskPreset _selectedPreset = MaskPreset.uaePhone;
  final _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _switchPreset(MaskPreset preset) {
    setState(() {
      _selectedPreset = preset;
      _textController.clear();
    });
  }

  String get _rawDigits => _textController.text.replaceAll(RegExp(r'\D'), '');

  @override
  Widget build(BuildContext context) {
    final hint = switch (_selectedPreset) {
      MaskPreset.uaePhone => '+971 (50) 000-0000',
      MaskPreset.creditCard => '0000 0000 0000 0000',
      MaskPreset.isoDate => 'YYYY-MM-DD',
    };

    final label = switch (_selectedPreset) {
      MaskPreset.uaePhone => 'Mobile Phone Number',
      MaskPreset.creditCard => 'Corporate Card Number',
      MaskPreset.isoDate => 'Effective Date',
    };

    final icon = switch (_selectedPreset) {
      MaskPreset.uaePhone => Icons.phone_android_rounded,
      MaskPreset.creditCard => Icons.credit_card_rounded,
      MaskPreset.isoDate => Icons.calendar_today_rounded,
    };

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: InputMaskingTokens.surfaceCard,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: InputMaskingTokens.borderLight),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: InputMaskingTokens.primaryTeal.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.dialpad_rounded,
                  color: InputMaskingTokens.primaryTeal,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cross-Platform Input Masking',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: InputMaskingTokens.textDark,
                      ),
                    ),
                    Text(
                      'OWASP Input Validation & Pure Dart Formatter',
                      style: TextStyle(
                        fontSize: 12,
                        color: InputMaskingTokens.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: InputMaskingTokens.badgeOwaspBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'OWASP COMPLIANT',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: InputMaskingTokens.badgeOwaspText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Preset Selector Chips
          SegmentedButton<MaskPreset>(
            segments: const [
              ButtonSegment(
                value: MaskPreset.uaePhone,
                label: Text('Phone'),
                icon: Icon(Icons.phone, size: 16),
              ),
              ButtonSegment(
                value: MaskPreset.creditCard,
                label: Text('Card'),
                icon: Icon(Icons.credit_card, size: 16),
              ),
              ButtonSegment(
                value: MaskPreset.isoDate,
                label: Text('Date'),
                icon: Icon(Icons.calendar_month, size: 16),
              ),
            ],
            selected: {_selectedPreset},
            onSelectionChanged: (set) => _switchPreset(set.first),
          ),
          const SizedBox(height: 14),
          // Masked Input Field
          TextField(
            key: ValueKey(_selectedPreset),
            controller: _textController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              PatternInputMaskFormatter(preset: _selectedPreset),
            ],
            onChanged: (val) {
              setState(() {});
              widget.onMaskedChanged?.call(_rawDigits, val);
            },
            decoration: InputDecoration(
              labelText: label,
              hintText: hint,
              prefixIcon: Icon(icon, color: InputMaskingTokens.primaryTeal),
              suffixIcon: _textController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () => setState(() => _textController.clear()),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Invariant Inspection Card
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: InputMaskingTokens.backgroundLight,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: InputMaskingTokens.borderLight),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Raw Unmasked Digits:',
                        style: TextStyle(
                            fontSize: 10,
                            color: InputMaskingTokens.textMuted)),
                    Text(
                      _rawDigits.isEmpty ? '(none)' : _rawDigits,
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w700,
                        color: InputMaskingTokens.textDark,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Masked Payload Value:',
                        style: TextStyle(
                            fontSize: 10,
                            color: InputMaskingTokens.textMuted)),
                    Text(
                      _textController.text.isEmpty
                          ? '(empty)'
                          : _textController.text,
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w700,
                        color: InputMaskingTokens.primaryTeal,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: CrossPlatformInputMaskingField(),
          ),
        ),
      ),
    ),
  );
}
