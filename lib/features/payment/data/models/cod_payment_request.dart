class CodPaymentRequest {
  final String orderId;
  final double amount;
  final String currency;

  CodPaymentRequest({
    required this.orderId,
    required this.amount,
    this.currency = 'EGP',
  });

  Map<String, dynamic> toJson() => {
    'orderId': orderId,
    'amount': amount,
    'currency': currency,
  };


}