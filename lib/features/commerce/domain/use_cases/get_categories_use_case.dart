import 'package:flower_app/config/base_response/base_response.dart';
import 'package:injectable/injectable.dart';

import '../entities/category_entity.dart';
import '../repo/commerce_repo.dart';

@injectable
class GetCategoriesUseCase {
  final CommerceRepo _commerceRepo;
  GetCategoriesUseCase(this._commerceRepo);

  Future<BaseResponse<List<CategoryEntity>>> call() {
    return _commerceRepo.getCategories();
  }
}
