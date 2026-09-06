import 'package:injectable/injectable.dart';

import '../../../../core/network/base_response.dart';
import '../entities/add_address_entity.dart';
import '../entities/address_entity.dart';
import '../repo/address_repo.dart';

@LazySingleton()
class AddAddressUseCase {
  final AddressRepo addressRepo;

  AddAddressUseCase(this.addressRepo);

  Future<BaseResponse<AddressEntity>> call(
      AddAddressEntity address,
      ) {
    return addressRepo.addAddress(address);
  }
}