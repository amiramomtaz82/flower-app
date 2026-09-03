import 'package:injectable/injectable.dart';

import '../../../../core/network/base_response.dart';
import '../entities/address_entity.dart';
import '../repo/address_repo.dart';

@lazySingleton
class GetAddressByIdUseCase {
  final AddressRepo _repository;

  GetAddressByIdUseCase(this._repository);

  Future<BaseResponse<AddressEntity>> call(String addressId) {
    return _repository.getAddressById(addressId);
  }
}
