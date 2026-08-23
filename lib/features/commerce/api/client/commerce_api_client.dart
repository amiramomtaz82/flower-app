import 'package:dio/dio.dart';
import 'package:flower_app/core/app_constants/endpoints.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../../data/models/categories_response_model.dart';
import '../../data/models/occasions_response_model.dart';
import '../../data/models/product_response_model.dart';
import '../../data/models/products_by_category_response_model.dart';
import '../../data/models/products_response_model.dart';
part 'commerce_api_client.g.dart';

@singleton
@RestApi()
abstract class CommerceApiClient {
  @factoryMethod
  factory CommerceApiClient(Dio dio) = _CommerceApiClient;

  @GET(Endpoints.categories)
  Future<CategoriesResponseModel> getCategories();

  @GET(Endpoints.occasions)
  Future<OccasionsResponseModel> getOccasions(
    @Query('pageNumber') int pageNumber,
    @Query('pageSize') int pageSize,
  );

  @GET(Endpoints.products)
  Future<ProductsResponseModel> getProducts(
    @Query('occasionId') String? occasionId,
    @Query('pageNumber') int pageNumber,
    @Query('pageSize') int pageSize,
  );

  @GET(Endpoints.productsByCategory)
  Future<ProductsByCategoryResponseModel> getProductsByCategory(
    @Query('categoryId') String categoryId,
  );

  @GET(Endpoints.productById)
  Future<ProductResponseModel> getProductById(
    @Path('productId') String productId,
  );
}
