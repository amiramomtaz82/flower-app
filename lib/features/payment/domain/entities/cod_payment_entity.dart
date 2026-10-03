import 'package:equatable/equatable.dart';

class CodPaymentEntity extends Equatable {
  final String orderId;
  final String status;
  final String paymentMethod;

  const CodPaymentEntity({
    required this.orderId,
    required this.status,
    required this.paymentMethod,
  });

  @override
  List<Object?> get props => [orderId, status, paymentMethod];
}