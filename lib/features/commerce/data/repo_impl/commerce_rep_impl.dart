import 'package:dio/dio.dart';
import 'package:flower_app/config/base_response/base_response.dart';
import 'package:flower_app/core/pagination/pagination_model.dart';
import 'package:flower_app/core/pagination/paginated_response.dart';
import 'package:flower_app/features/commerce/data/data_sorce/remote/commerce_remote_data_source.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/category_entity.dart';
import '../../domain/entities/occasion_entity.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repo/commerce_repo.dart';

@Injectable(as: CommerceRepo)
class CommerceRepImpl implements CommerceRepo {
  final CommerceRemoteDataSource _commerceRemoteDataSource;
  CommerceRepImpl(this._commerceRemoteDataSource);

  @override
  Future<BaseResponse<List<CategoryEntity>>> getCategories() async {
    try {
      final categories = await _commerceRemoteDataSource.getCategories();
      return SuccessResponse(categories.map((c) => c.toEntity()).toList());
    } on DioException catch (e) {
      return ErrorResponse(error: e);
    }
  }

  @override
  Future<BaseResponse<PaginatedResponse<OccasionEntity>>> getOccasions({
    required int pageNumber,
    required int pageSize,
  }) async {
    try {
      final occasions = await _commerceRemoteDataSource.getOccasions(
        pageNumber: pageNumber,
        pageSize: pageSize,
      );

      return SuccessResponse(
        PaginatedResponse<OccasionEntity>(
          data: occasions.items.map((o) => o.toEntity()).toList(),
          pagination: PaginationModel(
            page: occasions.pageNumber,
            pageSize: occasions.pageSize,
            totalCount: occasions.totalCount,
            totalPages: occasions.totalPages,
            hasNextPage: occasions.hasNextPage,
            hasPreviousPage: occasions.hasPreviousPage,
          ),
        ),
      );
    } on DioException catch (e) {
      return ErrorResponse(error: e);
    }
  }

  @override
  Future<BaseResponse<PaginatedResponse<ProductEntity>>> getProducts({
    String? occasionId,
    required int pageNumber,
    required int pageSize,
  }) async {
    try {
      final products = await _commerceRemoteDataSource.getProducts(
        occasionId: occasionId,
        pageNumber: pageNumber,
        pageSize: pageSize,
      );

      return SuccessResponse(
        PaginatedResponse<ProductEntity>(
          data: products.items.map((p) => p.toEntity()).toList(),
          pagination: PaginationModel(
            page: products.pageNumber,
            pageSize: products.pageSize,
            totalCount: products.totalCount,
            totalPages: products.totalPages,
            hasNextPage: products.hasNextPage,
            hasPreviousPage: products.hasPreviousPage,
          ),
        ),
      );
    } on DioException catch (e) {
      return ErrorResponse(error: e);
    }
  }

  @override
  Future<BaseResponse<List<ProductEntity>>> getProductsByCategory({
    required String categoryId,
  }) async {
    try {
      final products = await _commerceRemoteDataSource.getProductsByCategory(
        categoryId: categoryId,
      );
      return SuccessResponse(products.map((p) => p.toEntity()).toList());
    } on DioException catch (e) {
      return ErrorResponse(error: e);
    }
  }

  @override
  Future<BaseResponse<ProductEntity>> getProductById({
    required String productId,
  }) async {
    try {
      final product = await _commerceRemoteDataSource.getProductById(
        productId: productId,
      );
      return SuccessResponse(product.toEntity());
    } on DioException catch (e) {
      return ErrorResponse(error: e);
    }
  }
}
