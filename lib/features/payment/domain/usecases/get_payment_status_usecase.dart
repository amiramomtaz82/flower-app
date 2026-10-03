import 'package:injectable/injectable.dart';
import '../../../../config/base_response/base_response.dart';
import '../entities/payment_status_entity.dart';
import '../repo/payment_repo.dart';

@injectable
class GetPaymentStatusUseCase {
  final PaymentRepository _repo;
  GetPaymentStatusUseCase(this._repo);

  Future<BaseResponse<PaymentStatusEntity>> call(String orderId) =>
      _repo.getPaymentStatus(orderId);
}