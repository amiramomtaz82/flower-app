import 'package:flower_app/config/base_response/base_response.dart';
import 'package:flower_app/core/pagination/paginated_response.dart';
import 'package:injectable/injectable.dart';

import '../entities/product_entity.dart';
import '../repo/commerce_repo.dart';

@injectable
class GetProductsUseCase {
  final CommerceRepo _commerceRepo;
  GetProductsUseCase(this._commerceRepo);

  Future<BaseResponse<PaginatedResponse<ProductEntity>>> call({
    String? occasionId,
    String? categoryId,
    String? keyword,
    String? sortBy,
    required int pageNumber,
    required int pageSize,
  }) {
    return _commerceRepo.getProducts(
      occasionId: occasionId,
      categoryId: categoryId,
      keyword: keyword,
      sortBy: sortBy,
      pageNumber: pageNumber,
      pageSize: pageSize,
    );
  }
}
