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

  @override
  List<Object?> get props => [orderId, status, amount, currency, paymentMethod, transactionId];
}