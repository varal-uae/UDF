import 'package:flutter/material.dart';

/// Unique styling tokens for Validated Submit Button Form.
abstract final class ValidatedSubmitTokens {
  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);

  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color validGreen = Color(0xFF16A34A);
  static const Color validGreenBg = Color(0xFFDCFCE7);
  static const Color invalidAmber = Color(0xFFD97706);
  static const Color invalidAmberBg = Color(0xFFFEF3C7);
}

/// A reactive form strictly binding Submit button active/inactive state to a validation boolean.
class ValidatedSubmitButtonFormCard extends StatefulWidget {
  final void Function(String email, String tenantId)? onSubmitSuccess;

  const ValidatedSubmitButtonFormCard({
    super.key,
    this.onSubmitSuccess,
  });

  @override
  State<ValidatedSubmitButtonFormCard> createState() =>
      _ValidatedSubmitButtonFormCardState();
}

class _ValidatedSubmitButtonFormCardState extends State<ValidatedSubmitButtonFormCard> {
  final _emailController = TextEditingController();
  final _tenantController = TextEditingController();

  bool _isTermsChecked = false;
  bool _isSubmitting = false;
  bool _isSubmitted = false;

  bool get _isEmailValid {
    final text = _emailController.text.trim();
    return RegExp(r'^[\w\.-]+@[\w-]+\.\w{2,8}$').hasMatch(text);
  }

  bool get _isTenantValid {
    return _tenantController.text.trim().length >= 6;
  }

  bool get _isFormValid => _isEmailValid && _isTenantValid && _isTermsChecked;

  int get _validCount {
    int count = 0;
    if (_isEmailValid) count++;
    if (_isTenantValid) count++;
    if (_isTermsChecked) count++;
    return count;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _tenantController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_isFormValid) return;

    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 600));

    if (mounted) {
      setState(() {
        _isSubmitting = false;
        _isSubmitted = true;
      });
      widget.onSubmitSuccess?.call(_emailController.text.trim(), _tenantController.text.trim());
    }
  }

  void _resetForm() {
    setState(() {
      _emailController.clear();
      _tenantController.clear();
      _isTermsChecked = false;
      _isSubmitted = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isValid = _isFormValid;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: ValidatedSubmitTokens.surfaceCard,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: ValidatedSubmitTokens.borderLight),
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
                  color: ValidatedSubmitTokens.primaryBlue.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.check_box_outlined,
                  color: ValidatedSubmitTokens.primaryBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Validated Submit Engine',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: ValidatedSubmitTokens.textDark,
                      ),
                    ),
                    Text(
                      'Strict Boolean Binding (MD3 Form Guidelines)',
                      style: TextStyle(
                        fontSize: 12,
                        color: ValidatedSubmitTokens.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isValid
                      ? ValidatedSubmitTokens.validGreenBg
                      : ValidatedSubmitTokens.invalidAmberBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isValid ? 'VALID' : '$_validCount / 3 REQUIRED',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isValid
                        ? ValidatedSubmitTokens.validGreen
                        : ValidatedSubmitTokens.invalidAmber,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Email field
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: 'Corporate Email',
              hintText: 'admin@enterprise.org',
              prefixIcon: const Icon(Icons.email_outlined, size: 20),
              suffixIcon: _emailController.text.isNotEmpty
                  ? Icon(
                      _isEmailValid ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                      color: _isEmailValid ? ValidatedSubmitTokens.validGreen : Colors.orange,
                      size: 20,
                    )
                  : null,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
          const SizedBox(height: 12),
          // Tenant Code Field
          TextField(
            controller: _tenantController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: 'Merchant / Tenant Code (min 6 chars)',
              hintText: 'TENANT-8921',
              prefixIcon: const Icon(Icons.vpn_key_outlined, size: 20),
              suffixIcon: _tenantController.text.isNotEmpty
                  ? Icon(
                      _isTenantValid ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                      color: _isTenantValid ? ValidatedSubmitTokens.validGreen : Colors.orange,
                      size: 20,
                    )
                  : null,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
          const SizedBox(height: 10),
          // Agreement Checkbox
          InkWell(
            onTap: () => setState(() => _isTermsChecked = !_isTermsChecked),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  Checkbox(
                    value: _isTermsChecked,
                    onChanged: (val) => setState(() => _isTermsChecked = val ?? false),
                  ),
                  const Expanded(
                    child: Text(
                      'I confirm operational SLA compliance and auth token credentials.',
                      style: TextStyle(fontSize: 12, color: ValidatedSubmitTokens.textDark),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          if (_isSubmitted) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ValidatedSubmitTokens.validGreenBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: ValidatedSubmitTokens.validGreen, size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Form successfully submitted with valid state binding.',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: ValidatedSubmitTokens.validGreen),
                    ),
                  ),
                  TextButton(
                    onPressed: _resetForm,
                    child: const Text('Reset', style: TextStyle(fontSize: 11)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          // Strictly bound Submit Button
          SizedBox(
            width: double.infinity,
            height: 48, // 48dp baseline matrix standard
            child: ElevatedButton(
              onPressed: (isValid && !_isSubmitting) ? _handleSubmit : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: ValidatedSubmitTokens.primaryBlue,
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFFE2E8F0),
                disabledForegroundColor: const Color(0xFF94A3B8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: isValid ? 2 : 0,
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(isValid ? Icons.send_rounded : Icons.lock_outline_rounded, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          isValid ? 'Submit Verified Credentials' : 'Submit Inactive (Form Invalid)',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
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

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: ValidatedSubmitButtonFormCard(),
          ),
        ),
      ),
    ),
  );
}
