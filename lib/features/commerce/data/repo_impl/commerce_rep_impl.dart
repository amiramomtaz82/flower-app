import 'package:flower_app/config/base_response/base_response.dart';
import 'package:flower_app/core/pagination/paginated_response.dart';
import 'package:flower_app/features/commerce/data/data_sorce/remote/commerce_remote_data_source.dart';
import 'package:flower_app/features/commerce/domain/entities/product_entity.dart';
import 'package:flower_app/features/commerce/domain/entities/product_details_entity.dart';
import 'package:flower_app/features/commerce/domain/repo/commerce_repo.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: CommerceRepo)
class CommerceRepImpl implements CommerceRepo {
  final CommerceRemoteDataSource _remoteDataSource;

  CommerceRepImpl(this._remoteDataSource);

  @override
  Future<BaseResponse<PaginatedResponse<ProductEntity>>> getBestSellers({
    required int page,
    required int pageSize,
    required String sort,
  }) async {
    final result = await _remoteDataSource.getBestSellers(
      page: page,
      pageSize: pageSize,
      sort: sort,
    );

    switch (result) {
      case SuccessResponse():
        final entities = result.data.data.map((dto) => ProductEntity(
              id: dto.id?.toString(),
              name: dto.name,
              imageUrl: dto.imageUrl,
              currency: dto.currency,
              price: dto.price,
              originalPrice: dto.originalPrice,
              discountPercentage: dto.discountPercentage,
              status: dto.status,
            )).toList();
        return SuccessResponse(
          PaginatedResponse(
            data: entities,
            pagination: result.data.pagination,
          ),
        );
      case ErrorResponse():
        return ErrorResponse(error: result.error, errMessage: result.errMessage);
    }
  }

  @override
  Future<BaseResponse<ProductDetailsEntity>> getProductDetails(String id) async {
    final result = await _remoteDataSource.getProductDetails(id);

    switch (result) {
      case SuccessResponse():
        final dto = result.data;
        return SuccessResponse(
          ProductDetailsEntity(
            id: dto.id?.toString(),
            name: dto.name,
            imageUrl: dto.imageUrl,
            currency: dto.currency,
            price: dto.price,
            originalPrice: dto.originalPrice,
            discountPercentage: dto.discountPercentage,
            status: dto.status,
            images: dto.images,
            description: dto.description,
            includes: dto.includes?.map((i) => IncludeEntity(name: i.name)).toList(),
            categoryId: dto.categoryId,
            occasionIds: dto.occasionIds,
          ),
        );
      case ErrorResponse():
        return ErrorResponse(error: result.error, errMessage: result.errMessage);
    }
  }
}