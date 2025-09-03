enum PaymentStatus {
  pending,
  paid,
  refunded,
  failed,
}

extension PaymentStatusExtension on PaymentStatus {
  String get value {
    switch (this) {
      case PaymentStatus.pending:
        return 'pending';
      case PaymentStatus.paid:
        return 'paid';
      case PaymentStatus.refunded:
        return 'refunded';
      case PaymentStatus.failed:
        return 'failed';
      default:
        return 'pending';
    }
  }

  String get arabicLabel {
    switch (this) {
      case PaymentStatus.pending:
        return 'قيد الانتظار';
      case PaymentStatus.paid:
        return 'مدفوع';
      case PaymentStatus.refunded:
        return 'تم الاسترداد';
      case PaymentStatus.failed:
        return 'فشل الدفع';
      default:
        return 'غير معروف';
    }
  }

  static PaymentStatus fromString(String value) {
    return PaymentStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => PaymentStatus.pending,
    );
  }
}