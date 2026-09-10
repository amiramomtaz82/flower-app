
import 'package:injectable/injectable.dart';

import '../../../../core/network/base_response.dart';
import '../entities/address_entity.dart';
import '../repo/address_repo.dart';

@injectable
class UpdateAddressUseCase {
  final AddressRepo _addressRepo;

  UpdateAddressUseCase(this._addressRepo);

  Future<BaseResponse<AddressEntity>> call({
    required String id,
    required AddressEntity address,
  }) {
    return _addressRepo.updateAddress(id: id, address: address);
  }
}