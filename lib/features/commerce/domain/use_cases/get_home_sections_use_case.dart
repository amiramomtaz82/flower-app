import 'package:flower_app/config/base_response/base_response.dart';
import 'package:injectable/injectable.dart';

import '../entities/home_section_entity.dart';
import '../repo/commerce_repo.dart';

@injectable
class GetHomeSectionsUseCase {
  final CommerceRepo _commerceRepo;
  GetHomeSectionsUseCase(this._commerceRepo);

  Future<BaseResponse<List<HomeSectionEntity>>> call() {
    return _commerceRepo.getHomeSections();
  }
}
