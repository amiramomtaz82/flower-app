import 'package:flower_app/config/base_response/base_response.dart';
import 'package:flower_app/core/pagination/paginated_response.dart';

import '../entities/category_entity.dart';
import '../entities/home_section_entity.dart';
import '../entities/occasion_entity.dart';
import '../entities/product_details_entity.dart';
import '../entities/product_entity.dart';

abstract interface class CommerceRepo {
  Future<BaseResponse<List<HomeSectionEntity>>> getHomeSections();

  Future<BaseResponse<List<CategoryEntity>>> getCategories();

  Future<BaseResponse<PaginatedResponse<OccasionEntity>>> getOccasions({
    required int pageNumber,
    required int pageSize,
  });

  Future<BaseResponse<PaginatedResponse<ProductEntity>>> getProducts({
    String? occasionId,
    required int pageNumber,
    required int pageSize,
  });

  Future<BaseResponse<List<ProductEntity>>> getProductsByCategory({
    required String categoryId,
  });

  Future<BaseResponse<ProductEntity>> getProductById({
    required String productId,
  });

  Future<BaseResponse<PaginatedResponse<ProductEntity>>> getBestSellers({
    required int page,
    required int pageSize,
    required String sort,
  });

  Future<BaseResponse<ProductDetailsEntity>> getProductDetails(String id);
}
