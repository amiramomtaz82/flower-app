import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../../data/models/ProductResponse.dart';
part 'commerce_api_client.g.dart';

@singleton
@RestApi()
abstract class CommerceApiClient {
  @factoryMethod
  factory CommerceApiClient(Dio dio) = _CommerceApiClient;

  @GET("/products")
  Future<ProductResponse> getProducts();



}
