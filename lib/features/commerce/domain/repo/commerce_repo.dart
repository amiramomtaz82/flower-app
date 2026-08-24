import 'package:flower_app/config/base_response/base_response.dart';
import 'package:flower_app/core/pagination/paginated_response.dart';
import 'package:flower_app/features/commerce/domain/entities/product_entity.dart';
import 'package:flower_app/features/commerce/domain/entities/product_details_entity.dart';

abstract interface class CommerceRepo {
  Future<BaseResponse<PaginatedResponse<ProductEntity>>> getBestSellers({
    required int page,
    required int pageSize,
    required String sort,
  });

  Future<BaseResponse<ProductDetailsEntity>> getProductDetails(String id);
}