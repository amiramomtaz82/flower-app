import 'package:injectable/injectable.dart';

import '../../../../../core/app_constants/endpoints.dart';
import '../../../data/data_sorce/remote/commerce_remote_data_source.dart';
import '../../../data/models/category_dto.dart';
import '../../../data/models/home_section_dto.dart';
import '../../../data/models/occasions_data_model.dart';
import '../../../data/models/product_details_dto.dart';
import '../../../data/models/product_dto.dart';
import '../../../data/models/products_data_model.dart';
import '../../client/commerce_api_client.dart';

@Injectable(as: CommerceRemoteDataSource)
class CommerceRemoteDataSourceImpl implements CommerceRemoteDataSource {
  final CommerceApiClient _commerceApiClient;

  CommerceRemoteDataSourceImpl(this._commerceApiClient);

  @override
  Future<List<HomeSectionDTO>> getHomeSections() async {
    final response = await _commerceApiClient.getHomeSections();
    return response.data;
  }

  @override
  Future<List<CategoryDTO>> getCategories() async {
    final response = await _commerceApiClient.getCategories();
    return response.data;
  }

  @override
  Future<OccasionsDataModel> getOccasions({
    required int pageNumber,
    required int pageSize,
  }) async {
    final response = await _commerceApiClient.getOccasions(
      pageNumber,
      pageSize,
    );
    return response.data;
  }

  @override
  Future<ProductsDataModel> getProducts({
    String? occasionId,
    String? categoryId,
    String? keyword,
    String? sortBy,
    required int pageNumber,
    required int pageSize,
  }) async {
    final response = await _commerceApiClient.getProducts(
      occasionId: occasionId,
      categoryId: categoryId,
      keyword: keyword,
      sortBy: sortBy,
      pageNumber: pageNumber,
      pageSize: pageSize,
    );
    return response.data;
  }

  @override
  Future<ProductDTO> getProductById({required String productId}) async {
    final response = await _commerceApiClient.getProductById(productId);
    return response.data;
  }

  @override
  Future<ProductsDataModel> getBestSellers({
    required int page,
    required int pageSize,
  }) async {
    final response = await _commerceApiClient.getProducts(
      occasionId: Endpoints.bestSellersOccasionId,
      pageNumber: page,
      pageSize: pageSize,
    );
    return response.data;
  }

  @override
  Future<ProductDetailsDTO> getProductDetails(String productId) async {
    final response = await _commerceApiClient.getProductDetails(productId);
    return response.data;
  }
}
