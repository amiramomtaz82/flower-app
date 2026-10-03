import 'package:equatable/equatable.dart';

class PaymentStatusEntity extends Equatable {
  final String orderId;
  final String status; // "Paid", "PendingPayment", "Failed", "Cancelled"
  final double amount;
  final String currency;
  final String? paymentMethod;
  final String? transactionId;

  const PaymentStatusEntity({
    required this.orderId,
    required this.status,
    required this.amount,
    required this.currency,
    this.paymentMethod,
    this.transactionId,
  });

  bool get isPaid => status.toLowerCase() == 'paid';
  bool get isFailed => status.toLowerCase() == 'failed' || status.toLowerCase() == 'cancelled';
  bool get isPending => status.toLowerCase() == 'pendingpayment' || status.toLowerCase() == 'pending';

  @override
  List<Object?> get props => [orderId, status, amount, currency, paymentMethod, transactionId];
}