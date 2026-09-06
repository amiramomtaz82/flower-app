class CardPaymentSessionEntity {
  final String orderId;
  final String status;
  final String gateway;
  final String sessionId;
  final String sessionUrl;
  final String successUrl;
  final String cancelUrl;
  final String expiresAt;
  final double amount;
  final String currency;
  final String estimatedDeliveryAt;

  const CardPaymentSessionEntity({
    required this.orderId,
    required this.status,
    required this.gateway,
    required this.sessionId,
    required this.sessionUrl,
    required this.successUrl,
    required this.cancelUrl,
    required this.expiresAt,
    required this.amount,
    required this.currency,
    required this.estimatedDeliveryAt,
  });
}