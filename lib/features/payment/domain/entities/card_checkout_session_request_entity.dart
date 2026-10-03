import 'package:equatable/equatable.dart';
import '../../data/models/card_checkout_session_request.dart';

class CardCheckoutSessionRequestEntity extends Equatable {
  final String orderId;
  final double amount;
  final String currency;
  final String customerEmail;
  final String customerFirstName;
  final String customerLastName;
  final String customerPhone;

  const CardCheckoutSessionRequestEntity({
    required this.orderId,
    required this.amount,
    this.currency = 'EGP',
    required this.customerEmail,
    required this.customerFirstName,
    required this.customerLastName,
    required this.customerPhone,
  });

  /// Maps Entity to Data Transfer Object (DTO)
  CardCheckoutSessionRequest toDto() {
    return CardCheckoutSessionRequest(
      orderId: orderId,
      amount: amount,
      currency: currency,
      customerEmail: customerEmail,
      customerFirstName: customerFirstName,
      customerLastName: customerLastName,
      customerPhone: customerPhone,
    );
  }

  @override
  List<Object?> get props => [
    orderId,
    amount,
    currency,
    customerEmail,
    customerFirstName,
    customerLastName,
    customerPhone,
  ];
}