

import 'package:injectable/injectable.dart';

import '../../../../core/network/base_response.dart';
import '../entities/address_entity.dart';
import '../repo/address_repo.dart';

@LazySingleton()
class GetSavedAddressesUseCase {
  final AddressRepo addressRepo;

  GetSavedAddressesUseCase(this.addressRepo);

  Future<BaseResponse<List<AddressEntity>>> call() {
    return addressRepo.getSavedAddresses();
  }
}