import 'package:equatable/equatable.dart';
import '../../data/models/cod_payment_request.dart';

class CodPaymentRequestEntity extends Equatable {
  final String orderId;
  final double amount;
  final String currency;

  const CodPaymentRequestEntity({
    required this.orderId,
    required this.amount,
    this.currency = 'EGP',
  });

  /// Maps Entity to Data Transfer Object (DTO)
  CodPaymentRequest toDto() {
    return CodPaymentRequest(
      orderId: orderId,
      amount: amount,
      currency: currency,
    );
  }

  @override
  List<Object?> get props => [orderId, amount, currency];
}