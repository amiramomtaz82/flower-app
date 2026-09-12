
import 'package:injectable/injectable.dart';

import '../../../../core/network/base_response.dart';

import '../repo/address_repo.dart';

@injectable
class DeleteAddressUseCase {
  final AddressRepo _addressRepo;

  DeleteAddressUseCase(this._addressRepo);

  Future<BaseResponse<void>> call(String id) {
    return _addressRepo.deleteAddress(id);
  }
}