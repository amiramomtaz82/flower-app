import 'package:injectable/injectable.dart';
import '../../../../config/base_response/base_response.dart';
import '../../../checkout/domain/entities/card_payment_session_entity.dart';
import '../entities/card_checkout_session_request_entity.dart';
import '../repo/payment_repo.dart';

@injectable
class CreateCardSessionUseCase {
  final PaymentRepository _repo;
  CreateCardSessionUseCase(this._repo);

  Future<BaseResponse<CardPaymentSessionEntity>> call(CardCheckoutSessionRequestEntity request) =>
      _repo.createCardSession(request);
}