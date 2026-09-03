import 'package:injectable/injectable.dart';

import '../../../../core/network/base_response.dart';
import '../entities/add_address_entity.dart';
import '../entities/address_entity.dart';
import '../repo/address_repo.dart';

@lazySingleton
class UpdateAddressUseCase {
  final AddressRepo _repository;

  UpdateAddressUseCase(this._repository);

  Future<BaseResponse<AddressEntity>> call(
      String addressId,
      AddAddressEntity address,
      ) {
    return _repository.updateAddress(addressId, address);
  }
}
