import 'package:flower_app/core/location/location_model.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/network/base_response.dart';
import '../repo/address_repo.dart';

@injectable
class ReverseGeocodeUseCase {
  final AddressRepo _repo;
  ReverseGeocodeUseCase(this._repo);

  Future<BaseResponse<LocationModel>> call({
    required double lat,
    required double lng,
  }) => _repo.reverseGeocode(lat: lat, lng: lng);
}