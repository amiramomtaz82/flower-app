class CardCheckoutSessionRequest {
  final String orderId;
  final double amount;
  final String currency;
  final String customerEmail;
  final String customerFirstName;
  final String customerLastName;
  final String customerPhone;

  CardCheckoutSessionRequest({
    required this.orderId,
    required this.amount,
    this.currency = 'EGP',
    required this.customerEmail,
    required this.customerFirstName,
    required this.customerLastName,
    required this.customerPhone,
  });

  Map<String, dynamic> toJson() => {
    'orderId': orderId,
    'amount': amount,
    'currency': currency,
    'customerEmail': customerEmail,
    'customerFirstName': customerFirstName,
    'customerLastName': customerLastName,
    'customerPhone': customerPhone,
  };
}