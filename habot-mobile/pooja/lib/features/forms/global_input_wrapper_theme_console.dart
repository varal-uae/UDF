import 'package:flutter/material.dart';

/// Unique styling tokens for the Global Input Wrapper Theme Console.
abstract final class GlobalInputWrapperTokens {
  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);

  static const Color brandPrimary = Color(0xFF2563EB);
  static const Color successGreen = Color(0xFF16A34A);
  static const Color errorRed = Color(0xFFDC2626);
}

/// Global standard input wrapper widget enforcing uniform M3 borders, labels, and validation state.
class GlobalInputWrapper extends StatelessWidget {
  final String label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final IconData? prefixIcon;
  final Widget? suffix;
  final Widget child;

  const GlobalInputWrapper({
    super.key,
    required this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.suffix,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null && errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: hasError
                    ? GlobalInputWrapperTokens.errorRed
                    : GlobalInputWrapperTokens.textDark,
              ),
            ),
            if (hasError)
              Text(
                errorText!,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: GlobalInputWrapperTokens.errorRed,
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: hasError
                  ? GlobalInputWrapperTokens.errorRed
                  : GlobalInputWrapperTokens.borderLight,
              width: hasError ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            children: [
              if (prefixIcon != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Icon(
                    prefixIcon,
                    size: 18,
                    color: hasError
                        ? GlobalInputWrapperTokens.errorRed
                        : GlobalInputWrapperTokens.textMuted,
                  ),
                ),
              Expanded(child: child),
              if (suffix != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: suffix!,
                ),
            ],
          ),
        ),
        if (helperText != null && !hasError) ...[
          const SizedBox(height: 4),
          Text(
            helperText!,
            style: const TextStyle(
              fontSize: 11,
              color: GlobalInputWrapperTokens.textMuted,
            ),
          ),
        ],
      ],
    );
  }
}

/// Interactive console demonstrating global application of input component wrappers.
class GlobalInputWrapperThemeConsole extends StatefulWidget {
  const GlobalInputWrapperThemeConsole({super.key});

  @override
  State<GlobalInputWrapperThemeConsole> createState() =>
      _GlobalInputWrapperThemeConsoleState();
}

class _GlobalInputWrapperThemeConsoleState
    extends State<GlobalInputWrapperThemeConsole> {
  final _emailCtrl = TextEditingController(text: 'ops.lead@enterprise.habot.io');
  final _apiKeyCtrl = TextEditingController(text: 'hbt_live_9482948201948');
  bool _simulateError = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _apiKeyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: GlobalInputWrapperTokens.surfaceCard,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: GlobalInputWrapperTokens.borderLight),
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
                  color: GlobalInputWrapperTokens.brandPrimary.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.layers_rounded,
                  color: GlobalInputWrapperTokens.brandPrimary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Global Input Wrapper Console',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: GlobalInputWrapperTokens.textDark,
                      ),
                    ),
                    Text(
                      'Universal Form Decorator Pattern (ISO/IEC 27001)',
                      style: TextStyle(
                        fontSize: 12,
                        color: GlobalInputWrapperTokens.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'WRAPPERS ACTIVE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF166534),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Demo Input 1 using Global Wrapper
          GlobalInputWrapper(
            label: 'Administrator Identity',
            helperText: 'Validated corporate SSO directory email',
            prefixIcon: Icons.account_circle_outlined,
            errorText: _simulateError ? 'Domain authorization mismatch' : null,
            child: TextField(
              controller: _emailCtrl,
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          const SizedBox(height: 14),
          // Demo Input 2 using Global Wrapper
          GlobalInputWrapper(
            label: 'Scoped Secret Key',
            prefixIcon: Icons.vpn_key_outlined,
            suffix: const Icon(Icons.lock_rounded, size: 16, color: Colors.grey),
            child: TextField(
              controller: _apiKeyCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          const SizedBox(height: 14),
          // Toggle Error State Simulation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Simulate Global Wrapper Error State',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: GlobalInputWrapperTokens.textDark,
                ),
              ),
              Switch(
                value: _simulateError,
                onChanged: (v) => setState(() => _simulateError = v),
              ),
            ],
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
            child: GlobalInputWrapperThemeConsole(),
          ),
        ),
      ),
    ),
  );
}
