import '../../models/category_dto.dart';
import '../../models/home_section_dto.dart';
import '../../models/occasions_data_model.dart';
import '../../models/product_details_dto.dart';
import '../../models/product_dto.dart';
import '../../models/products_data_model.dart';

abstract interface class CommerceRemoteDataSource {
  Future<List<HomeSectionDTO>> getHomeSections();

  Future<List<CategoryDTO>> getCategories();

  Future<OccasionsDataModel> getOccasions({
    required int pageNumber,
    required int pageSize,
  });

  Future<ProductsDataModel> getProducts({
    String? occasionId,
    String? categoryId,
    String? keyword,
    String? sortBy,
    required int pageNumber,
    required int pageSize,
  });

  Future<ProductDTO> getProductById({required String productId});

  /// Best sellers has no dedicated backend endpoint (confirmed with the
  /// backend team — they won't add one), so this reuses [getProducts] under
  /// a fixed occasionId the backend seeds best-sellers under.
  Future<ProductsDataModel> getBestSellers({
    required int page,
    required int pageSize,
  });

  Future<ProductDetailsDTO> getProductDetails(String productId);
}
