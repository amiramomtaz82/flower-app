import 'package:injectable/injectable.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/network/base_response.dart';
import '../repo/address_repo.dart';

@injectable
class GetCurrentLocationUseCase {
  final AddressRepo _repo;
  GetCurrentLocationUseCase(this._repo);

  Future<BaseResponse<LatLng>> call({bool requestIfDenied = true}) {
    return _repo.getCurrentLocation(requestIfDenied: requestIfDenied);
  }
}