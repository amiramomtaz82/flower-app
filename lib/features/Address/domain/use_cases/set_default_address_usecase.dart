import 'package:injectable/injectable.dart';

import '../../../../core/network/base_response.dart';
import '../entities/address_entity.dart';
import '../repo/address_repo.dart';

@lazySingleton
class SetDefaultAddressUseCase {
  final AddressRepo _repository;

  SetDefaultAddressUseCase(this._repository);

  Future<BaseResponse<AddressEntity>> call(
      String addressId,
      ) {
    return _repository.setDefaultAddress(addressId);
  }
}