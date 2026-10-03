import 'package:injectable/injectable.dart';
import '../../../../config/base_response/base_response.dart';
import '../../../checkout/domain/entities/card_payment_session_entity.dart';
import '../repo/payment_repo.dart';

@injectable
class RetryPaymentUseCase {
  final PaymentRepository _repo;
  RetryPaymentUseCase(this._repo);

  Future<BaseResponse<CardPaymentSessionEntity>> call(String orderId) =>
      _repo.retryPayment(orderId);
}