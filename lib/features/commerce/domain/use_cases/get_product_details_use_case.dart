import 'package:flower_app/core/domain/result.dart';
import 'package:flower_app/features/commerce/domain/entities/product_details_entity.dart';
import 'package:flower_app/features/commerce/domain/repo/commerce_repo.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetProductDetailsUseCase {
  final CommerceRepo _repo;

  GetProductDetailsUseCase(this._repo);

  Future<Result<ProductDetailsEntity>> call(String id) {
    return _repo.getProductDetails(id);
  }
}
