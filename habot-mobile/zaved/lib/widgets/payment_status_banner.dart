import 'package:flutter/material.dart';
import '../theme/payment_status_theme.dart';

class PaymentStatusBanner extends StatelessWidget {
  const PaymentStatusBanner({
    super.key,
    required this.isSuccess,
    this.message,
  });

  final bool isSuccess;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final paymentTheme = Theme.of(context).extension<PaymentStatusTheme>()!;
    final backgroundColor = isSuccess
        ? paymentTheme.successContainer
        : paymentTheme.errorContainer;
    final textColor = isSuccess
        ? paymentTheme.onSuccessContainer
        : paymentTheme.onErrorContainer;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isSuccess ? Icons.check_circle : Icons.error, color: textColor),
          const SizedBox(width: 12.0),
          Flexible(
            child: Text(
              message ?? (isSuccess ? 'Payment Successful' : 'Payment Failed'),
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: textColor),
            ),
          ),
        ],
      ),
    );
  }
}
