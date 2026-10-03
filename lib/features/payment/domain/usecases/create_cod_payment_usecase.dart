import 'package:injectable/injectable.dart';
import '../../../../config/base_response/base_response.dart';
import '../entities/cod_payment_entity.dart';
import '../entities/cod_payment_request_entity.dart';
import '../repo/payment_repo.dart';

@injectable
class CreateCodPaymentUseCase {
  final PaymentRepository _repo;
  CreateCodPaymentUseCase(this._repo);

  Future<BaseResponse<CodPaymentEntity>> call(CodPaymentRequestEntity request) =>
      _repo.createCodPayment(request);
}