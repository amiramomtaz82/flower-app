import 'package:flower_app/config/base_response/base_response.dart';
import 'package:flower_app/core/pagination/paginated_response.dart';
import 'package:flower_app/features/commerce/data/models/product_dto.dart';
import 'package:flower_app/features/commerce/data/models/product_details_response.dart';

abstract interface class CommerceRemoteDataSource {
  Future<BaseResponse<PaginatedResponse<ProductDTO>>> getBestSellers({
    required int page,
    required int pageSize,
    required String sort,
  });

  Future<BaseResponse<ProductDetailsDTO>> getProductDetails(String id);
}