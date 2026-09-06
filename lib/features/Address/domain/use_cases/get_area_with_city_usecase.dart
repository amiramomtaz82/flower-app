import 'package:injectable/injectable.dart';

import '../../../../../../config/base_response/base_response.dart';
import '../entities/area_entity.dart';
import '../repo/address_repo.dart';


@lazySingleton
class GetAreasWithCitiesUseCase {
  final AddressRepo _repository;

  GetAreasWithCitiesUseCase(this._repository);

  Future<BaseResponse<List<AreaEntity>>> call() async {
    return await _repository.getAreasWithCities();
  }
}