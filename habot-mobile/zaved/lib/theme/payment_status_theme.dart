import 'package:flutter/material.dart';
import 'app_design_tokens.dart';

class PaymentStatusTheme extends ThemeExtension<PaymentStatusTheme> {
  const PaymentStatusTheme({
    required this.errorContainer,
    required this.onErrorContainer,
    required this.successContainer,
    required this.onSuccessContainer,
  });

  final Color errorContainer;
  final Color onErrorContainer;
  final Color successContainer;
  final Color onSuccessContainer;

  /// M3 Light Theme implementation of PaymentStatusTheme (SCTAS-013)
  static const light = PaymentStatusTheme(
    errorContainer: AppDesignTokens.paymentStatusErrorContainer,
    onErrorContainer: AppDesignTokens.paymentStatusOnErrorContainer,
    successContainer: AppDesignTokens.paymentStatusSuccessContainer,
    onSuccessContainer: AppDesignTokens.paymentStatusOnSuccessContainer,
  );

  @override
  PaymentStatusTheme copyWith({
    Color? errorContainer,
    Color? onErrorContainer,
    Color? successContainer,
    Color? onSuccessContainer,
  }) {
    return PaymentStatusTheme(
      errorContainer: errorContainer ?? this.errorContainer,
      onErrorContainer: onErrorContainer ?? this.onErrorContainer,
      successContainer: successContainer ?? this.successContainer,
      onSuccessContainer: onSuccessContainer ?? this.onSuccessContainer,
    );
  }

  @override
  PaymentStatusTheme lerp(ThemeExtension<PaymentStatusTheme>? other, double t) {
    if (other is! PaymentStatusTheme) {
      return this;
    }

    return PaymentStatusTheme(
      errorContainer:
          Color.lerp(errorContainer, other.errorContainer, t) ?? errorContainer,
      onErrorContainer:
          Color.lerp(onErrorContainer, other.onErrorContainer, t) ??
          onErrorContainer,
      successContainer:
          Color.lerp(successContainer, other.successContainer, t) ??
          successContainer,
      onSuccessContainer:
          Color.lerp(onSuccessContainer, other.onSuccessContainer, t) ??
          onSuccessContainer,
    );
  }

  @override
  int get hashCode => Object.hash(
    errorContainer,
    onErrorContainer,
    successContainer,
    onSuccessContainer,
  );

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is PaymentStatusTheme &&
            other.errorContainer == errorContainer &&
            other.onErrorContainer == onErrorContainer &&
            other.successContainer == successContainer &&
            other.onSuccessContainer == onSuccessContainer;
  }
}
