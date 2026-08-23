import '../../models/category_dto.dart';
import '../../models/occasions_data_model.dart';
import '../../models/product_dto.dart';
import '../../models/products_data_model.dart';

abstract interface class CommerceRemoteDataSource {
  Future<List<CategoryDTO>> getCategories();

  Future<OccasionsDataModel> getOccasions({
    required int pageNumber,
    required int pageSize,
  });

  Future<ProductsDataModel> getProducts({
    String? occasionId,
    required int pageNumber,
    required int pageSize,
  });

  Future<List<ProductDTO>> getProductsByCategory({required String categoryId});

  Future<ProductDTO> getProductById({required String productId});
}
