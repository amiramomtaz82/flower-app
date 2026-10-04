import '../../domain/entities/payment_status_entity.dart';

class PaymentStatusResponse {
  final bool isSuccess;
  final String statusCode;
  final PaymentStatusDto? data;
  final String? message;

  PaymentStatusResponse({
    required this.isSuccess,
    required this.statusCode,
    this.data,
    this.message,
  });

  factory PaymentStatusResponse.fromJson(Map<String, dynamic> json) {
    return PaymentStatusResponse(
      isSuccess: json['isSuccess'] ?? false,
      statusCode: json['statusCode']?.toString() ?? '',
      data: json['data'] != null ? PaymentStatusDto.fromJson(json['data']) : null,
      message: json['message'],
    );
  }
}

class PaymentStatusDto {
  final String orderId;
  final String status; // "Paid", "PendingPayment", "Failed", "Cancelled"
  final double amount;
  final String currency;
  final String? paymentMethod;
  final String? transactionId;

  PaymentStatusDto({
    required this.orderId,
    required this.status,
    required this.amount,
    required this.currency,
    this.paymentMethod,
    this.transactionId,
  });

  factory PaymentStatusDto.fromJson(Map<String, dynamic> json) {
    return PaymentStatusDto(
      orderId: json['orderId'] ?? '',
      status: json['status'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] ?? 'EGP',
      paymentMethod: json['paymentMethod'],
      transactionId: json['transactionId']?.toString(),
    );
  }

  bool get isPaid {
    final s = status.toLowerCase().trim();
    return s == 'paid' ||
        s == 'success' ||
        s == 'completed' ||
        s == 'approved' ||
        s == 'captured';
  }

  bool get isFailed {
    final s = status.toLowerCase().trim();
    return s == 'failed' ||
        s == 'cancelled' ||
        s == 'canceled' ||
        s == 'declined' ||
        s == 'rejected';
  }

  bool get isPending {
    final s = status.toLowerCase().trim();
    return s == 'pendingpayment' ||
        s == 'pending' ||
        s == 'initiated' ||
        s == 'created';
  }

  PaymentStatusEntity toEntity() {
    return PaymentStatusEntity(
      orderId: orderId,
      status: status,
      amount: amount,
      currency: currency,
      paymentMethod: paymentMethod,
      transactionId: transactionId,
    );
  }
}