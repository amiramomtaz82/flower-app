import 'package:flower_app/config/base_response/base_response.dart';
import 'package:flower_app/core/pagination/paginated_response.dart';
import 'package:flower_app/core/pagination/pagination_model.dart';
import 'package:flower_app/core/app_constants/endpoints.dart';
import 'package:flower_app/features/commerce/api/client/commerce_api_client.dart';
import 'package:flower_app/features/commerce/data/data_sorce/remote/commerce_remote_data_source.dart';
import 'package:flower_app/features/commerce/data/models/product_dto.dart';
import 'package:flower_app/features/commerce/data/models/product_details_response.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: CommerceRemoteDataSource)
class CommerceRemoteDataSourceImpl implements CommerceRemoteDataSource {
  final CommerceApiClient _apiClient;

  CommerceRemoteDataSourceImpl(this._apiClient);

  @override
  Future<BaseResponse<PaginatedResponse<ProductDTO>>> getBestSellers({
    required int page,
    required int pageSize,
    required String sort,
  }) async {
    try {
      final response = await _apiClient.getBestSellers(
        Endpoints.bestSellersOccasionId,
        page,
        pageSize,
      );
      final items = response.data?.items ?? [];
      final pagination = response.data?.pagination ?? PaginationModel();
      return SuccessResponse(
        PaginatedResponse(data: items, pagination: pagination),
      );
    } catch (e) {
      return ErrorResponse(errMessage: e.toString());
    }
  }

  @override
  Future<BaseResponse<ProductDetailsDTO>> getProductDetails(String id) async {
    try {
      final response = await _apiClient.getProductDetails(id);
      if (response.data != null) {
        return SuccessResponse(response.data!);
      } else {
        return ErrorResponse(errMessage: response.message ?? 'Product not found');
      }
    } catch (e) {
      return ErrorResponse(errMessage: e.toString());
    }
  }
}