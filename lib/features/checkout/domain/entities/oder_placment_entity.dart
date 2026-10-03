import 'package:equatable/equatable.dart';

import 'card_payment_session_entity.dart';

class OrderPlacementEntity extends Equatable {
  final bool isSuccess;
  final String? orderId; // <-- Add this
  final CardPaymentSessionEntity? cardSession;

  const OrderPlacementEntity({
    required this.isSuccess,
    this.orderId,
    this.cardSession,
  });

  @override
  List<Object?> get props => [isSuccess, orderId, cardSession];
}