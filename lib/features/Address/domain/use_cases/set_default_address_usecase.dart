
import 'package:injectable/injectable.dart';
import '../../../../config/base_response/base_response.dart';
import '../entities/address_entity.dart';
import '../repo/address_repo.dart';

@lazySingleton
class SetDefaultAddressUseCase {
  final AddressRepo _repo;

  SetDefaultAddressUseCase(this._repo);

  Future<BaseResponse<AddressEntity>> call(String id) {
    return _repo.setDefaultAddress(id);
  }
}