import 'package:dio/dio.dart';
import 'package:flower_app/core/app_constants/endpoints.dart';
import 'package:flower_app/features/commerce/data/models/ProductResponse.dart';
import 'package:flower_app/features/commerce/data/models/product_details_response.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

part 'commerce_api_client.g.dart';

@singleton
@RestApi()
abstract class CommerceApiClient {
  @factoryMethod
  factory CommerceApiClient(Dio dio) = _CommerceApiClient;

  @GET(Endpoints.products)
  Future<ProductResponse> getProducts(
    @Query('pageNumber') int? pageNumber,
    @Query('pageSize') int? pageSize,
  );

  @GET(Endpoints.products)
  Future<ProductResponse> getBestSellers(
    @Query('occasionId') String occasionId,
    @Query('pageNumber') int? pageNumber,
    @Query('pageSize') int? pageSize,
  );

  @GET('/catalog/products/{id}')
  Future<ProductDetailsResponse> getProductDetails(@Path('id') String id);
}
