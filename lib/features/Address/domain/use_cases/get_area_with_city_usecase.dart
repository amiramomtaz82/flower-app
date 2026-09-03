import 'package:injectable/injectable.dart';

import '../../../../../../config/base_response/base_response.dart';
import '../entities/city_entity.dart';
import '../repo/address_repo.dart';


@lazySingleton
class GetAreasWithCitiesUseCase {
  final AddressRepo _repository;

  GetAreasWithCitiesUseCase(this._repository);

  Future<BaseResponse<List<CityEntity>>> call() async {
    return await _repository.getAreasWithCities();
  }
}