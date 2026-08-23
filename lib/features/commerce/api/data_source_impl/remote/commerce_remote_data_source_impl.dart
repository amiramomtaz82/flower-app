import 'package:injectable/injectable.dart';

import '../../../data/data_sorce/remote/commerce_remote_data_source.dart';
import '../../../data/models/category_dto.dart';
import '../../../data/models/occasions_data_model.dart';
import '../../../data/models/product_dto.dart';
import '../../../data/models/products_data_model.dart';
import '../../client/commerce_api_client.dart';

@Injectable(as: CommerceRemoteDataSource)
class CommerceRemoteDataSourceImpl implements CommerceRemoteDataSource {
  final CommerceApiClient _commerceApiClient;

  CommerceRemoteDataSourceImpl(this._commerceApiClient);

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
    required int pageNumber,
    required int pageSize,
  }) async {
    final response = await _commerceApiClient.getProducts(
      occasionId,
      pageNumber,
      pageSize,
    );
    return response.data;
  }

  @override
  Future<List<ProductDTO>> getProductsByCategory({
    required String categoryId,
  }) async {
    final response = await _commerceApiClient.getProductsByCategory(
      categoryId,
    );
    return response.data;
  }

  @override
  Future<ProductDTO> getProductById({required String productId}) async {
    final response = await _commerceApiClient.getProductById(productId);
    return response.data;
  }
}
