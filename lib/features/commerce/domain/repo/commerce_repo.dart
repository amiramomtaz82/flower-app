import 'package:flower_app/core/domain/result.dart';
import 'package:flower_app/core/pagination/paginated_response.dart';
import 'package:flower_app/features/commerce/domain/entities/product_entity.dart';
import 'package:flower_app/features/commerce/domain/entities/product_details_entity.dart';

abstract interface class CommerceRepo {
  Future<Result<PaginatedResponse<ProductEntity>>> getBestSellers({
    required int page,
    required int pageSize,
    required String sort,
  });

  Future<Result<ProductDetailsEntity>> getProductDetails(String id);
}