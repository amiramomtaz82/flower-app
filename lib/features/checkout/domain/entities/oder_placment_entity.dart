import 'card_payment_session_entity.dart';

class OrderPlacementEntity {
  final bool isSuccess;
  final CardPaymentSessionEntity? cardSession;

  const OrderPlacementEntity({
    required this.isSuccess,
    this.cardSession,
  });
}